//
//  UIImage+Color.h
//  Tigase_imChatT
//
//  Created by 1 on 17/10/27.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WH_Color)

+(UIImage*) createImageWithColor:(UIColor*) color;

// 图片缩小
+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;


- (void)sp_didUserInfoFailed:(NSString *)isLogin;
@end
