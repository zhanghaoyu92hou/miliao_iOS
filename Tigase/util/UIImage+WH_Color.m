//
//  UIImage+Color.m
//  Tigase_imChatT
//
//  Created by 1 on 17/10/27.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "UIImage+WH_Color.h"

@implementation UIImage (WH_Color)

+(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    // 图片缩小
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}


- (void)sp_didUserInfoFailed:(NSString *)isLogin {
    NSLog(@"Get User Succrss");
}
@end
