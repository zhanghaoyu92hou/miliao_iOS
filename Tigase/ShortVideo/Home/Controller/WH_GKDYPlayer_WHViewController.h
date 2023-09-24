//
//  GKDYPlayerViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYBase_WHViewController.h"
#import "GKDYVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_GKDYPlayer_WHViewController : WH_GKDYBase_WHViewController

@property (nonatomic, strong) GKDYVideoView *wh_videoView;

@property (nonatomic, assign) JXSmallVideoType type;



NS_ASSUME_NONNULL_END
- (void)sp_getUserFollowSuccess;
@end
