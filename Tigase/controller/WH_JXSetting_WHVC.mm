//
//  myViewController.m
//  sjvodios
//
//  Created by  on 19-5-5-29.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import "WH_JXSetting_WHVC.h"
#import "WH_JXImageView.h"
#import "JXLabel.h"
#import "AppDelegate.h"
#import "JXServer.h"
#import "WH_JXConnection.h"
#import "UIFactory.h"
#import "JXTableView.h"
#import "WH_JXFriend_WHViewController.h"
#import "ImageResize.h"
#import "userWeiboVC.h"
#import "WH_myMedia_WHVC.h"
#import "WH_webpage_WHVC.h"
#import "WH_LoginViewController.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_forgetPwd_WHVC.h"
#import "WH_JXSelector_WHVC.h"
#import "WH_JXSetChatBackground_WHVC.h"
#import "WH_JXSetChatTextFont_WHVC.h"

#import "WH_PSRegisterBaseVC.h"
#import "photosViewController.h"
#import "WH_JXAbout_WHVC.h"
#import "WH_JXMessageObject.h"
#import "WH_JXMediaObject.h"
#import <StoreKit/StoreKit.h>
#import "WH_JXGroupMessagesSelectFriend_WHVC.h"
#import "WH_JXAccountBinding_WHVC.h"
#import "WH_JXSecuritySetting_WHVC.h"
#import "WH_LoginViewController.h"

#define HEIGHT 55

@interface WH_JXSetting_WHVC ()<WH_JXSelector_WHVCDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic, assign) NSInteger currentLanguageIndex;
@property (nonatomic, assign) NSInteger currentSkin;
@property (atomic,assign) BOOL reLogin;
@property (nonatomic, strong) UILabel *fileSizelab;

@end

@implementation WH_JXSetting_WHVC

- (id)init
{
    self = [super init];
    if (self) {

        self.wh_isGotoBack = YES;
        self.title = Localized(@"WaHu_JXSetting_WaHuVC_Set");
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
        self.wh_tableBody.scrollEnabled = YES;
        
        UIButton* btn;
        int h = 12;
        int w = JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset;
        
        UIView *clearView = [self bgViewWithOrginY:12 viewHeight:111];
        //清理缓存
        WH_JXImageView* iv;
        iv = [self WH_createMiXinButton:Localized(@"WaHu_JXSetting_WaHuVC_ClearCache") drawTop:NO drawBottom:YES icon:nil click:@selector(onClear) superView:clearView];
        iv.frame = CGRectMake(0,0, clearView.frame.size.width, HEIGHT);
        
        self.fileSizelab = [[UILabel alloc] initWithFrame:CGRectMake((w)/2-29 , 0, (w)/2, HEIGHT)];
        self.fileSizelab.textColor = HEXCOLOR(0x969696);
        self.fileSizelab.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        self.fileSizelab.textAlignment = NSTextAlignmentRight;
        self.fileSizelab.text = [self folderSizeAtPath:tempFilePath];
        [iv addSubview:self.fileSizelab];
        
//        h+=iv.frame.size.height;
        
//        清理所有缓存
        iv = [self WH_createMiXinButton:Localized(@"JX_ClearAllChatRecords") drawTop:NO drawBottom:NO icon:nil click:@selector(onClearChatLog) superView:clearView];
        iv.frame = CGRectMake(0 ,HEIGHT, w, HEIGHT);
        h += clearView.frame.size.height + 12;
        
        //群发消息
        UIView *groupMessageView = [self bgViewWithOrginY:h viewHeight:55];
        iv = [self WH_createMiXinButton:Localized(@"JXGroupMessages") drawTop:NO drawBottom:YES icon:nil click:@selector(groupMessages) superView:groupMessageView];
        iv.frame = CGRectMake(0,0, w, HEIGHT);
        h += groupMessageView.frame.size.height + 12;
        
//        //隐私设置
//        iv = [self WH_createMiXinButton:Localized(@"JX_PrivacySettings") drawTop:NO drawBottom:YES icon:nil click:@selector(onSet)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
//        
//        //安全设置
//        iv = [self WH_createMiXinButton:Localized(@"JX_SecuritySettings") drawTop:NO drawBottom:YES icon:nil click:@selector(onSecuritySetting)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
        
//        iv = [self WH_createMiXinButton:Localized(@"WaHu_JXSetting_WHVC_Help") drawTop:NO drawBottom:YES icon:nil click:@selector(onHelp)];
//        iv.frame = CGRectMake(0,h, w, HEIGHT);
//        h+=iv.frame.size.height;
        
        //语言切换
        NSString *lang = g_constant.sysLanguage;
        NSString *currentLanguage;
        if ([lang isEqualToString:@"zh"]) {
            currentLanguage = @"简体中文";
            _currentLanguageIndex = 0;
            
        }else if ([lang isEqualToString:@"big5"]) {
            currentLanguage = @"繁體中文(香港)";
            _currentLanguageIndex = 1;
        }
        else {
            currentLanguage = @"English";
            _currentLanguageIndex = 2;
        }
        
//        UIView *languageView = [self bgViewWithOrginY:h viewHeight:111];
        UIView *languageView = [self bgViewWithOrginY:h viewHeight:55];
        iv = [self WH_createMiXinButton:Localized(@"JX_LanguageSwitching") drawTop:NO drawBottom:YES icon:nil click:@selector(languageSwitch) superView:languageView];
        
        UILabel *arrTitle = [[UILabel alloc] initWithFrame:CGRectMake(w/2 - 29, 0, w / 2, HEIGHT)];
        arrTitle.text = currentLanguage;
        arrTitle.textColor = HEXCOLOR(0x969696);
        arrTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        arrTitle.textAlignment = NSTextAlignmentRight;
        [iv addSubview:arrTitle];
        
        iv.frame = CGRectMake(0,0, w, HEIGHT);
//        h+=iv.frame.size.height;
        
        //切换皮肤
//        iv = [self WH_createMiXinButton:Localized(@"JXTheme_switch") drawTop:NO drawBottom:YES icon:nil click:@selector(changeSkin) superView:languageView];
//        UILabel *skinTitle = [[UILabel alloc] initWithFrame:CGRectMake(w/2 - 29, 13, w / 2, 20)];
//        skinTitle.text = g_theme.themeName;
//        skinTitle.textColor = HEXCOLOR(0x969696);
//        skinTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
//        skinTitle.textAlignment = NSTextAlignmentRight;
//        [iv addSubview:skinTitle];
//        iv.frame = CGRectMake(0, HEIGHT, w, HEIGHT);
        h += languageView.frame.size.height + 12;
        
        UIView *changeView = [self bgViewWithOrginY:h viewHeight:111];
        iv = [self WH_createMiXinButton:Localized(@"JX_SettingUpChatBackground") drawTop:NO drawBottom:YES icon:nil click:@selector(setChatBackground) superView:changeView];
        iv.frame = CGRectMake(0, 0, w, HEIGHT);
//        h += iv.frame.size.height;
        
        //隐藏微信绑定
//        iv = [self WH_createMiXinButton:Localized(@"JX_AccountAndBindSettings") drawTop:NO drawBottom:YES icon:nil click:@selector(setAccountBinding)];
//        iv.frame = CGRectMake(0, h, w, HEIGHT);
//        h += iv.frame.size.height;
        
        iv = [self WH_createMiXinButton:Localized(@"JX_ChatFonts") drawTop:NO drawBottom:NO icon:nil click:@selector(setChatTextFont) superView:changeView];
        iv.frame = CGRectMake(0, HEIGHT, w, HEIGHT);
        h += changeView.frame.size.height+12;
        
        UIView *updatePsdView = [self bgViewWithOrginY:h viewHeight:HEIGHT];
        iv = [self WH_createMiXinButton:Localized(@"JX_UpdatePassWord") drawTop:YES drawBottom:YES icon:nil click:@selector(onForgetPassWord) superView:updatePsdView];
        iv.frame = CGRectMake(0, 0, w, HEIGHT);
        h += updatePsdView.frame.size.height+12;

        if (THE_APP_OUR) {
            UIView *view = [self bgViewWithOrginY:h viewHeight:111];
            iv = [self WH_createMiXinButton:Localized(@"JXSettingViewController_Evaluate") drawTop:YES drawBottom:YES icon:nil click:@selector(webAppStoreBtnAction) superView:view];
            iv.frame = CGRectMake(0,0, w, HEIGHT);
//            h+=iv.frame.size.height+11;
            
//            iv = [self WH_createMiXinButton:Localized(@"WaHu_JXAbout_WHVC_AboutUS") drawTop:YES drawBottom:YES icon:nil click:@selector(onAbout) superView:view];
//            iv.frame = CGRectMake(0,HEIGHT, w, HEIGHT);
            h += view.frame.size.height+12;
        }
        
        UIView *aboutUs = [self bgViewWithOrginY:h viewHeight:HEIGHT];
        iv = [self WH_createMiXinButton:Localized(@"WaHu_AboutUs_WaHu") drawTop:YES drawBottom:YES icon:nil click:@selector(onAbout) superView:aboutUs];
        iv.frame = CGRectMake(0,0, w, HEIGHT);
        h += aboutUs.frame.size.height + 12;
        
        btn = [UIFactory WH_create_WHLogOutButton:Localized(@"WaHu_JXSetting_WaHuVC_LogOut") target:self action:@selector(onLogout)];
        [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
        btn.custom_acceptEventInterval = 1.f;
        btn.frame = CGRectMake(g_factory.globelEdgeInset,h, w, 44);
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        btn.backgroundColor = HEXCOLOR(0xED6350);
        [btn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = g_factory.cardCornerRadius;
        [self.wh_tableBody addSubview:btn];
        
        if (self.wh_tableBody.frame.size.height < (h + INSETS+HEIGHT)) {
            self.wh_tableBody.contentSize = CGSizeMake(0, h + INSETS+HEIGHT + 40);
        }
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"WH_JXSetting_WHVC.dealloc");
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)actionLogout{
    [self.view endEditing:YES];
    [_wait stop];
    
    [g_server stopConnection:self];
    
//    if ([self.delegate respondsToSelector:@selector(admobDidQuit)]) {
//        [self.delegate admobDidQuit];
//    }
    [self actionQuit];
//    [self.view removeFromSuperview];
//    _pSelf = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if( [aDownload.action isEqualToString:wh_act_UserLogout] ){
//        [g_server closeSecondFeedOff:self];
        if (self.reLogin) {
//            [g_notify postNotificationName:kLogOutNotifaction object:nil];
//            [g_default setObject:nil forKey:kMY_USER_TOKEN];
//            g_server.access_token = nil;
            
            
            
            self.reLogin = NO;
            [self relogin];
//            g_mainVC = nil;

//            [JXMyTools showTipView:Localized(@"SignOuted")];
//            
//            [[JXXMPP sharedInstance] logout];
//            [self actionLogout];
//            [self admobDidQuit];
            return;
        }
        [self performSelector:@selector(doSwitch) withObject:nil afterDelay:1];
        
    }else if ([aDownload.action isEqualToString:wh_act_Settings]){
        
        //跳转新的页面
        WH_JXSettings_WHViewController* vc = [[WH_JXSettings_WHViewController alloc]init];
        vc.dataSorce = dict;
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        [_wait stop];
    }
    if ([aDownload.action isEqualToString:wh_act_EmptyMsg]){
        [g_App showAlert:Localized(@"JX_ClearSuccess")];
    }

}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    if( [aDownload.action isEqualToString:wh_act_UserLogout] ){
        [self performSelector:@selector(doSwitch) withObject:nil afterDelay:1];
    }
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_UserLogout]) {
        return WH_hide_error;
    }
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

-(void)onClear{
    [g_App showAlert:Localized(@"JX_ConfirmClearData") delegate:self tag:1345 onlyConfirm:NO];
}

// 清除所有聊天记录
- (void) onClearChatLog {
    [g_App showAlert:Localized(@"JX_ConfirmClearAllLogs") delegate:self tag:1134 onlyConfirm:NO];
}


// 群发消息
- (void)groupMessages {
    
    WH_JXGroupMessagesSelectFriend_WHVC *vc = [[WH_JXGroupMessagesSelectFriend_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

//切换皮肤主题
-(void)changeSkin{
    WH_JXSelector_WHVC *vc = [[WH_JXSelector_WHVC alloc] init];
    vc.title = Localized(@"JXTheme_choose");
    vc.WH_array = g_theme.skinNameList;
    vc.WH_selectIndex = g_theme.themeIndex;
    vc.wh_selectorDelegate = self;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

// 设置聊天背景
- (void)setChatBackground{
    
    WH_JXSetChatBackground_WHVC *vc = [[WH_JXSetChatBackground_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 账号和绑定设置
- (void)setAccountBinding {
    WH_JXAccountBinding_WHVC *bindVC = [[WH_JXAccountBinding_WHVC alloc] init];
    [g_navigation pushViewController:bindVC animated:YES];
}

// 聊天字体
- (void)setChatTextFont {
    WH_JXSetChatTextFont_WHVC *vc = [[WH_JXSetChatTextFont_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 切换语言
- (void)languageSwitch {
    NSString *lang = g_constant.sysLanguage;
    if ([lang isEqualToString:@"zh"]) {
        _currentLanguageIndex = 0;
    }else if ([lang isEqualToString:@"big5"]) {
        _currentLanguageIndex = 1;
    }else {
        _currentLanguageIndex = 2;
    }
    WH_JXSelector_WHVC *vc = [[WH_JXSelector_WHVC alloc] init];
    vc.title = Localized(@"JX_SelectLanguage");
    vc.WH_array = @[@"简体中文", @"繁體中文(香港)", @"English"];
//    vc.array = @[@"简体中文", @"繁體中文(香港)", @"English",@"Bahasa Melayu",@"ภาษาไทย"];
    vc.WH_selectIndex = _currentLanguageIndex;
    vc.wh_selectorDelegate = self;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}
- (void)selector:(WH_JXSelector_WHVC *)selector selectorAction:(NSInteger)selectIndex {
 
    if ([selector.title isEqualToString:Localized(@"JX_SelectLanguage")]) {
        self.currentLanguageIndex = selectIndex;
        [g_App showAlert:Localized(@"JX_SwitchLanguageNeed") delegate:self tag:3333 onlyConfirm:NO];
    }else{
        self.currentSkin = selectIndex;
        [g_App showAlert:Localized(@"JXTheme_confirm") delegate:self tag:4444 onlyConfirm:NO];
    }

    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 3333 && buttonIndex == 1) {
        
        NSString *currentLanguage;
        
        switch (self.currentLanguageIndex) {
            case 0:
                
                currentLanguage = @"zh";
                break;
            case 1:
                
                currentLanguage = @"big5";
                break;
            case 2:
                
                currentLanguage = @"en";
                break;
            case 3:
                
                currentLanguage = @"malay";
                break;
            case 4:
                
                currentLanguage = @"th";
                break;
            default:
                break;
        }
        
        [g_default setObject:currentLanguage forKey:kLocalLanguage];
        [g_default synchronize];
        [g_constant resetlocalized];
        
        self.reLogin = NO;
//        // 更新系统好友的显示
        [[WH_JXUserObject sharedUserInstance] WH_createSystemFriend];
//        [[WH_JXUserObject sharedUserInstance] createAddressBookFriend];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
//            [g_server logout:self];
            [self doLogout];
        });
    }else if (alertView.tag == 4444 && buttonIndex == 1) {
        [g_theme switchSkinIndex:self.currentSkin];
        [g_mainVC.view removeFromSuperview];
        g_mainVC = nil;
        [self.view removeFromSuperview];
        self.view = nil;
        g_navigation.lastVC = nil;
        [g_navigation.subViews removeAllObjects];
        [g_App showMainUI];
    }else if (alertView.tag == 1134 && buttonIndex == 1) {
        NSMutableArray* p = [[WH_JXMessageObject sharedInstance] fetchRecentChat];
        for (NSInteger i = 0; i < p.count; i ++) {
            WH_JXMsgAndUserObject *obj = p[i];
            if ([obj.user.userId isEqualToString:@"10000"] || [obj.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
                continue;
            }
            [obj.user reset];
            [obj.message deleteAll];
        }
        [g_server WH_emptyMsgWithTouserId:nil type:[NSNumber numberWithInt:1] toView:self];
        [g_notify postNotificationName:kDeleteAllChatLog_WHNotification object:nil];
    }else if (alertView.tag == 1345 && buttonIndex == 1) {
        [_wait start:Localized(@"JXAlert_ClearCache")];
        [FileInfo deleleFileAndDir:tempFilePath];
        // 录制的视频也会被清除，所以要清除视频记录表
        [[WH_JXMediaObject sharedInstance] deleteAll];
        self.fileSizelab.text = [self folderSizeAtPath:tempFilePath];
        [_wait performSelector:@selector(stop) withObject:nil afterDelay:1];
    }

}

- (NSString *)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return [NSString stringWithFormat:@"%.2fM",folderSize/(1024.0*1024.0)];
}

- (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


#pragma mark-----修改密码
- (void)onForgetPassWord{
    WH_forgetPwd_WHVC *forgetVC = [[WH_forgetPwd_WHVC alloc]init];
    forgetVC.wh_isModify = YES;
//    [g_App.window addSubview:forgetVC.view];
    [g_navigation pushViewController:forgetVC animated:YES];
}

- (void)onSet{
    
    // 获取设置状态
    [g_server WH_getFriendSettingsWithUserId:[NSString stringWithFormat:@"%ld",g_server.user_id] toView:self];
    
}

- (void)onSecuritySetting {
    
    WH_JXSecuritySetting_WHVC *vc = [[WH_JXSecuritySetting_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onLogout{
    [g_App showAlert:Localized(@"JXAlert_LoginOut") delegate:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 3333){
        
    }else if(alertView.tag == 4444){
        
    }else if(alertView.tag == 1134){
        
    }else if(alertView.tag == 1345){
        
    }else if(buttonIndex==1){
        //保存未读消息条数
        //        [g_notify postNotificationName:kSaveBadgeNotifaction object:nil];
        [self doLogout];
    }
}

-(void)doLogout {
    [g_server logout:g_myself.areaCode toView:self];
}

-(void)relogin{
//    [g_default removeObjectForKey:kMY_USER_PASSWORD];
//    [g_default setObject:nil forKey:kMY_USER_TOKEN];
    g_server.access_token = nil;
    [g_default setBool:YES forKey:kIsAutoLogin];
    [g_notify postNotificationName:kSystemLogout_WHNotifaction object:nil];
    [[JXXMPP sharedInstance] logout];
    NSLog(@"XMPP ---- WH_JXSetting_WHVC relogin");

     WH_LoginViewController* vc = [ WH_LoginViewController alloc];
    vc.isSwitchUser= NO;
    vc = [vc init];
    [g_mainVC.view removeFromSuperview];
    g_mainVC = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    vc.isPushEntering = YES;
    g_navigation.rootViewController = vc;
//    g_navigation.lastVC = nil;
//    [g_navigation.subViews removeAllObjects];
//    [g_navigation pushViewController:vc];
//    g_App.window.rootViewController = vc;
//    [g_App.window makeKeyAndVisible];
    
//     WH_LoginViewController* vc = [ WH_LoginViewController alloc];
//    vc.isAutoLogin = NO;
//    vc.isSwitchUser= NO;
//    vc = [vc init];
//    [g_window addSubview:vc.view];
//    [self actionQuit];
    //    [_wait performSelector:@selector(stop) withObject:nil afterDelay:1];
    [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
    [g_meeting WH_stopMeeting];
#endif
#endif
}

-(void)doSwitch{
    [g_default removeObjectForKey:kMY_USER_PASSWORD];
    [g_default removeObjectForKey:kMY_USER_TOKEN];
    [g_notify postNotificationName:kSystemLogout_WHNotifaction object:nil];
    [g_default setBool:NO forKey:kIsAutoLogin];
    [[JXXMPP sharedInstance] logout];
    NSLog(@"XMPP ---- WH_JXSetting_WHVC doSwitch");
    // 退出登录到登陆界面 隐藏悬浮窗
    g_App.subTopWindow.hidden = YES;
    g_App.isHaveTopWindow = YES;
    
//     WH_LoginViewController* vc = [ WH_LoginViewController alloc];
//    vc.isAutoLogin = NO;
//    vc.isSwitchUser= NO;
//    vc = [vc init];
//    [g_mainVC.view removeFromSuperview];
//    g_mainVC = nil;
//    [self.view removeFromSuperview];
//    self.view = nil;
//    g_navigation.rootViewController = vc;
    
    
    
//    g_navigation.lastVC = nil;
//    [g_navigation.subViews removeAllObjects];
//    [g_navigation pushViewController:vc];
//    g_App.window.rootViewController = vc;
//    [g_App.window makeKeyAndVisible];
    
//    JXLogoutLoginViewController *vc = [[JXLogoutLoginViewController alloc] init];
//    [g_mainVC.view removeFromSuperview];
//    g_mainVC = nil;
//    [self.view removeFromSuperview];
//    self.view = nil;
//    g_navigation.rootViewController = vc;
    
     WH_LoginViewController *loginVC = [[ WH_LoginViewController alloc] init];
    [g_mainVC.view removeFromSuperview];
    g_mainVC = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    loginVC.isPushEntering = YES;
    g_navigation.rootViewController = loginVC;
    

//     WH_LoginViewController* vc = [ WH_LoginViewController alloc];
//    vc.isAutoLogin = NO;
//    vc.isSwitchUser= YES;
//    vc = [vc init];
//    [g_navigation.subViews removeAllObjects];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc];
//    [self actionQuit];
//    [_wait performSelector:@selector(stop) withObject:nil afterDelay:1];
//    [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
    [g_meeting WH_stopMeeting];
#endif
#endif
}

// 去评价
-(void)webAppStoreBtnAction {
    if (g_config.appleId.length > 0) {
        [_wait start];
        SKStoreProductViewController *vc = [[SKStoreProductViewController alloc] init];
        vc.delegate = self;
        //加载App Store视图展示
        [vc loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:g_config.appleId} completionBlock:^(BOOL result, NSError * _Nullable error) {
            [_wait stop];
            if (!error) {
                [self presentViewController:vc animated:YES completion:nil];
            }
        }];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onAbout{
    WH_JXAbout_WHVC* vc = [[WH_JXAbout_WHVC alloc]init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onHelp{
    [g_server showWebPage:g_config.helpUrl title:Localized(@"WaHu_JXSetting_WaHuVC_Help")];
}

- (UIView *)bgViewWithOrginY:(CGFloat)orginY viewHeight:(CGFloat)height {
    UIView *clearView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, orginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, height)];
    [clearView setBackgroundColor:HEXCOLOR(0xffffff)];
    clearView.layer.masksToBounds = YES;
    clearView.layer.cornerRadius = g_factory.cardCornerRadius;
    clearView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    clearView.layer.borderWidth = g_factory.cardBorderWithd;
    [self.wh_tableBody addSubview:clearView];
    return clearView;
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click superView:(UIView *)parentView{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [parentView addSubview:btn];
//    [btn release];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, (JX_SCREEN_WIDTH - 40)/2 , HEIGHT)];
    p.text = title;
    p.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
//    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x3A404C);
    p.wh_delegate = self;
    p.didTouch = click;
    [btn addSubview:p];
//    [p release];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, (HEIGHT-20)/2, 20, 20)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
//        [iv release];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset,g_factory.cardBorderWithd)];
        line.backgroundColor = g_factory.globalBgColor;
        [btn addSubview:line];
//        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-g_factory.cardBorderWithd,JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset,g_factory.cardBorderWithd)];
        line.backgroundColor = g_factory.globalBgColor;
        [btn addSubview:line];
//        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 19, (HEIGHT - 12)/2, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [btn addSubview:iv];
//        [iv release];
    }
    
    return btn;
}

-(void)onVideoSize{
    NSString* s = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatVideoSize"];
    if(s==nil)
        s = @"1";

    WH_JXSelector_WHVC* vc = [[WH_JXSelector_WHVC alloc]init];
    vc.title = Localized(@"JX_ChatVideoSize");
    vc.WH_array = @[@"1920*1080", @"1280*720", @"640*480",@"320*240"];
    vc.WH_selectIndex = [s intValue];
    vc.wh_delegate = self;
    vc.wh_didSelected = @selector(wh_didSelected:);
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)didSelected:(WH_JXSelector_WHVC*)vc{
    [g_default setObject:[NSString stringWithFormat:@"%ld",vc.WH_selectIndex] forKey:@"chatVideoSize"];
}

@end
