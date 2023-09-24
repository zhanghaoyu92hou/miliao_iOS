//
//  downloadTasks.m
//  sjvodios
//
//  Created by  on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WH_VersionManageTool.h"
#import "AppDelegate.h"
#import "WH_JXConnection.h"
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudCore.h>
#import "RSA.h"
#import <JitsiMeet/JitsiMeet.h>
#import "WH_AppVersionUpdate.h"

@interface WH_VersionManageTool ()<QCloudSignatureProvider>

@end
@implementation WH_VersionManageTool

//remark = [NSString stringWithContentsOfFile:file encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:nil];//改变乱码为中文


@synthesize ftpHost;
@synthesize ftpUsername;
@synthesize ftpPassword;

@synthesize buyUrl;
@synthesize helpUrl;
@synthesize softUrl;
@synthesize shareUrl;
@synthesize aboutUrl;

@synthesize version;
@synthesize theNewVersion;
@synthesize versionRemark;
@synthesize disableVersion;
@synthesize message;

@synthesize website;
@synthesize backUrl;
@synthesize apiUrl;
@synthesize uploadUrl;
@synthesize downloadUrl;
@synthesize downloadAvatarUrl;
@synthesize XMPPDomain;
@synthesize meetingHost;
@synthesize lastLoginType;
@synthesize money_login;
@synthesize money_share;
@synthesize money_intro;
@synthesize money_videoMeeting;
@synthesize money_audioMeeting;
@synthesize isCanChange;

@synthesize uploadMaxSize;
@synthesize videoMaxLen;
@synthesize audioMaxLen;

@synthesize isThirdPartyLogins;

-(id)init{
    self = [super init];
    [self getDefaultValue];
    return self;
}

-(void)dealloc{
    self.apiUrl = nil;
    self.uploadUrl = nil;
    self.downloadAvatarUrl = nil;
    self.downloadUrl = nil;
    self.version   = nil;
    self.ftpHost = nil;
    self.ftpUsername = nil;
    self.ftpPassword = nil;
    self.shareUrl = nil;
    self.buyUrl = nil;
    self.helpUrl = nil;
    self.aboutUrl = nil;
    self.XMPPDomain = nil;
    self.meetingHost = nil;
    self.buyUrl = nil;
    self.helpUrl = nil;
    self.website = nil;
    self.jitsiServer = nil;
    self.fileValidTime = nil;
    //    [super dealloc];
}

-(void)showNewVersion{
    NSString *currentVersion = [self getVersion:version];
    if(theNewVersion != nil){
        if( [theNewVersion floatValue]> [currentVersion floatValue]){
            NSString* s=Localized(@"WH_VersionManageTool_Find");
            NSString *newVersion = [NSString stringWithFormat:@"%@",theNewVersion];
            NSString *temp = nil;
            NSMutableArray *array = [NSMutableArray array];
            for(int i =0; i < [newVersion length]; i++) {
                temp = [newVersion substringWithRange:NSMakeRange(i, 1)];
                [array addObject:temp];
            }
            newVersion = [array componentsJoinedByString:@"."];
            s = [NSString stringWithFormat:@"%@:%@",Localized(@"WH_VersionManageTool_Find"),newVersion];
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:Localized(@"WH_VersionManageTool_Find") message:s preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:Localized(@"JX_Update") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //转跳升级
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStoreString]];
            }];
            UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:Localized(@"JX_Cencal") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if(g_config.block)
                    g_config.block();
                
            }];
            
            [alert addAction:action];
            [alert addAction:actionCancel];
            
            [g_App.window.rootViewController  presentViewController:alert animated:YES completion:nil];
        }else{
            if(g_config.block)
                g_config.block();
        }
    }
    
}
//版本已被禁用
-(void)showDisableUse{
//    NSString* s=[NSString stringWithFormat:@"%@;",version];
//    if(disableVersion)
//        if( [disableVersion rangeOfString:s].location != NSNotFound )
//            [g_App showAlert:Localized(@"WH_VersionManageTool_Sorry")];
    NSString *banVer = [g_default objectForKey:@"ban_current_version"];
    if (!banVer || ![self.iosDisable isEqualToString:banVer]) {
        [g_default setObject:self.iosDisable forKey:@"ban_current_version"];
    }
    
    NSString *curVersion = [self.version stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *banVersion = [self.iosDisable stringByReplacingOccurrencesOfString:@"." withString:@""];
    if ([curVersion intValue] <= [banVersion intValue]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"WH_VersionManageTool_Find") message:Localized(@"JX_BanUserCurrentVersion") preferredStyle:UIAlertControllerStyleAlert];
        [g_App.window.rootViewController  presentViewController:alert animated:NO completion:nil];
    }
    
    
    
}

-(void)showServerMsg {
    //    message = @"通知：新版本";
    if([message length]<=0)
        return;
    NSString* s=[docFilePath stringByAppendingPathComponent:@"messages.txt"];
    @try {
        if([[NSFileManager defaultManager]fileExistsAtPath:s])
            _msg = [[NSMutableDictionary alloc] initWithContentsOfFile:s];
        if(_msg == nil)
            _msg = [[NSMutableDictionary alloc]init];
        
        if([_msg objectForKey:message]==nil){
            [g_App showAlert:message];
            [_msg setObject:@"1" forKey:message];
            [_msg writeToFile:s atomically:YES];
        }
        //        [_msg release];
    }
    @catch (NSException *exception) {
    }
}
- (void)setLastLoginType:(NSNumber *)loginType {
    lastLoginType = loginType;
    [[NSUserDefaults standardUserDefaults] setObject:lastLoginType forKey:@"LastLoginType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSNumber *)lastLoginType {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"LastLoginType"];
}

- (void)getDataWithDict:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    g_App.isShowRedPacket = [dict objectForKey:@"displayRedPacket"];
    //        g_App.isShowRedPacket = [NSString stringWithFormat:@"0"];
    NSDictionary* p = [dict objectForKey:@"ios"];
    self.isDelAfterReading = [NSString stringWithFormat:@"%@", [dict objectForKey:@"isDelAfterReading"]];
    self.theNewVersion = [dict objectForKey:@"iosVersion"];
    self.versionRemark = [p objectForKey:@"versionRemark"];
    self.disableVersion = [p objectForKey:@"disableVersion"];
    self.message = [p objectForKey:@"message"];
    
    p = [dict objectForKey:@"money"];
    self.money_audioMeeting = [[p objectForKey:@"audioMeeting"] intValue];
    self.money_videoMeeting = [[p objectForKey:@"videoMeeting"] intValue];
    self.money_intro = [[p objectForKey:@"intro"] intValue];
    self.money_login = [[p objectForKey:@"login"] intValue];
    self.money_share = [[p objectForKey:@"share"] intValue];
    self.videoMaxLen = [[p objectForKey:@"videoMaxLen"] intValue];
    self.audioMaxLen = [[p objectForKey:@"audioMaxLen"] intValue];
    self.isCanChange = [[p objectForKey:@"isCanChange"] boolValue];
    p = dict;
    
    if ([p objectForKey:@"isNodesStatus"]) {
        self.isNodesStatus = [p objectForKey:@"isNodesStatus"];
    }
    if ([p objectForKey:@"isOpenRegister"]) {
          self.isOpenRegister = [p objectForKey:@"isOpenRegister"];
      }
    if ([p objectForKey:@"nodesInfoList"]) {
        self.nodesInfoList = [p objectForKey:@"nodesInfoList"];
    }
    
    if([p objectForKey:@"ftpHost"])
        self.ftpHost = [p objectForKey:@"ftpHost"];
    if([p objectForKey:@"ftpUsername"])
        self.ftpUsername = [p objectForKey:@"ftpUsername"];
    if([p objectForKey:@"ftpPassword"])
        self.ftpPassword = [p objectForKey:@"ftpPassword"];
    if([p objectForKey:@"backUrl"])
        self.backUrl = [p objectForKey:@"resumeBaseUrl"];
    if([p objectForKey:@"buyUrl"])
        self.buyUrl = [p objectForKey:@"buyUrl"];
    if([p objectForKey:@"helpUrl"])
        self.helpUrl = [p objectForKey:@"helpUrl"];
    if([p objectForKey:@"softUrl"])
        self.softUrl = [p objectForKey:@"softUrl"];
    if([p objectForKey:@"shareUrl"])
        self.shareUrl = [p objectForKey:@"shareUrl"];
    if([p objectForKey:@"uploadUrl"]) {
        self.uploadUrl = [p objectForKey:@"uploadUrl"];
        [share_defaults setObject:self.uploadUrl forKey:kUploadUrl];
    }
    if ([p objectForKey:@"osType"]) {
        self.osType = [NSString stringWithFormat:@"%@",[p objectForKey:@"osType"]];
    }
    if ([p objectForKey:@"osAppId"]) {
        self.osAppId = [p objectForKey:@"osAppId"];
    }
    if ([p objectForKey:@"isOpenOSStatus"]) {
        self.isOpenOSStatus = [p objectForKey:@"isOpenOSStatus"];
    }
    if ([p objectForKey:@"accessSecretKey"]) {
        self.accessSecretKey = [p objectForKey:@"accessSecretKey"];
    }
    if ([p objectForKey:@"accessKeyId"]) {
        self.accessKeyId = [p objectForKey:@"accessKeyId"];
    }
    if ([p objectForKey:@"bucketName"]) {
        self.bucketName = [p objectForKey:@"bucketName"];
    }
    if ([p objectForKey:@"endPoint"]) {
        self.endPoint = [p objectForKey:@"endPoint"];
    }
    if ([p objectForKey:@"location"]) {
        self.location = [p objectForKey:@"location"];
    }
    
    if([p objectForKey:@"downloadUrl"])
        self.downloadUrl = [p objectForKey:@"downloadUrl"];
    if([p objectForKey:@"downloadAvatarUrl"]) {
        self.downloadAvatarUrl = [p objectForKey:@"downloadAvatarUrl"];
        [share_defaults setObject:self.downloadAvatarUrl forKey:kDownloadAvatarUrl];
    }
    
    // 默认连接xmpp配置
    if([p objectForKey:@"XMPPDomain"]){
        self.XMPPDomain = [p objectForKey:@"XMPPDomain"];
    }
    if([p objectForKey:@"XMPPHost"]){
        self.XMPPHost = [p objectForKey:@"XMPPHost"];
    }
    self.XMPPHostPort = 5222;
    
    // 上次登陆的节点
    NSString *xmpphost = [g_default objectForKey:kLastXmppHostUrl];
    NSInteger xmpphostPort = [g_default integerForKey:kLastXmppHostPort];
    
    if ([self.nodesInfoList isKindOfClass:[NSArray class]] && self.nodesInfoList.count) {
        // 默认连接xmpp节点列表中第一个节点
        self.XMPPHost = [self.nodesInfoList firstObject][@"nodeIp"];
        self.XMPPHostPort = [[NSString stringWithFormat:@"%@",[self.nodesInfoList firstObject][@"nodePort"]] integerValue];
        
        if (xmpphost && [xmpphost isKindOfClass:[NSString class]] && xmpphost.length) {
            for (id node in self.nodesInfoList) {
                if ([node[@"nodeIp"] isEqual:xmpphost]) {
                    // 上次连接的节点如果还可用, 还是使用上次的节点连接
                    self.XMPPHost = xmpphost;
                    self.XMPPHostPort = xmpphostPort;
                    break;
                }
            }
        }
    }
    
    
//    if (xmpphost && [xmpphost isKindOfClass:[NSString class]] && xmpphost.length) {
//        self.XMPPHost = xmpphost;
//    }else{
//        if ([self.nodesInfoList isKindOfClass:[NSArray class]] && self.nodesInfoList.count) {
//
//            self.XMPPHost = [self.nodesInfoList firstObject][@"nodeIp"];
//
//        }else{
//            if([p objectForKey:@"XMPPHost"]){
//                self.XMPPHost = [p objectForKey:@"XMPPHost"];
//            }
//        }
//
//    }
//    if (xmpphostPort) {
//        self.XMPPHostPort =xmpphostPort;
//    }else{
//        if ([self.nodesInfoList isKindOfClass:[NSArray class]] && self.nodesInfoList.count) {
//            NSString *xmpphostPort = [NSString stringWithFormat:@"%@",[self.nodesInfoList firstObject][@"nodePort"]];
//            self.XMPPHostPort = [xmpphostPort integerValue];
//        }else{
//            self.XMPPHostPort = 5222;
//        }
//    }
    
    NSLog(@"加载xmpp配置 %@:%ld",self.XMPPHost,self.XMPPHostPort);
    
    if([p objectForKey:@"meetingHost"]){
        self.meetingHost = [p objectForKey:@"meetingHost"];
    }
    if([p objectForKey:@"website"])
        self.website = [p objectForKey:@"website"];
    if ([p objectForKey:@"jitsiServer"]) {
        self.jitsiServer = [p objectForKey:@"jitsiServer"];
        
        /// Initialize default options for joining conferences.
        JitsiMeetConferenceOptions *defaultOptions
            = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
                builder.serverURL = [NSURL URLWithString:self.jitsiServer];
                builder.welcomePageEnabled = NO;
            }];
        [JitsiMeet sharedInstance].defaultConferenceOptions = defaultOptions;
    }
    if ([p objectForKey:@"fileValidTime"]) {
        self.fileValidTime = [p objectForKey:@"fileValidTime"];
    }
    if ([p objectForKey:@"XMPPTimeout"]) {
        self.XMPPTimeout = [[p objectForKey:@"XMPPTimeout"] intValue];
    }
    if ([p objectForKey:@"xmppPingTime"]) {
        self.XMPPPingTime = [[p objectForKey:@"xmppPingTime"] intValue];
    }
    if ([p objectForKey:@"isOpenSMSCode"]) {
        self.isOpenSMSCode = [p objectForKey:@"isOpenSMSCode"];
    }
    if ([p objectForKey:@"isOpenReceipt"]) {
        self.isOpenReceipt = [p objectForKey:@"isOpenReceipt"];
    }
    if ([p objectForKey:@"iosDisable"]) {
        self.iosDisable = [p objectForKey:@"iosDisable"];
    }
    if ([p objectForKey:@"isOpenCluster"]) {
        self.isOpenCluster = [p objectForKey:@"isOpenCluster"];
    }
    if ([p objectForKey:@"appleId"]) {
        self.appleId = [p objectForKey:@"appleId"];
    }
    if ([p objectForKey:@"companyName"]) {
        self.companyName = [p objectForKey:@"companyName"];
    }
    if ([p objectForKey:@"copyright"]) {
        self.copyright = [p objectForKey:@"copyright"];
    }
    if ([p objectForKey:@"hideSearchByFriends"]) {
        self.hideSearchByFriends = [p objectForKey:@"hideSearchByFriends"];
    }
    if ([p objectForKey:@"nicknameSearchUser"]) {
        self.nicknameSearchUser = [p objectForKey:@"nicknameSearchUser"];
    }
    if ([p objectForKey:@"regeditPhoneOrName"]) {
        self.regeditPhoneOrName = [p objectForKey:@"regeditPhoneOrName"];
        
//        self.regeditPhoneOrName = @0;
    }
    if ([p objectForKey:@"registerInviteCode"]) {
        self.registerInviteCode = [p objectForKey:@"registerInviteCode"];
//        self.registerInviteCode = @1;
    }
    if ([p objectForKey:@"isCommonFindFriends"]) {
        self.isCommonFindFriends = [p objectForKey:@"isCommonFindFriends"];
    }
    if ([p objectForKey:@"isCommonCreateGroup"]) {
        self.isCommonCreateGroup = [p objectForKey:@"isCommonCreateGroup"];
    }
    if ([p objectForKey:@"isOpenPositionService"]) {
        self.isOpenPositionService = [p objectForKey:@"isOpenPositionService"];
    }
    //        [self performSelectorOnMainThread:@selector(showNewVersion) withObject:nil waitUntilDone:NO];
    if ([p objectForKey:@"headBackgroundImg"]) {
        self.headBackgroundImg = [p objectForKey:@"headBackgroundImg"];
    }
    
    if ([p objectForKey:@"isThirdPartyLogins"]) {
        self.isThirdPartyLogins = [p objectForKey:@"isThirdPartyLogins"];
    }
    if ([p objectForKey:@"isQestionOpen"]) {
        self.isQestionOpen = [p objectForKey:@"isQestionOpen"];
    }

    if ([self.isOpenOSStatus integerValue] && [self.osType integerValue]==2) {
        
        QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
        configuration.appID = g_config.osAppId;
//        configuration.appID = @"1259280364";
        configuration.signatureProvider = self;
        QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
        endpoint.regionName = g_config.location;//服务地域名称，可用的地域请参考注释
        configuration.endpoint = endpoint;
        
        [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
        [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
    }
    
    if ([p objectForKey:@"tabBarConfigList"]) {
        self.tabBarConfigList = [p objectForKey:@"tabBarConfigList"];
    }
    
    if ([p objectForKey:@"isWithdrawToAdmin"]) {
        self.isWithdrawToAdmin = [p objectForKey:@"isWithdrawToAdmin"];
    }
    
    if ([p objectForKey:@"minWithdrawToAdmin"]) {
        self.minWithdrawToAdmin = [NSString stringWithFormat:@"%@",[p objectForKey:@"minWithdrawToAdmin"]];
    }
    
    if ([p objectForKey:@"uploadMaxSize"]) {
        self.uploadMaxSize = [[p objectForKey:@"uploadMaxSize"] intValue];
        if (self.uploadMaxSize <= 0) {
            //默认文件限制40M
            self.uploadMaxSize = 40;
        }
    } else {
        //默认文件限制40M
        self.uploadMaxSize = 40;
    }
    
    if ([p objectForKey:@"isUserSignRedPacket"]) {
        self.isUserSignRedPacket = [p objectForKey:@"isUserSignRedPacket"];
    }
    
    if ([p objectForKey:@"transferRate"]) {
        self.transferRate = [p objectForKey:@"transferRate"];
    }
    
    if ([p objectForKey:@"yunPayStatus"]) {
        self.yunPayStatus = [p objectForKey:@"yunPayStatus"];
    }
    
    if ([p objectForKey:@"aliPayStatus"]) {
        self.aliPayStatus = [p objectForKey:@"aliPayStatus"] ;
    }
    
    if ([p objectForKey:@"hmPayStatus"]) {
        self.hmPayStatus = [p objectForKey:@"hmPayStatus"];
    }
    
    if ([p objectForKey:@"hmWithdrawStatus"]) {
        self.hmWithdrawStatus = [p objectForKey:@"hmWithdrawStatus"];
    }
    
    if ([p objectForKey:@"aliWithdrawStatus"]) {
        self.aliWithdrawStatus = [p objectForKey:@"aliWithdrawStatus"] ;
    }
    if ([p objectForKey:@"wechatPayStatus"]) {
        self.wechatPayStatus = [p objectForKey:@"wechatPayStatus"] ;
    }
    if ([p objectForKey:@"wechatWithdrawStatus"]) {
        self.wechatWithdrawStatus = [p objectForKey:@"wechatWithdrawStatus"] ;
    }
    
    
    //第三方登录是否开启
    if ([p objectForKey:@"aliLoginStatus"]) {//!< 支付宝登录状态：1：开启 2：关闭
        self.aliLoginStatus = [p objectForKey:@"aliLoginStatus"] ;
    }
    
    if ([p objectForKey:@"qqLoginStatus"]) {//!< 支付宝登录状态：1：开启 2：关闭
        self.qqLoginStatus = [p objectForKey:@"qqLoginStatus"] ;
    }
    
    if ([p objectForKey:@"wechatLoginStatus"]) {//!< 支付宝登录状态：1：开启 2：关闭
        self.wechatLoginStatus = [p objectForKey:@"wechatLoginStatus"] ;
    }
    
    if ([p objectForKey:@"isOpenTwoBarCode"]) {
        self.isOpenTwoBarCode = [p objectForKey:@"isOpenTwoBarCode"];
    }
    
    if ([p objectForKey:@"isOpenTelnum"]) {
        self.isOpenTelnum = [p objectForKey:@"isOpenTelnum"];
    }
    
    if ([p objectForKey:@"isAudioStatus"]) {
        self.isAudioStatus = [p objectForKey:@"isAudioStatus"];
    }
    
    if ([p objectForKey:@"maxSendRedPagesAmount"]) {
        self.maxSendRedPagesAmount = [p objectForKey:@"maxSendRedPagesAmount"];
    }
    
    self.wechatAppId = p[@"wechatLoginAppId"] ?: @"";
    self.qqLoginAppId = p[@"qqLoginAppId"] ?: @"";
    
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDg/CxgoI8m6EXa6QJsleT1k+X6Cg2cGC2aS9il05kW7zfIgoIUwqGO6EXlcIWsRFgJQWvxS94vtbbCWqC9Os4SvfazikT8TmyQtCNnfGSqM7eZKql/jR6XAGBEN4OIQOrtb8GdO4PSpi5NhBziaGEGeSC4LmmolFic9Fm6FHYD4wIDAQAB\n-----END PUBLIC KEY-----";
    if (IsStringNull(g_config.accessKeyId)) {
        return;
    }
    NSString *access_key_id = [RSA decryptString:g_config.accessKeyId publicKey:pubkey];
    NSString *access_secret_key = [RSA decryptString:g_config.accessSecretKey publicKey:pubkey];
    QCloudCredential *credenttial = [QCloudCredential new];
    credenttial.secretID = access_key_id;
    credenttial.secretKey = access_secret_key;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credenttial];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);
}

//
-(void)didReceive:(NSDictionary*)dict{
    @try {
        // 默认值赋值时，getDataWithDict方法中不赋值apiUrl
        if([dict objectForKey:@"apiUrl"]){
            self.apiUrl = [dict objectForKey:@"apiUrl"];
            [share_defaults setObject:self.apiUrl forKey:kApiUrl];
        }
        [self getDataWithDict:dict];
        [self showDisableUse];
        [self showServerMsg];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
//            [self showNewVersion];
            [[WH_AppVersionUpdate shared] checkVersion];
        });
        //[self getNewVersion:version];
        
        // 保存这一次成功的IP
        [g_default setObject:self.apiUrl forKey:kLastApiUrl];
        [g_default synchronize];
    }
    @catch (NSException *exception){
        
    }
    @finally {
        
    }
}
//转换格式进行对比
- (NSString *)getVersion:(NSString *) phoneVersion{
    NSArray * numberArr = [phoneVersion componentsSeparatedByString:@"."];
    NSString * numberVersion = [numberArr componentsJoinedByString:@""];
//    version = [numberVersion substringToIndex:3];
    return [numberVersion substringToIndex:numberVersion.length];
}

//- (NSString *)getConfigDefault:(NSString *)url {
//    NSString* defApiUrl = @"http://服务器主机或域名:8092/config";
//    NSString* defCfgStr = @"{\"currentTime\":1615479996498,\"data\":{\"PCXMPPDomain\":\"服务器主机或域名\",\"PCXMPPHost\":\"xx.xx.xx\",\"XMPPDomain\":\"服务器主机或域名\",\"XMPPHost\":\"xx.xx.xx\",\"XMPPTimeout\":180,\"address\":\"CN\",\"aliLoginStatus\":2,\"aliPayStatus\":2,\"aliWithdrawStatus\":2,\"androidAppUrl\":\"\",\"androidDisable\":\"\",\"androidExplain\":\"\",\"androidVersion\":0,\"apiUrl\":\"http://api.服务器主机或域名/\",\"appleId\":\"\",\"audioLen\":\"20\",\"chatRecordTimeOut\":-1,\"copyrightInfo\":\"\",\"cusServerUrl\":\"\",\"displayRedPacket\":1,\"distance\":20,\"downloadAvatarUrl\":\"http://upload.服务器主机或域名/\",\"downloadUrl\":\"http://upload.服务器主机或域名/\",\"fileValidTime\":-1,\"guideWebsite\":\"\",\"headBackgroundImg\":\"\",\"helpUrl\":\"\",\"hideSearchByFriends\":1,\"hmPayStatus\":2,\"hmWithdrawStatus\":2,\"invisibleList\":[],\"iosAppUrl\":\"\",\"iosDisable\":\"\",\"iosExplain\":\"\",\"iosVersion\":0,\"ipAddress\":\"144.48.190.188\",\"isAudioStatus\":0,\"isCommonCreateGroup\":0,\"isCommonFindFriends\":0,\"isDelAfterReading\":0,\"isDiscoverStatus\":1,\"isEnableCusServer\":1,\"isNodesStatus\":1,\"isOpenCluster\":0,\"isOpenDHRecharge\":1,\"isOpenGoogleFCM\":0,\"isOpenOSStatus\":0,\"isOpenPositionService\":1,\"isOpenReadReceipt\":1,\"isOpenReceipt\":1,\"isOpenRegister\":1,\"isOpenSMSCode\":1,\"isOpenTelnum\":1,\"isOpenTwoBarCode\":1,\"isQestionOpen\":0,\"isTabBarStatus\":1,\"isUserSignRedPacket\":0,\"isWeiBaoStatus\":0,\"isWithdrawToAdmin\":0,\"jiGuangStatus\":2,\"jitsiServer\":\"\",\"liveUrl\":\"\",\"macAppUrl\":\"\",\"macDisable\":\"\",\"macExplain\":\"\",\"macVersion\":0,\"maxSendRedPagesAmount\":500,\"minTransferAmount\":0,\"minWithdrawToAdmin\":0,\"nicknameSearchUser\":1,\"nodesInfoList\":[{\"hostSocks\":\"\",\"id\":\"6048ae9c58a65daf03de8790\",\"isSocks\":0,\"nodeIp\":\"服务器主机或域名\",\"nodeName\":\"国际\",\"nodePort\":\"5222\",\"passSocks\":\"\",\"postSocks\":\"\",\"realmName\":\"服务器主机或域名\",\"status\":1,\"userSocks\":\"\"},{\"hostSocks\":\"\",\"id\":\"6048d0e958a65daf03df05b6\",\"isSocks\":0,\"nodeIp\":\"124.71.215.49\",\"nodeName\":\"国内\",\"nodePort\":\"5222\",\"passSocks\":\"\",\"postSocks\":\"\",\"realmName\":\"124.71.215.49\",\"status\":1,\"userSocks\":\"\"}],\"pCXMPPDomain\":\"服务器主机或域名\",\"pCXMPPHost\":\"xx.xx.xx\",\"pcAppUrl\":\"\",\"pcDisable\":\"\",\"pcExplain\":\"\",\"pcVersion\":0,\"popularAPP\":\"{\\\"lifeCircle\\\":1,\\\"videoMeeting\\\":1,\\\"liveVideo\\\":1,\\\"shortVideo\\\":1,\\\"peopleNearby\\\":1,\\\"scan\\\":1}\",\"projectIco\":\"\",\"projectLogo\":\"\",\"projectName\":\"演示产品\",\"qqLoginStatus\":2,\"regeditPhoneOrName\":1,\"registerInviteCode\":0,\"shareUrl\":\"\",\"showContactsUser\":0,\"softUrl\":\"\",\"tabBarConfigList\":{\"tabBarNum\":0,\"tabBarStatus\":0},\"tlPayStatus\":2,\"tlWithdrawStatus\":2,\"transferRate\":0,\"uploadMaxSize\":20,\"uploadUrl\":\"http://服务器主机或域名:8088/\",\"videoLen\":\"20\",\"webDownloadUrl\":\"\",\"webNewUrl\":\"\",\"website\":\"\",\"wechatH5LoginStatus\":2,\"wechatLoginStatus\":2,\"wechatPayStatus\":2,\"wechatWithdrawStatus\":2,\"weiBaoMaxRedPacketAmount\":0,\"weiBaoMaxTransferAmount\":0,\"weiBaoMinTransferAmount\":0,\"weiBaoTransferRate\":0,\"weiPayStatus\":2,\"weiWithdrawStatus\":2,\"xMPPDomain\":\"服务器主机或域名\",\"xMPPHost\":\"xx.xx.xx\",\"xMPPTimeout\":180,\"xmppPingTime\":72,\"yunPayStatus\":2,\"yunWithdrawStatus\":2},\"resultCode\":1}";
//    NSString* defApiUrl = @"http://changquhuyu.cn:80"; //@"http://47.99.32.196:8092/config";
//    NSString* defCfgStr = @"{\"currentTime\":1615479996498,\"data\":{\"PCXMPPDomain\":\"服务器主机或域名\",\"PCXMPPHost\":\"xx.xx.xx\",\"XMPPDomain\":\"服务器主机或域名\",\"XMPPHost\":\"xx.xx.xx\",\"XMPPTimeout\":180,\"address\":\"CN\",\"aliLoginStatus\":2,\"aliPayStatus\":2,\"aliWithdrawStatus\":2,\"androidAppUrl\":\"\",\"androidDisable\":\"\",\"androidExplain\":\"\",\"androidVersion\":0,\"apiUrl\":\"http://api.服务器主机或域名/\",\"appleId\":\"\",\"audioLen\":\"20\",\"chatRecordTimeOut\":-1,\"copyrightInfo\":\"\",\"cusServerUrl\":\"\",\"displayRedPacket\":1,\"distance\":20,\"downloadAvatarUrl\":\"http://upload.服务器主机或域名/\",\"downloadUrl\":\"http://upload.服务器主机或域名/\",\"fileValidTime\":-1,\"guideWebsite\":\"\",\"headBackgroundImg\":\"\",\"helpUrl\":\"\",\"hideSearchByFriends\":1,\"hmPayStatus\":2,\"hmWithdrawStatus\":2,\"invisibleList\":[],\"iosAppUrl\":\"\",\"iosDisable\":\"\",\"iosExplain\":\"\",\"iosVersion\":0,\"ipAddress\":\"144.48.190.188\",\"isAudioStatus\":0,\"isCommonCreateGroup\":0,\"isCommonFindFriends\":0,\"isDelAfterReading\":0,\"isDiscoverStatus\":1,\"isEnableCusServer\":1,\"isNodesStatus\":1,\"isOpenCluster\":0,\"isOpenDHRecharge\":1,\"isOpenGoogleFCM\":0,\"isOpenOSStatus\":0,\"isOpenPositionService\":1,\"isOpenReadReceipt\":1,\"isOpenReceipt\":1,\"isOpenRegister\":1,\"isOpenSMSCode\":1,\"isOpenTelnum\":1,\"isOpenTwoBarCode\":1,\"isQestionOpen\":0,\"isTabBarStatus\":1,\"isUserSignRedPacket\":0,\"isWeiBaoStatus\":0,\"isWithdrawToAdmin\":0,\"jiGuangStatus\":2,\"jitsiServer\":\"\",\"liveUrl\":\"\",\"macAppUrl\":\"\",\"macDisable\":\"\",\"macExplain\":\"\",\"macVersion\":0,\"maxSendRedPagesAmount\":500,\"minTransferAmount\":0,\"minWithdrawToAdmin\":0,\"nicknameSearchUser\":1,\"nodesInfoList\":[{\"hostSocks\":\"\",\"id\":\"6048ae9c58a65daf03de8790\",\"isSocks\":0,\"nodeIp\":\"服务器主机或域名\",\"nodeName\":\"国际\",\"nodePort\":\"5222\",\"passSocks\":\"\",\"postSocks\":\"\",\"realmName\":\"服务器主机或域名\",\"status\":1,\"userSocks\":\"\"},{\"hostSocks\":\"\",\"id\":\"6048d0e958a65daf03df05b6\",\"isSocks\":0,\"nodeIp\":\"124.71.215.49\",\"nodeName\":\"国内\",\"nodePort\":\"5222\",\"passSocks\":\"\",\"postSocks\":\"\",\"realmName\":\"124.71.215.49\",\"status\":1,\"userSocks\":\"\"}],\"pCXMPPDomain\":\"服务器主机或域名\",\"pCXMPPHost\":\"xx.xx.xx\",\"pcAppUrl\":\"\",\"pcDisable\":\"\",\"pcExplain\":\"\",\"pcVersion\":0,\"popularAPP\":\"{\\\"lifeCircle\\\":1,\\\"videoMeeting\\\":1,\\\"liveVideo\\\":1,\\\"shortVideo\\\":1,\\\"peopleNearby\\\":1,\\\"scan\\\":1}\",\"projectIco\":\"\",\"projectLogo\":\"\",\"projectName\":\"演示产品\",\"qqLoginStatus\":2,\"regeditPhoneOrName\":1,\"registerInviteCode\":0,\"shareUrl\":\"\",\"showContactsUser\":0,\"softUrl\":\"\",\"tabBarConfigList\":{\"tabBarNum\":0,\"tabBarStatus\":0},\"tlPayStatus\":2,\"tlWithdrawStatus\":2,\"transferRate\":0,\"uploadMaxSize\":20,\"uploadUrl\":\"http://服务器主机或域名:8088/\",\"videoLen\":\"20\",\"webDownloadUrl\":\"\",\"webNewUrl\":\"\",\"website\":\"\",\"wechatH5LoginStatus\":2,\"wechatLoginStatus\":2,\"wechatPayStatus\":2,\"wechatWithdrawStatus\":2,\"weiBaoMaxRedPacketAmount\":0,\"weiBaoMaxTransferAmount\":0,\"weiBaoMinTransferAmount\":0,\"weiBaoTransferRate\":0,\"weiPayStatus\":2,\"weiWithdrawStatus\":2,\"xMPPDomain\":\"服务器主机或域名\",\"xMPPHost\":\"xx.xx.xx\",\"xMPPTimeout\":180,\"xmppPingTime\":72,\"yunPayStatus\":2,\"yunWithdrawStatus\":2},\"resultCode\":1}";
//    // 获取config默认值 （先网页上调config 接口获取值后，到http://www.bejson.com/ 转译json，则获取configUrlStr）
//
//    NSString *configUrlStr = [NSString string];
//    if ([url containsString:defApiUrl]) {
//
//       configUrlStr = defCfgStr;
//    }
//    return configUrlStr;
//}


-(void)getDefaultValue{
    NSString* defApiUrl = @"http://43.132.102.226:8092/config";
    //@"http://changquhuyu.cn:80/config"; //@"http://47.99.32.196:8092/config";

    self.version   = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];


    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:SERVER_LIST_DATA];
    if (array.firstObject) {
        self.apiUrl = array.firstObject;
    } else {
        self.apiUrl = defApiUrl;
        array = [[NSMutableArray alloc] initWithObjects:self.apiUrl, nil];
        [array writeToFile:SERVER_LIST_DATA atomically:YES];
    }
    
//====================
//    NSString *configUrlStr = [self getConfigDefault:self.apiUrl];
//
//    // json 转 字典
//    NSDictionary *dict = [configUrlStr mj_JSONObject];
//
//    // 设置默认值
//    [self getDataWithDict:[dict objectForKey:@"data"]];

//====================
    // 写死中间按钮
//    self.tabBarConfigList = @{
//        @"tabBarId": @"",
//        @"tabBarImg": @"",
//        @"tabBarImg1": @"",
//        @"tabBarLinkUrl": @"",
//        @"tabBarName": @"",
//        @"tabBarNum": @1,
//        @"tabBarStatus": @1,
//        @"tabBarUpdateTime": @1611219311
//    };

    self.XMPPTimeout = 180;  //xmpp超时时间 默认值180
    self.XMPPPingTime = 72;  //xmpp ping时间间隔 默认值72
}

/*
 易智付: 139.9.190.69
 Tigase: api.域名
 花聊: api.686520.com
 掌中彩: api.erwerew.com
 乐彩: api.lccp.me
 网宝: api. zgjc678.com
 玩聊: api.mhpc888.com
 商聊新服务器: api.chat6666.com
 蜂窝: api.fengwo88.com
 美言: api.szltnetwork.com
 云呼: api.987340.com
 Tigase新测试服务器: csapi.域名
 徽信: api.xzdysm.cn
 纸飞机: api.zhifeiji.im
 聊信: api.nesk.cn
 K聊2: api.kk22.vip
 酷通: api.zgswhs.com
 享聊: 159.138.55.19
 雪花本地IP: 10.10.10.124:8092
 趣聊呗：quliaobei.com

 */

@end
