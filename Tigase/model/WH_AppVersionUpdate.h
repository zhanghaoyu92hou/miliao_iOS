//
//  WH_AppVersionUpdate.h
//  Tigase
//
//  Created by 闫振奎 on 2019/7/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_AppVersionUpdate : NSObject

/**
 单例
 
 @return 单例对象
 */
+ (instancetype)shared;

/**
 检查版本更新
 */
- (void)checkVersion;

@end

NS_ASSUME_NONNULL_END
