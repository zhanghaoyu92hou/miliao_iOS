//
//  UIView+Frame.h
//  WaHu
//
//  Created by Six on 15/12/30.
//  Copyright © 2015年 Six. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  坐标相关
 */
@interface UIView (Frame)

@property (nonatomic , assign) CGFloat x;
@property (nonatomic , assign) CGFloat y;
//@property (nonatomic , assign) CGFloat width;
//@property (nonatomic , assign) CGFloat height;
//@property (nonatomic , assign) CGFloat centerX;
//@property (nonatomic , assign) CGFloat centerY;
@property (nonatomic , assign) CGSize size;


- (void)sp_getMediaFailed:(NSString *)string;
@end
