//
//  WH_JXGroupManagement_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/5/28.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_JXGroupManagement_WHVC : WH_admob_WHViewController

@property (nonatomic,strong) WH_RoomData* room;

@property (nonatomic ,strong) UIView *cView;

@property (nonatomic ,assign) Boolean isSignIn; //是否是群签到功能

- (void)sp_getUsersMostLikedSuccess;
@end
