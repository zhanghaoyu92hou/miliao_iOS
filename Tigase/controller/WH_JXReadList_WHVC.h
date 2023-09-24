//
//  WH_JXReadList_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/9/2.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXTableViewController.h"

@class WH_RoomData;

@interface WH_JXReadList_WHVC : WH_JXTableViewController

@property (nonatomic, strong) WH_JXMessageObject *msg;
@property (nonatomic, strong) WH_RoomData *room;


- (void)sp_getLoginState;
@end
