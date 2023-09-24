//
//  WH_JXSelector_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2017/8/26.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXSelector_WHVC.h"

@interface WH_JXSelector_WHVC ()

@end

@implementation WH_JXSelector_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
//    _table.backgroundColor = g_factory.globalBgColor;
//    _table.frame = CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, JX_SCREEN_HEIGHT - JX_SCREEN_TOP);
    [self createHeadAndFoot];
//    self.isShowFooterPull = NO;
//    self.isShowHeaderPull = NO;
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    self.WH_tableView = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, JX_SCREEN_HEIGHT - JX_SCREEN_TOP) style:UITableViewStylePlain];
    [self.wh_tableBody addSubview:self.WH_tableView];
    [self.WH_tableView setBackgroundColor:g_factory.globalBgColor];
    [self.WH_tableView setDelegate:self];
    [self.WH_tableView setDataSource:self];
    [self.WH_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    //保存按钮
    UIButton *resaveBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 45, JX_SCREEN_TOP - 36, 45, 28)];
    [resaveBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
//    resaveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [resaveBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    resaveBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    resaveBtn.custom_acceptEventInterval = 1.0f;
    [resaveBtn addTarget:self action:@selector(WH_confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    //resaveBtn.backgroundColor = [UIColor redColor];
    resaveBtn.titleLabel.textAlignment = NSTextAlignmentRight;
//    [resaveBtn sizeToFit];
    [self.wh_tableHeader addSubview:resaveBtn];
    resaveBtn.layer.masksToBounds = YES;
    resaveBtn.layer.cornerRadius = 14;
    //    [resaveBtn release];
    
    
//    [self.wh_tableHeader addConstraints:@[
//                                       [NSLayoutConstraint constraintWithItem:resaveBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.wh_tableHeader attribute:NSLayoutAttributeTop multiplier:1.0 constant:JX_SCREEN_TOP - 38],
//                                       [NSLayoutConstraint constraintWithItem:resaveBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.wh_tableHeader attribute:NSLayoutAttributeRight multiplier:1.0 constant:- 10]]];
}

- (void) WH_confirmBtnAction {
    if ([self.wh_selectorDelegate respondsToSelector:@selector(selector:selectorAction:)]) {
        [self.wh_selectorDelegate selector:self selectorAction:self.WH_selectIndex];
    }
    
    if(self.wh_delegate != nil && [self.wh_delegate respondsToSelector:self.wh_didSelected])
        [self.wh_delegate performSelectorOnMainThread:self.wh_didSelected withObject:self waitUntilDone:NO];
    
    [self actionQuit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.WH_array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"SelectorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = sysFontWithSize(16);
        
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, cell.contentView.frame.size.height - 0.5, JX_SCREEN_WIDTH - 15, 0.5)];
//        line.backgroundColor = HEXCOLOR(0xf0f0f0);
//        [cell.contentView addSubview:line];
        
        UIImageView *selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 27, (55 - 15)/2, 15, 15)];
        selectImage.tag = 1000;
//        selectImage.center = CGPointMake(selectImage.center.x, cell.contentView.frame.size.height / 2);
        selectImage.image = [UIImage imageNamed:@"newicon_duihao"];
        [cell.contentView addSubview:selectImage];
    }
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = g_factory.cardCornerRadius;
    cell.layer.borderWidth = g_factory.cardBorderWithd;
    cell.layer.borderColor = g_factory.cardBorderColor.CGColor;
    
    
    cell.textLabel.text = self.WH_array[indexPath.section];
    [cell.textLabel setTextColor:HEXCOLOR(0x3A404C)];
    [cell.textLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    
    UIView *view = [cell.contentView viewWithTag:1000];
    
    if (self.WH_selectIndex == indexPath.section) {
        view.hidden = NO;
    }else {
        view.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.WH_selectIndex = indexPath.section;
    [self.WH_tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 12)];
    [view setBackgroundColor:g_factory.globalBgColor];
    return view;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
