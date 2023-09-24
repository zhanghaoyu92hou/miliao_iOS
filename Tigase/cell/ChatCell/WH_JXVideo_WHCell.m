//
//  MiXin_JXVideo_MiXinCell.m
//  wahu_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXVideo_WHCell.h"
#import <AVFoundation/AVFoundation.h>
#import "WH_JXVideoPlayer.h"
#import "WH_SCGIFImageView.h"
#import "NSString+ContainStr.h"


@implementation WH_JXVideo_WHCell

- (void)dealloc{
    NSLog(@"MiXin_JXVideo_MiXinCell.dealloc");
    //[g_notify removeObserver:self name:kCellReadDelNotification object:self.msg];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)creatUI{
    
    //预览图
    _chatImage=[[WH_JXImageView alloc]initWithFrame:CGRectZero];
    [_chatImage setBackgroundColor:[UIColor clearColor]];
//    _chatImage.layer.cornerRadius = 6;
//    _chatImage.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_chatImage];
//    [_chatImage release];
    
    _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    _pauseBtn.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
//    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"pausevideo"] forState:UIControlStateSelected];
    [_pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
    [_chatImage addSubview:_pauseBtn];
    
    _videoProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    _videoProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    _videoProgress.layer.masksToBounds = YES;
    _videoProgress.layer.borderWidth = 2.f;
    _videoProgress.layer.borderColor = [UIColor whiteColor].CGColor;
    _videoProgress.layer.cornerRadius = _videoProgress.frame.size.width/2;
    _videoProgress.text = @"0%";
    _videoProgress.hidden = YES;
    _videoProgress.font = sysFontWithSize(13);
    _videoProgress.textAlignment = NSTextAlignmentCenter;
    _videoProgress.textColor = [UIColor whiteColor];
    [_chatImage addSubview:_videoProgress];

}

- (void)showTheVideo {    
    if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(WH_showVideoPlayerWithTag:)]) {
        [self didVideoOpen];
        [self.videoDelegate WH_showVideoPlayerWithTag:self.indexTag];
    }
//    _player= [[WH_JXVideoPlayer alloc] initWithParent:g_App.window];
//    _player.didVideoOpen = @selector(didVideoOpen);
//    _player.MiXin_didVideoPlayEnd = @selector(MiXin_didVideoPlayEnd);
//    _player.delegate = self;
//    [self setUIFrame];
//    [_player switch];
}


- (void)didVideoOpen{
    [self.msg WH_sendAlreadyRead_WHMsg];
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    if ([self.msg.isReadDel boolValue] && !self.msg.isMySend) {
        self.msg.readTime = [NSDate date];
        [self timeGo:self.msg.fileName];
    }
    if(!self.msg.isMySend){
        [self drawIsRead];
    }
}


-(void)setCellData{
    [super setCellData];
    [self setUIFrame];
    
    if ([self.msg.isReadDel boolValue]) {

        _chatImage.alpha = 0.1;
  
    }else {
        _chatImage.alpha = 1;
    }
    
}


- (void)setUIFrame{
    float n = imageItemHeight;
    
/*location_x没有值的情况下，会卡：
    _chatImage.image = [FileInfo getFirstImageFromVideo:self.msg.content];
    int w = _chatImage.image.size.width;
    int h = _chatImage.image.size.height;
*/
    float w = [self.msg.location_x intValue] * kScreenWidthScale;
    float h = [self.msg.location_y intValue];

    if (w <= 0 || h <= 0){
        w = n;
        h = n;
    }
    
    float k = w/(h/n);
    if(k+INSETS > JX_SCREEN_WIDTH - 80)//如果超出屏幕宽度
        k = JX_SCREEN_WIDTH-n-INSETS;
    
    if (self.msg.isMySend) {
        self.bubbleBg.frame=CGRectMake(JX_SCREEN_WIDTH-HEAD_SIZE-INSETS*4-k+CHAT_WIDTH_ICON+10, INSETS, INSETS+k, n+INSETS-4);
        _chatImage.frame = self.bubbleBg.bounds;
    }else{
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + INSETS-CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), k+INSETS, n+INSETS-4);
        _chatImage.frame = self.bubbleBg.bounds;
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    _pauseBtn.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    _videoProgress.center = CGPointMake(_chatImage.frame.size.width/2,_chatImage.frame.size.height/2);
    _chatImage.image = [UIImage imageNamed:@"Default_Gray"];
    if([self.msg.fileName isUrl]) {//判断是否是视频链接
        [FileInfo getFirstImageFromVideo:self.msg.fileName imageView:_chatImage];
    }else if (isFileExist(self.msg.fileName)){//判断是否是本地路径
        [FileInfo getFirstImageFromVideo:self.msg.fileName imageView:_chatImage];
    }else {//fileName既不是有效的网路路径，也不是本地路径，只能从content中取值
        [FileInfo getFirstImageFromVideo:self.msg.content imageView:_chatImage];
    }
//    _player.parent = g_App.window;
//    if(self.msg.isMySend && isFileExist(self.msg.fileName))
//        _player.videoFile = self.msg.fileName;
//    else
//        _player.videoFile = self.msg.content;
    
    //音视频点击事件
    _chatImage.didTouch = @selector(doNotThing);
    
    [self setMaskLayer:_chatImage];
    
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    //视频返回会消失问题解决
//    [self startTimeer:^(WH_JXMessageObject *msg) {
//
//    }];

    __weak typeof(self) weakSelf = self;
    if ([self.msg.isReadDel boolValue]) {//是阅后即焚
        if (!self.msg.isMySend) {
            if([self.msg.isRead intValue] == transfer_status_yes){

                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [weakSelf deleteMsg];
                }];
            }
        }else {
            if([self.msg.isSend intValue] == transfer_status_yes){
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [weakSelf deleteMsg];
                }];
            }
        }
    }else{
        if(!self.msg.isMySend)
            [self drawIsRead];
    }
    } else {
//#else
    if(!self.msg.isMySend)
        [self drawIsRead];
    }
//#endif
    
    
}

- (void)updateFileLoadProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.fileDict isEqualToString:self.msg.messageId]) {
            _videoProgress.hidden = NO;
            _pauseBtn.hidden = YES;
            // UI更新代码
            if (self.loadProgress >= 1) {
                _videoProgress.text = [NSString stringWithFormat:@"99%@",@"%"];
            }else {
                _videoProgress.text = [NSString stringWithFormat:@"%d%@",(int)(self.loadProgress*100),@"%"];
            }
//            _videoProgress.hidden = self.loadProgress >= 1;
//            _pauseBtn.hidden = self.loadProgress < 1;
        }
    });

}

- (void)sendMessageToUser {
    [super sendMessageToUser];
    _videoProgress.text = [NSString stringWithFormat:@"100%@",@"%"];
    _pauseBtn.hidden = NO;
    _videoProgress.hidden = YES;
}


-(void)drawIsSend{
    [super drawIsSend];
//    if (self.msg.isMySend) {
//#ifdef IS_SHOW_NEWReadDelete
        if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
        if ([self.msg.isReadDel boolValue]) {
            if([self.msg.isSend intValue] == transfer_status_yes){
                self.msg.timeSend = [NSDate date];
            [self startTimeer:^(WH_JXMessageObject *msg) {
                [self deleteMsg];
            }];
            }
        }
        }
//#else
//#endif
//        return;
//    }
}

//未读红点
-(void)drawIsRead{
    [super drawIsRead];
//    if (!self.msg.isMySend) {
//#ifdef IS_SHOW_NEWReadDelete
//        
//        if ([self.msg.isReadDel boolValue]) {
//            if([self.msg.isRead intValue] == transfer_status_yes){
//                self.msg.readTime = [NSDate date];
//                [self startTimeer:^(WH_JXMessageObject *msg) {
//                    [self deleteMsg];
//                }];
//            }
//        }
//#else
//#endif
//        return;
//    }
    
    if([self.msg.isRead boolValue]){
        self.readImage.hidden = YES;
    }
    else{
        if(self.readImage==nil){
            self.readImage=[[WH_JXImageView alloc]init];
            [self.contentView addSubview:self.readImage];

        }
        self.readImage.image = [UIImage imageNamed:@"new_tips"];
        self.readImage.hidden = NO;
        self.readImage.frame = CGRectMake(self.bubbleBg.frame.origin.x+self.bubbleBg.frame.size.width+2, self.bubbleBg.frame.origin.y+13, 8, 8);
        self.readImage.center = CGPointMake(self.readImage.center.x, self.bubbleBg.center.y);
        
    }
}

- (void)timeGo:(NSString *)fileName{
    if (_oldFileName) {
        if ([_oldFileName isEqualToString:fileName]) {
            return;
        }else{
            self.oldFileName = fileName;
        }
    }else{
        self.oldFileName = fileName;
        
    }
    if ([self.msg.timeLen intValue] <= 0) {
        self.msg.timeLen = [NSNumber numberWithLong:_player.player.timeLen];
    }

    
//    if ([self.msg.isReadDel boolValue] && self.msg.isMySend) {
//        [self startTimeer:^(WH_JXMessageObject *msg) {
//            [self deleteMsg];
//        }];
//    }
    
}
- (void)deleteMsg{
//    //播放删除动画

    if (![self.msg.isReadDel boolValue]) {
        return;
    }
    //渐变隐藏
    [UIView animateWithDuration:0.5f animations:^{
        self.bubbleBg.alpha = 0;
        self.chatImage.alpha = 0;
        self.readImage.alpha = 0;
        self.burnImage.alpha = 0;
    } completion:^(BOOL finished) {
        //动画结束后删除UI
        if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
            [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
        }
        self.bubbleBg.alpha = 1;
        self.chatImage.alpha = 1;
        self.readImage.alpha = 1;
        self.burnImage.alpha = 1;
        self.oldFileName = nil;
        //阅后即焚图片通知
        [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
    }];
}

+ (float)getChatCellHeight:(WH_JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = imageItemHeight+20*2 + 40;
        }else {
            n = imageItemHeight+20*2;
        }
    }else {
        if (msg.isShowTime) {
            n = imageItemHeight+10*2 + 40;
        }else {
            n = imageItemHeight+10*2;
        }
    }
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([msg.isReadDel integerValue] >= 1) {
        n+=30;
//        if ([msg.isShowDel integerValue]>=1) {
//
//            if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
//                n += 70;
//            }else {
//                n+=40;
//            }
//        }
    }
    }
//#else
//#endif
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
        
    return n;
}

@end
