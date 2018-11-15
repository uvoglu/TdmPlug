//
//  main.m
//  tdmplug
//
//  Created by Simon Schuhmacher on 09.11.18.
//  Copyright © 2018 Simon Schuhmacher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TdmController.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        [[TdmController alloc] init];
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}
