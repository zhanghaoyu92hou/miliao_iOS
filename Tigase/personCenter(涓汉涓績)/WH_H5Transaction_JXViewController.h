//
//  WH_H5Transaction_JXViewController.h
//  Tigase
//
//  Created by Apple on 2019/12/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_H5Transaction_JXViewController : WH_admob_WHViewController<UITextFieldDelegate ,UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITextField *wh_moneyText;

@property (nonatomic ,strong) UITableView *wh_zfTable;
@property (nonatomic ,strong) NSMutableArray *wh_zfList;

@property (nonatomic, assign) NSInteger wh_checkIndex;

@property (nonatomic ,assign) NSInteger transactionType ; //交易类型:1:H5充值 2:H5提现

@end

NS_ASSUME_NONNULL_END
