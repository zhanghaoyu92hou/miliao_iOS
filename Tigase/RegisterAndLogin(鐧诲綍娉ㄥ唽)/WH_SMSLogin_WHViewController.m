//
//  WH_SMSLogin_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/7/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SMSLogin_WHViewController.h"

#import "WH_CountryCodeViewController.h"

#define HEIGHT 55

@interface WH_SMSLogin_WHViewController ()

@end

@implementation WH_SMSLogin_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_isGotoBack   = YES;
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
    
    self.title = @"短信登录";
    
    [self createContentView];
}

- (void)createContentView {
    UIView *tView = [self createViewWithOrginY:12 viewWidth:JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset viewHeight:HEIGHT*2];
    //区号
    if (!_wh_phone) {
        _wh_phone = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, 0, tView.frame.size.width - 28, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_InputPhone") font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        _wh_phone.clearButtonMode = UITextFieldViewModeWhileEditing;
        [tView addSubview:_wh_phone];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
        _wh_phone.leftView = leftView;
        _wh_phone.leftViewMode = UITextFieldViewModeAlways;
        NSString *areaStr;
        NSString *codeStr = [g_default objectForKey:kMY_USER_AREACODE];
        if (IsStringNull(codeStr)) {
            areaStr = @"+86";
        } else {
            areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
        }
        self.wh_areaCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, HEIGHT)];
        [self.wh_areaCodeBtn setTitle:areaStr forState:UIControlStateNormal];
        self.wh_areaCodeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        [self.wh_areaCodeBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        [self.wh_areaCodeBtn setImage:[UIImage imageNamed:@"down_arrow_black"] forState:UIControlStateNormal];
        self.wh_areaCodeBtn.custom_acceptEventInterval = 1.0f;
        [self.wh_areaCodeBtn addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self resetBtnEdgeInsets:self.wh_areaCodeBtn];
        [leftView addSubview:self.wh_areaCodeBtn];
    }
    
    //图片验证码
    _wh_imgCode = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, HEIGHT, CGRectGetWidth(tView.frame) -70-12-12 - 10, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    _wh_imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    [tView addSubview:_wh_imgCode];
    
    _wh_graphicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wh_graphicButton.frame = CGRectMake(CGRectGetMaxX(_wh_imgCode.frame) + 12, (HEIGHT - 35)/2, 70, 35);
    _wh_graphicButton.center = CGPointMake(_wh_graphicButton.center.x,_wh_imgCode.center.y);
    [_wh_graphicButton addTarget:self action:@selector(refreshGraphicAction:) forControlEvents:UIControlEventTouchUpInside];
    [tView addSubview:_wh_graphicButton];
    
    [tView addSubview:[self createLineViewWithOrighY:HEIGHT lineWidth:CGRectGetWidth(tView.frame)]];
    
    UIView *cView = [self createViewWithOrginY:CGRectGetMaxY(tView.frame) + 12 viewWidth:JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 115 - 10 viewHeight:HEIGHT];
    
    _wh_code = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, cView.frame.size.width, HEIGHT)];
    _wh_code.delegate = self;
    _wh_code.autocorrectionType = UITextAutocorrectionTypeNo;
    _wh_code.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _wh_code.enablesReturnKeyAutomatically = YES;
    _wh_code.font = sysFontWithSize(16);
    //      _code.borderStyle = UITextBorderStyleRoundedRect;
    _wh_code.returnKeyType = UIReturnKeyDone;
    _wh_code.clearButtonMode = UITextFieldViewModeWhileEditing;
    _wh_code.placeholder = Localized(@"JX_InputMessageCode");
    
    [cView addSubview:_wh_code];
    //      [self createLeftViewWithImage:[UIImage imageNamed:@"code"] superView:_code];
    
    _wh_send = [UIFactory WH_create_WHButtonWithTitle:Localized(@"JX_Send")
                                               titleFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15]
                                              titleColor:HEXCOLOR(0x8F9CBB)
                                                  normal:nil
                                               highlight:nil ];
    [_wh_send addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
    _wh_send.backgroundColor = HEXCOLOR(0xffffff);
    _wh_send.frame = CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 115, CGRectGetMaxY(tView.frame) + 12, 115, HEIGHT);
    [self.wh_tableBody addSubview:_wh_send];
    _wh_send.layer.borderColor = g_factory.cardBorderColor.CGColor;
    _wh_send.layer.borderWidth = g_factory.cardBorderWithd;
    _wh_send.layer.masksToBounds = YES;
    _wh_send.layer.cornerRadius = g_factory.cardCornerRadius;
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(cView.frame) + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    [loginBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    [loginBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [self.wh_tableBody addSubview:loginBtn];
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    [loginBtn addTarget:self action:@selector(loginMethod) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loginMethod {
    if([self.wh_phone.text length]<=0){
        if ([g_config.regeditPhoneOrName intValue] == 1) {
            [g_App showAlert:Localized(@"JX_InputUserAccount")];
        }else {
            [g_App showAlert:Localized(@"JX_InputPhone")];
        }
        return;
    }
    [self.view endEditing:YES];
    
    _wh_user.verificationCode = _wh_code.text;
    
    _wh_user.telephone = _wh_phone.text;
    _wh_user.areaCode = [_wh_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
//    self.isAutoLogin = NO;
    [_wait start:Localized(@"JX_Logining")];
    [g_server getSetting:self];
}

- (void)areaCodeBtnClick:(UIButton *)but{
    [self.view endEditing:YES];
    WH_CountryCodeViewController *telAreaListVC = [[WH_CountryCodeViewController alloc] init];
    telAreaListVC.wh_telAreaDelegate = self;
    telAreaListVC.wh_didSelect = @selector(didSelectTelArea:);
    //    [g_window addSubview:telAreaListVC.view];
    [g_navigation pushViewController:telAreaListVC animated:YES];
}
- (void)didSelectTelArea:(NSString *)areaCode{
    [_wh_areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
    [self resetBtnEdgeInsets:_wh_areaCodeBtn];
}

-(void)refreshGraphicAction:(UIButton *)button{
    [self getImgCodeImg];
}

-(void)getImgCodeImg{
    if(_wh_phone.text.length > 0){
        //    if ([self checkPhoneNum]) {
        //请求图片验证码
        NSString *areaCode = [_wh_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSString * codeUrl = [g_server getImgCode:_wh_phone.text areaCode:areaCode];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                UIImage * codeImage = [UIImage imageWithData:data];
                if (codeImage != nil) {
                    [_wh_graphicButton setImage:codeImage forState:UIControlStateNormal];
                    //               _imgCodeImg.image = codeImage;
                }else{
                    [g_App showAlert:Localized(@"JX_ImageCodeFailed")];
                }
                
            }else{
                NSLog(@"%@",connectionError);
                [g_App showAlert:connectionError.localizedDescription];
            }
        }];
    }else{
        
    }
    
}

//验证手机号格式
- (void)sendSMS{
    [_wh_phone resignFirstResponder];
    [_wh_imgCode resignFirstResponder];
    [_wh_code resignFirstResponder];
    
    _wh_send.enabled = NO;
    if (_wh_imgCode.text.length < 3) {
        [g_App showAlert:Localized(@"JX_inputImgCode")];
        _wh_send.enabled = YES;
        return;
    }
    
    [self onSend];
}

-(void)onSend{
    
    if (!_wh_send.selected) {
        [_wait start];
        NSString *areaCode = [_wh_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        //      _user = [WH_JXUserObject sharedUserInstance];
        _wh_user.areaCode = areaCode;
        [g_server WH_sendSMSCodeWithTel:[NSString stringWithFormat:@"%@",_wh_phone.text] areaCode:areaCode isRegister:NO imgCode:_wh_imgCode.text toView:self];
    }
    
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_SendSMS]){
        _wh_send.enabled = YES;
        _wh_send.selected = YES;
        _wh_send.userInteractionEnabled = NO;
        _wh_send.backgroundColor = HEXCOLOR(0xffffff);
        _wh_smsCode = [[dict objectForKey:@"code"] copy];
        [_wh_send setTitle:@"60s" forState:UIControlStateSelected];
        _wh_seconds = 60;
        self.wh_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_wh_send repeats:YES];
    }
    if( [aDownload.action isEqualToString:wh_act_Config]){
        
        [g_config didReceive:dict];
        [self actionConfig];
    }

}

- (void)actionConfig {
    // 自动登录失败，清除token后，重新赋值一次
    _wh_myToken = [g_default objectForKey:kMY_USER_TOKEN];
    
    if ([g_config.regeditPhoneOrName intValue] == 1) {
        _wh_areaCodeBtn.hidden = YES;
//        _forgetBtn.hidden = YES;
        _wh_phone.keyboardType = UIKeyboardTypeDefault;  // 仅支持大小写字母数字
        _wh_phone.placeholder = Localized(@"JX_InputUserAccount");
    }else {
        _wh_areaCodeBtn.hidden = NO;
        //        _forgetBtn.hidden = NO;
        _wh_phone.keyboardType = UIKeyboardTypeNumberPad;  // 限制只能数字输入，使用数字键盘
        _wh_phone.placeholder = Localized(@"JX_InputPhone");
        // 短信登录界面不显示忘记密码
//        _forgetBtn.hidden = self.isSMSLogin;
    }
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        _wh_isFirstLocation = YES;
        _wh_location = [[WH_JXLocation alloc] init];
        _wh_location.delegate = self;
        g_server.location = _wh_location;
        [g_server locate];
    }
//    if((self.isAutoLogin && !IsStringNull(_myToken)) || _isThirdLogin)
//        if (_isThirdLogin) {
//            [g_server WH_thirdLogin:_user type:2 openId:g_server.openId isLogin:NO toView:self];
//        }else {
//            [self performSelector:@selector(autoLogin) withObject:nil afterDelay:.5];
//        }
//        else if (IsStringNull(_myToken) && !IsStringNull(_phone.text) && !IsStringNull(_pwd.text)) {
//            [[JXServer sharedServer] login:_user toView:self];
//        }
//        else
//            [_wait stop];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    if([aDownload.action isEqualToString:wh_act_SendSMS]){
        [_wh_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
        _wh_send.enabled = YES;
    }else if ([aDownload.action isEqualToString:wh_act_PwdUpdate]) {
        NSString *error = [[dict objectForKey:@"data"] objectForKey:@"resultMsg"];
        
        [g_App showAlert:[NSString stringWithFormat:@"%@",error]];
        
        return WH_hide_error;
    }
    
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    _wh_send.enabled = YES;
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait stop];
}

-(void)showTime:(NSTimer*)sender{
    UIButton *but = (UIButton*)[self.wh_timer userInfo];
    _wh_seconds--;
//    __swe
    
    [but setTitle:[NSString stringWithFormat:@"%lds",(long)_wh_seconds] forState:UIControlStateSelected];
    if(_wh_seconds<=0){
        but.selected = NO;
        but.userInteractionEnabled = YES;
        but.backgroundColor = HEXCOLOR(0xffffff);
        [_wh_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
        if (self.wh_timer) {
            self.wh_timer = NULL;
            [sender invalidate];
        }
        _wh_seconds = 60;
        
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField == _wh_phone) {
        [self getImgCodeImg];
    }
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (UIView *)createViewWithOrginY:(CGFloat)orginY viewWidth:(CGFloat)width viewHeight:(CGFloat)height{
    UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, orginY, width, height)];
    [cView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_tableBody addSubview:cView];
    cView.layer.masksToBounds = YES;
    cView.layer.cornerRadius = g_factory.cardCornerRadius;
    cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cView.layer.borderWidth = g_factory.cardBorderWithd;
    return cView;
}

- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}

- (UIView *)createLineViewWithOrighY:(CGFloat)orginY lineWidth:(CGFloat)lWidth{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, lWidth, g_factory.cardBorderWithd)];
    [view setBackgroundColor:g_factory.globalBgColor];
    return view;
}


- (void)sp_didUserInfoFailed {
    NSLog(@"Get Info Failed");
}
@end
