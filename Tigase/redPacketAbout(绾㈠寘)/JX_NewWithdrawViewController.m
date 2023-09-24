//
//  JX_NewWithdrawViewController.m
//  WH_chat
//
//  Created by Apple on 2019/6/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JX_NewWithdrawViewController.h"
#import "WH_JXPayPassword_WHVC.h"
#import "WH_JXVerifyPay_WHVC.h"

#import "UIImage+WH_Color.h"

#define drawMarginX 25
#define bgWidth JX_SCREEN_WIDTH-15*2
#define drawHei 50

@interface JX_NewWithdrawViewController ()

@property (nonatomic, strong) WH_JXVerifyPay_WHVC *verVC;
@property (nonatomic, assign) BOOL isAlipay;
@property (nonatomic, strong) NSString *payPassword;

@end

@implementation JX_NewWithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.title = Localized(@"JXMoney_withdrawals");
    
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    
    self.wh_tableBody.backgroundColor = HEXCOLOR(0xefeff4);
    
    [self createContentView];
}

- (void)createContentView {
    if (!self.wh_contentView) {
        self.wh_contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 20, bgWidth, 308)];
        [self.wh_contentView setBackgroundColor:[UIColor whiteColor]];
        [self.wh_tableBody addSubview:self.wh_contentView];
        self.wh_contentView.layer.cornerRadius = 5;
        self.wh_contentView.clipsToBounds = YES;
        
        //金额
        UIView *moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgWidth, 126)];
        [moneyView setBackgroundColor:[UIColor whiteColor]];
        UILabel *cashTitle = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, 0, 120, drawHei) text:Localized(@"JXMoney_withDAmount")];
        [moneyView addSubview:cashTitle];
        [self.wh_contentView addSubview:moneyView];
        
        UILabel * rmbLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(cashTitle.frame), 35, drawHei) text:@"¥"];
        rmbLabel.font = sysBoldFontWithSize(28);
        rmbLabel.textAlignment = NSTextAlignmentLeft;
        [moneyView addSubview:rmbLabel];
        
        NSString *minMoney = g_config.minWithdrawToAdmin?:@"0";
        self.wh_countTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(CGRectGetMaxX(rmbLabel.frame), CGRectGetMaxY(cashTitle.frame), bgWidth-CGRectGetMaxX(rmbLabel.frame)-drawMarginX, drawHei) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:[NSString stringWithFormat:@"请输入%@元以上金额",minMoney] font:sysFontWithSize(16) color:[UIColor blackColor] delegate:self];
        self.wh_countTextField.borderStyle = UITextBorderStyleNone;
        [moneyView addSubview:self.wh_countTextField];
        
        UIView * line = [[UIView alloc] init];
        line.frame = CGRectMake(drawMarginX, CGRectGetMaxY(self.wh_countTextField.frame)+5, bgWidth-drawMarginX*2, 0.8);
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [moneyView addSubview:line];
        
        UIView *_balanceView = [[UIView alloc] init];
        _balanceView.frame = CGRectMake(0, CGRectGetMaxY(moneyView.frame), bgWidth, CGRectGetHeight(self.wh_contentView.frame) - CGRectGetHeight(moneyView.frame));
        _balanceView.backgroundColor = [UIColor whiteColor];
        [self.wh_contentView addSubview:_balanceView];
        
        NSString * moneyStr = [NSString stringWithFormat:@"%@¥%.2f",Localized(@"JXMoney_blance"),g_App.myMoney];
        UILabel *_balanceLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:moneyStr font:sysFontWithSize(14) textColor:[UIColor lightGrayColor] backgroundColor:nil];
        CGFloat blanceWidth = [moneyStr sizeWithAttributes:@{NSFontAttributeName:_balanceLabel.font}].width;
        _balanceLabel.frame = CGRectMake(drawMarginX, 0, blanceWidth, drawHei);
        [_balanceView addSubview:_balanceLabel];
        
        UIView * line3 = [[UIView alloc] init];
        line3.frame = CGRectMake(0, CGRectGetMaxY(_balanceLabel.frame), bgWidth, 0.8);
        line3.backgroundColor = HEXCOLOR(0xefeff4);
        [_balanceView addSubview:line3];
        
        //提现到哪里
        UILabel *accountTitle = [UIFactory WH_create_WHLabelWith:CGRectMake(drawMarginX, CGRectGetMaxY(_balanceLabel.frame), bgWidth-drawMarginX*2, drawHei) text:@"转账到会员账号"];
        accountTitle.font = sysFontWithSize(16);
        accountTitle.textAlignment = NSTextAlignmentLeft;
        [_balanceView addSubview:accountTitle];
        
        self.wh_accTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(drawMarginX, CGRectGetMaxY(_balanceLabel.frame) + CGRectGetHeight(accountTitle.frame), bgWidth-drawMarginX*2, drawHei) keyboardType:UIKeyboardTypeDefault secure:NO placeholder:@"请输入会员账号" font:sysFontWithSize(16) color:[UIColor blackColor] delegate:self];
        self.wh_accTextField.borderStyle = UITextBorderStyleNone;
        self.wh_accTextField.returnKeyType = UIReturnKeyDone;
        [_balanceView addSubview:self.wh_accTextField];
        
        UIView * line2 = [[UIView alloc] init];
        line2.frame = CGRectMake(drawMarginX, CGRectGetMaxY(self.wh_accTextField.frame)+5, bgWidth-drawMarginX*2, 0.8);
        line2.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
        [_balanceView addSubview:line2];
        
        UIButton *_withdrawalsBtn = [UIFactory WH_create_WHButtonWithRect:CGRectMake(15, CGRectGetMaxY(self.wh_contentView.frame)+20, bgWidth, 50) title:@"提现" titleFont:sysFontWithSize(17) titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(withdrawalsBtnAction:) target:self];
        _withdrawalsBtn.tag = 1000;
//        _withdrawalsBtn.frame = CGRectMake(drawMarginX, CGRectGetMaxY(self.contentView.frame)+20, bgWidth-drawMarginX*2, 50);
        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x1aad19)] forState:UIControlStateNormal];
        [_withdrawalsBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
        _withdrawalsBtn .layer.cornerRadius = 5;
        _withdrawalsBtn.clipsToBounds = YES;
        [self.wh_tableBody addSubview:_withdrawalsBtn];
    }
}

#pragma mark 提现
- (void) withdrawalsBtnAction:(UIButton *)button {
    [self.view endEditing:YES];
    NSString *countStr = [self.wh_countTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *accStr = [self.wh_accTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (countStr.length == 0) {
        [g_App showAlert:@"请输入提现金额!"];
        return;
    }
    
    NSString *minMoney = g_config.minWithdrawToAdmin?:@"0"; //最低提现额度
    if ([countStr floatValue] < [minMoney floatValue]) {
        [g_App showAlert:[NSString stringWithFormat:@"请输入至少%.2f以上金额" ,[minMoney floatValue]]];
        return;
    }
    if ([countStr doubleValue] > g_App.myMoney) {
        [g_App showAlert:@"余额不足"];
        return;
    }
    if (accStr.length == 0) {
        [g_App showAlert:@"请输入会员账号"];
        return;
    }
    
    g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
    if ([g_myself.isPayPassword boolValue]) {
        self.isAlipay = button.tag == 1000;
        self.verVC = [WH_JXVerifyPay_WHVC alloc];
        self.verVC.type = JXVerifyTypeWithdrawal;
        self.verVC.wh_RMB = self.wh_countTextField.text;
        self.verVC.delegate = self;
        self.verVC.didDismissVC = @selector(WH_dismiss_WHVerifyPayVC);
        self.verVC.didVerifyPay = @selector(WH_didVerifyPay:);
        self.verVC = [self.verVC init];
        
        [self.view addSubview:self.verVC.view];
    } else {
        WH_JXPayPassword_WHVC *payPswVC = [WH_JXPayPassword_WHVC alloc];
        payPswVC.type = JXPayTypeSetupPassword;
        payPswVC.enterType = JXEnterTypeWithdrawal;
        payPswVC = [payPswVC init];
        [g_navigation pushViewController:payPswVC animated:YES];
    }
    
}

-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //{"currentTime":1561199897386,"resultCode":1}
    if ([[dict objectForKey:@"resultCode"] integerValue] == 1) {
        [g_App showAlert:@"请求成功,等待后台审核!"];
        
        [self actionQuit];
        
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
        
        return;
    }
}
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    [_wait stop];
    [g_App showAlert:@"提现失败,请重试!"];
    return 0;
}

-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error {
    [_wait stop];
    [g_App showAlert:@"提现失败,请重试!"];
    return 0;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)WH_dismiss_WHVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

//验证支付密码了
- (void)WH_didVerifyPay:(NSString *)sender {
    self.payPassword = [NSString stringWithString:sender];
    
    NSString *countStr = [self.wh_countTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *accStr = [self.wh_accTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    long temptime = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    NSString *time = [NSString stringWithFormat:@"%ld",temptime];
    NSString *secret = [self getSecretWithText:self.payPassword time:time];
    [g_server userWithdrawalWithUserId:g_myself.userId amount:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[_wh_countTextField.text doubleValue]]] secret:secret context:[NSString stringWithFormat:@"%@:%@" ,accStr ,countStr] accountType:@"" toView:self time:time];
}

- (NSString *)getSecretWithText:(NSString *)text time:(NSString *)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:time];
    [str1 appendString:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[_wh_countTextField.text doubleValue]]]];
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    NSMutableString *str2 = [NSMutableString string];
    str2 = [[g_server WH_getMD5StringWithStr:text] mutableCopy];
    [str1 appendString:str2];
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    return [str1 copy];
    
}


- (void)sp_getUsersMostLikedSuccess {
    NSLog(@"Get User Succrss");
}
@end
