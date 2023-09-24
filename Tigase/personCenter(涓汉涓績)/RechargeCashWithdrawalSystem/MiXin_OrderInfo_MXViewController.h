//
//  MiXin_OrderInfo_MXViewController.h
//  mixin_chat
//
//  Created by Apple on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "WH_OrderListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiXin_OrderInfo_MXViewController : WH_admob_WHViewController<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *infoTable;

@property (nonatomic, strong) WH_OrderListModel *model;

@property (nonatomic, copy) void (^needRefreshOrderList)(void);

@end

NS_ASSUME_NONNULL_END
