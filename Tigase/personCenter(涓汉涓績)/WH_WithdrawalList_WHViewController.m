//
//  WH_WithdrawalList_WHViewController.m
//  Tigase
//
//  Created by lyj on 2019/11/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_WithdrawalList_WHViewController.h"
#import "WH_AddWithdrawalAccount_WHVC.h"
#import "WH_WithdrawThreeAccountViewController.h"

@interface WH_SelectWithdrawList_WHCell : UITableViewCell
@property (nonatomic, strong) NSDictionary  *dataDic;
@property (nonatomic, strong) UIImageView   *wh_iconImageView;
@property (nonatomic, strong) UILabel       *wh_accountLabel;
@property (nonatomic, strong) UIImageView   *wh_selectedImageView;
@end

@implementation WH_SelectWithdrawList_WHCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    UIImage *selectedImage = [UIImage imageNamed:@"newicon_duihao"];
    if (selected) {
        self.wh_selectedImageView.image = selectedImage;
    } else {
        self.wh_selectedImageView.image = [UIImage imageNamed:@""];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
                for (UIButton *btn in subView.subviews) {
                    if ([btn isKindOfClass:[UIButton class]]) {
    /*在此处可以自定义删除按钮的样式*/
                        [btn setImage:[UIImage imageNamed:@"WH_DeleteWithdrawalAccount"] forState:UIControlStateNormal];
                    }
                }
            }
        }
}

- (void)customSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(12, 10, 0, 10));
    }];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    
    //图标
    UIImageView *wh_iconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:wh_iconImageView];
    wh_iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.wh_iconImageView = wh_iconImageView;
    [wh_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(15);
        make.top.equalTo(self.contentView.mas_bottom).mas_offset(15);
        make.width.height.mas_equalTo(25);
        make.bottom.equalTo(self.contentView).mas_offset(-15);
    }];
    
    //提现到的账号
    UILabel *wh_withdrawalToAccountLabel = [[UILabel alloc] init];
    wh_withdrawalToAccountLabel.textColor = HEXCOLOR(0x3A404C);
    wh_withdrawalToAccountLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    [self.contentView addSubview:wh_withdrawalToAccountLabel];
    self.wh_accountLabel = wh_withdrawalToAccountLabel;
    [wh_withdrawalToAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wh_iconImageView.mas_right).mas_offset(10);
        make.top.bottom.equalTo(wh_iconImageView);
        make.right.equalTo(self.contentView).mas_offset(-50);
    }];
    
    //选中对号
    UIImageView *wh_selectedImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:wh_selectedImageView];
    wh_selectedImageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *selectedImage = [UIImage imageNamed:@"newicon_duihao"];
    self.wh_selectedImageView = wh_selectedImageView;
    [wh_selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).mas_offset(-15);
        make.centerY.mas_equalTo(wh_iconImageView);
        make.width.mas_equalTo(selectedImage.size.width);
        make.height.mas_equalTo(selectedImage.size.height);
    }];
    
}

- (void)loadContent {
    NSDictionary *accountDic = self.dataDic;
    NSString *type = accountDic[@"type"];
    NSString *account = @"";
    if (type.integerValue == 1) {//支付宝账号
        account = accountDic[@"alipayNumber"];
        self.wh_iconImageView.image = [UIImage imageNamed:@"WH_ALiPay"];
    } else if(type.integerValue == 5){//银行卡账号
        account = [NSString stringWithFormat:@"%@（%@）", accountDic[@"bankName"], accountDic[@"bankCardNo"]];
        self.wh_iconImageView.image = [UIImage imageNamed:@"MX_MyWallet_UnionPayPayment"];
    }else{
        account = [NSString stringWithFormat:@"%@ %@" ,accountDic[@"otherNode1"]?:@"" ,accountDic[@"otherNode2"]?:@""];
        self.wh_iconImageView.image = [UIImage imageNamed:@"threeWithdraw_icon"];
    }
    self.wh_accountLabel.text = account;
}
@end

@interface WH_WithdrawalList_WHViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSMutableArray *accountArray;
@property (nonatomic, strong) NSMutableArray *aliPayAccountArray;
@property (nonatomic, strong) NSMutableArray *bankAccountArray;
@end

@implementation WH_WithdrawalList_WHViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.accountArray = [NSMutableArray arrayWithCapacity:1];
    self.bankAccountArray = [NSMutableArray arrayWithCapacity:1];
    self.aliPayAccountArray = [NSMutableArray arrayWithCapacity:1];
    
    self.withdrawWay = [[NSMutableArray alloc] init];
    
    
    [_header removeFromSuperview];
    [_footer removeFromSuperview];
    
    if (IS_WITHDRAWTOPLATFORM) {
        //允许提现到平台
        [self requestWithdrawWay];
    }else{
        [self customView];
        [g_server WH_getWithdrawalAccountListWithParam:nil toView:self];
    }
}

- (void)requestWithdrawWay {
    [g_server userWithdrawWayWithToView:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self requestWithdrawWay];
    
    if (IS_WITHDRAWTOPLATFORM) {
        //允许提现到平台
        [self requestWithdrawWay];
    }else{
        [g_server WH_getWithdrawalAccountListWithParam:nil toView:self];
    }
}


- (void)customView {
    
    self.title = _titleName;
    [self WH_createHeadAndFoot];
    
    [_table setFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT- JX_SCREEN_TOP)];
    [_table setBackgroundColor:HEXCOLOR(0xF6F7FB)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = UITableViewAutomaticDimension;
    _table.estimatedRowHeight = 67;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self creatTableHeaderView];
    _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 34)];
}

- (void)creatTableHeaderView {
    UIView *wh_tableHeaderView = [[UIView alloc] init];
    
    if (IS_WITHDRAWTOPLATFORM) {
        NSInteger orginY = 12;
        for (int i = 0; i < self.withdrawWay.count; i++) {
            NSDictionary *wayDict = [self.withdrawWay objectAtIndex:i];
            NSString *waySort = [wayDict objectForKey:@"withdrawWaySort"];
            
            if ([[wayDict objectForKey:@"withdrawWayStatus"] intValue] == 1) {
                UIButton *wh_addAliPayButton = [wh_tableHeaderView createBtn:CGRectMake(10, orginY, JX_SCREEN_WIDTH - 20, 55) font:[UIFont fontWithName:@"PingFangSC-Medium" size:15] color:HEXCOLOR(0x0093FF) text:[NSString stringWithFormat:@"添加新的%@" ,[wayDict objectForKey:@"withdrawWayName"]?:@""] img:@"WH_AddWithdrawalAccount" target:self sel:@selector(WH_AddWithdrawalAccountAction:)];
                wh_addAliPayButton.tag = [waySort intValue];
                wh_addAliPayButton.backgroundColor = [UIColor whiteColor];
                wh_addAliPayButton.layer.cornerRadius = 10;
                wh_addAliPayButton.layer.masksToBounds = YES;
                [self setButton:wh_addAliPayButton imageTitleSpace:10];
                [wh_tableHeaderView addSubview:wh_addAliPayButton];
                
                orginY += 55 + 12;
            }
        }
        wh_tableHeaderView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, orginY );
    }else{
        wh_tableHeaderView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, (55 + 12)*2 );
        //添加支付宝
        UIButton *wh_addAliPayButton = [wh_tableHeaderView createBtn:CGRectMake(10, 12, JX_SCREEN_WIDTH - 20, 55) font:[UIFont fontWithName:@"PingFangSC-Medium" size:15] color:HEXCOLOR(0x0093FF) text:@"添加新的支付宝" img:@"WH_AddWithdrawalAccount" target:self sel:@selector(WH_AddWithdrawalAccountAction:)];
        wh_addAliPayButton.tag = 1000;
        wh_addAliPayButton.backgroundColor = [UIColor whiteColor];
        wh_addAliPayButton.layer.cornerRadius = 10;
        wh_addAliPayButton.layer.masksToBounds = YES;
        [self setButton:wh_addAliPayButton imageTitleSpace:10];
        [wh_tableHeaderView addSubview:wh_addAliPayButton];
        //添加银行卡
        UIButton *wh_addBankCardButton = [wh_tableHeaderView createBtn:CGRectMake(10, 12 + 55 + 12, JX_SCREEN_WIDTH - 20, 55) font:[UIFont fontWithName:@"PingFangSC-Medium" size:15] color:HEXCOLOR(0x0093FF) text:@"添加新的银行卡" img:@"WH_AddWithdrawalAccount" target:self sel:@selector(WH_AddWithdrawalAccountAction:)];
        wh_addBankCardButton.tag = 1000 + 1;
        wh_addBankCardButton.backgroundColor = [UIColor whiteColor];
        wh_addBankCardButton.layer.cornerRadius = 10;
        wh_addBankCardButton.layer.masksToBounds = YES;
        [self setButton:wh_addBankCardButton imageTitleSpace:10];
        [wh_tableHeaderView addSubview:wh_addBankCardButton];

    }
    
    _table.tableHeaderView = wh_tableHeaderView;
}

//设置button的图片和标题的间距
- (void)setButton:(UIButton *)button imageTitleSpace:(CGFloat)space {
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
    labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
    
    // 4. 赋值
    button.titleEdgeInsets = labelEdgeInsets;
    button.imageEdgeInsets = imageEdgeInsets;
}

- (void)WH_AddWithdrawalAccountAction:(UIButton *)button {
    if (IS_WITHDRAWTOPLATFORM) {
        if (button.tag == 1 || button.tag == 5) {
            //支付宝
            
            WH_AddWithdrawalAccount_WHVC *wh_AddWithdrawalAccountVC = [[WH_AddWithdrawalAccount_WHVC alloc] init];
            //        wh_AddWithdrawalAccountVC.withdrawAccountType = button.tag;
            if (button.tag == 1) {
                wh_AddWithdrawalAccountVC.withdrawAccountType = 0;
                wh_AddWithdrawalAccountVC.titleName = @"添加支付宝账号";
            } else {
                wh_AddWithdrawalAccountVC.withdrawAccountType = 1;
                wh_AddWithdrawalAccountVC.titleName = @"添加银行卡账号";
            }
            [g_navigation pushViewController:wh_AddWithdrawalAccountVC animated:YES];
            
        } else{
            
            for (int i = 0; i < self.withdrawWay.count; i++) {
                NSDictionary *wayDict = [self.withdrawWay objectAtIndex:i];
                NSString *waySort = [wayDict objectForKey:@"withdrawWaySort"];
                if ([waySort intValue] == button.tag) {
                    NSArray *details = [wayDict objectForKey:@"withdrawKeyDetails"];
                    //三方
                    WH_WithdrawThreeAccountViewController *threeAccountVC = [[WH_WithdrawThreeAccountViewController alloc] init];
                    threeAccountVC.withdrawSort = [NSString stringWithFormat:@"%li" ,(long)button.tag];
                    threeAccountVC.withdrawName = [wayDict objectForKey:@"withdrawWayName"]?:@"";
                    threeAccountVC.keyDetails = details;
                    [g_navigation pushViewController:threeAccountVC animated:YES];
                }
            }
        }
    }else{
        NSInteger tag = button.tag - 1000;
        WH_AddWithdrawalAccount_WHVC *wh_AddWithdrawalAccountVC = [[WH_AddWithdrawalAccount_WHVC alloc] init];
        wh_AddWithdrawalAccountVC.withdrawAccountType = tag;
        if (tag == 0) {
            wh_AddWithdrawalAccountVC.titleName = @"添加支付宝账号";
        } else {
            wh_AddWithdrawalAccountVC.titleName = @"添加银行卡账号";
        }
        [g_navigation pushViewController:wh_AddWithdrawalAccountVC animated:YES];
    }
}
#pragma mark -- 列表

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.accountArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    WH_SelectWithdrawList_WHCell *wh_listCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!wh_listCell) {
        wh_listCell = [[WH_SelectWithdrawList_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *accountDic = self.accountArray[indexPath.row];
    wh_listCell.dataDic = accountDic;
    [wh_listCell loadContent];
    if ([self isSelectedAccountDic:accountDic]) {//是选中的账号
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    return wh_listCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *accountDic = self.accountArray[indexPath.row];
    self.selectedAccountDic = accountDic;
    if (self.selectAccountBlock) {
        self.selectAccountBlock(self.selectedAccountDic);
    }
    [self actionQuit];
}
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos){
    
    // delete action
    UIContextualAction *deleteAction = [UIContextualAction
                                        contextualActionWithStyle:UIContextualActionStyleDestructive
                                        title:@"删除"
                                        handler:^(UIContextualAction * _Nonnull action,
                                                  __kindof UIView * _Nonnull sourceView,
                                                  void (^ _Nonnull completionHandler)(BOOL))
                                        {
                                            
                                            [self deleteAccountDic:indexPath];
                                            completionHandler(true);
                                        }];
    
    
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    actions.performsFirstActionWithFullSwipe = NO;
    
    return actions;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 添加一个删除的按钮
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteAccountDic:indexPath];
        
    }];
    // 设置颜色
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}

#pragma mark -- 判断是否选中的账号
- (BOOL)isSelectedAccountDic:(NSDictionary *)accountDic {
    NSString *alipayId = self.selectedAccountDic[@"alipayId"];
    NSString *bankId = self.selectedAccountDic[@"bankId"];
    NSString *otherId = self.selectedAccountDic[@"otherId"];
    NSString *cell_alipayId = accountDic[@"alipayId"];
    NSString *cell_bankId = accountDic[@"bankId"];
    NSString *cell_otherId = accountDic[@"otherId"];
    if (alipayId.length > 0 && cell_alipayId.length > 0 && [alipayId isEqualToString:cell_alipayId]) {
        return YES;
    }
    if (bankId.length > 0 && cell_bankId.length > 0 && [bankId isEqualToString:cell_bankId]) {
        return YES;
    }
    if (!IsStringNull(otherId) && !IsStringNull(cell_otherId) && [otherId isEqualToString:cell_otherId]) {
        return YES;
    }
    return NO;
}

#pragma mark -- 删除选中的账号
- (void)deleteAccountDic:(NSIndexPath *)indexPath {
    NSDictionary *accountDic = self.accountArray[indexPath.row];
    NSString *type = accountDic[@"type"];
    //删除数据接口
    if (type.integerValue == 1) {
        [g_server WH_deleteWithdrawalAccountWithAccountId:accountDic[@"alipayId"] accountType:type toView:self];
    } else if(type.integerValue == 5){
        [g_server WH_deleteWithdrawalAccountWithAccountId:accountDic[@"bankId"] accountType:type toView:self];
    }else {
        [g_server WH_deleteWithdrawalAccountWithAccountId:accountDic[@"otherId"] accountType:type toView:self];
    }
    
    // 界面做对应的操作
    if ([self isSelectedAccountDic:accountDic]) {//是选中的账号
        self.selectedAccountDic = @{};
        if (self.selectAccountBlock) {
            self.selectAccountBlock(self.selectedAccountDic);
        }
    }
    [self.accountArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)WH_scrollToPageUp {
    
}

- (void)WH_scrollToPageDown {
    [_footer endRefreshing];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    if ([aDownload.action isEqualToString:wh_act_userWithdrawMethodGet]) {
        [self.accountArray removeAllObjects];
        NSLog(@"账号列表:dict:%@ array1:%@", dict, array1);
        NSArray *alipayMethod = [dict objectForKey:@"alipayMethod"];
        NSArray *bankCardMethod = [dict objectForKey:@"bankCardMethod"];
        NSArray *otherMethod = [dict objectForKey:@"otherMethod"];
        if ([alipayMethod isKindOfClass:[NSArray class]] && alipayMethod.count > 0) {
            for (int i = 0; i < alipayMethod.count; i++) {
                [self.accountArray addObject:alipayMethod[i]];
            }
        }
        if ([bankCardMethod isKindOfClass:[NSArray class]] && bankCardMethod.count > 0) {
            for (int i = 0; i < bankCardMethod.count; i++) {
                [self.accountArray addObject:bankCardMethod[i]];
            }
        }
        if ([otherMethod isKindOfClass:[NSArray class]] && otherMethod.count > 0) {
            for (int i = 0; i < otherMethod.count; i++) {
                [self.accountArray addObject:otherMethod[i]];
            }
        }
        [_table reloadData];
    }else if ([aDownload.action isEqualToString:wh_act_withdrawWay]) {
        //提现方式
        if (self.withdrawWay) {
            [self.withdrawWay removeAllObjects];
        }
        [self.withdrawWay addObjectsFromArray:array1];
        
        [self customView];
        
        [g_server WH_getWithdrawalAccountListWithParam:nil toView:self];
    }
    
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self WH_stopLoading];
    if ([aDownload.action isEqualToString:wh_act_addEmployee]) {//添加员工
        [g_server showMsg:Localized(@"OrgaVC_AddEmployeeSuccess") delay:1.0];
    }
    return WH_hide_error;
}
#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    
    return WH_show_error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
