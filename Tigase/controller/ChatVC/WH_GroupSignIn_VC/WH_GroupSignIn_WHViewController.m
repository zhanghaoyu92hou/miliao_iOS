//
//  WH_GroupSignIn_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/9/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_GroupSignIn_WHViewController.h"

#import "LDCalendarView.h"

@interface WH_GroupSignIn_WHViewController ()

@end

@implementation WH_GroupSignIn_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.title = @"群签到";
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    UIButton *_listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _listButton.frame = CGRectMake(JX_SCREEN_WIDTH-70-15, JX_SCREEN_TOP - 38, 70, 35);
    [_listButton setTitle:@"签到日历" forState:UIControlStateNormal];
    [_listButton setTitle:@"签到日历" forState:UIControlStateHighlighted];
    [_listButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    _listButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    _listButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableHeader addSubview:_listButton];
    
    if (self.topContentView) {
        [self.topContentView removeFromSuperview];
    }
    self.topContentView = [self createTopContentView];
    [self.wh_tableBody addSubview:self.topContentView];
    
    self.listTable = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.topContentView.frame), JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, JX_SCREEN_HEIGHT - CGRectGetMaxY(self.topContentView.frame)) style:UITableViewStylePlain];
    [self.listTable setDelegate:self];
    [self.listTable setDataSource:self];
    [self.listTable setBackgroundColor:self.wh_tableBody.backgroundColor];
    [self.listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_tableBody addSubview:self.listTable];
    
    [g_server requestSignInDetailsWithRoomId:self.room.roomId toView:self];
}

- (UIView *)createTopContentView {
    //WithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH,((JX_SCREEN_WIDTH)*31)/75)
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 158+106)];
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_GroupSignIn_Image"]];
    [view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
        make.centerX.equalTo(view);
    }];
    
    if (self.headImgView) {
        [self.headImgView removeFromSuperview];
    }
    self.headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 45, 45)];
    [bgView addSubview:self.headImgView];
    self.headImgView.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = (MainHeadType)?CGRectGetWidth(self.headImgView.frame)/2:g_factory.headViewCornerRadius;
    [g_server WH_getHeadImageSmallWIthUserId:g_myself.userId userName:g_myself.userNickname imageView:self.headImgView];
    
    UILabel *nickLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(self.headImgView.frame) + 10, 30, bgView.frame.size.width - CGRectGetMaxX(self.headImgView.frame) - 10, 25) text:g_myself.userNickname font:sysFontWithSize(18) textColor:HEXCOLOR(0xffffff) backgroundColor:nil];
    [bgView addSubview:nickLabel];
    
    if (self.signInNum) {
        [self.signInNum removeFromSuperview];
    }
    self.signInNum = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(self.headImgView.frame) + 10, CGRectGetMaxY(nickLabel.frame), bgView.frame.size.width - CGRectGetMaxX(self.headImgView.frame) - 10, 20) text:@"您已经签到0天" font:sysFontWithSize(13) textColor:HEXCOLOR(0xffffff) backgroundColor:nil];
    [bgView addSubview:self.signInNum];
    
    //签到
    UIView *signInView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.headImgView.frame) + 30, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 158)];
    [view addSubview:signInView];
    [signInView setBackgroundColor:HEXCOLOR(0xffffff)];
    signInView.layer.masksToBounds = YES;
    signInView.layer.cornerRadius = g_factory.cardCornerRadius;
    signInView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    signInView.layer.borderWidth = g_factory.cardBorderWithd;
    
    if (self.signInReminder) {
        [self.signInReminder removeFromSuperview];
    }
    self.signInReminder = [UIFactory WH_create_WHLabelWith:CGRectMake(0, 25, CGRectGetWidth(signInView.frame), 23) text:@"今天还没有签到哟～" font:sysFontWithSize(16) textColor:HEXCOLOR(0x333333) backgroundColor:signInView.backgroundColor];
    [signInView addSubview:self.signInReminder];
    [self.signInReminder setTextAlignment:NSTextAlignmentCenter];
    
    if (self.signInButton) {
        [self.signInButton removeFromSuperview];
    }
    self.signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signInView addSubview:self.signInButton];
    [self.signInButton setFrame:CGRectMake(25, CGRectGetMaxY(self.signInReminder.frame) + 13, CGRectGetWidth(signInView.frame) - 50, 44)];
    [self.signInButton setBackgroundColor:HEXCOLOR(0x0093FF)];
    [self.signInButton setTitle:@"立即签到" forState:UIControlStateNormal];
    [self.signInButton setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [self.signInButton.titleLabel setFont:sysFontWithSize(16)];
    self.signInButton.layer.masksToBounds = YES;
    self.signInButton.layer.cornerRadius = 22;
    [self.signInButton addTarget:self action:@selector(signInMethod) forControlEvents:UIControlEventTouchUpInside];
    
    self.hadSignInView = [[UIView alloc] initWithFrame:self.signInButton.frame];
    [self.hadSignInView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]];
    self.hadSignInView.layer.cornerRadius = 22;
    self.hadSignInView.layer.masksToBounds = YES;
    [signInView addSubview:self.hadSignInView];
    [self.hadSignInView setHidden:YES];
    
    UILabel *markLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(self.signInButton.frame) + 10, CGRectGetWidth(signInView.frame), 20) text:@"联系签到可获得奖品，奖品联系客服兑换" font:sysFontWithSize(14) textColor:HEXCOLOR(0x999999) backgroundColor:signInView.backgroundColor];
    [signInView addSubview:markLabel];
    [markLabel setTextAlignment:NSTextAlignmentCenter];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
    //    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"cellIndentifier";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.backgroundColor = self.wh_tableBody.backgroundColor;
    cell.contentView.backgroundColor = self.wh_tableBody.backgroundColor;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 12, CGRectGetWidth(self.listTable.frame), 55)];
    view.backgroundColor = HEXCOLOR(0xffffff);
    view.layer.masksToBounds = YES;
    [cell addSubview:view];
    view.layer.cornerRadius = g_factory.cardCornerRadius;
    view.layer.borderColor = g_factory.cardBorderColor.CGColor;
    view.layer.borderWidth = g_factory.cardBorderWithd;
    
    //时间
    UILabel *timeLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(20, 0, 80, 55) text:@"20190902" font:sysFontWithSize(15) textColor:HEXCOLOR(0x3A404C) backgroundColor:view.backgroundColor];
    [view addSubview:timeLabel];
    //连续签到天数
    UILabel *daysLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(timeLabel.frame) + 10, 0, CGRectGetWidth(view.frame) - CGRectGetMaxX(timeLabel.frame) - 20 - 12 - 46, 55) text:@"连续签到1天" font:sysFontWithSize(15) textColor:HEXCOLOR(0x3A404C) backgroundColor:view.backgroundColor];
    [view addSubview:daysLabel];
    [daysLabel setTextAlignment:NSTextAlignmentCenter];
    //是否兑换
    UILabel *dhLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetWidth(view.frame) - 12 - 46, 0, 46, 55) text:@"已兑换" font:sysFontWithSize(15) textColor:HEXCOLOR(0xEEB026) backgroundColor:view.backgroundColor];
    [view addSubview:dhLabel];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55 + 12;
}

-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    NSLog(@"dict:%@ === array1:%@" ,dict ,array1);
    if ([aDownload.action isEqualToString:act_SignInDetails]) {
        [_wait stop];
        //签到详情
        [g_server WH_getRoomHeadImageSmallWithUserId:[dict objectForKey:@"userId"]?[NSString stringWithFormat:@"%@" ,[dict objectForKey:@"userId"]]:g_myself.userId roomId:g_myself.userNickname imageView:self.headImgView];
        
        NSString *status = [dict objectForKey:@"status"];
        if ([status integerValue] == 0) {
            //未签到
            [self.signInReminder setText:@""];
            [self.signInReminder setText:@"今天还没有签到哟～"];
            
            [self.hadSignInView setHidden:YES];
        }else {
            //已签到
            [self.signInReminder setText:@""];
            [self.signInReminder setText:@"今天已签到"];
            
            [self.signInButton setTitle:@"" forState:UIControlStateNormal];
            [self.signInButton setTitle:@"已签到" forState:UIControlStateNormal];
            [self.hadSignInView setHidden:NO];
        }
        
        //self.signInNum
        NSString *serialCount = [dict objectForKey:@"serialCount"];
        [self.signInNum setText:@""];
        [self.signInNum setText:[NSString stringWithFormat:@"您已经签到%@天" ,serialCount]];
        
        [self.dataArray removeAllObjects];
        NSArray *array = [dict objectForKey:@"roomSignInGift"];
        if (array.count > 0) {
            [self.dataArray addObjectsFromArray:array];
        }
        [self.listTable reloadData];
        
    }else if ([aDownload.action isEqualToString:act_SignInRightNow]) {
        //立即签到
        [_wait stop];
        [GKMessageTool showText:@"签到成功"];
        
        [self.signInButton setTitle:@"" forState:UIControlStateNormal];
        [self.signInButton setTitle:@"已签到" forState:UIControlStateNormal];
        [self.hadSignInView setHidden:NO];
        
        [g_server requestSignInDetailsWithRoomId:self.room.roomId toView:self];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_MinXinFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
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
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        [_wait stop];
        return;
    }
    [_wait start];
}

#pragma mark 签到日历
- (void)listButtonAction {
    NSLog(@"roomId:%@" ,self.room.roomId);
    LDCalendarView *calendarView = [[LDCalendarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) roomId:self.room.roomId];
    
    [self.wh_tableBody addSubview:calendarView];
    
    [calendarView show];
}

#pragma mark 立即签到
- (void)signInMethod {
    [g_server requestSignInRightNowWithRoomId:self.room.roomId nickName:g_myself.userNickname toView:self];
}

@end
