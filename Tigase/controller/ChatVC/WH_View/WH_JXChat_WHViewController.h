//
//  WH_JXChat_WHViewController.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import "WH_JXTableViewController.h"
#import "JXLocationVC.h"
#import "emojiViewController.h"


@class WH_JXEmoji;
@class WH_JXSelectImageView;
@class WH_VolumeView;
@class WH_JXRoomObject;
@class WH_JXBaseChat_WHCell;
@class WH_JXVideoPlayer;
@interface WH_JXChat_WHViewController : WH_JXTableViewController<UIImagePickerControllerDelegate,UITextViewDelegate,AVAudioPlayerDelegate,UIImagePickerControllerDelegate,AVAudioRecorderDelegate,UINavigationControllerDelegate,LXActionSheetDelegate>
{
    
    NSMutableArray *_pool;
    UITextView *_messageText;
    UIImageView *inputBar;
    UIButton* _recordBtn;
    UIButton* _recordBtnLeft;
    UIImage *_myHeadImage,*_userHeadImage;
    WH_JXSelectImageView *_moreView;
    UIButton* _btnFace;
    emojiViewController* _faceView;
    WH_JXEmoji* _messageConent;

    BOOL recording;
    NSTimer *peakTimer;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
	NSURL *pathURL;
    UIView* talkView;
    NSString* _lastRecordFile;
    NSString* _lastPlayerFile;
    NSTimeInterval _lastPlayerTime;
    long _lastIndex;

    double lowPassResults;
    NSTimeInterval _timeLen;
    int _refreshCount;
    
    WH_VolumeView* _voice;
    NSTimeInterval _disableSay;
    NSTimeInterval _personalBannedTime ; //个人禁言时间
    NSString * _audioMeetingNo;
    NSString * _videoMeetingNo;
    NSMutableArray * _orderRedPacketArray ;
}
- (IBAction)sendIt:(id)sender;
- (IBAction)shareMore:(id)sender;
//- (void)refresh;

@property (nonatomic,strong) WH_JXRoomObject *wh_chatRoom;
@property (nonatomic,strong) WH_RoomData *wh_room;
@property (nonatomic,strong) WH_JXUserObject *wh_chatPerson;//必须要赋值
@property (nonatomic, strong) WH_JXMessageObject *wh_lastMsg;
@property (nonatomic,strong) NSString *wh_roomJid;//相当于RoomJid
@property (nonatomic,strong) NSString *wh_roomId;
@property (nonatomic,strong) WH_JXBaseChat_WHCell *wh_selCell;
@property (nonatomic,strong) JXLocationVC *wh_locationVC;
@property (nonatomic, strong) NSMutableArray *wh_array;

//@property (nonatomic, strong) WH_JXMessageObject *relayMsg;
@property (nonatomic, strong) NSMutableArray *wh_relayMsgArray;
@property (nonatomic, assign) int wh_scrollLine;

@property (nonatomic, strong) NSMutableArray *wh_courseArray;
@property (nonatomic, copy) NSString *wh_courseId;

@property (nonatomic, strong) NSNumber *wh_groupStatus;

@property (nonatomic, assign) BOOL wh_isGroupMessages;
@property (nonatomic, strong) NSMutableArray *wh_userIds;
@property (nonatomic, strong) NSMutableArray *wh_userNames;

@property (nonatomic, assign) BOOL wh_isHiddenFooter;
@property (nonatomic, strong) NSMutableArray *wh_chatLogArray;

@property (nonatomic, assign) NSInteger wh_rowIndex;
@property (nonatomic, assign) int wh_newMsgCount;

@property (nonatomic, strong) WH_JXVideoPlayer *wh_player;
@property (nonatomic, strong) UIView *wh_playerView;
@property (nonatomic, assign) BOOL wh_isShare;
@property (nonatomic, copy) NSString *wh_shareSchemes;

@property (nonatomic ,copy) NSString *wh_groupNum; //群中人数


-(void)WH_sendRedPacketWithMoneyNum:(NSDictionary*)redPacketDict withGreet:(NSString *)greet;
//-(void)onPlay;
//-(void)recordPlay:(long)index;
-(void)resend:(WH_JXMessageObject*)p;
-(void)deleteMsg:(WH_JXMessageObject*)p;

/**
 跳转到聊天页面
 
 @param userId 用户id
 */
+ (void)gotoChatViewController:(NSString *)userId;
@end
