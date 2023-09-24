//
//  WH_BulletView.h
//  BulletForIOS
//
//  Created by 王朝阳 on 16/4/27.
//  Copyright © 2016年 Risun. All rights reserved.
//

#import <UIKit/UIKit.h>

//move status
typedef NS_ENUM(NSInteger, CommentMoveStatus)
{
    MoveIn,
    Enter,
    MoveOut
};

@class BulletSettingDic;

@interface WH_BulletView : UIView

@property (nonatomic, assign) float wh_moveDuration;   //defaule is 5s,setting before startAnimation effect

@property (nonatomic, assign,readonly) float wh_speed; //速度,这个速度在设置文字后自动生成，和屏幕宽度和文字长度有关。

@property (nonatomic, assign) float wh_speedRate;      //速度比率，真实速度为speed＊speedRate；

@property (nonatomic, copy) void(^wh_moveBlock)(CommentMoveStatus status);

@property (nonatomic, assign) NSInteger wh_trajectory;//所在轨道编号

- (instancetype)initWithCommentDic:(BulletSettingDic *)commentDic;

- (void)reloadDataWithDic:(BulletSettingDic *)reloadDic;

- (void)startAnimation;

- (void)stopAnimation;

- (void)pauseAnimation;

- (void)resumeAnimation;

@end

@interface BulletSettingDic : NSObject
{
    NSMutableDictionary *_settingDic;
}
//设置字颜色
-(void)setBulletTextColor:(UIColor *)color;
-(UIColor *)bulletTextColor;

//设置背景颜色
-(void)setBulletBackgroundColor:(UIColor *)color;
-(UIColor *)bulletBackgroundColor;

//设置字体
-(void)setBulletTextFont:(UIFont *)font;
-(UIFont *)bulletTextFont;

//设置内容
-(void)setbulletText:(NSString *)text;
-(NSString *)bulletText;

//设置高度
-(void)setBulletHeight:(CGFloat)height;
-(CGFloat)bulletHeight;

//设置动画时长
-(void)setBulletAnimationDuration:(float)duration;
-(float)bulletAnimationDuration;

//设置速度比率
-(void)setBulletAnimationSpeedRate:(float)speedRate;
-(float)bulletAnimationSpeedRate;

-(NSMutableDictionary *)settingDic;

@end
