//
//  UIDevice+FCUUID.m
//
//  Created by Fabio Caccamo on 19/11/15.
//  Copyright © 2015 Fabio Caccamo. All rights reserved.
//

#import "UIDevice+FCUUID.h"

@implementation UIDevice (FCUUID)


static inline void pg_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)load {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) {
        pg_swizzleSelector(UIDevice.class, @selector(endGeneratingDeviceOrientationNotifications), @selector(pgEndGeneratingDeviceOrientationNotifications));
    }
}

- (void)pgEndGeneratingDeviceOrientationNotifications {
    NSLog(@"pgEndGeneratingDeviceOrientationNotifications isMainThread:%d", [NSThread isMainThread]);
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pgEndGeneratingDeviceOrientationNotifications];
        });
        return;
    }
    [self pgEndGeneratingDeviceOrientationNotifications];
}


-(NSString *)uuid
{
    return [FCUUID uuidForDevice];
}

@end
