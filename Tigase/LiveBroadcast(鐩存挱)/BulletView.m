//
//  MX_BulletView.m
//  BulletForIOS
//
//  Created by 王朝阳 on 16/4/27.
//  Copyright © 2016年 Risun. All rights reserved.
//

#import "MX_BulletView.h"

#define Padding             5

@interface MX_BulletView ()

@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) float real_speed;
@end

@implementation MX_BulletView

- (instancetype)initWithCommentDic:(BulletSettingDic *)commentDic
{
    self = [super init];
    if (self)
    {
        if ([commentDic bulletText])
        {
            //背景颜色
            if ([commentDic bulletBackgroundColor])
                self.backgroundColor = [commentDic bulletBackgroundColor];
            else
                self.backgroundColor = [UIColor clearColor];
            
            //计算宽度,高度，设置bounds，font
            float width = 0.0;
            UIFont *font;
            CGFloat height;
            if ([commentDic bulletHeight]) {
                height = [commentDic bulletHeight];
            }else height = 25.0;
            
            if ([commentDic bulletTextFont])
            {
                font = [commentDic bulletTextFont];
                NSDictionary *attributes = @{NSFontAttributeName:font};
                width = [[commentDic bulletText] sizeWithAttributes:attributes].width;
            }else
            {
                font = [UIFont systemFontOfSize:14];
                NSDictionary *attributes = @{NSFontAttributeName:font};
                width = [[commentDic bulletText] sizeWithAttributes:attributes].width;
            }
            self.bounds = CGRectMake(0, 0, width + Padding*2, height);
            
            //文字颜色
            UIColor *color;
            if ([commentDic bulletTextColor]) {
                color = [commentDic bulletTextColor];
            }else color = [UIColor blackColor];
            
            //设置label
            _commentLabel = [[UILabel alloc] init];
            _commentLabel.frame = CGRectMake(Padding, 0, width, height);
            _commentLabel.backgroundColor = [UIColor clearColor];
            _commentLabel.text = [commentDic bulletText];
            _commentLabel.font = font;
            _commentLabel.textColor = color;
            [self addSubview:_commentLabel];
            
            //默认时间
            _moveDuration = [commentDic bulletAnimationDuration];
            
            //计算速度
            _screenWidth = [UIScreen mainScreen].bounds.size.width;
            _speed = (CGRectGetWidth(self.frame) + _screenWidth)/_moveDuration;
            _real_speed = _speed*[commentDic bulletAnimationSpeedRate];
        }
    }
    return self;
}
- (void)reloadDataWithDic:(BulletSettingDic *)reloadDic
{
    if ([reloadDic bulletText])
    {
        //背景颜色
        if ([reloadDic bulletBackgroundColor])
            self.backgroundColor = [reloadDic bulletBackgroundColor];
        else
            self.backgroundColor = [UIColor clearColor];
        
        //计算宽度,高度，设置bounds，font
        float width = 0.0;
        UIFont *font;
        CGFloat height;
        if ([reloadDic bulletHeight]) {
            height = [reloadDic bulletHeight];
        }else height = 25.0;
        
        if ([reloadDic bulletTextFont]) {
            font = [reloadDic bulletTextFont];
            NSDictionary *attributes = @{NSFontAttributeName:font};
            width = [[reloadDic bulletText] sizeWithAttributes:attributes].width;
        }else
        {
            font = [UIFont systemFontOfSize:14];
            NSDictionary *attributes = @{NSFontAttributeName:font};
            width = [[reloadDic bulletText] sizeWithAttributes:attributes].width;
        }
        self.bounds = CGRectMake(0, 0, width + Padding*2, height);
        
        //文字颜色
        UIColor *color;
        if ([reloadDic bulletTextColor]) {
            color = [reloadDic bulletTextColor];
        }else color = [UIColor blackColor];
        
        //设置label
        _commentLabel.frame = CGRectMake(Padding, 0, width, height);
        _commentLabel.text = [reloadDic bulletText];
        _commentLabel.font = font;
        _commentLabel.textColor = color;
        
        //计算速度
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        _speed = (CGRectGetWidth(self.frame) + _screenWidth)/_moveDuration;
        _real_speed = _speed*[reloadDic bulletAnimationSpeedRate];
    }
}
//开始动画
- (void)startAnimation
{
    __block CGRect frame = self.frame;
    __unsafe_unretained typeof(self)weakSelf = self;
    
    //计算移动的时间
    CGFloat dur = (CGRectGetMinX(frame)-_screenWidth)/_real_speed;
    
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        frame.origin.x = _screenWidth;
        weakSelf.frame = frame;
    } completion:^(BOOL finished)
     {
         [weakSelf.layer removeAllAnimations];
         //弹幕开始进入屏幕
         if (weakSelf.moveBlock)
             weakSelf.moveBlock(MoveIn);
         [weakSelf beginMoveIn];
     }];
}
//开始移入-->完全进入
-(void)beginMoveIn
{
    __block CGRect frame = self.frame;
    __unsafe_unretained typeof(self)weakSelf = self;
    
    //计算移动的时间
    CGFloat dur = CGRectGetWidth(frame)/_real_speed;
    
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        frame.origin.x = _screenWidth-CGRectGetWidth(frame);
        weakSelf.frame = frame;
    } completion:^(BOOL finished)
     {
         [weakSelf.layer removeAllAnimations];
         //弹幕完全进入屏幕
         if (weakSelf.moveBlock)
             weakSelf.moveBlock(Enter);
         [weakSelf enterIn];
     }];
}
//完全进入-->完全移出
-(void)enterIn
{
    __block CGRect frame = self.frame;
    __unsafe_unretained typeof(self)weakSelf = self;
    
    CGFloat dur = _screenWidth/_real_speed;
    
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        frame.origin.x = -CGRectGetWidth(frame);
        weakSelf.frame = frame;
    } completion:^(BOOL finished)
     {
         //弹幕完全离开屏幕
         if (weakSelf.moveBlock)
             weakSelf.moveBlock(MoveOut);
         [weakSelf.layer removeAllAnimations];
         [weakSelf removeFromSuperview];
     }];
}
//暂停动画
- (void)pauseAnimation
{
    CALayer *layer = self.layer;
    layer.fillMode = kCAFillModeForwards;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续动画
- (void)resumeAnimation
{
    CALayer*layer = self.layer;
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}
//停止动画
- (void)stopAnimation {
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}
- (void)dealloc {
    [self stopAnimation];
    self.moveBlock = nil;
}
@end

@implementation BulletSettingDic
-(instancetype)init
{
    self = [super init];
    if (self) {
        _settingDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
//设置字颜色
-(void)setBulletTextColor:(UIColor *)color
{
    [_settingDic setObject:color forKey:@"commentcolor"];
}
-(UIColor *)bulletTextColor
{
    return [_settingDic objectForKey:@"commentcolor"];
}

//设置背景颜色
-(void)setBulletBackgroundColor:(UIColor *)color
{
    [_settingDic setObject:color forKey:@"commentbackgroundcolor"];
}
-(UIColor *)bulletBackgroundColor
{
    return [_settingDic objectForKey:@"commentbackgroundcolor"];
}

//设置字体
-(void)setBulletTextFont:(UIFont *)font
{
    [_settingDic setObject:font forKey:@"commentfont"];
}
-(UIFont *)bulletTextFont
{
    return [_settingDic objectForKey:@"commentfont"];
}

//设置内容
-(void)setbulletText:(NSString *)text
{
    [_settingDic setObject:text forKey:@"commentstring"];
}
-(NSString *)bulletText
{
    return [_settingDic objectForKey:@"commentstring"];
}

//设置高度
-(void)setBulletHeight:(CGFloat)height
{
    [_settingDic setObject:[NSString stringWithFormat:@"%f",height] forKey:@"commentheight"];
}
-(CGFloat)bulletHeight
{
    return [[_settingDic objectForKey:@"commentheight"] floatValue];
}

//设置动画时长
-(void)setBulletAnimationDuration:(float)duration
{
    [_settingDic setObject:[NSString stringWithFormat:@"%f",duration] forKey:@"moveduration"];
}
-(float)bulletAnimationDuration
{
    float duration = 5.0;
    if ([_settingDic objectForKey:@"moveduration"] && [[_settingDic objectForKey:@"moveduration"] floatValue])
    {
        duration = [[_settingDic objectForKey:@"moveduration"] floatValue];
    }
    return duration;
}
//设置速度比率
-(void)setBulletAnimationSpeedRate:(float)speedRate
{
    [_settingDic setObject:[NSString stringWithFormat:@"%f",speedRate] forKey:@"movespeedrate"];
}
-(float)bulletAnimationSpeedRate
{
    float speedRate = 1.0;
    if ([_settingDic objectForKey:@"movespeedrate"] && [[_settingDic objectForKey:@"movespeedrate"] floatValue])
    {
        speedRate = [[_settingDic objectForKey:@"movespeedrate"] floatValue];
    }
    return speedRate;
}


-(NSMutableDictionary *)settingDic
{
    return _settingDic;
}
@end
