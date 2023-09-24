//
//  GKDYVideoView.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_GKDYVideoViewModel_WH.h"
#import "GKDYVideoControlView.h"
#import "JXSmallVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoView : UIView

@property (nonatomic, strong) WH_GKDYVideoViewModel_WH    *wh_viewModel;

@property (nonatomic, strong) GKDYVideoControlView      *wh_currentPlayView;

@property (nonatomic, strong) NSMutableArray            *wh_videos;
// 当前播放内容是h索引
@property (nonatomic, assign) NSInteger                 wh_currentPlayIndex;
// 控制播放的索引，不完全等于当前播放内容的索引
@property (nonatomic, assign) NSInteger                 wh_index;

@property (nonatomic, assign) JXSmallVideoType type;

- (instancetype)initWithVC:(UIViewController *)vc isPushed:(BOOL)isPushed;

- (void)setModels:(NSArray *)models index:(NSInteger)index;

- (void)pause;
- (void)resume;
- (void)destoryPlayer;



NS_ASSUME_NONNULL_END
- (void)sp_upload;
@end
