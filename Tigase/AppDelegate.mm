#import "AppDelegate.h"

#import "WH_JXMain_WHViewController.h"
#import "emojiViewController.h"
#import "JXXMPP.h"
#import "WH_VersionManageTool.h"
#import "WH_JXGroup_WHViewController.h"
#import "WH_LoginViewController.h"
#import "BPush.h"
#import <UMShare/UMShare.h>
#import <UMCommon/UMCommon.h>
#import "UMSocialWechatHandler.h"
#import "JXShareManage.h"
//#import <AlipaySDK/AlipaySDK.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#if Meeting_Version
#if !TARGET_IPHONE_SIMULATOR
#import <JitsiMeet/JitsiMeet.h>
#endif
#endif
#ifdef USE_GOOGLEMAP
#import <GoogleMaps/GoogleMaps.h>
#endif
#import <AlipaySDK/AlipaySDK.h>
#import "WH_NumLock_WHViewController.h"
#import <Bugly/Bugly.h>
#import "WH_LoginViewController.h"
#import "WH_AdvertisingViewController.h"
#import "JX_QQ_manager.h"
#import "WH_JXMsg_WHViewController.h"
#import <WebKit/WebKit.h>
#import "AppDelegate+ShareSDK.h"
#import "WH_JXUserObject+GetCurrentUser.h"
#import "WH_webpage_WHVC.h"

#import "NSString+StringNull.h"

@implementation AppDelegate
@synthesize window,faceView,mainVc;

#if TAR_IM
#ifdef Meeting_Version
@synthesize jxMeeting;
#endif
#endif

static  BMKMapManager* _baiduMapManager;
static  WH_webpage_WHVC *webVC;

- (void)dealloc
{
#if TAR_IM
#ifdef Meeting_Version
    [jxMeeting WH_stopMeeting];
#endif
#endif
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarStyle = UIStatusBarStyleDefault;
    
    _navigation = [[JXNavigation alloc] init];
    
    // 网络监听
    //    [self networkStatusChange];
    // 监听截屏
    //    [g_notify addObserver:self selector:@selector(getScreenShot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    //    if(isIOS7){
    //        application.statusBarStyle = UIStatusBarStyleDefault;
    //        window.clipsToBounds = YES;
    //        window.frame = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height-20);
    //    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    _didPushObj = [WH_JXDidPushObj sharedInstance];
    
#if TAR_IM
#ifdef Meeting_Version
    jxMeeting = [[WH_JXMeetingObject alloc] init];
    [self startVoIPPush];
#endif
#endif
    
    //    [NSThread sleepForTimeInterval:0.3];
    
//    进入登录页
    [self showLoginUI];
    
//    mainVc=[[WH_JXMain_WHViewController alloc]init];
//    g_navigation.rootViewController = mainVc;
    
    [self startPush:application didFinishLaunchingWithOptions:launchOptions];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _baiduMapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL ret = false;
    //    if ([identifier isEqualToString:@"com.shandianyun.wahu"]) {
    ret = [_baiduMapManager start:BMK_AK generalDelegate:nil];
    //    }
    if (!ret)
        NSLog(@"BMKMapManager start faild!");
    
    //谷歌地图
#ifdef USE_GOOGLEMAP
    [GMSServices provideAPIKey:@""];
#endif
    //    if (![g_default boolForKey:kUseGoogleMap]) {
    //        [g_default setBool:NO forKey:kUseGoogleMap];
    //    }
    // 设置友盟AppKey
    [UMConfigure initWithAppkey:UM_APPKEY channel:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    //设置微信三方登录和分享配置
    [WXApi registerApp:MXWechatAPPID universalLink:@"https://www.bbsmax.com/A/LPdoE8YEJ3/"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:MXWechatAPPID appSecret:MXWechatAPPSecret redirectURL:@"http://mobile.umeng.com/social"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatTimeLine appKey:MXWechatAPPID appSecret:MXWechatAPPSecret redirectURL:@"http://mobile.umeng.com/social"];
    
    
    [self registerAPN];
    
    [self setUserAgent];
    
    NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    //    [g_notify postNotificationName:kDidReceiveRemoteNotification object:pushNotificationKey];
    [g_default setObject:pushNotificationKey forKey:kDidReceiveRemoteDic];
    [g_default synchronize];
    
    // 设置腾讯奔溃日志
//    [Bugly startWithAppId:BUGLY_APPID];
    
    
//    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:self.timer1 forMode:NSRunLoopCommonModes];
    
    return YES;
}

- (void)changeTime {
    NSString *times = [@"2022-01-20 00:00:00" formatTimeToTimestampWithFormaterStr:@"yyyy-MM-dd HH:mm:ss"];

    if ([[NSString getNowTimeTimestamp] longLongValue] > [times longLongValue]) {
        [self exitTime];
    }
}

- (void)exitTime {
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    [UIView animateWithDuration:0.25f animations:^{
        CGAffineTransform curent =  window.transform;
        CGAffineTransform scale = CGAffineTransformScale(curent, 0.1,0.1);
        [window setTransform:scale];
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

- (void)setUserAgent {
    WKWebView *webView = [[WKWebView alloc] init];
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id obj, NSError *error) {
        if([obj isKindOfClass:[NSString class]]) {
            NSString *originUA = obj;
            NSString *newUA = [NSString stringWithFormat:@"%@ %@",originUA,@"app-tigimapp"];
            NSDictionary *dictionary = @{@"UserAgent":newUA};
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        }
    }];
}

- (void)registerAPN{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"注册失败");
            }
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

-(UIView *)subWindow
{
    if (!_subWindow) {
        _subWindow = [[UIView alloc] initWithFrame:CGRectMake(100,200,80,80)];
        //        _subWindow.windowLevel  =  UIWindowLevelAlert +1;
        //        [_subWindow makeKeyAndVisible]; //关键语句，显示窗口
        [g_window addSubview:_subWindow];
    }
    
    return _subWindow;
}
/**
 *开启悬浮的窗口
 */
- (void)showSuspensionWindow
{
    BOOL SUPPORT_FLOATING_WINDOW = NO;//是否开启全局悬浮窗
    if (!SUPPORT_FLOATING_WINDOW)
    {
        return;
    }
    
    NSDictionary *tabBarConfig = g_config.tabBarConfigList;
    NSString *tabBarLinkUrl = tabBarConfig[@"tabBarLinkUrl"];
    NSString *tabBarName = [tabBarConfig objectForKey:@"tabBarName"]?:@"";
    NSString *tabBarImg = tabBarConfig[@"tabBarImg"]?:@"";
    if (tabBarConfig && !IsStringNull(tabBarLinkUrl)&&!IsStringNull(tabBarLinkUrl)&&!IsStringNull(tabBarName) && !_subTopWindow) {
        
        _subTopWindow = [[UIView alloc] init];
        _subTopWindow.frame = CGRectMake(JX_SCREEN_WIDTH - 50 - 10, (JX_SCREEN_HEIGHT -50)/2, 50, 50);
        
        if (_subWindowInitFrame.origin.x) {
            _subTopWindow.frame  = _subWindowInitFrame;
        }
        _subTopWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _subTopWindow.layer.masksToBounds = YES;
        _subTopWindow.layer.cornerRadius = 25;
        [self.window addSubview:_subTopWindow];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_subTopWindow addGestureRecognizer:pan];
        
        _suspensionBtn = [[UIButton alloc] initWithFrame:_subTopWindow.bounds];
        _suspensionBtn.backgroundColor = [UIColor clearColor];
        [_suspensionBtn addTarget:self action:@selector(showFloatWindow) forControlEvents:UIControlEventTouchUpInside];
        [_subTopWindow addSubview:_suspensionBtn];
        
        imgV = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 34, 34)];
        [imgV sd_setImageWithURL:[NSURL URLWithString:tabBarImg]];
        imgV.layer.masksToBounds = YES;
        imgV.layer.cornerRadius = 17;
        [_subTopWindow addSubview:imgV];
        
        [self hideWebOnWindow];
    }
    _subTopWindow.hidden = NO;
    [self.window bringSubviewToFront:_subTopWindow];
}
-(void)hideWebOnWindow{
    _isINTopWindow = NO;
    if (webVC) {
        NSDictionary *tabBarConfig = g_config.tabBarConfigList;
        NSString *tabBarImg = tabBarConfig[@"tabBarImg"]?:@"";
        [imgV sd_setImageWithURL:[NSURL URLWithString:tabBarImg]];
        
        [UIView animateWithDuration:0.25 animations:^{
            webVC.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, 0);
        } completion:^(BOOL finished) {
            webVC.view.hidden = YES;
        }];
    }
}


- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        _subWindowFrame = _subTopWindow.frame;
    }
    CGPoint offset = [pan translationInView:g_App.window];
    CGPoint offset1 = [pan translationInView:_subTopWindow];
    NSLog(@"pan - offset = %@, offset1 = %@", NSStringFromCGPoint(offset), NSStringFromCGPoint(offset1));
    
    CGRect frame = _subWindowFrame;
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    _subTopWindow.frame = frame;
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        if (frame.origin.x <= JX_SCREEN_WIDTH / 2) {
            frame.origin.x = 10;
        }else {
            frame.origin.x = JX_SCREEN_WIDTH - frame.size.width - 10;
        }
        if (frame.origin.y < 0) {
            frame.origin.y = 10;
        }
        if ((frame.origin.y + frame.size.height) > JX_SCREEN_HEIGHT) {
            frame.origin.y = JX_SCREEN_HEIGHT - frame.size.height - 10;
        }
        _subWindowInitFrame = frame;
        [UIView animateWithDuration:0.5 animations:^{
            _subTopWindow.frame = frame;
        }];
    }
}

- (void)showFloatWindow {
    if (_isINTopWindow) {
        [self hideWebOnWindow];
        return;
    }
    NSDictionary *tabBarConfig = g_config.tabBarConfigList;
    NSString *tabBarLinkUrl = tabBarConfig[@"tabBarLinkUrl"];
    _isINTopWindow = YES;
    if (tabBarLinkUrl && (!webVC || _isHaveTopWindow)) {
        _isHaveTopWindow = NO;
        webVC = [WH_webpage_WHVC alloc];
        webVC.wh_isGotoBack= YES;
        webVC.isSend = YES;
        webVC.url = tabBarLinkUrl;
        webVC.isFormSuspension = YES;
        webVC = [webVC init];
        webVC.view.hidden = NO;
        [self.window addSubview:webVC.view];
        
        [self.window bringSubviewToFront:_subTopWindow];
        
    }else if (tabBarLinkUrl && webVC){
        webVC.view.hidden = NO;
    }
    webVC.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, 0);
    [UIView animateWithDuration:0.25 animations:^{
        webVC.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        imgV.image = [UIImage imageNamed:@"closefloatWindow"];
    }];
    
    
}

-(void)showLoginUI {
    
    if (APP_Startup_ShowAdvertisingView) {
        WH_AdvertisingViewController *adVC = [[WH_AdvertisingViewController alloc] init];
        g_navigation.rootViewController = adVC;
        __block WH_LoginViewController *loginVC = [[ WH_LoginViewController alloc] init];
        loginVC.isSwitchUser= NO;
        adVC.skipActionBlock = ^{
            NSLog(@"跳过");
            g_navigation.rootViewController = loginVC;
        };
    } else {
        WH_LoginViewController *loginVC = [[ WH_LoginViewController alloc] init];
        loginVC.isSwitchUser= NO;
        g_navigation.rootViewController = loginVC;
    }
}

#pragma mark - 进入主界面
-(void)showMainUI{
    //    if(mainVc==nil){
    mainVc=[[WH_JXMain_WHViewController alloc]init];
    
    //    }
    //        [window addSubview:mainVc.view];
    //        window.rootViewController = mainVc;
    g_navigation.rootViewController = mainVc;
    int height = 218;
    if (THE_DEVICE_HAVE_HEAD) {
        height = 253;
    }
    faceView = [[emojiViewController alloc]initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-height, JX_SCREEN_WIDTH, height)];
    
    
    NSString *str = [g_default stringForKey:kDeviceLockPassWord];
    if (str.length > 0) {
        [self showDeviceLock];
    }
    
    [self  showSuspensionWindow];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 进入后台
    [g_notify postNotificationName:kApplicationDidEnterBackground object:nil];
    
    [g_notify postNotificationName:kAllVideoPlayerStopNotifaction object:nil userInfo:nil];
    [g_notify postNotificationName:kAllAudioPlayerStopNotifaction object:nil userInfo:nil];
    
    NSLog(@"XMPP ---- Appdelegate");
    [g_server outTime:nil];
    g_xmpp.isCloseStream = YES;
    g_xmpp.isReconnect = NO;
    [g_xmpp logout];
#if TAR_IM
#ifdef Meeting_Version
    [jxMeeting WH_meetingDidEnterBackground:application];
#endif
#endif
    
    NSString *str = [g_default stringForKey:kDeviceLockPassWord];
    if (str.length > 0) {
        [self showDeviceLock];
    }
    if(self.taskId != UIBackgroundTaskInvalid){
        return;
    }
    self.taskId =[application beginBackgroundTaskWithExpirationHandler:^(void) {
        //当申请的后台时间用完的时候调用这个block
        //此时我们需要结束后台任务，
        [self endTask];
    }];
    // 模拟一个长时间的任务 Task
    self.timer =[NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(longTimeTask:)
                                               userInfo:nil
                                                repeats:YES];
}

#pragma mark - 停止timer
-(void)endTask
{
    
    if (_timer != nil||_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
        
        //结束后台任务
        [[UIApplication sharedApplication] endBackgroundTask:_taskId];
        _taskId = UIBackgroundTaskInvalid;
        
        // NSLog(@"停止timer");
    }
}
- (void) longTimeTask:(NSTimer *)timer{
    
    // 系统留给的我们的时间
//    NSTimeInterval time = [[UIApplication sharedApplication] backgroundTimeRemaining];
    
}

- (void)showDeviceLock {
    if (!self.isShowDeviceLock) {
        self.isShowDeviceLock = YES;
        _numLockVC = [[WH_NumLock_WHViewController alloc]init];
        _numLockVC.isClose = NO;
        [g_window addSubview:_numLockVC.view];
    }
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [g_server.config showDisableUse];
    [g_notify postNotificationName:kApplicationWillEnterForeground object:nil];
    //    NSLog(@"applicationWillEnterForeground");
    if(g_server.isLogin){
        //        NSLog(@"login");
        [[JXXMPP sharedInstance] login];
#if TAR_IM
#ifdef Meeting_Version
        [jxMeeting WH_meetingWillEnterForeground:application];
#endif
#endif
    }
    
    // 清除过期聊天记录
    [[WH_JXUserObject sharedUserInstance] WH_deleteUserChatRecordTimeOutMsg];
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
//	NSLog(@"OpenURL:%@",url);
//    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
////    if ([url.host isEqualToString:@"safepay"]) {
////        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
////            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
////            NSLog(@"result = %@",resultDic);
////        }];
////    }
////    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
////        
////        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
////            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
////            NSLog(@"result = %@",resultDic);
////        }];
////    }
//    
//    return YES;
//}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [[JXShareManage sharedManager] handleOpenURL:url delegate:nil];
    
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        return [TencentOAuth HandleOpenURL:url];
    }
#if Meeting_Version
#if !TARGET_IPHONE_SIMULATOR
    //    [JitsiMeetView application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
#endif
#endif
    [[JXShareManage sharedManager] handleOpenURL:url delegate:nil];
    
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        [QQApiInterface handleOpenURL:url delegate:(id<QQApiInterfaceDelegate>)[JX_QQ_manager class]];
        return [TencentOAuth HandleOpenURL:url];
    }
    
#if Meeting_Version
#if !TARGET_IPHONE_SIMULATOR
    
    [[JitsiMeet sharedInstance] application:app openURL:url options:options];
    
#endif
#endif
    
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //安装支付宝客户端回调
            NSLog(@"支付宝客户端支付结果result = %@",resultDic);
            [g_notify postNotificationName:@"kAlipayPaymentCallbackNotification" object:resultDic];
            //            if (resultDic && [resultDic objectForKey:@"resultStatus"] && ([[resultDic objectForKey:@"resultStatus"] intValue] == 9000)) {
            //                //支付成功
            //            } else {
            //                // 支付失败
            //            }
        }];
    }
    NSString *urlString = [url.absoluteString stringByRemovingPercentEncoding];
    if ([urlString containsString:@"BLN"]) {
        [self handleBLNShareWithUrl:url];
    }
    //wahu
    //返回APP处理
    if ([url.host containsString:@"wahu"]) {
        
        NSString *urlDescStr = url.description;
        NSLog(@"==================urlDescStr:%@" ,urlDescStr);
        if (urlDescStr.length > 0) {
            NSArray *array = [urlDescStr componentsSeparatedByString:@"?"];
            if (array.count > 1) {
                NSString *descStr = [array objectAtIndex:1];
                NSArray *array2 = [descStr componentsSeparatedByString:@"&"];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (int i = 0; i < array2.count; i++) {
                    NSString *str2 = [array2 objectAtIndex:i];
                    NSArray *array3 = [str2 componentsSeparatedByString:@"="];
                    [dict setObject:(array3.count > 1)?[array3 objectAtIndex:1]:@"" forKey:(array3.count > 0)?[array3 objectAtIndex:0]:@""];
                }
                
                [g_default setObject:dict forKey:@"shareInfo"];
                [g_default synchronize];
                
            }
        }
        
    }
    
    [[JXShareManage sharedManager] handleOpenURL:url delegate:nil];
    
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 进入活跃
    [g_notify postNotificationName:kApplicationDidBecomeActive object:nil];
    
    //    if(g_server.isLogin && g_xmpp.isLogined != login_status_yes)
    //        [[JXXMPP sharedInstance] login];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    //    if(g_server.isLogin) {
    //        [g_server outTime:nil];
    //        g_xmpp.isCloseStream = YES;
    //        g_xmpp.isReconnect = NO;
    //        [g_xmpp logout];
    //    }
}

- (void) showAlert: (NSString *) message
{
    //    UIAlertView *av = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:self cancelButtonTitle:Localized(@"JX_Confirm") otherButtonTitles:nil, nil];
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //
    //        [av show];
    //    });
    
    [GKMessageTool showText:message];
    
    //    [av release];
}

- (UIAlertView *) showAlert: (NSString *) message delegate:(id)delegate
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:delegate cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [av show];
    });
    
    return av;
}

- (UIAlertView *) showAlert: (NSString *) message delegate:(id)delegate tag:(NSUInteger)tag onlyConfirm:(BOOL)onlyConfirm
{
    UIAlertView *av;
    if (onlyConfirm)
        av = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:delegate cancelButtonTitle:Localized(@"JX_Confirm") otherButtonTitles:nil];
    else
        av = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:delegate cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    av.tag = tag;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [av show];
    });
    return av;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
#if TAR_IM
#ifdef Meeting_Version
    //    [jxMeeting doNotify:notification];
#endif
#endif
    //    NSLog(@"推送：接收本地通知啦！！！");
    //    [BPush showLocalNotificationAtFront:notification identifierKey:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [g_server outTime:nil];
    [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
    [g_myself saveCurrentUser:[g_myself toDictionary]];
#if TAR_IM
#ifdef Meeting_Version
    [jxMeeting WH_doTerminate];
    [self endCall];
#endif
#endif
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
#if TAR_IM
#ifdef Meeting_Version
    [jxMeeting clearMemory];
#endif
#endif
}

-(void)endCall{
    if (_uuid) {
        
        //        self.isShowCall = NO;
        //        CXEndCallAction * endAction = [[CXEndCallAction alloc] initWithCallUUID:_uuid];
        //        CXTransaction * trans = [[CXTransaction alloc] initWithAction:endAction];
        //
        //        CXCallController * callVC = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
        //        [callVC requestTransaction:trans completion:^(NSError * _Nullable error) {
        //            if (error) {
        //                //                NSLog(@"%@",error.description);
        //                [self.provider reportCallWithUUID:_uuid endedAtDate:nil reason:CXCallEndedReasonUnanswered];
        //            }
        //            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        //                [self applicationDidEnterBackground:[UIApplication sharedApplication]];
        //            }
        //            _uuid = nil;
        //        }];
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [self applicationDidEnterBackground:[UIApplication sharedApplication]];
    }
}


-(void)startPush:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // iOS8 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    //    NSString * identifier = [[NSBundle mainBundle] bundleIdentifier];
    //    if ([identifier isEqualToString:@"com.shiku.im.push"]) {
    //        [BPush registerChannel:launchOptions apiKey:@"YWCjFscGk7cv3RlEtaxoypzt0sipp6vw" pushMode: BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:YES isDebug:NO];
    //    }else{
    //        [BPush registerChannel:launchOptions apiKey:@"7LlWDe0AZGKILS4Tq5cMNMum" pushMode: BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:YES isDebug:NO];
    //    }
    
    //
    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        //        NSLog(@"从消息启动:%@",userInfo);
        [BPush handleNotification:userInfo];
    }
#if TARGET_IPHONE_SIMULATOR
    Byte dt[32] = {0xc6, 0x1e, 0x5a, 0x13, 0x2d, 0x04, 0x83, 0x82, 0x12, 0x4c, 0x26, 0xcd, 0x0c, 0x16, 0xf6, 0x7c, 0x74, 0x78, 0xb3, 0x5f, 0x6b, 0x37, 0x0a, 0x42, 0x4f, 0xe7, 0x97, 0xdc, 0x9f, 0x3a, 0x54, 0x10};
    [self application:application didRegisterForRemoteNotificationsWithDeviceToken:[NSData dataWithBytes:dt length:32]];
#endif
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

//// 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台 时调起
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    completionHandler(UIBackgroundFetchResultNewData);
//    // 打印到日志 textView 中
////    NSLog(@"********** iOS7.0之后 background **********");
//    // 应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
//    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
////        NSLog(@"acitve or background");
////        [self showAlert:userInfo[@"aps"][@"alert"]];
//    }
//    else//杀死状态下，直接跳转到跳转页面。
//    {
//    }
//}


// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"deviceToken:%@",deviceToken);
    //    NSString *token = [NSString stringWithFormat:@"%@",deviceToken];
    //    NSString * token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    //apnsToken 需要提交给服务器
    //    [g_default setObject:token forKey:@"apnsToken"];
    
    if (@available(iOS 13.0, *)) {
        NSMutableString *deviceTokenString = [NSMutableString string];
        const char *bytes = (char *)deviceToken.bytes;
        NSInteger count = deviceToken.length;
        for (int i = 0; i < count; i++) {
            [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
        }
        //apnsToken 需要提交给服务器
        [g_default setObject:deviceTokenString forKey:@"apnsToken"];
    } else {
        NSString *deviceTokenStr =  [[[[deviceToken description]
                                       stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                      stringByReplacingOccurrencesOfString:@">" withString:@""]
                                     stringByReplacingOccurrencesOfString:@" " withString:@""];
        //apnsToken 需要提交给服务器
        [g_default setObject:deviceTokenStr forKey:@"apnsToken"];
    }
    
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
        if (result) {
            [BPush setTag:@"Mytag" withCompleteHandler:^(id result, NSError *error) {
                if (result) {
                    NSLog(@"设置tag成功");
                }
            }];
        }
    }];
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App 收到推送的通知
    [BPush handleNotification:userInfo];
    
    NSMutableDictionary *mutaDict = [NSMutableDictionary dictionary];
    [userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *keyStr = [[NSString alloc] init];
        keyStr = [NSString stringWithFormat:@"%@",key];
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = @"";
        }
        [mutaDict setObject:obj forKey:keyStr];
    }];
    
    [g_default setObject:mutaDict forKey:kDidReceiveRemoteDic];
    [g_default synchronize];
    //    [g_notify postNotificationName:kDidReceiveRemoteNotification object:userInfo];
    
    //    NSLog(@"********** ios7.0之前 **********");
    // 应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
        //        NSLog(@"acitve or background");
        //        [self showAlert:userInfo[@"aps"][@"alert"]];
    }
    else//杀死状态下，直接跳转到跳转页面。
    {
    }
}

// 监听网络状态
- (void)networkStatusChange {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status != AFNetworkReachabilityStatusNotReachable) {
            if (g_server.isLogin) {
                if (g_xmpp.isLogined != login_status_yes) {
                    [[JXXMPP sharedInstance] logout];
                    [[JXXMPP sharedInstance] login];
                }
            }
            g_App.mainVc.msgVc.wh_isShowTopPromptV = NO;
        }else {
            [g_xmpp.reconnectTimer invalidate];
            g_xmpp.reconnectTimer = nil;
            g_xmpp.isReconnect = NO;
            [[JXXMPP sharedInstance] logout];
            //            [g_App showAlert:Localized(@"JX_NetWorkError")];
            //无网络,网络错误
            g_App.mainVc.msgVc.wh_isShowTopPromptV = YES;
        }
    }];
}

#if TAR_IM
#ifdef Meeting_Version
-(void)startVoIPPush{
    NSString * identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([identifier isEqualToString:@"com.shandianyun.wahu"] && [[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
    }else{
        [g_default removeObjectForKey:@"voipToken"];
    }
}

#pragma mark - PKPushRegistryDelegate
-(void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type{
    if ([credentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }
    NSString * voipToken = [[[[credentials.token description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    //voipToken 需要提交给服务器
    [g_default setObject:voipToken forKey:@"voipToken"];
    NSLog(@"voipToken:%@",voipToken);
}

-(void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type{
    
    if (type != PKPushTypeVoIP) {
        return;
    }
    
    NSString * fromUserName = payload.dictionaryPayload[@"fromUserName"];
    int messageType = [[NSString stringWithFormat:@"%@",payload.dictionaryPayload[@"messageType"]] intValue];
    BOOL isVoiceVideoKuangJia = messageType == kWCMessageTypeAudioChatAsk ? YES : NO;
    BOOL isAudio = (messageType == kWCMessageTypeAudioChatAsk || messageType == kWCMessageTypeAudioMeetingInvite) ? YES : NO;
    BOOL isVideo = (messageType == kWCMessageTypeVideoChatAsk || messageType == kWCMessageTypeVideoMeetingInvite) ? YES : NO;
    fromUserName = fromUserName.length > 0 ? fromUserName : APP_NAME;
    
    
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive:
        case UIApplicationStateInactive:{
            //不处理,显示app接听界面
            if (_uuid) {
                [self endCall];
            }
            break;
        }
        case UIApplicationStateBackground:
        default:{
            if (isVoiceVideoKuangJia && !_uuid && [[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
                if (_uuid) {
                    return;
                }
                
                _uuid = [NSUUID UUID];
                [self applicationWillEnterForeground:[UIApplication sharedApplication]];
                
                
            }else if(isAudio || isVideo){
                _uuid = nil;
                [self meetingLocalNotifi:fromUserName isAudio:isAudio];
            }
            break;
        }
    }
}

-(void)meetingLocalNotifi:(NSString *)fromUserName isAudio:(BOOL)isAudio{
    UILocalNotification *callNotification = [[UILocalNotification alloc] init];
    
    NSString *stringAlert;
    if (isAudio){
        stringAlert = [NSString stringWithFormat:@"%@ \n %@", Localized(@"WaHu_JXMeetingObject_VoiceChat"),fromUserName];
    }else{
        stringAlert = [NSString stringWithFormat:@"%@\n %@",Localized(@"WaHu_JXMeetingObject_VideoChat"), fromUserName];
    }
    callNotification.alertBody = stringAlert;
    
    callNotification.soundName = @"whynotyou.caf";
    [[UIApplication sharedApplication]
     presentLocalNotificationNow:callNotification];
}


#endif
#endif


// 截屏监听
//- (void)getScreenShot:(NSNotification *)notification{
//    NSLog(@"捕捉截屏事件");
//    
//    //获取截屏图片
////    UIImage *image = [UIImage imageWithData:[self imageDataScreenShot]];
//    NSData *imageData = [self imageDataScreenShot];
//    BOOL isSuccess = [imageData writeToFile:ScreenShotImage atomically:YES];
//    if (isSuccess) {
//        NSLog(@"截屏存储成功 - %@", NSHomeDirectory());
//    }else {
//        NSLog(@"截屏存储失败");
//    }
//}

- (NSData *)imageDataScreenShot
{
    CGSize imageSize = CGSizeZero;
    imageSize = [UIScreen mainScreen].bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

- (void)copyDbWithUserId:(NSString *)userId {
    // 拷贝文件到share extension 共享存储空间中
    userId = [userId uppercaseString];
    NSString* t =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* copyPath = [NSString stringWithFormat:@"%@/%@.db",t,userId];
    
    //获取分组的共享目录
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *fileName = [NSString stringWithFormat:@"%@.db",userId];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:fileName];
    
    NSString *path = [fileURL.absoluteString substringFromIndex:7];
    
    NSError *error = nil;
    [manager removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"删除失败error : %@",error);
    }
    if (path.length <= 0) {
        return;
    }
    BOOL isCopy = [manager copyItemAtPath:copyPath toPath:path error:nil];
    
    if (isCopy) {
        static dispatch_once_t disOnce;
        dispatch_once(&disOnce,^ {
            //只执行一次的代码
            NSLog(@"share extension : %@",path);
        });
    }
}


@end
