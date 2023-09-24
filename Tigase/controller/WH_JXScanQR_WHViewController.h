//
//  WH_JXScanQR_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/9/15.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@protocol WH_JXScanQR_WHViewControllerDelegate <NSObject>

- (void)needVerify:(WH_JXMessageObject *)msg;

@end

@interface WH_JXScanQR_WHViewController : WH_admob_WHViewController

@property (nonatomic ,assign) Boolean isAddFriend; //是否是扫码添加好友

@property (nonatomic ,copy) NSString *idStr; //扫出来的用户id
@property (nonatomic ,weak) id<WH_JXScanQR_WHViewControllerDelegate> delegate;


@end
