//
//  MiXin_WithdrawCoin_MiXinVC.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_WithdrawCoin_MiXinVC.h"
#import "MiXin_InputCoinNum_MiXinCell.h"
#import "MiXin_InputCoinAddress_MiXinCell.h"
#import "MiXin_BtnInCenter_MiXinCell.h"

#import "MiXin_ConfirmWithdraw_MiXinVC.h"

@interface MiXin_WithdrawCoin_MiXinVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) NSString *withdrawCount;
@property (nonatomic, copy) NSString *addressStr;

@end

@implementation MiXin_WithdrawCoin_MiXinVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.title = @"提币";
    [self createHeadAndFoot];
    
    UIButton  *orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    orderBtn.frame = CGRectMake(JX_SCREEN_WIDTH-70-15, JX_SCREEN_TOP - 38, 70, 35);
    [orderBtn setTitle:@"我的订单" forState:UIControlStateNormal];
    orderBtn.titleLabel.font = sysFontWithSize(15);
    orderBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [orderBtn addTarget:self action:@selector(myOrder:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableHeader addSubview:orderBtn];
    
    [self setupUI];
}

- (void)myOrder:(UIButton *)orderBtn{
    
}

- (void)setupUI{
    [self setupTableView];
}

- (void)setupTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(JX_SCREEN_TOP, 0, 0, 0));
    }];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MiXin_InputCoinNum_MiXinCell class] forCellReuseIdentifier:@"MiXin_InputCoinNum_MiXinCell"];
    [tableView registerClass:[MiXin_InputCoinAddress_MiXinCell class] forCellReuseIdentifier:@"MiXin_InputCoinAddress_MiXinCell"];
    [tableView registerClass:[MiXin_BtnInCenter_MiXinCell class] forCellReuseIdentifier:@"MiXin_BtnInCenter_MiXinCell"];
    tableView.backgroundColor = HEXCOLOR(0xF5F6FA);
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 1 ? 8 : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 134;
    } else if (indexPath.section == 1){
        return 208;
    } else {
        return 30*2+44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        MiXin_InputCoinNum_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_InputCoinNum_MiXinCell"];
        cell.titleLabel.text = @"提币数量";
        cell.inputTF.placeholder = @"请输入充值数量1~10000";
        cell.onInputTFEditChanged = ^(UITextField * _Nonnull inputTF) {
            weakSelf.withdrawCount = inputTF.text;
        };
        cell.inputTF.keyboardType = UIKeyboardTypeNumberPad;
        return cell;
    } else if (indexPath.section == 1) {
        MiXin_InputCoinAddress_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_InputCoinAddress_MiXinCell"];
        cell.titleLabel.text = @"##交易所提币地址:";
        cell.inputTF.placeholder = @"输入或长按粘贴地址";
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5.f;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"请输入##交易所提币地址，一个工作日内，我们会将所提币划归至该地址；提币将扣除一部分缴费费用，缴费费用为5%;即：提币100，实际划归95，5个WA币为交易费用。"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:130/255.0 green:146/255.0 blue:179/255.0 alpha:1.0],NSParagraphStyleAttributeName:style}];
        cell.promptLabel.attributedText = string;
        cell.onInpuTFEditChanged = ^(UITextField * _Nonnull inputF) {
            weakSelf.addressStr = inputF.text;
        };
        return cell;
    } else {
        MiXin_BtnInCenter_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_BtnInCenter_MiXinCell"];
        __weak typeof(self) weakSelf = self;
        cell.onClickButton = ^(MiXin_BtnInCenter_MiXinCell * _Nonnull cell, UIButton * _Nonnull button) {
            //点击提币
            MiXin_ConfirmWithdraw_MiXinVC *vc = [[MiXin_ConfirmWithdraw_MiXinVC alloc] init];
            vc.coinNum = weakSelf.withdrawCount;
            vc.coinAddress = weakSelf.addressStr;
            [g_navigation pushViewController:vc animated:YES];
        };
        [cell.button setTitle:@"提币" forState:UIControlStateNormal];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
