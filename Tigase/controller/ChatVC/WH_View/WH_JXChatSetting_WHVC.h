//
//  WH_JXChatSetting_WHVC.h
//  wahu_imChat
//
//  Created by p on 2018/5/19.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "WH_JXRoomObject.h"

@interface WH_JXChatSetting_WHVC : WH_admob_WHViewController

@property (nonatomic,strong) WH_JXUserObject *wh_user;
@property (nonatomic,strong) WH_JXRoomObject* wh_chatRoom;
@property (nonatomic,strong) WH_RoomData * wh_room;


- (void)sp_getUsersMostLikedSuccess:(NSString *)mediaInfo;
@end
