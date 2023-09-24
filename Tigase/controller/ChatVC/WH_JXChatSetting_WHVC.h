//
//  WH_JXChatSetting_WHVC.h
//  wahu_im
//
//  Created by p on 2018/5/19.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "WH_JXRoomObject.h"

@interface WH_JXChatSetting_WHVC : WH_admob_WHViewController

@property (nonatomic,strong) WH_JXUserObject *user;
@property (nonatomic,strong) WH_JXRoomObject* chatRoom;
@property (nonatomic,strong) WH_RoomData * room;

@end
