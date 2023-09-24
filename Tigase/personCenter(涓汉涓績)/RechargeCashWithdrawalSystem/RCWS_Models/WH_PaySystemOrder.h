//
//  WH_PaySystemOrder.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_PaySystemOrder : NSObject

@property (nonatomic, copy) NSString *money; //金额
@property (nonatomic, copy) NSString *ordernum; //订单号
@property (nonatomic, copy) NSString *zhmc; //名称
@property (nonatomic, copy) NSString *zhanghao; //账号
@property (nonatomic, copy) NSString *types; //微信
@property (nonatomic, copy) NSString *zfpic; //图片
@property (nonatomic, copy) NSString *mobile; //手机
@property (nonatomic, copy) NSString *nickname;//测试商行
@property (nonatomic, copy) NSString *zfje; //支付金额
@property (nonatomic, copy) NSString *des; //订单描述
@property (nonatomic, copy) NSString *khdz; //开户地址
@property (nonatomic, copy) NSString *khyh; //开户银行

@end

NS_ASSUME_NONNULL_END
