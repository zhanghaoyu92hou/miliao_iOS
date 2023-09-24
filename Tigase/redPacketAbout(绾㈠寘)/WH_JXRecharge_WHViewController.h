//
//  WH_JXRecharge_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/10/30.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXTableViewController.h"

@protocol RechargeDelegate <NSObject>

-(void)rechargeSuccessed;

@end

@interface WH_JXRecharge_WHViewController : WH_JXTableViewController

@property (nonatomic, weak) id<RechargeDelegate> rechargeDelegate;

@property (nonatomic,assign) BOOL isQuitAfterSuccess;


- (void)sp_getUsersMostFollowerSuccess:(NSString *)mediaInfo;
@end
