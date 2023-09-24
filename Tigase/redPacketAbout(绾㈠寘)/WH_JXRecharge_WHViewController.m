//
//  WH_JXRecharge_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/10/30.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXRecharge_WHViewController.h"
#import "WH_JXRecharge_WHCell.h"
#import "UIImage+WH_Color.h"
#import <AlipaySDK/AlipaySDK.h>

@interface WH_JXRecharge_WHViewController ()<UIAlertViewDelegate>
@property (nonatomic, assign) NSInteger checkIndex;
@property (atomic, assign) NSInteger payType;


//@property (nonatomic, strong) NSArray * rechargeArray;
@property (nonatomic, strong) NSArray * rechargeMoneyArray;


@property (nonatomic, strong) UILabel * totalMoney;
@property (nonatomic, strong) UIButton * wxPayBtn;
@property (nonatomic, strong) UIButton * aliPayBtn;

@end

static NSString * WH_JXRecharge_WHCellID = @"WH_JXRecharge_WHCellID";

@implementation WH_JXRecharge_WHViewController

-(instancetype)init{
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        self.title = Localized(@"JXLiveVC_Recharge");
        [self makeData];
        _checkIndex = -1;
        
        [g_notify addObserver:self selector:@selector(WH_receiveWXPayFinishNotification:) name:kWxPayFinish_WHNotification object:nil];
        [g_notify addObserver:self selector:@selector(WH_receiveAlipayFinishNotification:) name:@"kAlipayPaymentCallbackNotification" object:nil];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self WH_createHeadAndFoot];
    self.wh_isShowHeaderPull = NO;
    self.wh_isShowFooterPull = NO;
    _table.backgroundColor = HEXCOLOR(0xefeff4);
    [_table registerClass:[WH_JXRecharge_WHCell class] forCellReuseIdentifier:WH_JXRecharge_WHCellID];
    _table.showsVerticalScrollIndicator = NO;
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

-(void)dealloc{
    [g_notify removeObserver:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _rechargeMoneyArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WH_JXRecharge_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:WH_JXRecharge_WHCellID forIndexPath:indexPath];
    NSString * money = [NSString stringWithFormat:@"%@%@",_rechargeMoneyArray[indexPath.row],Localized(@"JX_ChinaMoney")];
    cell.textLabel.text = money;
    if(_checkIndex == indexPath.row){
        cell.wh_checkButton.selected = YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _checkIndex = indexPath.row;
    NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[indexPath.row]];
    [self setTotalMoneyText:money];
    NSArray * cellArray = [tableView visibleCells];
    for (WH_JXRecharge_WHCell * cell in cellArray) {
        cell.wh_checkButton.selected = NO;
    }
    
    WH_JXRecharge_WHCell * selCell = [tableView cellForRowAtIndexPath:indexPath];
    selCell.wh_checkButton.selected = YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 200;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * paySelView = [[UIView alloc] init];
    paySelView.backgroundColor = HEXCOLOR(0xefeff4);
    UILabel * payStyleLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(20, 0, JX_SCREEN_WIDTH-20*2, 40) text:Localized(@"JXMoney_choosePayType") font:sysFontWithSize(14) textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
    [paySelView addSubview:payStyleLabel];
    
    UIView * whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.frame = CGRectMake(0, CGRectGetMaxY(payStyleLabel.frame), JX_SCREEN_WIDTH, 200-CGRectGetMaxY(payStyleLabel.frame));
    [paySelView addSubview:whiteView];
    
    UILabel * totalTitle = [UIFactory WH_create_WHLabelWith:CGRectZero text:nil font:sysFontWithSize(14) textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
    NSString * totalStr = Localized(@"JXMoney_total");
    CGFloat totalWidth = [totalStr sizeWithAttributes:@{NSFontAttributeName:totalTitle.font}].width;
    totalTitle.frame = CGRectMake(20, 20, totalWidth+5, 18);
    totalTitle.text = totalStr;
    [whiteView addSubview:totalTitle];
    
    
    _totalMoney = [UIFactory WH_create_WHLabelWith:CGRectZero text:nil font:sysFontWithSize(20) textColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor]];
    NSString * totalMoneyStr = @"¥--";
    CGFloat moneyWidth = [totalMoneyStr sizeWithAttributes:@{NSFontAttributeName:_totalMoney.font}].width;
    _totalMoney.frame = CGRectMake(CGRectGetMaxX(totalTitle.frame), 20, moneyWidth+5, 18);
    _totalMoney.text = totalMoneyStr;
    _totalMoney.textColor = [UIColor redColor];
    [whiteView addSubview:_totalMoney];
    
    _wxPayBtn = [UIFactory WH_create_WHButtonWithRect:CGRectZero title:Localized(@"JXMoney_wxPay") titleFont:sysFontWithSize(17) titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(wxPayBtnAction:) target:self];
    _wxPayBtn.frame = CGRectMake(20, CGRectGetMaxY(_totalMoney.frame)+20, JX_SCREEN_WIDTH-20*2, 40);
    [_wxPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x0093FF)] forState:UIControlStateNormal];
//    [_wxPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
    _wxPayBtn.layer.cornerRadius = 5;
    _wxPayBtn.clipsToBounds = YES;
    [whiteView addSubview:_wxPayBtn];
    

    _aliPayBtn = [UIFactory WH_create_WHButtonWithRect:CGRectZero title:Localized(@"JXMoney_aliPay") titleFont:sysFontWithSize(17) titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(aliPayBtnAction:) target:self];
    _aliPayBtn.frame = CGRectMake(20, CGRectGetMaxY(_wxPayBtn.frame)+15, JX_SCREEN_WIDTH-20*2, 40);
    [_aliPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x0093FF)] forState:UIControlStateNormal];
//    [_aliPayBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0xa2dea3)] forState:UIControlStateDisabled];
    _aliPayBtn.layer.cornerRadius = 5;
    _aliPayBtn.clipsToBounds = YES;
    [whiteView addSubview:_aliPayBtn];
    
    
    return paySelView;
}

-(void)setTotalMoneyText:(NSString *)money{
    NSString * totalMoneyStr = [NSString stringWithFormat:@"¥%@",money];
    CGFloat moneyWidth = [totalMoneyStr sizeWithAttributes:@{NSFontAttributeName:_totalMoney.font}].width;
    CGRect frame = _totalMoney.frame;
    frame.size.width = moneyWidth;
    _totalMoney.frame = frame;
    _totalMoney.text = totalMoneyStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)makeData{
//    self.rechargeArray = @[@"10元",
//                           @"50元",
//                           @"100元",
//                           @"500元",
//                           @"1000元",
//                           @"5000元",
//                           @"10000元"];
    
    self.rechargeMoneyArray = @[@0.01,
                                @1,
                                @10,
                                @50,
                                @100,
                                @500,
                                @1000,
                                @5000,
                                @10000];
}


#pragma mark Action

-(void)wxPayBtnAction:(UIButton *)button{
    if (_checkIndex >=0 && _checkIndex <_rechargeMoneyArray.count) {
        NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[_checkIndex]];
        _payType = 2;
        [g_server WH_getPaySignWithPrice:money payType:2 toView:self];
    }
}

-(void)aliPayBtnAction:(UIButton *)button{
    if (_checkIndex >=0 && _checkIndex <_rechargeMoneyArray.count) {
        NSString * money = [NSString stringWithFormat:@"%@",_rechargeMoneyArray[_checkIndex]];
        _payType = 1;
        [g_server WH_getPaySignWithPrice:money payType:1 toView:self];
    }
}

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

- (void)tuningAlipayWithOrder:(NSString *)signedString {
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"wahu";
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:signedString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
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
    }
    if (_isQuitAfterSuccess) {
        [self actionQuit];
    }
}

//支付失败处理
- (void)payFailedHanlder{
    [JXMyTools showTipView:@"支付失败"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [g_server WH_getUserMoenyToView:self];
        });
    }
}


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
    //    if ([aDownload.action isEqualToString:]) {
    //        return WH_hide_error
    //    }
    return WH_show_error;
}

- (int)WH_didServerConnect_WHError:(WH_JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    //    if ([aDownload.action isEqualToString:]) {
    //        [self refreshAfterConnectError];
    //    }
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


- (void)sp_getUsersMostFollowerSuccess:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
