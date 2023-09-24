//
//  WH_JXCashWithDraw_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/10/27.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_JXCashWithDraw_WHViewController : WH_admob_WHViewController<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *wh_zfTable;
@property (nonatomic ,strong) NSMutableArray *wh_zfList;

@property (nonatomic, assign) NSInteger wh_checkIndex;


- (void)sp_upload;
@end
