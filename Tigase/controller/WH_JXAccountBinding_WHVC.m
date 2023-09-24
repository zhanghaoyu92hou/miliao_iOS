//
//  WH_JXAccountBinding_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/14.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXAccountBinding_WHVC.h"
#import "WXApi.h"
#import "JX_QQ_manager.h"
#import "WH_ChangeTheBoundPhoneNumber_WHViewController.h"
#import "WH_JXUserObject+GetCurrentUser.h"

#define HEIGHT 50
#define MY_INSET  0  // 每行左右间隙
#define TOP_ADD_HEIGHT  400  // 顶部添加的高度，防止下拉顶部空白

@interface WH_JXAccountBinding_WHVC () <UIAlertViewDelegate,WXApiDelegate,WXApiManagerDelegate>
@property (nonatomic, strong) UISwitch *wxBindStatus;
@property (nonatomic, strong) UISwitch *wxBindQQStatus;
@property (nonatomic, strong) UISwitch *BindAlipayStatus;
@property (nonatomic ,strong) NSNumber *isWXBinding;//0微信， 1，qq 2，支付宝
@end

@implementation WH_JXAccountBinding_WHVC
{
    JX_QQ_manager *qqManager;
    UILabel *_phoneLb;
    UIView *_bottomBgView;
    UISwitch *_selectedSwitch;//点击的switch
}
// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = Localized(@"JX_AccountAndBindSettings");
    self.wh_isGotoBack = YES;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    [self createHeadAndFoot];
    [self WH_getServerData];
    
    [self WH_setupViews];
    // 微信登录回调
    [WXApiManager sharedManager].delegate = self;
    
#ifdef IS_SHOW_BINDTELEPHONE
//    [g_server getUser:MY_USER_ID toView:self];
    [self getCurrentUserInfo];
#else
    
#endif
    
    [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthResp_WHNotification object:nil];
    
    //WH_ChangeTheBoundPhoneNumber_Notification
    [g_notify addObserver:self selector:@selector(wh_changeTheBoundPhoneNumberNotification) name:@"WH_ChangeTheBoundPhoneNumber_Notification" object:nil];
}

- (void)getCurrentUserInfo {
    [[WH_JXUserObject sharedUserInstance] getCurrentUser];
    [WH_JXUserObject sharedUserInstance].complete = ^(HttpRequestStatus status, NSDictionary * _Nullable userInfo, NSError * _Nullable error) {
        switch (status) {
            case HttpRequestSuccess:
            {
                self.userObject = [WH_JXUserObject sharedUserInstance];
                _phoneLb.text = @"";
                _phoneLb.text = self.userObject.phone?:@"暂无";
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
- (void)WH_getServerData {
    [g_server WH_getUserBindInfo:self];
}

- (void)wh_changeTheBoundPhoneNumberNotification {
    [g_server getUser:MY_USER_ID toView:self];
}

- (void)WH_setupViews {
    self.wh_tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
    
    
    
    UIView *phoneBgView ;
#ifdef IS_SHOW_BINDTELEPHONE
    phoneBgView = [[UIView alloc] initWithFrame:CGRectMake(10, 12, JX_SCREEN_WIDTH - 20, HEIGHT)];
    phoneBgView.layer.cornerRadius = 10;
    phoneBgView.layer.borderWidth = 1;
    phoneBgView.layer.borderColor = RGB(219, 224, 231).CGColor;
    phoneBgView.layer.masksToBounds = YES;
    [self.wh_tableBody addSubview:phoneBgView];
    //    phoneV.frame = phoneBgView.bounds;
    //    [phoneBgView addSubview:phoneV];
    
    WH_JXImageView* phoneV;
    phoneV = [self WH_create_WHButton:@"手机号" drawTop:NO drawBottom:NO icon:nil supView:phoneBgView click:@selector(changePhoneNum)];
    phoneV.frame = phoneBgView.bounds;
    
    UIImageView *nextImagV = [[UIImageView alloc] init];
    [nextImagV setImage:[UIImage imageNamed:@"WH_Back"]];
    [phoneBgView addSubview:nextImagV];
    [nextImagV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(phoneBgView.mas_right).offset(-12);
        make.width.mas_equalTo(7);
        make.height.mas_equalTo(12);
        make.centerY.mas_equalTo(phoneV.mas_centerY);
    }];
    _phoneLb = [UILabel new];
    _phoneLb.textColor = RGB(150, 150, 150);
    _phoneLb.font = [UIFont systemFontOfSize:15];
    [phoneBgView addSubview:_phoneLb];
    [_phoneLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(phoneBgView);
        make.right.mas_equalTo(phoneBgView.mas_right).offset(-27);
    }];
    _phoneLb.text = self.userObject.phone?:@"暂无";
#else
    
#endif
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(phoneBgView.frame), 120, 30)];
    title.text = Localized(@"JX_OtherLogin");
    title.font = sysFontWithSize(12);
    title.textColor = RGB(140, 154, 184);
    [self.wh_tableBody addSubview:title];
    
    _bottomBgView = [UIView new];
    _bottomBgView.layer.cornerRadius = 10;
    _bottomBgView.layer.borderWidth = 1;
    _bottomBgView.layer.borderColor = RGB(219, 224, 231).CGColor;
    _bottomBgView.layer.masksToBounds = YES;
    _bottomBgView.frame = CGRectMake(10, CGRectGetMaxY(title.frame), JX_SCREEN_WIDTH - 20, HEIGHT*2);
    [self.wh_tableBody addSubview:_bottomBgView];
    
    
    
    WH_JXImageView* iv;
    iv = [self WH_create_WHButton:Localized(@"JX_WeChat") drawTop:NO drawBottom:NO icon:@"wechat_icon" supView:_bottomBgView click:nil];
    iv.frame = CGRectMake(MY_INSET,0, JX_SCREEN_WIDTH, HEIGHT);
    
    self.wxBindStatus = [[UISwitch alloc] init];
    self.wxBindStatus.onTintColor = RGB(0, 147, 255);
    [self.wxBindStatus addTarget:self action:@selector(bindAcount:) forControlEvents:UIControlEventTouchUpInside];
    [iv addSubview:self.wxBindStatus];
    [self.wxBindStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(iv.mas_centerY);
        make.right.mas_equalTo(_bottomBgView.mas_right).offset(-14);
    }];
    
    
    
    //添加QQ解绑操作
    WH_JXImageView* ivQQ;
    ivQQ = [self WH_create_WHButton:@"QQ" drawTop:YES drawBottom:YES icon:@"WH_QQ" supView:_bottomBgView click:nil];
    ivQQ.frame = CGRectMake(MY_INSET,CGRectGetMaxY(iv.frame), JX_SCREEN_WIDTH, HEIGHT);
    
    self.wxBindQQStatus = [[UISwitch alloc] init];
    self.wxBindQQStatus.onTintColor = RGB(0, 147, 255);
    [self.wxBindQQStatus addTarget:self action:@selector(bindQQ:) forControlEvents:UIControlEventTouchUpInside];
    [ivQQ addSubview:self.wxBindQQStatus];
    [self.wxBindQQStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ivQQ.mas_centerY);
        make.right.mas_equalTo(_bottomBgView.mas_right).offset(-14);
    }];
    
    
    //添加支付宝
    WH_JXImageView* ivAlipy;
    ivAlipy = [self WH_create_WHButton:@"支付宝" drawTop:NO drawBottom:NO icon:@"WH_QQ" supView:_bottomBgView click:nil];
    ivAlipy.frame = CGRectMake(MY_INSET,CGRectGetMaxY(ivQQ.frame), JX_SCREEN_WIDTH, HEIGHT);
    
    self.BindAlipayStatus = [[UISwitch alloc] init];
    self.BindAlipayStatus.onTintColor = RGB(0, 147, 255);
    [self.BindAlipayStatus addTarget:self action:@selector(clickswithBnt:) forControlEvents:UIControlEventTouchUpInside];
    [ivAlipy addSubview:self.BindAlipayStatus];
    [self.BindAlipayStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ivAlipy.mas_centerY);
        make.right.mas_equalTo(_bottomBgView.mas_right).offset(-14);
    }];
    
    
}
//更改手机号
- (void)changePhoneNum{
    NSLog(@"更改手机号");
    NSString *title = @"";
    if (self.userObject.phone.length) {
        title = @"是否要修改手机号";
    }else{
        title = @"是否设置手机号";
    }
    [g_App showAlert:title delegate:self tag:100 onlyConfirm:NO];
    
}

- (void)bindAcount :(UISwitch *)sender {
    self.isWXBinding = @0;
    _selectedSwitch = sender;
    if (!self.wxBindStatus.isOn) {
        [g_App showAlert:Localized(@"JX_UnbindWeChat?") delegate:self tag:1001 onlyConfirm:NO];
    }else {
        [g_App showAlert:Localized(@"JX_BindWeChat?") delegate:self tag:1002 onlyConfirm:NO];
    }
}
- (void)bindQQ: (UISwitch *)sender{
    self.isWXBinding = @1;
    _selectedSwitch = sender;
    if (!self.wxBindQQStatus.isOn) {
        [g_App showAlert:@"解绑QQ？" delegate:self tag:1001 onlyConfirm:NO];
    }else {
        [g_App showAlert:@"绑定QQ？" delegate:self tag:1002 onlyConfirm:NO];
    }
}
//绑定支付宝
- (void) clickswithBnt:(UISwitch *)sender{
    self.isWXBinding = @2;
    _selectedSwitch = sender;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == 1001) {
            if ([self.isWXBinding intValue] == 0) { //weixin
                [g_server WH_setAccountUnbind:2 toView:self];
            }else if ([self.isWXBinding intValue] == 1) {//QQ
                [g_server WH_setAccountUnbind:1 toView:self];
            }
            
        }
        if (alertView.tag == 1002) {
            if ([self.isWXBinding intValue] == 0) {
                SendAuthReq* req = [[SendAuthReq alloc] init];
                req.scope = @"snsapi_userinfo"; // @"post_timeline,sns"
                req.state = @"login";
                req.openID = @"";
                [WXApi sendAuthReq:req
                    viewController:self
                          delegate:[WXApiManager sharedManager] completion:nil];
            }else if ([self.isWXBinding intValue] == 1) {
                //绑定扣扣
                [self qqLoginMethod];
            }
        }
        if (alertView.tag == 100) {
            //更改绑定手机号
            NSString *title = @"";
            if ([g_default boolForKey:WH_ThirdPartyLogins] && !self.userObject.phone.length) {
                
                title = @"设置手机号";
            }else{
                title = @"更改绑定手机号";
            }
            
            WH_ChangeTheBoundPhoneNumber_WHViewController *boundPhoneVC = [[WH_ChangeTheBoundPhoneNumber_WHViewController alloc] init];
            [boundPhoneVC setTopTitle:title];
            [g_navigation pushViewController:boundPhoneVC animated:YES];
        }
    }else{
        if (alertView.tag == 1001 || alertView.tag == 1002) {
            [_selectedSwitch setOn:!_selectedSwitch.isOn];
        }else{
            
        }
        
    }
}


- (void)qqLoginMethod {
    qqManager = [[JX_QQ_manager alloc] init];
    [qqManager QQ_login];
    __weak typeof(self)weakSelf = self;
    qqManager.loginCallBack = ^(TencentOAuth * _Nonnull tecentOauth) {
        NSLog(@"openId : %@", tecentOauth.openId);
        __strong typeof(weakSelf)strongSelf = weakSelf;
        g_server.openId = tecentOauth.openId;
        
//        WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
//        if ([g_default objectForKey:kMY_USER_PASSWORD]) {
//            user.password = [g_default objectForKey:kMY_USER_PASSWORD];
//        }
//        NSString *areaCode = [g_default objectForKey:kMY_USER_AREACODE];
//        user.areaCode = areaCode.length > 0 ? areaCode : @"86";
//        if ([g_default objectForKey:kMY_USER_LoginName]) {
//            user.telephone = [g_default objectForKey:kMY_USER_LoginName];
//        }
        g_server.openId = tecentOauth.openId;
        //        [g_server thirdLogin:user type:1 openId:g_server.openId isLogin:YES toView:strongSelf];
        
        
        [g_server WH_otherBindUserInfoWithOpenId:tecentOauth.openId otherToken:tecentOauth.accessToken otherType:@"1" toView:strongSelf];
        
    };
}



//微信授权返回
- (void)authRespNotification:(NSNotification *)notif {
    SendAuthResp *response = notif.object;
    NSString *strMsg = [NSString stringWithFormat:@"Auth结果 code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
    NSLog(@"-------%@",strMsg);
    //绑定第三方账号
    //    [g_server getWxOpenId:response.code toView:self];
    [g_server WH_otherBindUserInfoWithOpenId:response.code otherToken:nil otherType:@"2" toView:self];
    
}




#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_UserGet]) {
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        self.userObject = user;
        
        _phoneLb.text = @"";
        _phoneLb.text = self.userObject.phone?:@"暂无";
    }
    if([aDownload.action isEqualToString:wh_act_unbind]){
        
        if ([self.isWXBinding integerValue] == 0) {
            //微信
            self.wxBindStatus.selected = NO;
        }else if ([self.isWXBinding integerValue] == 1){
            //QQ
            self.wxBindQQStatus.selected = NO;
        }else{
            //支付宝
        }
        [g_server showMsg:Localized(@"JX_UnboundSuccessfully")];
    }
    if ([aDownload.action isEqualToString:act_otherBindUserInfo]) {
        NSString *codeStr = [NSString stringWithFormat:@"%@",dict[@"code"]];
        if ([codeStr intValue] == 5) {
            [GKMessageTool showText:dict[@"msg"]];
            return;
        }
        g_server.openId = nil;
        if ([self.isWXBinding integerValue] == 0) {
            self.wxBindStatus.selected = YES;
            [g_server showMsg:Localized(@"JX_BindingSuccessfully")];
        }else if ([self.isWXBinding integerValue] == 1){
            self.wxBindQQStatus.selected = YES;
            [g_server showMsg:@"绑定QQ成功"];
        }else{
            //绑定支付宝
        }
        
    }
    if ([aDownload.action isEqualToString:wh_act_GetWxOpenId]) {
        WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
        if ([g_default objectForKey:kMY_USER_PASSWORD]) {
            user.password = [g_default objectForKey:kMY_USER_PASSWORD];
        }
        NSString *areaCode = [g_default objectForKey:kMY_USER_AREACODE];
        user.areaCode = (!IsStringNull(areaCode)) ? areaCode : @"86";
        if ([g_default objectForKey:kMY_USER_LoginName]) {
            user.telephone = [g_default objectForKey:kMY_USER_LoginName];
        }
        
        g_server.openId = [dict objectForKey:@"openid"];
        
        [g_server WH_thirdLogin:user type:2 openId:g_server.openId isLogin:YES toView:self];
    }
    
    //获取用户绑定信息状态
    if( [aDownload.action isEqualToString:wh_act_getBindInfo] ){
        if (array1.count > 0) {
            for (NSDictionary *dict in array1) {
                if ([[dict objectForKey:@"type"] intValue] == 2) {
                    //微信绑定
                    [self.wxBindStatus setOn:YES];
                }
                if ([[dict objectForKey:@"type"] intValue] == 1) {
                    //QQ绑定
                    [self.wxBindQQStatus setOn:YES];
                }
            }
        }
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    //绑定 或者解绑失败 反转switch状态
    if([aDownload.action isEqualToString:wh_act_unbind] ||[aDownload.action isEqualToString:wh_act_getBindInfo]){
        if ([self.isWXBinding integerValue] == 0) {
            //微信
            [self.wxBindStatus setOn:NO];
        }else if ([self.isWXBinding integerValue] == 1){
            //QQ
            [self.wxBindQQStatus setOn:NO];
        }else{
            //支付宝
            [self.BindAlipayStatus setOn:NO];
        }
    }
    if ([aDownload.action isEqualToString:wh_act_thirdLogin]) {
        g_server.openId = nil;
    }
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_thirdLogin]) {
        g_server.openId = nil;
    }
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


-(WH_JXImageView*)WH_create_WHButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon supView:(UIView *)sView click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    //    [_bottomBgView addSubview:btn];
    [sView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20*2+20, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(16);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, (HEIGHT-20)/2, 21, 21)];
        iv.image = [UIImage imageNamed:icon];
        [btn addSubview:iv];
    }else{
        p.frame = CGRectMake(20, 0, 100, HEIGHT);
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.3,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
    
    //    if(click){
    //        UIImageView* iv;
    //        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET, 16, 20, 20)];
    //        iv.image = [UIImage imageNamed:@"set_list_next"];
    //        [btn addSubview:iv];
    //
    //    }
    return btn;
}
@end
