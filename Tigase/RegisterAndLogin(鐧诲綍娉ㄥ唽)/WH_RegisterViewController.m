//
//  WH_Register_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/7/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_RegisterViewController.h"

#import "WH_LoginViewController.h"
#import "WH_PSRegisterBaseVC.h"
#import "WH_webpage_WHVC.h"
#import "WH_SegmentSwitch.h"
#import "WH_LoginTextField.h"
#import "RITLUtility.h"

@interface WH_RegisterViewController ()
{
    CGFloat cellHeight;
    UIView *whiteBackView; //!<  白色背景View
    NSInteger debugRegist;// !< 测试用的登录类型
    WH_SegmentSwitch *registSwitch;
    NSString *userName; //!< 用户名/手机号
}
@property (nonatomic, strong) UIView *firstLineView; //!< 用户名和密码之间的线
@property (nonatomic, strong) UIView *secondLineView; //!< 密码和图片验证码之间的线
@property (nonatomic, strong) UIButton *registButton; //!< 注册按钮
@property (nonatomic, strong) UIButton *loginButton; //!< 以后账号去登录按钮
@property (nonatomic, strong) UIView *smsBackView; //!< 短信验证码背景
@property (nonatomic, strong) WH_LoginTextField *pwdTextField; //!< 密码输入框
@property (nonatomic, strong) WH_LoginTextField *invitedField; //!< 邀请码
@end

@implementation WH_RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_isGotoBack = NO;
    cellHeight = 55;
    [self createHeadAndFoot];
    [self setUpTitleView];
    [self.wh_tableHeader addSubview:[self closeButton]];
    [self createContentView];
    [self getImgCodeImg];
    registSwitch.wh_currentIndex = self.registType == 0 ? 1 : 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
    [self.wh_tableBody addGestureRecognizer:tap];
}

- (void)setUpTitleView {
    if ([g_config.regeditPhoneOrName integerValue] == 2 && self.isBindPhonePws == NO) {//[g_config.regeditPhoneOrName integerValue]
        registSwitch = [[WH_SegmentSwitch alloc] initWithFrame:CGRectMake(92, JX_SCREEN_TOP - 8 - 28, 192, 28) titles:@[Localized(@"AccountRegist"), Localized(@"PhoneNoRegist")] slideColor:HEXCOLOR(0x0093FF)];
        __weak __typeof(self) weakSelf = self;
        registSwitch.WH_onClickBtn = ^(NSInteger index) {
            weakSelf.phoneTextField.text = @"";
            weakSelf.pwdTextField.text = @"";
            weakSelf.registType = index == 0 ? 1 : 0;
            [weakSelf reloadViewsWithAnimation];
        };
        [self.wh_tableHeader addSubview:registSwitch];
    }else {
        self.title = self.isBindPhonePws ? Localized(@"BindID") : (self.registType == 1 ? Localized(@"AccountRegist") : Localized(@"REGISTERS"));
    }
}

/**
    更换登录方式，重新布局视图
 */
- (void)reloadViewsWithAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.registType == 1) {
            [self reloadViewsForAccount];
        }else{
            [self reloadViewsForPhoneLogin];
        }
    } completion:^(BOOL finished) {
        [self setUpPhoneTextPlaceHolderAttribute];
    }];
}

//头部视图
- (UIButton *)closeButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_TOP - 36, 28, 28)];
    [btn setImage:[UIImage imageNamed:@"WH_Close_Blue"] forState:UIControlStateNormal];
     [btn setImage:[UIImage imageNamed:@"WH_Close_Blue"] forState:UIControlStateHighlighted];
    [self.wh_tableBody addSubview:btn];
    [btn addTarget:self action:@selector(goBackMethod) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)createContentView {
    
    CGFloat whiteBackHeight = (self.registType == 0) ? cellHeight*3 : cellHeight*2; //!< 白色视图高度
 
    whiteBackView = [self createViewWithOrginY:12 viewWidth:JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset viewHeight:whiteBackHeight];
    [self.wh_tableBody addSubview:whiteBackView];
    
    [whiteBackView addSubview:self.phoneTextField];
    [whiteBackView addSubview:self.firstLineView];
    [whiteBackView addSubview:self.pwdTextField];
    
    //图片验证码
    if (self.registType == 0 ) {
        [whiteBackView addSubview:self.secondLineView];
        [whiteBackView addSubview:self.imgVerifyTextField];
        [whiteBackView addSubview:self.getGraphicButton];
        [whiteBackView addSubview:[self createLineViewWithOrginY:cellHeight lineWidth:whiteBackView.width]];
//        self.areaCodeBtn.width = 0;
    }
    
    //短信验证码
    //[g_config.isOpenSMSCode boolValue] &&
    if ( self.registType == 0) {
        [self.wh_tableBody addSubview:self.smsBackView];
        [self.wh_tableBody insertSubview:self.smsBackView belowSubview:whiteBackView];
    }
    if ([g_config.registerInviteCode integerValue] != 0) {
         [self.wh_tableBody addSubview:self.invitedField];
        self.invitedField.top = whiteBackView.bottom + 12;
    }
    
    [self setUpPhoneTextPlaceHolderAttribute];
    self.registButton.top = [self getRegistButtonOriginY];
    [self.wh_tableBody addSubview:self.registButton];
    if (!self.isBindPhonePws) {
        [self.wh_tableBody addSubview:self.loginButton];
    }
    [self loadServiceProtocalAndPrivacyGuideView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadViewsWithAnimation];
}
#pragma mark ----- 更新布局
/**
    设置用户名输入框的PlaceHolder
 */
- (void)setUpPhoneTextPlaceHolderAttribute {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.registType == 1) {
            [self reloadPhoneTextFieldStyleForAccout];
        }else{
            [self reloadPhoneTextFieldStyleForPhoneLogin];
//            if ([g_config.isOpenSMSCode boolValue]) {
//            [self.wh_tableBody addSubview:self.smsBackView];
            [whiteBackView addSubview:self.secondLineView];
            [whiteBackView addSubview:self.imgVerifyTextField];
            [whiteBackView addSubview:self.getGraphicButton];
//            }
            if ([g_config.registerInviteCode integerValue] != 0) {
                [self.wh_tableBody addSubview:self.invitedField];
            }
        }
    }];
}
- (void)reloadViewsForPhoneLogin {
    whiteBackView.height = cellHeight*3;
    [self.wh_tableBody addSubview:self.smsBackView];
    [self.wh_tableBody insertSubview:self.smsBackView belowSubview:whiteBackView];
    if ([g_config.registerInviteCode integerValue] != 0) {
        [self.wh_tableBody addSubview:self.invitedField];
        [self.wh_tableBody insertSubview:self.invitedField atIndex:0];
        self.invitedField.bottom = self.smsBackView.bottom + 12;
    }
    self.registButton.top = [self getRegistButtonOriginY];
    self.loginButton.top = self.registButton.bottom + 12;
    self.smsBackView.top = whiteBackView.bottom + 12;
    self.invitedField.top = self.smsBackView.bottom + 12;
    self.secondLineView.hidden = NO;
}
- (void)reloadViewsForAccount {
    whiteBackView.height = cellHeight*2;
    self.secondLineView.hidden = YES;
    [self.getGraphicButton removeFromSuperview];
    if ([g_config.registerInviteCode integerValue] != 0) {
         self.invitedField.top = whiteBackView.bottom+12;
    }
    self.smsBackView.bottom = whiteBackView.bottom;
    self.registButton.top = [self getRegistButtonOriginY];
    self.loginButton.top = self.registButton.bottom+12;
}
- (void)reloadPhoneTextFieldStyleForPhoneLogin {
    self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPhone") attributes:@{NSForegroundColorAttributeName: HEXCOLOR(0xCCCCCC)}];
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneTextField.leftView = self.areaCodeBtn;
}
- (void)reloadPhoneTextFieldStyleForAccout {
    self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"SetAccountName") attributes:@{NSForegroundColorAttributeName: HEXCOLOR(0xCCCCCC)}];
    self.phoneTextField.keyboardType = UIKeyboardTypeDefault;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.pwdTextField.height)];
    leftView.backgroundColor = self.pwdTextField.backgroundColor;
    self.phoneTextField.leftView = leftView;
}
/**
    获取登录按钮的OriginY
 @return Y起点
 */
- (CGFloat)getRegistButtonOriginY {
    CGFloat lHeight = whiteBackView.bottom + 20;
    if (self.registType == 0 ) {
//        if ([g_config.isOpenSMSCode boolValue]) {
            lHeight += cellHeight+12;
//        }
        if ([g_config.registerInviteCode integerValue] != 0) {
            lHeight += cellHeight+12;
        }
    }else {
        if ([g_config.registerInviteCode integerValue] != 0) {
            lHeight += cellHeight+12;
        }
    }
    return lHeight;
}
- (void)loadServiceProtocalAndPrivacyGuideView {
    //协议
    UIButton *agreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreBtn setFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 2*JX_SCREEN_BOTTOM - 20, JX_SCREEN_WIDTH, 40)];
    [agreBtn addTarget:self action:@selector(agrementMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableBody addSubview:agreBtn];
    
    UITextView *agreView = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, agreBtn.frame.size.width, agreBtn.frame.size.height-10)];
    agreView.userInteractionEnabled = NO;
    agreView.editable = NO;
    //    agreView.delegate = self;
    agreView.textContainer.lineFragmentPadding = 0.0;
    agreView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    agreView.backgroundColor = self.wh_tableBody.backgroundColor;
    agreView.linkTextAttributes = @{NSForegroundColorAttributeName:HEXCOLOR(0x0093FF)};
    [agreBtn addSubview:agreView];
    
    NSString *rangeStr = Localized(@"《Privacy Policy and Terms of Service》");
    NSString *protocolStr = [NSString stringWithFormat:@"%@ %@" , Localized(@"JX_ByRegisteringYouAgree"), Localized(@"《Privacy Policy and Terms of Service》")];
    NSRange privacyRange = [protocolStr rangeOfString:rangeStr];
    
    NSMutableAttributedString *privacyMutableAttrStr = [[NSMutableAttributedString alloc] initWithString:protocolStr attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size: 9],NSForegroundColorAttributeName:HEXCOLOR(0x969696)}];
    
    //给需要 点击事件的部分添加链接
    [privacyMutableAttrStr addAttribute:NSLinkAttributeName value:@"privacy://" range:privacyRange];
    //    [privacyMutableAttrStr addAttribute:NSLinkAttributeName value:@"privacy2://" range:privacyRange2];
    
    agreView.attributedText = privacyMutableAttrStr;
    agreView.textAlignment = NSTextAlignmentCenter;
    
    
//    [agreBtn setHidden:YES];
}
#pragma mark --- Lazy Load
- (UIView *)smsBackView {
    if (!_smsBackView) {
        _smsBackView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, whiteBackView.top, whiteBackView.width, cellHeight)];
        _smsBackView.backgroundColor = self.wh_tableBody.backgroundColor;
        [_smsBackView addSubview:self.smsVerifyTextfield];
        [_smsBackView addSubview:self.sendSMSButton];
    }
    return _smsBackView;
}
- (UIView *)firstLineView {
    if (!_firstLineView) {
        _firstLineView = [self createLineViewWithOrginY:self.phoneTextField.bottom lineWidth:whiteBackView.width];
    }
    return _firstLineView;
}
- (UIView *)secondLineView {
    if (!_secondLineView) {
        _secondLineView = [self createLineViewWithOrginY:self.pwdTextField.bottom lineWidth:whiteBackView.width];
    }
    return _secondLineView;
}
- (UITextField *)smsVerifyTextfield {
    if (!_smsVerifyTextfield) {
        _smsVerifyTextfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.smsBackView.width-115-10, cellHeight)];
        _smsVerifyTextfield.delegate = self;
        _smsVerifyTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
        _smsVerifyTextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _smsVerifyTextfield.enablesReturnKeyAutomatically = YES;
        _smsVerifyTextfield.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        _smsVerifyTextfield.returnKeyType = UIReturnKeyDone;
        _smsVerifyTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        _smsVerifyTextfield.placeholder = Localized(@"JX_InputMessageCode");
        _smsVerifyTextfield.backgroundColor = [UIColor whiteColor];
        _smsVerifyTextfield.layer.masksToBounds = YES;
        _smsVerifyTextfield.layer.cornerRadius = g_factory.cardCornerRadius;
        _smsVerifyTextfield.layer.borderWidth = g_factory.cardBorderWithd;
        _smsVerifyTextfield.layer.borderColor = g_factory.cardBorderColor.CGColor;
        _smsVerifyTextfield.keyboardType = UIKeyboardTypeNumberPad;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, cellHeight)];
        _smsVerifyTextfield.leftView = leftView;
        _smsVerifyTextfield.leftViewMode = UITextFieldViewModeAlways;
    }
    return _smsVerifyTextfield;
}
- (UITextField *)phoneTextField {
    if (!_phoneTextField) {
        _phoneTextField = [UIFactory WH_create_WHTextFieldWith:CGRectMake(0, 0, whiteBackView.width, cellHeight) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_InputPhone") font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.borderStyle = UITextBorderStyleNone;
        [_phoneTextField setTextColor:HEXCOLOR(0x333333)];
        [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _phoneTextField.leftViewMode = UITextFieldViewModeAlways;
        _phoneTextField.leftView = self.areaCodeBtn;
    }
    return _phoneTextField;
}
- (WH_LoginTextField *)pwdTextField {
    if (!_pwdTextField) {
        _pwdTextField = [[WH_LoginTextField alloc] initWithFrame:CGRectMake(0, self.firstLineView.bottom, whiteBackView.width, cellHeight)];
        _pwdTextField.delegate = self;
        _pwdTextField.fieldType = LoginFieldPassWordType;
        _pwdTextField.returnKeyType = UIReturnKeyDone;
        [_pwdTextField setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        [_pwdTextField setTextColor:HEXCOLOR(0x333333)];
        _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"RegistSetPass") attributes:@{NSForegroundColorAttributeName: HEXCOLOR(0xCCCCCC)}];
    }
    return _pwdTextField;
}
- (UIButton *)areaCodeBtn {
    if (!_areaCodeBtn) {
        NSString *areaStr = @"+86";
        NSString *codeStr = [g_default objectForKey:kMY_USER_AREACODE];
        if (!IsStringNull(codeStr)) {
            areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
        }
        _areaCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, cellHeight)];
        [_areaCodeBtn setTitle:areaStr forState:UIControlStateNormal];
        _areaCodeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        [_areaCodeBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _areaCodeBtn.custom_acceptEventInterval = 1.0f;
        [_areaCodeBtn addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self resetBtnEdgeInsets:_areaCodeBtn];
    }
    return _areaCodeBtn;
}
- (UITextField *)imgVerifyTextField {
    if (!_imgVerifyTextField) {
        _imgVerifyTextField = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, cellHeight*2, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset -70-12-12 - 10, cellHeight) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        _imgVerifyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _imgVerifyTextField;
}
- (UIButton *)getGraphicButton {
    if (!_getGraphicButton) {
        _getGraphicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _getGraphicButton.frame = CGRectMake(self.imgVerifyTextField.right + 12, (cellHeight*2 - 35)/2, 70, 35);
        //    [_graphicButton setBackgroundColor:[UIColor redColor]];
        _getGraphicButton.center = CGPointMake(_getGraphicButton.center.x,self.imgVerifyTextField.center.y);
        if (self.graphicImage) {
            [_getGraphicButton setImage:self.graphicImage forState:UIControlStateNormal];
        }
        [_getGraphicButton addTarget:self action:@selector(refreshGraphicAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getGraphicButton;
}
- (UIButton *)sendSMSButton{
    if (!_sendSMSButton) {
        _sendSMSButton = [UIFactory WH_create_WHButtonWithTitle:Localized(@"GET_VERIFICATION_CODE")
                                                   titleFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15]
                                                  titleColor:HEXCOLOR(0x8F9CBB)
                                                      normal:nil
                                                   highlight:nil ];
        [_sendSMSButton addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
        _sendSMSButton.backgroundColor = HEXCOLOR(0xffffff);
        _sendSMSButton.frame = CGRectMake(self.smsBackView.width - 115, 0, 115, cellHeight);
        
        _sendSMSButton.layer.borderColor = g_factory.cardBorderColor.CGColor;
        _sendSMSButton.layer.borderWidth = g_factory.cardBorderWithd;
        _sendSMSButton.layer.masksToBounds = YES;
        _sendSMSButton.layer.cornerRadius = g_factory.cardCornerRadius;
    }
    return _sendSMSButton;
}
- (UIButton *)registButton {
    if (!_registButton) {
        NSString *str = self.isBindPhonePws ? Localized(@"BIND") : Localized(@"REGISTERS");
        _registButton = [self createButtonWithOrginY:whiteBackView.bottom buttonTititle:str buttonTag:0 selector:@selector(registerMethod)];
    }
    return _registButton;
}
- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [self createButtonWithOrginY:(self.registButton.bottom + 12) buttonTititle:Localized(@"JX_HaveAccountLogin") buttonTag:1 selector:@selector(goLoginMethod)];
    }
    return _loginButton;
}
- (WH_LoginTextField *)invitedField {
    if (!_invitedField) {
        _invitedField = [[WH_LoginTextField alloc] initWithFrame:CGRectMake(10, whiteBackView.bottom+12, JX_SCREEN_WIDTH-2*10, cellHeight)];
        _invitedField.delegate = self;
        _invitedField.fieldType = LoginFieldInviteCodeType;
        _invitedField.layer.cornerRadius = g_factory.cardCornerRadius;
        _invitedField.layer.borderColor = g_factory.cardBorderColor.CGColor;
        _invitedField.layer.borderWidth = g_factory.cardBorderWithd;
        _invitedField.clipsToBounds = YES;
    }
    return _invitedField;
}
#pragma mark 获取协议
- (void)agrementMethod {
    WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
    webVC.url = [self protocolUrl];
    webVC.isSend = NO;
    webVC = [webVC init];
    webVC.isGoBack = YES;
    [g_navigation pushViewController:webVC animated:YES];
}

-(NSString *)protocolUrl{
    NSString * protocolStr = [NSString stringWithFormat:@"http://%@/agreement/",PrivacyAgreementBaseApiUrl];
    NSString * lange = g_constant.sysLanguage;
    if (![lange isEqualToString:ZHHANTNAME] && ![lange isEqualToString:NAME]) {
        lange = ENNAME;
    }
    return [NSString stringWithFormat:@"%@%@.html",protocolStr,lange];
}

//获取图形验证码
-(void)refreshGraphicAction:(UIButton *)button{
    [self getImgCodeImg];
}

-(void)getImgCodeImg{
    if(_phoneTextField.text.length > 0){
        //    if ([self checkPhoneNum]) {
        //请求图片验证码
        NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSString * codeUrl = [g_server getImgCode:_phoneTextField.text areaCode:areaCode];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                UIImage * codeImage = [UIImage imageWithData:data];
                if (codeImage != nil) {
                    self.graphicImage = codeImage;
                    if (_getGraphicButton) {
                        [_getGraphicButton setImage:codeImage forState:UIControlStateNormal];
                    }
                }else{
                    [GKMessageTool showError:Localized(@"JX_ImageCodeFailed")];
                }
            }else{
                NSLog(@"%@",connectionError);
                [GKMessageTool showError:connectionError.localizedDescription];
            }
        }];
    }
}

//验证手机号格式
- (void)sendSMS{
    [_phoneTextField resignFirstResponder];
    [_imgVerifyTextField resignFirstResponder];
    [_smsVerifyTextfield resignFirstResponder];
    
    _sendSMSButton.enabled = NO;
    if (_imgVerifyTextField.text.length < 3) {
        [GKMessageTool showTips:Localized(@"JX_inputImgCode")];
        _sendSMSButton.enabled = YES;
        return;
    }
    
    [self onSend];
}

-(void)onSend{
    
    [_wait start];
    NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    //      _user = [WH_JXUserObject sharedUserInstance];
    _user.areaCode = areaCode;
    [g_server WH_sendSMSCodeWithTel:_phoneTextField.text areaCode:areaCode isRegister:YES imgCode:_imgVerifyTextField.text toView:self];
    
}

#pragma mark 注册
- (void)registerMethod {
    [self.view endEditing:YES];
    _isSkipSMS = NO;
    BOOL shouldRegist = [self isShouldRegist:_phoneTextField.text];
    
    if (self.registType == 0) {
        NSString *areaCode =[_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        if (IsStringNull(userName)) {//手机号为空
            [GKMessageTool showTips:Localized(@"PhoneRegistFormatError")];
            return;
        } else {//手机号不为空
            if ([areaCode isEqualToString:@"86"] && ![RITLUtility isStringMobileNumber:userName]) {//区号为86时,验证手机号
                [GKMessageTool showTips:Localized(@"PhoneRegistFormatError")];
                return;
            }
        }
        if([_smsVerifyTextfield.text length]<6 || ![_smsCode isEqualToString:_smsVerifyTextfield.text]) {
            [GKMessageTool showTips:Localized(@"inputPhoneVC_MsgCodeNotOK")];
            return;
        }
        if (IsStringNull(_imgCodeStr)) {
            [GKMessageTool showTips:Localized(@"JX_ImageCodeErrorGetAgain")];
            return;
        }
    }else {
        if (userName.length < 5 || userName.length > 16) {
            [GKMessageTool showTips:Localized(@"UsernameRegistFomatError")];
            return;
        }
        if ([userName mj_isPureInt]) {
            [GKMessageTool showTips:Localized(@"UsernameShoudnotPureInt")];
            return;
        }
    }
    if (_pwdTextField.text.length < 6) {
        [GKMessageTool showTips:Localized(@"PasswordRegistFomatError")];
        return;
    }
    if ([g_config.registerInviteCode integerValue] == 1 && [self.invitedField.text length] == 0) {
        [GKMessageTool showTips:Localized(@"JX_EnterInvitationCode")];
        return;
    }
    if (self.isBindPhonePws) { //绑定手机号
        NSString *areaStr = _areaCodeBtn.titleLabel.text;
        [g_server WH_bindPhonePassWord:_phoneTextField.text pws:_pwdTextField.text areaCode:[areaStr stringByReplacingOccurrencesOfString:@"+" withString:@""] smsCode:_smsCode loginType:@"0" toView:self];
        return;
    }
    
    if (shouldRegist) {
        [_wait start];
        if (self.registType == 0) {
            NSString *areaCode =[_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
            NSDictionary *params = @{@"telephone":_phoneTextField.text, @"smsCode": self.smsVerifyTextfield.text, @"areaCode": areaCode};
            NSMutableDictionary *mutParams = [[NSMutableDictionary alloc] initWithDictionary:params];
            if (!IsStringNull(self.invitedField.text)) {
                [mutParams setObject:self.invitedField.text forKey:@"inviteCode"];
            }
            [g_server checkPhoneNum:mutParams toView:self];
        }else {
            [g_server checkUser:_phoneTextField.text inviteCode:self.invitedField.text toView:self];
        }
    }
}

//验证用户名或手机号不能为空
- (BOOL)isShouldRegist:(NSString *)number{
   // g_config.isOpenSMSCode boolValue] &&
    if ([number length] == 0) {
        [GKMessageTool showTips:Localized( self.registType == 0 ? @"JX_InputPhone" : @"JX_InputUserAccount")];
        return NO;
    }
    return YES;
}

#pragma mark 已有账号
- (void)goLoginMethod {
//    WH_LogoutAndLogin_WHViewController *vc = [[WH_LogoutAndLogin_WHViewController alloc] init];
    WH_LoginViewController *vc = [[WH_LoginViewController alloc] init];
    vc.isSwitchUser= NO;
    vc.isPushEntering = YES;
    //返回上一级
    UIViewController *goVC = [g_navigation.subViews objectAtIndex:(g_navigation.subViews.count >= 2 ? (g_navigation.subViews.count - 2):0)];
    [g_navigation popToViewController:[goVC class] animated:YES];
}

- (void) textFieldDidChange:(UITextField *) TextField {
    
}

#pragma mark 返回上一级
- (void)goBackMethod {
    [self actionQuit];
}

#pragma mark -------- UITextField Delegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _phoneTextField) {
        userName = textField.text;
        if (self.registType == 0) {
            NSString *areaCode =[_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
            if (IsStringNull(textField.text)) {//手机号为空
                [GKMessageTool showTips:Localized(@"PhoneRegistFormatError")];
                return;
            } else {//手机号不为空
                if ([areaCode isEqualToString:@"86"] && ![RITLUtility isStringMobileNumber:textField.text]) {//区号为86时,验证手机号
                    [GKMessageTool showTips:Localized(@"PhoneRegistFormatError")];
                    return;
                }
            }
            [self getImgCodeImg];
        }
    }else if (textField == _imgVerifyTextField) {
        _imgCodeStr = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_otherBindPhonePassWord]){
        [GKMessageTool showText:@"绑定成功"];
        [g_default setObject:[g_server WH_getMD5StringWithStr:_pwdTextField.text] forKey:kMY_USER_PASSWORD];
        [g_default synchronize];
        g_myself.phone = _phoneTextField.text;
        //回调
        [self actionQuit];
    }
    if([aDownload.action isEqualToString:wh_act_SendSMS]){
        [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
        
        _sendSMSButton.enabled = NO;
        _sendSMSButton.backgroundColor = HEXCOLOR(0xEDEFF1);
        
        _smsCode = [[dict objectForKey:@"code"] copy];
        
        [_sendSMSButton setTitle:@"60s" forState:UIControlStateSelected];
        _seconds = 60;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_sendSMSButton repeats:YES];
        
        userName = _phoneTextField.text;
    }
    if([aDownload.action isEqualToString:wh_act_CheckPhone]){
        if (self.isCheckToSMS) {
            self.isCheckToSMS = NO;
            [self onSend];
            return;
        }
        if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1 && self.registType == 0) {
            [self verifySMSByLocal];
        }else {
            [self pushToBasicInfoViewController];
        }
    }
}

-(void)showTime:(NSTimer*)sender{
    UIButton *but = (UIButton*)[_timer userInfo];
    _seconds--;
    [but setTitle:[NSString stringWithFormat:@"%lds",(long)_seconds] forState:UIControlStateNormal];
    if(_seconds <= 0){
        but.enabled = YES;
        but.backgroundColor = HEXCOLOR(0xffffff);
        [_sendSMSButton setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
        if (_timer) {
            [sender invalidate];
            _timer = nil;
        }
        _seconds = 60;
    }
}

#pragma mark - 请求失败回调

-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_SendSMS]){
        _sendSMSButton.enabled = YES;
        [_sendSMSButton setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
        [GKMessageTool showError:dict[@"resultMsg"]];
        [self getImgCodeImg];
        return WH_hide_error;
    }
    
    if([aDownload.action isEqualToString:act_otherBindPhonePassWord]){
        
    }
    
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_SendSMS]){
        _sendSMSButton.enabled = YES;
        return WH_hide_error;
    }
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
}

#pragma mark----验证短信验证码
-(void)verifySMSByLocal{
    if([_phoneTextField.text length]<=0){
        [GKMessageTool showTips:Localized(@"JX_InputPhone")];
        return;
    }
    if (!_isSkipSMS) {
        if([_smsVerifyTextfield.text length]<6){
            [GKMessageTool showTips:Localized(@"inputPhoneVC_MsgCodeNotOK")];
            return;
        }
        
        if([_smsCode length]<6){
            [GKMessageTool showTips:@"请输入正确的短信验证码"];
            return;
        }
        if (!([userName isEqualToString:_phoneTextField.text] && [_smsCode isEqualToString:_smsVerifyTextfield.text])) {
            if (![userName isEqualToString:_phoneTextField.text]) {
                [GKMessageTool showTips:Localized(@"JX_No.Changed,Again")];
            }else if (![_imgCodeStr isEqualToString:_imgVerifyTextField.text]) {
                [GKMessageTool showTips:Localized(@"JX_ImageCodeErrorGetAgain")];
            }else if (![_smsCode isEqualToString:_smsVerifyTextfield.text]) {
                [GKMessageTool showTips:Localized(@"inputPhoneVC_MsgCodeNotOK")];
            }
            return;
        }
    }
    
    
    [self.view endEditing:YES];
    if (!_isSkipSMS) {
        if([_smsVerifyTextfield.text isEqualToString:_smsCode]){
            self.isSmsRegister = YES;
            [self setUserInfo];
        }
        else
            [GKMessageTool showTips:Localized(@"inputPhoneVC_MsgCodeNotOK")];
    } else {
        self.isSmsRegister = NO;
        [self setUserInfo];
    }
    
}

-(void)pushToBasicInfoViewController {
    WH_JXUserObject* user = [[WH_JXUserObject alloc] init];
    user.telephone = _phoneTextField.text;
    [g_default setObject:user.telephone forKey:kMY_USER_LoginName];//下次进入登录页面时需要用来判断是否显示头像
    user.password  = [g_server WH_getMD5StringWithStr:_pwdTextField.text];
    user.areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];;
    //    user.companyId = [NSNumber numberWithInt:self.isCompany];
    WH_PSRegisterBaseVC* vc = [WH_PSRegisterBaseVC alloc];
    vc.isSmsRegister = (self.registType == 0);
    vc.inviteCode = self.invitedField.text;
    vc.registType = self.registType;
    vc.iswWxinLogin = self.iswWxinLogin;//是否是第三方登录
    vc.user       = user;
    vc.smsCode = _smsCode;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
    [self actionQuit];
}

- (void)setUserInfo {
    
    WH_JXUserObject* user = [[WH_JXUserObject alloc] init];
    user.telephone = _phoneTextField.text;
    user.password  = [g_server WH_getMD5StringWithStr:_pwdTextField.text];
    user.areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];;
    //    user.companyId = [NSNumber numberWithInt:self.isCompany];
    WH_PSRegisterBaseVC* vc = [WH_PSRegisterBaseVC alloc];
    vc.registType = self.registType;
    vc.isSmsRegister = self.isSmsRegister;
    vc.user       = user;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    [self actionQuit];
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

- (UIView *)createLineViewWithOrginY:(CGFloat)orginY lineWidth:(CGFloat)width {
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, width, g_factory.cardBorderWithd)];
    [lView setBackgroundColor:g_factory.globalBgColor];
    return lView;
}

- (UIButton *)createButtonWithOrginY:(CGFloat)orginY buttonTititle:(NSString *)bTitle buttonTag:(NSInteger)tag selector:(SEL)method{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(g_factory.globelEdgeInset, orginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    [button setTitle:bTitle forState:UIControlStateNormal];
    if (tag == 0) {
        [button setBackgroundColor:HEXCOLOR(0x0093FF)];
        [button setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
        [button setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateHighlighted];
        
    }else{
        [button setBackgroundColor:HEXCOLOR(0xffffff)];
        [button setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
        [button setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateHighlighted];
        
        button.layer.borderColor = g_factory.cardBorderColor.CGColor;
        button.layer.borderWidth = g_factory.cardBorderWithd;
    }
    [button.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = g_factory.cardCornerRadius;
    
    [button addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)createViewWithOrginY:(CGFloat)orginY viewWidth:(CGFloat)vWidth viewHeight:(CGFloat)vHeight{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, orginY, vWidth, vHeight)];
    [view setBackgroundColor:HEXCOLOR(0xffffff)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = g_factory.cardCornerRadius;
    view.layer.borderWidth = g_factory.cardBorderWithd;
    view.layer.borderColor = g_factory.cardBorderColor.CGColor;
    return view;
}

- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}

- (void)resignKeyboard {
    [self.view endEditing:YES];
}
@end
