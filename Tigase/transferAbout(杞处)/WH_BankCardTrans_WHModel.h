//
//  WH_BankCardTrans_WHModel.h
//  Tigase
//
//  Created by 闫振奎 on 2019/9/4.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_BankCardTrans_WHModel : NSObject

@property (nonatomic, assign) CGFloat amount;
@property (nonatomic, copy) NSString *statusMsg;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger payStatus;
@property (nonatomic, copy) NSString *drawee;

@end

NS_ASSUME_NONNULL_END
