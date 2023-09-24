//
//  WH_WithdrawalToBackground_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/28.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

#import "WH_JXVerifyPay_WHVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_WithdrawalToBackground_WHViewController : WH_admob_WHViewController<UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate>

@property (nonatomic ,strong) UITableView *pMementTable;

@property (nonatomic ,strong) NSMutableArray *listArray;
@property (nonatomic, assign) NSInteger checkIndex;

@property (nonatomic ,assign) CGFloat tableOrginY;

@property (nonatomic ,strong) UITextField *moneyTextField;

@property (nonatomic ,strong) UITextField *nameTextField;
@property (nonatomic ,strong) UITextField *codeTextField;
@property (nonatomic ,strong) UITextField *khhTextField;

@property (nonatomic, strong) WH_JXVerifyPay_WHVC *verVC;

@property (nonatomic, strong) NSString *payPassword;

@end

NS_ASSUME_NONNULL_END
