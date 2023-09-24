//
//  WH_NewRecharge_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_NewRecharge_WHViewController : WH_admob_WHViewController<UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate>

@property (nonatomic ,strong) UITextField *recMoneyTextField; //充值金额数
@property (nonatomic ,strong) UILabel *pMoneyLabel ;//需支付金额数

@property (nonatomic ,strong) UITableView *listTable;
@property (nonatomic ,strong) NSMutableArray *listArray;

@property (nonatomic ,strong) UITextField *accountTextField;

@property (nonatomic, assign) NSInteger checkIndex;

@end

NS_ASSUME_NONNULL_END
