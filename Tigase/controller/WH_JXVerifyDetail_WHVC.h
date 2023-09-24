//
//  WH_JXVerifyDetail_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/5/29.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "WH_JXChat_WHViewController.h"


@interface WH_JXVerifyDetail_WHVC : WH_admob_WHViewController
@property (nonatomic, strong) WH_JXMessageObject *msg;
@property (nonatomic,strong) WH_RoomData * room;
@property (nonatomic, weak) WH_JXChat_WHViewController *chatVC;


- (void)sp_getUserName;
@end
