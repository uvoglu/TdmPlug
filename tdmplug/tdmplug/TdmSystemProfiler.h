//
//  TdmSystemProfiler.h
//  tdmplug
//
//  Created by Simon Schuhmacher on 13.11.18.
//  Copyright © 2018 Simon Schuhmacher. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TdmSystemProfiler : NSObject

+ (NSArray *)dataType:(NSString *)type;
+ (NSArray *)dataTypes:(NSArray<NSString *> *)types;

@end

NS_ASSUME_NONNULL_END
