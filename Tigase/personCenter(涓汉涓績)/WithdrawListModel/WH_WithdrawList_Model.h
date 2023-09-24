//
//  WH_WithdrawList_Model.h
//  Tigase
//
//  Created by Apple on 2020/3/19.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_WithdrawList_Model : NSObject

@property (nonatomic ,strong) NSString *withdrawWayKeyId;
@property (nonatomic ,strong) NSString *withdrawWayName;
@property (nonatomic ,strong) NSString *withdrawWaySort;
@property (nonatomic ,strong) NSString *withdrawWayStatus;
@property (nonatomic ,strong) NSString *withdrawWayTime;
@property (nonatomic ,strong) NSArray *withdrawKeyDetails;

@end

NS_ASSUME_NONNULL_END
