//
//  WH_Recharge_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_Recharge_WHViewController.h"

#import "WH_Recharge_TableViewCell.h"

#import <AlipaySDK/AlipaySDK.h>


#import "WH_BankRecharge_WHVC.h"

#import "WH_webpage_WHVC.h"

#import "FCUUID.h"

@interface WH_Recharge_WHViewController ()

@end

@implementation WH_Recharge_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = NO;
    self.wh_isGotoBack = YES;
    self.title = Localized(@"JXLiveVC_Recharge");
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    self.wh_tableBody.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    

    //    NSArray *array = @[@{@"icon":@"WH_ALiPay" ,@"name":@"支付宝支付"} ,@{@"icon":@"WH_WeiXinPay" ,@"name":@"微信支付"},
    //                       @{@"icon":@"WH_BankIcon" ,@"name":@"银行转账"}];
    
    
    self.wh_zfList = [[NSMutableArray alloc] init];
    
    
    // 根据后台配置
    //aliPayStatus 支付宝充值状态 1:开启 2：关闭 wechatWithdrawStatus 微信提现状态1：开启 2：关闭
    

    if ([g_config.aliPayStatus integerValue] == 1) {
        [self.wh_zfList addObject:@{@"icon":@"WH_ALiPay" ,@"name":@"支付宝支付"}];
    }
    
    if ([g_config.wechatPayStatus integerValue] == 1) {
        if ([WXApi isWXAppInstalled]) {
            [self.wh_zfList addObject:@{@"icon":@"WH_WeiXinPay" ,@"name":@"微信支付"}];
        }
        
    }
    
    //    [self.zfList addObject:@{@"icon":@"WH_BankIcon" ,@"name":@"银行转账"}];
    if ([g_config.yunPayStatus integerValue] == 1) {
        //打开了云支付
        [self.wh_zfList addObject:@{@"icon":@"WH_BankIcon" ,@"name":@"银行转账"}];
        [self.wh_zfList addObject:@{@"icon":@"WH_H5Recharge_WHIcon" ,@"name":@"网页支付"}];
    }

    
    [self createMoneyContent];
    
    [self.wh_moneyText becomeFirstResponder];
    
    [g_notify addObserver:self selector:@selector(WaHu_receiveWXPayFinishNotification:) name:kWxPayFinish_WHNotification object:nil];
    [g_notify addObserver:self selector:@selector(WH_receiveAlipayFinishNotification:) name:@"kAlipayPaymentCallbackNotification" object:nil];
}

//- (void)createMoneyContent {
//    UIView *mView = [self createCommonViewWithHeight:140 orginY:12];
//    UILabel *mLabel = [self createCommonLabelWithWidth:CGRectGetWidth(mView.frame) - 40 labelText:@"充值余额"];
//    [mView addSubview:mLabel];
//
//    UILabel *mqLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(mLabel.frame) + 25, 20, 42)];
//    [mqLabel setText:@"¥"];
//    [mqLabel setTextColor:HEXCOLOR(0x3A404C)];
//    [mqLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 30]];
//    [mView addSubview:mqLabel];
//
//    self.wh_moneyText = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(CGRectGetMaxX(mqLabel.frame) + 10, CGRectGetMaxY(mLabel.frame) + 15, CGRectGetWidth(mView.frame) - CGRectGetMaxX(mqLabel.frame) - g_factory.globelEdgeInset - 10, 60) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:nil font:[UIFont fontWithName:@"PingFangSC-Medium" size: 45] color:HEXCOLOR(0x3A404C) delegate:self];
//    [self.wh_moneyText setBorderStyle:UITextBorderStyleNone];
//    [mView addSubview:self.wh_moneyText];
//    [self.wh_moneyText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//
//    UIView *zfView = [self createCommonViewWithHeight:171 orginY:CGRectGetMaxY(mView.frame) + 12];
//
//    UILabel *zfmLabel = [self createCommonLabelWithWidth:CGRectGetWidth(zfView.frame) - 40 labelText:@"支付方式"];
//    [zfView addSubview:zfmLabel];
//
//    self.wh_zfTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(zfmLabel.frame) + 10, CGRectGetWidth(zfView.frame) , self.wh_zfList.count * 60) style:UITableViewStylePlain];
//    [self.wh_zfTable setBackgroundColor:zfView.backgroundColor];
//    [self.wh_zfTable setDelegate:self];
//    [self.wh_zfTable setDataSource:self];
//    [self.wh_zfTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.wh_zfTable setScrollEnabled:NO];
//    [zfView addSubview:self.wh_zfTable];
//
//    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [payBtn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(zfView.frame) + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
//    [payBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
//    [payBtn setTitle:Localized(@"JXLiveVC_Recharge") forState:UIControlStateNormal];
//    [payBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
//    [payBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
//    [self.wh_tableBody addSubview:payBtn];
//    [payBtn addTarget:self action:@selector(payMethod) forControlEvents:UIControlEventTouchUpInside];
//    payBtn.layer.masksToBounds = YES;
//    payBtn.layer.cornerRadius = g_factory.cardCornerRadius;
//}

- (void)createMoneyContent {
    UIView *mView = [self createCommonViewWithHeight:140 orginY:12];
    UILabel *mLabel = [self createCommonLabelWithWidth:CGRectGetWidth(mView.frame) - 40 labelText:@"充值余额"];
    [mView addSubview:mLabel];
    
    UILabel *mqLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(mLabel.frame) + 25, 20, 42)];
    [mqLabel setText:@"¥"];
    [mqLabel setTextColor:HEXCOLOR(0x3A404C)];
    [mqLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 30]];
    [mView addSubview:mqLabel];
    
    self.wh_moneyText = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(CGRectGetMaxX(mqLabel.frame) + 10, CGRectGetMaxY(mLabel.frame) + 15, CGRectGetWidth(mView.frame) - CGRectGetMaxX(mqLabel.frame) - g_factory.globelEdgeInset - 10, 60) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:nil font:[UIFont fontWithName:@"PingFangSC-Medium" size: 45] color:HEXCOLOR(0x3A404C) delegate:self];
    [self.wh_moneyText setBorderStyle:UITextBorderStyleNone];
    [mView addSubview:self.wh_moneyText];
    [self.wh_moneyText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIView *zfView = [self createCommonViewWithHeight:55+self.wh_zfList.count * 60 orginY:CGRectGetMaxY(mView.frame) + 12];
    
    UILabel *zfmLabel = [self createCommonLabelWithWidth:CGRectGetWidth(zfView.frame) - 40 labelText:@"支付方式"];
    [zfView addSubview:zfmLabel];
    
    self.wh_zfTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(zfmLabel.frame) + 10, CGRectGetWidth(zfView.frame) , self.wh_zfList.count * 60) style:UITableViewStylePlain];
    [self.wh_zfTable setBackgroundColor:zfView.backgroundColor];
    [self.wh_zfTable setDelegate:self];
    [self.wh_zfTable setDataSource:self];
    [self.wh_zfTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_zfTable setScrollEnabled:NO];
    [zfView addSubview:self.wh_zfTable];
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(zfView.frame) + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    [payBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    [payBtn setTitle:Localized(@"JXLiveVC_Recharge") forState:UIControlStateNormal];
    [payBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [payBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [self.wh_tableBody addSubview:payBtn];
    [payBtn addTarget:self action:@selector(payMethod) forControlEvents:UIControlEventTouchUpInside];
    payBtn.layer.masksToBounds = YES;
    payBtn.layer.cornerRadius = g_factory.cardCornerRadius;
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
    
    NSDictionary *dict = [self.wh_zfList objectAtIndex:indexPath.row];
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
    _wh_checkIndex = indexPath.row;
    
    
    [self.wh_moneyText resignFirstResponder];
    
    WH_Recharge_TableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
//    selCell.checkButton.selected = YES;
    for (int i = 0; i < _wh_zfList.count; i++) {
        if (_wh_checkIndex == i) {
            [selCell.wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_selected"] forState:UIControlStateNormal];
        }else{
            [selCell.wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_unselected"] forState:UIControlStateNormal];
        }
    }
    [self.wh_zfTable reloadData];
}

- (void)payMethod {
    
    [self.wh_moneyText resignFirstResponder];
    
    if (self.wh_moneyText.text.floatValue == 0) {
        [GKMessageTool showText:@"金额不能为0"];
        return;
    }
    
    NSString *selectStr = self.wh_zfList[_wh_checkIndex][@"name"];
    
    if ([selectStr isEqualToString:@"支付宝支付"]) {
        //支付宝支付
        if (self.wh_moneyText.text.length > 0) {
            [g_server WH_getPaySignWithPrice:self.wh_moneyText.text payType:1 toView:self];
        }else{
            [GKMessageTool showText:@"请填写需要充值的金额"];
            return;
        }
        
    }else if ([selectStr isEqualToString:@"微信支付"]){
        //微信支付
        if (self.wh_moneyText.text.length > 0) {
            [g_server WH_getPaySignWithPrice:self.wh_moneyText.text payType:2 toView:self];
        }else{
            [GKMessageTool showText:@"请填写需要充值的金额"];
            return;
        }
    } else if ([selectStr isEqualToString:@"银行转账"]){
        //银行转账
        if (self.wh_moneyText.text.length > 0) {
            //跳转到银行转账界面
            WH_BankRecharge_WHVC *vc = [[WH_BankRecharge_WHVC alloc] init];
            vc.money = self.wh_moneyText.text;
            [g_navigation pushViewController:vc animated:YES];
        }else{
            [GKMessageTool showText:@"请填写需要充值的金额"];
            return;
        }
    } else{
        //网页支付
        NSString *appId =  @"2019081914593640521";
        NSString *appKey = @"e87c5fad3a76c75cca30a38618bf6282";
        NSString *host = @"http://43.132.102.226";
         // @"http://pay.域名";
        NSString *callbackUrl = @"http://43.132.102.226:8092/pay/callbackUrl"; //@"http://changquhuyu.cn:80/pay/callbackUrl"; // @"http://api.域名/pay/callbackUrl";
        NSString *tOrderNumber = [FCUUID uuid];
        NSString *money = [NSString stringWithFormat:@"%ld",(long)(self.wh_moneyText.text.floatValue * 100)]; //金额转换为分单位
        
        WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
        webVC.wh_isGotoBack= YES;
        webVC.isSend = YES;
        webVC.url = [NSString stringWithFormat:@"%@/business/api/h5Order?appId=%@&apiKey=%@&userName=%ld&callbackUrl=%@&serialAmount=%@&tOrderNumber=%@",host,appId,appKey,g_server.user_id,callbackUrl,money,tOrderNumber];
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
-(void)WaHu_receiveWXPayFinishNotification:(NSNotification *)notifi{
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

- (void)textFieldDidChange:(UITextField *)textField {
    
}

- (UIView *)createCommonViewWithHeight:(CGFloat)height orginY:(CGFloat)orginY{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, orginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, height)];
    [view setBackgroundColor:HEXCOLOR(0xffffff)];
    view.layer.cornerRadius = g_factory.cardCornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = g_factory.cardBorderColor.CGColor;
    view.layer.borderWidth = g_factory.cardBorderWithd;
    [self.wh_tableBody addSubview:view];
    return view;
}

- (UILabel *)createCommonLabelWithWidth:(CGFloat)width labelText:(NSString *)text{
    UILabel *mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, width, 24)];
    [mLabel setText:text];
    [mLabel setTextColor:HEXCOLOR(0x3A404C)];
    [mLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 17]];
    return mLabel;
}


@end
