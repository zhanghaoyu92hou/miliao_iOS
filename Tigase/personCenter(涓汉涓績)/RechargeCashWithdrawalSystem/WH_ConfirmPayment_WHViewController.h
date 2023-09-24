//
//  WH_ConfirmPayment_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ConfirmPaymentDelegate <NSObject>

-(void)rechargeSuccessed;

@end

@interface WH_ConfirmPayment_WHViewController : WH_admob_WHViewController

@property (nonatomic ,copy) NSString *pay_money; //支付金额
@property (nonatomic ,assign) NSInteger paymentType ; //支付方式 0：支付宝 1：微信 2：银行卡

@property (nonatomic, copy) NSString *zfid;

@property (nonatomic ,strong) NSMutableArray *pTypeArray; //支付方式数组
@property (nonatomic ,copy) NSString *accountNumber; //充值账号

@property (nonatomic, weak) id<ConfirmPaymentDelegate> rechargeDelegate;


@property (nonatomic,assign) BOOL isQuitAfterSuccess;

@end

NS_ASSUME_NONNULL_END
