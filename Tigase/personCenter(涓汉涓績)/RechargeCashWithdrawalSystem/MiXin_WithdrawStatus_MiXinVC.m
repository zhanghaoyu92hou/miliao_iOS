//
//  MiXin_WithdrawStatus_MiXinVC.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_WithdrawStatus_MiXinVC.h"
#import "MiXin_TitleWithContent_MiXinCell.h"
#import "MiXin_WithdrawStatus_MiXinCell.h"
#import "MiXin_WithdrawInfo_MiXinCell.h"

@interface MiXin_WithdrawStatus_MiXinVC () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_items;
    
    NSArray *_infos;
}

@end

@implementation MiXin_WithdrawStatus_MiXinVC

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
                   @"content":[NSString stringWithFormat:@"%ldWA币",1000],
                   },
               @{
                   @"title":@"交易费用:",
                   @"content":[NSString stringWithFormat:@"%ldWA币",5],
                   },
               @{
                   @"title":@"提币地址:",
                   @"content":@"wwww.baidu.com",
                   }];
    
    _infos = @[
               @{
                   @"title":@"订单号:",
                   @"content":@"132535626",
                   @"isShowCopy":@(YES),
                 },
                 @{
                   @"title":@"付款参考号:",
                   @"content":@"523525",
                   @"isShowCopy":@(YES),
                 },
                 @{
                    @"title":@"承兑商昵称:",
                    @"content":@"kevin",
                    @"isShowCopy":@(NO),
                  },
              ];
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
    [tableView registerClass:[MiXin_WithdrawStatus_MiXinCell class] forCellReuseIdentifier:@"MiXin_WithdrawStatus_MiXinCell"];
    [tableView registerClass:[MiXin_WithdrawInfo_MiXinCell class] forCellReuseIdentifier:@"MiXin_WithdrawInfo_MiXinCell"];
    tableView.backgroundColor = HEXCOLOR(0xF5F6FA);
}

- (void)getWithdrawInfoReq{
    [g_server paySystem_getWithdrawCoinInfoWithOrderid:_order_id toView:self];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else if (section == 1){
        return _items.count;
    } else{
        return _infos.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section != 0 ? 8 : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 82;
    } else if (indexPath.section == 1){
        return 52;
    } else {
        return 30;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        MiXin_WithdrawStatus_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_WithdrawStatus_MiXinCell"];
        NSDictionary *titleAttDic = @{NSFontAttributeName:sysFontWithSize(15),NSForegroundColorAttributeName:HEXCOLOR(0x333333)};
        NSDictionary *subAttDic = @{NSFontAttributeName:sysFontWithSize(12),NSForegroundColorAttributeName:HEXCOLOR(0x666666)};
        if (_type == MiXin_WithdrawStatusWaitForPayCoin) {
            //等待付币
            cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"请等待承兑商付币" attributes:titleAttDic];
        } else if (_type == MiXin_WithdrawStatusConfirmAcceptCoin){
            //确认手币
            NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:@"请确认收币" attributes:titleAttDic];
            [titleAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n承兑商已经付币至交易地址，请确认收币。\n未处理，24小时后，订单将自动完成。" attributes:subAttDic]];
            cell.titleLabel.attributedText = titleAtt;
        } else if(_type == MiXin_WithdrawStatusWithdrawDown){
            //已完成
            NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:@"已完成" attributes:titleAttDic];
            [titleAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n已将币划归至提币地址" attributes:subAttDic]];
            cell.titleLabel.attributedText = titleAtt;
        }
        return cell;
    } else if (indexPath.section == 1) {
        MiXin_TitleWithContent_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_TitleWithContent_MiXinCell"];
        NSDictionary *item = _items[indexPath.row];
        cell.titleLabel.text = item[@"title"];
        cell.contentLabel.text = item[@"content"];
        return cell;
    } else {
        MiXin_WithdrawInfo_MiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_WithdrawInfo_MiXinCell"];
        NSDictionary *info = _infos[indexPath.row];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@%@",info[@"title"],info[@"content"]];
        cell.copiedStr = info[@"content"];
        cell.isShowCopy = [info[@"isShowCopy"] boolValue];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
