//
//  WH_DeleteRoomMembers_ViewController.h
//  Tigase
//
//  Created by Apple on 2020/4/17.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_AddressbookSuper_WHController.h"

#import "WH_JXRoomObject.h"

@class WH_DeleteRoomMembers_ViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol DeleteRoomMembersDelegate <NSObject>

- (void)deleteRoomMembers:(WH_DeleteRoomMembers_ViewController *)vc members:(NSArray *)members;

@end

@interface WH_DeleteRoomMembers_ViewController : WH_AddressbookSuper_WHController

@property (nonatomic,strong) WH_RoomData* room;
@property (nonatomic,strong) WH_JXRoomObject* chatRoom;

@property (nonatomic, strong) NSMutableArray *searchArray;

//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic, strong) NSMutableArray *checkBoxArr;

@property (nonatomic,strong) NSSet * existSet;
@property (nonatomic,strong) NSSet * disableSet;
@property (nonatomic,strong) NSMutableSet* set;
@property (nonatomic ,strong) NSMutableArray *array;

@property (nonatomic, strong) WH_JXUserObject *user;

@property (nonatomic ,strong) NSMutableArray *managerMemberDataArr;//筛选出群管理

@property (nonatomic ,assign) NSInteger roleMark;

@property (nonatomic ,weak) id<DeleteRoomMembersDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
