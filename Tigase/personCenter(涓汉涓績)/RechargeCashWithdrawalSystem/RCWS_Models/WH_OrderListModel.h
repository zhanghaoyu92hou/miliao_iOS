//
//  WH_OrderListModel.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_OrderListModel : NSObject


@property (nonatomic, copy) NSString *ID; //订单id
@property (nonatomic, copy) NSString *zfje; //订单金额
@property (nonatomic, copy) NSString *skzh; //收款账号
@property (nonatomic, copy) NSString *ordernum; //订单号
@property (nonatomic, copy) NSString *zhifu; //收款类型

@end

NS_ASSUME_NONNULL_END
