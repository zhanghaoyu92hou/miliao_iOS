//
//  MiXin_WithdrawStatus_MiXinVC.h
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

typedef NS_ENUM(NSInteger,MiXin_WithdrawStatusType) {
    MiXin_WithdrawStatusWaitForPayCoin, //等待承兑商付币
    MiXin_WithdrawStatusConfirmAcceptCoin, //确认收币
    MiXin_WithdrawStatusWithdrawDown, //提币 已完成
};


NS_ASSUME_NONNULL_BEGIN

@interface MiXin_WithdrawStatus_MiXinVC : WH_admob_WHViewController

@property (nonatomic, assign) MiXin_WithdrawStatusType type;

@property (nonatomic, copy) NSString *order_id;

@end

NS_ASSUME_NONNULL_END
