//
//  WH_JXRoomMemberList_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/7/3.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import "WH_JXRoomObject.h"

#import "WH_JX_WHCell.h"

typedef enum : NSUInteger {
    Type_Default = 1,
    Type_NotTalk,
    Type_DelMember,
    Type_AddNotes,
} RoomMemberListType;

@class WH_JXInputValue_WHVC;
@class WH_JXRoomMemberList_WHVC;

@protocol WH_JXRoomMemberList_WHVCDelegate <NSObject>

- (void) roomMemberList:(WH_JXRoomMemberList_WHVC *)vc delMember:(memberData *)member;

- (void)roomMemberList:(WH_JXRoomMemberList_WHVC *)vc delMembers:(NSArray *)members;

- (void)roomMemberList:(WH_JXRoomMemberList_WHVC *)selfVC addNotesVC:(WH_JXInputValue_WHVC *)vc;

@end

@interface WH_JXRoomMemberList_WHVC : WH_JXTableViewController


@property (nonatomic,strong) WH_RoomData* room;

@property (nonatomic, assign) RoomMemberListType type;
@property (nonatomic,strong) WH_JXRoomObject* chatRoom;

@property (nonatomic ,copy) NSString *toUserId;
@property (nonatomic ,copy) NSString *toUserName;

@property (nonatomic ,assign) Boolean isTimeSorting ; //是否为时间排序

@property (nonatomic ,strong) NSMutableArray *timeArray; //按照时间排序数据


@property (nonatomic,strong) NSSet * existSet;
@property (nonatomic,strong) NSSet * disableSet;
@property (nonatomic, strong) NSMutableArray *checkBoxArr;

@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic,strong) NSMutableSet* set;

@property (nonatomic ,assign) NSInteger roleMark; 

@property (nonatomic, weak) id<WH_JXRoomMemberList_WHVCDelegate>delegate;


- (void)sp_getUserFollowSuccess;
@end
