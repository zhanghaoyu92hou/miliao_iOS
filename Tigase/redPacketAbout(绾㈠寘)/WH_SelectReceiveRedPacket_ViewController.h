//
//  WH_SelectReceiveRedPacket_ViewController.h
//  Tigase
//
//  Created by Apple on 2020/2/27.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_AddressbookSuper_WHController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_SelectReceiveRedPacket_ViewController : WH_AddressbookSuper_WHController

@property (nonatomic,strong) WH_RoomData * roomData;
@property (nonatomic ,copy) NSString *roomId;

@property (nonatomic ,strong) NSMutableArray *membersArray;

@property (nonatomic, strong) WH_JXUserObject *user;

@property (nonatomic ,strong)UILabel *tLabel;
@property (nonatomic ,strong) UILabel *remarkLabl;

//@property (nonatomic, strong) UITextField *seekTextField;
//@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic ,strong) NSMutableArray *array;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic,strong) NSSet * existSet;
@property (nonatomic,strong) NSSet * disableSet;

@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic,strong) NSMutableSet *set;

@property (nonatomic, strong) NSMutableArray *checkBoxArr;

@property (nonatomic ,copy) void(^selectcClaimBlock)(NSMutableArray *ids ,NSMutableArray *names);

@end

NS_ASSUME_NONNULL_END
