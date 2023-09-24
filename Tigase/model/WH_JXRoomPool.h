//
//  WH_JXRoomPool.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-4-21.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WH_JXRoomObject;
@class XMPPRoomCoreDataStorage;

@interface WH_JXRoomPool : NSObject{
//    NSMutableDictionary* _pool;
    XMPPRoomCoreDataStorage* _storage;
}
@property (nonatomic,strong) NSMutableDictionary* pool;

-(WH_JXRoomObject*)createRoom:(NSString*)jid title:(NSString*)title;
-(WH_JXRoomObject*)joinRoom:(NSString*)jid title:(NSString*)title isNew:(bool)isNew;

//-(WH_JXRoomObject*)connectRoom:(NSString*)jid title:(NSString*)title;

-(void)deleteAll;
-(void)createAll;
-(void)reconnectAll;
-(void)delRoom:(NSString*)jid;
-(WH_JXRoomObject*)getRoom:(NSString*)jid;


-(void)connectRoom;
@end
