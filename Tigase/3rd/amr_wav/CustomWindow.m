//
//  CustomWindow.m
//  AmrConvertAndRecord
//
//  Created by Jeans on 3/29/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import "CustomWindow.h"

@implementation CustomWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
        [g_notify postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
    }
    [super sendEvent:event];
}



- (void)sp_getUserName {
    NSLog(@"Get Info Success");
}
@end
