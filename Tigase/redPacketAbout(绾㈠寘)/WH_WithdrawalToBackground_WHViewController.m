//
//  WH_WithdrawalToBackground_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/28.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_WithdrawalToBackground_WHViewController.h"

#import "WH_Recharge_TableViewCell.h"
#import "WH_RechargeSelectAccount_WHCell.h"
#import "WH_JXPayPassword_WHVC.h"

#import "WH_SuccessfulWithdrawal_WHViewController.h"
#import "WH_WithdrawalList_WHViewController.h"  //选择提现账号的列表

@interface WH_WithdrawalToBackground_WHViewController ()
@property (nonatomic, strong) NSDictionary *selectedAccountDic;
@end

@implementation WH_WithdrawalToBackground_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.title = Localized(@"JXMoney_withdrawals");
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    UIView *tView = [self createMoneyView];
    [self.wh_tableBody addSubview:tView];
    self.wh_tableBody.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.listArray = [[NSMutableArray alloc] initWithObjects:@{@"icon":@"MX_MyWallet_Alipay" ,@"name":@"支付宝"} ,@{@"icon":@"WH_BankIcon" ,@"name":@"银行卡支付"} , nil];
    
    self.tableOrginY = CGRectGetMaxY(tView.frame) + 12;
    
    [g_server WH_getWithdrawalAccountListWithParam:nil toView:self];
    
    [self createContentTable];
    
    UIView *bView = [self createBottomViewWithOrginY:CGRectGetMaxY(self.pMementTable.frame) + 12];
    [self.wh_tableBody addSubview:bView];
    self.wh_tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, CGRectGetMaxY(bView.frame) + 22);

}

- (void)createContentTable {
    self.pMementTable = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, self.tableOrginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, self.listArray.count *66 + 40*3 + 16 + 20) style:UITableViewStylePlain];
    if (IS_CanAdd_WithdrawAccount) {
        self.pMementTable.frame = CGRectMake(g_factory.globelEdgeInset, self.tableOrginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 110);
        self.pMementTable.rowHeight = UITableViewAutomaticDimension;
        self.pMementTable.estimatedRowHeight = 55 * 2;
        self.pMementTable.scrollEnabled = NO;
    }
    [self.pMementTable setDelegate:self];
    [self.pMementTable setDataSource:self];
    [self.pMementTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //    [self.pMementTable setTableHeaderView:[self createMoneyView]];
    //    [self.pMementTable setTableFooterView:[self createBottomView]];
    [self.pMementTable setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_tableBody addSubview:self.pMementTable];
    self.pMementTable.layer.masksToBounds = YES;
    self.pMementTable.layer.cornerRadius = g_factory.cardCornerRadius;
    self.pMementTable.layer.borderColor = g_factory.cardBorderColor.CGColor;
    self.pMementTable.layer.borderWidth = g_factory.cardBorderWithd;
    self.pMementTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (UIView *)createMoneyView {
    UIView *cView = [self createViewWithRect:CGRectMake(0, 0, JX_SCREEN_WIDTH, 184 + 24) backgroundColor:self.wh_tableBody.backgroundColor];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 184)];
    [view setBackgroundColor:HEXCOLOR(0xffffff)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = g_factory.cardCornerRadius;
    view.layer.borderColor = g_factory.cardBorderColor.CGColor;
    view.layer.borderWidth = g_factory.cardBorderWithd;
    [cView addSubview:view];

    UILabel *label = [UIFactory WH_create_WHLabelWith:CGRectMake(20, 20, CGRectGetWidth(view.frame) - 40, 24) text:Localized(@"JXMoney_withDAmount")];
    [label setTextColor:HEXCOLOR(0x3A404C)];
    [label setFont:[UIFont fontWithName:@"PingFangSC" size: 17]];
    [view addSubview:label];
    
    UILabel *pmLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(20, CGRectGetMaxY(label.frame) + 20, 30, 63) text:@"￥"];
    [pmLabel setTextColor:HEXCOLOR(0x3A404C)];
    [pmLabel setFont:sysBoldFontWithSize(28)];
    [view addSubview:pmLabel];

    NSString *minMoney = g_config.minWithdrawToAdmin?:@"0.00";
    self.moneyTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(pmLabel.frame) + 10, CGRectGetMaxY(label.frame) + 20, CGRectGetWidth(view.frame) - CGRectGetMaxX(pmLabel.frame) - 20, 63)];
    [self.moneyTextField setTextColor:HEXCOLOR(0x3A404C)];
    [self.moneyTextField setFont:sysBoldFontWithSize(18)];
    [self.moneyTextField setPlaceholder:[NSString stringWithFormat:@"请输入%@元以上金额",minMoney]];
    [self.moneyTextField setBorderStyle:UITextBorderStyleNone];
    [self.moneyTextField setDelegate:self];
    [view addSubview:self.moneyTextField];
    
    UIView * line = [[UIView alloc] init];
    line.frame = CGRectMake(20, CGRectGetMaxY(self.moneyTextField.frame) + 10, CGRectGetWidth(view.frame) - 40, 0.5);
    line.backgroundColor = g_factory.cardBorderColor;
    [view addSubview:line];
    
    NSString * moneyStr = [NSString stringWithFormat:@"%@¥%.2f",Localized(@"JXMoney_blance"),g_App.myMoney];
    UILabel *_balanceLabel = [UIFactory WH_create_WHLabelWith:CGRectZero text:moneyStr font:sysFontWithSize(14) textColor:HEXCOLOR(0xBAC3D5) backgroundColor:nil];
    CGFloat blanceWidth = [moneyStr sizeWithAttributes:@{NSFontAttributeName:_balanceLabel.font}].width;
    [view addSubview:_balanceLabel];
    [_balanceLabel setFrame:CGRectMake(20, CGRectGetHeight(view.frame) - 18 - 20, blanceWidth, 20)];
    
    UIButton *pAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pAllBtn setTitle:Localized(@"JXMoney_withDAll") forState:UIControlStateNormal];
    [pAllBtn setTitleColor:HEXCOLOR(0x0093FF) forState:UIControlStateNormal];
    [pAllBtn.titleLabel setFont:sysFontWithSize(14)];
    NSString *pAllStr = Localized(@"JXMoney_withDAll");
    CGFloat pAllWidth = [pAllStr sizeWithAttributes:@{NSFontAttributeName:pAllBtn.titleLabel.font}].width + 10;
    [view addSubview:pAllBtn];
    [pAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view.mas_right).offset(-20);
        make.bottom.equalTo(view.mas_bottom).offset(-12);
        make.size.mas_equalTo(CGSizeMake(pAllWidth, 20));
    }];
    [pAllBtn addTarget:self action:@selector(allWithdrawalsBtnClickMethod) forControlEvents:UIControlEventTouchUpInside];
    
    return cView;
}

- (UIView *)createBottomViewWithOrginY:(CGFloat)orginY {
//    CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_HEIGHT - (168 + 15 + 44), CGRectGetWidth(self.pMementTable.frame) - 2*g_factory.globelEdgeInset, 168 + 15 + 44)
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.pMementTable.frame), JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 168 + 15 + 44)];
    [view setBackgroundColor:self.wh_tableBody.backgroundColor];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake(0, 20, view.frame.size.width, 44)];
    [confirmBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    [confirmBtn setTitle:@"确认提现" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:sysFontWithSize(16)];
    [view addSubview:confirmBtn];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    [confirmBtn addTarget:self action:@selector(confirmWithdrawalMethod) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *labelStr = @"提现说明：\n1. 支持两种提现方式：支付宝提现，银行卡提现。\n2. 支付宝提现需要输入支付宝提现账号信息。\n3. 银行卡提现需要输入银行卡号，开户行，户名，开户支行。\n4. 提现后，平台会对提现信息进行审核，审核确认提现后将收到提现通过提示，请留意您的账号，注意收款。";
    UILabel *label = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(confirmBtn.frame) + 10, CGRectGetWidth(view.frame), 168) text:labelStr font:sysFontWithSize(14) textColor:HEXCOLOR(0x8F9CBB) backgroundColor:view.backgroundColor];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:7];//调整行间距
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setNumberOfLines:0];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelStr length])];
    label.attributedText = attributedString;
    
    [view addSubview:label];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (IS_CanAdd_WithdrawAccount) {
        return 1;
    } else {
        return self.listArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_CanAdd_WithdrawAccount) {//可以添加提现账号
        static NSString *selectAccountCellIdentifier = @"selectAccountCell";
        WH_RechargeSelectAccount_WHCell *selectAccountCell = [tableView dequeueReusableCellWithIdentifier:selectAccountCellIdentifier];
        if (!selectAccountCell) {
            selectAccountCell = [[WH_RechargeSelectAccount_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectAccountCellIdentifier];
        }
        if (self.selectedAccountDic) {
            selectAccountCell.data = self.selectedAccountDic;
            [selectAccountCell loadContent];
        }
        
        __weak typeof(selectAccountCell) selectAccountCellWeak = selectAccountCell;
        __weak typeof(self) weakSelf = self;
        selectAccountCell.selectAccountBlock = ^{
            WH_WithdrawalList_WHViewController *wh_accountListVC = [[WH_WithdrawalList_WHViewController alloc] init];
            wh_accountListVC.titleName = @"选择提现方式";
            wh_accountListVC.selectedAccountDic = weakSelf.selectedAccountDic;
            
            wh_accountListVC.selectAccountBlock = ^(NSDictionary * _Nonnull accountDic) {
                selectAccountCellWeak.data = accountDic;
                [selectAccountCellWeak loadContent];
                weakSelf.selectedAccountDic = accountDic;
            };
            [g_navigation pushViewController:wh_accountListVC animated:YES];
        };
        return selectAccountCell;
    } else {
        
        //以前的提现方式,每次都需要填写账号
        static NSString *CellIdentifier = @"cell";
        
        WH_Recharge_TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[WH_Recharge_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell setBackgroundColor:HEXCOLOR(0xffffff)];
        
        NSDictionary *dict = [self.listArray objectAtIndex:indexPath.row];
        [cell setWh_data:dict];
        
        if (indexPath.row > 0 && indexPath.row < self.listArray.count) {
            UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(60, 60 - g_factory.cardBorderWithd, CGRectGetWidth(self.pMementTable.frame) - 60, g_factory.cardBorderWithd)];
            [lView setBackgroundColor:g_factory.cardBorderColor];
            [cell.contentView addSubview:lView];
        }
        
        //    self.listArray = [[NSMutableArray alloc] initWithObjects:@{@"icon":@"MX_MyWallet_Alipay" ,@"name":@"支付宝"} ,@{@"icon":@"MX_MyWallet_WeiXinPay" ,@"name":@"微信"} ,@{@"icon":@"WH_BankIcon" ,@"name":@"银行卡支付"} , nil];
        if (self.checkIndex == indexPath.row) {
            [cell.wh_checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Selected2"] forState:UIControlStateNormal];
            
            NSArray *array;
            if (self.checkIndex == 0) {
                array = @[@"请输入用户姓名" ,@"请输入支付宝账号"];
            }else{
                array = @[@"请输入银行卡号" ,@"请输入银行账户名",@"请输入开户行"];
            }
            for (int i = 0;  i < array.count; i++) {
                UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(53, 60 + i*50, CGRectGetWidth(self.pMementTable.frame) - 63, 40)];
                [cardView setBackgroundColor:HEXCOLOR(0xF8F8F8)];
                [cell addSubview:cardView];
                cardView.layer.masksToBounds = YES;
                cardView.layer.cornerRadius = 5;
                
                if (i == 0) {
                    if (self.nameTextField) {
                        [self.nameTextField removeFromSuperview];
                    }
                    self.nameTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(10, 8, CGRectGetWidth(cardView.frame) - 20, 40 - 16) keyboardType:UIKeyboardTypeDefault secure:NO placeholder:[array objectAtIndex:i] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 17] color:HEXCOLOR(0x333333) delegate:self];
                    [cardView addSubview:self.nameTextField];
                    [self.nameTextField setTag:indexPath.row];
                    self.nameTextField.borderStyle = UITextBorderStyleNone;
                    self.nameTextField.returnKeyType = UIReturnKeyDone;
                    [self.nameTextField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
                }else if(i == 1){
                    if (self.codeTextField) {
                        [self.codeTextField removeFromSuperview];
                    }
                    self.codeTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(10, 8, CGRectGetWidth(cardView.frame) - 20, 40 - 16) keyboardType:(array.count>2)?UIKeyboardTypeDefault:UIKeyboardTypeNumberPad secure:NO placeholder:[array objectAtIndex:i] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 17] color:HEXCOLOR(0x333333) delegate:self];
                    [cardView addSubview:self.codeTextField];
                    [self.codeTextField setTag:indexPath.row];
                    self.codeTextField.borderStyle = UITextBorderStyleNone;
                    self.codeTextField.returnKeyType = UIReturnKeyDone;
                    [self.codeTextField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
                }else{
                    if (self.khhTextField) {
                        [self.khhTextField removeFromSuperview];
                    }
                    
                    self.khhTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(10, 8, CGRectGetWidth(cardView.frame) - 20, 40 - 16) keyboardType:UIKeyboardTypeDefault secure:NO placeholder:[array objectAtIndex:i] font:[UIFont fontWithName:@"PingFangSC-Regular" size: 17] color:HEXCOLOR(0x333333) delegate:self];
                    [cardView addSubview:self.khhTextField];
                    [self.khhTextField setTag:indexPath.row];
                    self.khhTextField.borderStyle = UITextBorderStyleNone;
                    self.khhTextField.returnKeyType = UIReturnKeyDone;
                    [self.khhTextField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
                }
            }
        }
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_CanAdd_WithdrawAccount) {
        return UITableViewAutomaticDimension;
    }
    if (self.checkIndex == indexPath.row) {
        NSDictionary *dict = [self.listArray objectAtIndex:self.checkIndex];
        if ([[dict objectForKey:@"name"] isEqualToString:@"银行卡支付"]) {
            return 40*3 + 16 + 20 + 66;
        }else{
            return 66 + 40 + 20 + 40;
        }
    }else{
        return 66;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_CanAdd_WithdrawAccount == 0) {
        self.checkIndex = indexPath.row;
        
        WH_Recharge_TableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
        for (int i = 0; i < self.listArray.count; i++) {
            if (self.checkIndex == i) {
                [selectCell.wh_checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Selected2"] forState:UIControlStateNormal];
            }else {
                [selectCell.wh_checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Default"] forState:UIControlStateNormal];
            }
        }
        [self.pMementTable  reloadData];
    }
}

- (void)textField1TextChange:(UITextField *)textField {
    NSLog(@"textField.tag:%li" ,(long)textField.tag);
    
    if (textField.tag == 10) {
//        [self.pMoneyLabel setText:@""];
//        [self.pMoneyLabel setText:(textField.text && [textField.text integerValue] > 0)?[NSString stringWithFormat:@"￥%@" ,textField.text]:@"￥0.00"];
    }
}

#pragma mark 全部提现
- (void)allWithdrawalsBtnClickMethod {
    [self.moneyTextField setText:@""];
    [self.moneyTextField setText:[NSString stringWithFormat:@"%.2f" ,g_App.myMoney]];
}

#pragma mark 确认提现
- (void)confirmWithdrawalMethod {
    self.listArray = [[NSMutableArray alloc] initWithObjects:@{@"icon":@"MX_MyWallet_Alipay" ,@"name":@"支付宝"} ,@{@"icon":@"WH_BankIcon" ,@"name":@"银行卡支付"} , nil];
    NSString *nameStr = [self.nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *codeStr = [self.codeTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *khhStr = [self.khhTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *countStr = [self.moneyTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (countStr.length == 0) {
        [GKMessageTool showText:@"请输入提现金额"];
        return;
    }
    
    NSString *minMoney = g_config.minWithdrawToAdmin?:@"0"; //最低提现额度
    if ([countStr doubleValue] < [minMoney doubleValue]) {
        [GKMessageTool showText:[NSString stringWithFormat:@"请输入至少%.2f以上金额" ,[minMoney floatValue]]];
        return;
    }
    
    NSString *purseMoney = [NSString stringWithFormat:@"%.2lf",g_App.myMoney];
    
    if ([countStr doubleValue] > [purseMoney doubleValue]) {
        [GKMessageTool showText:@"余额不足"];
        return;
    }
    
    
    if (IS_CanAdd_WithdrawAccount == 0) {//每次都输入提现账号
        
        if (nameStr.length == 0) {
            [GKMessageTool showText:(self.checkIndex == 0)?@"请输入用户名":@"请输入银行卡账户姓名"];
            return;
        }
        if (codeStr.length == 0) {
            [GKMessageTool showText:(self.checkIndex == 0)?@"请输入支付宝账号":@"请输入银行卡账号"];
            return;
        }
        if (self.checkIndex == 0) {
            //支付宝提现
            
        }else{
            //银行卡提现
            if (khhStr.length == 0) {
                [GKMessageTool showText:@"请输入开户行"];
                return;
            }
        }
    } else {//可以添加提现账号
        if (!self.selectedAccountDic) {
            [GKMessageTool showText:@"请选择提现账号"];
            return;
        }
    }
    g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
    if ([g_myself.isPayPassword boolValue]) {
//        self.isAlipay = button.tag == 1000;
        self.verVC = [WH_JXVerifyPay_WHVC alloc];
        self.verVC.type = JXVerifyTypeWithdrawal;
        self.verVC.wh_RMB = self.moneyTextField.text;
        self.verVC.delegate = self;
        self.verVC.didDismissVC = @selector(WH_dismiss_WHVerifyPayVC);
        self.verVC.didVerifyPay = @selector(WH_didVerifyPay:);
        self.verVC = [self.verVC init];
        
        [self.view addSubview:self.verVC.view];
    } else {
        WH_JXPayPassword_WHVC *payPswVC = [WH_JXPayPassword_WHVC alloc];
        payPswVC.type = JXPayTypeSetupPassword;
        payPswVC.enterType = JXEnterTypeDefault;
        payPswVC = [payPswVC init];
        [g_navigation pushViewController:payPswVC animated:YES];
    }
    
}

- (void)WH_dismiss_WHVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

//验证支付密码了
- (void)WH_didVerifyPay:(NSString *)sender {
    self.payPassword = [NSString stringWithString:sender];
    
//    NSString *accStr = [self.codeTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSString *accNameStr = [self.nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (IS_CanAdd_WithdrawAccount) {//可以添加提现账号,此处仅是contextStr修改了
        NSString *countStr = [self.moneyTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *type = @"";
        type = [NSString stringWithFormat:@"%@", self.selectedAccountDic[@"type"]];
        NSString *contextStr = @"";
        NSString *accountId = @"";
        if (type.integerValue == 1) {//支付宝
            accountId = self.selectedAccountDic[@"alipayId"];
        } else if (type.integerValue == 5) {//银行卡
            accountId = self.selectedAccountDic[@"bankId"];
        } else {
//            [GKMessageTool showText:@"暂不支持的提现方式"];
//            return;
            accountId = self.selectedAccountDic[@"otherId"];
        }
        contextStr = accountId;
        long temptime = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
        NSString *time = [NSString stringWithFormat:@"%ld",temptime];
        NSString *secret = [self getSecretWithText:self.payPassword time:time];
        [g_server userWithdrawalWithUserId:g_myself.userId amount:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[self.moneyTextField.text doubleValue]]] secret:secret context:contextStr accountType:type toView:self time:time];
    } else {
        self.listArray = [[NSMutableArray alloc] initWithObjects:@{@"icon":@"MX_MyWallet_Alipay" ,@"name":@"支付宝"} ,@{@"icon":@"WH_BankIcon" ,@"name":@"银行卡支付"} , nil];
        NSString *nameStr = [self.nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *codeStr = [self.codeTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *khhStr = [self.khhTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *countStr = [self.moneyTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *contextStr = @"";
        NSString *type = @"";
        if (self.checkIndex == 0) {
            contextStr = [NSString stringWithFormat:@"%@:%@" ,nameStr ,codeStr];
        }else{
            contextStr = [NSString stringWithFormat:@"%@:%@:%@" ,nameStr ,codeStr ,khhStr];
        }
        long temptime = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
        NSString *time = [NSString stringWithFormat:@"%ld",temptime];
        NSString *secret = [self getSecretWithText:self.payPassword time:time];
        [g_server userWithdrawalWithUserId:g_myself.userId amount:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[self.moneyTextField.text doubleValue]]] secret:secret context:contextStr accountType:type toView:self time:time];
    }
}

-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if ([aDownload.action isEqualToString:wh_act_userWithdrawMethodGet]) {
        //提现方式 默认第一个
        //selectedAccountDic
        NSMutableArray *accountArray = [[NSMutableArray alloc] init];
        
        NSArray *alipayMethod = [dict objectForKey:@"alipayMethod"];
        NSArray *bankCardMethod = [dict objectForKey:@"bankCardMethod"];
        NSArray *otherMethod = [dict objectForKey:@"otherMethod"];
        if ([alipayMethod isKindOfClass:[NSArray class]] && alipayMethod.count > 0) {
            for (int i = 0; i < alipayMethod.count; i++) {
                [accountArray addObject:alipayMethod[i]];
            }
        }
        if ([bankCardMethod isKindOfClass:[NSArray class]] && bankCardMethod.count > 0) {
            for (int i = 0; i < bankCardMethod.count; i++) {
                [accountArray addObject:bankCardMethod[i]];
            }
        }
        if ([otherMethod isKindOfClass:[NSArray class]] && otherMethod.count > 0) {
            for (int i = 0; i < otherMethod.count; i++) {
                [accountArray addObject:otherMethod[i]];
            }
        }
        
        if (accountArray.count > 0) {
            self.selectedAccountDic = [accountArray objectAtIndex:0];
            if (self.pMementTable) {
                [self.pMementTable reloadData];
            }else{
                [self createContentTable];
            }
            
        }
    }else{
        if ([[dict objectForKey:@"resultCode"] integerValue] == 1) {
            //        [g_App showAlert:@"请求成功,等待后台审核!"];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [self actionQuit];
            });
            
            WH_SuccessfulWithdrawal_WHViewController *swVC = [[WH_SuccessfulWithdrawal_WHViewController alloc] init];
            [g_navigation pushViewController:swVC animated:YES];
            
            return;
        }
    }
}
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    [_wait stop];
    if (![aDownload.action isEqualToString:wh_act_userWithdrawMethodGet]) {
        [g_App showAlert:@"提现失败,请重试!"];
    }
    
    return 0;
}

-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error {
    [_wait stop];
    if (![aDownload.action isEqualToString:wh_act_userWithdrawMethodGet]) {
        [g_App showAlert:@"提现失败,请重试!"];
    }
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

- (NSString *)getSecretWithText:(NSString *)text time:(NSString *)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:time];
    [str1 appendString:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[self.moneyTextField.text doubleValue]]]];
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    NSMutableString *str2 = [NSMutableString string];
    str2 = [[g_server WH_getMD5StringWithStr:text] mutableCopy];
    [str1 appendString:str2];
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    return [str1 copy];
    
}

- (UIView *)createViewWithRect:(CGRect)frame backgroundColor:(UIColor *)color {
    UIView *mView = [[UIView alloc] initWithFrame:frame];
    [mView setBackgroundColor:color];
    return mView;
}
@end
