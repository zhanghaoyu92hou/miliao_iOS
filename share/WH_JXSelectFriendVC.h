//
//  WH_JXSelectFriendVC.h
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_JXSelectFriendVC;
@class WH_JXShareUser;
@protocol WH_JXSelectFriendVCDlegate <NSObject>

- (void)sendToFriendSuccess:(WH_JXSelectFriendVC *)selectVC user:(WH_JXShareUser *)user;

@end

@interface WH_JXSelectFriendVC : UIViewController
@property (nonatomic, strong) NSArray *wh_datas;
@property (weak, nonatomic) id <WH_JXSelectFriendVCDlegate> wh_delegate;


@end

