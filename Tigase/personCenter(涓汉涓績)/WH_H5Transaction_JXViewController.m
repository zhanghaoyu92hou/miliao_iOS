//
//  WH_H5Transaction_JXViewController.m
//  Tigase
//
//  Created by Apple on 2019/12/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_H5Transaction_JXViewController.h"

#import "WH_Recharge_TableViewCell.h"
#import "WH_webpage_WHVC.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

@interface WH_H5Transaction_JXViewController ()

@end

@implementation WH_H5Transaction_JXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = NO;
    self.wh_isGotoBack = YES;
    self.title = (self.transactionType == 1)?@"H5充值":@"H5提现";
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    self.wh_tableBody.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    if (self.transactionType == 1) {
        self.wh_zfList = [[NSMutableArray alloc] initWithObjects:@{@"icon":@"WH_ALiPay" ,@"name":@"支付宝支付"} ,
                          @{@"icon":@"WH_WeiXinPay" ,@"name":@"微信支付"} ,
                          @{@"icon":@"WH_BankIcon" ,@"name":@"银行转账"} , nil];
    }else{
        self.wh_zfList = [[NSMutableArray alloc] initWithObjects:@{@"icon":@"WH_ALiPay" ,@"name":@"支付宝"} ,
                          @{@"icon":@"WH_WeiXinPay" ,@"name":@"微信"} ,
                          @{@"icon":@"WH_BankIcon" ,@"name":@"银行卡"} , nil];
    }
    [self createMoneyContent];
    
    if (self.wh_moneyText) {
        [self.wh_moneyText becomeFirstResponder];
    }
    
}

- (void)createMoneyContent {
    UIView *mView = [self createCommonViewWithHeight:140 orginY:12];
    UILabel *mLabel = [self createCommonLabelWithWidth:CGRectGetWidth(mView.frame) - 40 labelText:(self.transactionType == 1)?@"充值余额":@"提现金额"];
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
    
    UILabel *zfmLabel = [self createCommonLabelWithWidth:CGRectGetWidth(zfView.frame) - 40 labelText:(self.transactionType == 1)?@"支付方式":@"提现到"];
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
    [payBtn setTitle:(self.transactionType == 1)?Localized(@"JXLiveVC_Recharge"):@"提现" forState:UIControlStateNormal];
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

#pragma mark 充值/提现事件
- (void)payMethod {
    NSLog(@"current select:%@" ,[self.wh_zfList objectAtIndex:self.wh_checkIndex]);
    [self.wh_moneyText resignFirstResponder];
    
    if (self.wh_moneyText.text.floatValue == 0) {
        [GKMessageTool showText:@"金额不能为0"];
        return;
    }
    
    if (self.transactionType == 1) {
        //1:微信/2:支付宝/3:银行卡
        NSInteger payType = 0;
        NSString *selectStr = self.wh_zfList[_wh_checkIndex][@"name"];
        if ([selectStr isEqualToString:@"支付宝支付"]) {
            payType = 2;
        }
        if ([selectStr isEqualToString:@"微信支付"]) {
            payType = 1;
        }
        if ([selectStr isEqualToString:@"银行转账"]) {
            payType = 3;
        }
        
        
        if (self.wh_moneyText.text.length > 0) {
            //h5充值
            NSString *ipAddress = [self getIpAddress];
            [g_server hmTransactionPayWithPrice:self.wh_moneyText.text payType:8 payWap:[NSString stringWithFormat:@"%li" ,(long)payType] userIp:ipAddress?:@"" toView:self];
        }else{
            [GKMessageTool showText:@"请填写需要充值的金额"];
            return;
        } 
    }
}

#pragma mark 请求成功
- (void)WH_didServerResult_WHSucces:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_getSign]) {
        NSLog(@"dict:%@  array1:%@" ,dict ,array1);

        [g_server h5PaymentWithMoney:[dict objectForKey:@"money"]?:@"" notifyUrl:[dict objectForKey:@"notify_url"]?:@"" tradeNo:[dict objectForKey:@"out_trade_no"]?:@"" pId:[dict objectForKey:@"pid"]?:@"" returnUrl:[dict objectForKey:@"return_url"]?:@"" sign:[dict objectForKey:@"sign"]?:@"" type:[dict objectForKey:@"type"]?:@"" userId:[dict objectForKey:@"userid"]?:@"" userIp:[dict objectForKey:@"userip"]?:@"" toView:self];
    }else{
        NSString *url = [dict objectForKey:@"resultUrl"];
        if (url) {
            WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
            webVC.isGoBack= YES;
            webVC.isSend = YES;
            webVC.title = @"";
//            webVC.isPostRequest = YES;
            webVC.url = url;
            webVC = [webVC init];
            [g_navigation.navigationView addSubview:webVC.view];

        }
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

- (NSString *) getIpAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
