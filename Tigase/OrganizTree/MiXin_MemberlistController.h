//
//  MiXin_MemberlistController.h
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import "MiXin_CompanyModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MiXin_MemberlistController : WH_JXTableViewController
@property (nonatomic, copy) NSString *createUserId;

@property (nonatomic, copy) NSString *tname;
@property (nonatomic, copy) NSString *comname;
@property (nonatomic, copy) NSString *comId;
@property (nonatomic, copy) NSString *departId;

//@property (nonatomic, assign) BOOL ischoose;
@end

NS_ASSUME_NONNULL_END
