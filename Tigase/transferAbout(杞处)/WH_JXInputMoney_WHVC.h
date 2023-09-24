//
//  WH_JXInputMoney_WHVC.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/7.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

typedef NS_ENUM(NSInteger, JXInputMoneyType) {
    JXInputMoneyTypeSetMoney,        // 设置金额
    JXInputMoneyTypeCollection,      // 收款
    JXInputMoneyTypePayment,         // 付款
};

@interface WH_JXInputMoney_WHVC : WH_admob_WHViewController

@property (nonatomic, assign) JXInputMoneyType type;

@property (nonatomic, strong) NSString *wh_userName;
@property (nonatomic, strong) NSString *wh_userId;
@property (nonatomic, strong) NSString *wh_money;
@property (nonatomic, strong) NSString *wh_desStr;
// 二维码付款用string
@property (nonatomic, strong) NSString *wh_paymentCode;

@property (weak, nonatomic) id delegate;
@property (nonatomic, assign) SEL onInputMoney;



@end

