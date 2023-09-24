//
//  WH_ConfirmPayment_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_ConfirmPayment_WHViewController.h"

#import "WH_Recharge_TableViewCell.h"

#import <AlipaySDK/AlipaySDK.h>


#import "WH_BankRecharge_WHVC.h"

#import "WH_webpage_WHVC.h"

#import "MiXin_OrderInfo_MXViewController.h"

#import "WH_NewRecharge_WHViewController.h"

@interface WH_ConfirmPayment_WHViewController ()

@end

@implementation WH_ConfirmPayment_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.title = @"确认支付";
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    UIView *cView = [self createContentView];
    
    UIView *paymentView = [self createPaymentViewWithOrginY:CGRectGetMaxY(cView.frame) + 8];
    [self.wh_tableBody addSubview:paymentView];
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setFrame:CGRectMake(16, paymentView.frame.size.height + paymentView.frame.origin.y + 30, JX_SCREEN_WIDTH - 32, 44)];
    [payBtn setBackgroundColor:HEXCOLOR(0x007EFF)];
    [payBtn setTitle:@"充值" forState:UIControlStateNormal];
    [payBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [payBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 17]];
    payBtn.layer.masksToBounds = YES;
    payBtn.layer.cornerRadius = 22;
    [self.wh_tableBody addSubview:payBtn];
    [payBtn addTarget:self action:@selector(rechargeMethod) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *regText = @"注意事项：\n1 请你在交易订单待付款状态下及时付款，付款后并点击\n“我已付款”按钮，充值才能及时到账。\n2 付款时请足额支付，精确到元、角、分，否则将无法到账";
    
    UILabel *regLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(payBtn.frame) + 20, JX_SCREEN_WIDTH - 32, 180)];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:regText attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]}];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [regText length])];
    
    regLabel.attributedText = string;
    regLabel.textAlignment = NSTextAlignmentLeft;
    regLabel.numberOfLines = 0;
    [self.wh_tableBody addSubview:regLabel];
    
    [g_notify addObserver:self selector:@selector(WH_receiveWXPayFinishNotification:) name:kWxPayFinish_WHNotification object:nil];
    [g_notify addObserver:self selector:@selector(WH_receiveAlipayFinishNotification:) name:@"kAlipayPaymentCallbackNotification" object:nil];
}

- (UIView *)createContentView {
    NSArray *array = @[@"充值数量：" ,@"支付金额：" ,@"单价："];
    NSArray *cArray = @[[NSString stringWithFormat:@"%@ WA币" ,self.pay_money] ,[NSString stringWithFormat:@"￥%@" ,self.pay_money] ,@"1WA币=1CNY"];
    
    UIView *cView = [self createViewWithRect:CGRectMake(0, 0, JX_SCREEN_WIDTH, 50.5*array.count) backgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_tableBody addSubview:cView];
    
    
    for (int i = 0; i < array.count; i++) {
        UIView *view = [self createViewWithRect:CGRectMake(16, i*50.5, CGRectGetWidth(cView.frame) - 32, 50.5) backgroundColor:cView.backgroundColor];
        [cView addSubview:view];
        
        UIView *lView = [self createViewWithRect:CGRectMake(0, 0, CGRectGetWidth(view.frame), 0.5) backgroundColor:HEXCOLOR(0xDBE0E7)];
        [view addSubview:lView];
        
        UILabel *label = [UIFactory WH_create_WHLabelWith:CGRectMake(0, 0.5, 90, 50) text:[array objectAtIndex:i] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:view.backgroundColor];
        [view addSubview:label];
        
        UILabel *cLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(100, 0.5, CGRectGetWidth(view.frame) - 100, 50) text:[cArray objectAtIndex:i] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:view.backgroundColor];
        [cLabel setTextAlignment:NSTextAlignmentRight];
        [view addSubview:cLabel];
    }
    
    return cView;
}

- (UIView *)createPaymentViewWithOrginY:(CGFloat)orginY {
    UIView *view = [self createViewWithRect:CGRectMake(0, orginY, JX_SCREEN_WIDTH, 130) backgroundColor:HEXCOLOR(0xffffff)];
    
    UIView *label = [UIFactory WH_create_WHLabelWith:CGRectMake(16, 0, CGRectGetWidth(view.frame), 53) text:@"支付方式：" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:view.backgroundColor];
    [view addSubview:label];
    
    UIView *payType = [self createViewWithRect:CGRectMake(16, CGRectGetMaxY(label.frame), 130, 40) backgroundColor:HEXCOLOR(0xF7F7F7)];
    [view addSubview:payType];
    payType.layer.cornerRadius = 5;
    payType.layer.masksToBounds = YES;
    
//    NSDictionary *dict = [self.pTypeArray objectAtIndex:self.paymentType];
//    NSString *nameStr = [dict objectForKey:@"name"];
//    if ([nameStr isEqualToString:@"支付宝支付"]) {
//        _checkIndex = 0;
//    }else if ([nameStr isEqualToString:@"微信支付"]) {
//        _checkIndex = 1;
//    }else if ([nameStr isEqualToString:@"银行转账"]){
//        _checkIndex = 2;
//    } else {
//        _checkIndex = 3;
//    }
    
    UIImageView *pImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 26, 26)];
    NSString *imgName = @"";
    NSString *payment = @"";
    
    NSDictionary *dict = [self.pTypeArray objectAtIndex:self.paymentType];
    NSString *nameStr = [dict objectForKey:@"name"];
    
    if ([nameStr isEqualToString:@"支付宝支付"]) {
        //支付宝
        imgName = @"MX_MyWallet_Alipay";
        payment = @"支付宝";
    }else if ([nameStr isEqualToString:@"微信支付"]) {
        //微信
        imgName = @"MX_MyWallet_WeiXinPay";
        payment = @"微信";
    }else if ([nameStr isEqualToString:@"银行转账"]){
        //银行卡
        imgName = @"MX_MyWallet_UnionPayPayment";
        payment = @"银行卡";
    }
    [pImgView setImage:[UIImage imageNamed:imgName]];
    [payType addSubview:pImgView];
    
    UILabel *pLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(pImgView.frame) + 10, 0, CGRectGetWidth(payType.frame) - CGRectGetMaxX(pImgView.frame) - 10, CGRectGetHeight(payType.frame)) text:payment font:[UIFont fontWithName:@"PingFangSC-Regular" size: 17] textColor:HEXCOLOR(0x3A404C) backgroundColor:payType.backgroundColor];
    [payType addSubview:pLabel];
    
    UIImageView *mImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(payType.frame) - 22, CGRectGetHeight(payType.frame) - 22, 22, 22)];
    [mImgView setImage:[UIImage imageNamed:@"MX_MyWallet_Selected"]];
    [payType addSubview:mImgView];
    
    return view;
}

#pragma mark 充值方法
- (void)rechargeMethod {
//    WH_OrderInfo_MXViewController *vc = [[WH_OrderInfo_MXViewController alloc] init];
//    [g_navigation pushViewController:vc animated:YES];
    [g_server paySystem_commitRechargeOrderWithMoney:self.pay_money zfid:self.zfid zfzh:self.accountNumber toView:self];
    return;
    
    NSDictionary *dict = [self.pTypeArray objectAtIndex:self.paymentType];
    NSString *nameStr = [dict objectForKey:@"name"];
    if ([nameStr isEqualToString:@"支付宝支付"]) {
        //支付宝
        [g_server WH_getPaySignWithPrice:self.self.pay_money payType:1 toView:self];
        
    }else if ([nameStr isEqualToString:@"微信支付"]) {
        //微信
        [g_server WH_getPaySignWithPrice:self.pay_money payType:2 toView:self];
    }else if ([nameStr isEqualToString:@"银行转账"]){
        //银行卡
        //跳转到银行转账界面
        WH_BankRecharge_WHVC *vc = [[WH_BankRecharge_WHVC alloc] init];
        vc.money = self.pay_money;
        [g_navigation pushViewController:vc animated:YES];
    }else {
        //网页支付
        WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
        webVC.wh_isGotoBack= YES;
        webVC.isSend = YES;
        webVC.url = [NSString stringWithFormat:@"%@?access_token=%@&money=%@",@"http://www.baidu.com/",g_server.access_token,self.pay_money];
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
    }
}

#pragma mark 微信
-(void)tuningWxWith:(NSDictionary *)dict{
    PayReq *req = [[PayReq alloc] init];
    req.partnerId = [dict objectForKey:@"partnerId"];
    req.prepayId = [dict objectForKey:@"prepayId"];
    req.nonceStr = [dict objectForKey:@"nonceStr"];
    req.timeStamp = [[dict objectForKey:@"timeStamp"] intValue];
    req.package = @"Sign=WXPay";//[dict objectForKey:@"package"];
    req.sign = [dict objectForKey:@"sign"];
    [WXApi sendReq:req completion:nil];
}

#pragma mark 支付宝
- (void)tuningAlipayWithOrder:(NSString *)signedString {
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"wahu";
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:signedString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"阿里回调reslut = %@",resultDic);
            //未安装支付宝客户端回调
            [g_notify postNotificationName:@"kAlipayPaymentCallbackNotification" object:resultDic];
        }];
    }
}

//微信支付回调处理
-(void)WH_receiveWXPayFinishNotification:(NSNotification *)notifi{
    PayResp *resp = notifi.object;
    switch (resp.errCode) {
        case WXSuccess:{
            [self paySuccessHandler];
            break;
        }
        case WXErrCodeUserCancel:{
            //取消了支付
            break;
        }
        default:{
            //支付错误
            [self payFailedHanlder];
            break;
        }
    }
}

//支付宝支付回调处理
- (void)WH_receiveAlipayFinishNotification:(NSNotification *)notifi{
    NSDictionary *resultDic = notifi.object;
    if (resultDic && [resultDic objectForKey:@"resultStatus"] && ([[resultDic objectForKey:@"resultStatus"] intValue] == 9000)) {
        [self paySuccessHandler];
    } else {
        // 支付失败
        [self payFailedHanlder];
    }
}

//支付成功处理
- (void)paySuccessHandler{
    [g_App showAlert:Localized(@"JXMoney_PaySuccess") delegate:self tag:1001 onlyConfirm:YES];
    if (self.rechargeDelegate && [self.rechargeDelegate respondsToSelector:@selector(rechargeSuccessed)]) {
        [self.rechargeDelegate performSelector:@selector(rechargeSuccessed)];
        
        [self actionQuit];
    }
    //    if (_isQuitAfterSuccess) {
    //        [self actionQuit];
    //    }
}

//支付失败处理
- (void)payFailedHanlder{
    //    [JXMyTools showTipView:@"支付失败"];
    [GKMessageTool showText:@"支付失败"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [g_server WH_getUserMoenyToView:self];
        });
    }
}

#pragma mark 请求成功
- (void)WH_didServerResult_WHSucces:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_portalIndexPostCz]){
        // 提交充值生成
        if ([dict[@"resultCode"] intValue] == 1) {
            //订单生成成功
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self actionQuit];
            });
//            [g_navigation popToViewController:[WH_NewRecharge_WHViewController class] animated:NO];
            MiXin_OrderInfo_MXViewController *vc = [[MiXin_OrderInfo_MXViewController alloc] init];
            [g_navigation pushViewController:vc animated:YES];
        } else {
            [GKMessageTool showText:dict[@"resultMsg"]];
        }
    }
    
    if ([aDownload.action isEqualToString:wh_act_getSign]) {
        if ([[dict objectForKey:@"package"] isEqualToString:@"Sign=WXPay"]) {
            [self tuningWxWith:dict];
        }else {
            [self tuningAlipayWithOrder:[dict objectForKey:@"orderInfo"]];
        }
    }else if ([aDownload.action isEqualToString:wh_act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
        [self actionQuit];
    }
}

- (int)WH_didServerResult_WHFailed:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_wait stop];
    return WH_show_error;
}

- (int)WH_didServerConnect_WHError:(WH_JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

- (UIView *)createViewWithRect:(CGRect)frame backgroundColor:(UIColor *)color {
    UIView *mView = [[UIView alloc] initWithFrame:frame];
    [mView setBackgroundColor:color];
    return mView;
}

@end
