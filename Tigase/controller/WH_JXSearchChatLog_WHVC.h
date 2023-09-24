//
//  WH_JXSearchChatLog_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/6/25.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"

@interface WH_JXSearchChatLog_WHVC : WH_JXTableViewController

@property (nonatomic, strong) WH_JXUserObject *user;
@property (nonatomic, assign) BOOL isGroup;


- (void)sp_getUserFollowSuccess;
@end
