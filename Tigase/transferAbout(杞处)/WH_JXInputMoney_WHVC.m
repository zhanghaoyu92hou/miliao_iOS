//
//  WH_JXInputMoney_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXInputMoney_WHVC.h"
#import "UIImage+WH_Color.h"
#import "WH_JXVerifyPay_WHVC.h"
#import "WH_JXPayPassword_WHVC.h"


#define drawMarginX 25
#define bgWidth JX_SCREEN_WIDTH-15*2
#define drawHei 30

@interface WH_JXInputMoney_WHVC () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField * countTextField;
@property (nonatomic, strong) UIButton *transferBtn;
@property (nonatomic, strong) UILabel *addDscLab;
@property (nonatomic, strong) UILabel *dscLab;
@property (nonatomic, strong) NSString *desContent;
@property (nonatomic, strong) WH_JXVerifyPay_WHVC *verVC;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *replayTitle;
@property (nonatomic, strong) UITextField *replayTextField;

@end

@implementation WH_JXInputMoney_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.type == JXInputMoneyTypePayment) {
        self.title = Localized(@"JX_Payment");
    }else if(self.type == JXInputMoneyTypeCollection) {
        self.title = Localized(@"JX_CollectionMoney");
    }else {
        self.title = Localized(@"JX_SetTheAmount");
    }
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    [self WH_setupViews];
    [self WH_setupReplayView];
    
    [g_notify addObserver:self selector:@selector(notifyPaymentGet:) name:kXMPPMessageQrPayment_WHNotification object:nil];
}

- (void)notifyPaymentGet:(NSNotification *)noti {
    WH_JXMessageObject *msg = noti.object;
    if ([msg.type intValue] == kWCMessageTypePaymentGet) {
        [g_server showMsg:Localized(@"JX_PaymentReceived")];
    }else if ([msg.type intValue] == kWCMessageTypeReceiptOut) {
        [g_server showMsg:Localized(@"JX_PaymentToFriend")];
    }
}

- (void)notifyReceiptOut {
}

- (void)WH_setupViews {
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
    
    int n = 0;
    CGFloat viewHeight = 0;
    
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_nameLabel.frame)+n+10, JX_SCREEN_WIDTH-20, (self.type == JXInputMoneyTypePayment)?338:280)];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.layer.masksToBounds = YES;
    baseView.layer.cornerRadius = 5.f;
    [self.wh_tableBody addSubview:baseView];
    
    if (self.type == JXInputMoneyTypePayment) {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(baseView.frame) - 50)/2, 35, 50, 50)];
        icon.layer.masksToBounds = YES;
        icon.layer.cornerRadius = icon.frame.size.width/2;
        [g_server WH_getHeadImageLargeWithUserId:_wh_userId userName:_wh_userName imageView:icon];
        [baseView addSubview:icon];
        
//        UILabel *payTit = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 17)];
//        payTit.text = Localized(@"JX_PaymentToIndividual");
//        payTit.font = sysFontWithSize(16);
//        [self.wh_tableBody addSubview:payTit];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame) + 8, CGRectGetWidth(baseView.frame), 22)];
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        _nameLabel.textColor = HEXCOLOR(0x3A404C);
        _nameLabel.text = [NSString stringWithFormat:@"付款给%@" ,_wh_userName];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [baseView addSubview:_nameLabel];
        
        n = 10;
    }
    
    UILabel * cashTitle = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, (self.type == JXInputMoneyTypePayment)?CGRectGetMaxY(_nameLabel.frame):0, CGRectGetWidth(baseView.frame) - 2*drawMarginX, drawHei) text:self.title];
    cashTitle.text = self.type == JXInputMoneyTypeCollection ? Localized(@"JX_GetMoney") : self.wh_desStr;
    //收款时 || 付款中有说明  不隐藏
    cashTitle.hidden = !(self.wh_desStr.length > 0 || self.type == JXInputMoneyTypeCollection);
    [cashTitle setTextColor:HEXCOLOR(0xBAC3D5)];
    [cashTitle setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
    [baseView addSubview:cashTitle];
    
    UILabel * rmbLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(cashTitle.frame), 35, 35) text:@"¥"];
    rmbLabel.font = sysBoldFontWithSize(28);
    rmbLabel.textAlignment = NSTextAlignmentLeft;
    [baseView addSubview:rmbLabel];
    
    _countTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(CGRectGetMaxX(rmbLabel.frame), CGRectGetMinY(rmbLabel.frame), bgWidth-CGRectGetMaxX(rmbLabel.frame)-drawMarginX, 35) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:nil font:[UIFont boldSystemFontOfSize:45] color:[UIColor blackColor] delegate:self];
    _countTextField.borderStyle = UITextBorderStyleNone;
    [baseView addSubview:_countTextField];
    [_countTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (self.wh_money.length > 0) {
        _countTextField.text = self.wh_money;
        _countTextField.enabled = NO;
    }
    
    UIView * line = [[UIView alloc] init];
    line.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_countTextField.frame)+5, bgWidth-drawMarginX*2, 0.8);
    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    [baseView addSubview:line];
    
    //转账说明内容
    _dscLab = [[UILabel alloc] initWithFrame:CGRectMake(drawMarginX, CGRectGetMaxY(line.frame)+15, 0, 0)];
    [_dscLab setTextColor:HEXCOLOR(0xBAC3D5)];
    [_dscLab setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
    [baseView addSubview:_dscLab];
    
    // 添加转账说明
    _addDscLab = [[UILabel alloc] initWithFrame:CGRectMake(drawMarginX, CGRectGetMaxY(line.frame)+15, 120, 18)];
    _addDscLab.text = Localized(@"JX_AddDescriptions");
    _addDscLab.textColor = HEXCOLOR(0x6E7B8F);
    _addDscLab.userInteractionEnabled = YES;
    _addDscLab.hidden = self.type == JXInputMoneyTypeCollection;
    [baseView addSubview:_addDscLab];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSendTransferDsc)];
    [_addDscLab addGestureRecognizer:tap];
    
    
    _transferBtn = [UIFactory WH_create_WHButtonWithRect:CGRectZero title:self.type ==JXInputMoneyTypeSetMoney ? Localized(@"JX_Confirm") : self.title titleFont:sysFontWithSize(17) titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(transferBtnAction:) target:self];
    _transferBtn.tag = 1000;
    _transferBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_addDscLab.frame)+20, JX_SCREEN_WIDTH-20-drawMarginX*2, 50);
    [_transferBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x0093FF)] forState:UIControlStateNormal];
    [_transferBtn setBackgroundImage:[UIImage createImageWithColor:[HEXCOLOR(0x0093FF) colorWithAlphaComponent:0.6f]] forState:UIControlStateDisabled];
    _transferBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    _transferBtn.clipsToBounds = YES;
    _transferBtn.enabled = self.wh_money.length > 0;
    
    [baseView addSubview:_transferBtn];
    
}


- (void)WH_setupReplayView {
    int height = 44;
    self.bigView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.bigView.hidden = YES;
    [g_App.window addSubview:self.bigView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.bigView addGestureRecognizer:tap];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self. baseView.layer.cornerRadius = 4.0f;
    [self.bigView addSubview:self.baseView];
    int n = 20;
    _replayTitle = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, n, self.baseView.frame.size.width - INSETS*2, 20)];
    _replayTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _replayTitle.textAlignment = NSTextAlignmentCenter;
    _replayTitle.textColor = HEXCOLOR(0x595959);
    _replayTitle.font = [UIFont boldSystemFontOfSize:17];
    _replayTitle.text = self.title;
    [self.baseView addSubview:_replayTitle];
    
    n = n + height;
    self.replayTextField = [self WH_createMiXinTextField:self.baseView default:nil hint:nil];
    self.replayTextField.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    self.replayTextField.frame = CGRectMake(10, n, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.replayTextField.delegate = self;
    self.replayTextField.textColor = HEXCOLOR(0x595959);
    self.replayTextField.placeholder = Localized(@"JX_10WordsAtMost");
    [self.replayTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    n = n + INSETS + height;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, n, self.baseView.frame.size.width, 44)];
    [self.baseView addSubview:self.topView];
    
    // 两条线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 0.5)];
    topLine.backgroundColor = HEXCOLOR(0xD6D6D6);
    [self.topView addSubview:topLine];
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, 0, 0.5, self.topView.frame.size.height)];
    botLine.backgroundColor = HEXCOLOR(0xD6D6D6);
    [self.topView addSubview:botLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:sysFontWithSize(15)];
    [cancelBtn addTarget:self action:@selector(hideBigView) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancelBtn];
    // 确定
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [sureBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0x383893) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:sysFontWithSize(15)];
    [sureBtn addTarget:self action:@selector(onRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:sureBtn];
    
}


- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == _countTextField) {
        if ([textField.text doubleValue] > 0) {
            _transferBtn.enabled = YES;
        }else {
            _transferBtn.enabled = NO;
        }
    }
}

#pragma mark - 收付款、设置金额
- (void)transferBtnAction:(UIButton *)button {
    //设置金额
    if (self.type == JXInputMoneyTypeSetMoney) {
        NSMutableDictionary *dict = @{@"type":[NSNumber numberWithInt:self.type]}.mutableCopy;
        if (self.countTextField.text.length > 0) {
            [dict addEntriesFromDictionary:@{@"money":self.countTextField.text}];
        }
        if (self.desContent.length > 0) {
            [dict addEntriesFromDictionary:@{@"desc":self.desContent}];
        }
        if (self.delegate && [self.delegate respondsToSelector:self.onInputMoney]) {
            [self.delegate performSelectorOnMainThread:self.onInputMoney withObject:dict waitUntilDone:NO];
            [self actionQuit];
        }
    }else if (self.type == JXInputMoneyTypeCollection) {
        // 扫码收款，二维码付款
        long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
        NSString *secret = [self getSecretWithPaymentCode:self.wh_paymentCode time:time];
        [g_server WH_codePaymentWithCodeUrlStr:self.wh_paymentCode money:self.countTextField.text time:time desc:self.desContent secret:secret toView:self];
    }
    else {
        // 扫码付款，二维码收款
        if ([_countTextField.text doubleValue] > g_App.myMoney) {
            [g_App showAlert:Localized(@"CREDIT_LOW")];
            return;
        }
        g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
        if ([g_myself.isPayPassword boolValue]) {
            self.verVC = [WH_JXVerifyPay_WHVC alloc];
            self.verVC.type = JXVerifyTypeQr;
            self.verVC.wh_RMB = self.countTextField.text;
            self.verVC.delegate = self;
            self.verVC.didDismissVC = @selector(WH_dismiss_WHVerifyPayVC);
            self.verVC.didVerifyPay = @selector(WH_didVerifyPay:);
            self.verVC = [self.verVC init];
            
            [self.view addSubview:self.verVC.view];
        } else {
            WH_JXPayPassword_WHVC *payPswVC = [WH_JXPayPassword_WHVC alloc];
            payPswVC.type = JXPayTypeSetupPassword;
            payPswVC.enterType = JXEnterTypeQr;
            payPswVC = [payPswVC init];
            [g_navigation pushViewController:payPswVC animated:YES];
        }
    }
    
}

- (void)WH_didVerifyPay:(NSString *)sender {
    long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    NSString *secret = [self getSecretWithtime:time];
    [g_server WH_codeReceiptWithUserId:self.wh_userId money:self.countTextField.text time:time desc:self.desContent secret:secret toView:self];
}


- (void)WH_dismiss_WHVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

- (void)showSendTransferDsc{
    self.bigView.hidden = NO;
    [self.replayTextField becomeFirstResponder];
}

- (void)hideBigView {
    [self resignKeyBoard];
}


- (void)onRelease {
    [self resignKeyBoard];
    self.desContent = _replayTextField.text;
    
    _dscLab.text = self.desContent;
    _addDscLab.text = self.desContent.length > 0 ? Localized(@"JX_Modify") : Localized(@"JX_AddDescriptions");
    CGSize size = [self.desContent sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(17)}];
    _dscLab.frame = CGRectMake(drawMarginX, _dscLab.frame.origin.y, size.width, 18);
    _addDscLab.frame = CGRectMake(CGRectGetMaxX(_dscLab.frame)+5, _addDscLab.frame.origin.y, 120, 18);
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _countTextField) {
        // 首位不能输入 .
        if (IsStringNull(textField.text) && [string isEqualToString:@"."]) {
            return NO;
        }
        //限制.后面最多有两位，且不能再输入.
        if ([textField.text rangeOfString:@"."].location != NSNotFound) {
            //有.了 且.后面输入了两位  停止输入
            if (toBeString.length > [toBeString rangeOfString:@"."].location+3) {
                return NO;
            }
            //有.了，不允许再输入.
            if ([string isEqualToString:@"."]) {
                return NO;
            }
        }
        //限制首位0，后面只能输入. 和 删除
        if ([textField.text isEqualToString:@"0"]) {
            if (![string isEqualToString:@"."] && ![string isEqualToString:@""]) {
                return NO;
            }
        }
        //限制只能输入：1234567890.
        NSCharacterSet * characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] invertedSet];
        NSString * filtered = [[string componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    if (textField == self.replayTextField) {
        if (toBeString.length > 10) {
            return NO;
        }
    }
    
    return YES;
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_codeReceipt]){
        [self WH_dismiss_WHVerifyPayVC];  // 销毁支付密码界面
        
        //成功创建红包，发送一条含红包Id的消息
//        if (self.delegate && [self.delegate respondsToSelector:@selector(transferToUser:)]) {
//            [self.delegate performSelector:@selector(transferToUser:) withObject:dict];
//        }
        [self actionQuit];
    }
    if( [aDownload.action isEqualToString:wh_act_codePayment]){
        
        [self actionQuit];
    }

}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_codeReceipt]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.verVC WH_clearUpPassword];
        });
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



-(UITextField*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,54)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = sysFontWithSize(16);
    [parent addSubview:p];
    return p;
}

- (void)resignKeyBoard {
    self.bigView.hidden = YES;
    [self hideKeyBoard];
    [self resetBigView];
}

- (void)resetBigView {
    self.replayTextField.frame = CGRectMake(10, 64, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5);
    self.topView.frame = CGRectMake(0, 118, self.baseView.frame.size.width, 40);
}

- (void)hideKeyBoard {
    if (self.replayTextField.isFirstResponder) {
        [self.replayTextField resignFirstResponder];
    }
}

// 付款码付款加密规则
- (NSString *)getSecretWithPaymentCode:(NSString *)paymentCode time:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
    [str1 appendString:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[_countTextField.text doubleValue]]]];
    [str1 appendString:paymentCode];
    
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];

    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    return [str1 copy];
}

// 二维码收款加密规则
- (NSString *)getSecretWithtime:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
    [str1 appendString:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[_countTextField.text doubleValue]]]];
    [str1 appendString:[self.verVC WH_getMD5Password]];
    
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    return [str1 copy];
}


@end
