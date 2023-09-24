//
//  UIView+CustomAlertView.m
//  CustomAnimation
//
//  Created by ning on 2017/4/17.
//  Copyright © 2017年 songjk. All rights reserved.
//

#import "UIView+CustomAlertView.h"
#import <objc/runtime.h>

#define ALPHA  0.5 //背景
#define AlertTime 0.3 //弹出动画时间
#define DropTime 0.5 //落下动画时间
#define ShareTime 0.5//分享时间


@implementation UIView (CustomAlertView)

static CustomAnimationMode mode;
static CGFloat  bgAlpha;
static BOOL isNeedEffective;
static BOOL isCancelGesturd;
static UIView *supView;

/*
 - (void)setBgAlpha:(CGFloat)bgAlpha{
 objc_setAssociatedObject(self, BGALPHA, @(bgAlpha), OBJC_ASSOCIATION_ASSIGN);
 }
 - (CGFloat)bgAlpha{
 return [objc_getAssociatedObject(self, @"bgAlpha") floatValue];
 }
 */

-(void)showInWindowWithMode:(CustomAnimationMode)animationMode inView:(UIView *)superV bgAlpha:(CGFloat)alpha needEffectView:(BOOL)isNeed{
    mode = animationMode;
    bgAlpha = alpha;
    isNeedEffective = isNeed;
    supView = superV;
    [self keyBoardListen];
    switch (animationMode) {
        case CustomAnimationModeAlert:
            [self showInWindow];
            break;
        case CustomAnimationModeDrop:
            [self upToDownShowInWindow];
            break;
        case CustomAnimationModeShare:
            [self shareViewShowInWindow];
            break;
        default:
            break;
    }
}

-(void)showInWindowWithMode:(CustomAnimationMode)animationMode inView:(UIView *)superV bgAlpha:(CGFloat)alpha needEffectView:(BOOL)isNeed cancelGestur:(BOOL)isCancel {
    mode = animationMode;
    bgAlpha = alpha;
    isNeedEffective = isNeed;
    isCancelGesturd = isCancel;
    supView = superV;
    [self keyBoardListen];
    switch (animationMode) {
        case CustomAnimationModeAlert:
            [self showInWindow];
            break;
        case CustomAnimationModeDrop:
            [self upToDownShowInWindow];
            break;
        case CustomAnimationModeShare:
            [self shareViewShowInWindow];
            break;
        default:
            break;
    }
}

-(void)tapBgView{
    switch (mode) {
        case CustomAnimationModeAlert:
            [self hide];
            break;
        case CustomAnimationModeDrop:
            [self dropDown];
            break;
        case CustomAnimationModeShare:
            [self hideShareView];
            break;
            
        default:
            
            break;
    }
}

-(void)hideView{
    [self removeKeyBoardListen];
    [self tapBgView];
}

#pragma mark- 动画显示

//弹出动画
-(void)showInWindow{
    if (self.superview) {
        [self removeFromSuperview];
    }
    [self addViewInWindowWith:AlertTime];
    if (supView) {
        [supView addSubview:self];
        self.center = supView.center;
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.center = [UIApplication sharedApplication].keyWindow.center;
    }
    self.alpha = 0;
    self.transform = CGAffineTransformScale(self.transform,0.1,0.1);
    [UIView animateWithDuration:AlertTime animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];
}
//下滑出动画
-(void)upToDownShowInWindow{
    if (self.superview) {
        [self removeFromSuperview];
    }
    [self addViewInWindowWith:0.25];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    CGFloat x = ([UIApplication sharedApplication].keyWindow.bounds.size.width-self.frame.size.width)/2;
    CGFloat y = -self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.frame = CGRectMake(x, y, width, height);
    [UIView animateWithDuration:DropTime delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = [UIApplication sharedApplication].keyWindow.center;
    } completion:^(BOOL finished) {
        
    }];
}

/**
 下方弹出分享视图
 */
-(void)shareViewShowInWindow{
    if (self.superview) {
        [self removeFromSuperview];
    }
    [self addViewInWindowWith:0.15];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.bounds.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:ShareTime delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect  oldFrame = self.frame;
        oldFrame.origin.y = self.frame.origin.y-self.frame.size.height+5;
        self.frame = oldFrame;
    } completion:^(BOOL finished) {
        
    }];
}
/*
 -(void)bigImageShowInWindow:(UIView *)fromView{
 if (self.superview) {
 [self removeFromSuperview];
 }
 [self addViewInWindow];
 oldFrame = self.frame;
 UIView *bgView = [[UIApplication sharedApplication].keyWindow viewWithTag:TagValue];
 [[UIApplication sharedApplication].keyWindow addSubview:self];
 self.frame = [bgView convertRect:self.frame fromView:self.superview];
 //放大
 [UIView animateWithDuration:AlertTime animations:^{
 CGRect frame = self.frame;
 frame.size.width = bgView.frame.size.width;
 frame.size.height = bgView.frame.size.width * (oldFrame.size.height / oldFrame.size.width);
 frame.origin.x = 0;
 frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
 self.frame = frame;
 }];
 }
 */
#pragma mark - 动画隐藏

//弹出隐藏
-(void)hide{
    
    UIView *bgvi = [[UIApplication sharedApplication].keyWindow viewWithTag:TagValue];
    
    
    if (self.superview) {
        [UIView animateWithDuration:AlertTime animations:^{
            self.transform = CGAffineTransformScale(self.transform,0.1,0.1);
            self.alpha = 0;
            bgvi.alpha = 0;
            
            

            
        } completion:^(BOOL finished) {
//            [self hideAnimationFinish];
            if (bgvi) {
                [bgvi removeFromSuperview];
            }
            [self removeFromSuperview];
            
        }];
    }
}
//下滑隐藏
-(void)dropDown{
    
    UIView *bgvi = [[UIApplication sharedApplication].keyWindow viewWithTag:TagValue];
    
    if (self.superview) {
        [UIView animateWithDuration:DropTime delay:0 usingSpringWithDamping:1 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake(self.frame.origin.x, [UIApplication sharedApplication].keyWindow.bounds.size.height, self.frame.size.width, self.frame.size.height);
            
            bgvi.alpha = 0;
            

            
        } completion:^(BOOL finished) {
//            [self hideAnimationFinish];
            if (bgvi) {
                [bgvi removeFromSuperview];
            }
            [self removeFromSuperview];
        }];
    }
}


/**
 下方分享视图隐藏
 */
-(void)hideShareView{
    
    UIView *bgvi = [[UIApplication sharedApplication].keyWindow viewWithTag:TagValue];
    
    
    if (self.superview) {
        [UIView animateWithDuration:ShareTime delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.bounds.size.height, self.frame.size.width, self.frame.size.height);
            
            bgvi.alpha = 0;
        } completion:^(BOOL finished) {
//            [self hideAnimationFinish];
            
            if (bgvi) {
                [bgvi removeFromSuperview];
            }
            [self removeFromSuperview];
        }];
    }
}
/*
 -(void)hideBigImageView{
 if (self.superview) {
 [UIView animateWithDuration:AlertTime animations:^{
 self.frame = oldFrame;
 } completion:^(BOOL finished) {
 UIView *bgvi = [[UIApplication sharedApplication].keyWindow viewWithTag:TagValue];
 if (bgvi) {
 [bgvi removeFromSuperview];
 }
 }];
 }
 }
 */

-(void)hideAnimationFinish{
    UIView *bgvi = [[UIApplication sharedApplication].keyWindow viewWithTag:TagValue];
    
    [UIView animateWithDuration:0.2 animations:^{
        bgvi.alpha = 0;
    }completion:^(BOOL finished) {
        if (bgvi) {
            [bgvi removeFromSuperview];
        }
        [self removeFromSuperview];
    }];
    
    
}





/**
 加入背景view
 */
-(void)addViewInWindowWith:(CGFloat) showTime {
    UIView *oldView;
    if (supView) {
        oldView = [supView viewWithTag:TagValue];
    }else{
        oldView = [[UIApplication sharedApplication].keyWindow viewWithTag:TagValue];
    }
    if (oldView) {
        [oldView removeFromSuperview];
    }
    UIView *v = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    v.tag = TagValue;
    if (!isCancelGesturd) {
        [self addGuesture:v];
    }
    
    v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:bgAlpha == -1 ? ALPHA : bgAlpha];
    if (isNeedEffective) {
        UIVisualEffectView *effectView =[[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effectView.frame = v.frame;
        effectView.alpha = 0.6;
        [v addSubview:effectView];
    }
    if (supView) {
        [supView addSubview:v];
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:v];
    }
    
    v.alpha = 0;
    
    [UIView animateWithDuration:showTime animations:^{
        v.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
}
//添加背景view手势
-(void)addGuesture:(UIView *)vi{
    vi.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView)];
    [vi addGestureRecognizer:tap];
}

- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    if (!view) {
        view = self;
    }
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}




#pragma mark - 键盘弹起监听
- (void)keyBoardListen {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)removeKeyBoardListen{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)keyboardWillShow:(NSNotification *)noti {
    NSDictionary *userInfo = [noti userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;  // 得到键盘弹出后的键盘视图所在y坐标;
    if (CGRectGetMaxY(self.frame)>=keyBoardEndY) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect _frame = self.frame;
            _frame.origin.y = keyBoardEndY-_frame.size.height-10;
            self.frame = _frame;
        }];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)noti {
    [UIView animateWithDuration:0.5 animations:^{
        self.center = [UIApplication sharedApplication].keyWindow.center;
    }];
}



@end

