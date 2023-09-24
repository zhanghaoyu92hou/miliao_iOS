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

@property (nonatomic,strong) WH_JXRoomObject* chatRoom;
@property (nonatomic,strong) WH_RoomData * room;
@property (nonatomic,strong) WH_JXUserObject *chatPerson;//必须要赋值
@property (nonatomic, strong) WH_JXMessageObject *lastMsg;
@property (nonatomic,strong) NSString* roomJid;//相当于RoomJid
@property (nonatomic,strong) NSString* roomId;
@property (nonatomic,strong) WH_JXBaseChat_WHCell* selCell;
@property (nonatomic,strong) JXLocationVC * locationVC;
@property (nonatomic, strong) NSMutableArray *array;

//@property (nonatomic, strong) WH_JXMessageObject *relayMsg;
@property (nonatomic, strong) NSMutableArray *relayMsgArray;
@property (nonatomic, assign) int scrollLine;

@property (nonatomic, strong) NSMutableArray *courseArray;
@property (nonatomic, copy) NSString *courseId;

@property (nonatomic, strong) NSNumber *groupStatus;

@property (nonatomic, assign) BOOL isGroupMessages;
@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic, assign) BOOL isHiddenFooter;
@property (nonatomic, strong) NSMutableArray *chatLogArray;

@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) int newMsgCount;

@property (nonatomic, strong) WH_JXVideoPlayer *player;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, copy) NSString *shareSchemes;
@property (nonatomic, copy) NSURL *shareUrl;
@property (nonatomic ,copy) NSString *groupNum; //群中人数

@property (nonatomic ,assign) BOOL isQRCodePush; //扫码进群

@property (nonatomic ,strong) NSMutableArray *noticesArry;

@property (nonatomic ,assign) NSInteger groupSize;

@property (nonatomic ,strong) NSString *bannedRemind; //单人禁言提示内容

-(void)sendRedPacket:(NSDictionary*)redPacketDict withGreet:(NSString *)greet;
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
