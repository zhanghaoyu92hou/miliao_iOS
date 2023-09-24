//
//  WH_JXDidPushObj.m
//  Tigase_imChatT
//
//  Created by p on 2019/5/14.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXDidPushObj.h"
#import "WH_WeiboViewControlle.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_JXMsg_WHViewController.h"
#import "WH_JXTransferNotice_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXRoomPool.h"
#import "WH_Addressbook_WHController.h"

@implementation WH_JXDidPushObj

static WH_JXDidPushObj *shared;

+(WH_JXDidPushObj*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared=[[WH_JXDidPushObj alloc]init];
    });
    return shared;
}

- (instancetype)init {
    if ([super init]) {
        
        [g_notify addObserver:self selector:@selector(onLoginChanged:) name:kXmppLogin_WHNotifaction object:nil];//登录状态变化了
    }
    return self;
}
-(void)onLoginChanged:(NSNotification *)notifacation{
    
    switch ([JXXMPP sharedInstance].isLogined){
        case login_status_ing:{

        }
            break;
        case login_status_no:{

        }
            break;
        case login_status_yes:{
            [self didReceiveRemoteNotif];
        }
            
            break;
    }
}

// 点击推送
- (void)didReceiveRemoteNotif {
    
    NSDictionary *dict = [g_default objectForKey:kDidReceiveRemoteDic];
    if (!dict) {
        return;
    }
    
    [g_default setObject:nil forKey:kDidReceiveRemoteDic];
    [g_default synchronize];
    
    [g_navigation popToRootViewController];
    
    if ([[dict objectForKey:@"messageType"] intValue] == kWCMessageTypeWeiboPraise || [[dict objectForKey:@"messageType"] intValue] == kWCMessageTypeWeiboComment || [[dict objectForKey:@"messageType"] intValue] == kWCMessageTypeWeiboRemind) {
        
        [g_mainVC doSelected:2];
        
        WH_WeiboViewControlle *weiboVC = [WH_WeiboViewControlle alloc];
        weiboVC.user = g_myself;
        weiboVC = [weiboVC init];
        [g_navigation pushViewController:weiboVC animated:YES];
        
        return;
    }
    
    if ([[dict objectForKey:@"messageType"] intValue]/100==5) {
        
        [g_mainVC doSelected:1];
        // 清空角标
        WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
        newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:FRIEND_CENTER_USERID];
        newobj.message = [[WH_JXMessageObject alloc] init];
        newobj.message.toUserId = FRIEND_CENTER_USERID;
        newobj.user.msgsNew = [NSNumber numberWithInt:0];
        [newobj.message WH_updateNewMsgsTo0];
        
        NSArray *friends = [[WH_JXFriendObject sharedInstance] WH_fetchAllFriendsFromLocal];
        for (NSInteger i = 0; i < friends.count; i ++) {
            WH_JXFriendObject *friend = friends[i];
            if ([friend.msgsNew integerValue] > 0) {
                [friend updateNewMsgUserId:friend.userId num:0];
            }
        }
        
        [g_mainVC.addressbookVC showNewMsgCount:0];
        
        WH_JXNewFriend_WHViewController* vc = [[WH_JXNewFriend_WHViewController alloc]init];
        [g_navigation pushViewController:vc animated:YES];
        
        return;
    }
    
    
    [g_mainVC doSelected:0];
    
    
    //    NSDictionary *dict = notif.object;
    
    NSString *userId = [dict objectForKey:@"from"];
    if ([dict objectForKey:@"roomJid"]) {
        userId = [dict objectForKey:@"roomJid"];
    }
    
    WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:userId];
    WH_JXMessageObject *p=[[WH_JXMessageObject alloc]init];
    //        [p fromRs:rs];
    p.content = user.content;
    p.type = user.type;
    p.timeSend = user.timeSend;
    p.fromUserId = user.userId;
    p.toUserId = MY_USER_ID;
    
    //    WH_JXMsgAndUserObject *p=[array objectAtIndex:indexPath.row];
    if (![user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        g_mainVC.msgVc.wh_msgTotal -= [user.msgsNew intValue];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - [user.msgsNew intValue];
//    [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
    
    if([user.userId isEqualToString:FRIEND_CENTER_USERID]){
        WH_JXNewFriend_WHViewController* vc = [[WH_JXNewFriend_WHViewController alloc]init];
        //        [g_App.window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        return;
    }
    if ([user.userId intValue] == [WAHU_TRANSFER intValue]) {
        WH_JXTransferNotice_WHVC *noticeVC = [[WH_JXTransferNotice_WHVC alloc] init];
        [g_navigation pushViewController:noticeVC animated:YES];
        user.msgsNew = [NSNumber numberWithInt:0];
        [p WH_updateNewMsgsTo0];
        [g_mainVC.msgVc getTotalNewMsgCount];
        return;
    }
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    
    //    sendView.scrollLine = lineNum;
    sendView.title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
    if([user.roomFlag intValue] > 0 || user.roomId.length > 0){
        //        if(g_xmpp.isLogined != 1){
        //            // 掉线后点击title重连
        //            [g_xmpp showXmppOfflineAlert];
        //            return;
        //        }
        
        sendView.roomJid = user.userId;
        sendView.roomId   = user.roomId;
        sendView.groupStatus = user.groupStatus;
        if ([user.groupStatus intValue] == 0) {
            
            sendView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname isNew:NO];
        }
        
        if (user.roomFlag || user.roomId.length > 0) {
            NSDictionary * groupDict = [user toDictionary];
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:groupDict];
            sendView.room = roomdata;
            sendView.newMsgCount = [user.msgsNew intValue];
            
            
            user.isAtMe = [NSNumber numberWithInt:0];
            [user updateIsAtMe];
        }
        
    }
    //    sendView.rowIndex = indexPath.row;
    sendView.lastMsg = p;
    sendView.chatPerson = user;
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.view.hidden = NO;
    
    user.msgsNew = [NSNumber numberWithInt:0];
    [p WH_updateNewMsgsTo0];
    
    [g_mainVC.msgVc WH_cancelBtnAction];
    
    [g_mainVC.msgVc getTotalNewMsgCount];
    
}

@end
