//
//  WH_NewRecharge_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_NewRecharge_WHViewController.h"

#import "WH_NewRecharge_WHTableViewCell.h"
#import "WH_ConfirmPayment_WHViewController.h"

#import "WH_MyOrderList_WHViewController.h"
#import "WH_PayTypeModel.h"

#define MIXIN_TEXTCOLOR HEXCOLOR(0x3A404C)

@interface WH_NewRecharge_WHViewController ()

@property (nonatomic, strong)NSArray <WH_PayTypeModel *> *payTypes;

@end

@implementation WH_NewRecharge_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = NO;
    self.wh_isGotoBack = YES;
    self.title = Localized(@"JXLiveVC_Recharge");
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    //我的订单
    UIButton *orderBtn = [UIFactory WH_create_WHButtonWithRect:CGRectMake(JX_SCREEN_WIDTH - 16 - 70, JX_SCREEN_TOP - 33, 70, 21) title:@"我的订单" titleFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15] titleColor:HEXCOLOR(0x2C2F36) normal:nil selected:nil selector:@selector(myOrdersData) target:self];
    [self.wh_tableHeader addSubview:orderBtn];
    
    self.listArray = [[NSMutableArray alloc] init];
    if ([g_config.aliPayStatus integerValue] == 1) {
        [self.listArray addObject:@{@"icon":@"MX_MyWallet_Alipay" ,@"name":@"支付宝支付"}];
    }
    
    if ([g_config.wechatPayStatus integerValue] == 1) {
        [self.listArray addObject:@{@"icon":@"MX_MyWallet_WeiXinPay" ,@"name":@"微信支付"}];
    }
    
    //    [self.zfList addObject:@{@"icon":@"WH_BankIcon" ,@"name":@"银行转账"}];
    if ([g_config.yunPayStatus integerValue] == 1) {
        //打开了云支付
        [self.listArray addObject:@{@"icon":@"MX_MyWallet_UnionPayPayment" ,@"name":@"银行转账"}];
    }
    
    
    [self.recMoneyTextField becomeFirstResponder];
    
    UIView *bView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 44 - JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM + 44)];
    [bView setBackgroundColor:HEXCOLOR(0xF5F6FA)];
    [self.view addSubview:bView];
    
    UIButton *subBtn = [UIFactory WH_create_WHLogOutButton:@"提交" target:self action:@selector(submitMethod)];
    [subBtn setFrame:CGRectMake(16, 10, JX_SCREEN_WIDTH - 32, 44)];
    [bView addSubview:subBtn];
    [subBtn setBackgroundColor:HEXCOLOR(0x007EFF)];
    subBtn.layer.cornerRadius = 22;
    subBtn.layer.masksToBounds = YES;
    
    UIView *pmView = [self createPaymentMethodViewWithOrginY:JX_SCREEN_TOP viewHeight:JX_SCREEN_HEIGHT - 44 - JX_SCREEN_BOTTOM - JX_SCREEN_TOP - 20];
    [self.view addSubview:pmView];
    

    
    [self getPayTypeReq];
}

//获取支付类型请求
- (void)getPayTypeReq{
    [g_server paySystem_getPayTypeToView:self];
}

//提交充值订单请求
- (void)submitMethod{
    
    if ([self.recMoneyTextField.text floatValue] <= 0) {
        [GKMessageTool showText:@"请填写需要充值的金额"];
        return;
    }
    
    NSString *accStr = [self.accountTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([accStr length] == 0) {
        [GKMessageTool showText:@"请填写您要使用的充值账号"];
        return;
    }
    
    if (_checkIndex < self.payTypes.count) {
        NSString *zfid = self.payTypes[_checkIndex].zfid;
        WH_ConfirmPayment_WHViewController *conPaymentVC = [[WH_ConfirmPayment_WHViewController alloc] init];
        conPaymentVC.pay_money = self.recMoneyTextField.text;
        conPaymentVC.paymentType = self.checkIndex;
        conPaymentVC.pTypeArray = self.listArray;
        conPaymentVC.zfid = zfid;
        conPaymentVC.accountNumber = self.accountTextField.text;
        [g_navigation pushViewController:conPaymentVC animated:YES];
    }
}

- (UIView *)createPaymentMethodViewWithOrginY:(CGFloat)orginY viewHeight:(CGFloat)height{
    UIView *cView = [self createViewWithRect:CGRectMake(0, orginY, JX_SCREEN_WIDTH, height) backgroundColor:HEXCOLOR(0xffffff)];
    
    self.listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cView.frame), CGRectGetHeight(cView.frame)) style:UITableViewStylePlain];
    [self.listTable setDataSource:self];
    [self.listTable setDelegate:self];
    [self.listTable setBackgroundColor:cView.backgroundColor];
    [self.listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.listTable setTableHeaderView:[self createMoneyView]];
    [cView addSubview:self.listTable];
    
    return cView;
}

#pragma mark 需输入金额数视图
- (UIView *)createMoneyView {
    UIView *mView = [self createViewWithRect:CGRectMake(0, 0, JX_SCREEN_WIDTH, 235 + 50 + 10) backgroundColor:self.view.backgroundColor];
    //    [self.tableBody addSubview:mView];
    [self.view addSubview:mView];
    
    UIView *numView = [self createViewWithRect:CGRectMake(0, 0, CGRectGetWidth(mView.frame), 175) backgroundColor:HEXCOLOR(0xffffff)];
    [mView addSubview:numView];
    UIView *nlView = [self createViewWithRect:CGRectMake(0, 0, CGRectGetWidth(numView.frame), 0.5) backgroundColor:HEXCOLOR(0xF0F0F0)];
    [numView addSubview:nlView];
    
    UILabel *numLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(16, 0.5, CGRectGetWidth(numView.frame) - 32, 54) text:@"充值数量" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 17] textColor:MIXIN_TEXTCOLOR backgroundColor:numView.backgroundColor];
    [numView addSubview:numLabel];
    
    self.recMoneyTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(16, CGRectGetMaxY(numLabel.frame), CGRectGetWidth(numView.frame) - 16 - 54 - 5, CGRectGetHeight(numView.frame) - 40.5 - 54) keyboardType:UIKeyboardTypeTwitter secure:NO placeholder:@"请输入充值数量1~10000" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 16] color:MIXIN_TEXTCOLOR delegate:self];
    //textField.borderStyle
    self.recMoneyTextField.borderStyle = UITextBorderStyleNone;
    self.recMoneyTextField.returnKeyType = UIReturnKeyDone;
    [self.recMoneyTextField setTag:10];
    [numView addSubview:self.recMoneyTextField];
    [self.recMoneyTextField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
    
    UILabel *markLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetWidth(numView.frame) - 16 - 50, CGRectGetMaxY(numLabel.frame), 50, CGRectGetHeight(numView.frame) - 40.5 - 54) text:@"WA币" font:[UIFont fontWithName:@"PingFangSC-Medium" size: 18] textColor:MIXIN_TEXTCOLOR backgroundColor:numView.backgroundColor];
    [markLabel setTextAlignment:NSTextAlignmentRight];
    [numView addSubview:markLabel];
    
    UIView *lView = [self createViewWithRect:CGRectMake(16, CGRectGetMaxY(markLabel.frame), CGRectGetWidth(numView.frame) - 32, 0.5) backgroundColor:HEXCOLOR(0xDBE0E7)];
    [numView addSubview:lView];
    
    UILabel *djLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(16, CGRectGetMaxY(lView.frame), CGRectGetWidth(lView.frame), 40) text:@"单价：1WA币=1CNY" font:[UIFont fontWithName:@"PingFangSC-Medium" size: 14] textColor:HEXCOLOR(0x8292B3) backgroundColor:numView.backgroundColor];
    [mView addSubview:djLabel];
    
    //支付金额
    UIView *pView = [self createViewWithRect:CGRectMake(0, CGRectGetMaxY(numView.frame) + 8, CGRectGetWidth(mView.frame), 54) backgroundColor:HEXCOLOR(0xffffff)];
    [mView addSubview:pView];
    UILabel *pLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(16, 0, 80, CGRectGetHeight(pView.frame)) text:@"支付金额：" font:[UIFont fontWithName:@"PingFangSC-Medium" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:pView.backgroundColor];
    [pView addSubview:pLabel];
    
    self.pMoneyLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(pLabel.frame), 0, CGRectGetWidth(pView.frame) - CGRectGetMaxX(pLabel.frame) - 16, CGRectGetHeight(pView.frame)) text:@"￥0.00" font:[UIFont fontWithName:@"PingFangSC-Medium" size: 16] textColor:HEXCOLOR(0x000000) backgroundColor:pView.backgroundColor];
    [self.pMoneyLabel setTextAlignment:NSTextAlignmentRight];
    [pView addSubview:self.pMoneyLabel];
    
    UIView *clView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(pView.frame) + 10, CGRectGetWidth(pView.frame), 50)];
    [clView setBackgroundColor:HEXCOLOR(0xffffff)];
    [mView addSubview:clView];
    UILabel *cLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(16, 0, CGRectGetWidth(clView.frame) - 32, 50) text:@"请选择支付方式：" font:[UIFont fontWithName:@"PingFangSC-Medium" size: 14] textColor:HEXCOLOR(0x3A404C) backgroundColor:pView.backgroundColor];
    [clView addSubview:cLabel];
    
    return mView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RechargeCell" ;
    WH_NewRecharge_WHTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[WH_NewRecharge_WHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
    [cell setBackgroundColor:HEXCOLOR(0xffffff)];
    
    NSDictionary *dict = [self.listArray objectAtIndex:indexPath.row];
    [cell setData:dict];
    
    if (indexPath.row > 0 && indexPath.row < self.listArray.count) {
        UIView *lView = [self createViewWithRect:CGRectMake(16 + 25 +12, 65, CGRectGetWidth(self.listTable.frame) - 16 - 12 - 25 - 16, 0.5) backgroundColor:HEXCOLOR(0xF8F8F7)];
        [cell addSubview:lView];
    }
    
    if (self.checkIndex == indexPath.row) {
        [cell.checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Selected2"] forState:UIControlStateNormal];
        
        UIView *view = [self createViewWithRect:CGRectMake(53, 66, CGRectGetWidth(self.listTable.frame) - 53 - 16, 189 - 53) backgroundColor:cell.backgroundColor];
        [cell addSubview:view];
        
        UIView *cardView = [self createViewWithRect:CGRectMake(0, 0, CGRectGetWidth(view.frame), 40) backgroundColor:HEXCOLOR(0xF8F8F8)];
        [view addSubview:cardView];
        cardView.layer.masksToBounds = YES;
        cardView.layer.cornerRadius = 5;
        
        //[self.listArray addObject:@{@"icon":@"WH_BankIcon" ,@"name":@"银行转账"}];
        
//        NSString *cardType = @"支付宝";
//        if (indexPath.row == 1) {
//            cardType = @"微信";
//        }else if (indexPath.row == 2) {
//            cardType = @"银行卡";
//        }

        NSString *cardType = [dict objectForKey:@"name"];
        
        if (self.accountTextField) {
            [self.accountTextField removeFromSuperview];
        }
        self.accountTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(10, 8, CGRectGetWidth(cardView.frame) - 20, 40 - 16) keyboardType:UIKeyboardTypeDefault secure:NO placeholder:[NSString stringWithFormat:@"请输入%@账号" , cardType] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 17] color:MIXIN_TEXTCOLOR delegate:self];
        [cardView addSubview:self.accountTextField];
        [self.accountTextField setTag:indexPath.row];
        self.accountTextField.borderStyle = UITextBorderStyleNone;
        self.accountTextField.returnKeyType = UIReturnKeyDone;
        [self.accountTextField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
        
        UILabel *label = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(cardView.frame) + 10, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame) - CGRectGetMaxY(cardView.frame) - 10) text:[NSString stringWithFormat:@"请填写您要使用的充值%@账号，以便于我们可以正确验证您的充值信息。填写后，信息将会保存，下次将不用在输入。" ,cardType] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 14] textColor:MIXIN_TEXTCOLOR backgroundColor:view.backgroundColor];
        [view addSubview:label];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
    }else{
        [cell.checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Default"] forState:UIControlStateNormal];
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.checkIndex == indexPath.row) {
        return 189 ;
    }else{
        return 66;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.checkIndex = indexPath.row;
    
    WH_NewRecharge_WHTableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i = 0; i < self.listArray.count; i++) {
        if (self.checkIndex == i) {
            [selectCell.checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Selected2"] forState:UIControlStateNormal];
        }else {
            [selectCell.checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Default"] forState:UIControlStateNormal];
        }
    }
    [self.listTable reloadData];
}

- (void)textField1TextChange:(UITextField *)textField {
    NSLog(@"textField.tag:%li" ,(long)textField.tag);
    
    if (textField.tag == 10) {
        [self.pMoneyLabel setText:@""];
        [self.pMoneyLabel setText:(textField.text && [textField.text integerValue] > 0)?[NSString stringWithFormat:@"￥%@" ,textField.text]:@"￥0.00"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark 我的订单
- (void)myOrdersData {
    WH_MyOrderList_WHViewController *orderListVC = [[WH_MyOrderList_WHViewController alloc] init];
    [g_navigation pushViewController:orderListVC animated:YES];
}

- (UIView *)createViewWithRect:(CGRect)frame backgroundColor:(UIColor *)color {
    UIView *mView = [[UIView alloc] initWithFrame:frame];
    [mView setBackgroundColor:color];
    return mView;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_portalIndexGetZhxx] ){
        // 获取支付类型
        _payTypes = [WH_PayTypeModel mj_objectArrayWithKeyValuesArray:array1];
        //准备listArray
        _listArray = [NSMutableArray array];
        for (WH_PayTypeModel *model in _payTypes) {
            if ([model.zfmc containsString:@"支付宝"]) {
                [self.listArray addObject:@{@"icon":@"MX_MyWallet_Alipay" ,@"name":@"支付宝支付"}];
            } else if ([model.zfmc containsString:@"微信"])  {
                [self.listArray addObject:@{@"icon":@"MX_MyWallet_WeiXinPay" ,@"name":@"微信支付"}];
            } else if ([model.zfmc containsString:@"银行"]){
                [self.listArray addObject:@{@"icon":@"MX_MyWallet_UnionPayPayment" ,@"name":@"银行转账"}];
            }
        }
        [_listTable reloadData];
    }
}


#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
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

@end
