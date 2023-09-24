//
//  WH_PrintManager.h
//  Tigase_imChatT
//
//  Created by Apple on 2019/6/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

#define NSLog(FORMAT, ...) output_log((FORMAT),##__VA_ARGS__);
// 输出日志到屏幕
FOUNDATION_EXPORT void output_log(NSString * _Nullable format, ...);
#else
#define NSLog(...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface WH_PrintManager : NSObject



NS_ASSUME_NONNULL_END

@end
