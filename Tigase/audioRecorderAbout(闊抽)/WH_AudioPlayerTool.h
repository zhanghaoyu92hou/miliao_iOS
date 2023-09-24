//
//  WH_AudioPlayerTool.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 17/1/12.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WH_JXWaitView.h"
#define kAllAudioPlayerStopNotifaction @"kAllAudioPlayerStopNotifaction"//退出程序时，保存未读消息
#define kAllAudioPlayerPauseNotifaction @"kAllAudioPlayerPauseNotifaction"//退出程序时，保存未读消息

@interface WH_AudioPlayerTool : NSObject<AVAudioPlayerDelegate>{
    AVAudioPlayer *_player;
    UIButton* _pauseBtn;
    BOOL _isOpened;
    WH_JXWaitView* _wait;
    WH_JXImageView * _voiceView;
    UILabel* _timeLenView;
    NSMutableArray* _array;
}
@property (nonatomic, strong, setter=setWh_audioFile:)NSString* wh_audioFile;//可动态改变文件
@property (nonatomic, strong, setter=setWh_parent:) UIView* wh_parent;//可动态改变父亲
@property (nonatomic, strong) AVAudioPlayer* wh_player;
@property (nonatomic, strong) WH_JXImageView * wh_voiceBtn;
@property (nonatomic, strong) UILabel* wh_timeLenView;
@property (nonatomic, strong) UIProgressView * wh_progressView;
@property (nonatomic, strong) UIView* wh_pgBGView; //进度条背景

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL didAudioOpen;//打开音频
@property (nonatomic, assign) SEL didAudioPlayEnd;//播放结束
@property (nonatomic, assign) SEL didAudioPlayBegin;//点击播放
@property (nonatomic, assign) SEL didAudioPause;//播放暂停

@property (nonatomic, assign) BOOL wh_isPlaying;//播放中
@property (nonatomic, assign, setter=setWh_timeLen:) int wh_timeLen;
@property (nonatomic, assign, setter=setWh_isLeft:) BOOL wh_isLeft;
@property (nonatomic, assign,setter=setWh_hidden:) BOOL wh_hidden;
@property (nonatomic, assign, setter=setWh_frame:) CGRect wh_frame;
@property (nonatomic, assign) BOOL wh_showProgress;//长于10s的音频默认启用进度条,设NO不显示
@property (nonatomic, strong) NSTimer *wh_timer;

@property (nonatomic, assign) BOOL wh_isNotStopLast;
@property (nonatomic, assign) BOOL wh_isOpenProximityMonitoring;   // 是否开启贴脸检测

@property (nonatomic ,assign) BOOL wh_isCollect; //是否为收藏

-(id)initWithParent:(UIView*)parent;//指定父亲建立，显示播放暂停按钮
-(id)initWithParent:(UIView*)parent frame:(CGRect)frame isLeft:(BOOL)isLeft;//指定父亲、frame、方向建立动画播放view
-(id)initWithParent:(UIView*)parent frame:(CGRect)frame isLeft:(BOOL)isLeft isCollect:(BOOL)collect;

-(id)init;//不可视
-(void)wh_open;
-(void)wh_play;
-(void)wh_pause;
-(void)wh_stop;
-(void)wh_switch;

//-(void)wavToamr:(NSString*)source target:(NSString*)target;
//-(void)amrTowav:(NSString*)source target:(NSString*)target;
@end
