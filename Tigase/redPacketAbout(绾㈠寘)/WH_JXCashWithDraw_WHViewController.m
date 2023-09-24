//
//  WH_JXCashWithDraw_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/10/27.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXCashWithDraw_WHViewController.h"
#import "UIImage+WH_Color.h"
#import "WXApi.h"
#import "WXApiManager.h"
#import "WH_JXVerifyPay_WHVC.h"
#import "WH_JXPayPassword_WHVC.h"
#import <AlipaySDK/AlipaySDK.h>

#import "WH_Recharge_TableViewCell.h"
#import "BindTelephoneChecker.h"

#define drawMarginX 20
#define bgWidth JX_SCREEN_WIDTH- g_factory.globelEdgeInset*2
#define drawHei 60

@interface WH_JXCashWithDraw_WHViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton * helpButton;

@property (nonatomic, strong) UIControl * hideControl;
@property (nonatomic, strong) UIControl * bgView;
@property (nonatomic, strong) UIView * targetView;
@property (nonatomic, strong) UIView * inputView;
@property (nonatomic, strong) UIView * balanceView;

@property (nonatomic, strong) UIButton * cardButton;
@property (nonatomic, strong) UITextField * countTextField;

@property (nonatomic, strong) UILabel * balanceLabel;
@property (nonatomic, strong) UIButton * drawAllBtn;
@property (nonatomic, strong) UIButton * withdrawalsBtn;
@property (nonatomic, strong) UIButton * aliwithdrawalsBtn;
@property (nonatomic, strong) ATMHud *loading;
@property (nonatomic, strong) WH_JXVerifyPay_WHVC *verVC;
@property (nonatomic, strong) NSString *payPassword;
@property (nonatomic, assign) BOOL isAlipay;
@property (nonatomic, strong) NSString *aliUserId;

@property (nonatomic ,strong) UIView *paymentView;

@end

@implementation WH_JXCashWithDraw_WHViewController

-(instancetype)init{
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        self.title = Localized(@"JXMoney_withdrawals");
    }
    return self;
}


// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
    
//    [self.wh_tableHeader addSubview:self.helpButton];
    
    [self.wh_tableBody addSubview:self.hideControl];
    [self.wh_tableBody addSubview:self.bgView];
    
    [self.bgView addSubview:self.inputView];
    [self.bgView addSubview:self.balanceView];
    
    self.paymentView = [self paymentMethodView];
    [self.wh_tableBody addSubview:self.paymentView];
    
    [self.wh_tableBody setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];

    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.paymentView.frame) + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    [payBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    [payBtn setTitle:Localized(@"JXMoney_withdrawals") forState:UIControlStateNormal];
    [payBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [payBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [self.wh_tableBody addSubview:payBtn];
    [payBtn addTarget:self action:@selector(payMethod) forControlEvents:UIControlEventTouchUpInside];
    payBtn.layer.masksToBounds = YES;
    payBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    _loading = [[ATMHud alloc] init];
    
    [_countTextField becomeFirstResponder];
    
    [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthResp_WHNotification object:nil];
}

-(UIButton *)helpButton{
    if(!_helpButton){
        _helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _helpButton.frame = CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 24, JX_SCREEN_TOP - 34, 24, 24);
        [_helpButton setImage:[UIImage imageNamed:@"im_003_more_button_normal"] forState:UIControlStateNormal];
        [_helpButton setImage:[UIImage imageNamed:@"im_003_more_button_normal"] forState:UIControlStateHighlighted];
        [_helpButton addTarget:self action:@selector(helpButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _helpButton;
}

-(UIControl *)hideControl{
    if (!_hideControl) {
        _hideControl = [[UIControl alloc] init];
        _hideControl.frame = self.wh_tableBody.bounds;
        [_hideControl addTarget:self action:@selector(hideControlAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideControl;
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIControl alloc] init];
        
        _bgView.frame = CGRectMake(g_factory.globelEdgeInset, 12, bgWidth, 184);
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = g_factory.cardCornerRadius;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

-(UIView *)targetView{
    if (!_targetView) {
        _targetView = [[UIView alloc] init];
        _targetView.frame = CGRectMake(0, 0, bgWidth, drawHei);
        _targetView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
        
        UILabel * targetLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, 0, 120, drawHei) text:Localized(@"JXMoney_withDrawalsTarget")];
        [_targetView addSubview:targetLabel];
        
        CGRect btnFrame = CGRectMake(CGRectGetMaxX(targetLabel.frame)+20, 0, bgWidth-CGRectGetMaxX(targetLabel.frame)-20-drawMarginX, drawHei);
        _cardButton = [UIFactory WH_create_WHButtonWithRect:btnFrame title:@"微信号(8868)" titleFont:sysFontWithSize(15) titleColor:HEXCOLOR(0x576b95) normal:nil selected:nil selector:@selector(WH_cardButtonAction:) target:self];
        [_targetView addSubview:_cardButton];
    }
    return _targetView;
}

-(UIView *)inputView{
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
        _inputView.frame = CGRectMake(0, 0, bgWidth, 126);
        _inputView.backgroundColor = [UIColor whiteColor];
        
        UILabel * cashTitle = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, 0, 120, drawHei) text:Localized(@"JXMoney_withDAmount")];
        [cashTitle setTextColor:HEXCOLOR(0x3A404C)];
        [cashTitle setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 17]];
        [_inputView addSubview:cashTitle];
        
        UILabel * rmbLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(cashTitle.frame), 20, drawHei) text:@"¥"];
        [rmbLabel setTextColor:HEXCOLOR(0x3A404C)];
        rmbLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 30];
        rmbLabel.textAlignment = NSTextAlignmentLeft;
        [_inputView addSubview:rmbLabel];
        
        _countTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(CGRectGetMaxX(rmbLabel.frame), CGRectGetMinY(rmbLabel.frame), bgWidth-CGRectGetMaxX(rmbLabel.frame)-drawMarginX, drawHei) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:nil font:[UIFont fontWithName:@"PingFangSC-Medium" size: 45] color:HEXCOLOR(0x3A404C) delegate:self];
        _countTextField.borderStyle = UITextBorderStyleNone;
        [_inputView addSubview:_countTextField];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_countTextField.frame)+5, bgWidth-drawMarginX*2, g_factory.cardBorderWithd);
        line.backgroundColor = g_factory.cardBorderColor;
        [_inputView addSubview:line];
        
    }
    return _inputView;
}

-(UIView *)balanceView{
    if (!_balanceView) {
        _balanceView = [[UIView alloc] init];
        _balanceView.frame = CGRectMake(0, CGRectGetMaxY(_inputView.frame), bgWidth, 185+60);
        _balanceView.backgroundColor = [UIColor whiteColor];

        NSString * moneyStr = [NSString stringWithFormat:@"%@¥%.2f元",@"可用余额：",g_App.myMoney];
        
        _balanceLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:moneyStr font:[UIFont fontWithName:@"PingFangSC-Regular" size: 14] textColor:HEXCOLOR(0xBAC3D5) backgroundColor:nil];
        CGFloat blanceWidth = [moneyStr sizeWithAttributes:@{NSFontAttributeName:_balanceLabel.font}].width;
        _balanceLabel.frame = CGRectMake(drawMarginX, 0, blanceWidth, drawHei);
        [_balanceView addSubview:_balanceLabel];
        
        _drawAllBtn = [UIFactory WH_create_WHButtonWithRect:CGRectZero title:Localized(@"JXMoney_withDAll") titleFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14] titleColor:HEXCOLOR(0x0093FF) normal:nil selected:nil selector:@selector(WH_drawAllBtnAction) target:self];
        CGFloat drawWidth = [_drawAllBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_drawAllBtn.titleLabel.font}].width;
        _drawAllBtn.frame = CGRectMake(CGRectGetWidth(_balanceView.frame) - drawWidth - 20, CGRectGetMinY(_balanceLabel.frame), drawWidth, drawHei);
        
        [_balanceView addSubview:_drawAllBtn];
        
//        _withdrawalsBtn = [UIFactory WH_create_WHButtonWithRect:CGRectZero title:Localized(@"JXMoney_wechatWithdrawals") titleFont:sysFontWithSize(17) titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(WH_withdrawalsBtnAction:) target:self];
//        _withdrawalsBtn.tag = 1000;
//        _withdrawalsBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_balanceLabel.frame)+20, bgWidth-drawMarginX*2, 50);
//        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x0093FF)] forState:UIControlStateNormal];
////        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
//        _withdrawalsBtn .layer.cornerRadius = 5;
//        _withdrawalsBtn.clipsToBounds = YES;
//
//        [_balanceView addSubview:_withdrawalsBtn];
//
//
//        _aliwithdrawalsBtn = [UIFactory WH_create_WHButtonWithRect:CGRectZero title:Localized(@"JXMoney_Aliwithdrawals") titleFont:sysFontWithSize(17) titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(WH_withdrawalsBtnAction:) target:self];
//        _aliwithdrawalsBtn.tag = 1011;
//        _aliwithdrawalsBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_balanceLabel.frame)+20+60, bgWidth-drawMarginX*2, 50);
//        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x0093FF)] forState:UIControlStateNormal];
////        [_aliwithdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
//        _aliwithdrawalsBtn .layer.cornerRadius = 5;
//        _aliwithdrawalsBtn.clipsToBounds = YES;
//
//        [_balanceView addSubview:_aliwithdrawalsBtn];

        
//        UILabel *noticeLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(_withdrawalsBtn.frame)+10+60, bgWidth-drawMarginX*2, 30) text:Localized(@"JXMoney_withDNotice") font:sysFontWithSize(14) textColor:[UIColor lightGrayColor] backgroundColor:nil];
//        noticeLabel.textAlignment = NSTextAlignmentCenter;
//        [_balanceView addSubview:noticeLabel];
    }
    return _balanceView;
}

- (UIView *)paymentMethodView {
    
    NSArray *array = @[@{@"icon":@"WH_ALiPay" ,@"name":@"支付宝支付"} ,@{@"icon":@"WH_WeiXinPay" ,@"name":@"微信支付"}];
    self.wh_zfList = [[NSMutableArray alloc] init];
    [self.wh_zfList addObjectsFromArray:array];
    
    /*self.zfList = [[NSMutableArray alloc] init];
    if ([g_config.aliWithdrawStatus integerValue] == 1) {
        //1：开启 2：关闭
        [self.zfList addObject:@{@"icon":@"WH_ALiPay" ,@"name":@"支付宝支付"}];
    }else {
        if ([g_config.wechatWithdrawStatus integerValue] == 1) {
            [self.zfList addObject:@{@"icon":@"WH_WeiXinPay" ,@"name":@"微信支付"}];
        }
    }*/
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.bgView.frame) + 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 60+_wh_zfList.count * 60)];
    [view setBackgroundColor:HEXCOLOR(0xffffff)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = g_factory.cardCornerRadius;
    view.layer.borderColor = g_factory.cardBorderColor.CGColor;
    view.layer.borderWidth = g_factory.cardBorderWithd;
    
    UILabel * cashTitle = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, 0, 120, drawHei) text:@"提现到"];
    [cashTitle setTextColor:HEXCOLOR(0x3A404C)];
    [cashTitle setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 17]];
    [view addSubview:cashTitle];
    
    
    self.wh_zfTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cashTitle.frame) , CGRectGetWidth(view.frame) , self.wh_zfList.count * 60) style:UITableViewStylePlain];
    [self.wh_zfTable setBackgroundColor:view.backgroundColor];
    [self.wh_zfTable setDelegate:self];
    [self.wh_zfTable setDataSource:self];
    [self.wh_zfTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_zfTable setScrollEnabled:NO];
    [view addSubview:self.wh_zfTable];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wh_zfList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"collectionCell";
    WH_Recharge_TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[WH_Recharge_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
    [cell setBackgroundColor:HEXCOLOR(0xffffff)];
    
    NSDictionary *dict = [self.wh_zfList objectAtIndex:indexPath.row];
    [cell setWh_data:dict];
    
    if (indexPath.row < self.wh_zfList.count - 1) {
        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(60, 60 - g_factory.cardBorderWithd, CGRectGetWidth(self.wh_zfTable.frame) - 60, g_factory.cardBorderWithd)];
        [lView setBackgroundColor:g_factory.cardBorderColor];
        [cell.contentView addSubview:lView];
    }
    
    if (_wh_checkIndex == indexPath.row) {
        //        cell.checkButton.selected = YES;
        [cell.wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_selected"] forState:UIControlStateNormal];
    }else{
        [cell.wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_unselected"] forState:UIControlStateNormal];
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _wh_checkIndex = indexPath.row;
    [_countTextField resignFirstResponder];
    
    WH_Recharge_TableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i = 0; i < _wh_zfList.count; i++) {
        if (_wh_checkIndex == i) {
            [selCell.wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_selected"] forState:UIControlStateNormal];
        }else{
            [selCell.wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_unselected"] forState:UIControlStateNormal];
        }
    }
    [self.wh_zfTable reloadData];
}

#pragma mark TextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _countTextField) {
        NSString *toString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (toString.length > 0) {
            NSString *stringRegex = @"(([0]|(0[.]\\d{0,2}))|([1-9]\\d{0,4}(([.]\\d{0,2})?)))?";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
            if (![predicate evaluateWithObject:toString]) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)payMethod {
    [_countTextField resignFirstResponder];
    
    NSString *countStr = [self.countTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (countStr.length == 0) {
        [GKMessageTool showText:@"请输入提现金额"];
        return;
    }
    
    NSString *minMoney = g_config.minWithdrawToAdmin?:@"0"; //最低提现额度
    if ([countStr floatValue] < [minMoney floatValue]) {
        [GKMessageTool showText:[NSString stringWithFormat:@"请输入至少%.2f以上金额" ,[minMoney floatValue]]];
        return;
    }
    
    NSString *purseMoney = [NSString stringWithFormat:@"%.2lf",g_App.myMoney];
    
    if ([countStr doubleValue] > [purseMoney doubleValue]) {
        [GKMessageTool showText:@"余额不足"];
        return;
    }
    
    NSLog(@"_countTextField.text doubleValue:%f" ,[_countTextField.text doubleValue] - g_App.myMoney);
    
   
    NSString *num1 = [NSString stringWithFormat:@"%.3lf",[_countTextField.text doubleValue]];
    NSString *num2 = [NSString stringWithFormat:@"%.3lf",g_App.myMoney];

    if ([num1 doubleValue] > [num2 doubleValue]) {
        [GKMessageTool showText:@"余额不足"];
        return;
    }

//    if (_checkIndex != 0) {
//        [GKMessageTool showText:@"暂未开放"];
//        return;
//    }
    
//    if (_checkIndex == 0) {
//        //支付宝
//
//
//    }else{
//        //微信
//        [GKMessageTool showText:@"暂未开放"];
//    }
    
    g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
    if ([g_myself.isPayPassword boolValue]) {
        //            self.isAlipay = button.tag == 1011;
        self.isAlipay = (_wh_checkIndex == 0);
        self.verVC = [WH_JXVerifyPay_WHVC alloc];
        self.verVC.type = JXVerifyTypeWithdrawal;
        self.verVC.wh_RMB = self.countTextField.text;
        self.verVC.delegate = self;
        self.verVC.didDismissVC = @selector(WH_dismiss_WHVerifyPayVC);
        self.verVC.didVerifyPay = @selector(WH_didVerifyPay:);
        self.verVC = [self.verVC init];
        
        [self.view addSubview:self.verVC.view];
    } else {
        [BindTelephoneChecker checkBindPhoneWithViewController:self entertype:JXEnterTypeDefault];
        
        
//        WH_JXPayPassword_WHVC *payPswVC = [WH_JXPayPassword_WHVC alloc];
//        payPswVC.type = JXPayTypeSetupPassword;
//        payPswVC.enterType = JXEnterTypeWithdrawal;
//        payPswVC = [payPswVC init];
//        [g_navigation pushViewController:payPswVC animated:YES];
    }
    
    
    
}

#pragma mark Action

-(void)WH_cardButtonAction:(UIButton *)button{
    
}

-(void)WH_drawAllBtnAction{
    NSString * allMoney = [NSString stringWithFormat:@"%.2f",g_App.myMoney];
    _countTextField.text = allMoney;
}

//-(void)WH_withdrawalsBtnAction:(UIButton *)button{
//    if (button.tag != 1011) {
//        [g_App showAlert:@"暂未开放"];
//        return;
//    }
//    if ([_countTextField.text doubleValue] < 1) {
////        [g_App showAlert:Localized(@"JX_Least0.5")];
//        [g_App showAlert:@"每次最少提现1元"];
//        return;
//    }
//    if ([_countTextField.text doubleValue] > g_App.myMoney) {
//        [g_App showAlert:@"余额不足"];
//        return;
//    }
//    if ([g_myself.isPayPassword boolValue]) {
//        self.isAlipay = button.tag == 1011;
//        self.verVC = [WH_JXVerifyPay_WHVC alloc];
//        self.verVC.type = JXVerifyTypeWithdrawal;
//        self.verVC.RMB = self.countTextField.text;
//        self.verVC.delegate = self;
//        self.verVC.didDismissVC = @selector(WH_dismiss_WHVerifyPayVC);
//        self.verVC.didVerifyPay = @selector(WH_didVerifyPay:);
//        self.verVC = [self.verVC init];
//
//        [self.view addSubview:self.verVC.view];
//    } else {
//        WH_JXPayPassword_WHVC *payPswVC = [WH_JXPayPassword_WHVC alloc];
//        payPswVC.type = JXPayTypeSetupPassword;
//        payPswVC.enterType = JXEnterTypeWithdrawal;
//        payPswVC = [payPswVC init];
//        [g_navigation pushViewController:payPswVC animated:YES];
//    }
////    // 绑定微信
////    SendAuthReq* req = [[SendAuthReq alloc] init];
////    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
////    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
////    // app名称
////    NSString *titleStr = [infoDictionary objectForKey:@"CFBundleDisplayName"];
////    req.state = titleStr;
////    req.openID = AppleId;
////
////    [WXApi sendAuthReq:req
////        viewController:self
////              delegate:[WXApiManager sharedManager]];
//
//}

- (void)WH_didVerifyPay:(NSString *)sender {
    self.payPassword = [NSString stringWithString:sender];

    if (self.isAlipay) {
        [g_server WH_getAliPayAuthInfoToView:self];
    }else {
        // 绑定微信
        SendAuthReq* req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app名称
        NSString *titleStr = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        req.state = titleStr;
        req.openID = g_config.appleId;
        [WXApi sendAuthReq:req viewController:self delegate:[WXApiManager sharedManager] completion:nil];
    }
}

- (void)WH_dismiss_WHVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

- (void)authRespNotification:(NSNotification *)notif {
    SendAuthResp *resp = notif.object;
    [self WH_getWeChatTokenThenGetUserInfoWithCode:resp.code];
}

// 用户绑定微信，获取openid
- (void)WH_getWeChatTokenThenGetUserInfoWithCode:(NSString *)code {

    [_loading start];
    [g_server WH_userBindWXCodeWithCode:code toView:self];
}

-(void)hideControlAction{
    [_countTextField resignFirstResponder];
}

-(void)actionQuit{
    [_countTextField resignFirstResponder];
    [super actionQuit];
}
-(void)helpButtonAction{
    
}


- (void)alipayGetUserId:(NSNotification *)noti {
    [g_server WH_safeAliPayUserIdWithUserId:noti.object toView:self];
}


- (void)WH_didServerResult_WHSucces:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
//    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_UserBindWXCode]) {
        
        NSString *amount = [NSString stringWithFormat:@"%d",(int)([_countTextField.text doubleValue] * 100)];
        long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
        NSString *secret = [self secretEncryption:dict[@"openid"] amount:amount time:time payPassword:self.payPassword];
        [g_server WH_transferWXPayWithAmount:amount secret:secret time:[NSNumber numberWithLong:time] toView:self];

    }else if ([aDownload.action isEqualToString:wh_act_TransferWXPay]) {
        [_loading stop];
        [self WH_dismiss_WHVerifyPayVC];  // 销毁支付密码界面
        [g_App showAlert:Localized(@"JX_WithdrawalSuccess")];
        _countTextField.text = nil;
        [g_server WH_getUserMoenyToView:self];
    }
    if ([aDownload.action isEqualToString:wh_act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        _balanceLabel.text = [NSString stringWithFormat:@"%@¥%.2f，",Localized(@"JXMoney_blance"),g_App.myMoney];
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
    }
    if ([aDownload.action isEqualToString:wh_act_aliPayUserId]) {
        long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
        NSString *secret = [self secretEncryption:self.aliUserId amount:_countTextField.text time:time payPassword:self.payPassword];
        [g_server WH_alipayTransferWithAmount:self.countTextField.text secret:secret time:@(time) toView:self];
    }
    if ([aDownload.action isEqualToString:wh_act_alipayTransfer]) {
        //阿里提现成功
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
        [g_server showMsg:Localized(@"JX_WithdrawalSuccess")];
        [g_navigation WH_dismiss_WHViewController:self animated:YES];
    }

    if ([aDownload.action isEqualToString:wh_act_getAliPayAuthInfo]) {
        NSString *aliId = [dict objectForKey:@"aliUserId"];
        NSString *authInfo = [dict objectForKey:@"authInfo"];
        if (IsStringNull(aliId)) {
            NSString *appScheme = @"wahu";
            [[AlipaySDK defaultService] auth_V2WithInfo:authInfo
                                             fromScheme:appScheme
                                               callback:^(NSDictionary *resultDic) {
                                                   NSLog(@"result = %@",resultDic);
                                                   // 解析 auth code
                                                   NSString *result = resultDic[@"result"];
                                                   if (result.length>0) {
                                                       NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                                                       for (NSString *subResult in resultArr) {
                                                           if (subResult.length > 10 && [subResult hasPrefix:@"user_id="]) {
                                                               self.aliUserId = [subResult substringFromIndex:8];
                                                               [g_server WH_safeAliPayUserIdWithUserId:self.aliUserId toView:self];
                                                               break;
                                                           }
                                                       }
                                                   }
                                               }];

        }else {
            long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
            NSString *secret = [self secretEncryption:aliId amount:_countTextField.text time:time payPassword:self.payPassword];
            [g_server WH_alipayTransferWithAmount:self.countTextField.text secret:secret time:@(time) toView:self];
        }
    }

}

- (int)WH_didServerResult_WHFailed:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_loading stop];
    if ([aDownload.action isEqualToString:wh_act_alipayTransfer]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.verVC WH_clearUpPassword];
        });
    }
    return WH_show_error;
}

- (int)WH_didServerConnect_WHError:(WH_JXConnection *)aDownload error:(NSError *)error{
    [_loading stop];
    return WH_hide_error;
}

- (NSString *)secretEncryption:(NSString *)openId amount:(NSString *)amount time:(long)time payPassword:(NSString *)payPassword {
    NSString *secret = [NSString string];
    
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:openId];
    [str1 appendString:MY_USER_ID];
    
    NSMutableString *str2 = [NSMutableString string];
    [str2 appendString:g_server.access_token];
    [str2 appendString:amount];
    [str2 appendString:[NSString stringWithFormat:@"%ld",time]];
    str2 = [[g_server WH_getMD5StringWithStr:str2] mutableCopy];
    
    [str1 appendString:str2];
    NSMutableString *str3 = [NSMutableString string];
    str3 = [[g_server WH_getMD5StringWithStr:payPassword] mutableCopy];
    [str1 appendString:str3];
    
    secret = [g_server WH_getMD5StringWithStr:str1];
    
    return secret;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
//    [_wait start];
}


- (void)sp_upload {
    NSLog(@"Check your Network");
}
@end
