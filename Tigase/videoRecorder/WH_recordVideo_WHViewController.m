#import "WH_recordVideo_WHViewController.h"
#import "WH_JXConvertMedia.h"
#import "WH_JXCaptureMedia.h"
#import "WH_JXImageView.h"


@implementation WH_recordVideo_WHViewController
@synthesize delegate;
@synthesize didRecord;
@synthesize timeLen;
@synthesize outputFileName;
@synthesize wh_recorder=_capture;

- (id)init
{
    self = [super init];
    _pSelf = self;
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.view.backgroundColor = HEXCOLOR(0x2e2f2f);
    preview = [[UIView alloc] initWithFrame:g_window.bounds];
    [self.view addSubview:preview];
//    [preview release];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-(JX_SCREEN_HEIGHT-JX_SCREEN_WIDTH)/2, JX_SCREEN_WIDTH, (JX_SCREEN_HEIGHT-JX_SCREEN_WIDTH)/2)];
    _bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bottomView];
//    [_bottomView release];
    
    CGFloat btnW = _bottomView.frame.size.height/1.8;
    _recrod = [UIButton buttonWithType:UIButtonTypeCustom];
    _recrod.frame = CGRectMake((JX_SCREEN_WIDTH-btnW)/2, 10, btnW, btnW);
//    _recrod.center = CGPointMake(_recrod.center.x, _recrod.);
    [_recrod setBackgroundImage:[UIImage imageNamed:@"recordvideo_normal"] forState:UIControlStateNormal];
    [_recrod setBackgroundImage:[UIImage imageNamed:@"play_press"] forState:UIControlStateSelected];
    [_recrod addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_recrod];
    
    _recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 17)];
    _recordLabel.center = CGPointMake(_recrod.center.x, _recrod.center.y+(CGRectGetHeight(_recrod.frame)+25)/2);
    _recordLabel.text = Localized(@"JX_Recorder");
    _recordLabel.textColor = [UIColor whiteColor];
    _recordLabel.font = sysFontWithSize(12);
    _recordLabel.backgroundColor = [UIColor clearColor];
    _recordLabel.textAlignment = NSTextAlignmentCenter;
    [_bottomView addSubview:_recordLabel];
//    [_recordLabel release];
    
    _close = [[WH_JXImageView alloc]initWithFrame:CGRectMake(52, _recrod.frame.origin.y, 31, 31)];
    _close.center = CGPointMake(_close.center.x, _recrod.center.y);
    _close.image = [UIImage imageNamed:@"fork"];
    _close.userInteractionEnabled = YES;
    _close.wh_delegate = self;
    _close.didTouch = @selector(onQuit);
    [_bottomView addSubview:_close];
//    [_close release];

    _save = [[WH_JXImageView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-_close.frame.origin.x-_close.frame.size.width, _close.frame.origin.y, 31, 31)];
    _save.image = [UIImage imageNamed:@"tick"];
    _save.userInteractionEnabled = YES;
    _save.wh_delegate = self;
    _save.didTouch = @selector(onSave);
    [_bottomView addSubview:_save];
//    [_save release];
    
    _flash = [[WH_JXImageView alloc]initWithFrame:CGRectMake(16, 10, 30, 30)];
    _flash.image = [UIImage imageNamed:@"automatic"];
    _flash.userInteractionEnabled = YES;
    _flash.wh_delegate = self;
    _flash.didTouch = @selector(flash);
    [self.view addSubview:_flash];
//    [_flash release];
    
    
    _flashOn = [[WH_JXImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_flash.frame)+20, CGRectGetMinY(_flash.frame), 30, 30)];
    _flashOn.image = [UIImage imageNamed:@"flash_on"];
    _flashOn.userInteractionEnabled = YES;
    _flashOn.wh_delegate = self;
    _flashOn.didTouch = @selector(flashOn);
    _flashOn.hidden = YES;
    [self.view addSubview:_flashOn];
//    [_flashOn release];
    
    _flashOff = [[WH_JXImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_flashOn.frame)+20, CGRectGetMinY(_flash.frame), 30, 30)];
    _flashOff.image = [UIImage imageNamed:@"flash_off"];
    _flashOff.userInteractionEnabled = YES;
    _flashOff.wh_delegate = self;
    _flashOff.didTouch = @selector(flashOff);
    _flashOff.hidden = YES;
    [self.view addSubview:_flashOff];
//    [_flashOff release];
    
    _cammer = [[WH_JXImageView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-16-30, CGRectGetMinY(_flash.frame), 30, 27)];
    _cammer.image = [UIImage imageNamed:@"switch_cammer"];
    _cammer.userInteractionEnabled = YES;
    _cammer.wh_delegate = self;
    _cammer.didTouch = @selector(toggle);
    [self.view addSubview:_cammer];
//    [_cammer release];
    
    
    //时间
    _timeBGView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-210)/2, (JX_SCREEN_HEIGHT-JX_SCREEN_WIDTH)/2-35, 210, 2)];
    _timeBGView.image = [UIImage imageNamed:@"time_axis"];
    _timeBGView.hidden  =YES;
    [self.view addSubview:_timeBGView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
    _timeLabel.center = _timeBGView.center;
    _timeLabel.text = @"";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.shadowColor  = [UIColor blackColor];
    _timeLabel.shadowOffset = CGSizeMake(1, 1);
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_timeLabel];
//    [_timeLabel release];
//    [_timeBGView release];
    
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, JX_SCREEN_WIDTH-45*2, 45)];
    _noticeLabel.center = self.view.center;
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.font = sysFontWithSize(15);
    _noticeLabel.numberOfLines = 2;
    _noticeLabel.backgroundColor = [UIColor clearColor];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_noticeLabel];
//    [_noticeLabel release];
    [self noticeLabelHidden:NO textType:1];
    
    [self initCapture];
    return self;
}


- (void)initCapture{
    _capture = [[WH_JXCaptureMedia alloc]init];
//    _capture.logoImage = [UIImage imageNamed:@"logo"];
    _capture.logoRect  = CGRectMake(0, JX_SCREEN_WIDTH-100, 100, 100);
    _capture.saveVideoToImage = 1;
    _capture.maxTime = _maxTime;
    _capture.isOnlySaveFirstImage = !_isShowSaveImage;
    _capture.labelTime = _timeLabel;
    _capture.isReciprocal = _isReciprocal;
    _capture.isRecordAudio = YES;
    _capture.isEditVideo = YES;
    _capture.videoWidth = JX_SCREEN_HEIGHT;
    _capture.videoHeight = JX_SCREEN_WIDTH;
    _capture.outputFileName = [FileInfo getUUIDFileName:@"mp4"];
    if(![_capture createPreview:preview]){
        [self performSelector:@selector(onQuit) withObject:nil afterDelay:1];
        return;
    }
    
    [g_notify addObserver:self selector:@selector(recordAutoEnd:) name:kVideoRecordEndNotifaction object:nil];//开始录音
}

- (void)dealloc {
    NSLog(@"WH_recordVideo_WHViewController.dealloc");
    [UIApplication sharedApplication].statusBarHidden = NO;
//    [super dealloc];
}

- (void)onSave{
    if(_capture.isRecording){
        if(_capture.timeLen < _minTime && _minTime > 0){
            [self noticeLabelHidden:NO textType:2];
            [self performSelector:@selector(hiddenNoticeLabel) withObject:nil afterDelay:3];
            return;
        }
        [_capture stop];
    }
    if(_isShowSaveImage && [_capture.outputImageFiles count]){
        WH_ImageSelector_WHViewController * imageSelectVC = [[WH_ImageSelector_WHViewController alloc] init];
        imageSelectVC.imageFileNameArray = _capture.outputImageFiles;
        imageSelectVC.imgDelegete = self;
        imageSelectVC.title = Localized(@"ImageSelectorVC_SelImage");
//        [g_window addSubview:imageSelectVC.view];
        [g_navigation pushViewController:imageSelectVC animated:YES];
    }else{
            [self notifyWithImage:nil];
        [self showPreview];
//            [self doQuit];
    }
}

-(void)notifyWithImage:(NSString *)imagePath{
    if (imagePath) {
        self.outputImage = imagePath;
    }else{
        if (_capture.outputImageFiles.count > 0)
            self.outputImage = _capture.outputImageFiles[0];
    }
    self.outputFileName = _capture.outputFileName;
    self.timeLen = (int)_capture.timeLen;
    if(_capture.timeLen>0)
        if (delegate && [delegate respondsToSelector:didRecord])
//            [delegate performSelector:didRecord withObject:self];
            [delegate performSelectorOnMainThread:didRecord withObject:self waitUntilDone:NO];
}

-(void)imageSelectorDidiSelectImage:(NSString *)imagePath{
    NSLog(@"imageSelectorDidiSelectImage:%@",imagePath);
    [self notifyWithImage:imagePath];
    [self doQuit];
}

- (void)toggle{
    [_capture toggleCamera];
    if(_capture.isFrontFace)
        [self flashOff];
}


- (void)start{
    [_capture start];
}

- (void)stop{
    [_capture stop];
}

- (IBAction)record:(UIButton*)sender{
    _recrod.selected = !_recrod.selected;
    if(_capture.isRecording){
        if(_capture.timeLen < _minTime && _minTime > 0){
            [self noticeLabelHidden:NO textType:2];
            [self performSelector:@selector(hiddenNoticeLabel) withObject:nil afterDelay:3];
            return;
        }
        _timeBGView.hidden = YES;
        _timeLabel.hidden = YES;
        _recordLabel.hidden = NO;
//        [self noticeLabelHidden:NO textType:1];
        
        [_capture stop];
        [self onSave];
//        if(self.didRecord)
//            [self onSave];
//        else
//            [_capture stop];

    }else{
        _timeBGView.hidden = NO;
        _timeLabel.hidden = NO;
        _recordLabel.hidden = YES;
        [self noticeLabelHidden:YES textType:1];
        [_capture clearTempFile];
        [_capture start];
    }
//    _recrod.selected = _capture.isRecording;
}

- (void)showPreview {
    _wh_playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_wh_playerView];
    _wh_player= [WH_JXVideoPlayer alloc];
    _wh_player.type = JXVideoTypePreview;
    _wh_player.isShowHide = YES; //播放中点击播放器便销毁播放器
    _wh_player.didSendBtn = @selector(didSendBtn:);
    _wh_player.isStartFullScreenPlay = YES; //全屏播放
    _wh_player.isPreview = YES; // 这是预览
    _wh_player.delegate = self;
    _wh_player = [_wh_player initWithParent:_wh_playerView];
    _wh_player.parent = _wh_playerView;
    _wh_player.videoFile = self.outputFileName;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_wh_player wh_switch];
    });
}

-(void)flashOn{
    _flashOn.hidden  = YES;
    _flashOff.hidden = YES;
    _flash.image = [UIImage imageNamed:@"flash_on"];
    _capture.curFlashMode = AVCaptureFlashModeOn;
}

-(void)flashOff{
    _flashOn.hidden  = YES;
    _flashOff.hidden = YES;
    _flash.image = [UIImage imageNamed:@"flash_off"];
    _capture.curFlashMode = AVCaptureFlashModeOff;
}

- (void)flash{
    if(_flashOn.hidden){
        if(_capture.isFrontFace)
            return;
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:1];

        _flashOn.hidden  = NO;
        _flashOff.hidden = NO;
        _flash.image = [UIImage imageNamed:@"automatic"];

        [UIView commitAnimations];
        return;
    }
    _flashOn.hidden  = YES;
    _flashOff.hidden = YES;
    _flash.image = [UIImage imageNamed:@"automatic"];
    _capture.curFlashMode = AVCaptureFlashModeAuto;
}

-(void)recordAutoEnd:(NSNotification*)notification{
    NSLog(@"sssss");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self onSave];
    });
}

-(void)noticeLabelHidden:(BOOL)hide textType:(int)type{
    _noticeLabel.hidden = hide;
    NSString * showStr = nil;
    switch (type) {
        case 1:
            showStr = [NSString stringWithFormat:@"%@%d%@",Localized(@"recordVideoVC_Show1"),_maxTime,Localized(@"recordVideoVC_Show2")];
            break;
        case 2:
            showStr = [NSString stringWithFormat:@"%@%ds",Localized(@"WaHu_recordVideo_WaHuViewController_LessThan"),_minTime];
            break;
        default:
            break;
    }
    _noticeLabel.text = showStr;
}

-(void)hiddenNoticeLabel{
    [self noticeLabelHidden:YES textType:1];
}
-(void)doQuit{
//    [_capture release];
    _capture = nil;
    [g_notify removeObserver:self name:kVideoRecordEndNotifaction object:nil];
//    [self.view removeFromSuperview];
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
//    [self release];
    _pSelf = nil;
}

-(void)onQuit{
    if(_capture.isRecording){
        [_capture stop];
        [_capture.captureSession startRunning];
        _recrod.selected = NO;
        _timeLabel.hidden = NO;
        _recordLabel.hidden = NO;
        _timeBGView.hidden = YES;
        _timeLabel.text = @"00:00";
        _timeLabel.hidden = YES;
    }else{
        [_capture.captureSession stopRunning];
        [self doQuit];
    }
}




@end
