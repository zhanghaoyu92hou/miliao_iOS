//
//  GKDYVideoView.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoView.h"
#import "GH_GKDYVideoPlayer.h"
#import "WH_HBShowImageControl.h"

@interface GKDYVideoView()<UIScrollViewDelegate, GKDYVideoPlayerDelegate, GKDYVideoControlViewDelegate>

@property (nonatomic, strong) UIScrollView              *scrollView;

// 创建三个控制视图，用于滑动切换
@property (nonatomic, strong) GKDYVideoControlView      *topView;   // 顶部视图
@property (nonatomic, strong) GKDYVideoControlView      *ctrView;   // 中间视图
@property (nonatomic, strong) GKDYVideoControlView      *btmView;   // 底部视图


@property (nonatomic, weak) UIViewController            *vc;
@property (nonatomic, assign) BOOL                      isPushed;

@property (nonatomic, strong) GH_GKDYVideoPlayer           *player;

// 记录播放内容
@property (nonatomic, copy) NSString                    *currentPlayId;

// 记录滑动前的播放状态
@property (nonatomic, assign) BOOL                      isPlaying_beforeScroll;

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) NSInteger page;

@end

@implementation GKDYVideoView

- (instancetype)initWithVC:(UIViewController *)vc isPushed:(BOOL)isPushed {
    if (self = [super init]) {
        self.vc = vc;
        self.isPushed = isPushed;
        self.page = 0;
        _datas = [NSMutableArray array];
        
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    }
    return self;
}

- (void)getData {
    if (self.page == 0) {
        [_datas removeAllObjects];
        [_datas addObjectsFromArray:self.wh_videos];
        [self setModels:self.wh_videos index:self.wh_index];
    }

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat controlW = CGRectGetWidth(self.scrollView.frame);
    CGFloat controlH = CGRectGetHeight(self.scrollView.frame);
    
    self.topView.frame   = CGRectMake(0, 0, controlW, controlH);
    self.ctrView.frame   = CGRectMake(0, controlH, controlW, controlH);
    self.btmView.frame   = CGRectMake(0, 2 * controlH, controlW, controlH);
}

#pragma mark - Public Methods
- (void)setModels:(NSArray *)models index:(NSInteger)index {
    [self.wh_videos removeAllObjects];
    [self.wh_videos addObjectsFromArray:models];
    
    self.wh_index = index;
    self.wh_currentPlayIndex = index;
    
    if (models.count == 0) return;
    
    if (models.count == 1) {
        [self.ctrView removeFromSuperview];
        [self.btmView removeFromSuperview];
        
        self.scrollView.contentSize = CGSizeMake(0, JX_SCREEN_HEIGHT);
        
        self.topView.wh_model = self.wh_videos.firstObject;
        // 播放第一个
        [self playVideoFrom:self.topView];
    }else if (models.count == 2) {
        [self.btmView removeFromSuperview];
        
        self.scrollView.contentSize = CGSizeMake(0, JX_SCREEN_HEIGHT * 2);
        
        self.topView.wh_model = self.wh_videos.firstObject;
        self.ctrView.wh_model = self.wh_videos.lastObject;
        
        if (index == 1) {
            self.scrollView.contentOffset = CGPointMake(0, JX_SCREEN_HEIGHT);
            // 播放中间
            [self playVideoFrom:self.ctrView];
        }else {
            
            // 播放第一个
            [self playVideoFrom:self.topView];
        }
    }else {
        if (index == 0) {   // 如果是第一个，则显示上视图，且预加载中下视图
            self.topView.wh_model = self.wh_videos[index];
            self.ctrView.wh_model = self.wh_videos[index + 1];
            self.btmView.wh_model = self.wh_videos[index + 2];
            
            // 播放第一个
            [self playVideoFrom:self.topView];
        }else if (index == models.count - 1) { // 如果是最后一个，则显示最后视图，且预加载前两个
            self.btmView.wh_model = self.wh_videos[index];
            self.ctrView.wh_model = self.wh_videos[index - 1];
            self.topView.wh_model = self.wh_videos[index - 2];
            
            // 显示最后一个
            self.scrollView.contentOffset = CGPointMake(0, JX_SCREEN_HEIGHT * 2);
            // 播放最后一个
            [self playVideoFrom:self.btmView];
        }else { // 显示中间，播放中间，预加载上下
            self.ctrView.wh_model = self.wh_videos[index];
            self.topView.wh_model = self.wh_videos[index - 1];
            self.btmView.wh_model = self.wh_videos[index + 1];
            
            // 显示中间
            self.scrollView.contentOffset = CGPointMake(0, JX_SCREEN_HEIGHT);
            // 播放中间
            [self playVideoFrom:self.ctrView];
        }
    }
}

- (void)pause {
    if (self.player.isPlaying) {
        self.isPlaying_beforeScroll = YES;
    }else {
        self.isPlaying_beforeScroll = NO;
    }
    
    [self.player pause];
}

- (void)resume {
    if (self.isPlaying_beforeScroll) {
        [self.player resume];
    }
}

- (void)destoryPlayer {
    self.scrollView.delegate = nil;
    [self.player removeVideo];
}

#pragma mark - Private Methods
- (void)playVideoFrom:(GKDYVideoControlView *)fromView {
    // 移除原来的播放
    [self.player removeVideo];
    
    // 取消原来视图的代理
    self.wh_currentPlayView.delegate = nil;
    
    // 切换播放视图
    self.currentPlayId    = fromView.wh_model.post_id;
    self.wh_currentPlayView  = fromView;
    self.wh_currentPlayIndex = [self indexOfModel:fromView.wh_model];
    // 设置新视图的代理
    self.wh_currentPlayView.delegate = self;
    
    // 重新播放
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.player playVideoWithView:fromView.wh_coverImgView url:fromView.wh_model.video_url];
    });
}

// 获取当前播放内容的索引
- (NSInteger)indexOfModel:(WH_GKDYVideoModel *)model {
    __block NSInteger index = 0;
    [self.wh_videos enumerateObjectsUsingBlock:^(WH_GKDYVideoModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.post_id isEqualToString:obj.post_id]) {
            index = idx;
        }
    }];
    return index;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 小于等于三个，不用处理
    if (self.wh_videos.count <= 3) return;
    
    // 上滑到第一个
    if (self.wh_index == 0 && scrollView.contentOffset.y <= JX_SCREEN_HEIGHT) {
        return;
    }
    // 下滑到最后一个
    if (self.wh_index == self.wh_videos.count - 1 && scrollView.contentOffset.y > JX_SCREEN_HEIGHT) {
        return;
    }
    
    // 判断是从中间视图上滑还是下滑
    if (scrollView.contentOffset.y >= 2 * JX_SCREEN_HEIGHT) {  // 上滑
        [self.player removeVideo];  // 在这里移除播放，解决闪动的bug
        if (self.wh_index == 0) {
            self.wh_index += 2;
            
            scrollView.contentOffset = CGPointMake(0, JX_SCREEN_HEIGHT);
            
            self.topView.wh_model = self.ctrView.wh_model;
            self.ctrView.wh_model = self.btmView.wh_model;
            
        }else {
            self.wh_index += 1;
            
            if (self.wh_index == self.wh_videos.count - 1) {
                self.ctrView.wh_model = self.wh_videos[self.wh_index - 1];
            }else {
                scrollView.contentOffset = CGPointMake(0, JX_SCREEN_HEIGHT);
                
                self.topView.wh_model = self.ctrView.wh_model;
                self.ctrView.wh_model = self.btmView.wh_model;
            }
        }
        if (self.wh_index < self.wh_videos.count - 1) {
            self.btmView.wh_model = self.wh_videos[self.wh_index + 1];
        }
    }else if (scrollView.contentOffset.y <= 0) { // 下滑
        [self.player removeVideo];  // 在这里移除播放，解决闪动的bug
        if (self.wh_index == 1) {
            self.topView.wh_model = self.wh_videos[self.wh_index - 1];
            self.ctrView.wh_model = self.wh_videos[self.wh_index];
            self.btmView.wh_model = self.wh_videos[self.wh_index + 1];
            self.wh_index -= 1;
        }else {
            if (self.wh_index == self.wh_videos.count - 1) {
                self.wh_index -= 2;
            }else {
                self.wh_index -= 1;
            }
            scrollView.contentOffset = CGPointMake(0, JX_SCREEN_HEIGHT);
            
            self.btmView.wh_model = self.ctrView.wh_model;
            self.ctrView.wh_model = self.topView.wh_model;
            
            if (self.wh_index > 0) {
                self.topView.wh_model = self.wh_videos[self.wh_index - 1];
            }
        }
    }
}

// 结束滚动后开始播放
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == 0) {
        if (self.currentPlayId == self.topView.wh_model.post_id) return;
        [self playVideoFrom:self.topView];
    }else if (scrollView.contentOffset.y == JX_SCREEN_HEIGHT) {
        if (self.currentPlayId == self.ctrView.wh_model.post_id) return;
        [self playVideoFrom:self.ctrView];
    }else if (scrollView.contentOffset.y == 2 * JX_SCREEN_HEIGHT) {
        if (self.currentPlayId == self.btmView.wh_model.post_id) return;
        [self playVideoFrom:self.btmView];
    }
    
    if (self.isPushed) return;
    
    // 当只剩最后两个的时候，获取新数据
    if (self.wh_currentPlayIndex == self.wh_videos.count - 2) {
//        [self.viewModel refreshNewListWithSuccess:^(NSArray * _Nonnull list) {
//            [self.videos addObjectsFromArray:list];
//        } failure:^(NSError * _Nonnull error) {
//            NSLog(@"%@", error);
//        }];
        if (self.page >= 0) {
            [g_server WH_circleMsgPureVideoPageIndex:self.page lable:[NSString stringWithFormat:@"%ld",self.type] toView:self];
        }
    }
}

#pragma mark - GKDYVideoPlayerDelegate
- (void)player:(GH_GKDYVideoPlayer *)player statusChanged:(GKDYVideoPlayerStatus)status {
    switch (status) {
        case GKDYVideoPlayerStatusUnload:   // 未加载
            
            break;
        case GKDYVideoPlayerStatusPrepared:   // 准备播放
            
            break;
        case GKDYVideoPlayerStatusLoading: {     // 加载中
            [self.wh_currentPlayView startLoading];
            [self.wh_currentPlayView hidePlayBtn];
        }
            break;
        case GKDYVideoPlayerStatusPlaying: {    // 播放中
            [self.wh_currentPlayView stopLoading];
            [self.wh_currentPlayView hidePlayBtn];
        }
            break;
        case GKDYVideoPlayerStatusPaused: {     // 暂停
            [self.wh_currentPlayView stopLoading];
            [self.wh_currentPlayView showPlayBtn];
        }
            break;
        case GKDYVideoPlayerStatusEnded:   // 停止
            
            break;
        case GKDYVideoPlayerStatusError:   // 错误
            
            break;
            
        default:
            break;
    }
}

- (void)player:(GH_GKDYVideoPlayer *)player currentTime:(float)currentTime totalTime:(float)totalTime progress:(float)progress {
    [self.wh_currentPlayView setProgress:progress];
}

#pragma mark - GKDYVideoControlViewDelegate
- (void)controlViewDidClickSelf:(GKDYVideoControlView *)controlView {
    if (self.player.isPlaying) {
        [self.player pause];
    }else {
        [self.player resume];
    }
}

- (void)controlViewDidClickIcon:(GKDYVideoControlView *)controlView {
    [GKMessageTool showText:Localized(@"JX_ClickToIcon")];
}

- (void)controlViewDidClickPriase:(GKDYVideoControlView *)controlView {
    [GKMessageTool showText:Localized(@"JX_GiveALike")];
}

- (void)controlViewDidClickComment:(GKDYVideoControlView *)controlView {
    [GKMessageTool showText:Localized(@"JX_Comment")];
}

- (void)controlViewDidClickShare:(GKDYVideoControlView *)controlView {
    [GKMessageTool showText:Localized(@"JX_small_share")];
}

#pragma mark - 懒加载
- (WH_GKDYVideoViewModel_WH *)wh_viewModel {
    if (!_wh_viewModel) {
        _wh_viewModel = [WH_GKDYVideoViewModel_WH new];
    }
    return _wh_viewModel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        [_scrollView addSubview:self.topView];
        [_scrollView addSubview:self.ctrView];
        [_scrollView addSubview:self.btmView];
        _scrollView.contentSize = CGSizeMake(0, JX_SCREEN_HEIGHT * 3);
        
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _scrollView;
}

- (GKDYVideoControlView *)topView {
    if (!_topView) {
        _topView = [GKDYVideoControlView new];
        _topView.wh_scrollView = self.scrollView;
    }
    return _topView;
}

- (GKDYVideoControlView *)ctrView {
    if (!_ctrView) {
        _ctrView = [GKDYVideoControlView new];
        _ctrView.wh_scrollView = self.scrollView;
    }
    return _ctrView;
}

- (GKDYVideoControlView *)btmView {
    if (!_btmView) {
        _btmView = [GKDYVideoControlView new];
        _btmView.wh_scrollView = self.scrollView;
    }
    return _btmView;
}

- (NSMutableArray *)wh_videos {
    if (!_wh_videos) {
        _wh_videos = [NSMutableArray new];
    }
    return _wh_videos;
}

- (GH_GKDYVideoPlayer *)player {
    if (!_player) {
        _player = [GH_GKDYVideoPlayer new];
        _player.delegate = self;
    }
    return _player;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if ([aDownload.action isEqualToString:wh_act_CircleMsgPureVideo]) {
        if(_page==0)
            [_datas removeAllObjects];
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //数据莫名为空
        if(_datas != nil){
            
            NSMutableArray * tempData = [[NSMutableArray alloc] init];
            for (int i=0; i<[array1 count]; i++) {
                NSDictionary* row = [array1 objectAtIndex:i];
                
                WH_GKDYVideoModel *model = [[WH_GKDYVideoModel alloc] init];
                [model WH_getDataFromDict:row];
                [tempData addObject:model];
                
//                WeiboData * weibo=[[WeiboData alloc]init];
//                [weibo WH_getDataFromDict:row];
//                [tempData addObject:weibo];
            }
            
            [_datas addObjectsFromArray:tempData];
            if (self.page == 0) {

//                [self setModels:_datas index:0];
//                [self setModels:self.videos index:self.index];

            }else {
                [self.wh_videos addObjectsFromArray:tempData];
            }
            if (array1.count > 0) {
                self.page ++;
            }else {
                self.page = -1;
            }
            
//            if (tempData.count > 0){
//                [_datas addObjectsFromArray:tempData];
//                [self loadWeboData:_datas complete:nil formDb:NO];
//            }else {
//                if (dict) {
//                    WeiboData *data = [[WeiboData alloc] init];
//                    [data WH_getDataFromDict:dict];
//                    [tempData addObject:data];
//                    [_datas addObjectsFromArray:tempData];
//                    [self loadWeboData:_datas complete:nil formDb:NO];
//                }
//            }
            
        }
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    
}


- (void)sp_upload {
    NSLog(@"Get Info Success");
}
@end
