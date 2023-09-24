//
//  WH_WithdrawalList_WHViewController.h
//  Tigase
//
//  Created by lyj on 2019/11/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_WithdrawalList_WHViewController : WH_JXTableViewController

@property (nonatomic ,strong) NSMutableArray *withdrawWay;
@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, strong) NSDictionary *selectedAccountDic;
@property (nonatomic, copy) void(^selectAccountBlock)(NSDictionary *accountDic);
@end

NS_ASSUME_NONNULL_END
