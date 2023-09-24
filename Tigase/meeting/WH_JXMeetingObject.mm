#import "WH_JXMeetingObject.h"
//#import "MessagesViewController.h"
//#import "ChatViewController.h"
//#import "ContactsViewController.h"
#import "AppDelegate.h"
#import "WH_VersionManageTool.h"
#import "acceptCallViewController.h"
#import "JXAVCallViewController.h"
#ifdef Live_Version
#import "WH_JXLiveJid_WHManager.h"
#endif
#undef TAG
#define kTAG @"AppDelegate///: "
#define TAG kTAG
#define kTabBarIndex_Favorites	0
#define kTabBarIndex_Recents	1
#define kTabBarIndex_Contacts	2
#define kTabBarIndex_Numpad		3
#define kTabBarIndex_Messages	4

#define kNotifKey									@"key"
#define kNotifKey_IncomingCall						@"icall"
#define kNotifKey_IncomingMsg						@"imsg"
#define kNotifIncomingCall_SessionId				@"sid"

#define kNetworkAlertMsgThreedGNotEnabled  Localized(@"WaHu_JXMeetingObject_3GNetWork")
#define kNetworkAlertMsgNotReachable				Localized(@"WaHu_JXMeetingObject_NoNetWork")
#define kNewMessageAlertText						Localized(@"WaHu_JXMeetingObject_NewMessage")
#define kAlertMsgButtonOkText						Localized(@"JX_Confirm")
#define kAlertMsgButtonCancelText					Localized(@"JX_Cencal")


static UIBackgroundTaskIdentifier sBackgroundTask = UIBackgroundTaskInvalid;
static dispatch_block_t sExpirationHandler = nil;

@interface WH_JXMeetingObject()

@property (nonatomic, assign) BOOL isInCall;
@property (nonatomic, copy) NSString *meetUrl;

@end

@implementation WH_JXMeetingObject

-(id)init{
    self = [super init];
    _count = 0;
    _lastConnectTime = 0;
    _showConnResult = NO;
    _checkCount = 0;
    [g_notify  addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsg_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(callAnswerNotification:) name:kCallAnswer_WHNotification object:nil];
    return self;
}

-(void)dealloc{
    [g_notify removeObserver:self];
}

-(void)callAnswerNotification:(NSNotification *)notifacation{
    self.hasAnswer = YES;
}

-(void)onOtherEvent:(NSNotification*)notification {
    NSLog(@"onOtherEvent:  %@",notification.name);
}

-(NSString*)getVideoSize{
    NSString* s = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatVideoSize"];
    if(s==nil)
        s = @"1";
    switch ([s intValue]) {
        case 0:
            s = @"11";
            break;
        case 1:
            s = @"9";
            break;
        case 2:
            s = @"5";
            break;
        case 3:
            s = @"2";
            break;
        default:
            s = @"5";
            break;
    }
    return s;
}

-(void)WH_startMeeting{
    
    multitaskingSupported = [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [[UIDevice currentDevice] isMultitaskingSupported];
//    sBackgroundTask = UIBackgroundTaskInvalid;
//    UIApplication* app = [UIApplication sharedApplication];
//    //sExpirationHandler = ^{//老代码
//    sBackgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        //NSLog(@"Background task completed");
//        [app endBackgroundTask:sBackgroundTask];
//        sBackgroundTask = UIBackgroundTaskInvalid;
//    }];
    
    if(multitaskingSupported){
        //		NgnNSLog(TAG, @"Multitasking IS supported");
    }
    
    // Set media parameters if you want
//    MediaSessionMgr::defaultsSetAudioGain(0, 0);
    // Set some codec priorities
    /*int prio = 0;
     SipStack::setCodecPriority(tdav_codec_id_g722, prio++);
     SipStack::setCodecPriority(tdav_codec_id_speex_wb, prio++);
     SipStack::setCodecPriority(tdav_codec_id_pcma, prio++);
     SipStack::setCodecPriority(tdav_codec_id_pcmu, prio++);
     SipStack::setCodecPriority(tdav_codec_id_h264_bp, prio++);
     SipStack::setCodecPriority(tdav_codec_id_h264_mp, prio++);
     SipStack::setCodecPriority(tdav_codec_id_vp8, prio++);*/
    //...etc etc etc
    
    //    [self changeLanguage];
    
    [self WH_MicrophoneCheck];
}

-(void)WH_stopMeeting{

}

-(void)WH_meetingDidEnterBackground:(UIApplication *)application {

}


- (void)WH_meetingWillEnterForeground:(UIApplication *)application {
    
    // check native contacts changed while app was runnig on background
    if(self->nativeABChangedWhileInBackground){
        // trigger refresh
        self->nativeABChangedWhileInBackground = NO;
    }
}

- (void) WH_MicrophoneCheck{
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                //                NSLog(@"Microphone is enabled..");
            }
            else {
                // Microphone disabled code
                //                NSLog(@"Microphone is disabled..");
                
                // We're in a background thread here, so jump to main thread to do UI work.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [g_App showAlert:Localized(@"JX_CanNotOpenMicr")];
                });
            }
        }];
    }
}

-(ChatViewController *)chatViewController{
    if(!_chatViewController){
        //        _chatViewController = [[ChatViewController alloc] initWithNibName: @"ChatView" bundle:nil];
    }
    return _chatViewController;
}


- (void)WH_doTerminate{
    [g_notify removeObserver:self];
}

- (void)clearMemory{
}

/*没用：
 - (void)setSettingToNgn:(NSDictionary*)dict{
 
 NSArray* itemArray = [dict objectForKey:@"PreferenceSpecifiers"];
 for(int i = 0; i < [itemArray count]; i++)
 {
 NSDictionary* identityItemDictionary = (NSDictionary*)[itemArray objectAtIndex:i];
 NSString* strType = (NSString*)[identityItemDictionary objectForKey:@"Type"];
 NSString* strKey = (NSString*)[identityItemDictionary objectForKey:@"Key"];
 NSString* strValue = (NSString*)[identityItemDictionary objectForKey:@"DefaultValue"];
 if([strType isEqualToString:@"PSTextFieldSpecifier"])
 [[NgnEngine sharedInstance].configurationService setStringWithKey:strKey andValue:strValue];
 if([strType isEqualToString:@"PSToggleSwitchSpecifier"])
 [[NgnEngine sharedInstance].configurationService setBoolWithKey:strKey andValue:[strValue isEqualToString:@"YES"]];
 }
 }*/

-(void)loadSeeting{
    /*
     [[CSetting sharedInstance] loadSetting];
     NSDictionary* p = [[[CSetting sharedInstance].identityDict objectForKey:@"PreferenceSpecifiers"] objectAtIndex:2];
     NSString* userId = [p objectForKey:@"DefaultValue"];
     if([userId isEqualToString:g_myself.userId]){//如果已保存则赋值
     [self setSettingToNgn:[CSetting sharedInstance].identityDict];
     [self setSettingToNgn:[CSetting sharedInstance].networkDict];
     [self setSettingToNgn:[CSetting sharedInstance].traversalDict];
     [self setSettingToNgn:[CSetting sharedInstance].mediaDict];
     [self setSettingToNgn:[CSetting sharedInstance].codecsDict];
     }
     else
     [self saveMeetingId:g_myself];//如果未保存则保存
     */
}

//SIP掉线后提示
- (void) WH_showAutoConnect{
    if(_alert)
        return;
    _alert = [[UIAlertView alloc] initWithTitle:Localized(@"JXMeeting_offline") message:Localized(@"JXMeeting_reConnect") delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    _alert.tag = 10000;
    [_alert show];
    _showConnResult = YES;
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == 10000) { //SIP掉线
            [JXMyTools showTipView:Localized(@"JX_Connection")];
            [self connect];
            //            [self performSelector:@selector(checkAutoConnect) withObject:nil afterDelay:60];
        }
    }
    _alert = nil;
}

-(void)showConnectFailed{
    [JXMyTools showTipView:[NSString stringWithFormat:@"%@%@",Localized(@"JXMeeting_connect"),Localized(@"JX_Failed")]];
    _showConnResult = NO;
}

-(void)showConnectSuccess{
    [JXMyTools showTipView:[NSString stringWithFormat:@"%@%@",Localized(@"JXMeeting_connect"),Localized(@"JX_Success")]];
    _showConnResult = NO;
}

-(void)checkAutoConnect{
    if(!self.connected)
        [self WH_showAutoConnect];
}

-(BOOL)isConnected{
}

-(void)sendAsk:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName meetUrl:(NSString *)meetUrl{
    NSString* content=nil;
    self.meetUrl = meetUrl;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0];
}

-(void)sendReady:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0];
}

-(void)sendAccept:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0];
}

-(void)sendCancel:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:0];
}

-(void)sendNoAnswer:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:1];
}

-(void)sendEnd:(int)type toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName timeLen:(int)timeLen{
    NSString* content=nil;
    [self doSendMsg:type content:content toUserId:toUserId toUserName:toUserName timeLen:timeLen];
}

-(void)sendMeetingInvite:(NSString*)toUserId toUserName:(NSString*)toUserName roomJid:(NSString*)roomJid callId:(NSString*)callId type:(int)type{
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    if(type == kWCMessageTypeVideoMeetingInvite)
        msg.content      = Localized(@"JXMeeting_InviteVideoMeeting");
    else
        msg.content      = Localized(@"JXMeeting_InviteAudioMeeting");
    msg.fileName     = callId;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = toUserId;
    msg.toUserName   = toUserName;
    msg.objectId     = roomJid;
    msg.isGroup      = NO;
    msg.type         = [NSNumber numberWithInt:type];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 1;
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:nil];//发送消息
    [g_notify postNotificationName:kXMPPShowMsg_WHNotifaction object:msg];//显示出来
}

-(void)doSendMsg:(int)type content:(NSString*)content toUserId:(NSString*)toUserId toUserName:(NSString*)toUserName timeLen:(int)timeLen{
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.content      = content;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = toUserId;
    msg.toUserName   = toUserName;
    msg.isGroup = NO;
    msg.type         = [NSNumber numberWithInt:type];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.timeLen      = [NSNumber numberWithInt:timeLen];//对方无应答标志或通话时长
    msg.sendCount    = 1;
    if (type == kWCMessageTypeAudioChatAsk || type == kWCMessageTypeVideoChatAsk) {
        msg.fileName = self.meetUrl;
    }
    [msg insert:nil];
    [g_xmpp sendMessage:msg roomName:nil];//发送消息
    [g_notify postNotificationName:kXMPPShowMsg_WHNotifaction object:msg];//显示出来
}

-(void)doSendGroupMsg:(int)type content:(NSString*)content toUserId:(NSString*)toUserId{
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.content      = content;
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = toUserId;
    msg.objectId     = toUserId;
    msg.isGroup      = YES;
    msg.type         = [NSNumber numberWithInt:type];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    msg.sendCount    = 3;
    [g_xmpp sendMessage:msg roomName:toUserId];//发送消息
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    WH_JXMessageObject *msg = notifacation.object;
    
    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
        if ([msg.type intValue] == kWCMessageTypeAudioChatAsk || [msg.type intValue] == kWCMessageTypeVideoChatAsk || [msg.type intValue] == kWCMessageTypeVideoMeetingInvite || [msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [msg.type intValue] == kWCMessageTypeAudioChatAccept || [msg.type intValue] == kWCMessageTypeVideoChatAccept) {
            return;
        }
    }
    
    if(msg==nil)
        return;
#ifdef Live_Version
    if([[WH_JXLiveJid_WHManager shareArray] contains:msg.toUserId] || [[WH_JXLiveJid_WHManager shareArray] contains:msg.fromUserId])
        return;
#endif
    
    if([msg.toUserId isEqualToString:MY_USER_ID]){
        if([msg.type intValue] == kWCMessageTypeVideoChatAsk || [msg.type intValue] == kWCMessageTypeAudioChatAsk){
            if(g_meeting.isMeeting){ //如果有别的通话 不弹出界面
                if (!msg.isMultipleRelay) {
                    [self sendAVBusy:msg.fromUserId];
                }
                return; //如果有别的通话 不弹出界面
            }
                
            int n = ([[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000))-[msg.timeSend timeIntervalSince1970];
            if(n>30)//如果时间差超过30秒，则放弃
                return;
            self.isInCall = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if(g_meeting.isMeeting){
                    if (!msg.isMultipleRelay) {
                        [self sendAVBusy:msg.fromUserId];
                    }
                    return; //如果有别的通话 不弹出界面
                }
                if (self.isInCall) {
                    self.meetUrl = msg.fileName;
                    acceptCallViewController* vc = [acceptCallViewController alloc];
                    vc.toUserName = msg.fromUserName;
                    vc.toUserId = msg.fromUserId;
                    vc.type = msg.type;
                    vc.roomNum = msg.fromUserId;
                    NSString* s;
                    if([msg.type intValue] == kWCMessageTypeAudioChatAsk)
                        s = Localized(@"JXMeeting_AudioCall_title");
                    else
                        s = Localized(@"JXMeeting_VideoCall_title");
                    vc.title = s;
                    vc.delegate = self;
                    vc.didTouch = @selector(WH_doAudioVideoMeeting:);
                    vc = [vc init];
                    //                    [g_window addSubview:vc.view];
                    [g_navigation pushViewController:vc animated:NO];
                    _msg = msg;
                }
                
            });
            
//            if(self.isConnected){
//                [self WH_sendReadyMsg:msg];//如果连接成功，则发ready消息
//            }else{
//                _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkMediaServer:) userInfo:msg repeats:YES];
//                [self connect];//如果不成功，则开定时器检查
//            }
            return;
        }
        if([msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [msg.type intValue] == kWCMessageTypeVideoMeetingInvite){
//            if (msg.isDelay) {  // 离线的会议音视频邀请不接收
//                return;
//            }
            int n = ([[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000))-[msg.timeSend timeIntervalSince1970];
            if(self.isMeeting) return; //如果有别的通话 不弹出界面
            if(n<=30){//如果时间差超过30秒，则放弃
                if(![current_meeting_no isEqualToString:msg.fileName]){//如果正在开会，则不弹框
                    NSString* s;
                    if([msg.type intValue] == kWCMessageTypeVideoMeetingInvite)
                        s = Localized(@"JXMeeting_InviteVideoMeeting");
                    else
                        s = Localized(@"JXMeeting_InviteAudioMeeting");
                    acceptCallViewController* vc = [acceptCallViewController alloc];
                    vc.isGroup = YES;
                    vc.toUserName = msg.fromUserName;
                    vc.toUserId = msg.fromUserId;
                    vc.roomNum = msg.objectId;
                    vc.type = msg.type;
                    vc.title = s;
                    vc.delegate = self;
                    vc.didTouch = @selector(WH_doAudioVideoMeeting:);
                    vc = [vc init];
//                    [g_window addSubview:vc.view];
                    [g_navigation pushViewController:vc animated:NO];
                    _msg = msg;
                }
            }
        }
    }
    
    if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel) {
        self.isInCall = NO;
        [g_App endCall];
    }
    msg = nil;
}

- (void)sendAVBusy:(NSString *)toUserId {
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    msg.toUserId     = toUserId;
    msg.isGroup = NO;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeAVBusy];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    [g_xmpp sendMessage:msg roomName:nil];//发送消息
    
}

-(void)checkMediaServer:(NSTimer*)sender{
    _checkCount++;
    if(self.isConnected){
        WH_JXMessageObject* msg = (WH_JXMessageObject*)[sender userInfo];
        [self WH_sendReadyMsg:msg];//如果连接成功，则发ready消息
        [_timer invalidate];
        _checkCount = 0;
    }
    if(_checkCount>30){//检查30次，每秒一次
        [_timer invalidate];
        _checkCount = 0;
    }
}

-(void)WH_sendReadyMsg:(WH_JXMessageObject*)msg{//发送准备好音视频通话的消息
    int n = [[NSDate date] timeIntervalSince1970]-[msg.timeSend timeIntervalSince1970];
    if(n>30)//如果时间差超过30秒，则放弃
        return;
    int k;
    if([msg.type intValue] == kWCMessageTypeVideoChatAsk)
        k = kWCMessageTypeVideoChatReady;
    else
        k = kWCMessageTypeAudioChatReady;
    [self sendReady:k toUserId:msg.fromUserId toUserName:msg.fromUserName];
}

-(void)WH_doAudioVideoMeeting:(acceptCallViewController*)vc{
    JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
    
    if([_msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [_msg.type intValue] == kWCMessageTypeAudioChatAsk){
        avVC.isAudio = YES;
        
    }
    
    if([_msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [_msg.type intValue] == kWCMessageTypeVideoMeetingInvite){
        avVC.isGroup = YES;
        avVC.roomNum = _msg.objectId;
    }else if ([_msg.type intValue] == kWCMessageTypeAudioChatAsk) {
        
        avVC.roomNum = _msg.fromUserId;
        avVC.meetUrl = self.meetUrl;
        [g_meeting sendAccept:kWCMessageTypeAudioChatAccept toUserId:_msg.fromUserId toUserName:_msg.fromUserName];
    }else if ([_msg.type intValue] == kWCMessageTypeVideoChatAsk) {
        
        avVC.roomNum = _msg.fromUserId;
        avVC.meetUrl = self.meetUrl;
        [g_meeting sendAccept:kWCMessageTypeVideoChatAccept toUserId:_msg.fromUserId toUserName:_msg.fromUserName];
    }
    avVC.toUserId = _msg.fromUserId;
    avVC.toUserName = _msg.fromUserName;
    avVC.view.frame = [UIScreen mainScreen].bounds;
    
//        [self startVideoMeeting:_msg.fileName roomJid:_msg.objectId];
//    else
//        [self startAudioMeeting:_msg.fileName roomJid:_msg.objectId];
//    UIViewController *lastVC = (UIViewController *)g_navigation.lastVC;
//    [lastVC presentViewController:avVC animated:NO completion:nil];
    [g_window addSubview:avVC.view];
    _msg = nil;
}

/*
-(BOOL)isMeeting{
//    return self.audioCallController.sessionId>0 || self.videoCallController.sessionId>0;
    return self.audioCallController || self.videoCallController;
}
*/

@end
