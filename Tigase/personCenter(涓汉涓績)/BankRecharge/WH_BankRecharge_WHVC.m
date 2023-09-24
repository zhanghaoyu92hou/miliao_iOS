//
//  WH_BankRecharge_WHVC.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_BankRecharge_WHVC.h"
#import "WH_BankList_WHModel.h"

#import "WH_RechargeTime_WHCell.h"
#import "WH_PayCard_WHCell.h"
#import "WH_BankRechargeStep_WHHeader.h"
#import "WH_SelectBank_WHCell.h"
#import "WH_RechargeBankInfo_WHCell.h"
#import "WH_AddBankCard_WHView.h"

@interface WH_BankRecharge_WHVC () <UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_titles;
    
    UITableView *_tableView;
    
    WH_AddBankCard_WHView *_addBankView;
    
    BOOL _isReqFromInit; //获取银行卡请求是否来自初始化请求,结合_isNeedRecharge用于自动下单
    BOOL _isNeedRecharge;//标记添加银行卡后是否需要自动下单
    
    WH_RechargeTime_WHCell *_rechargeTimeCell;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cardNum;

@property (nonatomic, strong) NSMutableArray *payBanks;

@property (nonatomic, strong) NSMutableArray *banks;

@property (nonatomic, strong) WH_BankList_WHModel *selectBank;
@end

@implementation WH_BankRecharge_WHVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    
    [self createHeadAndFoot];
    
    
    self.title = @"银行卡充值";
    
    [self commonInit];
    [self setupUI];

    _isReqFromInit = YES;
    [self getBankInfoReq];
    [self getPayBankListReq];



    [g_notify addObserver:self selector:@selector(bankCardPaymentHandle:) name:kXMPPMessageBankCardTrans_WHNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self actionQuit];
}

#pragma mark 银行卡充值结果
- (void)bankCardPaymentHandle:(NSNotification *)nofication {
    NSLog(@"notification.object:%@" ,nofication.object);
    WH_JXMessageObject * msg = (WH_JXMessageObject *)nofication.object;
    NSLog(@"bank card payment:%@" ,msg.content);
    NSString *msgContent = msg.content?:@"";
    NSData *jsonData = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if ([[dic objectForKey:@"payStatus"] integerValue] == 1) {
         [g_App showAlert:@"充值成功！" delegate:self tag:1 onlyConfirm:YES];
    }
}

- (void)commonInit{
    _titles = @[@"入款姓名:",@"银行账户:",@"支行名称:"];
}

- (void)setupUI{
    [self setupTable];
}

- (void)setupTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(JX_SCREEN_TOP, 0, 0, 0));
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = g_factory.globalBgColor;
    [_tableView registerClass:[WH_RechargeTime_WHCell class] forCellReuseIdentifier:@"WH_RechargeTime_WHCell"];
    [_tableView registerClass:[WH_PayCard_WHCell class] forCellReuseIdentifier:@"WH_PayCard_WHCell"];
    [_tableView registerClass:[WH_BankRechargeStep_WHHeader class] forHeaderFooterViewReuseIdentifier:@"WH_BankRechargeStep_WHHeader"];
    [_tableView registerClass:[WH_SelectBank_WHCell class] forCellReuseIdentifier:@"WH_SelectBank_WHCell"];
    [_tableView registerClass:[WH_RechargeBankInfo_WHCell class] forCellReuseIdentifier:@"WH_RechargeBankInfo_WHCell"];
}

//获取可支付银行卡列表
- (void)getPayBankListReq{
    [g_server getPayBankListWithView:self];
}

//拉去自己添加的银行卡列表
- (void)getBankInfoReq{
    [g_server getBankInfoByUserIdReqWithToView:self];
}

//添加银行卡请求
- (void)addBankCardReqWithName:(NSString *)name cardNum:(NSString *)cardNum{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [g_server userBindBankInfoReqWithRealName:name cardNum:cardNum toView:self];
}

//充值
- (void)recharge{
    [g_server payGetOrderDetailsReqWithSerialAmount:_money?:@"" toView:self];
}

//删除银行卡
- (void)deleteBankCard:(NSString *)bankId{
    if (bankId) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [g_server deleteBankInfoByIdReqWithBankId:bankId toView:self];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 68;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 3) {
        return 171;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 2) {
        return [UIView new];
    }
    WH_BankRechargeStep_WHHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"WH_BankRechargeStep_WHHeader"];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section != 3) {
        return [UIView new];
    }
    UIView *footer = [UIView new];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [footer addSubview:titleLabel];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"充值注意："attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:143/255.0 green:156/255.0 blue:187/255.0 alpha:1.0]}];
    titleLabel.attributedText = string;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(11);
        make.top.offset(12);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = HEXCOLOR(0xFFFDEC);
    label.numberOfLines = 0;
    [footer addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.right.offset(-10);
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.height.offset(100);
    }];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:@"  ①：每次转账时请按照此页面显示的收款方为准进行转账；\n  ②：务必使用此充值方式所绑定的银行卡进行转账;\n  ③：充值金额无上限，转账成功立即到账。"attributes: @{NSFontAttributeName: sysFontWithSize(14),NSForegroundColorAttributeName: [UIColor colorWithRed:247/255.0 green:106/255.0 blue:36/255.0 alpha:1.0],NSParagraphStyleAttributeName:style}];
    label.attributedText = content;
    label.textAlignment = NSTextAlignmentLeft;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    return footer;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else if (section == 1){
        return 1+_payBanks.count;
    } else if (section == 2){
        return 1;
    } else if (section == 3){
        return 3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 119+10*2;
    } else if (indexPath.section == 1){
        return 55;
    } else if (indexPath.section == 2){
        return 55;
    } else if (indexPath.section == 3){
        return 55;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (!_rechargeTimeCell) {
            _rechargeTimeCell = [tableView dequeueReusableCellWithIdentifier:@"WH_RechargeTime_WHCell"];
            __weak typeof(self) weakSelf = self;
            _rechargeTimeCell.onTimerCutToZero = ^{
                //倒计时到零,
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf actionQuit];
                }];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此订单已过期，如果您未付款请重新下单后支付！" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:confirmAction];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            };
        }
        return _rechargeTimeCell;
    } else if (indexPath.section == 1){
        WH_PayCard_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_PayCard_WHCell"];
        NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        if (rows == 1) {
            cell.bgRoundType = WHSettingCellBgRoundTypeAll;
        } else {
            cell.bgRoundType = indexPath.row == 0 ? WHSettingCellBgRoundTypeTop : (indexPath.row == rows - 1) ? WHSettingCellBgRoundTypeBottom :  WHSettingCellBgRoundTypeNone;
        }
        if (indexPath.row == 0) {
            cell.type = WH_PayCardTypeHeader;
            cell.titleLabel.text = @"付款银行卡";
            cell.addBtnTitle = @"添加";
        } else {
            cell.type = WH_PayCardTypeList;
            NSInteger index = indexPath.row-1;
            WH_BankList_WHModel *model = index > -1 && index < _payBanks.count ? _payBanks[index] : nil;
            cell.titleLabel.text = [NSString stringWithFormat:@"%@(尾号%@)",model.bankName,model.bankNumber.length > 9 ? [model.bankNumber substringFromIndex:9] : model.bankNumber];
            cell.addBtnTitle = [NSString stringWithFormat:@"%@(已绑定)",model.bankUserName];
        }
        return cell;
    } else if (indexPath.section == 2){
        WH_SelectBank_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_SelectBank_WHCell"];
        cell.bgRoundType = WHSettingCellBgRoundTypeTop;
        cell.items = _banks;
        __weak typeof(self) weakSelf = self;
        cell.onClickItem = ^(NSInteger index) {
            weakSelf.selectBank = weakSelf.banks[index];
            [tableView reloadData];
        };
        return cell;
    } else {
        WH_RechargeBankInfo_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_RechargeBankInfo_WHCell"];
        cell.titleLabel.text = _titles[indexPath.row];
        if (_selectBank) {
            NSArray *titles = @[_selectBank.accountName?:@"",_selectBank.bankNumber?:@"",_selectBank.accountAddr?:@""];
            NSInteger index = indexPath.row;
            cell.contentlabel.text = index >= 0 && index < titles.count ? titles[index] : nil;
        } else {
            cell.contentlabel.text = nil;
        }
        cell.copiedStr = cell.contentlabel.text;
        cell.bgRoundType = indexPath.row == 2 ? WHSettingCellBgRoundTypeBottom : WHSettingCellBgRoundTypeNone;
        return cell;
    }
}


//1
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 && indexPath.row != 0;
}
//2
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
//3
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
//4
//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    NSInteger index = indexPath.row - 1;
    if (index > -1 && index < _payBanks.count) {
        WH_BankList_WHModel *bank = _payBanks[index];
        [self deleteBankCard:bank.bankId];
        //        [_payBanks removeObjectAtIndex:index];
        //        [tableView reloadData];
    }
    
    
    //删除数据，和删除动画
    //    [self.myarray removeObjectAtIndex:deleteRow];
    //    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteRow inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        //选择银行
//        if (!_banks.count) {
//            [self initReq];
//            [GKMessageTool showText:@"拉取银行列表中,请稍等"];
//            return;
//        }
//        __weak typeof(self) weakSelf = self;
//    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //添加银行卡
            [self showAddBankView];
        }
    }
}

//显示添加银行卡界面
- (void)showAddBankView{
    if (_addBankView) {
        [_addBankView removeFromSuperview];
    }
    _addBankView = [[WH_AddBankCard_WHView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    _addBankView.onClickSubmitBtn = ^(WH_AddBankCard_WHView *view,UIButton * _Nonnull submitBtn) {
        //点击提交
        [weakSelf addBankCardReqWithName:view.namePopView.inputTF.text cardNum:view.cardNumPopView.inputTF.text];
    };
    [self.view addSubview:_addBankView];
    [_addBankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_getPayMethod]){
        //获取支付银行列表
        _banks = [WH_BankList_WHModel mj_objectArrayWithKeyValuesArray:array1];
        if (_banks.count) {
            _selectBank = _banks[0];
            [_tableView reloadData];
        }
    } else if ([aDownload.action isEqualToString:act_payGetOrderDetails]){
        if ([dict[@"resultCode"] intValue] == 1) {
            //成功
            [_rechargeTimeCell startCutdown];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [self actionQuit];
            }];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"订单添加成功" message:@"订单已添加成功，请您线下及时完成打款，核对无误后，我们将为你账户添加额度。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:confirmAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [GKMessageTool showText:@"充值失败"];
        }
    } else if ([aDownload.action isEqualToString:act_userBindBandInfo]){
        //添加银行卡请求回调
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([dict[@"code"] intValue] == 1) {
            //绑卡成功
            [_addBankView removeFromSuperview];
            //重新获取银行卡列表
            [self getBankInfoReq];
        }
        NSString *prompt = [dict[@"data"] isKindOfClass:[NSDictionary class]] ? dict[@"data"][@"msg"] : [dict[@"code"] intValue] == 1 ? @"添加成功" : nil;
        if (!prompt) {
            prompt = dict[@"msg"]?:@"添加失败";
        }
        [GKMessageTool showText:prompt];
        if ([dict[@"code"] intValue] == 1 && _isNeedRecharge) {
            //添加银行卡成功,自动下单
            [self recharge];
        }
    } else if ([aDownload.action isEqualToString:act_getBankInfoByUserId]){
        //获取自己添加的银行卡请求回调
        if (dict[@"pageData"]) {
            _payBanks = [[WH_BankList_WHModel mj_objectArrayWithKeyValuesArray:dict[@"pageData"]] mutableCopy];
//            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView reloadData];
            if (_payBanks.count) {
                if (_isReqFromInit) {
                    //已经添加了银行卡,直接下单
                    [self recharge];
                }
            } else {
                if (_isReqFromInit) {
                    //没有添加银行卡,弹出提示
                    _isNeedRecharge = YES;
                    [GKMessageTool showText:@"请先添加银行卡"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        //弹出添加界面
                        [self showAddBankView];
                    });
                }
            }
        }
        _isReqFromInit = NO;
    } else if ([aDownload.action isEqualToString:act_deleteBankInfoById]){
        //删除银行卡请求回调
        //重新获取银行卡列表
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self getBankInfoReq];
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
