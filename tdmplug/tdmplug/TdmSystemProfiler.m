//
//  TdmSystemProfiler.m
//  tdmplug
//
//  Created by Simon Schuhmacher on 13.11.18.
//  Copyright © 2018 Simon Schuhmacher. All rights reserved.
//

#import "TdmSystemProfiler.h"

@implementation TdmSystemProfiler

+ (NSArray *)dataType:(NSString *)type {
    return [self dataTypes:@[type]];
}

+ (NSArray *)dataTypes:(NSArray<NSString *> *)types {
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/system_profiler"];
    [task setArguments:[types arrayByAddingObject:@"-xml"]];
    
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    
    @try {
        [task launch];
    } @catch (NSException *exception) {
        NSLog(@"Caught exception: %@", exception);
        return nil;
    }
    
    NSFileHandle *read = [out fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    
    NSError *error;
    NSArray *plist = [NSPropertyListSerialization propertyListWithData:dataRead options:NSPropertyListImmutable format:NULL error:&error];
    
    return plist;
}

@end
