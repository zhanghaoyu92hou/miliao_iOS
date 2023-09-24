//
//  WHProgress.m
//  test
//
//  Created by Apple on 2019/8/13.
//  Copyright © 2019 shandianyun. All rights reserved.
//

#import "WHProgress.h"

@implementation WHProgress

- (void)drawRect:(CGRect)rect {

    CGPoint origin = CGPointMake(8, 8);

    CGFloat radius = 8;
    
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = startAngle + self.progress * M_PI * 2;
    
    UIBezierPath *sectorPath = [UIBezierPath bezierPathWithArcCenter:origin radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    [sectorPath addLineToPoint:origin];
    
    [[UIColor darkGrayColor] set];
    
    [sectorPath fill];
}


- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    //赋值结束之后要刷新UI
    [self setNeedsDisplay];
}
@end
