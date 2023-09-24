//
//  WH_BankList_WHModel.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/19.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_BankList_WHModel : NSObject

@property (nonatomic, copy) NSString *idNum;

@property (nonatomic, copy) NSString *bankNumber; //卡号
@property (nonatomic, copy) NSString *accountName; //账户名
@property (nonatomic, copy) NSString *accountAddr; //账户地址
@property (nonatomic, copy) NSString *bankName; //银行名称
@property (nonatomic, copy) NSString *payType; //支付类型
@property (nonatomic, copy) NSString *name; //银行名称
@property (nonatomic, copy) NSString *status;//状态

@property (nonatomic, copy) NSString *bankId; //银行卡id
@property (nonatomic, copy) NSString *bankUserName;//真实姓名
@end

NS_ASSUME_NONNULL_END
