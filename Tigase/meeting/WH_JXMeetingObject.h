#import <UIKit/UIKit.h>

@class AudioCallViewController;
@class VideoCallViewController;
@class MessagesViewController;
@class ChatViewController;
@class ContactsViewController;


@interface WH_JXMeetingObject:NSObject{
    BOOL scheduleRegistration;
    BOOL nativeABChangedWhileInBackground;
    BOOL multitaskingSupported;
    BOOL _showConnResult;//显示连接结果
    UIAlertView *_alert;
    NSTimeInterval _lastConnectTime;
    int _count;
    NSTimer* _timer;
    int _checkCount;
    WH_JXMessageObject* _msg;
}
-(id)init;
-(void)onNetworkEvent:(NSNotification*)notification;
-(void)onNativeContactEvent:(NSNotification*)notification;
-(void)onStackEvent:(NSNotification*)notification;
-(void)onRegistrationEvent:(NSNotification*)notification;
-(void)onMessagingEvent:(NSNotification*)notification;
-(void)onInviteEvent:(NSNotification*)notification;

-(NSString*)getVideoSize;

-(void)WH_startMeeting;
-(void)WH_stopMeeting;
-(void)saveMeetingId:(WH_JXUserObject*)user;
-(void)WH_doTerminate;
-(void)clearMemory;
-(void)setCodecForWebChat:(BOOL)isOpen;//WEB视频单聊需要，WEB视频会议不需要

-(void) WH_MicrophoneCheck;
-(void)doNotify:(UILocalNotification *)notification;
-(void)WH_meetingDidEnterBackground:(UIApplication *)application;
- (void)WH_meetingWillEnterForeground:(UIApplication *)application;

-(void)sendAsk:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName meetUrl:(NSString *)meetUrl;
-(void)sendReady:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName;
-(void)sendAccept:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName;
-(void)sendCancel:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName;
-(void)sendNoAnswer:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName;
-(void)sendEnd:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName timeLen:(int)timeLen;

-(void)sendMeetingInvite:(NSString*)toUserId toUserName:(NSString*)toUserName roomJid:(NSString*)roomJid callId:(NSString*)callId type:(int)type;

-(void)doSendMsg:(int)type content:(NSString*)content toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName;
-(void)doSendGroupMsg:(int)type content:(NSString*)content toUserId:(NSString*)toUserId;

-(BOOL)startAudioMeeting: (NSString*) remoteUri roomJid:(NSString*)roomJid;
-(BOOL)startVideoMeeting: (NSString*) remoteUri roomJid:(NSString*)roomJid;

@property (nonatomic, strong) ContactsViewController *contactsViewController;
@property (nonatomic, strong) MessagesViewController *messagesViewController;
@property (nonatomic, strong) AudioCallViewController *audioCallController;
@property (nonatomic, strong) VideoCallViewController *videoCallController;
@property (nonatomic, strong) ChatViewController *chatViewController;
@property (getter=isConnected) BOOL connected;
@property (nonatomic, assign) BOOL isMeeting;
@property (nonatomic, assign) BOOL hasAnswer;

-(void)WH_showAutoConnect;
-(void)checkAutoConnect;
-(BOOL)connect;
@end
