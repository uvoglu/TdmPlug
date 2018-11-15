//
//  TdmThunderboltObserver.h
//  tdmplug
//
//  Created by Simon Schuhmacher on 13.11.18.
//  Copyright © 2018 Simon Schuhmacher. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TdmThunderBoltObserverDelegate;

@interface TdmThunderboltObserver : NSObject

@property (nonatomic, strong) id<TdmThunderBoltObserverDelegate> delegate;
@property (readonly) BOOL macConnected;
@property (nonatomic, assign, readonly, getter=isThunderboltEnabled) BOOL thunderboltEnabled;

- (id)initWithDelegate:(id<TdmThunderBoltObserverDelegate>)delegate;
- (void)startObserving;
- (void)stopObserving;
- (BOOL)isInTargetDisplayMode;
- (NSString *)systemAssertionInfomation;

@end

@protocol TdmThunderBoltObserverDelegate <NSObject>

@optional
- (void)thunderboltObserver:(TdmThunderboltObserver *)observer isInitiallyConnected:(BOOL)connected;
- (void)thunderboltObserverDeviceConnected:(TdmThunderboltObserver *)observer;
- (void)thunderboltObserverDeviceDisconnected:(TdmThunderboltObserver *)observer;

@end

NS_ASSUME_NONNULL_END
