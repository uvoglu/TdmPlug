//
//  TdmController.m
//  tdmplug
//
//  Created by Simon Schuhmacher on 13.11.18.
//  Copyright © 2018 Simon Schuhmacher. All rights reserved.
//

#import "TdmController.h"

#include <sys/types.h>
#include <sys/sysctl.h>

#import "TdmHid.h"

@interface TdmController ()

@property (nonatomic, strong) TdmThunderboltObserver *thunderboltObserver;
@property (nonatomic, strong) id clientUserActivity;
@property (nonatomic) BOOL isClient;

@end

@implementation TdmController

+ (NSString *)machineModel {
    size_t len = 0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    
    if (len) {
        char *model = malloc(len * sizeof(char));
        sysctlbyname("hw.model", model, &len, NULL, 0);
        NSString *model_ns = [NSString stringWithUTF8String:model];
        free(model);
        NSLog(@"Running on %@.", model_ns);
        return model_ns;
    }
    
    return @"Unknown";
}

+ (void)initialize {
}
- (id)init {
    self = [super init];
    self.isClient = [[TdmController machineModel] rangeOfString:@"iMac"].location == NSNotFound;
    
    if (!self.isClient) {
        self.thunderboltObserver = [[TdmThunderboltObserver alloc] initWithDelegate:self];
        [self.thunderboltObserver startObserving];
        
        self.clientUserActivity = [[NSProcessInfo processInfo]beginActivityWithOptions:NSActivityIdleSystemSleepDisabled reason:@"Checking for connections"];
    }
    
    return self;
}

- (void)dealloc {
    [[NSProcessInfo processInfo]endActivity:self.clientUserActivity];
}

- (NSString *)modeString {
    if (self.isClient) {
        return NSLocalizedString(@"Client Mode", comment:nil);
    } else {
        return NSLocalizedString(@"Host Mode", comment:nil);
    }
}

- (void)awakeFromNib {
    
    if (self.isClient) {
        NSLog(@"Running in client mode.");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeScreenParametersNotification:) name:NSApplicationDidChangeScreenParametersNotification object:nil];
        [self updateConnectionState:[self clientIsInTargetDisplayMode]];
    } else {
        NSLog(@"Running in host mode.");
    }
    
}

#pragma mark - NSApplicationDidChangeScreenParametersNotification

- (void)applicationDidChangeScreenParametersNotification:(NSNotification *)notifcation {
    
    [self updateConnectionState:[self clientIsInTargetDisplayMode]];
}


#pragma mark - TdmThunderboltObserverDelegate

- (void)thunderboltObserverDeviceConnected:(TdmThunderboltObserver *)observer {
    NSLog(@"Thunderbolt device connected.");
    [self updateConnectionState:YES];
    
    [self enableTargetDisplayMode];
    
}

- (void)thunderboltObserverDeviceDisconnected:(TdmThunderboltObserver *)observer {
    NSLog(@"Thunderbolt device disconnected.");
    [self updateConnectionState:NO];
    
    [self disableTargetDisplayMode];
    
}

- (void)thunderboltObserver:(TdmThunderboltObserver *)observer isInitiallyConnected:(BOOL)connected {
    [self updateConnectionState:connected];
    
    if (connected) {
        [self enableTargetDisplayMode];
    }
}

- (void)updateConnectionState:(BOOL)connected {
    
    if (!self.isClient) {
        return;
    }
    if (connected && [self clientIsInTargetDisplayMode]) {
    } else {
        [self disableTargetDisplayMode];
    }
}

#pragma mark - Helpers

- (void)enableTargetDisplayMode {
    NSLog(@"Attempting to enable TDM.");
    if (self.thunderboltObserver.isInTargetDisplayMode || self.clientIsInTargetDisplayMode) {
        NSLog(@"Early return when attempting to enable TDM.");
        return;
    }
    
    // emulate keypress with foohid
    toggleTdmHid();
    
    
//    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
//
//    CGEventRef f2d = CGEventCreateKeyboardEvent(src, 0x90, true);
//    CGEventRef f2u = CGEventCreateKeyboardEvent(src, 0x90, false);
//
//    CGEventSetFlags(f2d, kCGEventFlagMaskSecondaryFn | kCGEventFlagMaskCommand);
//    CGEventSetFlags(f2u, kCGEventFlagMaskSecondaryFn | kCGEventFlagMaskCommand);
//
//    CGEventTapLocation loc = kCGHIDEventTap;
//    CGEventPost(loc, f2d);
//    CGEventPost(loc, f2u);
//
//    CFRelease(f2d);
//    CFRelease(f2u);
//    CFRelease(src);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.thunderboltObserver.isInTargetDisplayMode) {
            //TDM wasn't enabled try again
            [self enableTargetDisplayMode];
        }
    });
}


- (void)disableTargetDisplayMode {

}

#pragma mark - Target Display Mode Status

- (BOOL)clientIsInTargetDisplayMode {
    
    if (!self.isClient) {
        return NO;
    }
    //Will have multiple objects if the the MacBook is not in clamshell mode. However, when in clamshell mode `screens` should contain only contain 1 object, this object will be the iMac's screen.
    NSArray *screens = [NSScreen screens];
    
    if (screens.count == 0) {
        return NO;
    }
    
    NSMutableArray <NSNumber *> *screenNumbers = [NSMutableArray new];
    for (NSScreen *screen in screens) {
        if (screen.deviceDescription[@"NSScreenNumber"]) {
            [screenNumbers addObject:@([screen.deviceDescription[@"NSScreenNumber"] unsignedIntValue])];
        }
    }
    
    if (screenNumbers.count == 0) {
        return NO;
    }
    
    NSMutableArray <NSString *> *localizedScreenNames = [NSMutableArray new];
    
    for (NSNumber *screenNumber in screenNumbers) {
        
        NSString *localizedScreenName = [self screenNameForDisplay:screenNumber.unsignedIntValue];
        if (localizedScreenName && localizedScreenName.length != 0) {
            [localizedScreenNames addObject:localizedScreenName];
            //For testing: [localizedScreenNames addObject:@"iMac"];
        }
    }
    
    if (localizedScreenNames.count == 0) {
        return NO;
    }
    
    for (NSString *localizedScreenName in localizedScreenNames) {
        
        if ([localizedScreenName isEqualToString:@"iMac"]) {
            return YES;
            break;
        }
    }
    
    return NO;
}

- (NSString *)screenNameForDisplay:(CGDirectDisplayID)displayID {
    
    NSString *screenName = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDictionary *deviceInfo = (__bridge NSDictionary *)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(displayID), kIODisplayOnlyPreferredName);
#pragma clang diagnostic pop
    NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
    
    if ([localizedNames count] > 0) {
        screenName = [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]];
    }
    
    return screenName;
}

@end

