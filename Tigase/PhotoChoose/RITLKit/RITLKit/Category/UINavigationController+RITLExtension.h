//
//  UINavigationController+RITLExtension.h
//  TaoKeClient
//
//  Created by YueWen on 2017/10/21.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 根据导航控制器顶部控制器的preferredStatusBarStyle
@interface UINavigationController (RITLPreferredStatusBarStyle)



NS_ASSUME_NONNULL_END
- (void)sp_getLoginState:(NSString *)isLogin;
@end
