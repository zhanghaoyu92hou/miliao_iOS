//
//  WH_JXScanQR_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/9/15.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXScanQR_WHViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXRoomObject.h"
#import "WH_JXRoomPool.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_webpage_WHVC.h"
#import "WH_JXRoomRemind.h"
#import "WH_JXInput_WHVC.h"
#import "RITLPhotosViewController.h"
#import "WH_JXInputMoney_WHVC.h"
#import "WH_JXUserObject+GetCurrentUser.h"
#import "WH_ContentModification_WHView.h"
#import "UIView+WH_CustomAlertView.h"

#import "WH_PublicNumberLogin_WHVC.h"

#define TOP (JX_SCREEN_HEIGHT-300)/2
#define LEFT (JX_SCREEN_WIDTH-300)/2
#define kScanRect CGRectMake(LEFT, TOP, 300, 300)

@interface WH_JXScanQR_WHViewController ()<AVCaptureMetadataOutputObjectsDelegate,RITLPhotosViewControllerDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    CAShapeLayer *cropLayer;
    WH_JXRoomObject *_chatRoom;
    NSDictionary * _dataDict;
}
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//设置输出类型为Metadata，因为这种输出类型中可以设置扫描的类型，譬如二维码
//当启动摄像头开始捕获输入时，如果输入中包含二维码，就会产生输出
@property(nonatomic)AVCaptureMetadataOutput *output;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIImageView * line;

// 扫描到群组参数
@property (nonatomic, copy) NSString *roomJid;
@property (nonatomic, copy) NSString *roomUserId;
@property (nonatomic, copy) NSString *roomUserName;

@end

@implementation WH_JXScanQR_WHViewController

-(instancetype)init{
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        self.title = Localized(@"JXQR_Scan");
    }
    return self;
}
-(void)dealloc{
    [timer invalidate];
    timer = nil;
}
// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createHeadAndFoot];
    self.wh_tableBody.hidden = YES;
    [self configView];
    [self setCropRect:kScanRect];
    [self setupCamera];
    [self setupPhotoAlbum];
    [_session startRunning];
}

- (void)setupPhotoAlbum {
    UIButton *moreBtn = [UIFactory WH_create_WHButtonWithImage:@""
                                          highlight:nil
                                             target:self
                                           selector:@selector(onPhotoAlbum:)];
//    [moreBtn setTitle:Localized(@"ALBUM") forState:UIControlStateNormal];
//    [moreBtn.titleLabel setFont:sysFontWithSize(16)];
//    [moreBtn setTitleColor:HEXCOLOR(0x3A404C) forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"im_003_more_button_normal"] forState:UIControlStateNormal];
    moreBtn.custom_acceptEventInterval = 1.0f;
    moreBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 38, JX_SCREEN_TOP - 36, 28, 28);
    [self.wh_tableHeader addSubview:moreBtn];
}

- (void)onPhotoAlbum:(UIButton *)button {
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 1;//最大的选择数目
    photoController.configuration.containVideo = NO;//选择类型，目前只选择图片不选择视频
    photoController.configuration.containImage = YES;//选择类型，目前只选择图片不选择视频
    photoController.configuration.isRichScan = YES;//选择类型，目前只选择图片不选择视频
    photoController.photo_delegate = self;
    photoController.thumbnailSize = CGSizeMake(320, 320);//缩略图的尺寸
    //    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    
    [self presentViewController:photoController animated:true completion:^{}];

}

#pragma mark - 图库选择二维码后的回调
- (void)photosViewController:(UIViewController *)viewController thumbnailImages:(NSArray *)thumbnailImages infos:(NSArray<NSDictionary *> *)infos {
    
    UIImage *image = [thumbnailImages firstObject];
    if(image){
        
        //1. 初始化扫描仪，设置设别类型和识别质量
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
        
        //2. 扫描获取的特征组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        
        //3. 获取扫描结果
        if (features.count <= 0) {
            [g_App showAlert:Localized(@"JX_NoQrCode")];
            [self actionQuit];
            return;
        }
        
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        
        NSString *stringValue = feature.messageString;
        NSRange range = [stringValue rangeOfString:@"tigId"];
        if (range.location != NSNotFound) {
            
            NSString * idStr = [stringValue substringFromIndex:range.location + range.length + 1];
            self.idStr = idStr;
            
            if ([stringValue rangeOfString:@"=user"].location != NSNotFound) {
//                WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
//                vc.wh_userId       = idStr;
//                vc.wh_fromAddType = 1;
//                vc = [vc init];
//                [g_navigation pushViewController:vc animated:YES];
//                [self actionQuit];
                
                self.isAddFriend = YES;
//                [g_server getUser:MY_USER_ID toView:self];
                [self getCurrentUserInfo];
            }else if ([stringValue rangeOfString:@"=group"].location != NSNotFound) {
                [g_server getRoom:idStr toView:self];
            }else if ([stringValue rangeOfString:@"=open"].location != NSNotFound) {
                if ([idStr rangeOfString:@"http://"].location != NSNotFound && [idStr rangeOfString:@"https://"].location != NSNotFound) {
                    WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
                    webVC.url= idStr;
                    webVC.isSend = YES;
                    webVC = [webVC init];
                    [g_navigation.navigationView addSubview:webVC.view];
//                    [g_navigation pushViewController:webVC animated:YES];
                    [self actionQuit];
                }else{
                    [g_App showAlert:@"URL不标准,无法打开"];
                }
            }
            
        }else {
            NSRange idRange = [stringValue rangeOfString:@"userId"];
            NSRange nameRange = [stringValue rangeOfString:@"userName"];
            
            if ([stringValue hasPrefix:@"http://"] || [stringValue hasPrefix:@"https://"]) {
                WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
                webVC.url= stringValue;
                webVC.isSend = YES;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
                [self actionQuit];
                
            }else if (stringValue.length == 20 && [self isNumber:stringValue]){
                // 对面付款， 己方收款
                WH_JXInputMoney_WHVC *inputVC = [[WH_JXInputMoney_WHVC alloc] init];
                inputVC.type = JXInputMoneyTypeCollection;
                inputVC.wh_paymentCode = stringValue;
                [g_navigation pushViewController:inputVC animated:YES];
                [self actionQuit];
            }else if (idRange.location != NSNotFound && nameRange.location != NSNotFound) {
                // 己方付款， 对面收款
                NSDictionary *dict = [stringValue mj_JSONObject];
                WH_JXInputMoney_WHVC *inputVC = [[WH_JXInputMoney_WHVC alloc] init];
                inputVC.type = JXInputMoneyTypePayment;
                inputVC.wh_userId = [dict objectForKey:@"userId"];
                inputVC.wh_userName = [dict objectForKey:@"userName"];
                if ([dict objectForKey:@"money"]) {
                    inputVC.wh_money = [dict objectForKey:@"money"];
                }
                if ([dict objectForKey:@"description"]) {
                    inputVC.wh_desStr = [dict objectForKey:@"description"];
                }
                [g_navigation pushViewController:inputVC animated:YES];
                [self actionQuit];
            }else {
                NSLog(@"%@",Localized(@"JX_NoScanningInformation"));
                [GKMessageTool showMessage:Localized(@"JX_NoScanningInformation")];
                [self actionQuit];
                return;
            }
        }
    }else {
        
//        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:Localized(@"JX_ScanResults") message:Localized(@"JX_Haven'tQrCode") delegate:nil cancelButtonTitle:Localized(@"JX_Confirm") otherButtonTitles:nil, nil];
//
//        [alertView show];
        [GKMessageTool showText:Localized(@"JX_Haven'tQrCode")];
        [self actionQuit];
        return;
    }
}

- (void)getCurrentUserInfo {
    [[WH_JXUserObject sharedUserInstance] getCurrentUser];
    [WH_JXUserObject sharedUserInstance].complete = ^(HttpRequestStatus status, NSDictionary * _Nullable userInfo, NSError * _Nullable error) {
        switch (status) {
            case HttpRequestSuccess:
            {
                if (self.isAddFriend) {
                    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
                    vc.wh_userId       = self.idStr;
                    vc.isAddFriend = [WH_JXUserObject sharedUserInstance].isAddFirend;
                    vc.wh_fromAddType = 1;
                    vc = [vc init];
                    [g_navigation pushViewController:vc animated:YES];
                    [self actionQuit];
                }else{
                    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
                    vc.wh_user       = [WH_JXUserObject sharedUserInstance];
                    vc = [vc init];
                    //        [g_window addSubview:vc.view];
                    [g_navigation pushViewController:vc animated:YES];
                    
                    [self actionQuit];
                }
            }
                break;
            case HttpRequestFailed:
            {
                
            }
                break;
            case HttpRequestError:
            {
                
            }
                break;
                
            default:
                break;
        }
    };
}
-(void)configView{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:kScanRect];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+10, 300, 2)];
    _line.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 300, 2);
        if (2*num == 200) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 300, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
//    CGPathAddRect(path, nil, self.view.bounds);
    CGRect viewRect = self.view.bounds;
    viewRect.origin.y += JX_SCREEN_TOP;
    viewRect.size.height -= JX_SCREEN_TOP;
    CGPathAddRect(path, nil, viewRect);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    
    
    [cropLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:cropLayer];
}


- (void)setupCamera
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"JX_Tip") message:Localized(@"JX_DeviceNoCamera") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:Localized(@"JX_Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = TOP/JX_SCREEN_HEIGHT;
    CGFloat left = LEFT/JX_SCREEN_WIDTH;
    CGFloat width = 300/JX_SCREEN_WIDTH;
    CGFloat height = 300/JX_SCREEN_HEIGHT;
    ///top 与 left 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    _previewLayer =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
//    // Start
//    [_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        [timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        
        if ([stringValue containsString:@"pub&open&acc"]) {
            //进入扫描公众号登陆逻辑中
            WH_PublicNumberLogin_WHVC *publicNumberLoginVC = [[WH_PublicNumberLogin_WHVC alloc] init];
            publicNumberLoginVC.qrCodeStr = stringValue;
            publicNumberLoginVC.type = WH_PublicNumberLoginKaiFangPingTai;
            [g_navigation pushViewController:publicNumberLoginVC animated:YES];
            [self actionQuit];
            return;
        } else if (stringValue.length == 26 && [stringValue containsString:@"pub&acc"]) {
            //登录公众号二维码
            WH_PublicNumberLogin_WHVC *publicNumberLoginVC = [[WH_PublicNumberLogin_WHVC alloc] init];
            publicNumberLoginVC.qrCodeStr = stringValue;
            publicNumberLoginVC.type = WH_PublicNumberLoginGongZhongPingTai;
            [g_navigation pushViewController:publicNumberLoginVC animated:YES];
            [self actionQuit];
            return;
        }else if (stringValue.length == 30 && [stringValue containsString:@"user&login"]) {
            //扫码登录
//            [g_server requestScanLoginWithScanContent:stringValue toView:self];
            
            //登录PC端
            WH_PublicNumberLogin_WHVC *publicNumberLoginVC = [[WH_PublicNumberLogin_WHVC alloc] init];
            publicNumberLoginVC.qrCodeStr = stringValue;
            publicNumberLoginVC.type = WH_PublicNumberLoginPC;
            [g_navigation pushViewController:publicNumberLoginVC animated:YES];
            [self actionQuit];
            return;
        }
        
        NSRange range = [stringValue rangeOfString:@"tigId"];
        if (range.location != NSNotFound) {
            
            NSString * idStr = [stringValue substringFromIndex:range.location + range.length + 1];
            self.idStr = idStr;
            
            if ([stringValue rangeOfString:@"=user"].location != NSNotFound) {
//                [g_server getUser:idStr toView:self];
//                WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
//                vc.wh_userId       = idStr;
//                vc.wh_fromAddType = 1;
//                vc = [vc init];
//                [g_navigation pushViewController:vc animated:YES];
//
//                [self actionQuit];
                
                self.isAddFriend = YES;
                [g_server getUser:MY_USER_ID toView:self];
                
            }else if ([stringValue rangeOfString:@"=group"].location != NSNotFound) {//扫码进群
                [g_server getRoom:idStr toView:self];
            }else if ([stringValue rangeOfString:@"=open"].location != NSNotFound) {
                if ([idStr rangeOfString:@"http://"].location != NSNotFound && [idStr rangeOfString:@"https://"].location != NSNotFound) {
                    WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
                    webVC.url= idStr;
                    webVC.isSend = YES;
                    webVC = [webVC init];
                    [g_navigation.navigationView addSubview:webVC.view];
//                    [g_navigation pushViewController:webVC animated:YES];
                    [self actionQuit];
                }else{
                    [g_App showAlert:@"URL不标准,无法打开"];
                }
            }
            
        }else {
            NSRange idRange = [stringValue rangeOfString:@"userId"];
            NSRange nameRange = [stringValue rangeOfString:@"userName"];

            if ([stringValue hasPrefix:@"http://"] || [stringValue hasPrefix:@"https://"]) {
                WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
                webVC.url= stringValue;
                webVC.isSend = YES;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
                [self actionQuit];
                
            }else if (stringValue.length == 20 && [self isNumber:stringValue]){
                // 对面付款， 己方收款
                WH_JXInputMoney_WHVC *inputVC = [[WH_JXInputMoney_WHVC alloc] init];
                inputVC.type = JXInputMoneyTypeCollection;
                inputVC.wh_paymentCode = stringValue;
                [g_navigation pushViewController:inputVC animated:YES];
                [self actionQuit];
            }else if (idRange.location != NSNotFound && nameRange.location != NSNotFound) {
                // 己方付款， 对面收款
                NSDictionary *dict = [stringValue mj_JSONObject];
                WH_JXInputMoney_WHVC *inputVC = [[WH_JXInputMoney_WHVC alloc] init];
                inputVC.type = JXInputMoneyTypePayment;
                inputVC.wh_userId = [dict objectForKey:@"userId"];
                inputVC.wh_userName = [dict objectForKey:@"userName"];
                if ([dict objectForKey:@"money"]) {
                    inputVC.wh_money = [dict objectForKey:@"money"];
                }
                if ([dict objectForKey:@"description"]) {
                    inputVC.wh_desStr = [dict objectForKey:@"description"];
                }
                [g_navigation pushViewController:inputVC animated:YES];
                [self actionQuit];
            }else {
                NSLog(@"%@",Localized(@"JX_NoScanningInformation"));
                [GKMessageTool showMessage:Localized(@"JX_NoScanningInformation")];
                [self actionQuit];
                return;
            }
        }
        
    } else {
        NSLog(@"%@",Localized(@"JX_NoScanningInformation"));
        [GKMessageTool showText:Localized(@"JX_NoScanningInformation")];
        [self actionQuit];
        return;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:wh_act_roomMemberSet]) {
        
        [self showChatView];
        [self actionQuit];
    }
    
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        if (self.isAddFriend) {
            WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
            vc.wh_userId       = self.idStr;
            vc.isAddFriend = user.isAddFirend;
            vc.wh_fromAddType = 1;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
            [self actionQuit];
        }else{
            WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
            vc.wh_user       = user;
            vc = [vc init];
            //        [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
            
            [self actionQuit];
        }
        
    }else if( [aDownload.action isEqualToString:wh_act_roomGet] ){
        
        _dataDict = dict;
        
        if(g_xmpp.isLogined != 1){
            // 掉线后点击title重连
            // 判断XMPP是否在线  不在线重连
            [g_xmpp showXmppOfflineAlert];
            return;
        }
        NSDictionary * dict = _dataDict;
        
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:[dict objectForKey:@"jid"]];
        if(user && [user.groupStatus intValue] == 0){
            //老房间:
            _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
            //老房间:
            [self showChatView];
            [self actionQuit];
        }else{
            [self actionQuit];

            BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
            long userId = [dict[@"userId"] longLongValue];
            if (isNeedVerify && userId != [g_myself.userId longLongValue]) {
                
                self.roomJid = [dict objectForKey:@"jid"];
                self.roomUserName = [dict objectForKey:@"nickname"];
                self.roomUserId = [dict objectForKey:@"userId"];
                
#pragma mark 进群验证
//                WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:@"扫码进群验证" content:Localized(@"JX_GroupOwnersHaveEnabled") isEdit:NO isLimit:NO];
//                [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
                
                WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 289) title:@"扫码进群验证" promptContent:Localized(@"JX_GroupOwnersHaveEnabled") content:@"" isEdit:YES isLimit:NO];
//                [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
                [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO cancelGestur:YES];
                
                __weak typeof(cmView) weakShare = cmView;
                __weak typeof(self) weakSelf = self;
                [cmView setCloseBlock:^{
                    [weakShare hideView];
                }];
                [cmView setSelectActionBlock:^(NSInteger buttonTag, NSString * _Nonnull content) {
                    if (buttonTag == 0) {
                        [weakShare hideView];
                    }else{
                        [weakShare hideView];
                        
                        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
                        msg.fromUserId = MY_USER_ID;
                        msg.toUserId = [NSString stringWithFormat:@"%@", self.roomUserId];
                        msg.fromUserName = MY_USER_NAME;
                        msg.toUserName = self.roomUserName;
                        msg.timeSend = [NSDate date];
                        msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
                        NSString *userIds = g_myself.userId;
                        NSString *userNames = g_myself.userNickname;
                        NSDictionary *dict = @{
                                               @"userIds" : userIds,
                                               @"userNames" : userNames,
                                               @"roomJid" : weakSelf.roomJid,
                                               @"reason" : content,
                                               @"isInvite" : [NSNumber numberWithBool:YES]
                                               };
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
                        
                        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        msg.objectId = jsonStr;
                        [g_xmpp sendMessage:msg roomName:nil];
                        
                        msg.fromUserId = weakSelf.roomJid;
                        msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                        msg.content = Localized(@"JX_WaitGroupConfirm");
                        [msg insert:weakSelf.roomJid];
                        if ([weakSelf.delegate respondsToSelector:@selector(needVerify:)]) {
                            [GKMessageTool showText:@"群聊邀请已发送给群主！"];
                            [weakSelf.delegate needVerify:msg];
                        }
                    }
                }];
                
//
//                WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
//                vc.delegate = self;
//                vc.didTouch = @selector(onInputHello:);
//                vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
//                vc.titleColor = [UIColor lightGrayColor];
//                vc.titleFont = [UIFont systemFontOfSize:13.0];
//                vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
//                vc = [vc init];
//                [g_window addSubview:vc.view];
            }else {
                _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
                _chatRoom.isConnected = NO;
                [_wait start:Localized(@"JXAlert_AddRoomIng") delay:30];
                //新房间:
                _chatRoom.delegate = self;
                [_chatRoom joinRoom:YES];
            }
        }
    }
}


-(void)onInputHello:(WH_JXInput_WHVC*)sender{
    
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.fromUserId = MY_USER_ID;
    msg.toUserId = [NSString stringWithFormat:@"%@", self.roomUserId];
    msg.fromUserName = MY_USER_NAME;
    msg.toUserName = self.roomUserName;
    msg.timeSend = [NSDate date];
    msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    NSString *userIds = g_myself.userId;
    NSString *userNames = g_myself.userNickname;
    NSDictionary *dict = @{
                           @"userIds" : userIds,
                           @"userNames" : userNames,
                           @"roomJid" : self.roomJid,
                           @"reason" : sender.inputText,
                           @"isInvite" : [NSNumber numberWithBool:YES]
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    msg.objectId = jsonStr;
    [g_xmpp sendMessage:msg roomName:nil];
    [self actionQuit];
    
    //    msg.fromUserId = self.roomJid;
    //    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
    //    msg.content = @"申请已发送给群主，请等待群主确认";
    //    [msg insert:self.roomJid];
    //    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
    //        [self.delegate needVerify:msg];
    //    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

-(void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    NSDictionary * dict = _dataDict;
    
    WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
    user.userNickname = [dict objectForKey:@"name"];
    user.userId = [dict objectForKey:@"jid"];
    user.userDescription = [dict objectForKey:@"desc"];
    user.roomId = [dict objectForKey:@"id"];
    user.showRead = [dict objectForKey:@"showRead"];
    user.showMember = [dict objectForKey:@"showMember"];
    user.allowSendCard = [dict objectForKey:@"allowSendCard"];
    user.chatRecordTimeOut = [dict objectForKey:@"chatRecordTimeOut"];
    user.talkTime = [dict objectForKey:@"talkTime"];
    user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
    user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
    user.allowConference = [dict objectForKey:@"allowConference"];
    user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
    
    if (![user haveTheUser])
        [user insertRoom];
//    else
//        [user update];
    //    [user release];
    
    [g_server WH_addRoomMemberWithRoomId:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
    
    dict = nil;
    _chatRoom.delegate = nil;
    
}

-(void)showChatView{
    [_wait stop];
    NSDictionary * dict = _dataDict;
    
    WH_RoomData * roomdata = [[WH_RoomData alloc] init];
    [roomdata WH_getDataFromDict:dict];
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    sendView.title = [dict objectForKey:@"name"];
    sendView.roomJid = [dict objectForKey:@"jid"];
    sendView.roomId = [dict objectForKey:@"id"];
    sendView.chatRoom = _chatRoom;
    sendView.room = roomdata;
    
    WH_JXUserObject * userObj = [[WH_JXUserObject alloc]init];
    userObj.userId = [dict objectForKey:@"jid"];
    userObj.showRead = [dict objectForKey:@"showRead"];
    userObj.userNickname = [dict objectForKey:@"name"];
    userObj.showMember = [dict objectForKey:@"showMember"];
    userObj.allowSendCard = [dict objectForKey:@"allowSendCard"];
    userObj.chatRecordTimeOut = roomdata.chatRecordTimeOut;
    userObj.talkTime = [dict objectForKey:@"talkTime"];
    userObj.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
    userObj.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
    userObj.allowConference = [dict objectForKey:@"allowConference"];
    userObj.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
    
    sendView.chatPerson = userObj;
    sendView = [sendView init];
//    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    
    dict = nil;
}


- (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}




@end
