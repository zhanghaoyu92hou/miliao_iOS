//
//  GKDYHomeViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYBase_WHViewController.h"
#import "JXSmallVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class WH_GKDYPlayer_WHViewController;

@interface WH_GKDYHome_WHViewController : WH_GKDYBase_WHViewController
@property (nonatomic, strong) WH_GKDYPlayer_WHViewController  *wh_playerVC;
@property (nonatomic, copy) NSString *wh_titleStr;
@property (nonatomic, assign) JXSmallVideoType type;

@property (nonatomic ,strong) NSMutableArray *smallVideos;

NS_ASSUME_NONNULL_END
@end
