  //
//  WH_MyWallet_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/7/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_MyWallet_WHViewController.h"

#import "WH_JXPayPassword_WHVC.h"

#import "WH_JXRecordCode_WHVC.h"
#import "WH_JXRecharge_WHViewController.h"
#import "WH_JXCashWithDraw_WHViewController.h"
#import "JX_NewWithdrawViewController.h"

#import "WH_Recharge_WHViewController.h"
#import "WH_RegisterViewController.h"


#import "WH_NewRecharge_WHViewController.h"
#import "MiXin_WithdrawCoin_MiXinVC.h"
#import "WH_H5Transaction_JXViewController.h"

#import "WH_WithdrawalToBackground_WHViewController.h"
#import "BindTelephoneChecker.h"

#import "WH_webpage_WHVC.h"

#define View_Height (IS_SHOW_BLACK_HOURSE_DEAL)?(384):(384-44-12)

@interface WH_MyWallet_WHViewController ()

@end

@implementation WH_MyWallet_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"钱包";
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    [self.wh_tableHeader addSubview:[self createHeadButton]];
    
    [self createContentView];
    
    [g_notify addObserver:self selector:@selector(WH_doRefresh:) name:kUpdateUser_WHNotifaction object:nil];
    
    [g_notify addObserver:self selector:@selector(WH_doRefresh:) name:kXMPPMessageH5Payment__WHNotification object:nil];
}

-(void)WH_doRefresh:(NSNotification *)notifacation{
    self.wh_moneyLabel.text = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
    
    //获取用户余额
    [g_server WH_getUserMoenyToView:self];
}

- (void)createContentView {
    CGFloat viewHieght = View_Height;
    if ([g_config.hmPayStatus integerValue] == 1) {
        viewHieght = viewHieght + 44 + 12;
    }
    
    if ([g_config.hmWithdrawStatus integerValue] == 1) {
        viewHieght = viewHieght + 44 + 12;
    }
    UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, viewHieght)];
    [cView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_tableBody addSubview:cView];
    cView.layer.masksToBounds = YES;
    cView.layer.cornerRadius = g_factory.cardCornerRadius;
    cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cView.layer.borderWidth = g_factory.cardBorderWithd;
    
    //icon
    UIImageView *jbImg = [[UIImageView alloc] initWithFrame:CGRectMake((cView.frame.size.width - 72)/2, 24, 72, 72)];
    [jbImg setImage:[UIImage imageNamed:@"WH_YuE"]];
    [cView addSubview:jbImg];
    
    //我的余额
    UILabel *mLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, jbImg.frame.origin.y + jbImg.frame.size.height + 12, cView.frame.size.width, 20)];
    [mLabel setText:@"我的余额"];
    [mLabel setTextColor:HEXCOLOR(0x3A404C)];
    [mLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
    [mLabel setTextAlignment:NSTextAlignmentCenter];
    [cView addSubview:mLabel];
    
    self.wh_moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, mLabel.frame.origin.y + mLabel.frame.size.height, cView.frame.size.width, 40)];
    [self.wh_moneyLabel setText:@""];
    [self.wh_moneyLabel setTextColor:HEXCOLOR(0x3A404C)];
    [self.wh_moneyLabel setFont:[UIFont fontWithName:@"PingFangSC-Semibold" size: 30]];
    [cView addSubview:self.wh_moneyLabel];
    [self.wh_moneyLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSArray *array = @[Localized(@"JXLiveVC_Recharge") ,Localized(@"JXMoney_withdrawals")];;
    if ([g_config.hmPayStatus integerValue] == 1 && [g_config.hmWithdrawStatus integerValue] != 1) {
        array = @[Localized(@"JXLiveVC_Recharge") ,@"H5充值",Localized(@"JXMoney_withdrawals")];
    }
    if ([g_config.hmPayStatus integerValue] != 2 && [g_config.hmWithdrawStatus integerValue] == 1) {
        array = @[Localized(@"JXLiveVC_Recharge") ,Localized(@"JXMoney_withdrawals") ,@"H5提现"];
    }
    if ([g_config.hmPayStatus integerValue] == 1 && [g_config.hmWithdrawStatus integerValue] == 1) {
        array = @[Localized(@"JXLiveVC_Recharge") ,@"H5充值",Localized(@"JXMoney_withdrawals"),@"H5提现"];
    }
    
    for (int i = 0; i < array.count; i++) {
        NSString *titleStr = [array objectAtIndex:i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(15, (CGRectGetMaxY(self.wh_moneyLabel.frame) + 20) + i*(12 + 44), cView.frame.size.width - 30, 44)];
        [btn setTag:i];
        [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:([titleStr isEqualToString:Localized(@"JXLiveVC_Recharge")] || [titleStr isEqualToString:@"H5充值"])?HEXCOLOR(0xffffff):HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
        [btn setTitleColor:([titleStr isEqualToString:Localized(@"JXLiveVC_Recharge")] || [titleStr isEqualToString:@"H5充值"])?HEXCOLOR(0xffffff):HEXCOLOR(0x8C9AB8) forState:UIControlStateHighlighted];
        [btn setBackgroundColor:([titleStr isEqualToString:Localized(@"JXLiveVC_Recharge")] || [titleStr isEqualToString:@"H5充值"])?HEXCOLOR(0x0093FF):HEXCOLOR(0xffffff)];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = g_factory.cardCornerRadius;
        if (![titleStr isEqualToString:Localized(@"JXLiveVC_Recharge")] && ![titleStr isEqualToString:@"H5充值"]) {
            btn.layer.borderColor = g_factory.cardBorderColor.CGColor;
            btn.layer.borderWidth = g_factory.cardBorderWithd;
        }
        [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
        [cView addSubview:btn];
        [btn addTarget:self action:@selector(buttonClickMethod:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //获取余额
    [g_server WH_getUserMoenyToView:self];
}

- (UIButton *)createHeadButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(JX_SCREEN_WIDTH - 72, JX_SCREEN_TOP - 33, 62, 21)];
    [btn setTitle:@"账单" forState:UIControlStateNormal];
    [btn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    [btn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateHighlighted];
    [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    [btn addTarget:self action:@selector(recordMethod) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    if ([aDownload.action isEqualToString:wh_act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        NSString * moneyStr = [NSString stringWithFormat:@"¥%.2f",g_App.myMoney];
        self.wh_moneyLabel.text = moneyStr;
    }
}

- (void)buttonClickMethod:(UIButton *)button {
    
    /*@[Localized(@"JXLiveVC_Recharge") ,@"H5充值",Localized(@"JXMoney_withdrawals")] */
    NSString *actionTitle = [button titleForState:UIControlStateNormal];
    if ([actionTitle isEqualToString:Localized(@"JXLiveVC_Recharge")]) {
        
        if ([g_config.aliPayStatus integerValue] != 1 && [g_config.wechatPayStatus integerValue] != 1 && [g_config.yunPayStatus integerValue] != 1) {
            //aliPayStatus;  //支付宝充值状态 1:开启 2：关闭 wechatWithdrawStatus; //微信提现状态1：开启 2：关闭
            [GKMessageTool showText:@"暂不开放"];
            return;
            
        }else {
            
            WH_Recharge_WHViewController *rechargeVC = [[WH_Recharge_WHViewController alloc] init];
            [g_navigation pushViewController:rechargeVC animated:YES];
            
            
            //            WH_NewRecharge_WHViewController *rechargeVC = [[WH_NewRecharge_WHViewController alloc] init];
            //            [g_navigation pushViewController:rechargeVC animated:YES];
        }
        
    } else if ([actionTitle isEqualToString:@"H5充值"]) {
        
//        NSString *str = [NSString stringWithFormat:@"http://ht.icloudpay.us/mobile/chongzhi/wahucz?accessToken=%@" ,g_server.access_token];
//        WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
//        webVC.isGoBack= YES;
//        webVC.isSend = YES;
//        webVC.title = @"";
//        webVC.url = str;
//        webVC = [webVC init];
//        [g_navigation.navigationView addSubview:webVC.view];
        
        WH_H5Transaction_JXViewController *tranVC = [[WH_H5Transaction_JXViewController alloc] init];
        tranVC.transactionType = 1;
        [g_navigation pushViewController:tranVC animated:YES];
        
    } else if ([actionTitle isEqualToString:Localized(@"JXMoney_withdrawals")]) {
        //        MiXin_WithdrawCoin_MiXinVC *vc = [[MiXin_WithdrawCoin_MiXinVC alloc] init];
        //        [g_navigation pushViewController:vc animated:YES];
        //        return;
        
        /**
         * aliWithdrawStatus  支付宝提现状态 1:开启 2：关闭
         * wechatWithdrawStatus 微信提现状态1：开启 2：关闭
         * isWithdrawToAdmin 是否提现到后台 1：开启
         */
        
        if ([g_config.aliWithdrawStatus integerValue] != 1 && [g_config.wechatWithdrawStatus integerValue] != 1 && [g_config.isWithdrawToAdmin integerValue] != 1) {
            [GKMessageTool showText:@"暂不开放"];
            return;
        }else {
            //提现到后台审核
            //先判断是否绑定了手机号
            if ([g_config.isWithdrawToAdmin intValue] == 1) {//提现
                //提现到后台审核
                g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
                if ([g_myself.isPayPassword boolValue]) {
                    WH_WithdrawalToBackground_WHViewController *withdrawalBGVC = [[WH_WithdrawalToBackground_WHViewController alloc] init];
                    [g_navigation pushViewController:withdrawalBGVC animated:YES];
                }else {//没有支付密码
                    [BindTelephoneChecker checkBindPhoneWithViewController:self entertype:JXEnterTypeDefault];
                }
            } else {
                WH_JXCashWithDraw_WHViewController *cashWithVC = [[WH_JXCashWithDraw_WHViewController alloc] init];
                [g_navigation pushViewController:cashWithVC animated:YES];
            }
        }
    }else if ([actionTitle isEqualToString:Localized(@"H5提现")]) {
        WH_H5Transaction_JXViewController *tranVC = [[WH_H5Transaction_JXViewController alloc] init];
        tranVC.transactionType = 2;
        [g_navigation pushViewController:tranVC animated:YES];
    }
}
//未设置支付密码，设置支付密码
- (void)setPaypassForFirstTime {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"您还未设置支付密码，请设置支付密码。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WH_JXPayPassword_WHVC * PayVC = [WH_JXPayPassword_WHVC alloc];
        PayVC.type = JXPayTypeSetupPassword;
        PayVC.enterType = JXEnterTypeDefault;
        PayVC = [PayVC init];
        [g_navigation pushViewController:PayVC animated:YES];
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark 消费记录
- (void)recordMethod {
//    WH_PurchaseHistory_WHViewController *phVC = [[WH_PurchaseHistory_WHViewController alloc] init];
//    [g_navigation pushViewController:phVC animated:YES];
    
    WH_JXRecordCode_WHVC * recordVC = [[WH_JXRecordCode_WHVC alloc]init];
    [g_navigation pushViewController:recordVC animated:YES];
}



@end
