//
//  WH_SelectNode_WHView.m
//  Tigase
//
//  Created by Apple on 2019/7/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SelectNode_WHView.h"
#import "ServerPingValueHelper.h"
@interface WH_SelectNode_WHView()
{
    NSDictionary *pingValues;
}
@end
@implementation WH_SelectNode_WHView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        pingValues = [NSMutableDictionary new];
        [self contentView];
    }
    return self;
}

- (void)contentView {
    self.wh_listTable = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_TOP + 12 + 55 + 10, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, g_config.nodesInfoList.count * 45) style:UITableViewStylePlain];
    [self.wh_listTable setDataSource:self];
    [self.wh_listTable setDelegate:self];
    [self addSubview:self.wh_listTable];
    [self.wh_listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.wh_listTable.layer.masksToBounds = YES;
    self.wh_listTable.layer.cornerRadius = g_factory.cardCornerRadius;
    self.wh_listTable.layer.borderColor = g_factory.cardBorderColor.CGColor;
    self.wh_listTable.layer.borderWidth = g_factory.cardBorderWithd;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return g_config.nodesInfoList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = [NSString stringWithFormat:@"Cell_%li" ,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        
        [cell setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
        
        NSDictionary *data = g_config.nodesInfoList[indexPath.row];
        
        [cell.textLabel setText:[data objectForKey:@"nodeName"]?:@""];
        [cell.textLabel setTextColor:HEXCOLOR(0x333333)];
        [cell.textLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
        
        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 45 - g_factory.cardBorderWithd, CGRectGetWidth(self.frame), g_factory.cardBorderWithd)];
        [lView setBackgroundColor:g_factory.globalBgColor];
        [cell addSubview:lView];
        
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.wh_SelectNodeBlock) {
        [self hide];
        self.wh_SelectNodeBlock(g_config.nodesInfoList[indexPath.row]);
    }
}

- (void)hide {
    if (self) {
        [self removeFromSuperview];
    }
}

#pragma mark ------ 获取Ping值
- (void)getPingValues {
    [ServerPingValueHelper getNodesServerPingValue:^(NSDictionary * _Nonnull pingDic) {
        pingValues = pingDic;
    }];
}

- (void)sp_getMediaData {
    NSLog(@"Check your Network");
}
@end
