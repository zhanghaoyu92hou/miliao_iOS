//
//  GKDYHomeViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYHomeViewController.h"
#import "GKDYSearchViewController.h"
#import "GKDYPlayerViewController.h"
#import "GKDYPersonalViewController.h"
#import "GKDYScrollView.h"
#import "GKDYVideoView.h"
#import "MiXin_recordVideo_MiXinViewController.h"
#import "JXRecordVideoVC.h"
#import "JXSelectMusicVC.h"
#import "UIButton+WH_Button.h"

@interface GKDYHomeViewController()<UIScrollViewDelegate, GKViewControllerPushDelegate>

@property (nonatomic, strong) GKDYScrollView    *mainScrolView;

@property (nonatomic, strong) NSArray           *childVCs;

@property (nonatomic, strong) GKDYSearchViewController  *searchVC;
@property (nonatomic, strong) UIButton *exitBtn;


@end

@implementation GKDYHomeViewController

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden    = YES;
    
    [self.view addSubview:self.mainScrolView];
    
//    self.childVCs = @[self.searchVC, self.playerVC];
    self.childVCs = @[self.playerVC];
    
    CGFloat scrollW = JX_SCREEN_WIDTH;
    CGFloat scrollH = JX_SCREEN_HEIGHT;
    self.mainScrolView.frame = CGRectMake(0, 0, scrollW, scrollH);
    self.mainScrolView.contentSize = CGSizeMake(self.childVCs.count * scrollW, scrollH);
    
    [self MiXin_getServerData];
    
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
    titleLabel.text = self.titleStr;
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
    
    [g_notify addObserver:self selector:@selector(postVideoNotification) name:@"MiXin_PostVideo_Success" object:nil];
}

- (void)postVideoNotification {
    NSLog(@"发布视频成功");
    [self MiXin_getServerData];
}

- (void)MiXin_getServerData {
    if (self.smallVideos) {
        [self.smallVideos removeAllObjects];
    }else{
        self.smallVideos = [[NSMutableArray alloc] init];
    }
    
    [g_server circleMsgPureVideoPageIndex:0 lable:nil toView:self];
}

//点击拍摄按钮
- (void)clickShotBtn:(UIButton *)shotBtn{
    JXRecordVideoVC *vc = [[JXRecordVideoVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)exitVideoPlayer {
    [g_navigation MiXin_dismiss_MiXinViewController:self animated:YES];
}

- (void)addVideoAction:(UIButton *)btn{
    
//    JXSelectMusicVC *vc = [[JXSelectMusicVC alloc]init];
//    [g_navigation pushViewController:vc animated:YES];
    
    JXRecordVideoVC *vc = [[JXRecordVideoVC alloc] init];
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
    
    [self.playerVC.videoView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 取消push代理
    self.gk_pushDelegate = nil;
    
    [self.playerVC.videoView pause];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.gk_statusBarHidden = NO;
    
    // 右滑开始时暂停
    if (scrollView.contentOffset.x == JX_SCREEN_WIDTH) {
        [self.playerVC.videoView pause];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动结束，如果是播放页则恢复播放
    if (scrollView.contentOffset.x == JX_SCREEN_WIDTH) {
        self.gk_statusBarHidden = YES;
        
        [self.playerVC.videoView resume];
    }
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    GKDYPersonalViewController *personalVC = [GKDYPersonalViewController new];
    personalVC.uid = self.playerVC.videoView.currentPlayView.model.author.user_id;
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
-(void) MiXin_didServerResult_MiXinSucces:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
//    [_wait hide];
    if( [aDownload.action isEqualToString:act_CircleMsgPureVideo] ){
        [self.smallVideos removeAllObjects];
        for (int i = 0; i < array1.count; i++) {
            GKDYVideoModel *model = [[GKDYVideoModel alloc] init];
            [model MiXin_getDataFromDict:array1[i]];
            [self.smallVideos addObject:model];
        }
        
        [self.playerVC.videoView setModels:self.smallVideos index:0];
    }
}

#pragma mark - 请求失败回调
- (int) MiXin_didServerResult_MinXinFailed:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict{
//    [_wait hide];
    
    return hide_error;
}

#pragma mark - 请求出错回调
-(int) MiXin_didServerConnect_MiXinError:(MiXin_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
//    [_wait hide];
    
    return hide_error;
}

- (GKDYSearchViewController *)searchVC {
    if (!_searchVC) {
        _searchVC = [GKDYSearchViewController new];
    }
    return _searchVC;
}

- (GKDYPlayerViewController *)playerVC {
    if (!_playerVC) {
        _playerVC = [GKDYPlayerViewController new];
    }
    _playerVC.type = self.type;
    return _playerVC;
}

@end
