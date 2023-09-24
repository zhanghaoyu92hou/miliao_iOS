//
//  BindTelephoneHelper.h
//  Tigase
//
//  Created by 齐科 on 2019/9/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WH_JXPayPassword_WHVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface BindTelephoneChecker : NSObject
+ (void)checkBindPhoneWithViewController:(UIViewController *)viewController entertype:(JXEnterType)enterType;
+ (void)setPaypassForFirstTimeWithViewController:(UIViewController *)viewController entertype:(JXEnterType)enterType;
@end

NS_ASSUME_NONNULL_END
