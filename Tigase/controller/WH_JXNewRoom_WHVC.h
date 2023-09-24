//
//  WH_JXNewRoom_WHVC.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class WH_RoomData;
@class WH_JXRoomObject;

@interface WH_JXNewRoom_WHVC : WH_admob_WHViewController{
    UITextField* _desc;
    UILabel* _userName;
    UISwitch * _readSwitch;
    UISwitch * _publicSwitch;
    UILabel* _size;
    WH_JXRoomObject *_chatRoom;
    WH_RoomData* _room;
}

@property (nonatomic,strong) WH_JXRoomObject* chatRoom;
@property (nonatomic,strong) NSString* userNickname;
@property (nonatomic,strong) UITextField* roomName;
@property (nonatomic, assign) BOOL isAddressBook;
@property (nonatomic, strong) NSMutableArray *addressBookArr;


- (void)sp_getMediaFailed;
@end
