//
//  WH_AddWithdrawalAccount_WHVC.h
//  Tigase
//
//  Created by lyj on 2019/11/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

typedef NS_OPTIONS(NSInteger, WithdrawAccountType) {
    WithdrawAccountTypeAlipay = 0,
    WithdrawAccountTypeBankCard = 1 << 0,
};

NS_ASSUME_NONNULL_BEGIN

@interface WH_AddWithdrawalAccount_WHVC : WH_JXTableViewController
@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, assign) WithdrawAccountType withdrawAccountType;
@end

NS_ASSUME_NONNULL_END
