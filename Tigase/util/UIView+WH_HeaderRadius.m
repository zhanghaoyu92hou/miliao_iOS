//
//  UIView+WH_HeaderRadius.m
//  Tigase_imChatT
//
//  Created by Apple on 2019/6/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "UIView+WH_HeaderRadius.h"

@implementation UIView (WH_HeaderRadius)

/**
 *  控件修圆
 *
 *  @param angle 修圆的弧度数
 */
- (void)radiusWithAngle:(CGFloat)angle
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = angle;
}

- (void)headRadiusWithAngle:(CGFloat)angle{
    self.layer.masksToBounds = YES;
    if (MainHeadType){
        self.layer.cornerRadius = angle;
    }else{
        self.layer.cornerRadius = g_factory.headViewCornerRadius;
    }
}



- (void)sp_getUserFollowSuccess:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
