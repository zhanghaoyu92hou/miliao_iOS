//
//  JXLikeListViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 2018/12/19.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"

@interface JXLikeListViewController : WH_JXTableViewController

@property (nonatomic, strong) WeiboData *wh_weibo;


- (void)sp_getUserName;
@end
