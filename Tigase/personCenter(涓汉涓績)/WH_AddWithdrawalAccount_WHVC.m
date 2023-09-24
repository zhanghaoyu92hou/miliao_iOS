//
//  WH_AddWithdrawalAccount_WHVC.m
//  Tigase
//
//  Created by lyj on 2019/11/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AddWithdrawalAccount_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "WH_DepartObject.h"

@interface WH_AddWithdrawAccount_WHCell : UITableViewCell
@property (nonatomic, assign) WithdrawAccountType withdrawAccountType;
@property (nonatomic, strong) NSArray           *wh_titleArray;
@property (nonatomic, strong) NSArray           *wh_placeholderArray;
@property (nonatomic, strong) NSMutableArray    *wh_textFieldArray;
@end

@implementation WH_AddWithdrawAccount_WHCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customSubviews];
    }
    return self;
}

- (void)customSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 10, 0, 10));
    }];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    
}

- (void)loadContent {
    self.wh_textFieldArray = [NSMutableArray arrayWithCapacity:1];
    if (self.withdrawAccountType == WithdrawAccountTypeAlipay) {
        self.wh_titleArray = @[@"*支付宝姓名", @"*支付宝账号"];
        self.wh_placeholderArray = @[@"名字", @"账号"];
    } else {
       self.wh_titleArray = @[@"*持卡人姓名", @"*银行卡卡号", @"*银行名称", @"支行名称", @"备注信息"];
        self.wh_placeholderArray = @[@"名字", @"银行卡号", @"银行", @"支行(非对公账户可不填)", @"备注"];
    }
    
    for (int i = 0; i < self.wh_titleArray.count; i++) {
        //标题
        UILabel *wh_titleLabel = [[UILabel alloc] init];
        wh_titleLabel.textColor = HEXCOLOR(0x3A404C);
        wh_titleLabel.text = self.wh_titleArray[i];
        wh_titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:self.wh_titleArray[i]];
        [attriStr addAttributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x3A404C)} range:NSMakeRange(0, attriStr.length)];
        NSRange range = [self.wh_titleArray[i] rangeOfString:@"*"];
        [attriStr addAttributes:@{NSForegroundColorAttributeName : HEXCOLOR(0xED6350)} range:range];
        wh_titleLabel.attributedText = attriStr;
        [self.contentView addSubview:wh_titleLabel];
        [wh_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(20);
            make.top.equalTo(self.contentView).mas_offset(55 * i);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(54.5);
            
        }];
        
        //输入框
        UITextField *wh_textField = [self.contentView createTF:CGRectZero font:[UIFont fontWithName:@"PingFangSC-Regular" size:15] color:HEXCOLOR(0xD1D6E0) text:@"" place:self.wh_placeholderArray[i]];
        wh_textField.textColor = HEXCOLOR(0x3A404C);
        [self.contentView addSubview:wh_textField];
        [wh_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(120);
            make.top.bottom.equalTo(wh_titleLabel);
            make.right.equalTo(self.contentView).mas_offset(-5);
        }];
        [self.wh_textFieldArray addObject:wh_textField];
        
        //分割线
        UIView *wh_lineView = [[UIView alloc] init];
        wh_lineView.backgroundColor = HEXCOLOR(0xF8F8F7);
        [self.contentView addSubview:wh_lineView];
        [wh_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(wh_titleLabel.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.left.right.equalTo(self.contentView);
            if (i == self.wh_titleArray.count - 1) {
                make.top.equalTo(self.contentView.mas_bottom);
            }
        }];
    }
}
@end

@interface WH_AddWithdrawalAccount_WHVC ()<UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, strong) NSMutableArray *models;
@end

@implementation WH_AddWithdrawalAccount_WHVC
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
    
    [self customView];
    [_header removeFromSuperview];
    [_footer removeFromSuperview];
    //请求该部门员工
    //[g_server WH_getEmpListWithDepartmentId:_departId toView:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //请求所有部门所有员工
    //[g_server WH_getDepartmentListPageWithPageIndex:@0 companyId:_comId toView:self];
}


- (void)customView {
    
    self.title = _titleName;
    [self WH_createHeadAndFoot];
    
    [_table setFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT- JX_SCREEN_TOP)];
    [_table setBackgroundColor:HEXCOLOR(0xF6F7FB)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = UITableViewAutomaticDimension;
    _table.estimatedRowHeight = 55 * 5;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 34)];
}

#pragma mark -- 列表
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 84;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
       footerView.backgroundColor = [UIColor clearColor];
       
    //添加支付宝
    UIButton *wh_addAliPayButton = [footerView createBtn:CGRectMake(10, 20, JX_SCREEN_WIDTH - 20, 44) font:[UIFont fontWithName:@"PingFangSC-Medium" size:16] color:[UIColor whiteColor] text:@"绑定" img:@"" target:self sel:@selector(WH_bindWithdrawalAccountAction)];
    wh_addAliPayButton.backgroundColor = HEXCOLOR(0x0093FF);
    wh_addAliPayButton.layer.cornerRadius = 10;
    wh_addAliPayButton.layer.masksToBounds = YES;
    [footerView addSubview:wh_addAliPayButton];
    return footerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    WH_AddWithdrawAccount_WHCell *wh_listCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!wh_listCell) {
        wh_listCell = [[WH_AddWithdrawAccount_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    wh_listCell.withdrawAccountType = self.withdrawAccountType;
    [wh_listCell loadContent];
    return wh_listCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}

#pragma mark -- 绑定提现账号
- (void)WH_bindWithdrawalAccountAction {
    NSLog(@"绑定账号");
    WH_AddWithdrawAccount_WHCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSArray *textFieldArray = cell.wh_textFieldArray;
    if (textFieldArray.count == 0) {
        [g_App showAlert:@"请填写信息"];
        return;
    }
    NSDictionary *param = @{};
    if (self.withdrawAccountType == WithdrawAccountTypeBankCard) {
        UITextField *textField0 = cell.wh_textFieldArray[0];
        UITextField *textField1 = cell.wh_textFieldArray[1];
        UITextField *textField2 = cell.wh_textFieldArray[2];
        UITextField *textField3 = cell.wh_textFieldArray[3];
        UITextField *textField4 = cell.wh_textFieldArray[4];
        if (textField0.text.length == 0) {
            [g_App showAlert:@"请输入姓名"];
            return;
        }
        if (textField1.text.length == 0) {
            [g_App showAlert:@"请输入银行卡号"];
            return;
        }
        if (textField2.text.length == 0) {
            [g_App showAlert:@"请输入银行名称"];
            return;
        }
        param = @{@"type":@"5", @"bankUserName":[NSString stringWithFormat:@"%@", textField0.text], @"bankCardNo":[NSString stringWithFormat:@"%@", textField1.text], @"bankName":[NSString stringWithFormat:@"%@", textField2.text], @"subBankName":[NSString stringWithFormat:@"%@", textField3.text], @"remarks":[NSString stringWithFormat:@"%@", textField4.text]};
    } else {
        UITextField *textField0 = cell.wh_textFieldArray[0];
        UITextField *textField1 = cell.wh_textFieldArray[1];
        if (textField0.text.length == 0) {
            [g_App showAlert:@"请输入姓名"];
            return;
        }
        if (textField1.text.length == 0) {
            [g_App showAlert:@"请输入账号"];
            return;
        }
        param = @{@"type":@"1", @"alipayName":[NSString stringWithFormat:@"%@", textField0.text], @"alipayNumber":[NSString stringWithFormat:@"%@", textField1.text]};
    }
    [_wait start];
    [g_server WH_addWithdrawalAccountWithParam:param toView:self];
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
    [self actionQuit];
    
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self WH_stopLoading];
    [g_server showMsg:@"绑定失败" delay:1.0];
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
