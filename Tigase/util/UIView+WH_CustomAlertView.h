//
//  UIView+WH_CustomAlertView.h
//  CustomAnimation
//
//  Created by ning on 2017/4/17.
//  Copyright © 2017年 songjk. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TagValue  3333
typedef NS_ENUM(NSInteger, WH_CustomAnimationMode) {
    CustomAnimationModeAlert = 0,//弹出效果
    CustomAnimationModeDrop, //由上方掉落
    CustomAnimationModeShare,//下方弹出（类似分享效果）
};

@interface UIView (WH_CustomAlertView)

/**
 显示 弹出view 任意view导入头文件之后即可调用
 @param animationMode CustomAnimationMode 三种模式
 @param alpha CGFloat  背景透明度 0-1  默认0.2  传-1即为默认值
 @param isNeed BOOL 是否需要背景模糊效果
 */
-(void)showInWindowWithMode:(WH_CustomAnimationMode)animationMode inView:(UIView *)superV bgAlpha:(CGFloat)alpha needEffectView:(BOOL)isNeed;

/**
 显示 弹出view 任意view导入头文件之后即可调用
 @param animationMode CustomAnimationMode 三种模式
 @param alpha CGFloat  背景透明度 0-1  默认0.2  传-1即为默认值
 @param isNeed BOOL 是否需要背景模糊效果
 @param cancelGestur 是否取消点击背景手势
 */
-(void)showInWindowWithMode:(WH_CustomAnimationMode)animationMode inView:(UIView *)superV bgAlpha:(CGFloat)alpha needEffectView:(BOOL)isNeed cancelGestur:(BOOL)isCancel;

/**
 隐藏 view
 */
-(void)hideView;


/**
 给view 各个边加 layer.border
 */
- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width;



- (void)sp_getMediaData;
@end
