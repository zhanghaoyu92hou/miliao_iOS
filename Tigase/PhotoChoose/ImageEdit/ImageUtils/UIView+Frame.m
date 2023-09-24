//
//  UIView+Frame.m
//  WWImageEdit
//
//  Created by 邬维 on 2016/12/29.
//  Copyright © 2016年 kook. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - self.frame.size.height;
    self.frame = frame;
}

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

-(void)setCenterX:(CGFloat)centerX
{
    CGPoint point = self.center;
    point.x = centerX;
    self.center = point;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint point = self.center;
    point.y = centerY;
    self.center = point;
}

- (void)setRadiu:(CGFloat)radiu color:(UIColor *)color {
    self.layer.cornerRadius = radiu;
    self.layer.masksToBounds = YES;
    if (color) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = color.CGColor;
    }
}



- (UILabel *)createLab:(CGRect)frame font:(UIFont *)font color:(UIColor *)textColor text:(NSString *)str
{
    UILabel *lab = [[UILabel alloc]initWithFrame:frame];
    lab.textColor = textColor;
    lab.font = font;
    lab.text = str;
    return lab;
}

- (UITextField *)createTF:(CGRect)frame font:(UIFont *)font color:(UIColor *)textColor text:(NSString *)str place:(NSString *)placeholder
{
    UITextField *tf = [[UITextField alloc]initWithFrame:frame];
    tf.textColor = textColor;
    tf.font = font;
    tf.text = str;
    tf.placeholder = placeholder;
    return tf;
}


- (UIView *)createLine:(CGRect)frame color:(UIColor *)color radio:(CGFloat)radio border:(UIColor *)border
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    if (radio>0) [line setRadiu:radio color:border];
    return line;
}

- (void)createLine:(CGRect)frame color:(UIColor *)color radio:(CGFloat)radio border:(UIColor *)border sup:(UIView *)superview
{
    UIView *line = [[UIView alloc]initWithFrame:frame];
    line.backgroundColor = color;
    if (radio>0) [line setRadiu:radio color:border];
    [superview addSubview:line];
}


- (UIButton *)createBtn:(CGRect)frame font:(UIFont *)font color:(UIColor *)textColor text:(NSString *)str img:(NSString *)imgname target:(id)target sel:(SEL)action;
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (font) btn.titleLabel.font = font;
    if (str) [btn setTitle:str forState:UIControlStateNormal];
    if (imgname) [btn setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal];
    if (textColor) [btn setTitleColor:textColor forState:UIControlStateNormal];
    if (target && action) [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (NSString *)checkTextField:(NSArray *)tfArray
{
    for (UITextField *tf in tfArray) {
        if ([tf.text isEqualToString:@""]) {
            [g_server showMsg:tf.placeholder];
            return tf.placeholder;
        }
    }
    return nil;
}

@end
