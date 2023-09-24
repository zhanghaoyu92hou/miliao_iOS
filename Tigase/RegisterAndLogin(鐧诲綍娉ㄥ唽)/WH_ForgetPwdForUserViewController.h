//
//  WH_ForgetPwdForUserViewController.h
//  Tigase
//
//  Created by 齐科 on 2019/8/19.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_ForgetPwdForUserViewController : WH_admob_WHViewController
@property (nonatomic, assign) NSInteger forgetStep; //!< 1、用户名界面 2、密保界面
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSDictionary *questionDic;
@property (nonatomic, strong) NSArray *questions;
@end

NS_ASSUME_NONNULL_END
