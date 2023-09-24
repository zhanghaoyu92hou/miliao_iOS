//
//  MiXin_JXAudio_MiXinCell.m
//  wahu_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXAudio_WHCell.h"

@implementation WH_JXAudio_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)creatUI{
    if (_audioPlayer) {
        [_audioPlayer wh_stop];
    }
    _audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.bubbleBg frame:CGRectNull isLeft:YES];
    _audioPlayer.wh_isOpenProximityMonitoring = YES;
    _audioPlayer.delegate = self;
    _audioPlayer.didAudioPlayEnd = @selector(didAudioPlayEnd);
    _audioPlayer.didAudioPlayBegin = @selector(didAudioPlayBegin);
    _audioPlayer.didAudioOpen = @selector(didAudioOpen);
}

-(void)dealloc{
    //[g_notify removeObserver:self name:kCellReadDelNotification object:self.msg];
    NSLog(@"MiXin_JXAudio_MiXinCell.dealloc");
//    [_audioPlayer release];
//    [super dealloc];
    _audioPlayer = nil;
}
- (void)didAudioOpen{
    [self.msg WH_sendAlreadyRead_WHMsg];
//
    if (self.msg.isGroup) {
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self.msg updateIsRead:nil msgId:self.msg.messageId];
    }
    
}
- (void)setCellData{
    [super setCellData];
    int w = (JX_SCREEN_WIDTH-HEAD_SIZE-INSETS*2-70)/30;
    w = 70+w*[self.msg.timeLen intValue];
    if(w<70)
        w = 70;
    if(w>200)
        w = 200;
    
    CGFloat bubbleX = .0f;
    CGFloat bubbleY = .0f;
    CGFloat bubbleW = .0f;
    CGFloat bubbleH = .0f;
    if(self.msg.isMySend){
        bubbleW = w;
        bubbleX = JX_SCREEN_WIDTH - INSETS - HEAD_SIZE - CHAT_WIDTH_ICON - bubbleW;
        bubbleY = INSETS;
        bubbleH = 37;
    } else {
        bubbleX = CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON;
        bubbleY = INSETS2(self.msg.isGroup);
        bubbleW = w;
        bubbleH = 37;
    }
    self.bubbleBg.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
    if(self.msg.isMySend && isFileExist(self.msg.fileName))
        _audioPlayer.wh_audioFile = self.msg.fileName;
    else
        _audioPlayer.wh_audioFile = self.msg.content;
    _audioPlayer.wh_timeLen = [self.msg.timeLen intValue];
    _audioPlayer.wh_isLeft  = !self.msg.isMySend;
    _audioPlayer.wh_frame = self.bubbleBg.bounds;
    if(self.msg.isMySend)
        _audioPlayer.wh_timeLenView.textColor = HEXCOLOR(0x4776C6);
    else
        _audioPlayer.wh_timeLenView.textColor = HEXCOLOR(0x3A404C);
//    if(!self.msg.isMySend) [self drawIsRead];
    
    
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([self.msg.isReadDel boolValue]) {
        if (!self.msg.isMySend) {
            if([self.msg.isRead intValue] == transfer_status_yes){
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [self deleteMsg];
                }];
            }
        }else {
            if([self.msg.isSend intValue] == transfer_status_yes){
                [self startTimeer:^(WH_JXMessageObject *msg) {
                    [self deleteMsg];
                }];
            }
        }
    }
    }
//#else
//#endif
}


-(void)drawIsSend{
    [super drawIsSend];
    if (self.msg.isMySend) {
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
        return;
    }
}

//语音红点
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

-(void)didAudioPlayBegin{
    if(!self.msg.isMySend){
        self.msg.isRead = [NSNumber numberWithInt:1];
        [self drawIsRead];
    }
}

-(void)didAudioPlayEnd{
    [g_notify postNotificationName:kCellVoiceStartNotifaction object:self];
    if ([self.msg.isReadDel boolValue] && !self.msg.isMySend) {
        self.msg.readTime = [NSDate date];
        [self timeGo:self.msg.fileName];
    }
}

#pragma mark----开始计时
- (void)timeGo:(NSString *)fileName{
    //防止删除操作重复调用
    if (_oldFileName) {
        if ([_oldFileName isEqualToString:fileName]) {
            return;
        }else{
            self.oldFileName = fileName;
        }
    }else{
        self.oldFileName = fileName;
        
    }
    
    
    [self startTimeer:^(WH_JXMessageObject *msg) {
        [self deleteMsg];
    }];
    //if (self.msg.isReadDel) {
    //计时删除
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.msg.timeLen intValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.delegate != nil && [self.delegate respondsToSelector:self.readDele]){
                
            }
        });
    //}
}
#pragma mark----阅后即焚
- (void)deleteMsg{
    //播放删除动画

    [UIView animateWithDuration:0.5f animations:^{
        self.bubbleBg.alpha = 0;
        self.burnImage.alpha = 0;
    }];//渐变隐藏
    //动画结束后删除UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[webView removeFromSuperview];
        //self.bubbleBg.hidden = NO;
        [self.delegate performSelectorOnMainThread:self.readDele withObject:self.msg waitUntilDone:NO];
        self.bubbleBg.alpha = 1;
        self.burnImage.alpha = 1;
        self.oldFileName = nil;
        //阅后即焚图片通知
        [g_notify postNotificationName:kCellReadDelNotification object:self.msg];
    });
}

+ (float)getChatCellHeight:(WH_JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    if (msg.isGroup && !msg.isMySend) {
        if (msg.isShowTime) {
            n = 65 + 40;
        }else {
            n = 65;
        }
    }else {
        if (msg.isShowTime) {
            n = 55 + 40;
        }else {
            n = 55;
        }
    }
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([msg.isReadDel integerValue] >= 1) {
        n+=30;
//        if ([msg.isShowDel integerValue]>=1) {
//
//
//            if (msg.isMySend) {
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
