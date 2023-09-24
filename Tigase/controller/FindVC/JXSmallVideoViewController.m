//
//  JXSmallVideoViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/1/3.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSmallVideoViewController.h"
#import "JXSmallVideoCell.h"
#import "WH_VersionManageTool.h"
#import "WH_JXImageView.h"
#import "JXLabel.h"
#import "UIImage+WH_Tint.h"
#import "WH_GKDYVideoModel.h"
#import "WH_GKDYPlayer_WHViewController.h"
#import "WH_GKDYHome_WHViewController.h"
#import "WH_JXRecordVideo_WHVC.h"

#define CELL_HEIGHT   360    // cell高度
#define MENUE_INSET  20  // 顶部栏间隙


@interface JXSmallVideoViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, assign) JXSmallVideoType type;
@property (nonatomic, strong) UICollectionView *wh_collectionView;
@property (nonatomic, strong) UIView *wh_navigationView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) ATMHud* wait;
@property (nonatomic, assign) CGFloat wh_lastOffsetY;
@property (nonatomic, strong) MJRefreshFooterView *footer;
@property (nonatomic, strong) MJRefreshHeaderView *header;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) UILabel *wh_titleLabel;
@property (nonatomic, strong) UIScrollView *wh_headView;


@end

@implementation JXSmallVideoViewController

- (instancetype)init {
    if (self = [super init]) {
        _array = [[NSMutableArray alloc] init];
        self.type = JXSmallVideoTypeOther;
        [self WH_getServerData];
        [self addFooter];
        [self addHeader];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"CurrentController = %@",[self class]);
//    [UIApplication sharedApplication].statusBarHidden = !THE_DEVICE_HAVE_HEAD;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = NO;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self WH_setupViews];
    [self setupNavigationView];
}

- (void)WH_getServerData {
    _isLoading = YES;
    NSString *lable = [NSString stringWithFormat:@"%ld",self.type];
    if (self.type == JXSmallVideoTypeOther) {
        lable = nil;
    }
    [g_server WH_circleMsgPureVideoPageIndex:_page lable:lable toView:self];
}

- (void)WH_setupViews {
    [self.view addSubview:self.wh_collectionView];
}

- (void)setupNavigationView {
    _wh_navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
    _wh_navigationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_wh_navigationView];
    [self.view bringSubviewToFront:_wh_navigationView];

    _wh_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-40*2, 20)];
    _wh_titleLabel.text = Localized(@"JX_Recommended");
    _wh_titleLabel.backgroundColor = [UIColor clearColor];
    _wh_titleLabel.textColor = [UIColor whiteColor];
    _wh_titleLabel.textAlignment = NSTextAlignmentCenter;
    [_wh_navigationView addSubview:_wh_titleLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(NAV_INSETS, JX_SCREEN_TOP - 38, NAV_BTN_SIZE, NAV_BTN_SIZE)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [_wh_navigationView addSubview:btn];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 100, JX_SCREEN_TOP - 64 + 10, 100, 100)];
    
    [addBtn addTarget:self action:@selector(addVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_wh_navigationView addSubview:addBtn];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(addBtn.frame.size.width - 36, 20, 20, 20)];
    imgV.image = [UIImage imageNamed:@"ic_add"];
    [addBtn addSubview:imgV];
}

- (void)addVideoAction:(UIButton *)btn{
    
    WH_JXRecordVideo_WHVC *vc = [[WH_JXRecordVideo_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"------scrollView.contentOffset.y = %f = %f",offsetY,_wh_lastOffsetY);
    if (offsetY > JX_SCREEN_TOP) {
        if (offsetY < _wh_lastOffsetY) {
            [UIView animateWithDuration:.3f animations:^{
                _wh_navigationView.transform = CGAffineTransformIdentity; //复位
            } completion:^(BOOL finished) {
            }];
        }else {
            [UIView animateWithDuration:.3f animations:^{
                _wh_navigationView.transform = CGAffineTransformMakeTranslation(0, -JX_SCREEN_TOP);
            } completion:^(BOOL finished) {
            }];
        }
    }else {
        [UIView animateWithDuration:.3f animations:^{
            _wh_navigationView.transform = CGAffineTransformIdentity; //复位
        } completion:^(BOOL finished) {
        }];
    }
    _wh_lastOffsetY = offsetY;
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
    return CGSizeMake(JX_SCREEN_WIDTH/2-2, CELL_HEIGHT);
}
#pragma mark-----每一个边缘留白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}
#pragma mark-----最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
#pragma mark-----最小竖间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
#pragma mark-----返回每个单元格是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma mark-----创建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JXSmallVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JXSmallVideoCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell setupDataWithModel:_array[indexPath.row]];
    return cell;
    
}
#pragma mark-----点击单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSMutableArray * tempData = [[NSMutableArray alloc] init];
//    for (int i=0; i<[_array count]; i++) {
//        NSDictionary* row = [_array objectAtIndex:i];
//
//        GKDYVideoModel *model = [[GKDYVideoModel alloc] init];
//        [model WH_getDataFromDict:row];
//        [tempData addObject:model];
//    }
    
    WH_GKDYHome_WHViewController *homeVC = [[WH_GKDYHome_WHViewController alloc] init];
    [homeVC.wh_playerVC.wh_videoView setModels:_array index:indexPath.row];
//    homeVC.playerVC.videoView.videos = arr;
    homeVC.wh_titleStr = _wh_titleLabel.text;
    homeVC.wh_playerVC.wh_videoView.wh_index = indexPath.row;
    [g_navigation pushViewController:homeVC animated:YES];
}
#pragma mark-----头部视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    [headerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (!_wh_headView) {
        _wh_headView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, headerView.frame.size.height)];
        int height = 60;
        int width = 40;
        int X = 20;
        
        UIButton *button;
        //全部
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"WaHu_JXSearchUser_WaHuVC_All") image:@"others" index:JXSmallVideoTypeOther];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        //美食
        X += button.frame.size.width+MENUE_INSET;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"JX_Food") image:@"food" index:JXSmallVideoTypeFood];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        //景点
        X += button.frame.size.width+MENUE_INSET;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"JX_Attractions") image:@"sight" index:JXSmallVideoTypeAttractions];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        //文化
        X += button.frame.size.width+MENUE_INSET;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"JX_Culture") image:@"culture" index:JXSmallVideoTypeCulture];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        //玩乐
        X += button.frame.size.width+MENUE_INSET;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"JX_HaveFun") image:@"fun" index:JXSmallVideoTypeToHaveFun];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        //酒店
        X += button.frame.size.width+MENUE_INSET;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"JX_Hotel") image:@"hotel" index:JXSmallVideoTypeTheHotel];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        //购物
        X += button.frame.size.width+MENUE_INSET;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"JX_Shopping") image:@"shop" index:JXSmallVideoTypeShopping];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        //运动
        X += button.frame.size.width+MENUE_INSET;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, MENUE_INSET, width, height) title:Localized(@"JX_Movement") image:@"sport" index:JXSmallVideoTypeMovement];
        button.frame = CGRectMake(X, MENUE_INSET+44, width, height);
        [_wh_headView addSubview:button];
        
        _wh_headView.contentSize = CGSizeMake(CGRectGetMaxX(button.frame)+MENUE_INSET, 0);
    }
    
    [headerView addSubview:_wh_headView];

    return headerView;
    
}

- (void)updateWithButton:(UIButton *)button {
    
    self.wh_titleLabel.text = button.titleLabel.text;
    
    self.type = button.tag;
    _page = 0;
    [self WH_getServerData];
    
}

#pragma mark-----服务端返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    if( [aDownload.action isEqualToString:wh_act_CircleMsgPureVideo] ){
        [self stopLoading];
        
        if (_page == 0) {
            [_array removeAllObjects];
        }
        
        _isLoading = NO;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < array1.count; i++) {
            WH_GKDYVideoModel *model = [[WH_GKDYVideoModel alloc] init];
            [model WH_getDataFromDict:array1[i]];
            [arr addObject:model];
        }
        [_array addObjectsFromArray:arr];
        [self.wh_collectionView reloadData];
        
        _page++;
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


- (UIButton *)WH_create_WHButtonWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)image index:(NSInteger)index {
    UIButton *button = [[UIButton alloc] init];
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
    imgV.image = [UIImage imageNamed:image];
    [button addSubview:imgV];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgV.frame), frame.size.width, frame.size.height-frame.size.width)];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = sysFontWithSize(13);
    [button addSubview:label];
    
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTag:index];
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(updateWithButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)actionQuit{

    [UIApplication sharedApplication].statusBarHidden = NO;
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
//    [UIApplication sharedApplication].statusBarHidden = NO;

}

#pragma mark-----初始化 collectionView
- (UICollectionView *)wh_collectionView {
    if (!_wh_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset =UIEdgeInsetsMake(0,0, 0, 0);
        layout.headerReferenceSize =CGSizeMake(JX_SCREEN_WIDTH,100+44);//头视图大小
        _wh_collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,JX_SCREEN_HEIGHT) collectionViewLayout:layout];
        _wh_collectionView.backgroundColor = UIColor.blackColor;
        _wh_collectionView.dataSource = self;
        _wh_collectionView.delegate = self;
        _wh_collectionView.showsHorizontalScrollIndicator = NO;
        _wh_collectionView.showsVerticalScrollIndicator = YES;
        [_wh_collectionView registerClass:[JXSmallVideoCell class] forCellWithReuseIdentifier:NSStringFromClass([JXSmallVideoCell class])];
        [_wh_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    }
    return _wh_collectionView;
}

- (void)addFooter
{
    if(_footer){
        //        [_footer free];
        //        return;
    }
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = self.wh_collectionView;
    __weak JXSmallVideoViewController *weakSelf = self;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        [weakSelf WH_scrollToPageDown];
    };
    _footer.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
    };
    _footer.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                break;
                
            case MJRefreshStatePulling:
                break;
                
            case MJRefreshStateRefreshing:
                break;
            default:
                break;
        }
    };
}
- (void)addHeader
{
    _header = [MJRefreshHeaderView header];
    _header.scrollView = self.wh_collectionView;
    if (SCREENSIZE_IS_X || SCREENSIZE_IS_XS || SCREENSIZE_IS_XR || SCREENSIZE_IS_XS_MAX) {
        _header.frame = CGRectMake(_header.frame.origin.x, _header.frame.origin.y - 20, _header.frame.size.width, _header.frame.size.height);
    }
    __weak JXSmallVideoViewController *weakSelf = self;
    _header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        [weakSelf WH_scrollToPageUp];
    };
    _header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
    };
    _header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                break;
                
            case MJRefreshStatePulling:
                break;
                
            case MJRefreshStateRefreshing:
                break;
            default:
                break;
        }
    };
}

-(void)WH_scrollToPageDown{
    if(_isLoading)
        return;
    [self WH_getServerData];
}

//顶部刷新获取数据
-(void)WH_scrollToPageUp{
    if(_isLoading)
        return;
    NSLog(@"WH_scrollToPageUp");
    _page = 0;
    [self WH_getServerData];
    [self performSelector:@selector(WH_stopLoading) withObject:nil afterDelay:1.0];
}

- (void)stopLoading {
    _isLoading = NO;
    [_footer endRefreshing];
    [_header endRefreshing];
}

- (void)dealloc {
    NSLog(@"dealloc - %@",[self class]);
    
//    [UIApplication sharedApplication].statusBarHidden = NO;
    [_header free];
    [_footer free];
    _footer = nil;
    _header = nil;
}




@end
