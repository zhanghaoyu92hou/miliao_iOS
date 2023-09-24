//
//  WH_JXPayPassword_WHVC.h
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"

typedef NS_OPTIONS(NSInteger, JXPayType) {
    JXPayTypeSetupPassword,     //设置密码
    JXPayTypeRepeatPassword,    //重复密码
    JXPayTypeInputPassword,     //输入密码,确认身份
};


/**
*   新控制器进入密码设置按钮需要添加新的Type，处理界面返回（不然会出现界面无法返回的情况）
*/
typedef NS_OPTIONS(NSInteger, JXEnterType) {
    JXEnterTypeDefault,            //!< 默认，我的钱包进入
    JXEnterTypeWithdrawal,         //!< 提现进入
    JXEnterTypeSendRedPacket,      //!< 发红包进入
    JXEnterTypeTransfer,           //!< 转账进入
    JXEnterTypeQr,                 //!< 扫码付款进入
    JXEnterTypeSkPay,              //!< Tigase支付进入
    JXEnterTypeSecureSetting,      //!< 安全设置进入
    JXEnterTypeForgetPayPsw,       //!< 忘记支付密码进入
};

@interface WH_JXPayPassword_WHVC : WH_admob_WHViewController
@property (nonatomic, assign) JXPayType type;
@property (nonatomic, assign) JXEnterType enterType;
@property (nonatomic, strong) NSString *wh_lastPsw;
@property (nonatomic, strong) NSString *wh_oldPsw;

@property (nonatomic ,strong) UIView *wh_cView;


@end
