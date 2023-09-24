//
//  WH_JXPlayer_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/8/6.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//  直播间观看者

#import "WH_JXPlayer_WHViewController.h"
//#if !TARGET_OS_SIMULATOR
//#import <UPLiveSDKDll/UPAVPlayer.h>
//#import <IJKMediaFramework/IJKMediaFramework.h>
#import <TXLiteAVSDK_Player/TXLiveBase.h>
#import <TXLiteAVSDK_Player/TXVodPlayer.h>
#import <TXLiteAVSDK_Player/TXVodPlayListener.h>
//#endif


#import "WH_ChooseGiftView.h"


//#if !TARGET_OS_SIMULATOR
@interface WH_JXPlayer_WHViewController ()<WH_ChooseGiftViewDelegate,TXLivePlayListener>

@property (atomic, retain) TXLivePlayer *player;

@property (weak, nonatomic) UIView *PlayerView;

@property (nonatomic, strong)UIImageView *dimIamge;
@property (weak, nonatomic) UIView *displayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *bufferingProgressLabel;
/**
 礼物选择
 */
@property (nonatomic, strong) WH_ChooseGiftView * selGiftView;

@property (nonatomic, strong)  UIButton *giftBtn;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, assign) BOOL isPlayOK;

@end
//#endif


@implementation WH_JXPlayer_WHViewController
//#if !TARGET_OS_SIMULATOR
// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.isPlayOK = NO;
    [self.toolBar addSubview:self.giftBtn];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.player isPlaying]) {
        //准备播放
//        [self.player prepareToPlay];
    }
//    [self preparePlay];
}

-(UIButton *)giftBtn{
    if (!_giftBtn) {
        _giftBtn = [UIFactory WH_create_WHButtonWithImage:@"giftWhite" highlight:@"giftWhite" target:self selector:@selector(giftButtonAction:)];
        _giftBtn.frame = CGRectMake(CGRectGetWidth(self.toolBar.frame)-40-40, 0, 40, 40);
    }
    return _giftBtn;
}
-(void)quitLiveRoom{
    _activity.hidden = YES;
    [_activity stopAnimating];
    [self.player stopPlay];
//    [self.player shutdown];
    self.player = nil;
    [super quitLiveRoom];
}

-(void)preparePlay{
    
    
//    if (![self.player isPlaying]) {
//        //准备播放
//        [self.player prepareToPlay];
//    }
}
-(void)settingLive{
    [super settingLive];
    
    [self settingPlayer];
    
    
    // 开启通知
    [self installMovieNotificationObservers];
    
    // 设置加载视图
    [self setupLoadingView];

    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.frame = CGRectMake(0, 0, 20, 20);
        _activity.center = CGPointMake(JX_SCREEN_WIDTH / 2, JX_SCREEN_HEIGHT / 2);
        [g_window addSubview:_activity];
    }
    _activity.hidden = NO;
    [_activity startAnimating];
}


- (void)settingPlayer {
    //1. 初始化播放器
//    _player = [[UPAVPlayer alloc] initWithURL:self.liveUrl];
//    _player.playView.backgroundColor = [UIColor greenColor];
    
//    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.liveUrl] withOptions:nil];
//
//    UIView *playerview = [self.player view];
//    UIView *displayView = [[UIView alloc] initWithFrame:self.view.bounds];
//
//    self.PlayerView = displayView;
//    [self.view addSubview:self.PlayerView];
//
//    // 自动调整自己的宽度和高度
//    playerview.frame = self.PlayerView.bounds;
//    playerview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//
//    [self.PlayerView insertSubview:playerview atIndex:1];
//    [_player setScalingMode:IJKMPMovieScalingModeAspectFill];
    
    
    
//    return;
    //2. 设置代理，�接收状态回调信息
//    _player.delegate = self;
    
    
    UIView *displayView = [[UIView alloc] initWithFrame:self.view.bounds];
    displayView.backgroundColor = [UIColor lightGrayColor];
    self.displayView = displayView;
    _player = [[TXLivePlayer alloc] init];
    _player.delegate = self;
//    [self.view addSubview:self.displayView];
    //3. 设置播放器 playView Frame
    [_player setupVideoWidget:self.displayView.bounds containView:displayView insertIndex:1];

    //4. 添加播放器 playView
    [self.view addSubview:displayView];

    //5. 开始播放
    [_player startPlay:self.wh_liveUrl type:PLAY_TYPE_LIVE_RTMP];

//    //6. 停止播放
//    [_player stop];
    self.view.backgroundColor = [UIColor redColor];
//
//
//    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
//    _activityIndicatorView = [ [ UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
//    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
//    _activityIndicatorView.hidesWhenStopped = YES;
//    [self.displayView addSubview:_activityIndicatorView];
//    _activityIndicatorView.center = CGPointMake(_player.view.center.x - 30, _player.view.center.y);
//
//
//    _bufferingProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
//    _bufferingProgressLabel.backgroundColor = [UIColor clearColor];
//    _bufferingProgressLabel.textColor = [UIColor lightTextColor];
//
//    [self.displayView addSubview:_bufferingProgressLabel];
//    _bufferingProgressLabel.center = CGPointMake(_player.view.center.x + 30, _player.view.center.y);
}

- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
    
    if (EvtID == 2004) {
        _activity.hidden = YES;
        [_activity stopAnimating];
        _dimIamge.hidden = YES;
        self.isPlayOK = YES;
    }
    
//    if (EvtID == 2007) {
//        if (self.isPlayOK) {
//            self.isPlayOK = NO;
//            [g_App showAlert:@"主播已停止直播" delegate:self tag:2457 onlyConfirm:YES];
//        }
//    }
    
//    NSLog(@"evtId = %d", EvtID);
}

#pragma Install Notifiacation
- (void)installMovieNotificationObservers {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loadStateDidChange:)
//                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
//                                               object:_player];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayBackFinish:)
//                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
//                                               object:_player];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
//                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
//                                               object:_player];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayBackStateDidChange:)
//                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
//                                               object:_player];
    
}

- (void)removeMovieNotificationObservers {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
//                                                  object:_player];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
//                                                  object:_player];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
//                                                  object:_player];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
//                                                  object:_player];
    
}

#pragma mark ---- <设置加载视图>
- (void)setupLoadingView
{
    self.dimIamge = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [_dimIamge sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@", self.wh_imageUrl]] placeholderImage:[UIImage imageNamed:@"default_room"]];
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = _dimIamge.bounds;
    [_dimIamge addSubview:visualEffectView];
    [self.view addSubview:_dimIamge];
    
}
//
//#pragma mark - UPAVPlayerDelegate
//- (void)player:(UPAVPlayer *)player playerError:(NSError *)error {
//    //7. 监听播放错误。
//    [self.activityIndicatorView stopAnimating];
//    self.bufferingProgressLabel.hidden = YES;
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"主播已停止直播" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//    [alert addAction:defaultAction];
//    [self presentViewController:alert animated:YES completion:nil];
//
//}
//
//- (void)player:(UPAVPlayer *)player playerStatusDidChange:(UPAVPlayerStatus)playerStatus{
//    switch (playerStatus) {
//        case UPAVPlayerStatusIdle:{
//            NSLog(@"播放停止－－－－－");
//            [self.activityIndicatorView stopAnimating];
//            self.bufferingProgressLabel.hidden = YES;
//        }
//            break;
//
//        case UPAVPlayerStatusPause:{
//            NSLog(@"播放暂停－－－－－");
//            [self.activityIndicatorView stopAnimating];
//            self.bufferingProgressLabel.hidden = YES;
//        }
//            break;
//
//        case UPAVPlayerStatusPlaying_buffering:{
//            NSLog(@"播放缓冲－－－－－");
//            [self.activityIndicatorView startAnimating];
//            self.bufferingProgressLabel.hidden = NO;
//        }
//            break;
//        case UPAVPlayerStatusPlaying:{
////            _isSeeking = NO;
//            NSLog(@"播放中－－－－－");
//            [self.activityIndicatorView stopAnimating];
//            self.bufferingProgressLabel.hidden = YES;
//        }
//            break;
//        case UPAVPlayerStatusFailed:{
//            NSLog(@"播放失败－－－－－");
//
//
//        }
//            break;
//        default:
//            break;
//    }
//}
//- (void)player:(UPAVPlayer *)player displayPositionDidChange:(float)position{
//    NSLog(@"live_position:%f",position);
//}
//- (void)player:(UPAVPlayer *)player bufferingProgressDidChange:(float)progress{
//    self.bufferingProgressLabel.text = [NSString stringWithFormat:@"%.0f %%", (progress * 100)];
//    NSLog(@"live_progress:%f",progress);
//}
////视频流状态
//
//- (void)player:(UPAVPlayer *)player streamStatusDidChange:(UPAVStreamStatus)streamStatus{
//    switch (streamStatus) {
//        case UPAVStreamStatusIdle:
//            NSLog(@"连接断开－－－－－");
//            break;
//        case UPAVStreamStatusConnecting:{
//            NSLog(@"建立连接－－－－－");
//        }
//            break;
//        case UPAVStreamStatusReady:{
//            NSLog(@"连接成功－－－－－");
//        }
//            break;
//        default:
//            break;
//    }
//}
//- (void)player:(UPAVPlayer *)player streamInfoDidReceive:(UPAVPlayerStreamInfo *)streamInfo{
//    NSLog(@"%@",streamInfo.descriptionInfo);
//}



#pragma mark - action
-(void)bgSCrollViewTapAction:(UIGestureRecognizer *)ges{
    
    if (!_editing && !_isGiftViewShow) {
        [self sendPraise];
    }else if (_isGiftViewShow){
        [self hiddenSelGiftView];
    }
    [super bgSCrollViewTapAction:ges];
}

//选择礼物View
-(void)showWH_ChooseGiftView{
    if (!_selGiftView){
        _selGiftView = [[WH_ChooseGiftView alloc] initWithGiftData:self.giftArray delegate:self frame:CGRectMake(0, JX_SCREEN_HEIGHT-230, JX_SCREEN_WIDTH, 230)];
//        _selGiftView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_selGiftView];
    }
    _isGiftViewShow = YES;
    [_selGiftView setHidden:NO];
}

-(void)giftButtonAction:(UIButton *)button{
    [self showWH_ChooseGiftView];
    
}
-(void)hiddenSelGiftView{
    [_selGiftView setHidden:YES];
    _isGiftViewShow = NO;
}
-(void)sendPraise{
    [g_server liveRoomPraise:self.wh_liveRoomId toView:self];
}

-(void)showLiveIsStopView{
//    UIView * showStopView = [[UIView alloc] init];
//    showStopView.backgroundColor = [UIColor redColor];
//    showStopView.frame = CGRectMake(100, 100, 200, 200);
//    
//    [self.view addSubview:showStopView];
    [g_App showAlert:@"主播已停止直播"];
}

-(void)WH_ChooseGiftViewDelegateGift:(WH_JXLiveGift_WHObject *)giftObj count:(NSUInteger)count{
    double giftPrice = [giftObj.price doubleValue];
    if (g_App.myMoney >= giftPrice){
        [g_server liveRoomGiveGift:self.wh_liveRoomId anchorUserId:self.userId giftId:giftObj.wh_giftId price:giftObj.price count:1 toView:self];
//        g_App.myMoney -= giftPrice;
    }else{
        [g_App showAlert:Localized(@"JX_NotEnough") delegate:self tag:2000 onlyConfirm:NO];
    }
}
#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            [[JXXMPP sharedInstance] login];
        }
    }
    
    if (alertView.tag == 2457) {
        [self quitLiveRoom];
    }
}

//#pragma Selector func
//
//- (void)loadStateDidChange:(NSNotification*)notification {
//    IJKMPMovieLoadState loadState = _player.loadState;
//
//    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
//        _activity.hidden = YES;
//        [_activity stopAnimating];
//        NSLog(@"LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: %d\n",(int)loadState);
//    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
//        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
////        [g_App showAlert:@"主播已停止直播" delegate:self tag:2457 onlyConfirm:YES];
//    } else {
//        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
//    }
//}
//
//- (void)moviePlayBackFinish:(NSNotification*)notification {
//    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
//    switch (reason) {
//        case IJKMPMovieFinishReasonPlaybackEnded:
//            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
//            break;
//
//        case IJKMPMovieFinishReasonUserExited:
//            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
//            break;
//
//        case IJKMPMovieFinishReasonPlaybackError:
//            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
//            [self.view removeFromSuperview];
//            break;
//
//        default:
//            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
//            break;
//    }
//}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    
    _dimIamge.hidden = YES;
    
//    switch (_player.playbackState) {
//
//        case IJKMPMoviePlaybackStateStopped:
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
//            break;
//
//        case IJKMPMoviePlaybackStatePlaying:
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
//            break;
//
//        case IJKMPMoviePlaybackStatePaused:
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
//            break;
//
//        case IJKMPMoviePlaybackStateInterrupted:
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
//            break;
//
//        case IJKMPMoviePlaybackStateSeekingForward:
//        case IJKMPMoviePlaybackStateSeekingBackward: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
//            break;
//        }
//
//        default: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
//            break;
//        }
//    }
}

//#endif


@end
