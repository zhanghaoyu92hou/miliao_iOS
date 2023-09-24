//
//  UIView+WH_ScreenShot.h
//  Tigase_imChatT
//
//  Created by Apple on 16/12/7.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WH_ScreenShot)
- (UIImage *)screenshot;
- (UIImage *)screenshotWithRect:(CGRect)rect;
- (UIImage *)snapshot:(UIView *)view;
- (UIImage *)viewSnapshot:(UIView *)view withInRect:(CGRect)rect;
//-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;


@end
