//
//  AskCallViewController.m
//  Tigase_imChatT
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "AskCallViewController.h"
#import "WH_JXCustomButton.h"
#ifdef Live_Version
#import "WH_JXLiveJid_WHManager.h"
#endif
#import "JXAVCallViewController.h"
@interface AskCallViewController ()
@property (strong, nonatomic) UIView *viewTop;
@property (strong, nonatomic) UIImageView *headerImage;
@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) UILabel *labelRemoteParty;
@property (strong, nonatomic) UIView *viewCenter;

@property (strong, nonatomic) UIImageView *imageSecure;

@property (strong, nonatomic) UIView *viewBottom;
@property (strong, nonatomic) UIButton *buttonHangup;

@property (nonatomic, assign) int timerNum;

@end

#define Button_Width 80
#define Button_Height (Button_Width+20)
//#define BtnImage_big 56
//#define BtnImage_small 34
#define BtnImage_big 70
#define BtnImage_small 34

@implementation AskCallViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.wh_isGotoBack = YES;
        self.wh_heightHeader = 0;
        self.wh_heightFooter = 0;
        self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
        g_meeting.isMeeting = YES;
        
        [self customView];
 
        [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsg_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(WH_onSendTimeout:) name:kXMPPSendTimeOut_WHNotifaction object:nil];
        
        [g_meeting sendAsk:self.type toUserId:self.toUserId toUserName:self.toUserName meetUrl:self.meetUrl];
        _bAnswer = NO;
        //[self performSelector:@selector(checkAnswer) withObject:nil afterDelay:30];
//        [self performSelector:@selector(doCall) withObject:nil afterDelay:10];

        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:self.toUserId];
        if ([user.offlineNoPushMsg intValue] != 1) {
            _player = [[WH_AudioPlayerTool alloc]init];
            _player.wh_isOpenProximityMonitoring = NO;
            _player.wh_audioFile = [NSString stringWithFormat:@"%@dial.m4a",imageFilePath];
            [_player wh_open];
            [_player wh_play];
            _player.wh_player.numberOfLoops = 10000;
        }
    }
    return self;
}

- (void)customView {
    self.wh_tableBody.backgroundColor = HEXCOLOR(0x1F2025);
    
    //viewHeader viewTop
    _viewTop = [[UIView alloc] init];
    _viewTop.frame = CGRectMake(0, 40, JX_SCREEN_WIDTH, 86);
    _viewTop.userInteractionEnabled = YES;
    _viewTop.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100);
    [self.wh_tableBody addSubview:_viewTop];
    
    _headerImage = [[UIImageView alloc] init];
    _headerImage.frame = CGRectMake(10, 0, 86, 86);
    _headerImage.userInteractionEnabled = YES;
    [_headerImage headRadiusWithAngle:_headerImage.frame.size.width * 0.5];
    _headerImage.center = CGPointMake(_viewTop.frame.size.width / 2, _viewTop.frame.size.height / 2);
    [g_server WH_getHeadImageLargeWithUserId:self.toUserId userName:self.toUserName imageView:_headerImage];
    [_viewTop addSubview:_headerImage];
    
    _labelRemoteParty = [[UILabel alloc] init];
    _labelRemoteParty.frame = CGRectMake(0, CGRectGetMaxY(_headerImage.frame) + 10, _viewTop.frame.size.width, 43);
    _labelRemoteParty.textColor = [UIColor whiteColor];
    _labelRemoteParty.font = [UIFont systemFontOfSize:36];
    _labelRemoteParty.textAlignment = NSTextAlignmentCenter;
    _labelRemoteParty.text = self.toUserName;
    _labelRemoteParty.center = CGPointMake(_viewTop.frame.size.width / 2, _labelRemoteParty.center.y);
    [_viewTop addSubview:_labelRemoteParty];
    
    _labelStatus = [[UILabel alloc] init];
    _labelStatus.frame = CGRectMake(0, CGRectGetMaxY(_labelRemoteParty.frame) + 10, _viewTop.frame.size.width, 29);
    _labelStatus.textColor = [UIColor whiteColor];
    _labelStatus.font = [UIFont systemFontOfSize:14];
    _labelStatus.textAlignment = NSTextAlignmentCenter;
    _labelStatus.text = Localized(@"AskCallVC_Wait");
    _labelStatus.center = CGPointMake(_viewTop.frame.size.width / 2, _labelStatus.center.y);
    [_viewTop addSubview:_labelStatus];
    
    
    //viewFooter viewBottom
    _viewBottom = [[UIView alloc] init];
    _viewBottom.frame = CGRectMake(0, JX_SCREEN_HEIGHT*3.2/5, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT/2);
    _viewBottom.userInteractionEnabled = YES;
    [self.wh_tableBody addSubview:_viewBottom];
    
    _buttonHangup = [self createBottomButtonWithImage:@"hangup" SelectedImg:nil selector:@selector(doCancel) btnWidth:Button_Width imageWidth:BtnImage_big];
    [_buttonHangup setTitle:Localized(@"JXMeeting_Hangup") forState:UIControlStateNormal];
    _buttonHangup.frame = CGRectMake(JX_SCREEN_WIDTH/2 - (80/2)-5, 112-20, Button_Width, Button_Height);
    
    self.wh_tableBody.contentSize = CGSizeMake(0, 0);

}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    _timerNum = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

// 30秒无响应 自动挂断
- (void)timerAction:(NSTimer *)timer {
    _timerNum ++;
    [_player wh_play];
    NSLog(@"timerNum = %d", _timerNum);
    if (_timerNum > 32) {
        [timer invalidate];
        timer = nil;
        _timerNum = 0;
        [_player wh_stop];
        [self doCancel];
    }
}

-(WH_JXCustomButton *)createBottomButtonWithImage:(NSString *)Image SelectedImg:(NSString *)selectedImage selector:(SEL)selector btnWidth:(CGFloat)btnWidth imageWidth:(CGFloat)imageWidth{
    WH_JXCustomButton * button = [WH_JXCustomButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:Image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    
    [button.titleLabel setFont:sysFontWithSize(12)];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    button.titleRect = CGRectMake(0, imageWidth+(btnWidth-imageWidth)/2, btnWidth, 20);
    button.imageRect = CGRectMake((btnWidth-imageWidth)/2, (btnWidth-imageWidth)/2, imageWidth, imageWidth);
    if (selector)
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [_viewBottom addSubview:button];
    return button;
}

-(void)dealloc{
    //移除监听
    [g_notify removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation{
    WH_JXMessageObject *msg = (WH_JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    
    if ([msg.type integerValue] == kWCMessageTypeAVBusy) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            g_meeting.isMeeting = NO;
            [g_App endCall];
            [self actionQuit];
            [g_server showMsg:Localized(@"JX_TheOtherBusy")];
        });
        return;
    }
    
#ifdef Live_Version
    if([[WH_JXLiveJid_WHManager shareArray] contains:msg.toUserId] || [[WH_JXLiveJid_WHManager shareArray] contains:msg.fromUserId])
        return;
#endif
    if([msg.type intValue] == kWCMessageTypeAudioChatAccept){
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.isAudio = YES;
        avVC.isGroup = NO;
        avVC.toUserId = msg.fromUserId;
        avVC.toUserName = msg.fromUserName;
        avVC.meetUrl = self.meetUrl;
        avVC.roomNum = MY_USER_ID;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        [self actionQuit];
//        UIViewController *lastVC = (UIViewController *)g_navigation.lastVC;
//        [lastVC presentViewController:avVC animated:NO completion:nil];
        
        
    }else if ([msg.type intValue] == kWCMessageTypeVideoChatAccept) {
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.isAudio = NO;
        avVC.isGroup = NO;
        avVC.toUserId = msg.fromUserId;
        avVC.toUserName = msg.fromUserName;
        avVC.meetUrl = self.meetUrl;
        avVC.roomNum = MY_USER_ID;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        [self actionQuit];
//        UIViewController *lastVC = (UIViewController *)g_navigation.lastVC;
//        [lastVC presentViewController:avVC animated:NO completion:nil];
    }
    
    if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel) {
        g_meeting.isMeeting = NO;
        [self actionQuit];
        [g_App endCall];
    }
    
    // 多点登录
    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
        if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatEnd || [msg.type intValue] == kWCMessageTypeAudioChatEnd) {
            [_player wh_stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
        }
    }
    
//    if([msg.type intValue] == kWCMessageTypeAudioChatReady || [msg.type intValue] == kWCMessageTypeVideoChatReady){
//        if([msg.fromUserId isEqualToString:self.toUserId]){
//                [self doCall];
//        }
//    }
}

-(void)WH_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    WH_JXMessageObject *msg     = (WH_JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    if([msg.type intValue] == kWCMessageTypeAudioChatAsk || [msg.type intValue] == kWCMessageTypeVideoChatAsk){
//        [g_App showAlert:@"网络不好，无法送达"];
        [self doNoAnswer:[msg.type intValue]];
        return;
    }
}

-(void)doCancel{
    _bAnswer = YES;
    int n;
    if(self.type == kWCMessageTypeAudioChatAsk)
        n = kWCMessageTypeAudioChatCancel;
    else
        n = kWCMessageTypeVideoChatCancel;
    [g_meeting sendCancel:n toUserId:self.toUserId toUserName:self.toUserName];
    g_meeting.isMeeting = NO;
    [g_App endCall];
    [self actionQuit];
}

-(void)checkAnswer{
    if(!_bAnswer)
        [self doNoAnswer:self.type];
}

-(void)doNoAnswer:(int)type{
    int n;
    if(type == kWCMessageTypeAudioChatAsk)
        n = kWCMessageTypeAudioChatCancel;
    else
        n = kWCMessageTypeVideoChatCancel;
    [g_meeting sendNoAnswer:n toUserId:self.toUserId toUserName:self.toUserName];
    g_meeting.isMeeting = NO;
    [g_App endCall];
    [self actionQuit];
}

-(void)actionQuit{
    [super actionQuit];
    
    [_timer invalidate];
    _timer = nil;
    
    [_player wh_stop];
    _player = nil;
    
    
}

@end
