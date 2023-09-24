//
//  WH_WithdrawThreeAccountViewController.h
//  Tigase
//
//  Created by Apple on 2020/3/19.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_WithdrawThreeAccountViewController : WH_JXTableViewController

@property (nonatomic ,copy) NSString *withdrawName;
@property (nonatomic ,copy) NSString *withdrawSort; //提现方式
@property (nonatomic ,copy) NSArray *keyDetails;

@property (nonatomic, strong) NSMutableArray   *wh_titleArray;
@property (nonatomic, strong) NSMutableArray   *wh_placeholderArray;
@property (nonatomic, strong) NSMutableArray   *wh_textFieldArray;

@end

NS_ASSUME_NONNULL_END
