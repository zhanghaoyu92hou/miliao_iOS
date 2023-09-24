//
//  GKDYHomeViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYHome_WHViewController.h"
#import "WH_GKDYSearch_WHViewController.h"
#import "WH_GKDYPlayer_WHViewController.h"
#import "WH_GKDYPersonal_WHViewController.h"
#import "GKDYScrollView.h"
#import "GKDYVideoView.h"
#import "WH_recordVideo_WHViewController.h"
#import "WH_JXRecordVideo_WHVC.h"
#import "WH_JXSelectMusic_WHVC.h"
#import "UIButton+WH_Button.h"

@interface WH_GKDYHome_WHViewController()<UIScrollViewDelegate, GKViewControllerPushDelegate>

@property (nonatomic, strong) GKDYScrollView    *mainScrolView;

@property (nonatomic, strong) NSArray           *childVCs;

@property (nonatomic, strong) WH_GKDYSearch_WHViewController  *searchVC;
@property (nonatomic, strong) UIButton *exitBtn;


@end

@implementation WH_GKDYHome_WHViewController

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden    = YES;
    
    [self.view addSubview:self.mainScrolView];
    
//    self.childVCs = @[self.searchVC, self.playerVC];
    self.childVCs = @[self.wh_playerVC];
    
    CGFloat scrollW = JX_SCREEN_WIDTH;
    CGFloat scrollH = JX_SCREEN_HEIGHT;
    self.mainScrolView.frame = CGRectMake(0, 0, scrollW, scrollH);
    self.mainScrolView.contentSize = CGSizeMake(self.childVCs.count * scrollW, scrollH);
    
    [self WaHu_getServerData];
    
    [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addChildViewController:vc];
        [self.mainScrolView addSubview:vc.view];
        
        vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
    }];
    
    self.mainScrolView.contentOffset = CGPointMake(0, 0);
    
    _exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 64 + 5, 100, 100)];
    
    [_exitBtn addTarget:self action:@selector(exitVideoPlayer) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_exitBtn];
    [self.view bringSubviewToFront:_exitBtn];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 18, 31, 31)];
    imgV.image = [UIImage imageNamed:@"WH_WhiteBack_WHIcon"];
    [_exitBtn addSubview:imgV];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 64 + 30, JX_SCREEN_WIDTH, 20)];
    titleLabel.text = self.wh_titleStr;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UIButton *shotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shotBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - (30+10+25), CGRectGetMinY(titleLabel.frame), (30+10+25), 25);
    shotBtn.center = CGPointMake(shotBtn.center.x, titleLabel.center.y);
    [self.view addSubview:shotBtn];
    [shotBtn setImage:[UIImage imageNamed:@"WH_TakeAPicture_WHIcon"] forState:UIControlStateNormal];
    [shotBtn setTitle:@"拍摄" forState:UIControlStateNormal];
    shotBtn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Semibold" size: 15];
    [shotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shotBtn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextRight imageTitleSpace:8];
    [shotBtn addTarget:self action:@selector(clickShotBtn:) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 100, JX_SCREEN_TOP - 64 + 10, 100, 100)];
//
//    [addBtn addTarget:self action:@selector(addVideoAction:) forControlEvents:UIControlEventTouchUpInside];
//
//    [self.view addSubview:addBtn];
//    [self.view bringSubviewToFront:addBtn];
//    imgV = [[UIImageView alloc] initWithFrame:CGRectMake(addBtn.frame.size.width - 36, 20, 20, 20)];
//    imgV.image = [UIImage imageNamed:@"ic_add"];
//    [addBtn addSubview:imgV];
    
    [g_notify addObserver:self selector:@selector(postVideoNotification) name:@"WaHu_PostVideo_Success" object:nil];
}

- (void)postVideoNotification {
    NSLog(@"发布视频成功");
    [self WaHu_getServerData];
}

- (void)WaHu_getServerData {
    if (self.smallVideos) {
        [self.smallVideos removeAllObjects];
    }else{
        self.smallVideos = [[NSMutableArray alloc] init];
    }
    
    [g_server WH_circleMsgPureVideoPageIndex:0 lable:nil toView:self];
}

//点击拍摄按钮
- (void)clickShotBtn:(UIButton *)shotBtn{
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] <= 0) {
        [g_App showAlert:@"未检测到摄像头"];
        return;
    }
    
    WH_JXRecordVideo_WHVC *vc = [[WH_JXRecordVideo_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)exitVideoPlayer {
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
}

- (void)addVideoAction:(UIButton *)btn{
    
//    JXSelectMusicVC *vc = [[JXSelectMusicVC alloc]init];
//    [g_navigation pushViewController:vc animated:YES];
    
    WH_JXRecordVideo_WHVC *vc = [[WH_JXRecordVideo_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.mainScrolView.contentOffset.x == JX_SCREEN_WIDTH) {
        self.gk_statusBarHidden = YES;
    }else {
        self.gk_statusBarHidden = NO;
    }
    
    // 设置左滑push代理
    self.gk_pushDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.wh_playerVC.wh_videoView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 取消push代理
    self.gk_pushDelegate = nil;
    
    [self.wh_playerVC.wh_videoView pause];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.gk_statusBarHidden = NO;
    
    // 右滑开始时暂停
    if (scrollView.contentOffset.x == JX_SCREEN_WIDTH) {
        [self.wh_playerVC.wh_videoView pause];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动结束，如果是播放页则恢复播放
    if (scrollView.contentOffset.x == JX_SCREEN_WIDTH) {
        self.gk_statusBarHidden = YES;
        
        [self.wh_playerVC.wh_videoView resume];
    }
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    WH_GKDYPersonal_WHViewController *personalVC = [WH_GKDYPersonal_WHViewController new];
    personalVC.wh_uid = self.wh_playerVC.wh_videoView.wh_currentPlayView.wh_model.author.wh_user_id;
    [self.navigationController pushViewController:personalVC animated:YES];
}

#pragma mark - 懒加载
- (GKDYScrollView *)mainScrolView {
    if (!_mainScrolView) {
        _mainScrolView = [GKDYScrollView new];
        _mainScrolView.pagingEnabled = YES;
        _mainScrolView.showsHorizontalScrollIndicator = NO;
        _mainScrolView.showsVerticalScrollIndicator = NO;
        _mainScrolView.bounces = NO; // 禁止边缘滑动
        _mainScrolView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _mainScrolView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _mainScrolView;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //    [_wait hide];
    if( [aDownload.action isEqualToString:wh_act_CircleMsgPureVideo] ){
        [self.smallVideos removeAllObjects];
        for (int i = 0; i < array1.count; i++) {
            WH_GKDYVideoModel *model = [[WH_GKDYVideoModel alloc] init];
            [model WH_getDataFromDict:array1[i]];
            [self.smallVideos addObject:model];
        }
        
        [self.wh_playerVC.wh_videoView setModels:self.smallVideos index:0];
    }
}

#pragma mark - 请求失败回调
- (int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    //    [_wait hide];
    
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    //    [_wait hide];
    
    return WH_hide_error;
}

- (WH_GKDYSearch_WHViewController *)searchVC {
    if (!_searchVC) {
        _searchVC = [WH_GKDYSearch_WHViewController new];
    }
    return _searchVC;
}

- (WH_GKDYPlayer_WHViewController *)wh_playerVC {
    if (!_wh_playerVC) {
        _wh_playerVC = [WH_GKDYPlayer_WHViewController new];
    }
    _wh_playerVC.type = self.type;
    return _wh_playerVC;
}


@end
