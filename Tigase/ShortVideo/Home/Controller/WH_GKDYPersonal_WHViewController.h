//
//  GKDYPersonalViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYBase_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_GKDYPersonal_WHViewController : WH_GKDYBase_WHViewController

@property (nonatomic, copy) NSString    *wh_uid;



NS_ASSUME_NONNULL_END
- (void)sp_checkUserInfo;
@end
