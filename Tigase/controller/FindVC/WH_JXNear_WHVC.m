//
//  WH_JXNear_WHVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXNear_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "WH_JXRoomPool.h"
#import "JXTableView.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_JXTopMenuView.h"
#import "QCheckBox.h"
#import "WH_JXConstant.h"
#import "WH_JXSearchUser_WHVC.h"
#import "WH_selectProvince_WHVC.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_SearchData.h"
//#import "WH_JX_WHCell.h"
#import "MJRefresh.h"
#import "WH_JXNear_WHCell.h"
#import "WH_JXTopSiftJobView.h"
#import "WH_JXLocMap_WHVC.h"
#import "WH_JXGooMap_WHVC.h"

#import "WH_AddFriend_WHController.h"

@interface WH_JXNear_WHVC () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WH_JXActionSheet_WHVCDelegate>
{
    WH_JXTopSiftJobView *_topSiftView; //表头筛选控件
    int _selMenu;

    BOOL _isLoading;
    BOOL _selected; //cell点击延时,防止多次快速点击
    BOOL _isNoMoreData;
    
    WH_JXCollectionView *_collectionView;
    MJRefreshHeaderView *_refreshHeader;
    MJRefreshFooterView *_refreshFooter;
    
}

@property (nonatomic, strong) NSMutableArray *wh_nearArray;
//@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, assign) NSInteger wh_selectNum;
@end

@implementation WH_JXNear_WHVC

- (id)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        
        self.wh_isFreeOnClose = YES;

        self.wh_isGotoBack = YES;
        
        _array = [[NSMutableArray alloc] init];
        _wh_nearArray = [NSMutableArray array];
//        _userArray = [NSMutableArray array];
        
        _selMenu = 1;
        _wh_page=0;
        _isLoading=0;
        
        [g_notify addObserver:self selector:@selector(searchAddUser:) name:kSeachAddUserNotification object:nil];
        [g_notify addObserver:self selector:@selector(refreshCallPhone:) name:kNearRefreshCallPhone object:nil];
        
    }
    return self;
}

- (void)refreshCallPhone:(NSNotification *)notif {
    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.wh_selectNum inSection:0], nil]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    if (!self.isSearch) {
//        [self WH_scrollToPageUp];
//    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
    [self createHeadAndFoot];
    CGRect frame = self.wh_tableBody.frame;
    if (!_wh_isSearch) {
        frame.origin.y += 40;
        
        frame.size.height -= 40;
        
        self.title = Localized(@"WaHu_JXNear_WaHuVC_NearHere");
    }else {
        self.title = Localized(@"WaHu_JXNear_WaHuVC_AddFriends");
    }
    
    self.wh_tableBody.frame = frame;
    
    [self customView];
    
    //发现
    UIButton* btn = [UIFactory WH_create_WHButtonWithImage:@"WH_Find_Blue" highlight:nil target:self selector:@selector(onSearch)];
    btn.custom_acceptEventInterval = 1.0f;
    btn.frame = CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 28 - 10 - 28, JX_SCREEN_TOP - 36, 28, 28);
    [self.wh_tableHeader addSubview:btn];
    
    //筛选
    btn = [UIFactory WH_create_WHButtonWithImage:@"WH_Filter" highlight:nil target:self selector:@selector(onScreening)];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 28, JX_SCREEN_TOP - 38, 28, 28);
    btn.custom_acceptEventInterval = 1.0f;
    [self.wh_tableHeader addSubview:btn];
    
    _wh_search = [[WH_SearchData alloc] init];
    _wh_search.minAge = 0;
    _wh_search.maxAge = 200;
    _wh_search.sex = -1;
    
    [self WH_scrollToPageUp];
    
}

- (void) customView {
    //顶部筛选控件
    _topSiftView = [[WH_JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 40)];
    _topSiftView.wh_delegate = self;
    _topSiftView.wh_isShowMoreParaBtn = NO;
    _topSiftView.wh_preferred = _selMenu;
    _topSiftView.wh_dataArray = [[NSArray alloc] initWithObjects:Localized(@"WaHu_JXNear_WaHuVC_NearPer"),Localized(@"WaHu_JXNear_WaHuVC_Map"), nil];
    //Localized(@"WaHu_JXNear_WHVC_NewPer")
    //    _topSiftView.searchForType = SearchForPos;
    [self.view addSubview:_topSiftView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[WH_JXCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.wh_tableBody.frame.size.height)collectionViewLayout:layout];
    _collectionView.frame = self.wh_tableBody.frame;
    _collectionView.backgroundColor = g_factory.globalBgColor;
    _collectionView.contentSize = CGSizeMake(0, self.wh_tableBody.frame.size.height+10);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[WH_JXNear_WHCell class] forCellWithReuseIdentifier:NSStringFromClass([WH_JXNear_WHCell class])];
    [self.view addSubview:_collectionView];
    _refreshHeader = [MJRefreshHeaderView header];
    _refreshFooter = [MJRefreshFooterView footer];
    [self addRefreshViewWith:_collectionView header:_refreshHeader footer:_refreshFooter];
}

- (void)onScreening {
    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_OnlySeeFemale"),Localized(@"JX_OnlyLookAtMen"),Localized(@"JX_NoGender")]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];

}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    [_wait start];
    if (index == 2) {
        _wh_search.sex = -1;
    }else {
        _wh_search.sex = (int)index;
    }
    [self WH_scrollToPageUp];
}


//添加刷新控件
- (void)addRefreshViewWith:(UICollectionView *)collectionView header:(MJRefreshHeaderView *)header footer:(MJRefreshFooterView *)footer{
    header.scrollView = collectionView;
    footer.scrollView = collectionView;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [self WH_scrollToPageUp];
        _wh_page = 0;
//        [self WH_getServerData];
    };
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [self WH_scrollToPageDown];
//        [self WH_getServerData];
    };
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UICollectionView delegate
#pragma mark-----多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma mark-----多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return _array.count;
    if (_selMenu == 0) {
        return _wh_nearArray.count;
    }
//    else if (_selMenu == 2) {
//        return _userArray.count;
//    }
    return 0;
}
#pragma mark-----每一个的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((JX_SCREEN_WIDTH - 30)/2, (JX_SCREEN_WIDTH - 30)/2 + 65);
}
#pragma mark-----每一个边缘留白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}
#pragma mark-----最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma mark-----最小竖间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma mark-----返回每个单元格是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma mark-----创建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    WH_JXNear_WHCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WH_JXNear_WHCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    //        cell.delegate = self;
    //        cell.didTouch = @selector(WH_on_WHHeadImage:);
    //        if (_array.count)
    //            [cell doRefreshNearExpert:[_array objectAtIndex:indexPath.row]];
    if (_selMenu == 0) {
        if (_wh_nearArray.count) {
            [cell doRefreshNearExpert:[_wh_nearArray objectAtIndex:indexPath.row]];
        }
    }
//    else if (_selMenu == 2) {
//        if (_userArray.count) {
//            [cell doRefreshNearExpert:[_userArray objectAtIndex:indexPath.row]];
//        }
//    }
    
    return cell;
    
}
#pragma mark-----点击单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    [self stopAllPlayer];
    
    if (_selected == false) {   //防多次快速点击cell
        _selected = true;
        //点击过一次之后。5秒再让cell点击可以响应
        [self performSelector:@selector(changeDidSelect) withObject:nil afterDelay:0.2];
        
        NSDictionary* d;
        if (_selMenu == 0) {
            d = [_wh_nearArray objectAtIndex:indexPath.row];
        }
        self.wh_selectNum = indexPath.row;
//        else if (_selMenu == 2) {
//            d = [_userArray objectAtIndex:indexPath.row];
//        }
//        [_array objectAtIndex:indexPath.row];
//        [g_server getUser:[d objectForKey:@"userId"] toView:self];
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_userId       = [d objectForKey:@"userId"];
        vc.isAddFriend = [d objectForKey:@"isAddFriend"];
        vc.wh_fromAddType = 6;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        d = nil;
    }
}
-(void)changeDidSelect{
    _selected = false;
}



- (void)dealloc {
//    NSLog(@"WH_JXNear_WHVC.dealloc");
//    [_search release];
//    [_array removeAllObjects];
//    [_array release];
//    [super dealloc];
}

-(void)changeToMap{
    //创建地图视图
    [self createMap];
   
}

-(void)createMap{
//    NSString *countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:kISOcountryCode];
//    if ([countryCode isEqualToString:@"CN"] || !countryCode) {
    
//        if (!_mapVC) {
//            _mapVC = [[WH_JXLocMap_WHVC alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.wh_tableBody.frame.size.height) andType:2];
//            [self.view addSubview:_mapVC.view];
//        }
//        _mapVC.view.frame = self.wh_tableBody.frame;
//        _mapVC.view.hidden = NO;
        
//    }else {
//    BOOL isShowGoo = [g_default boolForKey:kUseGoogleMap];
    BOOL isShowGoo = [g_myself.isUseGoogleMap intValue] > 0 ? YES : NO;
    if (!isShowGoo) {
        if (!_wh_mapVC) {
            _wh_mapVC = [[WH_JXLocMap_WHVC alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.wh_tableBody.frame.size.height) andType:2];
            [self.view addSubview:_wh_mapVC.view];
        }
        _wh_mapVC.search = _wh_search;
        _wh_mapVC.view.frame = self.wh_tableBody.frame;
        _wh_mapVC.view.hidden = NO;
        [_wh_mapVC getDataByCurrentLocation];
    } else {
        if (!_wh_goomapVC) {
            _wh_goomapVC = [[WH_JXGooMap_WHVC alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.wh_tableBody.frame.size.height) andType:2];
            [self.view addSubview:_wh_goomapVC.view];
        }
        _wh_goomapVC.search = _wh_search;
        _wh_goomapVC.view.frame = self.wh_tableBody.frame;
        _wh_goomapVC.view.hidden = NO;
        [_wh_goomapVC getDataByCurrentLocation];
    }
    

    
        //AppStore上线ipv6被拒,先隐藏google地图
//        [self checkAfterScroll:0];
//        [_topSiftView resetAllParaBtn];
//    }
}
-(void)WH_getServerData{
    [_wait start];
//    self.isShowFooterPull = _selMenu == 1;
    if (_selMenu == 0) {
        
//        [_refreshHeader beginRefreshing];
        //18938880001
        if ([g_myself.telephone isEqualToString:@"18938880001"]) {
            [g_server WH_nearbyNewUserWithData:_wh_search nearOnly:_wh_bNearOnly page:_wh_page toView:self];
        }else {
            [g_server nearbyUser:_wh_search nearOnly:_wh_bNearOnly lat:g_server.latitude lng:g_server.longitude page:_wh_page toView:self];
        }
    
    }else if(_selMenu == 1){
        //Map
        [_wait stop];
        [self changeToMap];
        
    }

}

//顶部刷新获取数据
-(void)WH_scrollToPageUp{
    if(_isLoading)
        return;
    _wh_page = 0;
//    _search = nil;
    _wh_bNearOnly = YES;
    [self WH_getServerData];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.0];
}

-(void)WH_scrollToPageDown{
    if(_isLoading)
        return;
    if (!_isNoMoreData) {
        _wh_page++;
    }
    [self WH_getServerData];
}

- (void)stopLoading {
    _isLoading = NO;
    [_refreshHeader endRefreshing];
    [_refreshFooter endRefreshing];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self stopLoading];
    
    
    if([aDownload.action isEqualToString:wh_act_nearbyUser] || [aDownload.action isEqualToString:wh_act_nearNewUser]){
        BOOL scrollToTop = NO;
        if (_isNoMoreData) {
            _isNoMoreData = NO;
            scrollToTop = YES;
        }
        
        if(_wh_page == 0){
//            [_array removeAllObjects];
//            [_array addObjectsFromArray:array1];
            [_wh_nearArray removeAllObjects];
            [_wh_nearArray addObjectsFromArray:array1];
        }else{
            if([array1 count]>0){
                [_wh_nearArray addObjectsFromArray:array1];
            }else{//刷新到最后没有数据，重新配置参数，加载所有
                [g_App showAlert:Localized(@"JX_NotMoreData")];
                _isNoMoreData = YES;
                _wh_bNearOnly = YES;
                _wh_search = nil;
                _wh_search = [[WH_SearchData alloc] init];
                
                _wh_search.sex = -1;
                _wh_page=0;
            }
            
        }
//        _refreshCount++;
//        [_table reloadData];
//        self.isShowFooterPull = [array1 count]>=WH_page_size;
        [_collectionView reloadData];
        if (scrollToTop && _wh_nearArray.count > 0)
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        
    }else if([aDownload.action isEqualToString:wh_act_UserGet]){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = user;
        vc.isAddFriend = user.isAddFirend;
        vc.wh_fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
//        [user release];
    }
//    else if ([aDownload.action isEqualToString:wh_act_nearNewUser]) {
//        if (_page == 0) {
////            [_array removeAllObjects];
////            [_array addObjectsFromArray:array1];
//            [_userArray removeAllObjects];
//            [_userArray addObjectsFromArray:array1];
//        }else{
//            if ([_userArray count] > 0) {
//                [_userArray addObjectsFromArray:array1];
//            }else{
//                [g_App showAlert:Localized(@"JX_NotMoreData")];
//                _isNoMoreData = YES;
//                _search = nil;
//                _search = [[searchData alloc] init];
//                _search.minAge = 0;
//                _search.maxAge = 200;
//                _search.sex = -1;
//                _page=0;
//            }
//            
//        }
//        [_collectionView reloadData];
//    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self stopLoading];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    [self stopLoading];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

//-(void)buildMenu{
//    _tb = [WH_JXTopMenuView alloc];
//    _tb.items = [NSArray arrayWithObjects:@"最新",@"最热",@"附近",nil];
//    _tb.delegate = self;
//    _tb.onClick  = @selector(actionSegment:);
//    [_tb initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 44)];
//    [_tb selectOne:0];
//    [self.wh_tableHeader addSubview:_tb];
////    [_tb release];
//}

//-(void)actionSegment:(UIButton*)sender{
//    [_array removeAllObjects];
////    _refreshCount++;
////    [_table reloadData];
//    [_collectionView reloadData];
//    [self WH_scrollToPageUp];
//}


/**
 消息列表添加好友的搜索
 */
-(void)searchAddUser:(NSNotification *)notificition{
    [g_mainVC doSelected:2];
    
    WH_SearchData * searchData = notificition.object;
    [self doSearch:searchData];

}

#pragma mark 添加好友
-(void)onSearch{
    WH_AddFriend_WHController *afVC = [[WH_AddFriend_WHController alloc] init];
    [g_navigation pushViewController:afVC animated:YES];
    
//    WH_JXSearchUser_WHVC* vc = [[WH_JXSearchUser_WHVC alloc]init];
//    vc.delegate  = self;
//    vc.didSelect = @selector(doSearch:);
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
}

-(void)doSearch:(WH_SearchData*)p{

    _wh_search = p;
    _wh_bNearOnly = NO;
    _wh_isSearch = YES;
    _wh_page = 0;
    _selMenu = 0;
    [_topSiftView WH_resetBottomLineIndex:0];
    [self checkAfterScroll:0];
    [self WH_getServerData];
}

-(void)WH_on_WHHeadImage:(UIView*)sender{
}

//筛选点击
- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
    [_topSiftView WH_resetAllParaBtn];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    if (offsetX == 0) {
        _selMenu = 0;
        if (_wh_nearArray.count <= 0) {
            if (!_wh_isSearch) {
                [self WH_scrollToPageUp];
            }
        }else {
            [_collectionView reloadData];
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
        _wh_mapVC.view.hidden = YES;
        _wh_goomapVC.view.hidden = YES;
    }else if (offsetX == 1){
        _selMenu = 1;
        [self changeToMap];
        [_topSiftView WH_resetBottomLineIndex:1];
    }
//    else if (offsetX == 2){
//        _selMenu = 2;
////        _page=0;
//        _search = nil;
//        _search = [[searchData alloc] init];
//        _search.minAge = 0;
//        _search.maxAge = 200;
//        _search.sex = -1;
//        _bNearOnly = NO;
//        
//        if (_userArray.count <= 0) {
//            [self WH_scrollToPageUp];
//        }else {
//            [_collectionView reloadData];
//            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//        }
//        
//        _mapVC.view.hidden = YES;
//        _goomapVC.view.hidden = YES;
//    }
    
}


- (void)sp_getUsersMostLiked:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
