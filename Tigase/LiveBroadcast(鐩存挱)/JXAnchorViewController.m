//
//  MX_AnchorMXViewController.m
//  shiku_im
//
//  Created by 1 on 17/8/6.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "MX_AnchorMXViewController.h"
#import "LFLiveSession.h"



@interface MX_AnchorMXViewController ()<LFLiveSessionDelegate,UIAlertViewDelegate>{
    BOOL _isRequestVideoAuthorizate;//重新请求相机授权
    BOOL _isRequestAudioAuthorizate;//重新请求麦克风授权
}

//@property (nonatomic, strong) UIView *containerView;
@property (weak, nonatomic) UIView *displayView;
@property (nonatomic, strong) LFLiveDebug *debugInfo;

@property (nonatomic, strong) LFLiveSession *session;

//美颜
@property (nonatomic, strong) UIButton *beautyButton;

//切换前后摄像头
@property (nonatomic, strong) UIButton *cameraButton;
//开始直播
@property (nonatomic, strong) UIButton *startLiveButton;

@end

@implementation MX_AnchorMXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.toolBar addSubview:self.startLiveButton];
    [self.toolBar addSubview:self.cameraButton];
    [self.toolBar addSubview:self.beautyButton];
    
    [g_notify addObserver:self selector:@selector(onReceiveRoomRemind:) name:kXMPPRoomNotifaction object:nil];
    
    if (_isRequestVideoAuthorizate) {
        [self requestAccessForVideo];
        if (_isRequestVideoAuthorizate) {
            //            [g_App showAlert:@"你已拒绝APP访问相机,继续操作请前往设置->隐私更改设置"];
            [g_App showAlert:Localized(@"JX_CanNotopenCenmar")];
        }
    }else if (_isRequestAudioAuthorizate) {
        [self requestAccessForAudio];
        if (_isRequestAudioAuthorizate) {
            //            [g_App showAlert:@"你已拒绝APP访问麦克风,继续操作请前往设置->隐私更改设置"];
            [g_App showAlert:Localized(@"JX_CanNotOpenMicr")];
        }
    }
    
    [self startLiveButtonAction:_startLiveButton];
    
}

- (void)dealloc {
    [g_notify removeObserver:self];
}

-(void)onReceiveRoomRemind:(NSNotification *)notifacation {
    JXRoomRemind *p= (JXRoomRemind *)notifacation.object;
    if ([p.type integerValue] == kLiveRemind_RoomDisable) {
        [g_App showAlert:Localized(@"JX_RoomNotUse") delegate:self tag:2457 onlyConfirm:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2457) {
        if (buttonIndex == 0) {
            [self quitLiveRoom];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)settingLive{
    //视频的视图
    UIView *displayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.displayView = displayView;
    [self.view addSubview:self.displayView];
    
    //加载视频录制
    [self requestAccessForVideo];
    
    //加载音频录制
    [self requestAccessForAudio];
    
    if (!_isRequestVideoAuthorizate && !_isRequestAudioAuthorizate) {
        [self.session setRunning:YES];
    }
    
    
    
    //    创建界面容器
    //    [self.view insertSubview:self.containerView atIndex:0];
}


#pragma mark ---- <加载视频录制>
- (void)requestAccessForVideo{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    _isRequestVideoAuthorizate = NO;
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            _isRequestVideoAuthorizate = NO;
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            _isRequestVideoAuthorizate = YES;
            break;
        default:
            break;
    }
}

#pragma mark ---- <加载音频录制>
- (void)requestAccessForAudio{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    _isRequestAudioAuthorizate = NO;
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            _isRequestAudioAuthorizate = NO;
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            _isRequestAudioAuthorizate = YES;
            break;
        default:
            break;
    }
}

#pragma mark ---- <创建会话>
- (LFLiveSession*)session{
    if(!_session){
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Low3]];
        _session.running = YES;
        _session.preView = self.displayView;
        _session.showDebugInfo = YES;
        _session.delegate = self;
    }
    return _session;
}

- (void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo {
    NSLog(@"debugInfo == %@", debugInfo);
}

- (void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    
    NSLog(@"errorCode == %lu", (unsigned long)errorCode);
}

- (void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"state == %lu", (unsigned long)state);
    if (state == LFLiveError) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [JXMyTools showTipView:@"服务器出错"];
            _session = nil;
            [g_server liveRoomStatus:0 roomId:self.liveRoomId toView:nil];
            [super quitLiveRoom];
        });
    }
}

#pragma mark ---- <开始录制>
//调用LF的API开始录制
- (UIButton*)startLiveButton{
    if(!_startLiveButton){
        
        _startLiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //位置
        _startLiveButton.frame = CGRectMake(0, 0, 200, 40);
        _startLiveButton.center = CGPointMake(CGRectGetWidth(self.toolBar.frame)/2, _startLiveButton.center.y);
        _startLiveButton.layer.cornerRadius = _startLiveButton.frame.size.height * 0.5;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:Localized(@"JXLiveVC_StartLive") forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor grayColor]];
        _startLiveButton.exclusiveTouch = YES;
        
        [_startLiveButton addTarget:self action:@selector(startLiveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startLiveButton;
}
#pragma mark ---- <切换摄像头>
- (UIButton*)cameraButton{
    if(!_cameraButton){
        _cameraButton = [UIButton new];
        
        //位置
        _cameraButton.frame = CGRectMake(CGRectGetMaxX(_startLiveButton.frame) +10, 0, 40, 40);
        
        [_cameraButton setImage:[UIImage imageNamed:@"camra_preview"] forState:UIControlStateNormal];
        _cameraButton.exclusiveTouch = YES;
        [_cameraButton addTarget:self action:@selector(switchCameraAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cameraButton;
}

#pragma mark ---- <美颜功能>
- (UIButton*)beautyButton{
    if(!_beautyButton){
        _beautyButton = [UIButton new];
        
        //位置
        _beautyButton.frame = CGRectMake(CGRectGetMaxX(_cameraButton.frame), 0, 40, 40);
        
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateSelected];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateNormal];
        _beautyButton.exclusiveTouch = YES;
        
        [_beautyButton addTarget:self action:@selector(beautyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}



#pragma mark - buttonAction
-(void)startLiveButtonAction:(UIButton *)button{
    _startLiveButton.enabled = NO;
    [self performSelector:@selector(changeStartButtonEnable) withObject:nil afterDelay:0.5];
    
    _startLiveButton.selected = !_startLiveButton.selected;
    if(_startLiveButton.selected){
        [_startLiveButton setTitle:Localized(@"JXLiveVC_StopLive") forState:UIControlStateNormal];
        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
        stream.url = self.liveUrl;
        _session.showDebugInfo = YES;
        [_session startLive:stream];
        [g_server liveRoomStatus:1 roomId:self.liveRoomId toView:self];
    }else{
        [_startLiveButton setTitle:Localized(@"JXLiveVC_StartLive") forState:UIControlStateNormal];
//        [_session stopLive];
//        [g_server liveRoomStatus:0 roomId:self.liveRoomId toView:self];
        
        [self quitLiveRoom];
    }
}

-(void)changeStartButtonEnable{
    _startLiveButton.enabled = YES;
}

-(void)switchCameraAction:(UIButton *)button{
    AVCaptureDevicePosition devicePositon = _session.captureDevicePosition;
    _session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

-(void)beautyButtonAction:(UIButton *)button{
    _session.beautyFace = !_session.beautyFace;
    _beautyButton.selected = !_session.beautyFace;
}

-(void)quitLiveRoom{
    [_session stopLive];
    _session = nil;
    [g_server liveRoomStatus:0 roomId:self.liveRoomId toView:nil];
    [super quitLiveRoom];
}

@end
