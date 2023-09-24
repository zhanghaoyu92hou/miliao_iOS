//
//  WH_JXRoomPool.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-4-21.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXRoomPool.h"
#import "WH_JXRoomObject.h"
#import "WH_JXUserObject.h"
#import "WH_JXGroup_WHViewController.h"

@implementation WH_JXRoomPool

-(id)init{
    self = [super init];
    _pool = [[NSMutableDictionary alloc] init];
    _storage = [[XMPPRoomCoreDataStorage alloc] init];
    [g_notify addObserver:self selector:@selector(onQuitRoom:) name:kQuitRoom_WHNotifaction object:nil];
    return self;
}

-(void)dealloc{
//    NSLog(@"WH_JXRoomPool.dealloc");
    [g_notify  removeObserver:self name:kQuitRoom_WHNotifaction object:nil];
    [self deleteAll];
//    [_storage release];
//    [_pool release];
//    [super dealloc];
}

-(WH_JXRoomObject*)createRoom:(NSString*)jid title:(NSString*)title{
    if(jid==nil)
        return nil;
    WH_JXRoomObject* room = [[WH_JXRoomObject alloc] init];
    room.roomJid = jid;
    room.roomTitle = title;
    room.storage   = _storage;
    room.nickName  = MY_USER_ID;
    [room createRoom];
    [_pool setObject:room forKey:room.roomJid];
//    [room release];
    return room;
}

-(WH_JXRoomObject*)joinRoom:(NSString*)jid title:(NSString*)title isNew:(bool)isNew{
    if([_pool objectForKey:jid])
        return [_pool objectForKey:jid];
    if(jid==nil)
        return nil;
    WH_JXRoomObject* room = [[WH_JXRoomObject alloc] init];
    room.roomJid = jid;
    room.roomTitle = title;
    room.storage   = _storage;
    room.nickName  = MY_USER_ID;
    [room joinRoom:isNew];
    [_pool setObject:room forKey:room.roomJid];
//    [room release];
    return room;
}

-(void)connectRoom{
    
    for (int i = 0; i < [[_pool allValues] count]; i++) {
        WH_JXRoomObject * obj = [_pool allValues][i];
        if (!obj.isConnected) {
            [obj reconnect];
        }
    }
//    g_App.groupVC.sel = -1;
}

-(void)deleteAll{
    for(NSInteger i=[_pool count]-1;i>=0;i--){
        WH_JXRoomObject* p = (WH_JXRoomObject*)[_pool.allValues objectAtIndex:i];
        [p leave];
        p = nil;
    }
    [_pool removeAllObjects];
}

-(void)createAll{
    NSMutableArray* array = [[WH_JXUserObject sharedUserInstance] WH_fetchAllRoomsFromLocal];
    //
    
    for(int i=0;i<[array count];i++){
        WH_JXUserObject *room = [array objectAtIndex:i];
        if ([room.groupStatus intValue] == 0) {
            [self joinRoom:room.userId title:room.userNickname isNew:NO];
        }
    }
//    [array release];
}

-(void)reconnectAll{
    for(int i=0;i<[_pool count];i++){
        WH_JXRoomObject* p = (WH_JXRoomObject*)[_pool.allValues objectAtIndex:i];
        [p reconnect];
        p = nil;
    }
}

-(void)onQuitRoom:(NSNotification *)notifacation//退出房间
{
    WH_JXRoomObject* p     = (WH_JXRoomObject *)notifacation.object;
    for(NSInteger i=[_pool count]-1;i>=0;i--){
        if(p == [_pool.allValues objectAtIndex:i]){
            [_pool removeObjectForKey:p.roomJid];
            break;
        }
    }
    p = nil;
}

-(void)delRoom:(NSString*)jid{
    if([_pool objectForKey:jid]){
        WH_JXRoomObject* p = [_pool objectForKey:jid];
        [p leave];
        [_pool removeObjectForKey:jid];
        p = nil;
    }
}

-(WH_JXRoomObject*)getRoom:(NSString*)jid{
    return [_pool objectForKey:jid];
}

@end
