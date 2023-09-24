//
//  NSString+WH_ContainStr.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WH_ContainStr)

-(BOOL)containsMyString:(NSString *)str;

//生成UUID
+ (NSString *)createUUID;

- (BOOL)isUrl;
- (void)sp_getUserName;

//判断是否包含中文
+ (BOOL)isHasChineseWithStr:(NSString *)strFrom ;
@end
