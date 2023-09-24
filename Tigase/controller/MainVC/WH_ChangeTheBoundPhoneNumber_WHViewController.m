//
//  WH_ChangeTheBoundPhoneNumber_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/21.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_ChangeTheBoundPhoneNumber_WHViewController.h"

#import "WH_CountryCodeViewController.h"

#define HEIGHT 50

@interface WH_ChangeTheBoundPhoneNumber_WHViewController ()

@end

@implementation WH_ChangeTheBoundPhoneNumber_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.title = self.topTitle;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    [self createContentView];
}

- (void)createContentView {
    UIView *tView = [self createViewWithFrame:CGRectMake(g_factory.globelEdgeInset, 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 2*HEIGHT + 0.5) backgroungColor:HEXCOLOR(0xffffff) borderWidth:g_factory.cardBorderWithd];
    [self.wh_tableBody addSubview:tView];
    
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, CGRectGetWidth(tView.frame), 0.5)];
    [lView setBackgroundColor:g_factory.globalBgColor];
    [tView addSubview:lView];
    
    self.phone = [UIFactory WH_create_WHTextFieldWith:CGRectMake(76, 0, tView.frame.size.width - 76 - g_factory.globelEdgeInset, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:@"填写新的手机号" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
//    self.phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"填写新的手机号" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.phone.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phone.keyboardType = ([g_config.regeditPhoneOrName intValue] == 1) ? UIKeyboardTypeDefault : UIKeyboardTypeNumberPad;
    self.phone.borderStyle = UITextBorderStyleNone;
    [self.phone setTextColor:HEXCOLOR(0x333333)];
    [tView addSubview:self.phone];
    [self.phone addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSString *areaStr = @"+86";
    NSString *codeStr = [g_default objectForKey:kMY_USER_AREACODE];
    if (IsStringNull(codeStr)) {
        areaStr = @"+86";
    } else {
        areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
    }
    if (self.areaCodeBtn) {
        [self.areaCodeBtn removeFromSuperview];
    }
    self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.areaCodeBtn setFrame:CGRectMake(16, 0, 50, HEIGHT)];
    [self.areaCodeBtn setTitle:areaStr forState:UIControlStateNormal];
    self.areaCodeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    [self.areaCodeBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    self.areaCodeBtn.custom_acceptEventInterval = 1.0f;
    [self.areaCodeBtn addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self resetBtnEdgeInsets:self.areaCodeBtn];
    [tView addSubview:self.areaCodeBtn];
    
    //图片验证码
    _imgCode = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, HEIGHT + 0.5, CGRectGetWidth(tView.frame) -70-12-12 - 10, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    _imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    [tView addSubview:_imgCode];
    
    _graphicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _graphicButton.frame = CGRectMake(CGRectGetMaxX(_imgCode.frame) + 12, (HEIGHT*2 - 35)/2, 70, 35);
    //    [_graphicButton setBackgroundColor:[UIColor redColor]];
    _graphicButton.center = CGPointMake(_graphicButton.center.x,_imgCode.center.y);
    if (self.graphicImage) {
        [_graphicButton setImage:self.graphicImage forState:UIControlStateNormal];
    }
    [_graphicButton addTarget:self action:@selector(refreshGraphicAction:) forControlEvents:UIControlEventTouchUpInside];
    [tView addSubview:_graphicButton];
    
    //验证码
    UIView *yzcView = [self createViewWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(tView.frame) + 12, JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 115 - 2*g_factory.globelEdgeInset, HEIGHT) backgroungColor:HEXCOLOR(0xffffff) borderWidth:g_factory.cardBorderWithd];
    [self.wh_tableBody addSubview:yzcView];

    _code = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, yzcView.frame.size.width - 16, yzcView.frame.size.height)];
    _code.delegate = self;
    _code.autocorrectionType = UITextAutocorrectionTypeNo;
    _code.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _code.enablesReturnKeyAutomatically = YES;
    _code.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    _code.returnKeyType = UIReturnKeyDone;
    _code.clearButtonMode = UITextFieldViewModeWhileEditing;
    _code.placeholder = @"请输入验证码";
    [yzcView addSubview:_code];
    
    //短信验证码
    _send = [UIFactory WH_create_WHButtonWithTitle:Localized(@"JX_Send")
                                               titleFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15]
                                              titleColor:HEXCOLOR(0x8F9CBB)
                                                  normal:nil
                                               highlight:nil ];
    [_send addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
    _send.backgroundColor = HEXCOLOR(0xEDEFF1);
    _send.frame = CGRectMake(CGRectGetMaxX(yzcView.frame) + g_factory.globelEdgeInset, yzcView.frame.origin.y, 115, HEIGHT);
    [self.wh_tableBody addSubview:_send];
    _send.layer.borderColor = g_factory.cardBorderColor.CGColor;
    _send.layer.borderWidth = g_factory.cardBorderWithd;
    _send.layer.masksToBounds = YES;
    _send.layer.cornerRadius = g_factory.cardCornerRadius;
    
    CGFloat tempLocation = CGRectGetMaxY(yzcView.frame);
    //如果是第三方登录添加登录密码输入
    if ([self.topTitle isEqualToString:@"设置手机号"]) {
        
        UIView *pwsView = [self createViewWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(yzcView.frame) + 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 2*HEIGHT + 0.5) backgroungColor:HEXCOLOR(0xffffff) borderWidth:g_factory.cardBorderWithd];
        [self.wh_tableBody addSubview:pwsView];
        tempLocation = CGRectGetMaxY(pwsView.frame);
        
        self.loginPwsTF = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, 0, pwsView.frame.size.width - g_factory.globelEdgeInset, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:@"请输入密码" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
//        self.loginPwsTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        self.loginPwsTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.loginPwsTF.secureTextEntry = YES;
        self.loginPwsTF.borderStyle = UITextBorderStyleNone;
        [self.loginPwsTF setTextColor:HEXCOLOR(0x333333)];
        [pwsView addSubview:self.loginPwsTF];
        [self.loginPwsTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, CGRectGetWidth(pwsView.frame), 0.5)];
        [lView setBackgroundColor:g_factory.globalBgColor];
        [pwsView addSubview:lView];
        
        self.loginConfirmPwsTF = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, HEIGHT + 0.5, pwsView.frame.size.width - g_factory.globelEdgeInset, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:@"请确认密码" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
//        self.loginConfirmPwsTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请确认密码" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        self.loginConfirmPwsTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.loginConfirmPwsTF.secureTextEntry = YES;
        self.loginConfirmPwsTF.borderStyle = UITextBorderStyleNone;
        [self.loginConfirmPwsTF setTextColor:HEXCOLOR(0x333333)];
        [pwsView addSubview:self.loginConfirmPwsTF];
        [self.loginConfirmPwsTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    }
    
    UIButton *bBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bBtn setFrame:CGRectMake(g_factory.globelEdgeInset, tempLocation + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    [bBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    if ([self.topTitle isEqualToString:@"设置手机号"]) {
        [bBtn setTitle:@"绑定" forState:UIControlStateNormal];
    }else{
        [bBtn setTitle:@"更换绑定" forState:UIControlStateNormal];
    }
    [bBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [bBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size: 16]];
    [self.wh_tableBody addSubview:bBtn];
    [bBtn addTarget:self action:@selector(bindTelephoneMethod) forControlEvents:UIControlEventTouchUpInside];
    bBtn.layer.masksToBounds = YES;
    bBtn.layer.cornerRadius = g_factory.cardCornerRadius;
}

#pragma mark 绑定手机号
- (void)bindTelephoneMethod {
    //_smsCode
    if (![_code.text isEqualToString:_smsCode]) {
        [g_App showAlert:Localized(@"inputPhoneVC_MsgCodeNotOK")];
        return;
    }else{
        NSString *areaStr = _areaCodeBtn.titleLabel.text;
        if ([self.topTitle isEqualToString:@"设置手机号"]) {
            if (![self.loginPwsTF.text isEqualToString:self.loginConfirmPwsTF.text]) {
                [g_appName showAlert:@"两次输入密码不一致，请确认后绑定！"];
                return;
            }
            [g_server WH_bindPhonePassWord:_phone.text pws:self.loginPwsTF.text areaCode:[areaStr stringByReplacingOccurrencesOfString:@"+" withString:@""] smsCode:_smsCode loginType:@"0" toView:self];
            
        }else{
            [g_server WH_bindPhonePassWord:_phone.text pws:@"" areaCode:[areaStr stringByReplacingOccurrencesOfString:@"+" withString:@""] smsCode:_smsCode loginType:@"1" toView:self];
        }
    }
}


#pragma mark 选择国家区域
- (void)areaCodeBtnClick:(UIButton *)but{
    [self.view endEditing:YES];
    WH_CountryCodeViewController *telAreaListVC = [[WH_CountryCodeViewController alloc] init];
    telAreaListVC.wh_telAreaDelegate = self;
    telAreaListVC.wh_didSelect = @selector(didSelectTelArea:);
    [g_navigation pushViewController:telAreaListVC animated:YES];
    
}

- (void)didSelectTelArea:(NSString *)areaCode{
    [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
    [self resetBtnEdgeInsets:self.areaCodeBtn];
}

//获取图形验证码
-(void)refreshGraphicAction:(UIButton *)button{
    [self getImgCodeImg];
}

-(void)getImgCodeImg{
    if(_phone.text.length > 0){
        //    if ([self checkPhoneNum]) {
        //请求图片验证码
        NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSString * codeUrl = [g_server getImgCode:_phone.text areaCode:areaCode];
        NSLog(@"CODEuURL：%@" ,codeUrl);
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                UIImage * codeImage = [UIImage imageWithData:data];
                if (codeImage != nil) {
                    self.graphicImage = codeImage;
                    if (_graphicButton) {
                        [_graphicButton setImage:codeImage forState:UIControlStateNormal];
                    }
                }else{
                    [g_App showAlert:Localized(@"JX_ImageCodeFailed")];
                }
                
            }else{
                NSLog(@"%@",connectionError);
                [g_App showAlert:connectionError.localizedDescription];
            }
        }];
    }else{
        [GKMessageTool showText:@"请输入手机号"];
        return;
    }
    
}

//验证手机号格式
- (void)sendSMS{
    [_phone resignFirstResponder];
    [_imgCode resignFirstResponder];
    [_code resignFirstResponder];
    
    _send.enabled = NO;
    if (_imgCode.text.length < 3) {
        [g_App showAlert:Localized(@"JX_inputImgCode")];
        _send.enabled = YES;
        return;
    }
    
    [self onSend];
}

-(void)onSend{
    
    if (!_send.selected) {
        [GKMessageTool showMessage:@""];
        NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        //      _user = [WH_JXUserObject sharedUserInstance];
//        _user.areaCode = areaCode;
        [g_server WH_sendSMSCodeWithTel:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
    }
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    if([aDownload.action isEqualToString:wh_act_SendSMS]){
        [GKMessageTool hideMessage];
        [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
        
        _send.enabled = YES;
        _send.selected = YES;
        _send.userInteractionEnabled = NO;
        _send.backgroundColor = HEXCOLOR(0xEDEFF1);
        
        _smsCode = [[dict objectForKey:@"code"] copy];
        
        [_send setTitle:@"60s" forState:UIControlStateSelected];
        _seconds = 60;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_send repeats:YES];
        
//        _phoneStr = _phone.text;
        _imgCodeStr = _imgCode.text;
    }else if ([aDownload.action isEqualToString:act_otherBindPhonePassWord]) {
        [GKMessageTool showText:@"绑定成功"];
        if ([self.topTitle isEqualToString:@"设置手机号"]) {
            [g_default setObject:[g_server WH_getMD5StringWithStr:self.loginPwsTF.text] forKey:kMY_USER_PASSWORD];
            [g_default synchronize];
        }
        g_myself.phone = _phone.text;
        //回调
        [self actionQuit];
        [g_notify postNotificationName:@"WH_ChangeTheBoundPhoneNumber_Notification" object:nil];
    }
}
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_SendSMS]){
        [GKMessageTool hideMessage];
        _send.enabled = YES;
        [_send setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
//        [g_App showAlert:Localized(@"JX_ImageCodeError")];
        [self getImgCodeImg];
        
    }
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_SendSMS]) {
        [GKMessageTool hideMessage];
        _send.enabled = YES;
    }
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait stop];
}

-(void)showTime:(NSTimer*)sender{
    UIButton *but = (UIButton*)[_timer userInfo];
    _seconds--;
    [but setTitle:[NSString stringWithFormat:@"%lds",(long)_seconds] forState:UIControlStateSelected];
    if (_isSendFirst) {
        _isSendFirst = NO;
    }
    
    if(_seconds<=0){
        but.selected = NO;
        but.userInteractionEnabled = YES;
        but.backgroundColor = HEXCOLOR(0xffffff);
        [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
        if (_timer) {
            _timer = nil;
            [sender invalidate];
        }
        _seconds = 60;
        
    }
}

- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}

- (void) textFieldDidChange:(UITextField *) TextField {
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.imgCode]) {
        [self getImgCodeImg];
    }
    return YES;
}

- (UIView *)createViewWithFrame:(CGRect)frame backgroungColor:(UIColor *)bColor borderWidth:(CGFloat)width{
    UIView *tView = [[UIView alloc] initWithFrame:frame];
    [tView setBackgroundColor:bColor];
    tView.layer.cornerRadius = g_factory.cardCornerRadius;
    tView.layer.masksToBounds = YES;
    tView.layer.borderWidth = width;
    if (width > 0) {
        tView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    }
    [self.wh_tableBody addSubview:tView];
    return tView;
}

@end
