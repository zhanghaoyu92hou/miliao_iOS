//
//  MiXin_ConfirmWithdraw_MiXinVC.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_ConfirmWithdraw_MiXinVC.h"
#import "MiXin_TitleWithContent_MiXinCell.h"
#import "MiXin_BtnInCenter_MiXinCell.h"
#import "MiXin_WithdrawStatus_MiXinVC.h"

@interface MiXin_ConfirmWithdraw_MiXinVC () <UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_items;
}
@end

@implementation MiXin_ConfirmWithdraw_MiXinVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self commonInit];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.title = @"确认提币";
    [self createHeadAndFoot];
    
    [self setupUI];
}

- (void)commonInit{
    _items = @[@{
                   @"title":@"提现数量:",
                   @"content":[NSString stringWithFormat:@"%@WA币",_coinNum],
               },
               @{
                   @"title":@"交易费用:",
                   @"content":[NSString stringWithFormat:@"%.2fWA币",_coinNum.intValue * 0.05],
                   },
               @{
                   @"title":@"提币地址:",
                   @"content":_coinAddress,
                   }];
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
    [tableView registerClass:[MiXin_TitleWithContent_MiXinCell class] forCellReuseIdentifier:@"MiXin_TitleWithContent_MiXinCell"];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [tableView registerClass:[MiXin_BtnInCenter_MiXinCell class] forCellReuseIdentifier:@"MiXin_BtnInCenter_MiXinCell"];
    tableView.backgroundColor = HEXCOLOR(0xF5F6FA);
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 3 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 1 ? 15 : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 52;
    } else if (indexPath.section == 1){
        return 15*2+44;
    } else {
        return 158;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        MiXin_TitleWithContent_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_TitleWithContent_MiXinCell"];
        NSDictionary *item = _items[indexPath.row];
        cell.titleLabel.text = item[@"title"];
        cell.contentLabel.text = item[@"content"];
        return cell;
    } else if (indexPath.section == 1) {
        MiXin_BtnInCenter_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_BtnInCenter_MiXinCell"];
        __weak typeof(self) weakSelf = self;
        cell.onClickButton = ^(MiXin_BtnInCenter_MiXinCell * _Nonnull cell, UIButton * _Nonnull button) {
            //点击提现
            [g_server paySystem_withdrawCoinWithNums:weakSelf.coinNum address:weakSelf.coinAddress toView:self];
        };
        [cell.button setTitle:@"提现" forState:UIControlStateNormal];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"注意事项：\n确认提币后，一个工作日内，我们会将所提币划归至提币地址中；\n提币将扣除一部分交易费用，费用为提币额度的5%；即：提币100，实际划归95，5个WA币为交易费用。"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0],NSParagraphStyleAttributeName:style}];
        cell.textLabel.attributedText = string;
        cell.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark 请求成功
- (void)WH_didServerResult_WHSucces:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_portalIndexPostTb]){
        if ([dict[@"resultCode"] intValue] == 1) {
            //请求成功
            MiXin_WithdrawStatus_MiXinVC *vc = [[MiXin_WithdrawStatus_MiXinVC alloc] init];
            [g_navigation pushViewController:vc animated:YES];
        } else {
            [GKMessageTool showText:dict[@"resultMsg"]];
        }
    }
}

- (int)WH_didServerResult_WHFailed:(WH_JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_wait stop];
    return WH_show_error;
}

- (int)MiXin_didServerConnect_MiXinError:(WH_JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

@end
