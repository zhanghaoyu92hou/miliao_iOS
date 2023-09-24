//
//  WH_JXSearchFileLog_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FileLogType_file,
    FileLogType_Link,
    FileLogType_transact,
} FileLogType;

@interface WH_JXSearchFileLog_WHVC : WH_JXTableViewController

@property (nonatomic, assign) FileLogType type;

@property (nonatomic, strong) WH_JXUserObject *user;

@property (nonatomic, assign) BOOL isGroup;



NS_ASSUME_NONNULL_END

@end
