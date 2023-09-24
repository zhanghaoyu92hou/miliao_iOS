//
//  WH_LoginViewController.m
//  Tigase
//
//  Created by 齐科 on 2019/8/18.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_LoginViewController.h"
#import "WH_ContentModification_WHView.h"
#import "WH_RegisterViewController.h"
#import "MiXin_forgetPwd_MiXinVC.h"
#import "UIView+CustomAlertView.h"
#import "WH_ForgetPwdForUserViewController.h"
#import "WH_LoginTextField.h"
#import "JX_QQ_manager.h"
#import "WH_JXLocation.h"
#import "WH_JXServerList_WHVC.h"
#import "WH_RoundCornerCell.h"
#import "WH_AuthViewController.h"
#import "WH_SelectNode_WHView.h"
#import "WH_JXUserObject+GetCurrentUser.h"
#import "ThirdLoginView.h"
#import "WH_AdvertisingViewController.h"
#import "RITLUtility.h"

@interface WH_LoginViewController () <UITableViewDelegate, UITableViewDataSource, WXApiManagerDelegate, JXLocationDelegate, UITextFieldDelegate>
{
    
    NSMutableArray *dataArray; //!< 数据源
    NSInteger currentLoginType; //!< 0 手机号， 1 用户名
    NSString *userToken;
    NSString *passWord; //!< 登录框中的密码,在登录时会对密码进行MD5，此变量保存为源数据，不会被MD5
    WH_JXUserObject *userObject; //!< 用户对象
    ThirdLoginView *thirdLoginView;
    UITableView *loginTable;
    BOOL isWXLogin;
    JX_QQ_manager *qqManager;
    WH_JXLocation *userLocation; //!< 用户定位
    BOOL isThirdLogin; //!< 是否是第三方登录
    BOOL isHadLoginName; //!< 已经有登录账号
    BOOL switchUser;
    UIImageView *lunchImageView; //!< 在自动登录时显示启动图
    NSMutableDictionary *pingValues; //!< 节点ping值
    BOOL isRegistSuccess; //!< 是否注册成功
    NSString *areaCodeString; //!< 手机号区号
    
}
@end
static NSString *phoneCellIdentifier = @"phoneCellIdentifier";
static NSString *pwdCellIdentifier = @"pwdCellIdentifier";
static NSString *buttonCellIdentifier = @"buttonCellIdentifier";

@implementation WH_LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //开启网络监听
    [self networkChange];
    [self initLoginData];
    [self customHeader];
    [self loadTableView];
    [self loadConfigServerButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    tap.numberOfTapsRequired = 1;
    tap.cancelsTouchesInView = NO;
    [loginTable addGestureRecognizer:tap];
    
    if (!self.isPushEntering) {
        lunchImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        lunchImageView.image = [UIImage imageNamed:[self getLaunchImageName]];
        [self.view addSubview:lunchImageView];
        //创建广告图
        if (APP_Startup_ShowAdvertisingView) {
            UIImageView *adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT * 0.85)];
            adImageView.contentMode = UIViewContentModeScaleAspectFill;
            adImageView.clipsToBounds = YES;
            [adImageView sd_setImageWithURL:[NSURL URLWithString:[g_default objectForKey:advertisingImageUrl]]];
            [lunchImageView addSubview:adImageView];
        }
    }
    
    [g_notify addObserver:self selector:@selector(onRegistered:) name:kRegistSuccessNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthResp_WHNotification object:nil];
       
}

- (void)networkChange {
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    // 2.设置网络状态改变后的处理
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"未知网络");
                [g_server getSetting:self];
                break;
                
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                NSLog(@"没有网络(断网)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"手机自带网络");
                //重新请求
                [g_server getSetting:self];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                NSLog(@"WIFI");
                //重新请求
                [g_server getSetting:self];
                break;
        }
    }];
    
    // 3.开始监控
    [manager startMonitoring];
}



- (void)initLoginData {
    
    isRegistSuccess = NO;
    isHadLoginName = NO;
    self.title = isThirdLogin ? (([g_config.regeditPhoneOrName intValue] != 1) ? Localized(@"JX_BindNo.") : Localized(@"BindID")) : Localized(@"JX_Login");
//    [g_constant LocalizedWithStr:str] 
    g_server.isLogin = NO;
    g_navigation.lastVC = nil;
    if (!isThirdLogin) {
        self.isInitialization = YES;
    }

    //先从服务器的config数据设定当前登录类型
    if (g_config.regeditPhoneOrName && [g_config.regeditPhoneOrName integerValue] != 2) {
        currentLoginType = [g_config.regeditPhoneOrName integerValue];
    }
    //如果不是首次登录，会保存登录类型，获取登录类型作为当前的类型
    currentLoginType = (g_config.lastLoginType != nil) ? [g_config.lastLoginType integerValue] : 1;//默认用户名登录
    NSArray *tempArray;
    
    if ([g_config.isOpenRegister integerValue] == 1) {
          tempArray = @[@[Localized(@"JX_InputUserAccount"), Localized(@"JX_InputPassWord")], @[Localized(@"JX_LoginNow")], @[Localized(@"JX_Register")]];
    }else{
          tempArray = @[@[Localized(@"JX_InputUserAccount"), Localized(@"JX_InputPassWord")], @[Localized(@"JX_LoginNow")]];
    }
    dataArray = [NSMutableArray arrayWithArray:tempArray];
    userObject = [WH_JXUserObject sharedUserInstance];
    
    [self resetDataSource];
    // 微信登录回调
    [WXApiManager sharedManager].delegate = self;
}
- (void)customHeader {
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_isGotoBack = NO;
    self.wh_isNotCreatewh_tableBody = YES;
    [self createHeadAndFoot];
}
- (void)loadTableView {
    loginTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP) style:UITableViewStylePlain];
    [loginTable setDelegate:self];
    [loginTable setDataSource:self];
    [loginTable setBackgroundColor:g_factory.globalBgColor];
    [loginTable setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    loginTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
//    loginTable.scrollEnabled = NO;
    loginTable.tableFooterView = [self getTableFooterView];
    [self.view addSubview:loginTable];
}
- (UIView *)getTableFooterView {
    NSInteger sectionCount = [dataArray count];
    CGRect rectInTableView = [loginTable rectForFooterInSection:sectionCount-1];
    CGRect rectInSuperview = [loginTable convertRect:rectInTableView toView:self.view];
    CGFloat totalHeight = rectInSuperview.origin.y + rectInSuperview.size.height;
    CGFloat footerHeight = self.view.height - totalHeight;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, footerHeight)];
    footer.backgroundColor = g_factory.globalBgColor;
    if (IS_SHOW_THIRDLOGIN) {
        thirdLoginView = [[ThirdLoginView alloc] initWithFrame:footer.bounds];
        [footer addSubview:thirdLoginView];
        __weak typeof(self) weakSelf = self;
        thirdLoginView.thirdLoginBlock = ^(NSInteger loginType) {
            if (loginType == 1) {
                [weakSelf qqLoginMethod];
            }else {
                [weakSelf weixinLoginMethod];
            }
        };
    }
    return footer;
}
- (void)loadConfigServerButton {
#ifdef DEBUG
    UIButton* btn = [UIFactory WH_create_WHButtonWithTitle:Localized(@"JX_SetupServer")  titleFont:[UIFont systemFontOfSize:15] titleColor:[UIColor blackColor] normal:nil highlight:nil];
    [btn addTarget:self action:@selector(onSetting) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH-88, JX_SCREEN_TOP - 38, 83, 30);
    [self.wh_tableHeader addSubview:btn];
    btn.hidden = YES;
#endif
}

#pragma mark ---- Handle Data
- (void)setUpDefaultValues {
    [self setUpLoginStatus];
    if ([g_default objectForKey:kLocationLogin]) {
        NSDictionary *dict = [g_default objectForKey:kLocationLogin];
        g_server.longitude = [[dict objectForKey:@"longitude"] doubleValue];
        g_server.latitude = [[dict objectForKey:@"latitude"] doubleValue];
    }
}
- (void)setUpLoginStatus {
    if (g_config.regeditPhoneOrName && [g_config.regeditPhoneOrName integerValue] != 2) {
        currentLoginType = [g_config.regeditPhoneOrName integerValue];
    }
    NSString *loginName = [g_default objectForKey:kMY_USER_LoginName];
    NSString *userId = [g_default objectForKey:kMY_USER_ID];
    if (IsStringNull(loginName) || IsStringNull(userId)) {
        isHadLoginName = NO;
        userObject = [[WH_JXUserObject alloc] init];
    }else{
        if (!switchUser && !IsStringNull(loginName) && ![userId isEqualToString:@"10000"]) {
            //从Document文件读取用户数据
            userObject = [WH_JXUserObject sharedUserInstance];
            isHadLoginName = YES;
        }else {
            isHadLoginName = NO;
            userObject = [[WH_JXUserObject alloc] init];
        }
    }
    
}
- (void)resetDataSource {
    [self setUpLoginStatus];
    [dataArray removeAllObjects];
    userToken = [g_default objectForKey:kMY_USER_TOKEN];
    NSMutableArray *accountArray = [[NSMutableArray alloc] init];
    BOOL status = g_config.lastLoginType && currentLoginType != [g_config.lastLoginType integerValue];
    if (!isHadLoginName || status) {
        if ([g_config.isNodesStatus integerValue] == 1) {
            // 是否支持多节点服务 0：不支持 1：支持
            if (g_config.nodesInfoList.count > 0) {
                NSDictionary *dict = [g_config.nodesInfoList objectAtIndex:0];
                NSString *nodeHost = dict[@"nodeIp"];
                if (!IsStringNull(nodeHost)) {
                    g_config.XMPPHost = dict[@"nodeIp"];
                    g_config.XMPPHostPort = [dict[@"nodePort"] integerValue];
                    [g_default setObject:g_config.XMPPHost forKey:kLastXmppHostUrl];
                    [g_default setInteger:g_config.XMPPHostPort forKey:kLastXmppHostPort];
                    [g_default synchronize];
                }
                NSString *str = dict[@"nodeName"];
                [accountArray addObject:str];
            }
        }
        [accountArray addObject:currentLoginType == 0 ? Localized(@"JX_InputPhone") : Localized(@"JX_InputUserAccount")];
    }
    [accountArray addObject:Localized(@"JX_InputPassWord")];
    [dataArray addObject:accountArray];
//    if ([g_config.isOpenRegister integerValue] == 1) {
        [dataArray addObject:@[Localized(@"JX_LoginNow")]];
//    }
    NSNumber *regeNumber = g_config.regeditPhoneOrName;
    if (regeNumber && [regeNumber integerValue] == 2) {
        if (!isHadLoginName || switchUser || status) {
            if (currentLoginType == 0) {
                [dataArray addObject:@[Localized(@"LoginWithUserName")]];
            }else {
                [dataArray addObject:@[Localized(@"LoginWithPhoneNo")]];
            }
        }
    }
    //如果登录过，设置头像和昵称
    if (isHadLoginName && !status) {
        [dataArray addObject:@[Localized(@"SwitchAccount")]];
    }
    if ([g_config.isOpenRegister integerValue] == 1) {
        [dataArray addObject:@[Localized(@"JX_Register")]];
    }
}

//设置配置文件
- (void)reSetConfigFile {
    // 自动登录失败，清除token后，重新赋值一次
    
    if (g_config.XMPPDomain) {
        
        if ([g_config.isOpenPositionService intValue] == 0) {
            if (IS_LOCATE_ATFIRST) {
                userLocation = [[WH_JXLocation alloc] init];
                userLocation.delegate = self;
                g_server.location = userLocation;
                [g_server locate];
            }
            
        }
    }
    
    BOOL autoLogin = [[g_default objectForKey:kIsAutoLogin] boolValue];
    if((autoLogin && !IsStringNull(userToken)) || isThirdLogin) {
        if (isThirdLogin) {
            [g_server WH_thirdLogin:userObject type:isWXLogin ? 2 : 1 openId:g_server.openId isLogin:NO toView:self];
        }else {
            [self performSelector:@selector(autoLogin) withObject:nil afterDelay:.5];
        }
    } else if (IsStringNull(userToken) && !IsStringNull(userObject.telephone) && !IsStringNull(passWord)) {
        [[JXServer sharedServer] login:userObject loginType:[g_config.lastLoginType integerValue] toView:self];
    } else {
        [lunchImageView removeFromSuperview];
    }
    [self resetDataSource];
    [loginTable reloadData];
    loginTable.tableFooterView = [self getTableFooterView];
//    [loginTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataArray.count)] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)autoLogin{
     [g_server autoLogin:self];
}
#pragma mark ------- UITableView DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 50 : 44;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = nil;
    NSString *rowIdentifier = dataArray[indexPath.section][indexPath.row];
    
    
    if ([rowIdentifier isEqualToString:Localized(@"JX_InputPhone")] || [rowIdentifier isEqualToString:Localized(@"JX_InputUserAccount")]) {
        cell = [self phoneFieldCellAtIndexPath:indexPath];
    }else if ([rowIdentifier isEqualToString:Localized(@"JX_InputPassWord")]) {
        cell = [self pwdFieldCellForIndexPath:indexPath];
    }else if ([rowIdentifier isEqualToString:@"图片验证码"]) {
        cell = [self pwdFieldCellForIndexPath:indexPath];
    }else {
        if (indexPath.section == 0) {
            if ([g_config.isNodesStatus integerValue] == 1 && indexPath.row == 0 && g_config.nodesInfoList.count > 0) {
                //有节点
                cell = [self buttonCellForPointIndexPath:indexPath];
            }
        } else {
            cell = [self buttonCellForIndexPath:indexPath];
        }
    }
    
    NSInteger count = [dataArray[indexPath.section] count];
    if (count == 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, JX_SCREEN_WIDTH/2, 0, JX_SCREEN_WIDTH/2);
    }else {
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = g_factory.globalBgColor;
    return cell;
}

- (WH_RoundCornerCell *)phoneFieldCellAtIndexPath:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [loginTable dequeueReusableCellWithIdentifier:phoneCellIdentifier];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:phoneCellIdentifier tableView:loginTable indexPath:indexPath];
        WH_LoginTextField *phoneField = [[WH_LoginTextField alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH-g_factory.globelEdgeInset*2, 50)];
        phoneField.fieldType = currentLoginType == 0 ? LoginFieldPhoneNoType : LoginFieldUserNameType;
        phoneField.tag = 200;
        phoneField.delegate = self;
        phoneField.backgroundColor = UIColor.clearColor;
        [cell.contentView addSubview:phoneField];
    }
    WH_LoginTextField *field = (WH_LoginTextField *)[cell.contentView viewWithTag:200];
    field.fieldType = currentLoginType == 0 ? LoginFieldPhoneNoType : LoginFieldUserNameType;
    if (currentLoginType == 0) {
        areaCodeString = [field getAreaString];
        
        field.areaCodeBlock = ^(NSString * _Nonnull areaCode) {
            areaCodeString = areaCode;
        };
    }
    cell.cellIndexPath = indexPath;
    field.text = @"";
    return cell;
}

- (WH_RoundCornerCell *)pwdFieldCellForIndexPath:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [loginTable dequeueReusableCellWithIdentifier:pwdCellIdentifier];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:pwdCellIdentifier tableView:loginTable indexPath:indexPath];
        WH_LoginTextField *pwdField = [[WH_LoginTextField alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 1, JX_SCREEN_WIDTH-g_factory.globelEdgeInset*2, 50)];
        pwdField.fieldType = LoginFieldPassWordType;
        pwdField.tag = 201;
        pwdField.delegate = self;
        pwdField.backgroundColor = UIColor.clearColor;
        [cell.contentView addSubview:pwdField];
    }
    cell.cellIndexPath = indexPath;
    WH_LoginTextField *field = (WH_LoginTextField *)[cell.contentView viewWithTag:201];
    field.text = @"";
    return cell;
}

- (WH_RoundCornerCell *)buttonCellForIndexPath:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [loginTable dequeueReusableCellWithIdentifier:buttonCellIdentifier];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:buttonCellIdentifier tableView:loginTable indexPath:indexPath];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, JX_SCREEN_WIDTH-20, 44)];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        button.tag = 100;
        [button.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = g_factory.cardCornerRadius;
        [cell.contentView addSubview:button];
    }
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:100];
    NSString *titleString = dataArray[indexPath.section][indexPath.row];
    [button setTitle: titleString forState:UIControlStateNormal];
    if ([titleString isEqualToString:Localized(@"JX_LoginNow")]) {
        [button setBackgroundColor:HEXCOLOR(0x0093FF)];
        [button setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    }else {
        [button setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
        [button setBackgroundColor:HEXCOLOR(0xffffff)];
    }
    cell.cellIndexPath = indexPath;
    return cell;
}

- (WH_RoundCornerCell *)buttonCellForPointIndexPath:(NSIndexPath *)indexPath {
    WH_RoundCornerCell *cell = [loginTable dequeueReusableCellWithIdentifier:@"pointIndexPath"];
    if (!cell) {
        cell = [[WH_RoundCornerCell alloc] initWithReuseIdentifier:@"pointIndexPath" tableView:loginTable indexPath:indexPath];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(16, 0, JX_SCREEN_WIDTH-32, 50)];
        button.tag = 200;
        button.clipsToBounds = YES;
        button.layer.cornerRadius = g_factory.cardCornerRadius;
        [cell.contentView addSubview:button];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:200];
    NSString *titleString = dataArray[indexPath.section][indexPath.row];
    for (UIView *v in button.subviews) {
        if (v.tag == 10001) {
            [v removeFromSuperview];
        }
    }

    self.pointLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(10, 0, CGRectGetWidth(button.frame) - 10 - 29, 50) text:titleString?:@"" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15] textColor:HEXCOLOR(0x333333) backgroundColor:button.backgroundColor];
    self.pointLabel.tag = 10001;

    [button addSubview:self.pointLabel];
    
    UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(button.frame) - 19, (CGRectGetHeight(button.frame) - 12)/2, 7, 12)];
    [markImg setImage: [UIImage imageNamed:@"WH_Back"]];
    [button addSubview:markImg];
    
    return cell;
}
#pragma mark ---- UITableView HeaderView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 20;
    if (section == 0) {
        BOOL status = g_config.lastLoginType && currentLoginType != [g_config.lastLoginType integerValue];
        headerHeight = isHadLoginName && !status ? 158 : 12;
    }else if (section == 1) {
        headerHeight = 20;
    }else headerHeight = 12;
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerRect = [tableView rectForHeaderInSection:section];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, CGRectGetHeight(headerRect))];
    header.backgroundColor = g_factory.globalBgColor;
    BOOL status = g_config.lastLoginType && currentLoginType != [g_config.lastLoginType integerValue];
    if (section == 0 && isHadLoginName && !status) {
        UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH - 75)/2, 40, 75, 75)];
        headImgView.layer.masksToBounds = YES;
        headImgView.layer.cornerRadius = (MainHeadType)?(75/2):(g_factory.headViewCornerRadius);
        [header addSubview:headImgView];
//        [g_server WH_getHeadImageLargeWithUserId:g_myself.userId userName:g_myself.userNickname imageView:headImgView];

        NSString *str = [g_default objectForKey:kMY_USER_NICKNAME];
        NSString *userId = [g_default objectForKey:kMY_USER_ID];
        
        [g_server WH_getHeadImageLargeWithUserId:userId userName:str imageView:headImgView];
        
        UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(0, headImgView.bottom + 8, JX_SCREEN_WIDTH, 23)];
//        [nickName setText:g_myself.userNickname];
        [nickName setText:str];
        [nickName setTextAlignment:NSTextAlignmentCenter];
        [nickName setTextColor:HEXCOLOR(0x333333)];
        [nickName setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
        [header addSubview:nickName];
    }else {
        for (UIView *v in header.subviews) {
            [v removeFromSuperview];
        }
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSInteger lastSection = dataArray.count - 1;
    if (section == lastSection && [self showForgetPasswordButton]) {
        return 12+40;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect footRect = [tableView rectForHeaderInSection:section];
    UIView *footerView = [[UIView alloc] initWithFrame:footRect];
    footerView.backgroundColor = g_factory.globalBgColor;
    NSInteger lastSection = dataArray.count - 1;
    if (lastSection == section && [self showForgetPasswordButton]) {
        UIButton *forgetbutton = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 80, 12 , 80, 40)];
        [forgetbutton setTitle:Localized(@"JX_ForgetPassWord") forState:UIControlStateNormal];
        [forgetbutton setTitleColor:HEXCOLOR(0xB5C0D2) forState:UIControlStateNormal];
        [forgetbutton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 12]];
        [forgetbutton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [forgetbutton addTarget:self action:@selector(forgetPwdMethod) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:forgetbutton];
    }
    return footerView;
}
- (BOOL)showForgetPasswordButton {
    if (currentLoginType == 1 && [g_config.isQestionOpen boolValue]) {
        return YES;
    }else if (currentLoginType == 0) {
        return YES;
    }
    return NO;
}
#pragma mark ----- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    WH_LoginTextField *loginField = (WH_LoginTextField *)textField;
    if (loginField.fieldType == LoginFieldPhoneNoType) {
        userObject.phone = textField.text; //登录时判断手机号是否输入时用userObject.phone(userObject.phone全局都是存储手机号)
        userObject.telephone = userObject.phone;//给loginName赋值时用userObject.telephone(userObject.phone不一定是手机号，特殊情况也可能是用户名)
    }else if (loginField.fieldType == LoginFieldPassWordType) {
        passWord = textField.text;
    }else if (loginField.fieldType == LoginFieldUserNameType) {
         userObject.account = textField.text;
    }
}
#pragma mark ----- Button Action
- (void)buttonAction:(UIButton *)button {
    [self.view endEditing:YES];
    if (button.tag == 200) {
        //节点选择
        WH_SelectNode_WHView *sNodeView = [[WH_SelectNode_WHView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
        [g_App.window addSubview:sNodeView];
        [sNodeView setWh_SelectNodeBlock:^(NSDictionary * _Nonnull data) {
            NSString *xmpphost = [NSString stringWithFormat:@"%@",data[@"nodeIp"]];
            NSString *xmpphostPort = [NSString stringWithFormat:@"%@",data[@"nodePort"]];
            
            if (xmpphost.length) {
                g_config.XMPPHost = xmpphost;
                g_config.XMPPHostPort = [xmpphostPort integerValue];
                // 保存上次选择的节点
                [g_default setObject:xmpphost forKey:kLastXmppHostUrl];
                // 保存上次选择的端口号
                [g_default setInteger:[xmpphostPort integerValue] forKey:kLastXmppHostPort];
                [g_default synchronize];
                
                [self.pointLabel setText:[data objectForKey:@"nodeName"] ?: @""];
            }
        }];
    }else if ([button.titleLabel.text isEqualToString:Localized(@"JX_LoginNow")]) {
        [self loginMethod];
    }else if ([button.titleLabel.text isEqualToString:Localized(@"JX_Register")] || [button.titleLabel.text isEqualToString:Localized(@"RegistNewAccount")]) {
        [self registMethod];
    }else if ([button.titleLabel.text isEqualToString:Localized(@"SwitchAccount")]) {
        [self switchAccount];
    }else if ([button.titleLabel.text isEqualToString:Localized(@"LoginWithUserName")]){
        currentLoginType = 1;
        isHadLoginName = NO;
        [self resetDataSource];
        [self clearTextFieldText];
        loginTable.tableFooterView = [self getTableFooterView];
//        [loginTable reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [loginTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if([button.titleLabel.text isEqualToString:Localized(@"LoginWithPhoneNo")]){
        currentLoginType = 0;
        isHadLoginName = NO;
        [self resetDataSource];
        [self clearTextFieldText];
        loginTable.tableFooterView = [self getTableFooterView];
//        [loginTable reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [loginTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma -- mark 登录
- (void)loginMethod {
    self.isInitialization = NO;
//    if (isHadLoginName) {
//        NSInteger numbers = [loginTable numberOfRowsInSection:0];
//        if (numbers == 1) {
//            if (currentLoginType == 1) {
//                userObject.account = [g_default objectForKey:kMY_USER_LoginName];
//            }else {
//                userObject.telephone = [g_default objectForKey:kMY_USER_LoginName];
//            }
//        }
//    }
    BOOL status = g_config.lastLoginType && currentLoginType != [g_config.lastLoginType integerValue];
    if (currentLoginType == 0 && (!isHadLoginName || status)) {
        //出去@"+"号
        areaCodeString = [areaCodeString stringByReplacingOccurrencesOfString:@"+" withString:@""];
        userObject.areaCode = areaCodeString;
    }else {
        userObject.areaCode = g_myself.areaCode;
    }
    if(currentLoginType == 0) {//手机号注册
        if (IsStringNull(userObject.phone)) {//手机号为空
            [GKMessageTool showTips:Localized(@"JX_InputPhone")];
            return;
        }
    }
    
//    if (currentLoginType == 1 && IsStringNull(userObject.account)) {
//        [GKMessageTool showTips:Localized(@"JX_InputUserAccount")];
//        return;
//    }
    NSString *loginName = [g_default objectForKey:kMY_USER_LoginName];
    
    if (currentLoginType == 1 && IsStringNull(loginName) && IsStringNull(userObject.account)) {
        [GKMessageTool showTips:Localized(@"JX_InputUserAccount")];
        return;
    }
        
    if(IsStringNull(passWord)){
        [GKMessageTool showTips:Localized(@"JX_InputPassWord")];
        return;
    }
    if (currentLoginType == 0) {
        if (![userObject.phone mj_isPureInt]) {
            [GKMessageTool showTips:Localized(@"PhoneRegistFormatError")];
            return;
        };
    }
    userObject.password = [g_server WH_getMD5StringWithStr:passWord];
    if (isHadLoginName && !status) {
        userObject.account = loginName;
    }
    [_wait start];
    [[JXServer sharedServer] login:userObject loginType:currentLoginType toView:self];
}
- (void)registMethod {
    WH_RegisterViewController *vc = [[WH_RegisterViewController alloc] init];
    if ([g_default boolForKey:WH_ThirdPartyLogins]) {
        vc.iswWxinLogin = isWXLogin ? @(2) : @(1);
    }
    vc.registType = currentLoginType;
    [g_navigation pushViewController:vc animated:YES];
}
- (void)switchAccount {
    [g_default removeObjectForKey:kMY_USER_TOKEN];
    switchUser = YES;
    [self clearTextFieldText];
    [[JXXMPP sharedInstance] logout];
    isHadLoginName = NO;
    currentLoginType = currentLoginType == 0 ? 1 : 0;
    [self resetDataSource];
//    [UIView performWithoutAnimation:^{
         [loginTable reloadData];
        loginTable.tableFooterView = [self getTableFooterView];
//    }];
}
- (void)forgetPwdMethod {
    if (currentLoginType == 1) {
        WH_ForgetPwdForUserViewController *pwsVC = [[WH_ForgetPwdForUserViewController alloc] init];
        pwsVC.forgetStep = 1;
        [g_navigation pushViewController:pwsVC animated:YES];
        return;
    }
    MiXin_forgetPwd_MiXinVC* vc = [[MiXin_forgetPwd_MiXinVC alloc] init];
    vc.isModify = NO;
    vc.forgetType = currentLoginType;
    [g_navigation pushViewController:vc animated:YES];
}
- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}
- (void)clearTextFieldText {
    userObject = [[WH_JXUserObject alloc] init];
    [loginTable reloadData];
}
- (void)onSetting {
    WH_JXServerList_WHVC *vc = [[WH_JXServerList_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

#pragma mark ------ 网络请求
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    //测试第三方登录registerInviteCode
    if ([aDownload.action isEqualToString:act_otherLogin]) {
        NSString *inviteStatus = [NSString stringWithFormat:@"%@",dict[@"inviteStatus"]];//!< 1、正常 2、填写
        NSString *registerStatus = dict[@"registerStatus"]; //!< 第一次使用该账号登录时为1
        [g_default setObject:[dict objectForKey:@"payPassword"] forKey:PayPasswordKey];//第三方登录成功时,保存一下支付密码的设置状态
        if ([g_config.registerInviteCode integerValue] == 1 &&  inviteStatus.integerValue == 2) {
            //弹框请输入邀请码
            [self showInviteCodeAlertView:dict];
        }else if ([g_config.registerInviteCode integerValue] == 2 &&  registerStatus.integerValue == 1){
            [self showInviteCodeAlertView:dict];
        }else {
            [self setUpThirdLoginWithDict:dict];
        }
        return;
    }else if ([aDownload.action isEqualToString:act_otherSetInviteCode]) {
        g_server.openId = nil;
   
        [self setUpThirdLoginWithDict:dict];
        return;
    }else if( [aDownload.action isEqualToString:wh_act_Config]){
        [g_config didReceive:dict];
        [self setUpDefaultValues];
    
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        [manager stopMonitoring];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reSetConfigFile];
        });
        return;
    }
    
    if( [aDownload.action isEqualToString:wh_act_UserLogin] || [aDownload.action isEqualToString:wh_act_thirdLogin] || [aDownload.action isEqualToString:act_sdkLogin] || [aDownload.action isEqualToString:act_otherLogin]){//所有登录类型
        [g_default setObject:[dict objectForKey:@"payPassword"] forKey:PayPasswordKey];//登录成功时,保存一下支付密码的设置状态
        if (isRegistSuccess) {
            [g_App showMainUI];
            [self actionQuit];
            
            return;
        }
        if ([aDownload.action isEqualToString:wh_act_thirdLogin] || [aDownload.action isEqualToString:act_sdkLogin] || [aDownload.action isEqualToString:act_otherLogin]) {
            g_server.openId = nil;
            [g_default setBool:YES forKey:kTHIRD_LOGIN_AUTO];
        }else {
            [g_default setBool:NO forKey:kTHIRD_LOGIN_AUTO];
        }
        [g_default setBool:YES forKey:kIsAutoLogin];
        [g_default setObject:currentLoginType == 0 ? userObject.telephone : userObject.account forKey:kMY_USER_LoginName];
        [g_server doLoginOK:dict user:userObject];
        
        if (_isFromAuth) {
            WH_AuthViewController *vc = [[WH_AuthViewController alloc]init];
            vc.infoDic = self.shareInfoDic[@"info"];
            vc.sdkImage = self.sdkImage;
            vc.fromSchema = self.fromSchema;
            [g_navigation pushViewController:vc animated:YES];
            [_wait stop];
            return;
        }
        
        if(self.isSwitchUser){
            //切换登录，同步好友
            [g_notify postNotificationName:kXmppClickLogin_WHNotifaction object:nil];
            g_config.lastLoginType = [NSNumber numberWithInteger:currentLoginType];
            // 更新“我”页面
            [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
            [self actionQuit];
        }else if([aDownload.action isEqualToString:wh_act_UserLogin]) {
            [g_default setBool:NO forKey:WH_ThirdPartyLogins];
            g_config.lastLoginType = [NSNumber numberWithInteger:currentLoginType];
            
            g_myself.password = [[g_server WH_getMD5StringWithStr:passWord] copy];
            [[WH_JXUserObject sharedUserInstance] getCurrentUser];
            [WH_JXUserObject sharedUserInstance].complete = ^(HttpRequestStatus status, NSDictionary * _Nullable userInfo, NSError * _Nullable error) {
                [g_App showMainUI];
                [self actionQuit];
                [lunchImageView removeFromSuperview];
            };
            
            

            
        }else {
            [g_App showMainUI];
            [self actionQuit];
        }
        return;
    }
    if([aDownload.action isEqualToString:wh_act_UserLoginAuto]){
        [lunchImageView removeFromSuperview];
        [g_server doLoginOK:dict user:nil];
        NSString *passwordsalt = [NSString stringWithFormat:@"%@",[dict objectForKey:@"salt"]];
        if (passwordsalt.length) {
            [g_default setObject:passwordsalt forKey:kMY_USER_PASSWORDSalt];
            [g_default synchronize];
        }
        
        [g_App showMainUI];
        [self actionQuit];
        [_wait stop];
    }
    if ([aDownload.action isEqualToString:wh_act_GetWxOpenId]) {
        g_server.openId = [dict objectForKey:@"openid"];
        [g_server WH_wxSdkLogin:userObject type:2 openId:g_server.openId toView:self];
    }
}
- (void)setUpThirdLoginWithDict:(NSDictionary *)dict {
    [g_default setBool:YES forKey:kTHIRD_LOGIN_AUTO];
    [g_default setBool:YES forKey:kIsAutoLogin];
    [g_default setBool:YES forKey:WH_ThirdPartyLogins];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [g_server doLoginOK:dict user:userObject];
    if(self.isSwitchUser){
        //切换登录，同步好友
        [g_notify postNotificationName:kXmppClickLogin_WHNotifaction object:nil];
        
        // 更新“我”页面
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
    } else {
        [g_App showMainUI];
    }
    [self actionQuit];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    [_wait stop];
    //第三方登录(新版)
    if ([aDownload.action isEqualToString:act_otherSetInviteCode]) {
        [GKMessageTool showError:dict[@"data"][@"resultMsg"]];
        return WH_hide_error;
    }else if ([aDownload.action isEqualToString:act_otherLogin] && [[dict objectForKey:@"resultCode"] intValue] == 1040305) {
        isThirdLogin = YES;
        self.isSwitchUser= NO;
        return WH_hide_error;
    }else if ([aDownload.action isEqualToString:wh_act_Config]) {
        
        NSString *url = [g_default stringForKey:kLastApiUrl];
        if (url && [url isKindOfClass:[NSString class]] && url.length) {
            g_config.apiUrl = url;
        }
        
        [self reSetConfigFile];
        return WH_hide_error;
    }else if ([aDownload.action isEqualToString:act_sdkLogin] && [[dict objectForKey:@"resultCode"] intValue] == 1040305) {
        isThirdLogin = YES;
        self.isSwitchUser= NO;
        return WH_hide_error;
    }else if ([aDownload.action isEqualToString:wh_act_thirdLogin] && [[dict objectForKey:@"resultCode"] intValue] == 1040306) {
        [self registMethod]; //注册
        return WH_hide_error;
    }else if([aDownload.action isEqualToString:wh_act_UserLoginAuto]){
        [g_default removeObjectForKey:kMY_USER_TOKEN];
        [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
        [lunchImageView removeFromSuperview];
    }else if ([aDownload.action isEqualToString:wh_act_thirdLogin]) {
        g_server.openId = nil;
    }
    
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    
     [lunchImageView removeFromSuperview];
    //测试第三方登录
    if ([aDownload.action isEqualToString:act_otherLogin]) {
        
    }
    
    
    if ([aDownload.action isEqualToString:wh_act_Config]) {
        
        NSString *url = [g_default stringForKey:kLastApiUrl];
        if (url && [url isKindOfClass:[NSString class]] && url.length) {
            g_config.apiUrl = url;
        }
        
        [self reSetConfigFile];
        return WH_hide_error;
    }
    if([aDownload.action isEqualToString:wh_act_UserLoginAuto]){
        [g_default removeObjectForKey:kMY_USER_TOKEN];
        [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
    }
    if ([aDownload.action isEqualToString:wh_act_thirdLogin]) {
        g_server.openId = nil;
    }
    
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_MiXinStart:(WH_JXConnection*)aDownload{
    //    _btn.userInteractionEnabled = NO;
    if([aDownload.action isEqualToString:wh_act_thirdLogin] || [aDownload.action isEqualToString:act_sdkLogin]|| [aDownload.action isEqualToString:act_otherLogin]){
        [_wait start];
    }else{
//        [_wait start:Localized(@"JX_Logining")];
        [_wait start];
    }
}



#pragma mark -------------- 第三方登录
- (void)qqLoginMethod {
    isWXLogin = NO;
    qqManager = [[JX_QQ_manager alloc] init];
    [qqManager QQ_login];
    __weak typeof(self)weakSelf = self;
    __weak typeof(WH_JXUserObject *) weakUser = userObject;
    qqManager.loginCallBack = ^(TencentOAuth * _Nonnull tecentOauth) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        g_server.openId = tecentOauth.openId;
        [g_server WH_otherLogin:weakUser type:1 openId:g_server.openId toView:strongSelf token:tecentOauth.accessToken];
    };
}
- (void)weixinLoginMethod {
    isWXLogin = YES;
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo"; // @"post_timeline,sns"
    req.state = @"login";
    req.openID = @"";
    [WXApi sendAuthReq:req viewController:self delegate:[WXApiManager sharedManager] completion:nil];
}
//微信授权返回
- (void)authRespNotification:(NSNotification *)notif {
    if ([WXApiManager sharedManager].isHandlerThirdLoginCallback) {
        return;
    } else {
        [WXApiManager sharedManager].isHandlerThirdLoginCallback = YES;
    }
    SendAuthResp *response = notif.object;
    NSString *strMsg = [NSString stringWithFormat:@"Auth结果 code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
    NSLog(@"-------%@",strMsg);
    [g_server WH_otherLogin:userObject type:2 openId:response.code toView:self token:nil];
    
    //    [g_server getWxOpenId:response.code toView:self];
}

#pragma mark ---- 邀请码处理
- (void)showInviteCodeAlertView:(NSDictionary *)thirdLoginInfo {
    BOOL isCodeNecessary = g_config.registerInviteCode.integerValue == 1; //!< 邀请码是否为必填
    NSString *placeHolderString = !isCodeNecessary ? @"请填写邀请码（选填）" : @"";
    WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:@"请输入您的邀请码" content:placeHolderString isEdit:YES isLimit:YES];
    [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(cmView) inviteCodeAlert = cmView;
    __weak typeof(self) weakSelf = self;
    [cmView setCloseBlock:^{
        [inviteCodeAlert hideView];
    }];
    [cmView setSelectActionBlock:^(NSInteger buttonTag, NSString * _Nonnull content) {
        if (buttonTag == 0) {
            if (isCodeNecessary && IsStringNull(content)) {
                //邀请码为必填
                [GKMessageTool showText:@"请输入邀请码"];
            }else if (!isCodeNecessary){
                [inviteCodeAlert hideView];
                [self setUpThirdLoginWithDict:thirdLoginInfo];
            }
        }else{
            if (isCodeNecessary && IsStringNull(content)) {
                //邀请码为必填
                [GKMessageTool showText:@"请输入邀请码"];
            }else {
                [g_server WH_otherSetInviteCode:content access_token:thirdLoginInfo[@"access_token"] userId:[NSString stringWithFormat:@"%@",thirdLoginInfo[@"userId"]] toView:weakSelf];
                [inviteCodeAlert hideView];
            }
        }
    }];
}
#pragma mark ---- 获取启动图
// 获取启动图
- (NSString *)getLaunchImageName
{
    NSString *viewOrientation = @"Portrait";
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        viewOrientation = @"Landscape";
    }
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}
-(void)onRegistered:(NSNotification *)notifacation{
    isRegistSuccess = YES;
    [[JXServer sharedServer] login:g_myself loginType:currentLoginType toView:self];
}

#pragma mark ----- JXLocationDelegate
- (void) location:(WH_JXLocation *)location CountryCode:(NSString *)countryCode CityName:(NSString *)cityName CityId:(NSString *)cityId Address:(NSString *)address Latitude:(double)lat Longitude:(double)lon {
    g_server.countryCode = countryCode;
    g_server.cityName = cityName;
    g_server.cityId = [cityId intValue];
    g_server.address = address;
    g_server.latitude = lat;
    g_server.longitude = lon;
    NSDictionary *dict = @{@"latitude":@(lat),@"longitude":@(lon)};
    [g_default setObject:dict forKey:kLocationLogin];
}

- (void)location:(WH_JXLocation *)location getLocationWithIp:(NSDictionary *)dict {
    
}
- (void)location:(WH_JXLocation *)location getLocationError:(NSError *)error {
    
}

- (void)dealloc {
    
    
}
@end
