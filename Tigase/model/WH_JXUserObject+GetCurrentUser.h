//
//  WH_JXUserObject+GetCurrentUser.h
//  Tigase
//
//  Created by 齐科 on 2019/9/21.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXUserObject.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, HttpRequestStatus) {
    HttpRequestSuccess,
    HttpRequestFailed,
    HttpRequestError
};
typedef void (^ _Nullable getCurrentUerComplete)(HttpRequestStatus status, NSDictionary *_Nullable userInfo,  NSError *_Nullable error);
@interface WH_JXUserObject (GetCurrentUser)
@property (nonatomic, copy) getCurrentUerComplete complete;//!<获取当前用户

/**
 从服务器获取当前用户
 */
- (void)getCurrentUser;


/**
 将当前用户保存到文件

 @param userInfo 用户信息
 */
- (void)saveCurrentUser:(NSDictionary *_Nullable)userInfo;

/**
 从沙盒读取用户数据
 */
- (void)getCurrentUserFromDocument;
@end

NS_ASSUME_NONNULL_END
