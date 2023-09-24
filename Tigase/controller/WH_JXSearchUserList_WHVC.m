//
//  WH_JXSearchUserList_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/4/18.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXSearchUserList_WHVC.h"
#import "WH_JXNear_WHCell.h"
#import "WH_JXUserInfo_WHVC.h"

@interface WH_JXSearchUserList_WHVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{

    WH_JXCollectionView *_collectionView;
    MJRefreshHeaderView *_refreshHeader;
    MJRefreshFooterView *_refreshFooter;
}
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic,assign)int page;
@property (nonatomic, assign) NSInteger selectNum;
@end

@implementation WH_JXSearchUserList_WHVC
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
        _page=0;
        
        [g_notify addObserver:self selector:@selector(refreshCallPhone:) name:kNearRefreshCallPhone object:nil];
    }
    return self;
}

- (void)refreshCallPhone:(NSNotification *)notif {
    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.selectNum inSection:0], nil]];
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wh_tableBody.backgroundColor = THEMEBACKCOLOR;
    [self createHeadAndFoot];
    [self customView];
    [self WH_getServerData];
}

- (void) customView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[WH_JXCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.wh_tableBody.frame.size.height)collectionViewLayout:layout];
    _collectionView.frame = self.wh_tableBody.frame;
    _collectionView.backgroundColor = THEMEBACKCOLOR;
    _collectionView.contentSize = CGSizeMake(0, self.wh_tableBody.frame.size.height+10);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[WH_JXNear_WHCell class] forCellWithReuseIdentifier:NSStringFromClass([WH_JXNear_WHCell class])];
    [self.view addSubview:_collectionView];
    _refreshHeader = [MJRefreshHeaderView header];
    _refreshFooter = [MJRefreshFooterView footer];
    [self addRefreshViewWith:_collectionView header:_refreshHeader footer:_refreshFooter];
}

//添加刷新控件
- (void)addRefreshViewWith:(UICollectionView *)collectionView header:(MJRefreshHeaderView *)header footer:(MJRefreshFooterView *)footer{
    header.scrollView = collectionView;
    footer.scrollView = collectionView;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [self WH_scrollToPageUp];
        _page = 0;
        //        [self WH_getServerData];
    };
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [self WH_scrollToPageDown];
        //        [self WH_getServerData];
    };
}
//顶部刷新获取数据
-(void)WH_scrollToPageUp{
    _page = 0;
    [self WH_getServerData];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.0];
}

-(void)WH_scrollToPageDown{
    _page++;
    [self WH_getServerData];
}

- (void)stopLoading {
    [_refreshHeader endRefreshing];
    [_refreshFooter endRefreshing];
}

-(void)WH_getServerData{
    [_wait start];
    if (_isUserSearch) {
        [g_server nearbyUser:_search nearOnly:NO lat:0 lng:0 page:_page toView:self];
    }else {
        [g_server WH_searchPublicWithKeyWorld:_keyWorld limit:20 page:_page toView:self];
    }
}

#pragma mark UICollectionView delegate
#pragma mark-----多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma mark-----多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _array.count;
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
    if (_array.count) {
        [cell doRefreshNearExpert:[_array objectAtIndex:indexPath.row]];
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
    
    self.selectNum = indexPath.row;
    NSDictionary* d;
    d = [_array objectAtIndex:indexPath.row];
//    [g_server getUser:[d objectForKey:@"userId"] toView:self];
    int fromAddType = 0;
    NSString *name = [d objectForKey:@"nickname"];
    if ([name rangeOfString:_keyWorld].location == NSNotFound) {
        fromAddType = 4;
    }else {
        fromAddType = 5;
    }
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId = [d objectForKey:@"userId"];
    vc.wh_fromAddType = fromAddType;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    d = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self stopLoading];
    
    if([aDownload.action isEqualToString:wh_act_nearbyUser] || [aDownload.action isEqualToString:wh_act_nearNewUser]||[aDownload.action isEqualToString:wh_act_PublicSearch]){
        
        if(_page == 0){
            //            [_array removeAllObjects];
            //            [_array addObjectsFromArray:array1];
            [_array removeAllObjects];
            [_array addObjectsFromArray:array1];
        }else{
            if([array1 count]>0){
                [_array addObjectsFromArray:array1];
            }
        }
        if (_array.count <= 0 && !_isUserSearch) {
            [g_App showAlert:Localized(@"JX_NoSuchServerNo.IsAvailable")];
        }
        [_collectionView reloadData];
        
    }else if([aDownload.action isEqualToString:wh_act_UserGet]){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = user;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_checkNetWorking {
    NSLog(@"Get Info Failed");
}
@end
