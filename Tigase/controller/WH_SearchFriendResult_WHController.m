//
//  WH_SearchFriendResult_WHController.m
//  Tigase
//
//  Created by Apple on 2019/7/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SearchFriendResult_WHController.h"
#import "WH_JX_WHCell.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_SearchData.h"

@interface WH_SearchFriendResult_WHController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger page;

@end

@implementation WH_SearchFriendResult_WHController

- (id)init{
    if (self = [super init]) {
        _array = [NSMutableArray array];
        [self setupNavigation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:g_factory.globalBgColor];
    
    [self setupNavigation];
    [self setupUI];
    [self searchReq];
}

- (void)setupNavigation{
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = .0f;
    self.wh_isNotCreatewh_tableBody = YES;
    [self createHeadAndFoot];
    self.title = Localized(@"WaHu_JXNear_WaHuVC_AddFriends");
    self.wh_isGotoBack = YES;
}

- (void)setupUI{
    [self setupTable];
}

- (void)createEmptyView {
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
    self.emptyView = [[UIView alloc] init];
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.edges.insets(UIEdgeInsetsMake(JX_SCREEN_TOP, 0, 0, 0));
    }];
    
    UIImageView *emptyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_Empty"]];
    [self.emptyView addSubview:emptyImg];
    [emptyImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.emptyView);
    }];
    
//    UILabel *label = [[UILabel alloc] init];
//    [self.emptyView addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(emptyImg).top.offset(-20);
//        make.left.equalTo(self.emptyView);
//        make.width.equalTo(self.emptyView);
//        make.height.mas_equalTo(20);
//    }];
//    [label setText:@"未搜索到好友"];
//    [label setTextAlignment:NSTextAlignmentCenter];
//    [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]];
//    [label setTextColor:HEXCOLOR(0x969696)];
}

- (void)setupTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(JX_SCREEN_TOP, 0, 0, 0));
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = g_factory.globalBgColor;
    [_tableView registerClass:[WH_JX_WHCell class] forCellReuseIdentifier:@"WH_JX_WHCell"];
}

- (void)searchReq{
    [g_server nearbyUser:_search nearOnly:NO lat:0 lng:0 page:0 toView:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,indexPath.row];
   WH_JX_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:@"WH_JX_WHCell"];
    
    NSDictionary *data = _array[indexPath.row];
    cell.lbTitle.text = [data objectForKey:@"nickname"];
    [g_server WH_getHeadImageLargeWithUserId:[data objectForKey:@"userId"] userName:[data objectForKey:@"nickname"] imageView:cell.headImageView];

    cell.backgroundColor = [UIColor whiteColor];

    cell.isSmall = YES;
    [cell setLineDisplayOrHidden:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    self.selectNum = indexPath.row;
    NSDictionary* d;
    d = [_array objectAtIndex:indexPath.row];
    //    [g_server getUser:[d objectForKey:@"userId"] toView:self];
    int fromAddType = 0;
    NSString *name = [d objectForKey:@"nickname"];
    if ([name rangeOfString:_search.name].location == NSNotFound) {
        fromAddType = 4;
    }else {
        fromAddType = 5;
    }
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId = [d objectForKey:@"userId"];
    vc.wh_fromAddType = fromAddType;
    vc.isAddFriend = self.isAddFriend;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    d = nil;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary *)dict array:(NSArray*)array1{
    [_wait stop];
//    [self stopLoading];
    if([aDownload.action isEqualToString:wh_act_nearbyUser] || [aDownload.action isEqualToString:wh_act_nearNewUser]||[aDownload.action isEqualToString:wh_act_PublicSearch]){
        if(_page == 0){
            [_array removeAllObjects];
            [_array addObjectsFromArray:array1];
        }else{
            if([array1 count]>0){
                [_array addObjectsFromArray:array1];
            }
        }
        
        if (_array.count == 0) {
            [self createEmptyView];
            
            [_tableView setHidden:YES];
        }else{
            [self.emptyView removeFromSuperview];
            
            [_tableView reloadData];
        }
//        if (_array.count <= 0 && !_isUserSearch) {
//            [g_App showAlert:Localized(@"JX_NoSuchServerNo.IsAvailable")];
//        }
        
    }else if([aDownload.action isEqualToString:wh_act_UserGet]){
//        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
//        [user WH_getDataFromDict:dict];
//        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
//        vc.user       = user;
//        vc = [vc init];
//        [g_navigation pushViewController:vc animated:YES];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
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
    [_wait start];
}


- (void)sp_getUserFollowSuccess {
    NSLog(@"Get User Succrss");
}
@end
