//
//  JXBlogRemindVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXTableViewController.h"

@interface JXBlogRemindVC : WH_JXTableViewController

@property (nonatomic, strong) NSMutableArray *wh_remindArray;

@property (nonatomic, assign) BOOL wh_isShowAll;

@property (nonatomic ,copy) NSString *detailMsgId;


- (void)sp_getUserFollowSuccess;
@end
