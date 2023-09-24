//
//  GKDYHomeViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import "JXSmallVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYPlayerViewController;

@interface GKDYHomeViewController : GKDYBaseViewController
@property (nonatomic, strong) GKDYPlayerViewController  *playerVC;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, assign) JXSmallVideoType *type;

@property (nonatomic ,strong) NSMutableArray *smallVideos;

@end

NS_ASSUME_NONNULL_END
