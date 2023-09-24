//
//  WH_JXMsg_WHViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>

#import "WH_JXRoomObject.h"

@interface WH_JXMsg_WHViewController : WH_JXTableViewController <UIScrollViewDelegate>{
//    NSMutableArray *_array;
    int _refreshCount;
    int _recordCount;
    float lastContentOffset;
    int upOrDown;
    WH_AudioPlayerTool* _audioPlayer;
}
@property(nonatomic,assign) int wh_msgTotal;
@property (nonatomic, strong) NSMutableArray *wh_array;

- (void)WH_cancelBtnAction;
- (void)getTotalNewMsgCount;


@property (nonatomic, assign) BOOL wh_isShowTopPromptV; //是否显示顶部提示框
//@property (nonatomic, copy) NSString *promptText; //顶部提示文本

@property (nonatomic ,assign) NSInteger sharePushType; //1:分享进来 2：分享进群(群不需要验证)
@property (nonatomic ,copy) NSString *invitePeopleId; //邀请人Id
@property (nonatomic ,copy) NSString *invPeoNickName; //邀请人nickname
@property (nonatomic ,copy) NSString *invPeoRoomId;
@property (nonatomic ,strong) WH_RoomData *invPeoRoom;

@property (nonatomic,strong) WH_JXRoomObject *chatRoom;
@property (nonatomic,strong) WH_RoomData* room;
@property (nonatomic, strong) NSMutableArray *noticeArr; //群公告

@property (nonatomic, strong) WH_JXUserObject *user;

@property (nonatomic,strong) WH_RoomData * createRoom; //创建群组

@property (nonatomic ,assign) Boolean isTwoWithdrawal; //是否是双向撤回
@property (nonatomic ,copy) NSString *rJid;

- (void)sp_getMediaFailed;
@end
