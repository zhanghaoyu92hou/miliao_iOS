//
//  WH_MyOrderList_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

#import "WH_MyOrderTop_NavigationVew.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_MyOrderList_WHViewController : WH_JXTableViewController<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *listTable;
@property (nonatomic ,strong) NSMutableArray *dataArray;

@property (nonatomic ,strong) WH_MyOrderTop_NavigationVew *topNavView;

@end

NS_ASSUME_NONNULL_END
