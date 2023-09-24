//
//  WH_ForgetPayPsw_WHVC.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_ForgetPayPsw_WHVC.h"
#import "WH_AddFriend_WHCell.h"
#import "WH_BtnInCenter_WHCell.h"
#import "WH_JXPayPassword_WHVC.h"

@interface WH_ForgetPayPsw_WHVC () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray <NSArray *> *_items;
}

@property (nonatomic, copy) NSString *loginPsw;

@end

@implementation WH_ForgetPayPsw_WHVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    
    [self createHeadAndFoot];
    
    
    self.title = @"忘记支付密码";
    
    [self commonInit];
    [self setupUI];
}

- (void)commonInit{
    _items = @[
               @[@{
                     @"title":@"输入登陆密码，完成身份验证",
                     @"content":@"",
                     @"type":@(WHSettingCellTypeTitleWithContent),
                     },
                 @{
                     @"title":@"输入登陆密码",
                     @"content":@"",
                     @"type":@(WHSettingCellTypeIconWithTextField),
                     },
                 ],
               ];
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
    [_tableView registerClass:[WH_AddFriend_WHCell class] forCellReuseIdentifier:@"WH_AddFriend_WHCell"];
    [_tableView registerClass:[WH_BtnInCenter_WHCell class] forCellReuseIdentifier:@"WH_BtnInCenter_WHCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 13;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? _items[section].count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        WH_AddFriend_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_AddFriend_WHCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *item = _items[indexPath.section][indexPath.row];
        cell.type = [item[@"type"] intValue];
        NSInteger numOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        if (numOfRows == 1) {
            cell.bgRoundType = WHSettingCellBgRoundTypeAll;
        } else {
            cell.bgRoundType = indexPath.row == 0 ? WHSettingCellBgRoundTypeTop : indexPath.row == numOfRows - 1 ? WHSettingCellBgRoundTypeBottom : WHSettingCellBgRoundTypeNone;
        }
        cell.iconImageView.image = nil;
        cell.contentLabel.text = nil;
        if (indexPath.row == 0) {
            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            cell.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
            cell.titleLabel.text = item[@"title"];
        } else {
            cell.titleLabel.text = nil;
            cell.textField.placeholder = item[@"title"];
            [cell.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(16);
                make.top.bottom.offset(0);
                make.right.offset(-16);
            }];
            [cell.textField addTarget:self action:@selector(onTextFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
        }
        return cell;
    } else {
        WH_BtnInCenter_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_BtnInCenter_WHCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.button setTitle:@"下一步" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        cell.onClickButton = ^(WH_BtnInCenter_WHCell * _Nonnull cell, UIButton * _Nonnull button) {
            //点击下一步
            if (weakSelf.loginPsw.length > 0) {
                WH_JXPayPassword_WHVC * PayVC = [WH_JXPayPassword_WHVC alloc];
                PayVC.wh_oldPsw = weakSelf.loginPsw;
                PayVC.type = JXPayTypeSetupPassword;
                PayVC.enterType = JXEnterTypeForgetPayPsw;
                PayVC = [PayVC init];
                [g_navigation pushViewController:PayVC animated:YES];
            } else {
                [GKMessageTool showText:@"请先输入登录密码"];
            }
        };
        return cell;
    }
}

- (void)onTextFieldEditChanged:(UITextField *)textField{
    _loginPsw = textField.text;
}


- (void)sp_getMediaData:(NSString *)followCount {
    NSLog(@"Continue");
}
@end
