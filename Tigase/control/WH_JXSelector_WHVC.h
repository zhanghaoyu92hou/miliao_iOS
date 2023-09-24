//
//  WH_JXSelector_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/8/26.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXTableViewController.h"
@class WH_JXSelector_WHVC;

@protocol WH_JXSelector_WHVCDelegate <NSObject>

- (void) selector:(WH_JXSelector_WHVC*)selector selectorAction:(NSInteger)selectIndex;

@end

@interface WH_JXSelector_WHVC : WH_admob_WHViewController<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *WH_tableView;

@property (nonatomic, strong) NSArray *WH_array;

@property (nonatomic, assign) NSInteger WH_selectIndex;

@property (nonatomic, weak) id wh_delegate;

@property (nonatomic, assign) SEL wh_didSelected;

@property (nonatomic, weak) id<WH_JXSelector_WHVCDelegate> wh_selectorDelegate;
@end
