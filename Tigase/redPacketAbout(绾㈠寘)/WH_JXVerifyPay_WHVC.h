//
//  WH_JXVerifyPay_WHVC.h
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"

typedef NS_OPTIONS(NSInteger, JXVerifyType) {
    JXVerifyTypeWithdrawal,         // 提现验证
    JXVerifyTypeSendReadPacket,     // 发红包验证
    JXVerifyTypeTransfer,           // 转账
    JXVerifyTypeQr,                 // 扫码支付
    JXVerifyTypeSkPay,              // Tigase支付
};

@interface WH_JXVerifyPay_WHVC : WH_admob_WHViewController

@property (nonatomic, assign) JXVerifyType type;
@property (nonatomic, strong) NSString *wh_RMB;
@property (nonatomic, strong) NSString *wh_titleStr;

@property (nonatomic, assign) SEL didDismissVC;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL didVerifyPay;

@property (nonatomic, strong) UILabel *RMBLab;

/**
 *  清除密码
 */
- (void)WH_clearUpPassword;

/**
 *  输入密码后
 *  获取密码(MD5加密)
 */
- (NSString *)WH_getMD5Password;


- (void)sp_didUserInfoFailed;
@end
