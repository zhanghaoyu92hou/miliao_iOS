//
//  WH_JXVideoPlayer.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 17/1/12.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WH_JXVideoPlayer_WHVC.h"
#import "WH_JXActionSheet_WHVC.h"

#define kAllVideoPlayerStopNotifaction @"kAllVideoPlayerStopNotifaction"//停止所有
#define kAllVideoPlayerPauseNotifaction @"kAllVideoPlayerPauseNotifaction"//暂停所有

typedef NS_ENUM(NSInteger, JXVideoType) {
    JXVideoTypeChat,           // 聊天界面
    JXVideoTypeWeibo,          // 朋友圈
    JXVideoTypePreview,          // 预览
};



@interface WH_JXVideoPlayer : NSObject <WH_JXActionSheet_WHVCDelegate>{
    UIView* _parent;
    UILabel* _timeLab;
    UILabel* _timeEnd;
    NSString* _videoFile;
    WH_JXWaitView* _wait;
    UIButton* _pauseBtn;
    UIButton* _exitBtn;
    UISlider*_movieTimeControl;
    UIButton* _disBtn;
    UIButton* _sendBtn;
    UIButton *_outBtn;
    UIView* _topView;
    UIView* _botView;
    UIImageView* _videoFirst;
    UIView* _firstBaseView;
    BOOL _saved;
}
@property (nonatomic, strong, setter=setVideoFile:) NSString* videoFile;//可动态改变文件
@property (nonatomic, strong, setter=setParent:) UIView* parent;//可动态改变父亲
@property (nonatomic, assign, setter=setIsVideo:) BOOL isVideo;
@property (nonatomic, assign, setter=setHidden:) BOOL hidden;
@property (nonatomic, assign, setter=setTimeLen:) int timeLen;
@property (nonatomic, strong) WH_JXVideoPlayer_WHVC* player;

@property (nonatomic, assign) BOOL isPlaying;//播放中
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL didVideoOpen;//打开文件
@property (nonatomic, assign) SEL WH_didVideoPlayEnd;//播放结束
@property (nonatomic, assign) SEL didVideoPlayBegin;//点击播放
@property (nonatomic, assign) SEL didVideoPause;//播放暂停
@property (nonatomic, assign) SEL didExitBtn;//点击返回，循环播放时可调用
@property (nonatomic, assign) SEL didSendBtn;//播放暂停

@property (nonatomic, assign) BOOL isStartFullScreenPlay;//开始后全屏播放
@property (nonatomic, assign) BOOL isShowHide;//全屏播放时点击隐藏播放器

@property (nonatomic, assign) BOOL isScreenPlay;//当前是全屏播放
@property (nonatomic, assign) JXVideoType type;

@property (nonatomic, assign) BOOL isEndPlay;

@property (nonatomic, assign) BOOL isPreview;  // 拍摄视频后的预览



-(id)initWithParent:(UIView*)parent;//指定父亲建立，显示播放暂停按钮
//-(void)open:(NSString *)value;
-(void)stop;
-(void)play;
-(void)pause;
-(void)wh_switch;


@end
