//
//  WH_JXSkPay_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2019/5/16.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class WH_JXSkPay_WHVC;
@protocol WH_JXSkPay_WHVCDelegate <NSObject>

- (void)skPayVC:(WH_JXSkPay_WHVC *)skPayVC payBtnAction:(NSDictionary *)payDic;

@end

@interface WH_JXSkPay_WHVC : WH_admob_WHViewController

@property (nonatomic, strong) NSDictionary *payDic;

@property (nonatomic, weak) id<WH_JXSkPay_WHVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
