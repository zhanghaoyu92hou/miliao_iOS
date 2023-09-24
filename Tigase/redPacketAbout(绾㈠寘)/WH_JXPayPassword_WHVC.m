//
//  WH_JXPayPassword_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXPayPassword_WHVC.h"
#import "UIImage+WH_Color.h"
#import "WH_JXMoneyMenu_WHViewController.h"
#import "WH_JXTextField.h"
#import "WH_JXUserObject.h"
#import "WH_JXSendRedPacket_WHViewController.h"
#import "WH_JXCashWithDraw_WHViewController.h"
#import "WH_JXTransfer_WHViewController.h"
#import "WH_JXInputMoney_WHVC.h"
#import "WH_webpage_WHVC.h"
#import "WH_JXMyMoney_WHViewController.h"
#import "WH_JXSecuritySetting_WHVC.h"
#import "WH_ForgetPayPsw_WHVC.h"

#import "WH_MyWallet_WHViewController.h"

#define kDotSize CGSizeMake (10, 10) //密码点的大小
#define kDotCount 6  //密码个数
#define K_Field_Height 45  //每一个输入框的高度

@interface WH_JXPayPassword_WHVC () <UITextFieldDelegate>
@property (nonatomic, strong) WH_JXTextField *textField;
@property (nonatomic, strong) NSMutableArray *dotArray; //用于存放黑色的点点
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation WH_JXPayPassword_WHVC

- (instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}


// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    //页面出现时让键盘弹出
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    
    [self createHeadAndFoot];
    self.view.backgroundColor = g_factory.globalBgColor;
    
    [self WH_setupViews];
    [self initPwdTextField];
    [self setupTitle];
    [self.textField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


- (void)WH_setupViews {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_TOP - 36, 28, 28)];
    [btn setImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateHighlighted];
//    [btn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//    btn.titleLabel.font = sysFontWithSize(16);
//    btn.custom_acceptEventInterval = 1.f;
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didDissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.wh_cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset,JX_SCREEN_TOP + 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, (self.type == JXPayTypeRepeatPassword)?208+84:208)];
    [self.wh_cView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.view addSubview:self.wh_cView];
    self.wh_cView.layer.masksToBounds = YES;
    self.wh_cView.layer.cornerRadius = g_factory.cardCornerRadius;
    self.wh_cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    self.wh_cView.layer.borderWidth = g_factory.cardBorderWithd;

//    self.titleLab.frame = CGRectMake(0, 0 , self.cView.frame.size.width, 75);
    self.detailLab.frame = CGRectMake(0, 0 , self.wh_cView.frame.size.width, 75);
    [self.detailLab setTextColor:HEXCOLOR(0x333333)];
    [self.detailLab setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.detailLab.frame), self.wh_cView.frame.size.width, g_factory.cardBorderWithd)];
    [lView setBackgroundColor:g_factory.globalBgColor];
    [self.wh_cView addSubview:lView];
    
    self.textField.frame = CGRectMake(20, CGRectGetMaxY(lView.frame)+45, self.wh_cView.frame.size.width - 40, K_Field_Height);
    
    self.nextBtn.frame = CGRectMake(self.textField.frame.origin.x, CGRectGetMaxY(self.textField.frame)+20, self.wh_cView.frame.size.width - 2*self.textField.frame.origin.x, 44);
    [self.wh_cView addSubview:self.textField];
    [self.wh_cView addSubview:self.titleLab];
    [self.wh_cView addSubview:self.detailLab];
    [self.wh_cView addSubview:self.nextBtn];
    
}

- (void)didDissVC {
    if (self.type == JXPayTypeInputPassword) {
        [self WH_goBackToVC];
    }else {
        [g_App showAlert:Localized(@"JX_CancelPayPsw") delegate:self];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self WH_goBackToVC];
//        lyj 2019.11.04注释功能
//        BOOL canPopWH_JXSecuritySetting_WHVC = NO;
//        for (id subView in g_navigation.subViews) {
//            if ([[subView class] isKindOfClass:[WH_JXSecuritySetting_WHVC class]]) {
//                canPopWH_JXSecuritySetting_WHVC = YES;
//                [g_navigation popToViewController:[WH_JXSecuritySetting_WHVC class] animated:YES];//设置支付密码界面，如果进入多层设置界面，点击左上角返回时，直接退出到安全设置界面
//            }
//        }
//        if (canPopWH_JXSecuritySetting_WHVC == NO) {
//            [self actionQuit];
//        }
//        [self actionQuit];
    }
}


- (void)setupTitle {
    if (self.type == JXPayTypeSetupPassword) {  // 第一次设置密码
        [self.nextBtn setHidden:YES];
        self.title = Localized(@"JX_SetPayPsw");
        self.detailLab.text = Localized(@"JX_SetPayPswNo.1");
    } else if (self.type == JXPayTypeRepeatPassword) { // 第二次设置密码
        [self.nextBtn setHidden:NO];
        self.title = Localized(@"JX_SetPayPsw");
        self.detailLab.text = Localized(@"JX_SetPayPswNo.2");
    } else if (self.type == JXPayTypeInputPassword) { // 如果有密码，进入需要确认密码
        [self.nextBtn setHidden:YES];
        self.title = Localized(@"JX_UpdatePassWord");
        self.detailLab.text = Localized(@"JX_EnterToVerify");
    }
}


- (void)didNextButton {
    if ([self.textField.text length] < 6) {
        [g_App showAlert:Localized(@"JX_PswError")];
        [self WH_clearUpPassword];
        return;
    }
    if (![self.textField.text isEqualToString:self.wh_lastPsw]) {
        [g_App showAlert:Localized(@"JX_NotMatch")];
        [self WH_goToSetupTypeVCWithOld:NO];
        return;
    }
//    if (![self.textField.text isEqualToString:self.wh_oldPsw]) {
//        [g_App showAlert:Localized(@"JX_NewEqualOld")];
//        [self WH_goToSetupTypeVCWithOld:NO];
//        return;
//    }
    if(self.type == JXPayTypeRepeatPassword) {
        if (self.enterType == JXEnterTypeForgetPayPsw) {
            //来自于忘记密码
            [g_server forgetPayPswWithModifyType:@"1" oldPassword:_wh_oldPsw newPassword:_textField.text toView:self];
        } else {
            WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
            user.payPassword = self.textField.text;
            user.oldPayPassword = self.wh_oldPsw;
            [g_server WH_updatePayPasswordWithUser:user toView:self];
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPwdTextField {
    //每个密码输入框的宽度
    CGFloat width = (JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 40) / kDotCount;
    
    //生成分割线
    for (int i = 0; i < kDotCount - 1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (i + 1) * width, CGRectGetMinY(self.textField.frame), 0.5, K_Field_Height)];
        lineView.backgroundColor = HEXCOLOR(0xC4C4C4);
        [self.wh_cView addSubview:lineView];
    }
    
    self.dotArray = [[NSMutableArray alloc] init];
    //生成中间的点
    for (int i = 0; i < kDotCount; i++) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (width - kDotCount) / 2 + i * width, CGRectGetMinY(self.textField.frame) + (K_Field_Height - kDotSize.height) / 2, kDotSize.width, kDotSize.height)];
        dotView.backgroundColor = [UIColor blackColor];
        dotView.layer.cornerRadius = kDotSize.width / 2.0f;
        dotView.clipsToBounds = YES;
        dotView.hidden = YES; //先隐藏
        [self.wh_cView addSubview:dotView];
        //把创建的黑色点加入到数组中
        [self.dotArray addObject:dotView];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        //按回车关闭键盘
        [textField resignFirstResponder];
        return NO;
    } else if(string.length == 0) {
        //判断是不是删除键
        return YES;
    }
    else if(textField.text.length >= kDotCount) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        return NO;
    } else {
        return YES;
    }
}

/**
 *  清除密码
 */
- (void)WH_clearUpPassword {
    self.textField.text = @"";
    [self textFieldDidChange:self.textField];
}

/**
 *  重置显示的点
 */
- (void)textFieldDidChange:(UITextField *)textField {
    for (UIView *dotView in self.dotArray) {
        dotView.hidden = YES;
    }
    for (int i = 0; i < textField.text.length; i++) {
        ((UIView *)[self.dotArray objectAtIndex:i]).hidden = NO;
    }
    if (textField.text.length >= kDotCount) {
        if (self.type == JXPayTypeSetupPassword) {
            WH_JXPayPassword_WHVC *payVC = [WH_JXPayPassword_WHVC alloc];
            payVC.type = JXPayTypeRepeatPassword;
            payVC.enterType = self.enterType;
            payVC.wh_lastPsw = self.textField.text;
            payVC.wh_oldPsw = self.wh_oldPsw;
            payVC = [payVC init];
            [g_navigation pushViewController:payVC animated:YES];
        }else if(self.type == JXPayTypeRepeatPassword) {
            [self.nextBtn setUserInteractionEnabled:YES];
            [_nextBtn setBackgroundColor:THEMECOLOR];
        } else if(self.type == JXPayTypeInputPassword) {
            WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
            user.payPassword = self.textField.text;
            [g_server WH_checkPayPasswordWithUser:user toView:self];
        }
    }else {
        [self.nextBtn setUserInteractionEnabled:NO];
        [_nextBtn setBackgroundColor:[THEMECOLOR colorWithAlphaComponent:0.5]];
    }
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_UpdatePayPassword] || [aDownload.action isEqualToString:wh_act_forgetPayPassword]){
        [self.textField resignFirstResponder];
        [self WH_clearUpPassword];
        [g_App showAlert:Localized(@"JX_SetUpSuccess")];
        g_myself.isPayPassword = [dict objectForKey:@"payPassword"];
        [g_default setObject:[dict objectForKey:@"payPassword"] forKey:PayPasswordKey];//用户设置支付密码成功时,保存一下支付密码的设置状态
        [self WH_goBackToVC];
    }
    if([aDownload.action isEqualToString:wh_act_CheckPayPassword]){
        [self WH_goToSetupTypeVCWithOld:YES];
    }

}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_UpdatePayPassword]) {
        //返回
//        [self WH_goBackToVC];
        [self WH_goToSetupTypeVCWithOld:NO];
    }
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


- (void)WH_goBackToVC {
    if (self.enterType == JXEnterTypeDefault) {
//        [g_navigation popToViewController:[WH_JXMoneyMenu_WHViewController class] animated:YES];
        [g_navigation popToViewController:[WH_MyWallet_WHViewController class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeWithdrawal){
        [g_navigation popToViewController:[WH_JXCashWithDraw_WHViewController class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeTransfer){
        [g_navigation popToViewController:[WH_JXTransfer_WHViewController class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeQr){
        [g_navigation popToViewController:[WH_JXInputMoney_WHVC class] animated:YES];
    }
    else if (self.enterType == JXEnterTypeSkPay){
        [g_navigation popToViewController:[WH_webpage_WHVC class] animated:YES];
    } else if (self.enterType == JXEnterTypeSecureSetting){
        [g_navigation popToViewController:[WH_JXSecuritySetting_WHVC class] animated:YES];
    } else if (self.enterType == JXEnterTypeForgetPayPsw){
        //忘记支付密码修改为返回到安全设置界面
        [g_navigation popToViewController:[WH_JXSecuritySetting_WHVC class] animated:YES];
    } else if (self.enterType == JXEnterTypeSendRedPacket) {
        [g_navigation popToViewController:[WH_JXSendRedPacket_WHViewController class] animated:YES];
    } else{
        [self actionQuit];
    }

}

- (void)WH_goToSetupTypeVCWithOld:(BOOL)isOld {
    WH_JXPayPassword_WHVC *payVC = [WH_JXPayPassword_WHVC alloc];
    payVC.type = JXPayTypeSetupPassword;
    payVC.enterType = self.enterType;
    payVC.wh_lastPsw = self.textField.text;
    // 这个是记录旧密码的
    payVC.wh_oldPsw = isOld ? self.textField.text : self.wh_oldPsw;
    payVC = [payVC init];
    [g_navigation pushViewController:payVC animated:YES];
}

#pragma mark - init

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[WH_JXTextField alloc] init];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.textColor = [UIColor whiteColor];
        _textField.tintColor = [UIColor whiteColor];
        _textField.delegate = self;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.layer.borderColor = HEXCOLOR(0xC4C4C4).CGColor;
        _textField.layer.borderWidth = .5;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}


- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = sysFontWithSize(26);
    }
    return _titleLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLab;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] init];
        [_nextBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
        
//        [_nextBtn setBackgroundColor:[THEMECOLOR colorWithAlphaComponent:0.6]];
        [_nextBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
        _nextBtn.userInteractionEnabled = NO;
        _nextBtn.layer.masksToBounds = YES;
        _nextBtn.layer.cornerRadius = g_factory.cardCornerRadius;
        [self.nextBtn setHidden:YES];
        [_nextBtn addTarget:self action:@selector(didNextButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}



@end
