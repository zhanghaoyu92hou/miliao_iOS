//
//  UIView+Frame.h
//  WWImageEdit
//
//  Created by 邬维 on 2016/12/29.
//  Copyright © 2016年 kook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;


- (void)setRadiu:(CGFloat)radiu color:(UIColor *)color;

- (UILabel *)createLab:(CGRect)frame font:(UIFont *)font color:(UIColor *)textColor text:(NSString *)str;
- (UITextField *)createTF:(CGRect)frame font:(UIFont *)font color:(UIColor *)textColor text:(NSString *)str place:(NSString *)placeholder;
- (UIButton *)createBtn:(CGRect)frame font:(UIFont *)font color:(UIColor *)textColor text:(NSString *)str img:(NSString *)imgname target:(id)target sel:(SEL)action;
- (UIView *)createLine:(CGRect)frame color:(UIColor *)color radio:(CGFloat)radio border:(UIColor *)border;
- (NSString *)checkTextField:(NSArray *)tfArray;

- (void)createLine:(CGRect)frame color:(UIColor *)color radio:(CGFloat)radio border:(UIColor *)border sup:(UIView *)superview;
@end
