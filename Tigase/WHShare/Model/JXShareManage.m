//
//  JXShareManage.m
//  Tigase_imChatT
//
//  Created by p on 2018/11/1.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "JXShareManage.h"
#import "WH_JXRelay_WHVC.h"
#ifdef Meeting_Version
#import "JXAVCallViewController.h"
#endif
#import "WH_JXSkPay_WHVC.h"
#import "WH_JXVerifyPay_WHVC.h"
#import "WH_JXPayPassword_WHVC.h"

@interface JXShareManage ()<WH_JXSkPay_WHVCDelegate>

@property (nonatomic, assign) BOOL isAuth;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, assign) BOOL isMeet;
@property (nonatomic, assign) BOOL isSkPay;
@property (nonatomic, assign) BOOL isSkShare;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, strong) WH_JXAuth_WHViewController *authVC;
@property (nonatomic, strong) WH_JXRelay_WHVC *relayVC;

@property (nonatomic, assign) BOOL isWebAuth;
@property (nonatomic, strong) NSDictionary *orderDic;
@property (nonatomic, strong) WH_JXVerifyPay_WHVC * verVC;
@property (nonatomic, strong) NSDictionary *skPayDic;
@property (nonatomic, strong) NSDictionary *skShareDic;

@end

@implementation JXShareManage

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static JXShareManage *instance;
    dispatch_once(&onceToken, ^{
        instance = [[JXShareManage alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if ([super init]) {
        
        [g_notify addObserver:self selector:@selector(systemLoginNotif:) name:kSystemLogin_WHNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(WH_onXmppLoginChanged:) name:kXmppLogin_WHNotifaction object:nil];
    }
    
    return self;
}

- (void)systemLoginNotif:(NSNotification *)notif {
    
    if (self.isAuth) {
        self.isAuth = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSString *urlSchemes = [self subString:self.urlStr withString:@"urlSchemes"];
            NSString *appId = [self subString:self.urlStr withString:@"appId"];
            NSString *appSecret = [self subString:self.urlStr withString:@"appSecret"];
            NSString *callbackUrl = [self subString:self.urlStr withString:@"callbackUrl"];
            
            self.authVC = [[WH_JXAuth_WHViewController alloc] init];
            self.authVC.urlSchemes = urlSchemes;
            self.authVC.appId = appId;
            self.authVC.isWebAuth = self.isWebAuth;
            self.authVC.callbackUrl = callbackUrl;
            self.authVC.appSecret = appSecret;
            UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
            [lastVC presentViewController:self.authVC animated:YES completion:nil];
        });
    }else if (self.isShare){
        [g_server WH_openOpenAuthInterfaceWithUserId:g_myself.userId appId:[self subString:self.urlStr withString:@"appId"] appSecret:[self subString:self.urlStr withString:@"appSecret"] type:2 toView:self];
    }
    if (self.isSkPay) {
        
        [g_server WH_payGetOrderInfoWithAppId:[self.orderDic objectForKey:@"appId"] prepayId:[self.orderDic objectForKey:@"prepayId"] toView:self];
    }
    
}

-(void)WH_onXmppLoginChanged:(NSNumber*)isLogin{
    if([JXXMPP sharedInstance].isLogined == login_status_yes){

        if (self.isShare) {
            self.isShare = NO;
            WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
            msg.type = [NSNumber numberWithInt:kWCMessageTypeShare];
            msg.content = Localized(@"JX_[Link]");
            
            NSDictionary *dict = @{
                                   @"url" : [self subString:self.urlStr withString:@"url"],
                                   @"downloadUrl" : [self subString:self.urlStr withString:@"downloadUrl"],
                                   @"title" : [self subString:self.urlStr withString:@"title"],
                                   @"subTitle" : [self subString:self.urlStr withString:@"subTitle"],
                                   @"imageUrl" : [self subString:self.urlStr withString:@"imageUrl"],
                                   @"appName" : [self subString:self.urlStr withString:@"appName"],
                                   @"appIcon" : [self subString:self.urlStr withString:@"appIcon"],
                                   @"urlSchemes" : [self subString:self.urlStr withString:@"urlSchemes"]
                                   };
            
            NSString * jsonString = [dict mj_JSONString];
            
            msg.objectId = jsonString;
            
            self.relayVC = [[WH_JXRelay_WHVC alloc] init];
            self.relayVC.isShare = YES;
            self.relayVC.shareSchemes = [self subString:self.urlStr withString:@"urlSchemes"];
            NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
            self.relayVC.relayMsgArray = array;
            UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
            [lastVC presentViewController:self.relayVC animated:YES completion:nil];
        }
        
        
        // 网页拉起音视频会议
        if (self.isMeet) {
            self.isMeet = NO;
            NSString *type = [self subString:self.urlStr withString:@"type"];
            NSString *room = [self subString:self.urlStr withString:@"room"];
            BOOL isAudio = ![type isEqualToString:@"video"];
            [self WH_startMeetWithIsAudio:isAudio roomNum:room];
        }
        
        // 网页分享
        if (self.isSkShare) {
            [self WH_skShareAction];
        }
    }
}

- (void)WH_startMeetWithIsAudio:(BOOL)isAudio roomNum:(NSString *)roomNum {
    
#ifdef Meeting_Version
    JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
    avVC.roomNum = roomNum;
    avVC.isAudio = isAudio;
    avVC.isGroup = YES;
//    avVC.toUserName = MY_USER_NAME;
    avVC.view.frame = [UIScreen mainScreen].bounds;
    [g_window addSubview:avVC.view];

#endif
    
}

// 第三方APP 跳转回调
-(BOOL) handleOpenURL:(NSURL *) url delegate:(id) delegate {
    
    [self.authVC dismissViewControllerAnimated:YES completion:nil];
    [self.relayVC dismissViewControllerAnimated:YES completion:nil];
    
    NSString *urlStr = [url absoluteString];
    urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.urlStr = urlStr;
    
    NSString *type = [self subString:urlStr withString:@"type"];
    if ([urlStr containsString:SDKShareIdentifier]) {
        type = nil;
    }
    
    
    // 网页拉起音视频会议
    NSRange meetRange = [urlStr rangeOfString:@"meet.ttechworld.com"];
    
    NSLog(@"g_config.jitsiServer == %@", g_config.jitsiServer);
    NSLog(@"urlStr == %@", urlStr);
//https://meet.ttechworld.com/
//    NSRange meetRange = [urlStr rangeOfString:@"47.99.32.196"];
    if (meetRange.location != NSNotFound && meetRange.length > 0) {
        
        if ([JXXMPP sharedInstance].isLogined == login_status_yes) {
            self.isMeet = NO;
            NSString *room = [self subString:urlStr withString:@"room"];
            BOOL isAudio = ![type isEqualToString:@"video"];
            [self WH_startMeetWithIsAudio:isAudio roomNum:room];
            
            return YES;
        }else {
            
            self.isMeet = YES;
            return NO;
        }
    }
    
    
    // 网页支付
    NSRange skPayRange = [urlStr rangeOfString:@"skPay"];
    if (skPayRange.location != NSNotFound && skPayRange.length > 0) {
        
        self.orderDic = @{
                          @"appId" : [self subString:urlStr withString:@"appId"],
                          @"prepayId" : [self subString:urlStr withString:@"prepayId"],
                          @"sign" : [self subString:urlStr withString:@"sign"]
                          };
        
        if (!g_server.isLogin) {
            
            self.isSkPay = YES;
            return NO;
        }else {
            return YES;
        }
    }
    
    // 网页分享
    NSRange skShareRange = [urlStr rangeOfString:@"skShare"];
    if (skShareRange.location != NSNotFound && skShareRange.length > 0) {
        
        self.skShareDic = @{
                          @"appId" : [self subString:urlStr withString:@"appId"],
                          @"appName" : [self subString:urlStr withString:@"appName"],
                          @"appIcon" : [self subString:urlStr withString:@"appIcon"],
                          @"title" : [self subString:urlStr withString:@"title"],
                          @"subTitle" : [self subString:urlStr withString:@"subTitle"],
                          @"url" : [self subString:urlStr withString:@"url"],
                          @"downloadUrl" : [self subString:urlStr withString:@"downloadUrl"],
                          @"imageUrl" : [self subString:urlStr withString:@"imageUrl"]
                          };
        
        if (g_xmpp.isLogined != login_status_yes) {
            
            self.isSkShare = YES;
            return NO;
        }else {
            [self WH_skShareAction];
            return YES;
        }
    }
    

    // 网页第三方认证
    NSRange range = [urlStr rangeOfString:@"www.baidu.com"];
    if (range.location != NSNotFound && range.length > 0) {
        
        self.isWebAuth = YES;
        type = @"Auth";
    }else {
        self.isWebAuth = NO;
    }
    
    if (!type) {
        return NO;
    }
    if ([type isEqualToString:@"Auth"]) {
        
        if (!g_server.isLogin) {
            
            self.isAuth = YES;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (!g_server.isLogin) {
                
                self.isAuth = YES;
            }else {
                NSString *urlSchemes = [self subString:urlStr withString:@"urlSchemes"];
                NSString *appId = [self subString:self.urlStr withString:@"appId"];
                NSString *appSecret = [self subString:self.urlStr withString:@"appSecret"];
                NSString *callbackUrl = [self subString:self.urlStr withString:@"callbackUrl"];
                
                self.authVC = [[WH_JXAuth_WHViewController alloc] init];
                self.authVC.urlSchemes = urlSchemes;
                self.authVC.appId = appId;
                self.authVC.isWebAuth = self.isWebAuth;
                self.authVC.callbackUrl = callbackUrl;
                self.authVC.appSecret = appSecret;
                UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
                [lastVC presentViewController:self.authVC animated:YES completion:nil];
            }
            
        });
        
    }else {
        if (g_server.isLogin) {
            [g_server WH_openOpenAuthInterfaceWithUserId:g_myself.userId appId:[self subString:urlStr withString:@"appId"] appSecret:[self subString:urlStr withString:@"appSecret"] type:2 toView:self];
        }else {
            self.isShare = YES;
        }
        
    }
    return YES;
}

- (void)WH_skShareAction {
    
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.type = [NSNumber numberWithInt:kWCMessageTypeShare];
    msg.content = Localized(@"JX_[Link]");
    
    msg.objectId = [self.skShareDic mj_JSONString];
    self.relayVC = [[WH_JXRelay_WHVC alloc] init];
    self.relayVC.isShare = YES;
    self.relayVC.shareSchemes = nil;
    NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
    self.relayVC.relayMsgArray = array;
    UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
    [lastVC presentViewController:self.relayVC animated:YES completion:nil];
}

- (NSString *)subString:(NSString *)url withString:(NSString *)str {
    NSString *urlStr = [url copy];
    
    NSRange range = [urlStr rangeOfString:@"//"];
    urlStr = [urlStr substringFromIndex:range.location + range.length];
    
    range = [urlStr rangeOfString:[NSString stringWithFormat:@"%@=",str]];
    if (range.location == NSNotFound) {
        return nil;
    }
    urlStr = [urlStr substringFromIndex:range.location + range.length];
    
    range = [urlStr rangeOfString:@","];
    if (range.location != NSNotFound) {
        urlStr = [urlStr substringToIndex:range.location];
    }else {
        range = [urlStr rangeOfString:@"&"];
        if (range.location != NSNotFound) {
            urlStr = [urlStr substringToIndex:range.location];
        }
    }
    
    return urlStr;
}

- (void)skPayVC:(WH_JXSkPay_WHVC *)skPayVC payBtnAction:(NSDictionary *)payDic {
    g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
    if ([g_myself.isPayPassword boolValue]) {
        self.verVC = [WH_JXVerifyPay_WHVC alloc];
        self.verVC.type = JXVerifyTypeSkPay;
        self.verVC.wh_RMB = [payDic objectForKey:@"money"];
        self.verVC.wh_titleStr = [payDic objectForKey:@"desc"];
        self.verVC.delegate = self;
        self.verVC.didDismissVC = @selector(WH_dismiss_WHVerifyPayVC);
        self.verVC.didVerifyPay = @selector(WH_didVerifyPay:);
        self.verVC = [self.verVC init];
        
        UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
        [lastVC.view addSubview:self.verVC.view];
    } else {
        WH_JXPayPassword_WHVC *payPswVC = [WH_JXPayPassword_WHVC alloc];
        payPswVC.type = JXPayTypeSetupPassword;
        payPswVC.enterType = JXVerifyTypeSkPay;
        payPswVC = [payPswVC init];
        [g_navigation pushViewController:payPswVC animated:YES];
    }
}

- (void)WH_didVerifyPay:(NSString *)sender {
    long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    NSString *appId = [self.orderDic objectForKey:@"appId"];
    NSString *prepayId = [self.orderDic objectForKey:@"prepayId"];
    NSString *sign = [self.orderDic objectForKey:@"sign"];
    NSString *secret = [self WH_getSecretWithPassword:sender time:time];
    
    [g_server payPasswordPaymentWithAppId:appId prepayId:prepayId sign:sign time:[NSString stringWithFormat:@"%ld",time] secret:secret toView:self];
}

- (NSString *)WH_getSecretWithPassword:(NSString *)password time:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    
    NSMutableString *str2 = [NSMutableString string];
    [str2 appendString:APIKEY];
    [str2 appendString:[NSString stringWithFormat:@"%ld",time]];
    [str2 appendString:[g_server WH_getMD5StringWithStr:password]];
    str2 = [[g_server WH_getMD5StringWithStr:str2] mutableCopy];
    
    [str1 appendString:str2];
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    return [str1 copy];
}

- (void)WH_dismiss_WHVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if([aDownload.action isEqualToString:wh_act_OpenAuthInterface]){
        
        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
        msg.type = [NSNumber numberWithInt:kWCMessageTypeShare];
        msg.content = Localized(@"JX_[Link]");
        
        NSDictionary *dict = @{
                               @"url" : [self subString:self.urlStr withString:@"url"],
                               @"downloadUrl" : [self subString:self.urlStr withString:@"downloadUrl"],
                               @"title" : [self subString:self.urlStr withString:@"title"],
                               @"subTitle" : [self subString:self.urlStr withString:@"subTitle"],
                               @"imageUrl" : [self subString:self.urlStr withString:@"imageUrl"],
                               @"appName" : [self subString:self.urlStr withString:@"appName"],
                               @"appIcon" : [self subString:self.urlStr withString:@"appIcon"],
                               @"urlSchemes" : [self subString:self.urlStr withString:@"urlSchemes"]
                               };
        
        
        msg.objectId = [dict mj_JSONString];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (g_xmpp.isLogined != login_status_yes) {
                
                self.isShare = YES;
            }else {
                self.relayVC = [[WH_JXRelay_WHVC alloc] init];
                self.relayVC.isShare = YES;
                self.relayVC.shareSchemes = [self subString:self.urlStr withString:@"urlSchemes"];
                NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
                self.relayVC.relayMsgArray = array;
                UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
                [lastVC presentViewController:self.relayVC animated:YES completion:nil];
            }
            
        });
        
    }
    
    if ([aDownload.action isEqualToString:wh_act_PayGetOrderInfo]) {
        
        self.skPayDic = [dict copy];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            WH_JXSkPay_WHVC *vc = [[WH_JXSkPay_WHVC alloc] init];
            vc.payDic = [dict copy];
            vc.delegate = self;
            UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
            [lastVC presentViewController:vc animated:YES completion:nil];
//        });
    }
    
    if ([aDownload.action isEqualToString:wh_act_PayPasswordPayment]) {
        
        [self WH_dismiss_WHVerifyPayVC];
        [g_server showMsg:@"支付成功" delay:.5];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时

    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{

}

@end
