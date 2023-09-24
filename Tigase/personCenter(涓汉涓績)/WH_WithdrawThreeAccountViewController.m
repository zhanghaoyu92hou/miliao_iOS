//
//  WH_WithdrawThreeAccountViewController.m
//  Tigase
//
//  Created by Apple on 2020/3/19.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_WithdrawThreeAccountViewController.h"

@interface WH_WithdrawThreeAccountViewController ()

@end

@implementation WH_WithdrawThreeAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.title = [NSString stringWithFormat:@"添加%@账号" ,self.withdrawName];
    self.wh_isGotoBack = YES;
    [_header removeFromSuperview];
    [_footer removeFromSuperview];
    [self WH_createHeadAndFoot];
    
    self.wh_textFieldArray = [[NSMutableArray alloc] init];
    self.wh_titleArray = [[NSMutableArray alloc] init];
    self.wh_placeholderArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < self.keyDetails.count; i++) {
        NSDictionary *detailDict = [self.keyDetails objectAtIndex:i];
        if ([[detailDict objectForKey:@"withdrawStatus"] intValue] == 1) {
            //必填项
            [self.wh_titleArray addObject:[NSString stringWithFormat:@"*%@" ,([detailDict objectForKey:@"withdrawName"]?:@"")]];
        }else{
            [self.wh_titleArray addObject:([detailDict objectForKey:@"withdrawName"]?:@"")];
        }
        [self.wh_placeholderArray addObject:([detailDict objectForKey:@"withdrawName"]?:@"")];
    }
    
    [self createContentView];
}

- (void)createContentView {
    [_table setFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT- JX_SCREEN_TOP)];
    [_table setBackgroundColor:HEXCOLOR(0xF6F7FB)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = UITableViewAutomaticDimension;
    _table.estimatedRowHeight = 55 * (self.keyDetails.count);
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
    UIButton *wh_addAliPayButton = [footerView createBtn:CGRectMake(10, 20, JX_SCREEN_WIDTH - 20, 44) font:[UIFont fontWithName:@"PingFangSC-Medium" size:16] color:[UIColor whiteColor] text:@"绑定" img:@"" target:self sel:@selector(bindWithdrawalAccountAction)];
    wh_addAliPayButton.backgroundColor = HEXCOLOR(0x0093FF);
    wh_addAliPayButton.layer.cornerRadius = 10;
    wh_addAliPayButton.layer.masksToBounds = YES;
    [footerView addSubview:wh_addAliPayButton];
    return footerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.keyDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_%li" ,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 10, 0, 10));
    }];
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    //标题
    UILabel *wh_titleLabel = [[UILabel alloc] init];
    wh_titleLabel.textColor = HEXCOLOR(0x3A404C);
    wh_titleLabel.text = self.wh_titleArray[indexPath.row];
    wh_titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:self.wh_titleArray[indexPath.row]];
    [attriStr addAttributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x3A404C)} range:NSMakeRange(0, attriStr.length)];
    NSRange range = [self.wh_titleArray[indexPath.row] rangeOfString:@"*"];
    [attriStr addAttributes:@{NSForegroundColorAttributeName : HEXCOLOR(0xED6350)} range:range];
    wh_titleLabel.attributedText = attriStr;
    [cell.contentView addSubview:wh_titleLabel];
    [wh_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).mas_offset(20);
        make.top.equalTo(cell.contentView);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(54.5);
        
    }];
    
    NSString *text = @"";
    if (self.wh_textFieldArray.count > indexPath.row) {
        UITextField *field = [self.wh_textFieldArray objectAtIndex:indexPath.row];
        if (field) {
            text = field.text;
        }
    }
    //输入框
    UITextField *wh_textField = [cell.contentView createTF:CGRectZero font:[UIFont fontWithName:@"PingFangSC-Regular" size:15] color:HEXCOLOR(0xD1D6E0) text:text place:self.wh_placeholderArray[indexPath.row]];
    wh_textField.textColor = HEXCOLOR(0x3A404C);
    wh_textField.tag = indexPath.row;
    [cell.contentView addSubview:wh_textField];
    [wh_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).mas_offset(120);
        make.top.bottom.equalTo(wh_titleLabel);
        make.right.equalTo(cell.contentView).mas_offset(-5);
    }];
    [self.wh_textFieldArray addObject:wh_textField];
    
//    //分割线
//    UIView *wh_lineView = [[UIView alloc] init];
//    wh_lineView.backgroundColor = HEXCOLOR(0xF8F8F7);
//    [cell.contentView addSubview:wh_lineView];
//    [wh_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(wh_titleLabel.mas_bottom);
//        make.height.mas_equalTo(0.5);
//        make.left.right.equalTo(cell.contentView);
//        if (indexPath.row == self.wh_titleArray.count - 1) {
//            make.top.equalTo(cell.contentView.mas_bottom);
//        }
//    }];
    
    return cell;
}

#pragma mark 绑定账号
- (void)bindWithdrawalAccountAction {
    if (self.wh_textFieldArray.count == 0) {
        [GKMessageTool showText:@"请填写信息"];
        return;
    }
    
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *p = @{@"type":self.withdrawSort ,
                        @"otherNode1":@"" ,
                        @"otherNode2":@"" ,
                        @"otherNode3":@"" ,
                        @"otherNode4":@"" ,
                        @"otherNode5":@""
                        };
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithDictionary:p];
    
    
    
    for (int i = 0; i < self.keyDetails.count; i++) {
        NSDictionary *dict = [self.keyDetails objectAtIndex:i];
        NSString *name = [dict objectForKey:@"withdrawName"];
        NSString *status = [dict objectForKey:@"withdrawStatus"];
        
        for (int m = 0; m < self.wh_textFieldArray.count; m ++) {
            UITextField *field = [self.wh_textFieldArray objectAtIndex:m];
            if (field.tag == i) {
                if ([status intValue] == 1) {
                    //必填
                    if (IsStringNull(field.text)) {
                        [GKMessageTool showText:[NSString stringWithFormat:@"请输入%@",name]];
                        return;
                    }
                }
//                [param objectForKey:[NSString stringWithFormat:@"otherNode%li" ,(field.tag + 1)]] = field.text;
                [param setObject:field.text?:@"" forKey:[NSString stringWithFormat:@"otherNode%li" ,(field.tag + 1)]];
            }
        }
    }
    NSLog(@"========param:%@" ,param);
    [g_server WH_addWithdrawalAccountWithParam:param toView:self];
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

@end
