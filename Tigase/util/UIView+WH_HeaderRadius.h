//
//  UIView+WH_HeaderRadius.h
//  Tigase_imChatT
//
//  Created by Apple on 2019/6/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (WH_HeaderRadius)

/**
 *  控件修圆
 *
 *  @param angle 修圆的弧度数
 */
- (void)radiusWithAngle:(CGFloat)angle;


/**
 *  将头像改成方形或圆形
 *
 *
 */
- (void)headRadiusWithAngle:(CGFloat)angle;



NS_ASSUME_NONNULL_END
- (void)sp_getUserFollowSuccess:(NSString *)mediaInfo;
@end
