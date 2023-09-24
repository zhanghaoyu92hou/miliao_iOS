//
//  JXXMPP.m
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//
// Log levels: off, error, warn, info, verbose

#import "JXXMPP.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilities.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPRoster.h"
#import "XMPPMessage.h"
#import "TURNSocket.h"
#import "AppDelegate.h"
#import "FMDatabase.h"

#import "WH_JXRoomPool.h"
#import "XMPPMessage+XEP_0184.h"
#import "WH_JXMain_WHViewController.h"
#import "WH_JXFriendObject.h"
#import "FileInfo.h"
#import "WH_JXGroup_WHViewController.h"
#import "WH_JXRoomObject.h"
#import "WH_JXRoomRemind.h"
#import "JXBlogRemind.h"
#import "WH_JXFriendObject.h"
#import "AppleReachability.h"
#import "WH_StrongReminderView.h"
#import "WH_JXChat_WHViewController.h"
#import "wahu_2_0-Swift.h"
#import "WH_LoginViewController.h"
#import "JXSynTask.h"
#import "WH_HBCoreLabel.h"
#if DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#endif




#define DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define CACHES_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]

@interface JXXMPP ()<XMPPReconnectDelegate,XMPPStreamManagementDelegate>

@property (nonatomic, strong) ATMHud *wait;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic ,strong) WHL_EventSource * eventSource;

@end

@implementation JXXMPP
@synthesize stream=xmppStream,isLogined,roomPool,poolSend=_poolSend,blackList;




static JXXMPP *sharedManager;

+(JXXMPP*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[JXXMPP alloc]init];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [sharedManager setupStream];
    });
    
    return sharedManager;
}

-(id)init{
    self = [super init];
    _poolSend = [[NSMutableDictionary alloc]init];
    _poolSendRead = [[NSMutableArray alloc]init];
    _poolSendIQ = [[NSMutableArray alloc] init];
    blackList = [[NSMutableSet alloc]init];
    isLogined = login_status_no;
    _chatingUserIds = [[NSMutableArray alloc]init];
//    _isEncryptAll = [[NSUserDefaults standardUserDefaults] boolForKey:kMESSAGE_isEncrypt];
    [g_notify addObserver:self selector:@selector(readDelete:) name:kCellReadDelNotification object:nil];
    self.newMsgAfterLogin = 0;
    _wait = [ATMHud sharedInstance];
    self.isReconnect = YES;
    
    return self;
}

- (WHL_EventSource *)eventSource
{
    if (_eventSource == nil) {
        _eventSource= [[WHL_EventSource alloc] init];
        
        NSString *urlStr = @"";
        NSString *urlPath = @"";
        NSString *apiUrl = g_config.apiUrl?:@"";
        if ([apiUrl hasSuffix:@"/"]) {
            urlStr = [apiUrl substringToIndex:[apiUrl length] - 1];
        }else{
            urlStr = apiUrl;
        }
                
        if ([urlStr rangeOfString:@":"].location != NSNotFound) {
        //包含有端口号
                    
            NSString *lowerStr = [urlStr lowercaseString]; //将所有字符串内容转为小写
                    
            NSArray *strArray = [urlStr componentsSeparatedByString:@":"];
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:strArray];
            if ([lowerStr hasPrefix:@"http://"] || [lowerStr hasPrefix:@"https://"]) {
                if (array.count > 2) {
                    [array removeObjectAtIndex:array.count -1];
                 }
            }else{
                [array removeObjectAtIndex:array.count -1];
            }
            urlPath = [array componentsJoinedByString:@":"];
        }else{
            urlPath = urlStr;
        }
        
        [_eventSource creatEventSourceWithHost:[NSString stringWithFormat:@"%@:8095" ,urlPath] uid:g_server.access_token];

        [_eventSource onMessage:^(NSString * _Nullable sid, id _Nullable event, id _Nullable data) {
            NSLog(@"sse收到 %@ %@ %@", sid, event, data);
            NSString *dataStr = [NSString stringWithFormat:@"%@",data];
            if (![dataStr isEqualToString:@"ok"] && ![dataStr isEqualToString:@"fail"]) {
                
                //字典消息类型解析
                NSDictionary *dic = [data mj_JSONObject];
                if (dic.allKeys.count) {
                    [self dealEventSourceMessageWithDict:dic];
                }else{
                    //字符串转xml消息结构
                    NSError *error;
                    DDXMLElement *elm = [[DDXMLElement alloc] initWithXMLString:dataStr error:&error];
                    XMPPMessage *msg = [XMPPMessage messageFromElement:elm];
                    //处理接收到的消息
                    [self xmppStream:nil didReceiveMessage:msg];
                }
                
            }
        }];
    }
    
    return _eventSource;
}

+ (NSString *)getString:(id)json {
    if (json && ![json isKindOfClass:[NSNull class]]) {
        NSString *string = [NSString stringWithFormat:@"%@", json];
        return string;
    } else {
        return @"";
    }
}
//获取今日日期
+ (NSString *)getCurrentDay
{
    NSDate *date = [NSDate date];
    NSDateFormatter *fomater =[[NSDateFormatter alloc] init];
    [fomater setDateFormat:@"yyyy-MM-dd"];
    
    NSString * timeString = [fomater stringFromDate:date];
    
    return timeString;
}
- (void)dealEventSourceMessageWithDict:(NSDictionary *)dict
{
    NSLog(@"=====第二通道:%@" ,dict);
    NSString* type = [JXXMPP getString:dict[@"attributes"][@"type"]];
//    NSString* read = [[message attributeForName:@"read"] stringValue];
    NSString* messageId = [JXXMPP getString:dict[@"attributes"][@"id"]];

    NSString *body = nil;
    NSArray *children = [NSArray arrayWithArray:dict[@"children"]];
    for (NSDictionary *tempDic in children) {
        if ([tempDic[@"name"] isEqual:@"body"]) {
            body = [JXXMPP getString:tempDic[@"cData"]];
            //&quot;替换成\"
            body = [body stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            
        }
    }
    NSString *fromUserId=[self getUserId:[JXXMPP getString:dict[@"attributes"][@"from"]]];
    NSString *toUserId=[self getUserId:[JXXMPP getString:dict[@"attributes"][@"to"]]];


    
    if(![blackList containsObject:fromUserId]){ //排除黑名单，未对黑名单处理
        //将字符串转为字典
        NSDictionary* resultObject = [body mj_JSONObject];
//        [resultParser release];
        
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        if([type isEqualToString:@"chat"] || [type isEqualToString:@"groupchat"]){
            //创建message对象
            msg.messageId    = [messageId copy];
            //            msg.timeSend     = [NSDate date];//接收消息一律以本机时间为准，才不会乱序
            if(msg.messageId == nil)
                msg.messageId = [resultObject objectForKey:@"messageId"];

            if (self.enableMsgIQ) {
                [self sendXMPPIQ:(NSString *)msg.messageId];
            }
            
            //保存收到每一条消息的messageId，并保存到_poolSendIQ
            [msg fromDictionary:resultObject];
            
            if ([fromUserId isEqualToString:MY_USER_ID]) {
                msg.isMultipleRelay = YES;
            }else {
                msg.isMultipleRelay = NO;
            }
            
            if ([msg.content isKindOfClass:[NSDictionary class]]) {
                
                msg.content = [msg.content mj_JSONString];
            }
            
            
            // 已过期的消息不处理
            if (([msg.deleteTime timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) && [msg.deleteTime timeIntervalSince1970] > 0) {
                return;
            }
            
            if ([type isEqualToString:@"chat"] && msg.fromUserId && msg.toUserId && [msg.fromUserId isEqualToString:msg.toUserId]) {
                NSString *from = [JXXMPP getString:dict[@"attributes"][@"from"]];
                NSRange range = [from rangeOfString:@"/"];
                NSString *device = [from substringFromIndex:range.location + 1];
                if ([device isEqualToString:@"android"]) {
                    msg.fromUserId = ANDROID_USERID;
                    fromUserId  = ANDROID_USERID;
                }
                if ([device isEqualToString:@"pc"]) {
                    msg.fromUserId = PC_USERID;
                    fromUserId  = PC_USERID;
                }
                if ([device isEqualToString:@"mac"]) {
                    msg.fromUserId = MAC_USERID;
                    fromUserId  = MAC_USERID;
                }
                if ([device isEqualToString:@"web"]) {
                    msg.fromUserId = WEB_USERID;
                    fromUserId  = WEB_USERID;
                }
            }
            msg.fromId       = fromUserId;
            msg.toId         = toUserId;
            
            if([msg.toUserId intValue]<=0)
                msg.toUserId     = toUserId;
            if([msg.fromUserId intValue]<=0)//如果是群聊，则获取正确的fromUserId
                msg.fromUserId   = fromUserId;
            
            if ([msg.fromUserName isKindOfClass:[NSString class]]) {
                if([msg.fromUserName length]>0 && [type isEqualToString:@"chat"] && ![msg.fromUserId isEqualToString:MY_USER_ID]){//保存陌生人信息：
                    [self saveFromUser:msg];
                }
            }
            
            if ([msg.type intValue] == kWCMessageTypeMultipleLogin) {
                NSLog(@"200消息=====fromId:%@",msg.fromId);
                
            }else {
                if ([type isEqualToString:@"groupchat"]) {
                    msg.isGroup = YES;
//                    if (x) {
//                        msg.isDelay = YES;
//                    }
                    
                    msg.isDelay      = YES;
                }else {
                    msg.isGroup = NO;
                    msg.isDelay      = YES;
                }
//                [g_multipleLogin relaySendMessage:message msg:msg];
            }
            
            if ([msg.type integerValue] == kWCMessageTypeUpdateUserInfoSendToServer) {
                //其他端更改用户信息
                [g_notify postNotificationName:kXMPPMessageUpdateUserInfo_WHNotification object:nil];
            }
            
            if ([msg.type integerValue] == kWCMessageTypeBankCardTrans) {
                //银行卡转账状态消息
                [g_notify postNotificationName:kXMPPMessageBankCardTrans_WHNotification object:msg];
            }
            
            if ([msg.type integerValue] == kWCMessageTypeH5PaymentReturn) {
                //h5充值状态消息
                [g_notify postNotificationName:kXMPPMessageH5Payment__WHNotification object:msg];
            }
            
            //判断是否为已读类型
            if ([msg.type intValue] == kWCMessageTypeIsRead){
//                [self sendMsgReceipt:message];//收到已读消息后，发回执，确认收到
                BOOL isHave = [msg haveTheMessage];
                BOOL inserted = NO;
                if ([type isEqualToString:@"chat"]) {
                    inserted = [msg insert:nil];
                }else {
                    msg.isGroup  = YES;
                    msg.toUserId = fromUserId;
                    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
                        return;
                    }
                    inserted = [msg insert:fromUserId];
                }
                if (inserted) {
//                    if(![msg.fromUserId isEqualToString:MY_USER_ID]){//假如是我发送的，则以收到回执为准
                        if (isHave) {
                            return;
                        }
                        [msg updateIsReadWithContent];
                        [g_notify postNotificationName:kXMPPMessageReadType_WHNotification object:msg];//发送方收到已读类型，改变消息图片为已读
//                        if (!msg.isGroup) {
                        
                        // 阅后即焚：对方查看了我发送的阅后即焚消息，收到已读回执后删除阅后即焚消息
                    NSString *fetchUserId;
                    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
                        fetchUserId = msg.toUserId;
                    }else {
                        fetchUserId = msg.fromUserId;
                    }
                            NSMutableArray *arr = [[WH_JXMessageObject sharedInstance] fetchAllMessageListWithUser:fetchUserId];
                            for (NSInteger i = 0; i < arr.count; i ++) {
                                WH_JXMessageObject * p = [arr objectAtIndex:i];
                                if ([p.messageId isEqualToString:msg.content]) {
                                    if ([p.isReadDel boolValue]) {
                                        if ([p.type intValue] == kWCMessageTypeImage || [p.type intValue] == kWCMessageTypeVoice || [p.type intValue] == kWCMessageTypeVideo || [p.type intValue] == kWCMessageTypeText) {
                                            
                                            if ([p.fromUserId isEqualToString:MY_USER_ID]) {
                                                WH_JXMessageObject *newMsg = [[WH_JXMessageObject alloc] init];
                                                newMsg.isShowTime = NO;
                                                newMsg.messageId = msg.content;
                                                if(![type isEqualToString:@"chat"]){
                                                    newMsg.isGroup = YES;
                                                    msg.toUserId = fromUserId;
                                                }else {
//                                                    [self sendMsgReceipt:message];
                                                }
                                                newMsg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                                                newMsg.content = Localized(@"JX_OtherLookedYourReadingMsg");
                                                newMsg.fromUserId = msg.fromUserId;
                                                newMsg.toUserId = msg.toUserId;
                                                [newMsg update];
                                                [newMsg updateLastSend:UpdateLastSendType_None];
                                                msg = nil;
                                            }else {
                                                [p delete];
                                            }
                                            
                                        }
                                    }
                                }
//                            }
                            
                        }
                        
//                    }
                }
                return;
            }
            
            if(msg.type != nil ){
                // 判断是否是撤回消息
                if ([msg.type intValue] == kWCMessageTypeWithdraw || [msg.type intValue] == kWCMessageTypeWithdrawWithServer) {
                    
                    WH_JXMessageObject *newMsg = [[WH_JXMessageObject alloc] init];
                    newMsg.isShowTime = NO;
                    newMsg.messageId = msg.content;
                    if(![type isEqualToString:@"chat"]){
                        newMsg.isGroup = YES;
                        msg.toUserId = fromUserId;
                    }else {
//                        [self sendMsgReceipt:message];
                    }
                    newMsg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
                        newMsg.content = Localized(@"JX_AlreadyWithdraw");
                    }else {
                        newMsg.content = [NSString stringWithFormat:@"%@%@",msg.fromUserName, Localized(@"JX_OtherWithdraw")];
                    }
                    newMsg.fromUserId = msg.fromUserId;
                    newMsg.toUserId = msg.toUserId;
                    newMsg.timeSend = msg.timeSend;
                    WH_JXMessageObject *msg1 = [newMsg getMsgWithMsgId:msg.content];
                    if (msg1 && [msg1.type integerValue] != kWCMessageTypeRemind) {
                        [newMsg updateLastSend:UpdateLastSendType_None];
                        [g_notify postNotificationName:kXMPPMessageWithdraw_WHNotification object:newMsg];
                    }
                    [newMsg update];
                    msg = nil;
                    return;
                }
                
                //设备/ip禁用
                if ([msg.type intValue] == kWCMessageTypeDisable) {
                    [GKMessageTool showText:@"当前设备/IP被禁用！"];
                    [g_server logout:g_myself.areaCode toView:self];
                }
                // 分享消息
                if ([msg.type intValue] == kWCMessageTypeShare) {
                    msg.content = [NSString stringWithFormat:@"[%@]",Localized(@"JXLink")];
                }
                // 转账已被领取消息
                if ([msg.type intValue] == kWCMessageTypeTransferReceive) {
                    [g_notify postNotificationName:kXMPPMessageTransferReceive_WHNotification object:msg];
                }
                // 转账已被退回消息
                if ([msg.type intValue] == kWCMessageTypeTransferBack) {
                    [g_notify postNotificationName:kXMPPMessageTransferBack_WHNotification object:msg];
                }
                // 扫码支付款
                if ([msg.type intValue] == kWCMessageTypePaymentOut || [msg.type intValue] == kWCMessageTypeReceiptOut ||[msg.type intValue] == kWCMessageTypePaymentGet ||[msg.type intValue] == kWCMessageTypeReceiptGet) {
                    [g_notify postNotificationName:kXMPPMessageQrPayment_WHNotification object:msg];
                }
                
                if([type isEqualToString:@"chat"]){
                    //单聊发送回执：
                    if (![fromUserId isEqualToString:MY_USER_ID]) {
//                        [self sendMsgReceipt:message];
                    }
                    // 判断是否是正在输入
                    if ([msg.type intValue] == kWCMessageTypeRelay) {
                        [g_notify postNotificationName:kXMPPMessageEntering_WHNotification object:msg];
                        msg = nil;
                        return;
                    }
                    // 点赞 & 评论
                    if ([msg.type intValue] == kWCMessageTypeWeiboPraise || [msg.type intValue] == kWCMessageTypeWeiboComment || [msg.type intValue] == kWCMessageTypeWeiboRemind) {
                        
//                        WH_JXUserObject* obj = [[WH_JXUserObject sharedUserInstance] getUserById:msg.fromUserId];
                        
                        NSArray *allFriend = [[WH_JXUserObject sharedUserInstance] WH_fetchAllFriendsFromLocal];
                        
                        NSArray *serverFriend = [[WH_JXUserObject sharedUserInstance] WH_fetchSystemUser];
                        
                        Boolean isServer = NO; //是否为公众号
                        Boolean isSystemTo = NO; //是否接受者是公众号
                        for (int i = 0; i < serverFriend.count; i++) {
                            WH_JXUserObject *user = serverFriend[i];
                            if ([user.userId isEqualToString:msg.fromUserId]) {
                                isServer = YES;
                            }
                            if ([user.userId isEqualToString:msg.toUserId]) {
                                isSystemTo = YES;
                            }
                        }
                        
                        Boolean isFriendFrom = NO;
                        Boolean isFriendTo = NO;
                        
                        for (NSInteger i = 0; i < allFriend.count; i ++) {
                            WH_JXFriendObject *friend = allFriend[i];
                            if ([friend.userId isEqualToString:msg.fromUserId]) {
                                isFriendFrom = YES;
                            }
                        }
                        
                        if ([msg.toUserId integerValue] == 0) {
                            isFriendTo = YES;
                        }else{
                            for (NSInteger i = 0; i < allFriend.count; i ++) {
                                WH_JXFriendObject *friend = allFriend[i];
                                if ([friend.userId isEqualToString:msg.toUserId]) {
                                    isFriendTo = YES;
                                }
                            }
                        }
                        
                        NSLog(@"isFriendFrom:%hhu isFriendTo:%hhu myUserId:%@",isFriendFrom ,isFriendTo ,MY_USER_ID);
                        if ((isFriendFrom && isSystemTo) || (isServer && [msg.toUserId isEqualToString:MY_USER_ID]) || (isServer && isFriendTo) ||(isFriendFrom && [msg.toUserId isEqualToString:MY_USER_ID]) || (isFriendFrom && isFriendTo)) {
                            JXBlogRemind *br = [[JXBlogRemind alloc] init];
                            [br fromObject:msg];
                            [br insertObj];
                            [g_notify postNotificationName:kXMPPMessageWeiboRemind_WHNotification object:msg];
                            msg = nil;
                        }
                        
//                        NSString *toUserId = msg.toUserId;
//                        //yzk添加过滤,过滤非自己好友发布的点赞评论(fromUserId是自己的好友,toUserId是自己)
//                        if (obj != nil && [toUserId isEqualToString:MY_USER_ID]) {
//                            JXBlogRemind *br = [[JXBlogRemind alloc] init];
//                            [br fromObject:msg];
//                            [br insertObj];
//                            [g_notify postNotificationName:kXMPPMessageWeiboRemind_WHNotification object:msg];
//                            msg = nil;
//                        }
                        
//                        NSMutableArray *friendArray = [[WH_JXUserObject sharedUserInstance] WH_fetchAllFriendsFromLocal];
//                        if ([friendArray containsObject:msg.fromUserId]) {
//                            //好友关系
//                            NSLog(@"好友关系");
//                            NSString *toUserId = msg.toUserId;
//                            //yzk添加过滤,过滤非自己好友发布的点赞评论(fromUserId是自己的好友,toUserId是自己)
//                            if (obj != nil && [toUserId isEqualToString:MY_USER_ID]) {
//                                JXBlogRemind *br = [[JXBlogRemind alloc] init];
//                                [br fromObject:msg];
//                                [br insertObj];
//                                [g_notify postNotificationName:kXMPPMessageWeiboRemind_WHNotification object:msg];
//                                msg = nil;
//                            }
//
//                        }
                        
                        return;
                    }
                    // 加好友消息
                    if([msg isAddFriendMsg]){
                        if ([msg.type intValue] == XMPP_TYPE_CONTACTREGISTER) {
                            [g_notify postNotificationName:kMsgComeContactRegister object:msg];
                        }else {
                            [self doReceiveFriendRequest:msg];
                        }
                        return;
                    }
                    
                    // 面对面建群通知
                    if ([msg.type integerValue] == kRoomRemind_FaceRoomSearch) {
                        [g_notify postNotificationName:kMsgRoomFaceNotif object:msg];
                        return;
                    }
                    
                    //群文件：
                    if([msg.type intValue] == kWCMessageTypeGroupFileUpload || [msg.type intValue] == kWCMessageTypeGroupFileDelete || [msg.type intValue] == kWCMessageTypeGroupFileDownload){
                        [msg doGroupFileMsg];
                        return;
                    }
                    //清空双方聊天记录
                    if ([msg.type intValue] == kWCMessageTypeDelMsgTwoSides) {
                        WH_JXMessageObject *msg1 = [[WH_JXMessageObject alloc] init];
                        msg1.toUserId = msg.fromUserId;
                        [msg1 deleteAll];
                        msg1.type = [NSNumber numberWithInt:1];
                        msg1.content = @" ";
                        [msg1 updateLastSend:UpdateLastSendType_None];
                        [msg1 notifyMyLastSend];
                        [g_server WH_emptyMsgWithTouserId:msg1.fromUserId type:[NSNumber numberWithInt:0] toView:self];
                        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
                    }
                    
                    //清空群聊天记录(后台控制)
                    if ([msg.type integerValue] == kRoomRemind_ClearRoomChatRecord) {
                        if (msg.objectId) {
                            [[WH_JXMessageObject sharedInstance] clearMessageWithUser:msg.objectId clearChatTime:msg.timeSend];
                        }
                        //通知聊天页刷新数据
                        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
                        [g_notify postNotificationName:kClearRoomChatRecord object:msg.objectId];
                        return;
                    }
                    
                    if (![msg haveTheMessage]) {
                        BOOL isRoomControlMsg = msg.isRoomControlMsg;
                        BOOL isInsert = [msg insert:nil];//在保存时检测MessageId是否已存在记录
                        if (isRoomControlMsg && !isInsert) {
                            return;
                        }

                        [msg updateLastSend:UpdateLastSendType_Add];
                        [msg notifyNewMsg];//在显示时检测MessageId是否已显示
                    }
                }else{
                    
                    //清空群聊天记录(后台控制)
                    if ([msg.type integerValue] == kRoomRemind_ClearRoomChatRecord) {
                        return;
                    }
                    
                    //群文件：
                    if([msg.type intValue] == kWCMessageTypeGroupFileUpload || [msg.type intValue] == kWCMessageTypeGroupFileDelete || [msg.type intValue] == kWCMessageTypeGroupFileDownload){
                        [msg doGroupFileMsg];
                        return;
                    }
                    
                    if ([msg.type intValue] == kWCMessageTypeTwoWayWithdrawal) {
                        //双向撤回
                        NSLog(@"=====双向撤回");
                        WH_JXMessageObject *msgObj = [[WH_JXMessageObject alloc] init];
                        msgObj.isGroup = YES;
                        
                        NSError *err;
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                        if (dict) {
                            NSString *roomJidStr = [dict objectForKey:@"roomJid"]?:@"";
                            WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:roomJidStr];
                            msg.toUserId = user.userId;
                            [msg deleteAll];
                            
                            msgObj.type = [NSNumber numberWithInt:1];
                            msgObj.content = @" ";
                            [msgObj updateLastSend:UpdateLastSendType_None];
                            [msg notifyMyLastSend];
                            
                            [[JXSynTask sharedInstance] deleteTaskWithRoomId:user.roomId];
                            [g_server WH_ClearGroupChatHistoryWithRoomId:user.roomId toView:self];
                            
                            [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
                            [g_notify postNotificationName:@"kReadDelRefreshNotif" object:roomJidStr];
                        }
                    }
                    
                    msg.isGroup  = YES;
                    BOOL isRoomControlMsg = msg.isRoomControlMsg;
                    if(!isRoomControlMsg)
                        msg.toUserId = fromUserId;

//                    if(![msg.fromUserId isEqualToString:MY_USER_ID]){
                    
                    //如果是回复消息要将objectId字典转为字符串存入数据库
                    if ([msg.type intValue] == kWCMessageTypeReply) {
                        if ([msg.objectId isKindOfClass:[NSDictionary class]]) {
                            NSString *dicStr = [msg.objectId mj_JSONString];
                            msg.objectId = dicStr;
                        }
                    }
                    if(![msg insert:fromUserId]){ //在保存时检测MessageId是否已存在记录
                        if (isRoomControlMsg) {
                            return;
                        }
                        msg.isRepeat = YES;
                    }else {
                        [msg updateLastSend:UpdateLastSendType_Add];
                    }
                    
                    if (msg.type.integerValue == kWCMessageTypeRemind) {
                        //公告类型,判断是否为强提醒公告
                        @try{
                            NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                            if (![[NSString stringWithFormat:@"%@",jsonObj[@"fromUserId"]] isEqualToString:g_myself.userId]) {
                                //不是自己发送的
                                if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                                    NSDictionary *content = jsonObj[@"content"];
                                    if ([content isKindOfClass:[NSDictionary class]]) {
                                        if ([content[@"noticeType"] intValue] == 1) {
                                            //强提醒公告
                                            NSString *objectId = jsonObj[@"objectId"];
                                            NSNumber *isCloseStrongReminder = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_group_strong_reminder_%@",g_myself.userId,objectId]];
                                            BOOL isClose = [isCloseStrongReminder boolValue];
                                            if (!isClose) {
                                                //未打开关闭强提醒,弹出弹框
                                                WH_StrongReminderView *strongReminderView = [[WH_StrongReminderView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                strongReminderView.wh_name = content[@"nickname"];
                                                
                                                NSString *userId = [NSString stringWithFormat:@"%@",content[@"userId"]];
                                                NSString* dir  = [NSString stringWithFormat:@"%lld",[userId longLongValue] % 10000];
                                                NSString* urlString  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",[share_defaults objectForKey:kDownloadAvatarUrl],dir,userId];
                                                strongReminderView.wh_headUrl = urlString;
                                                strongReminderView.wh_notice = content;
                                                strongReminderView.entryGroupCallback = ^(WH_StrongReminderView *reminderView){
                                                    //关闭强提醒窗口
                                                    [reminderView wh_close];
                                                    //点击进入群聊
                                                    [WH_JXChat_WHViewController gotoChatViewController:objectId];
                                                };
                                                [strongReminderView setupUI];
                                                [[UIApplication sharedApplication].keyWindow addSubview:strongReminderView];
                                                [strongReminderView wh_show];
                                            }
                                        }
                                    }
                                }
                            }
                        } @catch(NSException *e){}
                    }
                    
                    
                    [msg notifyNewMsg];
//                    }
                    
                }
            }
        }
        
        msg = nil;
    }
}

- (void)dealloc
{
    [blackList removeAllObjects];
//    [blackList release];
//    [_db close];
//    [_db release];
	[self teardownStream];
//    [roomPool release];
    [_poolSend removeAllObjects];
//    [_poolSend release];
//    [password release];
//    [super dealloc];
    [g_notify removeObserver:self name:kCellReadDelNotification object:nil];
}

-(void)login{
    
    
    AppleReachability *reach = [AppleReachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reach currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:{
            if (self.isLogined != login_status_no) {
                [self logout];
            }
        }
            break;
            
        default:{
            
            self.isReconnect = YES;
            pingTimeoutCount = 0;
            if(isLogined == login_status_yes)
                return;
            if (![self connect]) {
                //        [g_App showAlert:@"服务器连接失败,本demo服务器非24小时开启，若急需请QQ 287076078"];
            };
            
        }
            break;
    }
    
    
}

-(void)doLogin{
    NSLog(@"XMPP开始登录");
    self.newMsgAfterLogin = 0; //重新登陆后，新消息要置0
    pingTimeoutCount = 0;
    self.isCloseStream = NO;
    [FileInfo createDir:myTempFilePath];
    [self goOnline];
    [xmppRoster fetchRoster];//获取花名册
    self.isLogined = login_status_yes;
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self.roomPool createAll];
//    });

    [self notify];
    
    [self enableIQ];
    if (IS_OPEN_SecondChannel) {
         [self.eventSource connect:@""];
         [g_server syncMessages:nil orDelete:@"false" withUrl: [NSString stringWithFormat:@"%@:8095/messages/sync" ,[self backUrl]] toView:self];
     }
}



-(void)logout{
    if(!isLogined)
        return;
    
    NSLog(@"isLogined = %d", self.isLogined);
    if (self.isLogined == login_status_yes) {
        g_server.lastOfflineTime = [[NSDate date] timeIntervalSince1970];
        [g_default setObject:[NSNumber numberWithLongLong:g_server.lastOfflineTime] forKey:kLastOfflineTime];
        [g_default synchronize];
    }
    
    self.isLogined = login_status_no;
    [self notify];
    self.newMsgAfterLogin = 0;
	isXmppConnected = NO;
    [self disconnect];
    [roomPool deleteAll];
    
    if (IS_OPEN_SecondChannel) {
        [self.eventSource disconnect:@""];
        
        NSString *urlStr = @"";
        NSString *urlPath = @"";
        NSString *apiUrl = g_config.apiUrl?:@"";
        if ([apiUrl hasSuffix:@"/"]) {
            urlStr = [apiUrl substringToIndex:[apiUrl length] - 1];
        }else{
            urlStr = apiUrl;
        }
                
        if ([urlStr rangeOfString:@":"].location != NSNotFound) {
        //包含有端口号
                    
            NSString *lowerStr = [urlStr lowercaseString]; //将所有字符串内容转为小写
                    
            NSArray *strArray = [urlStr componentsSeparatedByString:@":"];
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:strArray];
            if ([lowerStr hasPrefix:@"http://"] || [lowerStr hasPrefix:@"https://"]) {
                if (array.count > 2) {
                    [array removeObjectAtIndex:array.count -1];
                 }
            }else{
                [array removeObjectAtIndex:array.count -1];
            }
            urlPath = [array componentsJoinedByString:@":"];
        }else{
            urlPath = urlStr;
        }
        [self.eventSource closeEventSourceWithHost:[NSString stringWithFormat:@"%@:8095" ,urlPath] token:g_server.access_token];
    }
    
}

#pragma mark 向服务器发开启批量回执消息
- (void)enableIQ  {
    // 向服务器发开启消息
    XMPPIQ *xmppIQ = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:g_config.XMPPDomain] elementID:[xmppStream generateUUID]];
    NSXMLElement * xmlns = [NSXMLElement elementWithName:@"enable" xmlns:@"xmpp:tig:ack"];
    xmlns.stringValue = @"enable";
//    [xmppIQ addChild:xmlns];
    [xmppIQ WH_addChild:xmlns];
    
    [xmppStream sendElement:xmppIQ];
    NSLog(@"xmppIQ = %@",xmppIQ);
}

//开启消息压缩
- (void)enableCompression
{
    NSXMLElement *compress = [NSXMLElement elementWithName:@"compress"];
    [compress addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/compress"];
    NSXMLElement *method = [NSXMLElement elementWithName:@"method"];
    [method setStringValue:@"zlib"];
    [compress WH_addChild:method];
    
    NSLog(@"========%@",[compress XMLString]);
    [xmppStream sendElement:compress];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
#pragma mark 暂停消息回执
    //    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
    if ([[iq stringValue] rangeOfString:@"enable"].location != NSNotFound) {
      NSLog(@"收到iq:%@",iq);
      self.enableMsgIQ = YES;
      self.IQTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendIQ:) userInfo:nil repeats:YES];
    }
    return NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma  mark ------------发消息------------
- (void)sendMessage:(WH_JXMessageObject*)msg roomName:(NSString*)roomName
{
    
    // 普通消息设置重发次数
    if (msg.isVisible && msg.sendCount <= 0) {
        msg.sendCount = 5;
    }
    //采用SBjson将params转化为json格式的字符串
    //    msg.roomJid = roomName;
    if([msg.messageId length]<=0)//必须有
        [msg setMsgId];
    if ([g_myself.isEncrypt intValue] == 1) {
        msg.isEncrypt = [NSNumber numberWithInt:YES];
    }else{
        msg.isEncrypt = [NSNumber numberWithInt:NO];
    }
    
    // 消息发送时间更新
    NSTimeInterval time = [msg.timeSend timeIntervalSince1970];
    msg.timeSend = [NSDate dateWithTimeIntervalSince1970:(time *1000 + g_server.timeDifference)/1000];
    
    // 直接发给此账号的其他端
    if ([msg.toUserId rangeOfString:[NSString stringWithFormat:@"%@_" ,MY_USER_ID]].location != NSNotFound && msg.toUserId.length > [MY_USER_ID length]) {
        NSString *relayUserId = msg.toUserId;
        msg.toUserId = MY_USER_ID;
        [self relaySendMessage:msg relayUserId:relayUserId roomName:nil];
        
        return;
    }
    
    if (!roomName || roomName.length <= 0) {
        // 多点登录转发给其他端
        [g_multipleLogin relaySendMessage:nil msg:msg];
    }

    NSDictionary *jsonDic = [msg toDictionary];
    NSString *jsonString = [jsonDic mj_JSONString];
    
    XMPPMessage *aMessage;
    NSString* from = [NSString stringWithFormat:@"%@@%@",msg.fromUserId,g_config.XMPPDomain];
    if(roomName == nil){
        NSString* to = [NSString stringWithFormat:@"%@@%@",msg.toUserId,g_config.XMPPDomain];
        aMessage=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:to]];
        to   = nil;
    }
    else{
        NSString* roomJid = [NSString stringWithFormat:@"%@@muc.%@",roomName,g_config.XMPPDomain];
        aMessage=[XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomJid]];
        roomJid = nil;
    }
    [aMessage addAttributeWithName:@"id" stringValue:msg.messageId];

//    if ([g_config.isOpenReceipt boolValue] || [msg.type intValue] == kWCMessageTypeMultipleLogin) {
    
        NSXMLElement * request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
        [aMessage WH_addChild:request];
        request = nil;
//    }

    DDXMLNode* node = [DDXMLNode elementWithName:@"body" stringValue:jsonString];
    [aMessage WH_addChild:node];
    node = nil;

//    NSLog(@"sendMessage:%@,%@",msg.messageId,jsonString);
    [xmppStream sendElement:aMessage];
    NSLog(@">>>>>>>>>>>发送消息:%@_ios,%@",MY_USER_ID,aMessage);
    
    //判断消息是否为已读类型
    if ([msg.type intValue] == kWCMessageTypeIsRead) {
        bool found = NO;
        //不重复添加
        for (WH_JXMessageObject * msgObj in _poolSendRead){
            if ([msgObj.messageId isEqualToString: msg.messageId]){
                found = YES;
                break;
            }
        }
        if (!found) {
            [_poolSendRead addObject:msg];
        }
    }else{
        // 排除发送正在输入
        if ([msg.type intValue] != kWCMessageTypeRelay){
            
            [_poolSend setObject:msg forKey:msg.messageId];
        }
    }
    AppleReachability *reach = [AppleReachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reach currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:{
            
            [msg updateIsSend:transfer_status_no];
            if (![msg.fromUserId isEqualToString:msg.toUserId]) {
                if ([msg.type intValue] != kWCMessageTypeAVPing) {
                    [msg notifyTimeout];//重发次数为0,才发超时通知
                }
            }
        }
            break;
            
        default:
            //超时后若还收不到回执,就更新界面显示超时
            
            [self performSelector:@selector(WH_onSendTimeout:) withObject:msg afterDelay:[msg getMaxWaitTime]];
            break;
    }
    
    from = nil;
}


#pragma  mark ------------多点登录转发发消息------------
- (void)relaySendMessage:(WH_JXMessageObject*)msg relayUserId:(NSString *)relayUserId roomName:(NSString*)roomName
{
    // 普通消息设置重发次数
    if (msg.isVisible && msg.sendCount <= 0) {
        msg.sendCount = 5;
    }
    //采用SBjson将params转化为json格式的字符串
    //    msg.roomJid = roomName;
    if([msg.messageId length]<=0)//必须有
        [msg setMsgId];
    if ([g_myself.isEncrypt intValue] == 1) {
        msg.isEncrypt = [NSNumber numberWithInt:YES];
    }else{
        msg.isEncrypt = [NSNumber numberWithInt:NO];
    }
    
    NSString * jsonString = [[msg toDictionary] mj_JSONString];
    
    NSRange range = [relayUserId rangeOfString:@"_"];
    NSString *relayType = @"";
    if (range.length != 0) {
        relayType = [relayUserId substringFromIndex:range.location + 1];
    }else{
        relayType = @"1";
    }
    XMPPMessage *aMessage;
    NSString* from = [NSString stringWithFormat:@"%@@%@",msg.fromUserId,g_config.XMPPDomain];
    if(roomName == nil){
        NSString* to = [NSString stringWithFormat:@"%@@%@/%@",g_myself.userId,g_config.XMPPDomain,relayType];
        aMessage=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:to]];
        to   = nil;
    }
    else{
        NSString* roomJid = [NSString stringWithFormat:@"%@@muc.%@",roomName,g_config.XMPPDomain];
        aMessage=[XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomJid]];
        roomJid = nil;
    }
    [aMessage addAttributeWithName:@"id" stringValue:msg.messageId];
    
//    if ([g_config.isOpenReceipt boolValue] || [msg.type intValue] == kWCMessageTypeMultipleLogin) {
    
        NSXMLElement * request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
        [aMessage WH_addChild:request];
        request = nil;
//    }
    
    DDXMLNode* node = [DDXMLNode elementWithName:@"body" stringValue:jsonString];
    [aMessage WH_addChild:node];
    node = nil;
    
    [xmppStream sendElement:aMessage];
    NSLog(@">>>>>>>>>>>转发消息:%@,%@",relayUserId,aMessage);
    //判断消息是否为已读类型
    if ([msg.type intValue] == kWCMessageTypeIsRead) {
        bool found = NO;
        //不重复添加
        for (WH_JXMessageObject * msgObj in _poolSendRead){
            if ([msgObj.messageId isEqualToString: msg.messageId]){
                found = YES;
                break;
            }
        }
        if (!found) {
            [_poolSendRead addObject:msg];
        }
    }else{
        // 排除发送正在输入
        if ([msg.type intValue] != kWCMessageTypeRelay){
            if ([msg.fromUserId isEqualToString:msg.toUserId]) {
                msg.toUserId = relayUserId;
            }
            
            [_poolSend setObject:msg forKey:msg.messageId];
        }
    }
    
    [self performSelector:@selector(WH_onSendTimeout:) withObject:msg afterDelay:[msg getMaxWaitTime]];
    from = nil;
}

-(void)sendMessageInvite:(WH_JXMessageObject *)msg{
    [_poolSend setObject:msg forKey:msg.messageId];
    [self performSelector:@selector(WH_onSendTimeout:) withObject:msg afterDelay:[msg getMaxWaitTime]];
}

/*
-(void)sendMsgIsRead{
    if([g_xmpp.poolSendRead count] == 0|| g_xmpp.poolSendRead == nil)
        return;
    
    for (int i = 0; i < [g_xmpp.poolSendRead count]; i++) {
        WH_JXMessageObject * msg = g_xmpp.poolSendRead[i];
        if (msg.sendCount>0){//一般只重发3次，在发之前赋值3
            msg.sendCount--;
            [g_xmpp sendMessage:msg roomName:nil];
        }
        else
            [g_xmpp.poolSendRead removeObject:msg];
    }
}
*/

-(void)WH_onSendTimeout:(WH_JXMessageObject *)p{//超时未收到回执
    
    //过滤池子中不存在msg对象,解决重发问题
    WH_JXMessageObject*obj = [_poolSend objectForKey:p.messageId];
    if (!obj) {
        return;
    }
    
    if([p.isSend isEqualToNumber:[NSNumber numberWithInt:transfer_status_yes]])
        return;
    [p updateIsSend:transfer_status_ing];
    if(p.sendCount>0){//一般只重发3次，在发之前赋值3
        NSLog(@"超时未收到回执重发开始执行 msg->%@--messageId->%@--sendCount--%ld",p,p.messageId,(long)p.sendCount);
        [self login];
        NSString* roomJid=nil;
        if(p.isGroup)
            roomJid = p.toUserId;
        [self sendMessage:p roomName:roomJid];
        p.sendCount--;//重发次数减1
    }else{
        
        [p updateIsSend:transfer_status_no];
        if (![p.fromUserId isEqualToString:p.toUserId]) {
            if ([p.type intValue] != kWCMessageTypeAVPing) {
                [p notifyTimeout];//重发次数为0,才发超时通知
            }
        }
    }
    
}

#pragma mark --------配置XML流---------
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
        xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
    
    // 设置发送心跳包
    xmppAutoPing = [[XMPPAutoPing alloc] init];
    xmppAutoPing.pingInterval = g_config.XMPPPingTime;   // 心跳包发送时间间隔
    [xmppAutoPing activate:xmppStream];
    [xmppAutoPing addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
	
    // 自动重连
    xmppReconnect = [[XMPPReconnect alloc] init];
    xmppReconnect.autoReconnect = YES;
    xmppReconnect.reconnectDelay = 0.f;
    xmppReconnect.reconnectTimerInterval = 3.0;
	
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    
//    if (![g_config.isOpenReceipt boolValue]) {
//        // 创建流状态缓存对象
//        _streamStorage = [[XMPPStreamManagementPersistentStorage alloc] init];
//        // 创建流管理对象
//        _xmppStreamManagement = [[XMPPStreamManagement alloc] initWithStorage:_streamStorage];
//        // 设置自动恢复
//        [_xmppStreamManagement setAutoResume:YES];
//        // 设置代理和返回队列
//        [_xmppStreamManagement addDelegate:self delegateQueue:dispatch_get_main_queue()];
//        [_xmppStreamManagement requestAck];
//        [_xmppStreamManagement automaticallyRequestAcksAfterStanzaCount:1 orTimeout:10];
//        [_xmppStreamManagement automaticallySendAcksAfterStanzaCount:1 orTimeout:10];
//        // 激活模块
//        [_xmppStreamManagement activate:xmppStream];
//    }
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSLog(@"配置XML流时xmpp连接的域名（XMPPHost）和端口号（Port）%@:%ld",g_config.XMPPHost,(long)g_config.XMPPHostPort);
    xmppStream.hostName = g_config.XMPPHost;
    xmppStream.hostPort = g_config.XMPPHostPort;
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
    
    self.roomPool = [[WH_JXRoomPool alloc] init];
}

#pragma mark -- terminate
/**
 *  申请后台更多的时间来完成关闭流的任务
 */
-(void)applicationWillTerminate
{
    UIApplication *app=[UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskId;
    taskId=[app beginBackgroundTaskWithExpirationHandler:^(void){
        [app endBackgroundTask:taskId];
    }];

    [xmppStream disconnectAfterSending];
}

- (void)xmppStreamManagement:(XMPPStreamManagement *)sender wasEnabled:(NSXMLElement *)enabled {
    
}
- (void)xmppStreamManagement:(XMPPStreamManagement *)sender wasNotEnabled:(NSXMLElement *)failed {
    
}

#pragma mark - 消息回执
- (void)xmppStreamManagement:(XMPPStreamManagement *)sender didReceiveAckForStanzaIds:(NSArray<id> *)stanzaIds {
    NSLog(@"XMPPElement2 --- ");
    if ([g_config.isOpenReceipt boolValue]) {
        return;
    }
    for (NSInteger i = 0; i < stanzaIds.count; i++) {
        NSString *msgId = stanzaIds[i];
        //正常消息回执
        WH_JXMessageObject *msg   = (WH_JXMessageObject*)[_poolSend objectForKey:msgId];
//        if ([msg.type intValue] == kWCMessageTypeMultipleLogin) {
//            [g_multipleLogin upDateOtherOnline:message isOnLine:[NSNumber numberWithInt:msg.content.intValue]];
//        }
//        NSLog(@"收到回执:%@,%@",messageId,[message receiptResponseID]);
        if([msg.isSend intValue] != transfer_status_yes &&msg.messageId != nil){
            [self doSendFriendRequest:msg];
            if ([msg.type intValue] == kWCMessageTypeWithdraw || [msg.type intValue] == kWCMessageTypeWithdrawWithServer) {
                msg.content = Localized(@"JX_AlreadyWithdraw");
            }
            [msg updateLastSend:UpdateLastSendType_Add];
            [msg updateIsSend:transfer_status_yes];
            [msg notifyReceipt];
            [msg notifyMyLastSend];
            [_poolSend removeObjectForKey:msg.messageId];
        }
        
        //已读消息的回执
        if (msg == nil) {
            for (int i = 0; i < [_poolSendRead count]; i++) {
                WH_JXMessageObject * p = _poolSendRead[i];
                if ([p.messageId isEqualToString:msgId]) {
                    //对方已收到已读消息的回执
                    [p updateIsReadWithContent];
                    [g_notify postNotificationName:kXMPPMessageReadTypeReceipt_WHNotification object:p];//接收方收到已读消息的回执，改变标志避免重复发
                    [_poolSendRead removeObject:p];
                    p =nil;
                    break;
                }
            }
        }
        
        msg = nil;
        return;
    }
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    
    return YES;
}


- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	
	[xmppReconnect         deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
}

// 心跳包回调
#pragma mark - XMPPAutoPingDelegate
- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender{
    // 如果至少有1次超时了，再收到pong包，则清除超时次数
    if (pingTimeoutCount > 0) {
        pingTimeoutCount = 0;
    }
}
- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender {
    // 收到两次超时，就disconnect
    pingTimeoutCount++;
    if (pingTimeoutCount >= 2) {
        NSLog(@"xmpp ---- PingDidTimeout");
        [self logout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self login];
        });
    }
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[xmppStream sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[xmppStream sendElement:presence];
}

-(void)notify{
    [g_notify  postNotificationName:kXmppLogin_WHNotifaction object:nil];
    if (self.isLogined == login_status_yes) {
        // 上线发送消息通知其他端
        [g_multipleLogin sendOnlineMessage];
    }else {
    }
    [self loginChanged];
    if (self.isLogined != login_status_ing) {
        [_wait stop];
    }
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - XMPP连接
- (BOOL)connect
{
	if (![xmppStream isDisconnected])
		return YES;
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_ID];
//    NSString *myPassword =  [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_PASSWORD];
    NSString *myPassword = [g_default objectForKey:kMY_USER_PASSWORD];
    NSString *salt = [g_default objectForKey:kMY_USER_PASSWORDSalt];
    NSString *xmppLoginPws = [NSString string];
    if (IsStringNull(salt)) {
        xmppLoginPws = myPassword;
    }else{
        xmppLoginPws = [self getXMPPLoginPwsWith:myPassword salt:salt];
    }
//    BOOL isMultipleLogin = [[g_default objectForKey:kISMultipleLogin] boolValue];
//    BOOL isMultipleLogin = [g_myself.multipleDevices intValue] > 0 ? YES : NO;
//    BOOL isMultipleLogin = YES;
    
    NSString *sameResource = @"/youjob";
    
//    if (isMultipleLogin) {
//        sameResource = @"/ios";
//    }
    
    NSLog(@"xmpp连接的域名（XMPPHost）和端口号（Port）%@:%ld",g_config.XMPPHost,(long)g_config.XMPPHostPort);
    xmppStream.hostName = g_config.XMPPHost;
    xmppStream.hostPort = g_config.XMPPHostPort;
    
    
    NSString *myJID = [NSString stringWithFormat:@"%@@%@%@",userID,g_config.XMPPDomain,sameResource];//拼接主机名&resource
    
	if (myJID == nil || xmppLoginPws == nil || myPassword == nil) {
		return NO;
	}
    self.isLogined = login_status_ing;
    [self notify];
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];

    password = xmppLoginPws;
    
	NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
        self.isLogined = login_status_no;
        [self notify];
        NSLog(@"XMPP连接失败错误信息: %@", error);
		return NO;
	}
	return YES;
}

- (NSString *)getXMPPLoginPwsWith:(NSString *)pws salt:(NSString *)salt
{
    if (IsStringNull(salt)) {
//        [GKMessageTool showText:@"xmpp授权salt为空!"];
        return @"";
    }
    if (IsStringNull(pws)) {
//        [GKMessageTool showText:@"xmpp授权密码为空!"];
        return @"";
    }
    
    NSString *resultStr = [NSString string];
    resultStr = [resultStr stringByAppendingString:pws];
    resultStr = [resultStr stringByAppendingString:salt];

    resultStr = [g_server WH_getMD5StringWithStr:resultStr];
    
    resultStr = [salt stringByAppendingString:resultStr];
    
    resultStr = [g_server WH_getMD5StringWithStr:resultStr];
    
    resultStr = [g_server WH_getMD5StringWithStr:resultStr];
    
    return resultStr;

}

- (void)disconnect
{
    //未读上报
    [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
    // 离线前发送消息通知其他端
    [g_multipleLogin sendOfflineMessage];
    
    self.isReconnect = NO;
	[self goOffline];
//    if (self.isCloseStream && ![g_config.isOpenReceipt boolValue]) {
//        self.isCloseStream = NO;
//        [self applicationWillTerminate];
//    }else {
        [xmppStream disconnect];
//    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif

	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}
// Returns the URL to the application's Documents directory.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

//连接成功时调用
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![xmppStream authenticateWithPassword:password error:&error])
	{
        self.isLogined = login_status_no;
        [self notify];
		DDLogError(@"Error authenticating: %@", error);
        NSLog(@"XMPP授权失败错误信息:%@",error);
	}
}

//授权成功时调用
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP授权成功%@: %@",THIS_FILE, THIS_METHOD);
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self doLogin];
//    if (![g_config.isOpenReceipt boolValue]) {
//        [_xmppStreamManagement enableStreamManagementWithResumption:YES maxTimeout:60];
//        //    [_xmppStreamManagement requestAck];
//        [_xmppStreamManagement sendAck];
//    }
}

//授权失败时调用
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    if ([[error stringValue] isEqualToString:@"Password not verified"]) {
        self.isPasswordError = YES;
    }
    self.isLogined = login_status_no;
    self.isReconnect = NO;
    [self notify];
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

//- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
//{
////    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
//
////    NSLog(@"收到iq:%@",iq);
//
//
//    return NO;
//}
#pragma mark - －－－－－－－－－收到消息时调用
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"<<<<<<<<<<<收到消息: %@", message);
    NSLog(@"%@", MY_USER_ID);
        pingTimeoutCount = 0;
    
//    NSString* read = [[message attributeForName:@"read"] stringValue];
    NSString* messageId = [[message attributeForName:@"id"] stringValue];

    NSString *body = [[message elementForName:@"body"] stringValue];
    NSString *fromUserId=[self getUserId:[message fromStr]];
    NSString *toUserId=[self getUserId:[message toStr]];
    NSString* type = [[message attributeForName:@"type"] stringValue];
    if (![toUserId isEqualToString:MY_USER_ID]) {
        return;
    }


//    NSXMLElement *x = [message elementForName:@"x"];
    
//    NSLog(@"didReceiveMessage:%@,%@",messageId,body);
//    if(delay != nil && [type isEqualToString:@"groupchat"] && messageId == nil)//如果是群聊的历史消息，则忽略
//        return;
    if([message hasReceiptResponse]) {//如果是回执，则通知界面
        //正常消息回执
        NSString*receiptResponseID = [message receiptResponseID];
        WH_JXMessageObject *msg   = (WH_JXMessageObject*)[_poolSend objectForKey:receiptResponseID];
        if ([msg.type intValue] == kWCMessageTypeMultipleLogin) {
            [g_multipleLogin upDateOtherOnline:message isOnLine:[NSNumber numberWithInt:msg.content.intValue]];
        }

        if(([msg.isSend intValue] != transfer_status_yes) && (msg.messageId != nil)){
            NSLog(@"收到回执-改变状态开始 msg->%@--receiptResponseID->%@--messageId->%@",msg,receiptResponseID,msg.isSend);

            [self doSendFriendRequest:msg];
            [msg updateLastSend:UpdateLastSendType_Add];
            [msg updateIsSend:transfer_status_yes];
            [msg notifyReceipt];
            [msg notifyMyLastSend];
            

            [_poolSend removeObjectForKey:msg.messageId];
        }
        
        //已读消息的回执
        if (msg == nil) {
            for (int i = 0; i < [_poolSendRead count]; i++) {
                WH_JXMessageObject * p = _poolSendRead[i];
                if ([p.messageId isEqualToString:[message receiptResponseID]]) {
                    //对方已收到已读消息的回执
                    [p updateIsReadWithContent];
                    [g_notify postNotificationName:kXMPPMessageReadTypeReceipt_WHNotification object:p];//接收方收到已读消息的回执，改变标志避免重复发
                    [_poolSendRead removeObject:p];
                    p =nil;
                    break;
                }
            }
        }
        
        msg = nil;
        return;
    }
    
    //测试第二通道时 将下面消息处理内容隐掉
    if(![blackList containsObject:fromUserId]){ //排除黑名单，未对黑名单处理
        //将字符串转为字典
        NSDictionary* resultObject = [body mj_JSONObject];
//        [resultParser release];

        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        if([type isEqualToString:@"chat"] || [type isEqualToString:@"groupchat"]){
            //创建message对象
            msg.messageId    = [messageId copy];
            //            msg.timeSend     = [NSDate date];//接收消息一律以本机时间为准，才不会乱序
            if(msg.messageId == nil)
                msg.messageId = [resultObject objectForKey:@"messageId"];

            if (self.enableMsgIQ) {
                [self sendXMPPIQ:(NSString *)msg.messageId];
            }

            //保存收到每一条消息的messageId，并保存到_poolSendIQ
            [msg fromDictionary:resultObject];

            if ([fromUserId isEqualToString:MY_USER_ID]) {
                msg.isMultipleRelay = YES;
            }else {
                msg.isMultipleRelay = NO;
            }

            if ([msg.content isKindOfClass:[NSDictionary class]]) {

                msg.content = [msg.content mj_JSONString];
            }


            // 已过期的消息不处理
            if (([msg.deleteTime timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) && [msg.deleteTime timeIntervalSince1970] > 0) {
                return;
            }

            if ([type isEqualToString:@"chat"] && msg.fromUserId && msg.toUserId && [msg.fromUserId isEqualToString:msg.toUserId]) {
                NSString *from = [message fromStr];
                NSRange range = [from rangeOfString:@"/"];
                NSString *device = [from substringFromIndex:range.location + 1];
                if ([device isEqualToString:@"android"]) {
                    msg.fromUserId = ANDROID_USERID;
                    fromUserId  = ANDROID_USERID;
                }
                if ([device isEqualToString:@"pc"]) {
                    msg.fromUserId = PC_USERID;
                    fromUserId  = PC_USERID;
                }
                if ([device isEqualToString:@"mac"]) {
                    msg.fromUserId = MAC_USERID;
                    fromUserId  = MAC_USERID;
                }
                if ([device isEqualToString:@"web"]) {
                    msg.fromUserId = WEB_USERID;
                    fromUserId  = WEB_USERID;
                }
            }
            msg.fromId       = fromUserId;
            msg.toId         = toUserId;

            if([msg.toUserId intValue]<=0)
                msg.toUserId     = toUserId;
            if([msg.fromUserId intValue]<=0)//如果是群聊，则获取正确的fromUserId
                msg.fromUserId   = fromUserId;

            if ([msg.fromUserName isKindOfClass:[NSString class]]) {
                if([msg.fromUserName length]>0 && [type isEqualToString:@"chat"] && ![msg.fromUserId isEqualToString:MY_USER_ID]){//保存陌生人信息：
                    [self saveFromUser:msg];
                }
            }

            if ([msg.type intValue] == kWCMessageTypeMultipleLogin) {
                NSLog(@"200消息=====fromId:%@",msg.fromId);
                [self sendMsgReceipt:message];//收到200验证消息后，发回执
                [g_multipleLogin upDateOtherOnline:message isOnLine:[NSNumber numberWithInt:msg.content.intValue]];
            }else {
                if ([type isEqualToString:@"groupchat"]) {
                    msg.isGroup = YES;
//                    if (x) {
//                        msg.isDelay = YES;
//                    }

                    msg.isDelay      = [[message elementForName:@"delay"] stringValue] != nil;
                }else {
                    msg.isGroup = NO;
                    msg.isDelay      = [[message elementForName:@"delay"] stringValue] != nil;
                }
                [g_multipleLogin relaySendMessage:message msg:msg];
            }

            if ([msg.type integerValue] == kWCMessageTypeUpdateUserInfoSendToServer) {
                //其他端更改用户信息
                [g_notify postNotificationName:kXMPPMessageUpdateUserInfo_WHNotification object:nil];
            }

            if ([msg.type integerValue] == kWCMessageTypeBankCardTrans) {
                //银行卡转账状态消息
                [g_notify postNotificationName:kXMPPMessageBankCardTrans_WHNotification object:msg];
            }

            if ([msg.type integerValue] == kWCMessageTypeH5PaymentReturn) {
                //h5充值状态消息
                [g_notify postNotificationName:kXMPPMessageH5Payment__WHNotification object:msg];
            }

            //判断是否为已读类型
            if ([msg.type intValue] == kWCMessageTypeIsRead){
//                [self sendMsgReceipt:message];//收到已读消息后，发回执，确认收到
                BOOL isHave = [msg haveTheMessage];
                BOOL inserted = NO;
                if ([type isEqualToString:@"chat"]) {
                    inserted = [msg insert:nil];
                }else {
                    msg.isGroup  = YES;
                    msg.toUserId = fromUserId;
                    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
                        return;
                    }
                    inserted = [msg insert:fromUserId];
                }
                if (inserted) {
//                    if(![msg.fromUserId isEqualToString:MY_USER_ID]){//假如是我发送的，则以收到回执为准
                        if (isHave) {
                            return;
                        }
                        [msg updateIsReadWithContent];
                        [g_notify postNotificationName:kXMPPMessageReadType_WHNotification object:msg];//发送方收到已读类型，改变消息图片为已读
//                        if (!msg.isGroup) {

                        // 阅后即焚：对方查看了我发送的阅后即焚消息，收到已读回执后删除阅后即焚消息
                    NSString *fetchUserId;
                    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
                        fetchUserId = msg.toUserId;
                    }else {
                        fetchUserId = msg.fromUserId;
                    }
                            NSMutableArray *arr = [[WH_JXMessageObject sharedInstance] fetchAllMessageListWithUser:fetchUserId];
                            for (NSInteger i = 0; i < arr.count; i ++) {
                                WH_JXMessageObject * p = [arr objectAtIndex:i];
                                if ([p.messageId isEqualToString:msg.content]) {
                                    if ([p.isReadDel boolValue]) {
                                        if ([p.type intValue] == kWCMessageTypeImage || [p.type intValue] == kWCMessageTypeVoice || [p.type intValue] == kWCMessageTypeVideo || [p.type intValue] == kWCMessageTypeText) {

                                            if ([p.fromUserId isEqualToString:MY_USER_ID]) {
                                                WH_JXMessageObject *newMsg = [[WH_JXMessageObject alloc] init];
                                                newMsg.isShowTime = NO;
                                                newMsg.messageId = msg.content;
                                                if(![type isEqualToString:@"chat"]){
                                                    newMsg.isGroup = YES;
                                                    msg.toUserId = fromUserId;
                                                }else {
//                                                    [self sendMsgReceipt:message];
                                                }
                                                newMsg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                                                newMsg.content = Localized(@"JX_OtherLookedYourReadingMsg");
                                                newMsg.fromUserId = msg.fromUserId;
                                                newMsg.toUserId = msg.toUserId;
                                                [newMsg update];
                                                [newMsg updateLastSend:UpdateLastSendType_None];
                                                msg = nil;
                                            }else {
                                                [p delete];
                                            }

                                        }
                                    }
                                }
//                            }

                        }

//                    }
                }
                return;
            }

            if(msg.type != nil ){
                // 判断是否是撤回消息
                if ([msg.type intValue] == kWCMessageTypeWithdraw || [msg.type intValue] == kWCMessageTypeWithdrawWithServer) {

                    WH_JXMessageObject *newMsg = [[WH_JXMessageObject alloc] init];
                    newMsg.isShowTime = NO;
                    newMsg.messageId = msg.content;
                    if(![type isEqualToString:@"chat"]){
                        newMsg.isGroup = YES;
                        msg.toUserId = fromUserId;
                    }else {
//                        [self sendMsgReceipt:message];
                    }
                    newMsg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
                        newMsg.content = Localized(@"JX_AlreadyWithdraw");
                    }else {
                        newMsg.content = [NSString stringWithFormat:@"%@%@",msg.fromUserName, Localized(@"JX_OtherWithdraw")];
                    }
                    newMsg.fromUserId = msg.fromUserId;
                    newMsg.toUserId = msg.toUserId;
                    newMsg.timeSend = msg.timeSend;
                    WH_JXMessageObject *msg1 = [newMsg getMsgWithMsgId:msg.content];
                    if (msg1 && [msg1.type integerValue] != kWCMessageTypeRemind) {
                        [newMsg updateLastSend:UpdateLastSendType_None];
                        [g_notify postNotificationName:kXMPPMessageWithdraw_WHNotification object:newMsg];
                    }
                    [newMsg update];
                    msg = nil;
                    return;
                }
                
                if ([msg.type intValue] == kWCMessageTypeTwoWayWithdrawal) {
                    //双向撤回
                    NSLog(@"=====双向撤回");
                    WH_JXMessageObject *msgObj = [[WH_JXMessageObject alloc] init];
                    msgObj.isGroup = YES;
                    
                    NSString *body = [[message elementForName:@"body"] stringValue];
                    
                    NSError *err;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                    if (dict) {
                        NSString *roomJidStr = [dict objectForKey:@"roomJid"]?:@"";
                        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:roomJidStr];
                        msg.toUserId = user.userId;
                        [msg deleteAll];
                        
                        msgObj.type = [NSNumber numberWithInt:1];
                        msgObj.content = @" ";
                        [msgObj updateLastSend:UpdateLastSendType_None];
                        [msg notifyMyLastSend];
                        
                        [[JXSynTask sharedInstance] deleteTaskWithRoomId:user.roomId];
                        [g_server WH_ClearGroupChatHistoryWithRoomId:user.roomId toView:self];
                        
                        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
                        [g_notify postNotificationName:@"kReadDelRefreshNotif" object:roomJidStr];
                    }
                }
                
                //设备/ip禁用
                if ([msg.type intValue] == kWCMessageTypeDisable) {
                    [GKMessageTool showText:@"当前设备/IP被禁用！"];
                    [g_server logout:g_myself.areaCode toView:self];
                }

                // 分享消息
                if ([msg.type intValue] == kWCMessageTypeShare) {
                    msg.content = [NSString stringWithFormat:@"[%@]",Localized(@"JXLink")];
                }
                // 转账已被领取消息
                if ([msg.type intValue] == kWCMessageTypeTransferReceive) {
                    [g_notify postNotificationName:kXMPPMessageTransferReceive_WHNotification object:msg];
                }
                // 转账已被退回消息
                if ([msg.type intValue] == kWCMessageTypeTransferBack) {
                    [g_notify postNotificationName:kXMPPMessageTransferBack_WHNotification object:msg];
                }
                // 扫码支付款
                if ([msg.type intValue] == kWCMessageTypePaymentOut || [msg.type intValue] == kWCMessageTypeReceiptOut ||[msg.type intValue] == kWCMessageTypePaymentGet ||[msg.type intValue] == kWCMessageTypeReceiptGet) {
                    [g_notify postNotificationName:kXMPPMessageQrPayment_WHNotification object:msg];
                }

                if([type isEqualToString:@"chat"]){
                    //单聊发送回执：
                    if (![fromUserId isEqualToString:MY_USER_ID]) {
//                        [self sendMsgReceipt:message];
                    }
                    // 判断是否是正在输入
                    if ([msg.type intValue] == kWCMessageTypeRelay) {
                        [g_notify postNotificationName:kXMPPMessageEntering_WHNotification object:msg];
                        msg = nil;
                        return;
                    }
                    // 点赞 & 评论
                    if ([msg.type intValue] == kWCMessageTypeWeiboPraise || [msg.type intValue] == kWCMessageTypeWeiboComment || [msg.type intValue] == kWCMessageTypeWeiboRemind) {

//                        WH_JXUserObject* obj = [[WH_JXUserObject sharedUserInstance] getUserById:msg.fromUserId];

                        NSArray *allFriend = [[WH_JXUserObject sharedUserInstance] WH_fetchAllFriendsFromLocal];

                        NSArray *serverFriend = [[WH_JXUserObject sharedUserInstance] WH_fetchSystemUser];

                        Boolean isServer = NO; //是否为公众号
                        Boolean isSystemTo = NO; //是否接受者是公众号
                        for (int i = 0; i < serverFriend.count; i++) {
                            WH_JXUserObject *user = serverFriend[i];
                            if ([user.userId isEqualToString:msg.fromUserId]) {
                                isServer = YES;
                            }
                            if ([user.userId isEqualToString:msg.toUserId]) {
                                isSystemTo = YES;
                            }
                        }

                        Boolean isFriendFrom = NO;
                        Boolean isFriendTo = NO;

                        for (NSInteger i = 0; i < allFriend.count; i ++) {
                            WH_JXFriendObject *friend = allFriend[i];
                            if ([friend.userId isEqualToString:msg.fromUserId]) {
                                isFriendFrom = YES;
                            }
                        }

                        if ([msg.toUserId integerValue] == 0) {
                            isFriendTo = YES;
                        }else{
                            for (NSInteger i = 0; i < allFriend.count; i ++) {
                                WH_JXFriendObject *friend = allFriend[i];
                                if ([friend.userId isEqualToString:msg.toUserId]) {
                                    isFriendTo = YES;
                                }
                            }
                        }

                        NSLog(@"isFriendFrom:%hhu isFriendTo:%hhu myUserId:%@",isFriendFrom ,isFriendTo ,MY_USER_ID);
                        if ((isFriendFrom && isSystemTo) || (isServer && [msg.toUserId isEqualToString:MY_USER_ID]) || (isServer && isFriendTo) ||(isFriendFrom && [msg.toUserId isEqualToString:MY_USER_ID]) || (isFriendFrom && isFriendTo)) {
                            JXBlogRemind *br = [[JXBlogRemind alloc] init];
                            [br fromObject:msg];
                            [br insertObj];
                            [g_notify postNotificationName:kXMPPMessageWeiboRemind_WHNotification object:msg];
                            msg = nil;
                        }

//                        NSString *toUserId = msg.toUserId;
//                        //yzk添加过滤,过滤非自己好友发布的点赞评论(fromUserId是自己的好友,toUserId是自己)
//                        if (obj != nil && [toUserId isEqualToString:MY_USER_ID]) {
//                            JXBlogRemind *br = [[JXBlogRemind alloc] init];
//                            [br fromObject:msg];
//                            [br insertObj];
//                            [g_notify postNotificationName:kXMPPMessageWeiboRemind_WHNotification object:msg];
//                            msg = nil;
//                        }

//                        NSMutableArray *friendArray = [[WH_JXUserObject sharedUserInstance] WH_fetchAllFriendsFromLocal];
//                        if ([friendArray containsObject:msg.fromUserId]) {
//                            //好友关系
//                            NSLog(@"好友关系");
//                            NSString *toUserId = msg.toUserId;
//                            //yzk添加过滤,过滤非自己好友发布的点赞评论(fromUserId是自己的好友,toUserId是自己)
//                            if (obj != nil && [toUserId isEqualToString:MY_USER_ID]) {
//                                JXBlogRemind *br = [[JXBlogRemind alloc] init];
//                                [br fromObject:msg];
//                                [br insertObj];
//                                [g_notify postNotificationName:kXMPPMessageWeiboRemind_WHNotification object:msg];
//                                msg = nil;
//                            }
//
//                        }

                        return;
                    }
                    // 加好友消息
                    if([msg isAddFriendMsg]){
                        if ([msg.type intValue] == XMPP_TYPE_CONTACTREGISTER) {
                            [g_notify postNotificationName:kMsgComeContactRegister object:msg];
                        }else {
                            [self doReceiveFriendRequest:msg];
                        }
                        return;
                    }

                    // 面对面建群通知
                    if ([msg.type integerValue] == kRoomRemind_FaceRoomSearch) {
                        [g_notify postNotificationName:kMsgRoomFaceNotif object:msg];
                        return;
                    }

                    //群文件：
                    if([msg.type intValue] == kWCMessageTypeGroupFileUpload || [msg.type intValue] == kWCMessageTypeGroupFileDelete || [msg.type intValue] == kWCMessageTypeGroupFileDownload){
                        [msg doGroupFileMsg];
                        return;
                    }
                    //清空双方聊天记录
                    if ([msg.type intValue] == kWCMessageTypeDelMsgTwoSides) {
                        WH_JXMessageObject *msg1 = [[WH_JXMessageObject alloc] init];
                        msg1.toUserId = msg.fromUserId;
                        [msg1 deleteAll];
                        msg1.type = [NSNumber numberWithInt:1];
                        msg1.content = @" ";
                        [msg1 updateLastSend:UpdateLastSendType_None];
                        [msg1 notifyMyLastSend];
                        [g_server WH_emptyMsgWithTouserId:msg1.fromUserId type:[NSNumber numberWithInt:0] toView:self];
                        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
                    }

                    //清空群聊天记录(后台控制)
                    if ([msg.type integerValue] == kRoomRemind_ClearRoomChatRecord) {
                        if (msg.objectId) {
                            [[WH_JXMessageObject sharedInstance] clearMessageWithUser:msg.objectId clearChatTime:msg.timeSend];
                        }
                        //通知聊天页刷新数据
                        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
                        [g_notify postNotificationName:kClearRoomChatRecord object:msg.objectId];
                        return;
                    }

                    if (![msg haveTheMessage]) {
                        BOOL isRoomControlMsg = msg.isRoomControlMsg;
                        BOOL isInsert = [msg insert:nil];//在保存时检测MessageId是否已存在记录
                        if (isRoomControlMsg && !isInsert) {
                            return;
                        }

                        [msg updateLastSend:UpdateLastSendType_Add];
                        [msg notifyNewMsg];//在显示时检测MessageId是否已显示
                    }
                }else{

                    //清空群聊天记录(后台控制)
                    if ([msg.type integerValue] == kRoomRemind_ClearRoomChatRecord) {
                        return;
                    }

                    //群文件：
                    if([msg.type intValue] == kWCMessageTypeGroupFileUpload || [msg.type intValue] == kWCMessageTypeGroupFileDelete || [msg.type intValue] == kWCMessageTypeGroupFileDownload){
                        [msg doGroupFileMsg];
                        return;
                    }

                    msg.isGroup  = YES;
                    BOOL isRoomControlMsg = msg.isRoomControlMsg;
                    if(!isRoomControlMsg)
                        msg.toUserId = fromUserId;

//                    if(![msg.fromUserId isEqualToString:MY_USER_ID]){

                    //如果是回复消息要将objectId字典转为字符串存入数据库
                    if ([msg.type intValue] == kWCMessageTypeReply) {
                        if ([msg.objectId isKindOfClass:[NSDictionary class]]) {
                            NSString *dicStr = [msg.objectId mj_JSONString];
                            msg.objectId = dicStr;
                        }
                    }
                    if(![msg insert:fromUserId]){ //在保存时检测MessageId是否已存在记录
                        if (isRoomControlMsg) {
                            return;
                        }
                        msg.isRepeat = YES;
                    }else {
                        [msg updateLastSend:UpdateLastSendType_Add];
                    }

                    if (msg.type.integerValue == kWCMessageTypeRemind) {
                        //公告类型,判断是否为强提醒公告
                        @try{
                            NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                            if (![[NSString stringWithFormat:@"%@",jsonObj[@"fromUserId"]] isEqualToString:g_myself.userId]) {
                                //不是自己发送的
                                if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                                    NSDictionary *content = jsonObj[@"content"];
                                    if ([content isKindOfClass:[NSDictionary class]]) {
                                        if ([content[@"noticeType"] intValue] == 1) {
                                            //强提醒公告
                                            NSString *objectId = jsonObj[@"objectId"];
                                            NSNumber *isCloseStrongReminder = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_group_strong_reminder_%@",g_myself.userId,objectId]];
                                            BOOL isClose = [isCloseStrongReminder boolValue];
                                            if (!isClose) {
                                                //未打开关闭强提醒,弹出弹框
                                                WH_StrongReminderView *strongReminderView = [[WH_StrongReminderView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                strongReminderView.wh_name = content[@"nickname"];

                                                NSString *userId = [NSString stringWithFormat:@"%@",content[@"userId"]];
                                                NSString* dir  = [NSString stringWithFormat:@"%lld",[userId longLongValue] % 10000];
                                                NSString* urlString  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",[share_defaults objectForKey:kDownloadAvatarUrl],dir,userId];
                                                strongReminderView.wh_headUrl = urlString;
                                                strongReminderView.wh_notice = content;
                                                strongReminderView.entryGroupCallback = ^(WH_StrongReminderView *reminderView){
                                                    //关闭强提醒窗口
                                                    [reminderView wh_close];
                                                    //点击进入群聊
                                                    [WH_JXChat_WHViewController gotoChatViewController:objectId];
                                                };
                                                [strongReminderView setupUI];
                                                [[UIApplication sharedApplication].keyWindow addSubview:strongReminderView];
                                                [strongReminderView wh_show];
                                            }
                                        }
                                    }
                                }
                            }
                        } @catch(NSException *e){}
                    }


                    [msg notifyNewMsg];
//                    }

                }
            }
        }

        msg = nil;
    }
}

- (void)sendXMPPIQ:(NSString *)messageId {
    //保存每条消息的messageId
    if (IsStringNull(messageId)) {
         return;
     }
    if (![_poolSendIQ containsObject:messageId]) {
        [_poolSendIQ addObject:messageId];
     }
}

- (void)sendIQ:(NSTimer *)timer {
    _IQNum = _IQNum > 5 ? 0 : _IQNum +1;
    // 消息回执（发送给服务器）
    // 每秒执行一次，判断5秒没发回执就发一次，或者消息数量大于100也发一次
    if (_poolSendIQ.count >= 100 || (_IQNum >= 5 && _poolSendIQ.count > 0)) {
        XMPPIQ *xmppIQ = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:g_config.XMPPDomain]];
        DDXMLNode* idN = [DDXMLNode elementWithName:@"id" stringValue:[xmppStream generateUUID]];
//        [xmppIQ addChild:idN];
        [xmppIQ WH_addChild:idN];
        NSXMLElement * xmlns = [NSXMLElement elementWithName:@"body" xmlns:@"xmpp:tig:ack"];
        NSArray *arr = [[NSArray alloc] init];
        if (_poolSendIQ.count > 100) {
            arr = [_poolSendIQ subarrayWithRange:NSMakeRange(0, 100)];
         }else {
              arr = _poolSendIQ.copy;
         }
        
        xmlns.stringValue = [arr componentsJoinedByString:@","];
//        [xmppIQ addChild:xmlns];
        [xmppIQ WH_addChild:xmlns];
        
        [xmppStream sendElement:xmppIQ];
        // 消息发送后清空_poolSendIQ里面的messageId
        if (_poolSendIQ.count > 100) {
            [_poolSendIQ removeObjectsInRange:NSMakeRange(0, 100)];
        }else {
             [_poolSendIQ removeAllObjects];
         }
        NSLog(@"每秒执行一次，判断5秒没发回执就发一次，或者消息数量大于100也发一次,xmppIQ = %@",xmppIQ);
     }
}

- (void) sendMsgReceipt:(XMPPMessage *)message{//单聊发送消息回执
//    NSString *delay = [[message elementForName:@"delay"] stringValue];
//    if([message hasReceiptRequest] && delay == nil){//离线不发送回执
    if([message hasReceiptRequest]){//离线也发送回执，这样服务器可以确保消息送达
        XMPPMessage* reply = [message generateReceiptResponse];//发送回执
        [xmppStream sendElement:reply];
        NSLog(@"单聊发送消息回执===%@",reply);
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement*)element
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSString *elementName = [element name];
    
    if ([elementName isEqualToString:@"stream:error"]){
        DDXMLNode * errorNode = (DDXMLNode *)element;
        NSArray * errorNodeArray = [errorNode children];
        for (DDXMLNode * node in errorNodeArray) {
            if ([[node name] isEqualToString:@"conflict"]) {
                self.isReconnect = NO;
                [_reconnectTimer invalidate];
                _reconnectTimer = nil;
                NSLog(@"xmpp ---- error");
                [self logout];
                [g_notify postNotificationName:kXMPPLoginOther_WHNotification object:nil];
                return;
            }
        }
    }
    elementName = nil;
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"XMPP ---- disconnect");
    NSLog(@"XMPP连接失败错误信息:%@", error);
    if (error && self.isReconnect) {
        [roomPool deleteAll];
        self.isLogined = login_status_no;
        g_server.lastOfflineTime = [[NSDate date] timeIntervalSince1970];
        [self login];
        //未读上报
        [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
        //异常上报
        if (IS_OPEN_LOGREPORT) {
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_ID];
                NSString *myPassword =  [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_PASSWORD];
//                NSString *userID = g_myself.userId;
//                NSString *myPassword =  g_myself.password;
//                BOOL isMultipleLogin = [g_myself.multipleDevices intValue] > 0 ? YES : NO;
                BOOL isMultipleLogin = YES;
                NSString *sameResource = @"/youjob";
                if (isMultipleLogin) {
                    sameResource = @"/ios";
                }
                NSString *myJID = [NSString stringWithFormat:@"%@@%@%@",userID,g_config.XMPPDomain,sameResource];//拼接主机名&resource
                NSString *buildStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                
                //拼接上报信息
                NSString *contextStr = [NSString string];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"userId:%@",userID]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"password:%@",myPassword]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"myJID:%@",myJID]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"手机型号:%@",g_server.deviceVersion]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"系统版本:%@",[UIDevice currentDevice].systemVersion]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"app版本:%@.%@",g_config.version,buildStr]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"上报时间:%@",[self getCurrentTimes]]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"当前http连接ip:%@",g_config.apiUrl]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"当前XMPP连接域名:%@",g_config.XMPPHost]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"当前XMPP连接端口:%ld",(long)g_config.XMPPHostPort]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"xmpp error:%@",error]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"error Des=%@",error.description]];
                contextStr = [contextStr stringByAppendingString:@"\n"];
                
                [g_server logReportWithLogContext:contextStr toView:self];
            });
        }
        
    }
    
	if (isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

- (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    return nil;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate(花名册代理方法)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//接收到好友请求时调用
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    XMPPJID *jid=[XMPPJID jidWithString:[presence stringValue]];
    [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}
#pragma mark 开始检索好友列表的方法
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"开始检索好友列表");
}

- (void)addSomeBody:(NSString *)userId
{
    [xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",userId,g_config.XMPPDomain]]];
}

-(void)fetchUser:(NSString*)userId
{
    [g_server getUser:userId toView:self];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if ([aDownload.action isEqualToString:wh_act_readDelMsg]) {
        NSLog(@"删除成功");
    }else if ([aDownload.action isEqualToString:act_LogReport]) {
        NSLog(@"XMPP连接异常上报成功");
    }else if ([aDownload.action isEqualToString:wh_act_UserLogout]) {
        NSLog(@"退出登录");
        [self loginOutMethod];
    }else if ([aDownload.action rangeOfString:@"messages/sync"].location != NSNotFound){
            if (array1.count) {
                for (NSString *str in array1) {
                    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    [self dealEventSourceMessageWithDict:dic];
                }
            }
            
            NSLog(@"退出登录");
        }

    if([dict count]>0){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user userFromDictionary:user dict:dict];
        [user insert];
//        [user release];
    }
}


-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    
    if ([aDownload.action isEqualToString:@"messages/sync"]) {
           NSLog(@"退出登录");
       }
}


- (void)loginOutMethod {
    [g_default removeObjectForKey:kMY_USER_PASSWORD];
    [g_default removeObjectForKey:kMY_USER_TOKEN];
    [g_notify postNotificationName:kSystemLogout_WHNotifaction object:nil];
    [g_default setBool:NO forKey:kIsAutoLogin];
    [[JXXMPP sharedInstance] logout];
    NSLog(@"XMPP ---- WH_JXSetting_WHVC doSwitch");
        // 退出登录到登陆界面 隐藏悬浮窗
    g_App.subTopWindow.hidden = YES;
    g_App.isHaveTopWindow = YES;
        
    WH_LoginViewController *loginVC = [[ WH_LoginViewController alloc] init];
    [g_mainVC.view removeFromSuperview];
    g_mainVC = nil;
//        [self.view removeFromSuperview];
//        self.view = nil;
    loginVC.isPushEntering = YES;
    g_navigation.rootViewController = loginVC;
        
    #if TAR_IM
    #ifdef Meeting_Version
    [g_meeting WH_stopMeeting];
    #endif
    #endif
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
//    NSString *body = [[message elementForName:@"body"] stringValue];
//	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, body);
}

- (FMDatabase*)openUserDb:(NSString*)userId{
    userId = [userId uppercaseString];
    if([_userIdOld isEqualToString:userId]){
        if(_db && [_db goodConnection])
            return _db;
    }
//    [_userIdOld release];
//    _userIdOld = [userId retain];
    _userIdOld = userId;
    NSString* t =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* s = [NSString stringWithFormat:@"%@/%@.db",t,userId];
    
//    [_db close];
//    [_db release];
    _db = [[FMDatabase alloc] initWithPath:s];
    if (![_db open]) {
//        NSLog(@"数据库打开失败");
        return nil;
    };
    NSLog(@"本地自己用户表地址dataPath:%@",_db.databasePath);
    
    if (userId.length > 0) {
        [self getBlackList];
    }
    return _db;
}

-(void)getBlackList{
    [blackList removeAllObjects];
    NSMutableArray* a = [[WH_JXUserObject sharedUserInstance] WH_fetchAllBlackFromLocal];
    for(int i=0;i<[a count];i++){
        WH_JXUserObject* p = [a objectAtIndex:i];
        [blackList addObject:p.userId];
//        [p release];
    }
    a = nil;
}

-(NSString*)getUserId:(NSString*)s{
    NSRange range = [s rangeOfString:@"@"];
    if(range.location != NSNotFound)
        s = [s substringToIndex:range.location];
    return s;
}

-(void)saveToUser:(WH_JXMessageObject*)msg{
    WH_JXUserObject *user=[[WH_JXUserObject alloc]init];
    user.userId = msg.toUserId;
    if (![user haveTheUser]) {
        user.userNickname = msg.toUserName;
        user.userDescription = msg.toUserName;
        [user insert];
    }
//    [user release];
}

-(void)saveFromUser:(WH_JXMessageObject*)msg{
    WH_JXUserObject *user=[[WH_JXUserObject alloc]init];
    user.userId = msg.fromUserId;
    if (![user haveTheUser]) {
        user.userNickname = msg.fromUserName;
        user.userDescription = msg.fromUserName;
        [user insert];
    }
//    [user release];
}
#pragma mark-----阅后即焚删除本地数据
- (void)readDelete:(NSNotification *)notification{
    WH_JXMessageObject *msg = notification.object;
    [msg delete];
//    if (!msg.isGroup || !msg.isMySend) {//群聊不删除服务器消息
//        [g_server readDeeleteMsg:msg toView:self];
//    }
}

-(void)notifyNewMsg{
//    NSLog(@"收到新消息：%f",g_xmpp.lastNewMsgTime);
    double n = [[NSDate date] timeIntervalSince1970]-g_xmpp.lastNewMsgTime;
    if(n>0.5){//假如0.5秒之内没有新消息到达，则认为收取完毕，一次性刷新
//        NSLog(@"刷新聊天记录：%f",n);
//        self.newMsgAfterLogin = 1;
        [g_notify postNotificationName:kXMPPAllMsg_WHNotifaction object:nil userInfo:nil];
    }
}

-(void)doReceiveFriendRequest:(WH_JXMessageObject*)msg{
    if(![msg isAddFriendMsg])
        return;
    if([msg.type intValue] == XMPP_TYPE_SAYHELLO || [msg.type intValue] == XMPP_TYPE_FEEDBACK){
        int n = [msg.type intValue];
        msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
        msg.isRead = [NSNumber numberWithInt:1];
        [msg insert:nil];
        msg.type = [NSNumber numberWithInt:n];
    }

    WH_JXFriendObject* friend = [[WH_JXFriendObject alloc]init];
    [friend loadFromMessageObj:msg];
    [friend doWriteDb];
    [friend notifyNewRequest];

    WH_JXFriendObject *user = [[WH_JXFriendObject sharedInstance] getFriendById:friend.userId];
    msg.content = [friend getLastContent];
//    if ([user.msgsNew intValue] > 0) {
//        [msg updateLastSend:UpdateLastSendType_None];
//    }else {
        [user updateNewMsgUserId:user.userId num:1];
        [msg updateLastSend:UpdateLastSendType_Add];
//    }
    [msg notifyNewMsg];
}

-(void)doSendFriendRequest:(WH_JXMessageObject*)msg{
    if(![msg isAddFriendMsg])
        return;
    if(!msg.isMySend)
        return;
    if([msg.type intValue] == XMPP_TYPE_SAYHELLO || [msg.type intValue] == XMPP_TYPE_FEEDBACK){
        int n = [msg.type intValue];
        msg.timeReceive = [NSDate date];
        msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
        msg.isSend = [NSNumber numberWithInt:transfer_status_yes];
        msg.isRead = [NSNumber numberWithInt:1];
        [msg insert:nil];
        msg.type = [NSNumber numberWithInt:n];
    }

    WH_JXFriendObject* friend = [[WH_JXFriendObject alloc]init];
    [friend loadFromMessageObj:msg];
    [friend doWriteDb];

    msg.content = [friend getLastContent];
    [msg updateLastSend:UpdateLastSendType_None];
    [msg notifyNewMsg];
}

-(void)inviteGroup{

}

// xmpp掉线后提示
- (void) showXmppOfflineAlert {
    
    [g_App showAlert:Localized(@"JX_Reconnect") delegate:self];
}

- (void) timerAction:(NSTimer *)timer{
    [_wait stop];
    // 连接失败
    [JXMyTools showTipView:Localized(@"JX_ConnectFailed")];
    [timer invalidate];
    self.timer = nil;
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        AppleReachability *reach = [AppleReachability reachabilityWithHostName:@"www.apple.com"];
        NetworkStatus internetStatus = [reach currentReachabilityStatus];
        switch (internetStatus) {
            case NotReachable:{
                if (self.isLogined != login_status_no) {
                    [self logout];
                }
//                [g_App showAlert:Localized(@"JX_NetWorkError")];
                [GKMessageTool showMessage:Localized(@"JX_NetWorkError")];
            }
                break;
                
            default:{
                //        if (alertView.tag == 10000) { // XMPP掉线
                _isShowLoginChange = YES;
                //            [_wait start:Localized(@"JX_Connection")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.isLogined != 1) {
                        self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
                        //                    self.loginStatus = YES;
                        NSLog(@"XMPP --- alert");
                        [self logout];
                        [_wait start:Localized(@"JX_Connection")];
                        [self login];
                    }
                });
                //        }
            }
                break;
        }
    }
}

-(BOOL)deleteMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId{//删除一条聊天记录
    NSString* myUserId = MY_USER_ID;
    if([myUserId length]<=0)
        return NO;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    NSString *queryString=[NSString stringWithFormat:@"delete from msg_%@ where messageId=?",userId];
    
    BOOL worked=[db executeUpdate:queryString,msgId];
    return worked;
}

-(WH_JXMessageObject*)findMessageWithUserId:(NSString *)userId messageId:(NSString *)msgId{//搜索一条记录
    NSString* myUserId = MY_USER_ID;
    if([myUserId length]<=0)
        return nil;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    NSString *queryString=[NSString stringWithFormat:@"select * from msg_%@ where messageId=?",userId];
    
    FMResultSet *rs=[db executeQuery:queryString,msgId];
    WH_JXMessageObject *p=nil;
    while ([rs next]) {
        p = [[WH_JXMessageObject alloc]init];
        [p fromRs:rs];
        break;
    }
    return p;
}

- (void)loginChanged {
    // 弹登录提示
    if (_isShowLoginChange) {
        _isShowLoginChange = NO;
        switch (self.isLogined){
            case login_status_ing:
                // 连接失败
//                [JXMyTools showTipView:Localized(@"JX_ConnectFailed")];
                break;
            case login_status_no:
                
                g_server.lastOfflineTime = [[NSDate date] timeIntervalSince1970];
                // 连接失败
//                [JXMyTools showTipView:Localized(@"JX_ConnectFailed")];
                break;
            case login_status_yes:
                // 连接成功
                [JXMyTools showTipView:Localized(@"JX_ConnectSuccessfully")];
                break;
        }
    }
    
    // 定时检测XMPP登录状态，实现重连机制
    if (!self.isReconnect) {
        self.isReconnect = YES;
        return;
    }
    if(self.isLogined != login_status_yes) {
        [_reconnectTimer invalidate];
        _reconnectTimer = nil;
        _reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(xmppTimerAction:) userInfo:nil repeats:NO];
        NSLog(@"login-开始登陆 - %d",self.isLogined);
    }else {
        [_reconnectTimer invalidate];
        _reconnectTimer = nil;
    }
}

- (void)xmppTimerAction:(NSTimer *)timer {
    NSLog(@"login-timerAction - %d",self.isLogined);
    if (self.isLogined != login_status_yes){
        [self logout];
        [self login];
    }else {
        [_reconnectTimer invalidate];
        _reconnectTimer = nil;
    }
}

-(NSString*)backUrl{
    NSString *urlStr = @"";
          NSString *urlPath = @"";
          NSString *apiUrl = g_config.apiUrl?:@"";
          if ([apiUrl hasSuffix:@"/"]) {
              urlStr = [apiUrl substringToIndex:[apiUrl length] - 1];
          }else{
              urlStr = apiUrl;
          }
                  
          if ([urlStr rangeOfString:@":"].location != NSNotFound) {
          //包含有端口号
                      
              NSString *lowerStr = [urlStr lowercaseString]; //将所有字符串内容转为小写
                      
              NSArray *strArray = [urlStr componentsSeparatedByString:@":"];
              NSMutableArray *array = [[NSMutableArray alloc] initWithArray:strArray];
              if ([lowerStr hasPrefix:@"http://"] || [lowerStr hasPrefix:@"https://"]) {
                  if (array.count > 2) {
                      [array removeObjectAtIndex:array.count -1];
                   }
              }else{
                  [array removeObjectAtIndex:array.count -1];
              }
              urlPath = [array componentsJoinedByString:@":"];
          }else{
              urlPath = urlStr;
          }
    return urlPath;
}
//Label创建
+ (UILabel *)createLabelWith:(NSString *)text frame:(CGRect)frame color:(UIColor *)color font:(float)font {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:font];
    label.text = text;
    label.textColor = color;
    return label;
}
//TextFiled创建
+ (UITextField *)createTextFiledWith:(NSString *)placeholder frame:(CGRect)frame color:(UIColor *)color font:(float)font {
    UITextField *textFiled = [[UITextField alloc] initWithFrame:frame];
    textFiled.font = [UIFont systemFontOfSize:font];
    textFiled.placeholder = placeholder;
    textFiled.textColor = color;
    return textFiled;
}
//无图片Button创建
+ (UIButton *)createButtonWith:(NSString *)text frame:(CGRect)frame color:(UIColor *)color font:(float)font {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.titleLabel.font = [UIFont systemFontOfSize:font];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    return button;
}
//有图片无标题Button创建
+ (UIButton *)createButtonWithFrame:(CGRect)frame image:(UIImage *)image{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:image forState:UIControlStateNormal];
    return button;
}
//有图片有标题Button创建
+ (UIButton *)createButtonWith:(NSString *)text frame:(CGRect)frame color:(UIColor *)color font:(float)font image:(UIImage *)image{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:font];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    return button;
}
//实现button上图下文
+ (void)getButtonStyle:(UIButton *)button {
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.titleEdgeInsets = UIEdgeInsetsMake(button.imageView.frame.size.height, -button.imageView.frame.size.width, 0, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-button.imageView.frame.size.height, 0, 0, - button.titleLabel.bounds.size.width);
}
//实现button左文右图
+ (void)becomeButtonStyle:(UIButton *)button {

[button setTitleEdgeInsets:UIEdgeInsetsMake(0, -button.imageView.bounds.size.width, 0, button.imageView.bounds.size.width)];
[button setImageEdgeInsets:UIEdgeInsetsMake(0, button.titleLabel.bounds.size.width, 0, -button.titleLabel.bounds.size.width)];
}
+(void)getAttributeTextWithLabel:(UILabel *)label textString:(NSString *)textString color:(UIColor *)color {
    if (!label.text || label.text.length == 0) {
        return ;
    }
    NSMutableAttributedString *text = [label.attributedText mutableCopy];
    [text addAttribute:NSForegroundColorAttributeName value:color range:[label.text rangeOfString:textString]];
    label.attributedText = text;
}
//计算label高度
+ (CGFloat)getLabelHeightWithContent:(NSString *)content andLabelWidth:(CGFloat)width andLabelFontSize:(int)font{
    
    if ([content isKindOfClass:[NSNull class]] || content.length == 0) {
        return 0;
    } else {
        CGSize size = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]} context:nil].size;
        return size.height;
    }
}
@end
