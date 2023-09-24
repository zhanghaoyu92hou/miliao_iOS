//
//  MiXin_OrderInfo_MXViewController.m
//  mixin_chat
//
//  Created by Apple on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_OrderInfo_MXViewController.h"
#import "WH_PaySystemOrder.h"
#import "WH_PaySystemQrView.h"

@interface MiXin_OrderInfo_MXViewController ()

@property (nonatomic, strong) WH_PaySystemOrder *payOrder;

@end

@implementation MiXin_OrderInfo_MXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.title = @"交易中";
    [self createHeadAndFoot];
    
    [self.view setBackgroundColor:HEXCOLOR(0xF5F6FA)];
    
    self.infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP - JX_SCREEN_BOTTOM) style:UITableViewStylePlain];
    [self.infoTable setDelegate:self];
    [self.infoTable setDataSource:self];
    [self.infoTable setSeparatorColor:UITableViewCellSeparatorStyleNone];
    [self.infoTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.infoTable setBackgroundColor:self.view.backgroundColor];
    [self.view addSubview:self.infoTable];
    
    [self createBottomView];
    
    if (_model) {
        [self getOrderDetailReq];
    } else {
        [self getOrderReq];
    }
}

//获取订单
- (void)getOrderReq{
    [g_server paySystem_getOrderWithToView:self];
}

//获取订单详情接口
- (void)getOrderDetailReq{
    [g_server paySystem_getOrderDetailWithId:_model.ID toView:self];
}

- (void)createBottomView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_WIDTH)];
    [view setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.view addSubview:view];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(16, 10, 120, 32)];
    [cancelBtn setBackgroundColor:HEXCOLOR(0xffffff)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HEXCOLOR(0x007EFF) forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.borderColor = HEXCOLOR(0x007EFF).CGColor;
    cancelBtn.layer.borderWidth = 1;
    [view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelMethod) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 15, cancelBtn.frame.origin.y, CGRectGetWidth(view.frame) - CGRectGetMaxX(cancelBtn.frame) - 15 - 16, 32)];
    [payBtn setBackgroundColor:HEXCOLOR(0x007EFF)];
    [payBtn setTitle:@"我已成功付款" forState:UIControlStateNormal];
    [payBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [view addSubview:payBtn];
    payBtn.layer.masksToBounds = YES;
    payBtn.layer.cornerRadius = 5;
    [payBtn addTarget:self action:@selector(payMethod) forControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"Cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    [cell.contentView setBackgroundColor:self.infoTable.backgroundColor];
    [cell setBackgroundColor:self.infoTable.backgroundColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = 82 ;
    }else if (indexPath.row == 1) {
        cellHeight =  160;
    }else{
        cellHeight =  243;
    }
    UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.infoTable.frame), cellHeight)];
    [cView setBackgroundColor:HEXCOLOR(0xffffff)];
    [cell addSubview:cView];
    
    if (indexPath.row == 0) {
        
        //联系对方
        UIButton *lBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [lBtn setFrame:CGRectMake(CGRectGetWidth(self.infoTable.frame) - 16 - 50, (cellHeight - 38)/2, 50, 38)];
        [cell addSubview:lBtn];
        [lBtn addTarget:self action:@selector(contactEachOtherMethod) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(lBtn.frame) - 20)/2, 0, 20, 20)];
        [imgView setImage:[UIImage imageNamed:@"MX_MyWallet_Contact"]];
        [lBtn addSubview:imgView];
        
        UILabel *lLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(imgView.frame), CGRectGetWidth(lBtn.frame), CGRectGetHeight(lBtn.frame) - CGRectGetMaxY(imgView.frame)) text:@"联系对方" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 12] textColor:HEXCOLOR(0x333333) backgroundColor:cView.backgroundColor];
        [lBtn addSubview:lLabel];
        
        UILabel *tLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(16, 20, CGRectGetWidth(self.infoTable.frame) - 32 - CGRectGetWidth(lBtn.frame), 20) text:@"待付款" font:[UIFont fontWithName:@"PingFangSC-Semibold" size: 15] textColor:HEXCOLOR(0x333333) backgroundColor:cView.backgroundColor];
        [cView addSubview:tLabel];
        
        //描述
        UILabel *dec = [UIFactory WH_create_WHLabelWith:CGRectMake(16, CGRectGetMaxY(tLabel.frame) + 5, CGRectGetWidth(tLabel.frame), 18) text:@"请付款给承兑商，24小时后订单将取消" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 12] textColor:HEXCOLOR(0x666666) backgroundColor:cView.backgroundColor];
        [cView addSubview:dec];
    }else if (indexPath.row == 1) {
        //支付金额
        NSArray *array = @[@"支付金额：" ,@"单价：" ,@"数量："];
        NSArray *cArray = @[[NSString stringWithFormat:@"￥%@",_payOrder.money] ,@"1WA币=1CNY" ,[NSString stringWithFormat:@"%@WA币",_payOrder.money]];
        for (int i = 0; i < array.count; i++) {
            UILabel *pLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(16, i*53.5, 90, 53.5) text:[array objectAtIndex:i] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:cView.backgroundColor];
            [cView addSubview:pLabel];
            
            UILabel *cLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(pLabel.frame) + 10, i*53.5, CGRectGetWidth(cView.frame) - 16 - CGRectGetMaxX(pLabel.frame) - 10, 53.5) text:[cArray objectAtIndex:i] font:[UIFont fontWithName:@"PingFangSC-Medium" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:cView.backgroundColor];
            [cLabel setTextAlignment:NSTextAlignmentRight];
            [cView addSubview:cLabel];
            
            if (i < cArray.count - 1) {
                UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(pLabel.frame.origin.x, 53 + i*53, CGRectGetWidth(cView.frame) - 2*pLabel.frame.origin.x, 0.5)];
                [lView setBackgroundColor:HEXCOLOR(0xDBE0E7)];
                [cView addSubview:lView];
            }
        }
    }else{
        //承兑商信息：
        UILabel *label = [UIFactory WH_create_WHLabelWith:CGRectMake(16, 0, CGRectGetWidth(cView.frame) - 32, 53) text:@"承兑商信息：" font:[UIFont fontWithName:@"PingFangSC-Medium" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:cView.backgroundColor];
        [cView addSubview:label];
        
        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(label.frame.origin.x, 53, CGRectGetWidth(cView.frame) - 2*label.frame.origin.x, 0.5)];
        [lView setBackgroundColor:HEXCOLOR(0xDBE0E7)];
        [cView addSubview:lView];
        
        NSString *payName = nil;
        NSString *payTitle = nil;
        NSString *orderNum = nil;
        if ([_payOrder.types containsString:@"微信"]) {
            //微信
            payTitle = @"收款二维码";
            payName = [NSString stringWithFormat:@"微信账号: %@",_payOrder.zhanghao];
            orderNum = [NSString stringWithFormat:@"订单号：%@",_payOrder.ordernum];
        } else if([_payOrder.types containsString:@"支付宝"]){
            //支付宝
            payTitle = @"收款二维码";
            payName = [NSString stringWithFormat:@"支付宝账号: %@",_payOrder.zhanghao];
            orderNum = [NSString stringWithFormat:@"订单号：%@",_payOrder.ordernum];
        } else {
            //银行卡
            payTitle = [NSString stringWithFormat:@"银行卡号: %@",_payOrder.zhanghao];
            payName = [NSString stringWithFormat:@"开户银行: %@",_payOrder.khyh];
            orderNum = [NSString stringWithFormat:@"开户支行：%@",_payOrder.khdz];
        }
        NSArray *array = @[[NSString stringWithFormat:@"收款人：%@",_payOrder.zhmc] ,payTitle ,payName ,orderNum ,[NSString stringWithFormat:@"承兑商昵称：%@",_payOrder.nickname]];
        for (int i = 0; i < array.count; i++) {
            NSString *str = [array objectAtIndex:i];
            CGSize size = [str sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size: 14]}];
            UILabel *aLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(16, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), size.width, 20) text:str font:[UIFont fontWithName:@"PingFangSC-Semibold" size: 14] textColor:HEXCOLOR(0x8292B3) backgroundColor:cView.backgroundColor];
            [cView addSubview:aLabel];
            if (i == 1) {
                if ([_payOrder.types containsString:@"微信"] || [_payOrder.types containsString:@"支付宝"]) {
                    //二维码
                    UIButton *qrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [qrBtn setFrame:CGRectMake(CGRectGetMaxX(aLabel.frame) + 10, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), 20, 20)];
                    [qrBtn setImage:[UIImage imageNamed:@"MX_MyWallet_QRCode"] forState:UIControlStateNormal];
                    [cView addSubview:qrBtn];
                    [qrBtn addTarget:self action:@selector(qrCodeMethod) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    //拷贝
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setFrame:CGRectMake(CGRectGetMaxX(aLabel.frame) + 20, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), 20, 20)];
                    [btn setImage:[UIImage imageNamed:@"MX_MyWallet_Copy"] forState:UIControlStateNormal];
                    [cView addSubview:btn];
                    [btn setTag:i];
                    [btn addTarget:self action:@selector(copyMethod:) forControlEvents:UIControlEventTouchUpInside];
                }
            }else if (i == 2) {
                //账号
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(CGRectGetMaxX(aLabel.frame) + 20, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), 20, 20)];
                [btn setImage:[UIImage imageNamed:@"MX_MyWallet_Copy"] forState:UIControlStateNormal];
                [cView addSubview:btn];
                [btn setTag:i];
                [btn addTarget:self action:@selector(copyMethod:) forControlEvents:UIControlEventTouchUpInside];
            }else if (i == 3) {
                //订单号
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(CGRectGetMaxX(aLabel.frame) + 20, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), 20, 20)];
                [btn setImage:[UIImage imageNamed:@"MX_MyWallet_Copy"] forState:UIControlStateNormal];
                [cView addSubview:btn];
                [btn setTag:i];
                [btn addTarget:self action:@selector(copyMethod:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 82 + 10;
    }else if (indexPath.row == 1) {
        return 160 + 10;
    }else{
        return 243 + 10;
    }
}

#pragma mark 取消事件
- (void)cancelMethod {
    //取消
    [g_server paySystem_getCancelOrderWithOrderNum:_payOrder.ordernum toView:self];
}

#pragma mark 付款事件
- (void)payMethod {
    //我已成功付款
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [g_server paySystem_getPayOrderWithOrderNum:_payOrder.ordernum toView:self];
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"付款确认" message:@"请确认您已向卖家付款，恶意点击将直接冻结账户" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 联系对方
- (void)contactEachOtherMethod {
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *str = [NSString stringWithFormat:@"tel:%@",_payOrder.mobile];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_payOrder.mobile message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 二维码
- (void)qrCodeMethod {
    WH_PaySystemQrView *qrView = [[WH_PaySystemQrView alloc] init];
    qrView.qrUrl = _payOrder.zfpic;
    [self.view addSubview:qrView];
    [qrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
}

#pragma mark 拷贝事件
- (void)copyMethod:(UIButton *)button {
    [GKMessageTool showText:@"复制成功"];
    if (button.tag == 2) {
        //账号
        [UIPasteboard generalPasteboard].string = _payOrder.zhanghao;
    }else{
        //订单号
        [UIPasteboard generalPasteboard].string = _payOrder.ordernum;
    }
}

#pragma mark 请求成功
- (void)WH_didServerResult_WHSucces:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_portalIndexGetOrder]) {
      //获取订单
        _payOrder = [WH_PaySystemOrder mj_objectWithKeyValues:dict];
        [_infoTable reloadData];
    } else if ([aDownload.action isEqualToString:act_portalIndexGetCancelOrder]){
        //取消订单
        if ([dict[@"resultCode"] intValue] == 1) {
            [GKMessageTool showText:dict[@"resultMsg"]?:@"取消成功"];
            if (_needRefreshOrderList) {
                _needRefreshOrderList();
            }
            [self actionQuit];
        } else {
            [GKMessageTool showText:dict[@"resultMsg"]?:@"取消失败"];
        }
    } else if ([aDownload.action isEqualToString:act_portalIndexGetPayOrder]){
        //我已付款接口
        if ([dict[@"resultCode"] intValue] == 1) {
            //成功
            [GKMessageTool showText:dict[@"resultMsg"]?:@"操作成功"];
            [self actionQuit];
        } else {
            [GKMessageTool showText:dict[@"resultMsg"]?:@"操作失败"];
        }
    } else if ([aDownload.action isEqualToString:act_portalIndexGetOrderDetail]){
        //获取订单详情
        _payOrder = [WH_PaySystemOrder mj_objectWithKeyValues:dict];
        [_infoTable reloadData];
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

@end
