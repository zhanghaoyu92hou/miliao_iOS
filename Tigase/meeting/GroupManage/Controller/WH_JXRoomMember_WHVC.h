//
//  WH_JXRoomMember_WHVC.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "WH_SetGroupHeads_WHView.h"


@class WH_RoomData;
@class WH_JXRoomObject;

@protocol WH_JXRoomMember_WHVCDelegate <NSObject>

- (void) setNickName:(NSString *)nickName;
- (void) needVerify:(WH_JXMessageObject *)msg;

@end

@interface WH_JXRoomMember_WHVC : WH_admob_WHViewController<LXActionSheetDelegate>{
    JXLabel* _desc;
    JXLabel* _userName;
    JXLabel* _roomName;
    UILabel* _memberCount;
    UILabel* _creater;
    UILabel* _size;
    NSMutableArray* _deleteArr;
    NSMutableArray* _images;
    NSMutableArray* _names;
    BOOL _delMode;
    WH_JXRoomObject *_chatRoom;
    int _h;
    BOOL _isAdmin;
    BOOL _allowEdit;
    UILabel* _note;
    UIView* _heads;
    int _delete;
    int _disable;
    BOOL _disableMode;
    BOOL _unfoldMode;
    WH_JXUserObject* _user;
    WH_JXImageView* _blackBtn;
    int _modifyType;
    NSString* _content;
    NSString* _toUserId;
    NSString* _toUserName;
    UISwitch * _readSwitch;
    UISwitch *_messageFreeSwitch;
    UISwitch *_allNotTalkSwitch;
    UILabel* _roomNum;
}

@property (nonatomic, assign) NSString *wh_roomId;

@property (nonatomic,strong) WH_JXRoomObject *wh_chatRoom;
@property (nonatomic,strong) WH_RoomData *wh_room;
@property (nonatomic,strong) WH_JXImageView *wh_iv;
@property (nonatomic, weak) id<WH_JXRoomMember_WHVCDelegate> delegate;
@property (nonatomic, assign) int wh_rowIndex;
@property (nonatomic ,copy) NSString *wh_groupNum;
@property (nonatomic ,strong) WH_SetGroupHeads_WHView *wh_setGroupHeadsview;
@property (nonatomic ,strong) WH_JXMsgAndUserObject *pData;
//@property (nonatomic,strong) NSString* userNickname;

@property (nonatomic ,assign) BOOL isStartEnter; //是否第一次进入界面

@property (nonatomic, strong) NSMutableArray *noticeArr; //群公告

@property (nonatomic ,assign) NSInteger membersNum; //成员数量

@property (nonatomic ,strong) UIButton *seeAllBtn;

//@property (nonatomic ,strong) UIImageView *tView;

- (void)sp_checkUserInfo;
@end
