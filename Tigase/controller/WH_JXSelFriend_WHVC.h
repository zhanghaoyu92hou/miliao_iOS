//
//  WH_JXSelFriend_WHVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>
@class WH_menuImageView;
@class WH_JXRoomObject;

typedef NS_OPTIONS(NSInteger, JXSelUserType) {
    JXSelUserTypeGroupAT    = 1,
    JXSelUserTypeSpecifyAdmin,
    JXSelUserTypeSelMembers,
    JXSelUserTypeSelFriends,
    JXSelUserTypeCustomArray,
    JXSelUserTypeDisAble,
    JXSelUserTypeRoomTransfer,
    JXSelUserTypeRoomInvisibleMan,  //设置隐身人
    JXSelUserTypeRoomMonitorPeople, // 设置监控人
};

@interface WH_JXSelFriend_WHVC: WH_JXTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
    WH_menuImageView* _tb;
    UIView* _topView;
    int _selMenu;
    
}
@property (nonatomic,strong) WH_JXRoomObject* chatRoom;
@property (nonatomic,strong) WH_RoomData* room;
@property (assign) BOOL isNewRoom;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didSelect;
@property (nonatomic,strong) NSMutableSet* set;
@property (nonatomic,strong) NSMutableArray* array;
//@property (nonatomic,strong) memberData* member;
@property (nonatomic,strong) NSSet * existSet;
@property (nonatomic,strong) NSSet * disableSet;
@property (nonatomic,assign) JXSelUserType type;
@property (nonatomic, assign) BOOL isShowMySelf;

@property (nonatomic, assign) BOOL isForRoom;
@property (nonatomic, strong) WH_JXUserObject *forRoomUser;
@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic, assign) BOOL isShowAlert;
@property (nonatomic, assign) SEL alertAction;

- (void)sp_checkNetWorking;
@end
