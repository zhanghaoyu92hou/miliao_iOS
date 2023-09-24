//
//  JXRecordVideoVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/12/3.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXRecordVideo_WHVC.h"
#import "GPUImage.h"
#import "WH_GPUImageBeautifyFilter.h"
#import "WH_JXVideoPlayer.h"
#import "UIImage+WH_Color.h"
#import "WH_JXSelectMusic_WHVC.h"
#import "WH_EditAudioVideo.h"
#import "addMsgVC.h"
#import "WH_JXConvertMedia.h"
#import "WH_JXSelectMusicModel.h"
#import "UIButton+WH_Button.h"

#define kCameraVideoPath [FileInfo getUUIDFileName:@"mp4"]

@interface WH_JXRecordVideo_WHVC ()<JXSelectMusicVCDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera; // 錄像
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter; // 存錄像

@property (nonatomic, strong) UIButton *photoCaptureButton;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) WH_GPUImageBeautifyFilter *beautifyFilter;
@property (nonatomic, strong) NSArray *filterArray;
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;
@property (nonatomic, strong) NSMutableArray *photoStyleImages;

@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) UIImageView *timeBGView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger timerNum;
@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) WH_JXVideoPlayer *player;

@property (nonatomic, strong) UIButton *beautyBtn;
@property (nonatomic, strong) GPUImageBrightnessFilter *normalFilter;

@property (nonatomic,strong) NSString* outputFileName;//返回的video

@property (nonatomic, strong) UILabel *selectMusic;
@property (nonatomic, strong) WH_JXSelectMusicModel *selectMusicModel;
@property (nonatomic, strong) WH_AudioPlayerTool* audioPlayer;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) NSMutableArray* urlArray; // 录制多段视频url

@property (nonatomic, strong) NSTimer *exportTimer;
@property (nonatomic, strong) UIView *exportContent;
@property (nonatomic, strong) UILabel *exportPro;
@property (nonatomic, strong) AVAssetExportSession *exporter;   // 视频导出

//美颜/滤镜属性
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomControlView;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *skinCareBtn;

@property (nonatomic, assign) BOOL isCreateFilter;
//// isRecoverHis = YES作用是 当前滤镜调整到正常后，要记录美颜中的磨皮和亮度的历史值
//@property (nonatomic, assign) BOOL isRecoverHis;
@property (nonatomic, strong) UISlider *bilateralSld;
@property (nonatomic, strong) UISlider *brightnessSld;

@property (nonatomic, assign) CGFloat bilHis;
@property (nonatomic, assign) CGFloat briHis;

@property (nonatomic, strong) GPUImageBilateralFilter *bilateralFilter;//  磨皮滤镜
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;// 美白滤镜
@property (nonatomic, strong) GPUImageToonFilter *toonfilter;
@property (nonatomic, strong) GPUImageFilter *filter;//滤镜

@property (nonatomic, strong) UIImageView *lastSelImgView;

@end

@implementation WH_JXRecordVideo_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    _urlArray = [NSMutableArray array];
    
    _photoStyleImages = [NSMutableArray array];
    _isRecording = NO;
    
    if([self cameraCount]<=0){
        [self performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:nil afterDelay:0.5];
        //        [self dismissViewControllerAnimated:YES completion:nil];
        [g_App performSelector:@selector(showAlert:) withObject:Localized(@"JXAlert_NoCenmar") afterDelay:1];
        return;
    }
    
    // Yes, I know I'm a caveman for doing all this by hand
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    primaryView.backgroundColor = [UIColor blackColor];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchSkinCare)];
//    [primaryView addGestureRecognizer:tap];
    
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(primaryView.bounds), 63.f)];
    [primaryView addSubview:coverView];
    // gradient
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = coverView.bounds;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.74].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    [coverView.layer addSublayer:gl];
    
    // 添加上下两个地方的透明模板
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, THE_DEVICE_HAVE_HEAD ? 62 : 42)];
    UIView *botView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-90, JX_SCREEN_WIDTH, 90)];
//    topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//    botView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [primaryView addSubview:topView];
    [primaryView addSubview:botView];
    
    //中间录制按钮
    _photoCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _photoCaptureButton.frame = CGRectMake(round(JX_SCREEN_WIDTH / 2.0 - 73 / 2.0), JX_SCREEN_HEIGHT - 50 - 73, 73, 73);
    [_photoCaptureButton setBackgroundImage:[UIImage imageNamed: @"WH_StartRecord_WHIcon"] forState:UIControlStateNormal];
    [_photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_photoCaptureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [primaryView addSubview:_photoCaptureButton];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, THE_DEVICE_HAVE_HEAD ? 34+65 : 65, 30, 30)];
    [cancelBtn setImage:[UIImage imageNamed:@"WH_WhiteClose_WHIcon"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(WaHu_cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [primaryView addSubview:cancelBtn];
    
    _completeBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 53 - 40, JX_SCREEN_HEIGHT - 67 - 40, 40, 40)];
    _completeBtn.custom_acceptEventInterval = 1;
    [_completeBtn setImage:[UIImage imageNamed:@"WH_CompletionRecordVideo_WHIcon"] forState:UIControlStateNormal];
    [_completeBtn addTarget:self action:@selector(completeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _completeBtn.hidden = YES;
    [primaryView addSubview:_completeBtn];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 0;
    shadow.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
    shadow.shadowOffset =CGSizeMake(0.5,1);
    
    UIButton *switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 10 - 28, CGRectGetMinY(cancelBtn.frame), 28, 25+2+19)];
    [switchBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"翻转" attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0], NSShadowAttributeName: shadow}] forState:UIControlStateNormal];
    [switchBtn setImage:[UIImage imageNamed:@"WH_SwitchCamera_WHIcon"] forState:UIControlStateNormal];
//    switchBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 13];
    [switchBtn addTarget:self action:@selector(switchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [primaryView addSubview:switchBtn];
    [switchBtn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextBottom imageTitleSpace:2];
    
    self.view = primaryView;
    
    //    GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    //    blurFilter.blurRadiusInPixels = 2.0;
    
    _beautifyFilter = [[WH_GPUImageBeautifyFilter alloc] init];
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES; // 镜像
    [_videoCamera rotateCamera];
    
    //        CGFloat y = ((JX_SCREEN_HEIGHT - JX_SCREEN_WIDTH) / 2) / JX_SCREEN_HEIGHT;
    //        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, y, 1.0,JX_SCREEN_WIDTH/(JX_SCREEN_HEIGHT - 160))];
    
    if (THE_DEVICE_HAVE_HEAD) {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1.0 - (480.0/640.0 - 0.13)) / 2, 0.0, 480.0/640.0 - 0.13,1.0)];
    }else {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1.0 - 480.0/640.0) / 2, 0.0, 480.0/640.0 ,1.0)];
    }
    
    //        [_videoCamera addTarget:_beautifyFilter];
    //        GPUImageView *filterView = (GPUImageView *)self.view;
    //        [_beautifyFilter addTarget:filterView];
    [self setFilterGroup];
    
    if ( _videoCamera.inputCamera.hasFlash) {
        
        [_videoCamera.inputCamera lockForConfiguration:nil];
        _videoCamera.inputCamera.flashMode = AVCaptureFlashModeAuto;
        [_videoCamera.inputCamera unlockForConfiguration];
        
//        UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, kDevice_Is_iPhoneX ? 32 : 12, 18, 18)];
//        [flashBtn setImage:[UIImage imageNamed:@"automatic"] forState:UIControlStateNormal];
//        [flashBtn addTarget:self action:@selector(flashBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//        [flashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [primaryView addSubview:flashBtn];
    }
    
    _beautyBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(switchBtn.frame), CGRectGetMaxY(switchBtn.frame)+30, 28, 28+2+19.f)];
    _beautyBtn.selected = NO;
    [_beautyBtn setAttributedTitle:[[NSMutableAttributedString alloc] initWithString:@"美颜"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0], NSShadowAttributeName: shadow}] forState:UIControlStateNormal];
//    _beautyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 13];
    [_beautyBtn setImage:[UIImage imageNamed:@"WH_CameraBeauty_WHIcon"] forState:UIControlStateNormal];
    [_beautyBtn addTarget:self action:@selector(beautyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_beautyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [primaryView addSubview:_beautyBtn];
    [_beautyBtn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextBottom imageTitleSpace:2];
    
    _filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(switchBtn.frame), CGRectGetMaxY(_beautyBtn.frame)+30, 28, 28+2+19.f)];
    _filterBtn.selected = NO;
    [_filterBtn setAttributedTitle:[[NSMutableAttributedString alloc] initWithString:@"滤镜"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0], NSShadowAttributeName: shadow}] forState:UIControlStateNormal];
    _filterBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 13];
    [_filterBtn setImage:[UIImage imageNamed:@"WH_CameraFilter_WHIcon"] forState:UIControlStateNormal];
    [_filterBtn addTarget:self action:@selector(filterBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [primaryView addSubview:_filterBtn];
    [_filterBtn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextBottom imageTitleSpace:2];
    
//    [self addPhotoStyle:primaryView];
   
    _iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    _iv.backgroundColor = [UIColor blackColor];
    _iv.contentMode = UIViewContentModeScaleAspectFill;
    _iv.userInteractionEnabled = YES;
    _iv.hidden = YES;
    [primaryView addSubview:_iv];
    UIButton *cancelImageBtn = [self WaHu_create_WaHuButtonWithFrame:CGRectMake(20, JX_SCREEN_HEIGHT-20-80, 80, 80)  image:@"video_return" action:@selector(cancelImageBtnAction:)];
    [_iv addSubview:cancelImageBtn];
    UIButton *confirmBtn = [self WaHu_create_WaHuButtonWithFrame:CGRectMake(JX_SCREEN_WIDTH-20-80, JX_SCREEN_HEIGHT-20-80, 80, 80) image:@"video_gou" action:@selector(WaHu_confirmBtnAction:)];
    [_iv addSubview:confirmBtn];
    
    [self isVideoCustomView];
    [g_notify addObserver:self selector:@selector(didEnterBackground:) name:kApplicationDidEnterBackground object:nil];
}

- (void)setFilterGroup {
    /// 滤镜分组
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    
//    [self videoSetFilter];

    //  磨皮滤镜
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    [_filterGroup addFilter:bilateralFilter];
    _bilateralFilter = bilateralFilter;
    //  美白滤镜
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [_filterGroup addFilter:brightnessFilter];
    [_bilateralFilter setDistanceNormalizationFactor:MAXFLOAT];
    _brightnessFilter = brightnessFilter;
    //  设置滤镜组链
    [bilateralFilter addTarget:brightnessFilter];
    [_filterGroup setInitialFilters:@[bilateralFilter]];
    _filterGroup.terminalFilter = brightnessFilter;
    
    //    _beautifyFilter = [[WaHu_GPUImageBeautifyFilter alloc] init];
    //    [_filterGroup addFilter:_beautifyFilter];
    // 添加滤镜
    GPUImageFilter*filter = [[GPUImageFilter alloc] init];
    [_filterGroup addTarget:filter];
    [filter addTarget:_cropFilter];
    _filter = filter;
    
    [_videoCamera addTarget:_filterGroup];
    [_filterGroup addTarget:(GPUImageView *)self.view];
    
    [_videoCamera startCameraCapture];
}


- (void)actionQuit {
    [g_notify removeObserver:self];
    [super actionQuit];
}

- (void)didEnterBackground:(NSNotification *)notif {
    if (_isRecording) {
        [self takePhoto:_photoCaptureButton];
    }
}

- (void)didAudioPlayBegin {
    
}

- (void)didAudioPlayEnd {
    
}

// X
- (void)WaHu_cancelBtnAction:(UIButton *)btn {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [_audioPlayer wh_stop];
    _audioPlayer = nil;
    _isRecording = NO;
    [_recordTimer invalidate];
    
    _recordTimer = nil;
//    [g_navigation WaHu_dismiss_WaHuViewController:self animated:YES];
    [self actionQuit];
}
// 转换摄像头
- (void)switchBtnAction:(UIButton *)btn {
    [_videoCamera rotateCamera];
}
// 重新拍照
- (void) cancelImageBtnAction:(UIButton *)btn {
    _iv.hidden = YES;
    _iv.image = nil;
}

// 确定此照片
- (void) WaHu_confirmBtnAction:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:^{
        
//        if ([self.cameraDelegate respondsToSelector:@selector(cameraVC:didFinishWithImage:)]) {
//            [self.cameraDelegate cameraVC:self didFinishWithImage:_iv.image];
//        }
    }];
}

// 美颜按鈕
- (void) beautyBtnAction:(UIButton *)btn {
    
    if (!_baseView) {
        [self showBaseView];
    }
    [self.view bringSubviewToFront:_filterBtn];
    [self setupBeautyView:NO];

//    [self switchSkinCare];
    return;
    
//    if (_isRecording) {
//        [JXMyTools showTipView:Localized(@"JX_CannotSwitchDuringRecording")];
//        return;
//    }
//
//    btn.selected = !btn.selected;
//
//    if (btn.selected) {
//        [btn setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateNormal];
//        [_videoCamera removeAllTargets];
//        [_beautifyFilter removeAllTargets];
//        [_filterGroup removeAllTargets];
//        [_cropFilter removeAllTargets];
//        [_videoCamera addTarget:_cropFilter];
//        [_cropFilter addTarget:(GPUImageView *)self.view];
//
//    }else {
//        [btn setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
//
//        [_beautifyFilter removeAllTargets];
//
//        [_videoCamera removeAllTargets];
//        [_cropFilter removeAllTargets];
//        [_filterGroup removeAllTargets];
//        [self videoSetFilter];
//
//    }
}

- (void)filterBtnAction:(UIButton *)filterBtn{
    if (!_baseView) {
        [self showBaseView];
    }
    [self.view bringSubviewToFront:_beautyBtn];
    [self setupBeautyView:YES];
}

#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

// 设置录制视频filter
- (void)videoSetFilter{
    [_cropFilter addTarget:_beautifyFilter];
    
    [_filterGroup addTarget:_cropFilter];
    
    [_filterGroup addTarget:_beautifyFilter];
    
    [_filterGroup setInitialFilters:[NSArray arrayWithObject:_cropFilter]];
    
    [_filterGroup setTerminalFilter:_beautifyFilter];
    
    [_filterGroup forceProcessingAtSize:self.view.frame.size];
    
    [_filterGroup useNextFrameForImageCapture];
    
    [_videoCamera addTarget:_filterGroup];
    
    [_filterGroup addTarget:(GPUImageView *)self.view];
}
// 添加美颜风格
- (void) addPhotoStyle:(UIView *)parentView{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, JX_SCREEN_WIDTH, 77)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [parentView addSubview:_scrollView];
    
    //    NSArray *nameArray = @[Localized(@"JX_Standard"),Localized(@"JX_Pale"),Localized(@"JX_Dark"),Localized(@"JX_Morning"),Localized(@"JX_Dusk"),Localized(@"JX_Natural"),Localized(@"JX_Highlight")];
    //
    //    _filterArray = @[
    //                     @{@"x":@1.1, @"y":@1.1},
    //                     @{@"x":@1.1, @"y":@0.5},
    //                     @{@"x":@0.9, @"y":@1.1},
    //                     @{@"x":@1.1, @"y":@1.3},
    //                     @{@"x":@1.1, @"y":@1.5},
    //                     @{@"x":@1.3, @"y":@1.1},
    //                     @{@"x":@1.5, @"y":@1.1},
    //                       ];
    //美颜
    WH_GPUImageBeautifyFilter *BeautifyFilter = [[WH_GPUImageBeautifyFilter alloc] init];
    //哈哈镜效果
    GPUImageStretchDistortionFilter *stretchDistortionFilter = [[GPUImageStretchDistortionFilter alloc] init];
    //黑白
    GPUImageGrayscaleFilter *GrayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    //高斯模糊
    GPUImageGaussianBlurFilter  *GaussianBlurFilter = [[GPUImageGaussianBlurFilter  alloc] init];
    //边缘检测
    GPUImageXYDerivativeFilter *XYDerivativeFilter = [[GPUImageXYDerivativeFilter alloc] init];
    //怀旧
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    //反色
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
    //饱和度
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    // 亮度阈值
    GPUImageLuminanceThresholdFilter *LuminanceThresholdFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
    //去雾
    GPUImageHazeFilter *HazeFilter = [[GPUImageHazeFilter alloc] init];
    //初始化滤镜数组
    self.filterArray = @[BeautifyFilter,stretchDistortionFilter,GrayscaleFilter,GaussianBlurFilter,XYDerivativeFilter,sepiaFilter,invertFilter,saturationFilter,LuminanceThresholdFilter,HazeFilter];
    
    NSArray *nameArray = @[Localized(@"JX_CameraDefault"),Localized(@"JX_CameraSkinCare"),Localized(@"JX_CameraDistortingMirror"),Localized(@"JX_CameraBlackAndWhite"),Localized(@"JX_CameraGaussianBlur"),Localized(@"JX_CameraEdgeDetection"),Localized(@"JX_CameraNostalgia"),Localized(@"JX_CameraContrary"),Localized(@"JX_CameraSaturation"),Localized(@"JX_CameraThreshold"),Localized(@"JX_CameraFog")];
    UIImageView *lastImageView;
    for (NSInteger i = 0; i < nameArray.count; i ++) {
        //        NSDictionary *dict = _filterArray[i];
        UIImage *inputImage = [UIImage imageNamed:@"zhang"];
        
        //        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
        
        //        GPUImageHSBFilter *hsbFilter = [[GPUImageHSBFilter alloc] init];
        //        [hsbFilter adjustBrightness:[dict[@"x"] floatValue]];
        //        [hsbFilter adjustSaturation:[dict[@"y"] floatValue]];
        
        //        [stillImageSource addTarget:hsbFilter];
        //        [hsbFilter useNextFrameForImageCapture];
        //        [stillImageSource processImage];
        
        //        UIImage *image = [hsbFilter imageFromCurrentFramebuffer];
        
        if (i > 0) {
            [self.filterArray[i-1] useNextFrameForImageCapture];
            //获取数据源
            GPUImagePicture *stillImageSource=[[GPUImagePicture alloc]initWithImage:inputImage];
            [stillImageSource addTarget:self.filterArray[i-1]];
            //开始渲染
            [stillImageSource processImage];
            inputImage = [self.filterArray[i-1] imageFromCurrentFramebuffer];
        }

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lastImageView.frame) + 15, 0, 53, 53)];
        imageView.layer.cornerRadius = CGRectGetHeight(imageView.frame) / 2.f;
        imageView.layer.masksToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhotoStyle:)];
        [imageView addGestureRecognizer:tap];
        
        imageView.image = inputImage;
        [_scrollView addSubview:imageView];
        lastImageView = imageView;
        
//        if (i == 0) {
//            imageView.layer.borderWidth = 2.0;
//            imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
//        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height - 15, imageView.frame.size.width, 15)];
//        label.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        label.text = nameArray[i];
        label.font = sysFontWithSize(13);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [_scrollView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(5);
            make.centerX.equalTo(imageView);
            make.height.offset(19);
        }];
        
        UIImageView *checkImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_CheckEffect_WHIcon"]];
        checkImgView.hidden = i != 0;
        [imageView addSubview:checkImgView];
        [checkImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(imageView);
            make.size.mas_equalTo(CGSizeMake(25, 17));
        }];
        checkImgView.tag = 100;
        if (i == 0) {
            _lastSelImgView = checkImgView;
        }
        
        [_photoStyleImages addObject:imageView];
    }
    _scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastImageView.frame) + 10, 0);
}

- (UIButton *)WaHu_create_WaHuButtonWithFrame:(CGRect)frame image:(NSString *)image action:(SEL)action {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.frame.size.width/2;
    [button setImage:[UIImage scaleToSize:[UIImage imageNamed:image] size:CGSizeMake(32, 32)] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}
// 選擇美颜风格
- (void) selectPhotoStyle:(UIGestureRecognizer *)tap{
    
    if (_isRecording) {
        [JXMyTools showTipView:Localized(@"JX_CannotSwitchDuringRecording")];
        return;
    }
    
    if (_beautyBtn.selected) {
        [JXMyTools showTipView:Localized(@"JX_PleaseOpenBeauty")];
        return;
    }
    
    UIView *view = tap.view;
    self.isCreateFilter = YES;
    
    if (_lastSelImgView) {
        _lastSelImgView.hidden = YES;
    }
    UIImageView *checkImgView = [view viewWithTag:100];
    checkImgView.hidden = NO;
    _lastSelImgView = checkImgView;
    
    if (view == _photoStyleImages[1]) {
        [self recoverFilterGroup];
        [_bilateralSld setValue:self.bilHis > 0 ? self.bilHis : 4.2];
        [_brightnessSld setValue:self.briHis> 0 ? self.briHis : 0.07];
        [_bilateralFilter setDistanceNormalizationFactor:[self getBilValue:self.bilHis > 0 ? self.bilHis : 4.2]];
        _brightnessFilter.brightness = self.briHis> 0 ? self.briHis : 0.07;
        return;
    }else {
        [_bilateralSld setValue:0];
        [_brightnessSld setValue:0];
    }
    
//    for (UIImageView *imageView in _photoStyleImages) {
//        if (view == imageView) {
//            imageView.layer.borderWidth = 2.0;
//            imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
//        }else {
//            imageView.layer.borderWidth = 0.0;
//        }
//    }
    
    [self.videoCamera removeAllTargets];
    if (view.tag >= 1) {
        GPUImageFilter *filter = self.filterArray[view.tag-1];
        [self.videoCamera addTarget:filter];
        [filter addTarget:(GPUImageView *)self.view];
        [filter addTarget:_cropFilter];
        self.filter = filter;
    }else {
        [self setFilterGroup];
    }

    
//    [_beautifyFilter removeAllTargets];
//
//    _beautifyFilter = [WaHu_GPUImageBeautifyFilter alloc];
//
//    _beautifyFilter.dict = _filterArray[view.tag];
//
//    _beautifyFilter = [_beautifyFilter init];
//
//    [_videoCamera removeAllTargets];
//    [_cropFilter removeAllTargets];
//    [_filterGroup removeAllTargets];
//    [self videoSetFilter];

    
}


// 录制视频专有UI
- (void) isVideoCustomView{
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, JX_SCREEN_WIDTH-45*2, 45)];
    _noticeLabel.center = self.view.center;
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.font = sysFontWithSize(15);
    _noticeLabel.numberOfLines = 2;
    _noticeLabel.backgroundColor = [UIColor clearColor];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_noticeLabel];
    //    [_noticeLabel release];
    //    [self noticeLabelHidden:NO textType:1];
    
    //时间
    _timerNum = 0;
    _timeBGView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-210)/2,  THE_DEVICE_HAVE_HEAD ? JX_SCREEN_TOP/2+5 : JX_SCREEN_TOP/2-15, 210, 2)];
    //    _timeBGView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-210)/2, (JX_SCREEN_HEIGHT-JX_SCREEN_WIDTH)/2-35, 210, 2)];
    _timeBGView.image = [UIImage imageNamed:@"time_axis"];
//    [self.view addSubview:_timeBGView];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, THE_DEVICE_HAVE_HEAD ? 34+39 : 39, JX_SCREEN_WIDTH - 20, 50)];
//    _progressView.backgroundColor = [UIColor redColor];
    _progressView.progressTintColor = HEXCOLOR(0xFACE15);
    _progressView.trackTintColor = [UIColor colorWithWhite:0 alpha:0.5];
    _progressView.progress = 0.0;
    _progressView.transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    _progressView.layer.cornerRadius = 3.f;
    _progressView.layer.masksToBounds = YES;
    [self.view addSubview:_progressView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
    _timeLabel.center = _timeBGView.center;
    _timeLabel.text = @"00:00";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.shadowColor  = [UIColor blackColor];
    _timeLabel.shadowOffset = CGSizeMake(1, 1);
    _timeLabel.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_timeLabel];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, THE_DEVICE_HAVE_HEAD ? 34 + 66 : 66, 100, 30)];
    btn.center = CGPointMake(self.view.center.x, btn.center.y);
    [btn addTarget:self action:@selector(selectMusicBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn setTitle:Localized(@"JX_ChooseMusic") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = sysFontWithSize(13);
    [btn setImage:[UIImage imageNamed:@"WH_Music_WHIcon"] forState:UIControlStateNormal];
    [btn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextRight imageTitleSpace:2];
    
//    _selectMusic = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//    _selectMusic.font = sysFontWithSize(13);
//    _selectMusic.textColor = [UIColor whiteColor];
//    _selectMusic.text = Localized(@"JX_ChooseMusic");
//    _selectMusic.textAlignment = NSTextAlignmentCenter;
//    [btn addSubview:_selectMusic];
    
    
    _exportContent = [[UIView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH - 100) / 2, (JX_SCREEN_HEIGHT - 100) /2, 100, 100)];
    _exportContent.backgroundColor = [UIColor clearColor];
    _exportContent.hidden = YES;
    [self.view addSubview:_exportContent];
    
    _exportPro = [[UILabel alloc] initWithFrame:CGRectMake((_exportContent.frame.size.width - 50) / 2, (_exportContent.frame.size.height - 50) /2 - 10, 50, 50)];
    _exportPro.layer.borderWidth = 2.0;
    _exportPro.layer.borderColor = [UIColor whiteColor].CGColor;
    _exportPro.layer.cornerRadius = 50 / 2;
    _exportPro.layer.masksToBounds = YES;
    _exportPro.text = @"100%";
    _exportPro.font = [UIFont systemFontOfSize:15.0];
    _exportPro.textAlignment = NSTextAlignmentCenter;
    _exportPro.textColor = [UIColor whiteColor];
    [_exportContent addSubview:_exportPro];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_exportPro.frame) + 5, _exportContent.frame.size.width, 20)];
    tipLabel.text = Localized(@"JX_InTheCompression...");
    tipLabel.font = [UIFont systemFontOfSize:15.0];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    [_exportContent addSubview:tipLabel];
    
}

- (void)selectMusicBtnAction:(UIButton *)btn {
    if (_isRecording) {
        [self takePhoto:_photoCaptureButton];
    }
    WH_JXSelectMusic_WHVC *vc = [[WH_JXSelectMusic_WHVC alloc]init];
    vc.delegate = self;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectMusicVC:(WH_JXSelectMusic_WHVC *)vc selectMusic:(WH_JXSelectMusicModel *)model{
    
    _progressView.progress = 0.0;
    [_urlArray removeAllObjects];
    _timerNum = 0;
    _completeBtn.hidden = YES;
    self.selectMusic.text = model.name;
    self.selectMusicModel = model;
    
    _audioPlayer = [[WH_AudioPlayerTool alloc]initWithParent:self.view frame:CGRectNull isLeft:YES];
    _audioPlayer.wh_isOpenProximityMonitoring = NO;
    _audioPlayer.delegate = self;
    _audioPlayer.didAudioPlayEnd = @selector(didAudioPlayEnd);
    _audioPlayer.didAudioPlayBegin = @selector(didAudioPlayBegin);
    _audioPlayer.didAudioOpen = @selector(didAudioOpen);
    _audioPlayer.wh_audioFile = [[NSString stringWithFormat:@"%@%@",g_config.downloadUrl,model.path] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// 随时切换模式
- (void)switchSkinCare {
    self.scrollView.hidden = !self.scrollView.hidden;
    
}

- (void)completeBtnAction:(UIButton *)btn {
    
    _photoCaptureButton.enabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _photoCaptureButton.enabled = YES;
    });
    
    [_photoCaptureButton setBackgroundImage:[UIImage imageNamed: @"WH_StartRecord_WHIcon"] forState:UIControlStateNormal];
    [_recordTimer invalidate];
    _recordTimer = nil;
    [self endRecording];
    if (_isRecording) {
        
        [_urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",self.outputFileName]]];
    }
    _isRecording = NO;
    _timerNum = 0;
    _timeLabel.text = @"00:00";
    
    self.outputFileName = kCameraVideoPath;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self mergeAndExportVideos:_urlArray withOutPath:self.outputFileName];
        [_urlArray removeAllObjects];
        _completeBtn.hidden = YES;
        
    });
    
}

// 開始拍照、錄像
- (void)takePhoto:(UIButton *)btn;
{

    if (!_isRecording) {
        _outputFileName = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/Movie%lu.mov",(unsigned long)_urlArray.count]];
        [self.scrollView setHidden:YES];
        [_photoCaptureButton setBackgroundImage:[UIImage imageNamed:@"stop_video"] forState:UIControlStateNormal];
        _isRecording = YES;
        [self startPhoto];
        if (_audioPlayer.wh_audioFile.length > 0) {
            [_audioPlayer wh_switch];
        }
        
        _progressView.progress = 0.0;
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(recordTimerAction:) userInfo:nil repeats:YES];
        
        //            [self noticnoticeLabelHiddeneLabelHidden:YES textType:1];
    }else {
        [_recordTimer invalidate];
        if (_audioPlayer.wh_audioFile.length > 0) {
            [_audioPlayer wh_pause];
        }
        [_photoCaptureButton setBackgroundImage:[UIImage imageNamed: @"WH_StartRecord_WHIcon"] forState:UIControlStateNormal];
        _isRecording = NO;
        [self endRecording];
        [_urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",self.outputFileName]]];
        
        //            [self.scrollView setHidden:NO];
        
//        if (_timerNum <= 0) {
//            return;
//        }
        
        
        //            [self dismissViewControllerAnimated:YES completion:^{
        //
        //                if ([self.cameraDelegate respondsToSelector:@selector(cameraVC:didFinishWithVideoPath:timeLen:)]) {
        //                    [self.cameraDelegate cameraVC:self didFinishWithVideoPath:self.outputFileName timeLen:self.timerNum];
        //                }
        //
        //                _timerNum = 0;
        //            }];
        
    }
}

- (void) showPreview:(NSString *)path{
    _exportContent.hidden = YES;
    _progressView.progress = 0.0;
    [_audioPlayer wh_stop];
    _playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_playerView];
    _player= [WH_JXVideoPlayer alloc];
    _player.type = JXVideoTypePreview;
    _player.isShowHide = YES; //播放中点击播放器便销毁播放器
    _player.didSendBtn = @selector(didSendBtn:);
    _player.didExitBtn = @selector(didExitBtn:);
    _player.isStartFullScreenPlay = YES; //全屏播放
    _player.isPreview = YES; // 这是预览
    _player.delegate = self;
    _player = [_player initWithParent:_playerView];
    _player.parent = _playerView;
    _player.videoFile = path;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player wh_switch];
    });
}

- (void)synthesizeClick:(NSString *)videoPath AudioPath:(NSString *)audioPath {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [WH_EditAudioVideo editVideoSynthesizeVieoPath:[NSURL fileURLWithPath:videoPath] BGMPath:[NSURL fileURLWithPath:audioPath] needOriginalVoice:NO videoVolume:0 BGMVolume:1 complition:^(NSURL *outputPath, BOOL isSucceed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.outputFileName = [outputPath absoluteString];
                [self showPreview:[outputPath absoluteString]];
            });
            
            NSLog(@"%@",outputPath);
        }];
    });
    
}

- (void)didSendBtn:(UIButton *)btn {
    
    addMsgVC* vc = [[addMsgVC alloc] init];
    vc.wh_videoFile = self.outputFileName;
    vc.wh_isShortVideo = YES;
    vc.dataType = weibo_dataType_video;
    vc.delegate = self;
//    vc.didSelect = @selector(hideKeyShowAlert);
    //        [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
    
    [_playerView removeFromSuperview];
    _playerView = nil;
    _player = nil;
}

- (void)didExitBtn:(id)sender {
    _playerView = nil;
    _player = nil;
}


- (NSString *)getDataFilePath {
    NSString* s = [NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()];
    //NSLog(@"%@",s);
    return s;
}

// 开始录制视频
- (void)startPhoto {
    
    ///录制的视频会存储到该路径下 唯一
    
    NSString *pathToMovie = _outputFileName;
//    _outputFileName = pathToMovie;
    
    //    [videoArray addObject:pathToMovie];
    
    NSLog(@"%@",pathToMovie);
    
    unlink([pathToMovie UTF8String]);
    
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    //    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 720) fileType:AVFileTypeQuickTimeMovie outputSettings:nil];
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(((int)JX_SCREEN_WIDTH/16)*16, ((int)JX_SCREEN_HEIGHT/16)*16) fileType:AVFileTypeQuickTimeMovie outputSettings:nil];
    
    AudioChannelLayout channelLayout;
    
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,//制定编码算法
                                   [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,//声道
                                   [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,//采样率
                                   [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                                   [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,//编码率
                                   
                                   nil];
    
    [_movieWriter setHasAudioTrack:YES audioSettings:audioSettings];
    _movieWriter.hasAudioTrack = YES;
    
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    //    [_filterGroup addTarget:_movieWriter];
    
    [_videoCamera addAudioInputsAndOutputs];
    
    _videoCamera.audioEncodingTarget = _movieWriter;
    
//    if (_filterGroup.targets.count <= 0) {
//        [_cropFilter addTarget:_movieWriter];
//    }
//    else {
//        [_filterGroup addTarget:_movieWriter];
//    }
    [_cropFilter addTarget:_movieWriter];
    [_movieWriter startRecording];
    
}

// 录制视频计时
- (void)recordTimerAction:(NSTimer *)timer {
    _timerNum ++;
    NSInteger m = _timerNum/60;
    NSInteger n = _timerNum%60;
    NSString * labelTimeStr;
    labelTimeStr = [NSString stringWithFormat:@"%.2ld:%.2ld",m,n];
    _timeLabel.text = labelTimeStr;
    _completeBtn.hidden = NO;
    
    CGFloat f = 15;
    _progressView.progress = _timerNum / 100.0 / f;
    if (_timerNum / 100.0 / f >= 1.0) {
        [_recordTimer invalidate];
        _recordTimer = nil;
        _timerNum = 0;
//        [self takePhoto:_photoCaptureButton];
        [self completeBtnAction:_completeBtn];
    }
}

///完成录制
- (void)endRecording {
    
    [_movieWriter finishRecording];
    
    [_cropFilter removeTarget:_movieWriter];
    
    [_beautifyFilter removeTarget:_movieWriter];
    
    [_filterGroup removeTarget:_movieWriter];
    
    _videoCamera.audioEncodingTarget = nil;
    
    //    [self savePhotoCmare:videoArray.lastObject];
    
}

- (void)mergeAndExportVideos:(NSArray*)videosPathArray withOutPath:(NSString*)outpath{
    if (videosPathArray.count == 0) {
        return;
    }
    //音频视频合成体
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //创建音频通道容器
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    //创建视频通道容器
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    UIImage* waterImg = [UIImage imageNamed:@"LDWatermark"];
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < videosPathArray.count; i++) {
        //        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videosPathArray[i]]];
        NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVAsset* asset = [AVURLAsset URLAssetWithURL:videosPathArray[i] options:options];
        
        NSError *erroraudio = nil;
        //获取AVAsset中的音频 或者视频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //向通道内加入音频或者视频
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        
        NSLog(@"erroraudio:%@%d",erroraudio,ba);
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    NSLog(@"%@",NSHomeDirectory());
    
    //创建视频水印layer 并添加到视频layer上
    //2017 年 04 月 19 日 视频水印由后台统一转码添加   del by hyy；
    CGSize videoSize = [videoTrack naturalSize];
//    CALayer* aLayer = [CALayer layer];
//    aLayer.contents = (id)waterImg.CGImage;
//    aLayer.frame = CGRectMake(videoSize.width - waterImg.size.width - 30, videoSize.height - waterImg.size.height*3, waterImg.size.width, waterImg.size.height);
//    aLayer.opacity = 0.9;

    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
//    [parentLayer addSublayer:aLayer];
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;


    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];

    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    
    
    _exportTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(exportTimerAction:) userInfo:nil repeats:YES];
    _exportContent.hidden = NO;
    _exportPro.text = @"0%";
    
    //视频导出工具
    _exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPreset1280x720];
    _exporter.videoComposition = videoComp;
    /*
     exporter.progress
     导出进度
     This property is not key-value observable.
     不支持kvo 监听
     只能用定时器监听了  NStimer
     */
    _exporter.outputURL = mergeFileURL;
    _exporter.outputFileType = AVFileTypeQuickTimeMovie;
    _exporter.shouldOptimizeForNetworkUse = YES;
    [_exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (_audioPlayer.wh_audioFile.length > 0) {
                [self synthesizeClick:self.outputFileName AudioPath:_audioPlayer.wh_audioFile];
            }else {
                [self showPreview:self.outputFileName];
            }
        });
        
        
    }];
    
}

- (void)exportTimerAction:(NSTimer *)timer {
    NSLog(@"exporter.progress = %f",_exporter.progress);
    
    NSString *str = [NSString stringWithFormat:@"%d%%",(int)(_exporter.progress * 100)];
    _exportPro.text = str;
    
    if (_exporter.progress >= 1) {
        [_exportTimer invalidate];
        _exportTimer = nil;
    }
}

- (void)showBaseView {
    self.baseView  = [[UIView alloc] initWithFrame:self.view.bounds];
    self.baseView.backgroundColor = [UIColor clearColor];
    self.baseView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBaseView)];
    [self.baseView addGestureRecognizer:tap];
    
    [self.view addSubview:self.baseView];
    
    CGFloat bigViewCorner = 10;
    CGFloat bigViewH = 117 + (THE_DEVICE_HAVE_HEAD ? 34 : 0);
    self.bigView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-bigViewH, JX_SCREEN_WIDTH,   bigViewH+bigViewCorner)];
    self.bigView.backgroundColor = HEXCOLOR(0x171717);
    [self.baseView addSubview:self.bigView];
    self.bigView.layer.cornerRadius = bigViewCorner;
    self.bigView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBigView)];
    [self.bigView addGestureRecognizer:tap1];
    
    [self addPhotoStyle:self.bigView];
    [self initBottomView:self.bigView];
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame)+20, JX_SCREEN_WIDTH, .5)];
//    line.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
//    [self.bigView addSubview:line];
    
    
    //滤镜
//    self.filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame)+20, JX_SCREEN_WIDTH/2, JX_SCREEN_BOTTOM)];
//    [self.filterBtn setTitle:Localized(@"JX_CameraFilter") forState:UIControlStateNormal];
//    [self.filterBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [self.filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [self.filterBtn.titleLabel setFont:sysFontWithSize(15)];
//    [self.filterBtn addTarget:self action:@selector(didFilterBtn) forControlEvents:UIControlEventTouchUpInside];
//    [self.bigView addSubview:self.filterBtn];
    
//    UIView *lineF = [[UIView alloc] initWithFrame:CGRectMake(self.filterBtn.frame.size.width-.5, 12, 0.5, 49-12*2)];
//    lineF.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
//    [self.filterBtn addSubview:lineF];
    
    //美颜
//    self.skinCareBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2, self.filterBtn.frame.origin.y, JX_SCREEN_WIDTH/2, self.filterBtn.frame.size.height)];
//    [self.skinCareBtn setTitle:Localized(@"JX_CameraSkinCare") forState:UIControlStateNormal];
//    [self.skinCareBtn.titleLabel setFont:sysFontWithSize(15)];
//    [self.skinCareBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [self.skinCareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [self.skinCareBtn addTarget:self action:@selector(didBeautyBtn) forControlEvents:UIControlEventTouchUpInside];
//    [self.bigView addSubview:self.skinCareBtn];
    
}

- (void)setupBeautyView:(BOOL)isFilter {
    self.baseView.hidden = NO;
    _scrollView.hidden = !isFilter;
    _bottomControlView.hidden = isFilter;
    [self.filterBtn setSelected:isFilter];
    [self.skinCareBtn setSelected:!isFilter];
}


- (void)initBottomView:(UIView *)parentView
{
    _bottomControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, JX_SCREEN_WIDTH, 60)];
    [parentView addSubview:_bottomControlView];
    
    
    //磨皮
    UILabel *bilateralL = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 25)];
    bilateralL.text = Localized(@"JX_CameraExfoliating");
    bilateralL.font = [UIFont systemFontOfSize:14];
    bilateralL.textColor = [UIColor whiteColor];
    [_bottomControlView addSubview:bilateralL];
    
    UISlider *bilateralSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 0, JX_SCREEN_WIDTH-100, 30)
                               ];
    bilateralSld.maximumValue = 6;
    [bilateralSld addTarget:self action:@selector(bilateralFilter:) forControlEvents:UIControlEventValueChanged];
    [_bottomControlView addSubview:bilateralSld];
    _bilateralSld = bilateralSld;
    
    //美白
    UILabel *brightnessL = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 40, 25)];
    brightnessL.text = Localized(@"JX_CameraWhitening");
    brightnessL.font = [UIFont systemFontOfSize:14];
    brightnessL.textColor = [UIColor whiteColor];
    [_bottomControlView addSubview:brightnessL];
    
    UISlider *brightnessSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 40, JX_SCREEN_WIDTH-100, 30)
                                ];
    brightnessSld.minimumValue = 0;
    brightnessSld.maximumValue = 0.1;
    [brightnessSld addTarget:self action:@selector(brightnessFilter:) forControlEvents:UIControlEventValueChanged];
    [_bottomControlView addSubview:brightnessSld];
    _brightnessSld = brightnessSld;
}

//点击滤镜
- (void)didFilterBtn {
    [self setupBeautyView:YES];
}
//点击美颜
- (void)didBeautyBtn {
    [self setupBeautyView:NO];
}

#pragma mark - 调整磨皮
- (void)bilateralFilter:(UISlider *)slider {
    [self recoverFilterGroup];
    //值越小，磨皮效果越好
    [_bilateralFilter setDistanceNormalizationFactor:[self getBilValue:slider.value]];
    self.bilHis = slider.value;
    NSLog(@"------调整磨皮 = %f - %f - %f",[self getBilValue:slider.value],(ldexp(slider.value, 10)),slider.value);
}

#pragma mark - 调整亮度
- (void)brightnessFilter:(UISlider *)slider {
    [self recoverFilterGroup];
    _brightnessFilter.brightness = slider.value;
    self.briHis = slider.value;
    NSLog(@"------调整亮度 = %f",slider.value);
}

// 恢复调整状态下的磨皮和亮度
- (void)recoverFilterGroup {
    if (self.isCreateFilter) {
        [_videoCamera removeAllTargets];
        [self setFilterGroup];
        self.isCreateFilter = NO;
        UIView *view = _photoStyleImages[1];
//        for (UIImageView *imageView in _photoStyleImages) {
//            if (view == imageView) {
//                imageView.layer.borderWidth = 2.0;
//                imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
//            }else {
//                imageView.layer.borderWidth = 0.0;
//            }
//        }
        
        
    }
}


- (CGFloat)getBilValue:(CGFloat)value {
    CGFloat maxValue = 10;
    CGFloat va = maxValue - value;
    va = 60000 / (ldexp(value, 10));
    return va;
}

- (void)hideBaseView {
    self.baseView.hidden = YES;
}

- (void)clickBigView {}



- (void)sp_getLoginState {
    NSLog(@"Get User Succrss");
}
@end
