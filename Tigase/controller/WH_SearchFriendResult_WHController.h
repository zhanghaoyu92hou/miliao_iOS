//
//  WH_SearchFriendResult_WHController.h
//  Tigase
//
//  Created by Apple on 2019/7/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_SearchFriendResult_WHController : WH_admob_WHViewController

@property (nonatomic, strong) WH_SearchData *search;

@property (nonatomic ,strong) UIView *emptyView; //空提示

@property (nonatomic ,strong) NSNumber *isAddFriend; //个人是否有权限加好友 1、允许建群 0、禁止建群

NS_ASSUME_NONNULL_END
- (void)sp_getUserFollowSuccess;
@end
