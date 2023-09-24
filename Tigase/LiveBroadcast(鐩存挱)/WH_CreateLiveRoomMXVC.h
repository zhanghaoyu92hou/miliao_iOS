//
//  WH_CreateLiveRoomMXVC.h
//  Tigase_imChatT
//
//  Created by 1 on 17/8/9.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@protocol JXCreateLiveRoomDelegate <NSObject>

-(void)createLiveRoomDelegate:(NSString *)name notice:(NSString *)notice;

@end

@interface WH_CreateLiveRoomMXVC : WH_admob_WHViewController

@property (nonatomic, weak) id<JXCreateLiveRoomDelegate> delegate;

@property (nonatomic, strong) NSString * wh_userId;

@end
