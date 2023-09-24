//
//  WH_PayTypeModel.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_PayTypeModel : NSObject

@property (nonatomic, copy) NSString *zfid; //支付类型id
@property (nonatomic, copy) NSString *zfmc; //支付类型名称

@end

NS_ASSUME_NONNULL_END
