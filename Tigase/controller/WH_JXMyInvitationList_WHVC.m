//
//  WH_JXMyInvitationList_WHVC.m
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXMyInvitationList_WHVC.h"
#import "WH_JXHaveInverted_WHCell.h"
#import "WH_JXUserInfo_WHVC.h"

@interface WH_JXMyInvitationList_WHVC ()<WH_JXHaveInverted_WHCellDelegate>
@property (nonatomic , strong) NSMutableArray *myFriendIdArr;

@property (assign, nonatomic) int friendStatus;//数据源
@end

@implementation WH_JXMyInvitationList_WHVC
- (NSMutableArray *)myFriendIdArr
{
    if (_myFriendIdArr == nil) {
        _myFriendIdArr = [NSMutableArray array];
    }
    
    return _myFriendIdArr;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    //    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    self.wh_isGotoBack = YES;
    _table.backgroundColor = THEMEBACKCOLOR;
    [self WH_createHeadAndFoot];
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = NO;
    
    self.title = @"我的邀请";
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WH_JXHaveInverted_WHCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WH_JXHaveInverted_WHCell class])];

    self.wh_isShowHeaderPull = YES;
    self.wh_isShowFooterPull = YES;
    
    //获取数据
    [self WH_getServerData];
    
    NSMutableArray *array =[[WH_JXUserObject sharedUserInstance] WH_fetchAllFriendsFromLocal];
    for (WH_JXUserObject *obj in array) {
        [self.myFriendIdArr addObject:obj.userId];
    }
    
}

#pragma mark - 数据请求
-(void)WH_getServerData{
    [_wait start];
    [g_server FindUserInviteMemberWithUserId:g_myself.userId PageIndex:_page toView:self];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXHaveInverted_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WH_JXHaveInverted_WHCell class])];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.myFriendIdArr) {
        cell.friendIdArr = self.myFriendIdArr;
    }
    
    cell.dataDic = _dataArr[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 40)];
    view.backgroundColor = HEXCOLOR(0xf5f5f5);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, view.height)];
    label.text = @"我的邀请";
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    label.textColor = HEXCOLOR(0x999999);
    [view addSubview:label];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

//服务端返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    //消费记录
    if ([aDownload.action isEqualToString:wh_act_InviteFindUserInviteMember]){
        if (dict == nil) {
            return;
        }
        if ([dict[@"pageIndex"] intValue] == 0) {
            _dataArr = [[NSMutableArray alloc]initWithArray:dict[@"pageData"]];
            //            self.dataDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
        }else if([dict[@"pageIndex"] intValue] <= [dict[@"pageCount"] intValue]){
            [_dataArr addObjectsFromArray:dict[@"pageData"]];
        }else{
            //没有更多数据
        }
        
        [self WH_getDataObjFromArr:_dataArr];
    }
    
    
}

-(void)WH_getDataObjFromArr:(NSMutableArray*)arr{
    [_table reloadData];
}


#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self WH_stopLoading];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

#pragma mark - WH_JXHaveInverted_WHCellDelegate
- (void)WH_JXHaveInverted_WHCell:(WH_JXHaveInverted_WHCell *)cell didClickAddFriendBtnAction:(UIButton *)btn AndIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSDictionary *dic = _dataArr[indexPath.row];
    NSString *userId = [NSString stringWithFormat:@"%@",dic[@"inviteUserId"]];
    
    
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = userId;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}


- (void)sp_getUsersMostLikedSuccess {
    NSLog(@"Get User Succrss");
}
@end
