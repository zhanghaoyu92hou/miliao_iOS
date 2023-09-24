//
//  clockLayer.m
//  HYBClockDemo
//
//  Created by admin on 2019/8/1.
//  Copyright © 2019年 huangyibiao. All rights reserved.
//

#import "WH_ClockLayer.h"
#import <UIKit/UIKit.h>
@interface WH_ClockLayer()

@property (nonatomic ,strong) CALayer *bgLayer;
@property (nonatomic ,strong) CALayer *secondLayer;

@end


@implementation WH_ClockLayer
- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubLayers];
    }
    return self;
}
- (void) startClock{
    [self addSubLayers];
}
- (void) addSubLayers{
    
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = self.bounds;
    layer.borderWidth = 1;
    layer.borderColor = [UIColor grayColor].CGColor;
    layer.cornerRadius = self.bounds.size.width * 0.5;
    self.bgLayer = layer;
    [self.layer addSublayer:layer];
    
    self.secondLayer = [self layerWithBackgroundColor:[UIColor redColor] size:CGSizeMake(1.5, layer.bounds.size.width * 0.45)];
    
    [self.bgLayer addSublayer:self.secondLayer];
}


- (void)duration:(CGFloat)duration{
    [self addMinuteAnimationWithWithAngle:0 duration:duration];
}

- (void)addMinuteAnimationWithWithAngle:(CGFloat)angle duration:(CGFloat)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.repeatCount = 0;
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = @(angle * M_PI / 180);
    animation.byValue = @(2 * M_PI);
    [self.secondLayer addAnimation:animation forKey:@"MinuteAnimationKey"];
}

- (CALayer *)layerWithBackgroundColor:(UIColor *)color size:(CGSize)size {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.anchorPoint = CGPointMake(0.5, 1);
    // 设置为中心
    layer.position = CGPointMake(self.bgLayer.frame.size.width / 2,self.bgLayer.frame.size.height / 2);
    // 时针、分针、秒针长度是不一样的
    layer.bounds = CGRectMake(0, 0, size.width, size.height);
    // 加个小圆角
    layer.cornerRadius = size.width * 0.5;
    return layer;
}



- (void)sp_getMediaData {
    NSLog(@"Get Info Failed");
}
@end
