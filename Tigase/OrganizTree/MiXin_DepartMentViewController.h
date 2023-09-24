//
//  MiXin_DepartMentViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiXin_DepartMentViewController : WH_JXTableViewController
@property (nonatomic ,copy) NSString *companyName;
@property (nonatomic, copy) NSString *tname;
@property (nonatomic, copy) NSString *comId;
@property (nonatomic, copy) NSString *parentId;

@property (nonatomic, assign) BOOL ischoose;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) void(^updateDepart)(NSString *str);
@property (nonatomic, copy) void(^deleteCom)(void);
@end

NS_ASSUME_NONNULL_END
