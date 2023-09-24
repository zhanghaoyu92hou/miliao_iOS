//
//  WH_AudioPlayerTool.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 17/1/12.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_AudioPlayerTool.h"
#import "VoiceConverter.h"
#import "WH_AudioSessionControl.h"

#import <MediaPlayer/MediaPlayer.h>


@implementation WH_AudioPlayerTool
@synthesize wh_player=_wh_player,delegate,wh_timeLenView=_wh_timeLenView;

- (id)initWithParent:(UIView*)value{
    self = [super init];
    if (self) {
        self.wh_parent = value;
        [self reset];
        
        _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _pauseBtn.center = CGPointMake(_wh_parent.frame.size.width/2,_wh_parent.frame.size.height/2);
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"feeds_play_btn_u"] forState:UIControlStateNormal];
        [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"feeds_play_btn_h_u"] forState:UIControlStateSelected];
        [_pauseBtn addTarget:self action:@selector(wh_switch) forControlEvents:UIControlEventTouchUpInside];
        [_wh_parent addSubview:_pauseBtn];

        _wait = [[WH_JXWaitView alloc] initWithParent:_wh_parent];
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

-(id)initWithParent:(UIView*)parent frame:(CGRect)frame isLeft:(BOOL)isLeft isCollect:(BOOL)collect {
    self = [super init];
    if (self) {
        self.wh_parent = parent;
        [self reset];
        
        _wh_frame = frame;
        _wh_voiceBtn = [[WH_JXImageView alloc] initWithFrame:frame];
        _wh_voiceBtn.wh_delegate = self;
//        _wh_voicebtn.didTouch = @selector(voicePlayViewDidTouch);
        _wh_voiceBtn.userInteractionEnabled = YES;
        _wh_voiceBtn.backgroundColor = [UIColor clearColor];
        _wh_voiceBtn.didTouch = @selector(wh_switch);
        _wh_voiceBtn.wh_delegate = self;
        [_wh_parent addSubview:_wh_voiceBtn];
        
        if (collect) {
            UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            [_wh_voiceBtn addSubview:iconImg];
            [iconImg setImage:[UIImage imageNamed:@"WH_Collect_Audio"]];
        }
        
        _voiceView = [[WH_JXImageView alloc]init];
        _voiceView.animationDuration = 1;
        _voiceView.frame = CGRectMake(2, 1.5, 25, _wh_voiceBtn.frame.size.height-3);
        [_wh_voiceBtn addSubview:_voiceView];
        //        [_voiceView release];
        
        _wh_timeLenView = [[UILabel alloc] init];
        _wh_timeLenView.backgroundColor = [UIColor clearColor];
        _wh_timeLenView.textColor = [UIColor blackColor];
        _wh_timeLenView.font = sysFontWithSize(16);
        _wh_timeLenView.userInteractionEnabled = NO;
        [_wh_voiceBtn addSubview:_wh_timeLenView];
        //        [_wh_timeLenView release];
        
        _wh_showProgress = YES;
        _wh_pgBGView = [[UIView alloc] init];
        [_wh_voiceBtn addSubview:_wh_pgBGView];
        
        _wh_progressView = [[UIProgressView alloc] init];
        _wh_progressView.progress = 0.0;
        [_wh_pgBGView addSubview:_wh_progressView];
        _wh_pgBGView.hidden= YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAudioTime:)];
        [_wh_pgBGView addGestureRecognizer:tap];
        
        
        _wait = [[WH_JXWaitView alloc] initWithParent:_wh_voiceBtn];
        self.wh_isLeft = isLeft;
        self.wh_isCollect = collect;
        
    }
    return self;
}

- (id)initWithParent:(UIView*)value frame:(CGRect)frame isLeft:(BOOL)isLeft{
    self = [super init];
    if (self) {
        self.wh_parent = value;
        [self reset];

        _wh_frame = frame;
        _wh_voiceBtn = [[WH_JXImageView alloc] initWithFrame:frame];
        _wh_voiceBtn.wh_delegate = self;
//        _wh_voicebtn.didTouch = @selector(voicePlayViewDidTouch);
        _wh_voiceBtn.userInteractionEnabled = YES;
        _wh_voiceBtn.backgroundColor = [UIColor clearColor];
        _wh_voiceBtn.layer.cornerRadius = 3;
        _wh_voiceBtn.layer.masksToBounds = YES;
        _wh_voiceBtn.didTouch = @selector(wh_switch);
        _wh_voiceBtn.wh_delegate = self;
        [_wh_parent addSubview:_wh_voiceBtn];
        
        _voiceView = [[WH_JXImageView alloc]init];
        _voiceView.animationDuration = 1;
        _voiceView.frame = CGRectMake(2, 1.5, 25, _wh_voiceBtn.frame.size.height-3);
        [_wh_voiceBtn addSubview:_voiceView];
//        [_voiceView release];

        _wh_timeLenView = [[UILabel alloc] init];
        _wh_timeLenView.backgroundColor = [UIColor clearColor];
        _wh_timeLenView.textColor = [UIColor blackColor];
        _wh_timeLenView.font = sysFontWithSize(16);
        _wh_timeLenView.userInteractionEnabled = NO;
        [_wh_voiceBtn addSubview:_wh_timeLenView];
//        [_wh_timeLenView release];
        
        _wh_showProgress = YES;
        _wh_pgBGView = [[UIView alloc] init];
        [_wh_voiceBtn addSubview:_wh_pgBGView];
        
        _wh_progressView = [[UIProgressView alloc] init];
        _wh_progressView.progress = 0.0;
        [_wh_pgBGView addSubview:_wh_progressView];
        _wh_pgBGView.hidden= YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAudioTime:)];
        [_wh_pgBGView addGestureRecognizer:tap];
        
        
        _wait = [[WH_JXWaitView alloc] initWithParent:_wh_voiceBtn];
        self.wh_isLeft = isLeft;
    }
    return self;
}

-(void)gotoAudioTime:(UITapGestureRecognizer *)tapGes{
    CGPoint touchPoint = [tapGes locationInView:tapGes.view];
    float progress = touchPoint.x / tapGes.view.frame.size.width;
    _wh_progressView.progress = progress;
    NSLog(@"ddddd%f",_player.duration*progress);
    _player.currentTime = _player.duration*progress;
}

- (void)dealloc {
    NSLog(@"WH_AudioPlayerTool.dealloc");
    self.wh_parent = nil;
    [g_notify removeObserver:self];
    [self freeTimer];
    [self wh_stop];
}

-(void)reset{
    _isOpened = NO;
    self._wh_isPlaying = NO;
    _array=[[NSMutableArray alloc] init];

    [g_notify addObserver:self selector:@selector(playerPause:) name:kAllAudioPlayerPauseNotifaction object:nil];//开始录音
    [g_notify addObserver:self selector:@selector(playerStop:) name:kAllAudioPlayerStopNotifaction object:nil];//开始录音
    [g_notify addObserver:self selector:@selector(EnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self setHardware];
}

-(void)setHardware{
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    //初始化播放器的时候如下设置,添加监听
//    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    //默认情况下扬声器播放
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [audioSession setActive:YES error:nil];
//    audioSession = nil;
}

- (void)set_wh_isPlaying:(BOOL)isPlaying{
    if (_wh_isPlaying != isPlaying) {
        _wh_isPlaying = isPlaying;
        if (_wh_isPlaying) {
            [WH_AudioSessionControl pauseBackgroundSoundWithError:nil];
        } else {
            [WH_AudioSessionControl resumeBackgroundSoundWithError:nil];
        }
    }
}
//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        if(!self.wh_isPlaying)//正在播放才影响
            return;
        
        if(![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
            NSLog(@"切换到听筒模式");
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }
    }
    else
    {
        if(![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayback]) {
            NSLog(@"切换到免提模式");
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
        
        if (!self.wh_isPlaying) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [g_notify removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
        }else {
            if (self.wh_isOpenProximityMonitoring) {
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            }
        }
    }
}

-(void)wh_open{
    
    if (!_wh_audioFile) {
        return;
    }
    
    NSString* file;
    file = [myTempFilePath stringByAppendingString:[_wh_audioFile lastPathComponent]];
    
    if([_wh_audioFile rangeOfString:@"://"].location != NSNotFound){
        if(![[NSFileManager defaultManager]fileExistsAtPath:file]){
            [self downloadFile:_wh_audioFile];
            return;
        }
    }else
        file = _wh_audioFile;
    
    if([[[_wh_audioFile pathExtension] uppercaseString] isEqualToString:@"AMR"])
        file = [VoiceConverter amrToWav:file];
    if(file==nil)
        return;
    if(_player)
        [self wh_stop];
    
    _player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:file] error:nil];
    _player.delegate = self;
    _player.volume = 1;
    
//    float volume = [[AVAudioSession sharedInstance] outputVolume];
//    if (volume == 0) {
//        _player.volume = 0;
//    } else {
//        _player.volume = 1;
//    }
    _isOpened = YES;
    
    if(_player.prepareToPlay)
        [self doAudioOpen];
}

-(void)wh_switch{
    if(_player.prepareToPlay){
        if(_player.isPlaying){
            [self wh_pause];
        }
        else{
            [self wh_play];
        }
    }else{
        [self wh_open];
        [self wh_play];
    }
}

-(void)wh_play{
    if(!_player.prepareToPlay)
        return;
    if (!self.wh_isNotStopLast) {
        [g_notify postNotificationName:kAllAudioPlayerPauseNotifaction object:self userInfo:nil];
        [g_notify postNotificationName:kAllVideoPlayerPauseNotifaction object:self userInfo:nil];
    }
    [_player play];
    [self doPlayBegin];
}

-(void)wh_pause{
    [self doPause];
    [_player pause];
}

-(void)wh_stop{
    if(_player==nil)
        return;
    [self doPause];
    [_player stop];
//    [_player release];
    _player = nil;
    _isOpened = NO;
}

-(void)setwh_parent:(UIView *)value{
    [self adjust];
    if([_wh_parent isEqual:value])
        return;
//    [_wh_parent release];
//    _wh_parent = [value retain];
    _wh_parent = value;
    [self adjust];
}

-(void)setWh_audioFile:(NSString *)value{
    if([_wh_audioFile isEqual:value])
        return;
//    [_wh_audioFile release];
//    _wh_audioFile = [value retain];
    _wh_audioFile = value;
    
    [self wh_stop];
}

-(void)playerStop:(NSNotification*)notification{
    if([notification.object isEqual:self])
        return;
    [self wh_stop];
}

-(void)playerPause:(NSNotification*)notification{
    if([notification.object isEqual:self])
        return;
    [self wh_pause];
}

- (void)downloadFile:(NSString *)fileUrl{
    if([fileUrl length]<=0)
        return;
    NSString *filepath = [myTempFilePath stringByAppendingPathComponent:[fileUrl lastPathComponent]];
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filepath])
        [g_server addTask:fileUrl param:nil toView:self];
}

- (void)WH_didServerResult_WHSucces:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait WH_stop];
    self.wh_audioFile = aDownload.downloadFile;
    [self wh_open];
//    [_player play];
    [self wh_play];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait WH_stop];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{
    [_wait WH_stop];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait WH_start];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player1 successfully:(BOOL)flag{
    [self doPlayEnd];
}

-(void)adjust{
    if(_wh_parent==nil)
        return;
    
    [_wh_parent addSubview:_wh_voiceBtn];
    [_wh_parent addSubview:_pauseBtn];
    _wh_voiceBtn.frame = _wh_frame;
    _pauseBtn.center = CGPointMake(_wh_parent.frame.size.width/2,_wh_parent.frame.size.height/2);
    if(_wh_voiceBtn)
        _wait.parent = _wh_voiceBtn;
    else
        _wait.parent = _wh_parent;
    [_wait WH_adjust];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player{
    [self doPause];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    //NSLog(@"");
}

-(void)doAudioOpen{
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioOpen])
        [self.delegate performSelectorOnMainThread:self.didAudioOpen withObject:self waitUntilDone:NO];
}

-(void)doPlayEnd{
    self._wh_isPlaying = NO;
    
    if ([[UIDevice currentDevice] proximityState] == NO) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //播放结束设置NO，结束红外感应
        [g_notify removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    }
    

    _pauseBtn.selected = NO;
    [_voiceView stopAnimating];
    _wh_progressView.progress = 0.0;
    _wh_pgBGView.hidden = YES;
    [self freeTimer];
    if (!_wh_parent) return;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioPlayEnd])
        [self.delegate performSelectorOnMainThread:self.didAudioPlayEnd withObject:self waitUntilDone:NO];
}

-(void)doPlayBegin{
    self._wh_isPlaying = YES;
    if (self.wh_isOpenProximityMonitoring) {
        [g_notify addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //播放之前设置yes，开启红外感应
    }
    _pauseBtn.selected = YES;
    if (!_wh_isCollect) {
        [_voiceView startAnimating];
    }

    _wh_pgBGView.hidden = (_wh_timeLen >= 10 && _wh_showProgress) ? NO : YES;
    if (_wh_timer == nil) {
        _wh_timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }

    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioPlayBegin])
        [self.delegate performSelectorOnMainThread:self.didAudioPlayBegin withObject:self waitUntilDone:NO];
}

-(void)doPause{
    self.wh_isPlaying = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //播放结束设置NO，结束红外感应
    _pauseBtn.selected = NO;
    [_voiceView stopAnimating];
    _wh_pgBGView.hidden = YES;
    [self freeTimer];

    if(self.delegate != nil && [self.delegate respondsToSelector:self.didAudioPause])
        [self.delegate performSelectorOnMainThread:self.didAudioPause withObject:self waitUntilDone:NO];
}
-(void)freeTimer{
    [_wh_timer invalidate];
    _wh_timer = nil;
}
-(void)EnterForeground{
    if(_player.prepareToPlay){
        [self performSelector:@selector(wh_pause) withObject:nil afterDelay:0.1];
    }
}
- (void)setWh_isLeft:(BOOL)value{
    _wh_isLeft = value;
    self.wh_timeLen = _wh_timeLen;

    [_array removeAllObjects];
    NSString* file,*s;
    if (self.wh_isCollect) {
        file = @"";
        _voiceView.image = [UIImage imageNamed:file];
    }else{
        if(!_wh_isLeft)
            file = @"WH_voice_paly_right_";
        else
            file = @"WH_voice_paly_left_";
        
        for(int i=1;i<=3;i++){
            s = [NSString stringWithFormat:@"%@%d",file,i];
            [_array addObject:[UIImage imageNamed:s]];
        }
        _voiceView.animationImages = _array;
        _voiceView.image = [_array objectAtIndex:[_array count]-1];
    }
    
}


-(void)setWh_timeLen:(int)value{
    _wh_timeLen = value;
    if(_wh_timeLen <= 0)
        _wh_timeLen = 1;
    int w = (JX_SCREEN_WIDTH-HEAD_SIZE-INSETS*2-70)/30;
    w = 70+w*self.wh_timeLen;
    if(w<70)
        w = 70;
    if(w>200)
        w = 200;
    if(w>_wh_frame.size.width)
        w = _wh_frame.size.width;
    
    if(_wh_isLeft){
        _voiceView.frame = CGRectMake(INSETS, (_wh_frame.size.height-24)/2, 24, 24);
        _wh_timeLenView.frame = CGRectMake(55, (_wh_frame.size.height-24)/2, 60, 24);
//        _wh_timeLenView.textAlignment = NSTextAlignmentRight;
        _wh_pgBGView.frame = CGRectMake(CGRectGetMaxX(_voiceView.frame), 0, CGRectGetMinX(_wh_timeLenView.frame)-CGRectGetMaxX(_voiceView.frame), _wh_frame.size.height);
    }
    else{
        _voiceView.frame = CGRectMake(w-INSETS-24, (_wh_frame.size.height-24)/2, 24, 24);
        _wh_timeLenView.frame = CGRectMake(4+5,    (_wh_frame.size.height-24)/2, 60, 24);
        _wh_timeLenView.textAlignment = NSTextAlignmentLeft;
        _wh_pgBGView.frame = CGRectMake(CGRectGetMaxX(_wh_timeLenView.frame), 0, CGRectGetMinX(_voiceView.frame)-CGRectGetMaxX(_wh_timeLenView.frame), _wh_frame.size.height);
    }
    _wh_progressView.transform = CGAffineTransformIdentity;
    _wh_progressView.frame = CGRectMake(0, (CGRectGetHeight(_wh_pgBGView.frame)-2)/2, CGRectGetWidth(_wh_pgBGView.frame), 2);
    _wh_progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    if (_wh_isCollect) {
        if (_wh_timeLen == 60) {
            _wh_timeLenView.text = @"1:00";
        }else{
            _wh_timeLenView.text = [NSString stringWithFormat:@"00:%02d" ,_wh_timeLen];
        }
    }else{
        _wh_timeLenView.text = [NSString stringWithFormat:@"%d''",_wh_timeLen];
    }
    

}

-(void)setWh_hidden:(BOOL)value{
    _pauseBtn.hidden = value;
    _wh_voiceBtn.hidden = value;
}

- (void)setWh_frame:(CGRect)value {
    _wh_frame = value;
    [self adjust];
    self.wh_isLeft = _wh_isLeft;
}

-(void)updateProgress{
    [_wh_progressView setProgress:(_player.currentTime/_player.duration) animated:YES];
//    NSLog(@"player_%f,%f",_player.currentTime,_player.duration);
}



@end
