//
//  WH_JXSendRedPacket_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/8/14.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@protocol SendRedPacketVCDelegate <NSObject>

-(void)sendRedPacketDelegate:(NSDictionary *)redpacketDict;

- (void)sendReceiveRedPacketDelegate:(NSDictionary *)redpacketDict;

@end


@interface WH_JXSendRedPacket_WHViewController : WH_admob_WHViewController

@property (nonatomic, assign) BOOL isRoom;
@property (nonatomic,strong) NSString* wh_roomJid;//相当于RoomJid
@property (nonatomic ,strong) NSString *wh_roomId;
@property (nonatomic, strong) NSString *wh_toUserId;
@property (nonatomic, weak) id<SendRedPacketVCDelegate> delegate;

@property (nonatomic ,strong) NSMutableArray *selectIds;
@property (nonatomic ,strong) NSMutableArray *selectNames;

@property (nonatomic,strong) WH_RoomData * room;

@property (nonatomic ,copy) NSString *memberCount; //群成员人数

- (void)sp_getMediaData:(NSString *)isLogin;
@end
