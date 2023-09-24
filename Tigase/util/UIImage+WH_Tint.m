//
//  UIImage+WH_Tint.m
//  Tigase_imChatT
//
//  Created by 1 on 17/3/6.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "UIImage+WH_Tint.h"

@implementation UIImage (WH_Tint)


-(UIImage *)imageWithTintColor:(UIColor *)tintColor{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

-(UIImage *)imageWithGradientTintColor:(UIColor *)tintColor{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

-(UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode{
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
    
}


@end
