//
//  JXShareManage.h
//  Tigase_imChatT
//
//  Created by p on 2018/11/1.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WH_JXAuth_WHViewController.h"

@interface JXShareManage : NSObject

+ (instancetype)sharedManager;

// 第三方APP 跳转回调
-(BOOL) handleOpenURL:(NSURL *) url delegate:(id) delegate;

@end
