//
//  WH_JXChatLog_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/7/5.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"

@interface WH_JXChatLog_WHVC : WH_JXTableViewController

@property (nonatomic, strong) NSMutableArray *array;


- (void)sp_upload:(NSString *)isLogin;
@end
