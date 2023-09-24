//
//  WH_JXReportUser_WHVC.h
//  Tigase_imChatT
//
//  Created by 1 on 17/6/26.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXTableViewController.h"

#import "WH_admob_WHViewController.h"

@protocol JXReportUserDelegate <NSObject>

-(void)report:(WH_JXUserObject *)reportUser reasonId:(NSNumber *)reasonId;

@end

@interface WH_JXReportUser_WHVC : WH_admob_WHViewController<UITableViewDataSource ,UITableViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic, strong) WH_JXUserObject * user;

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) BOOL isUrl;



- (void)sp_getLoginState;
@end
