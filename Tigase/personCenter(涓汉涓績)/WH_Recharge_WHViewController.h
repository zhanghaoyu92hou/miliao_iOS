//
//  WH_Recharge_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 Reese. All rights reserved.
//  充值

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WH_RechargeDelegate <NSObject>

-(void)rechargeSuccessed;

@end

@interface WH_Recharge_WHViewController : WH_admob_WHViewController<UITextFieldDelegate ,UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITextField *wh_moneyText;

@property (nonatomic ,strong) UITableView *wh_zfTable;
@property (nonatomic ,strong) NSMutableArray *wh_zfList;

@property (nonatomic, assign) NSInteger wh_checkIndex;

@property (nonatomic, weak) id<WH_RechargeDelegate> rechargeDelegate;



NS_ASSUME_NONNULL_END

@end
