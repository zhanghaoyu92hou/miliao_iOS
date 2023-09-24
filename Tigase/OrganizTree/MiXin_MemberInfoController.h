//
//  MiXin_MemberInfoController.h
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "MiXin_CompanyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiXin_MemberInfoController : WH_admob_WHViewController
@property (nonatomic, copy) NSString *tname;
@property (nonatomic, copy) NSString *comname;
@property (nonatomic, copy) NSString *departname;

@property (nonatomic, copy) NSString *employeeId;

//通知员工列表刷新block
@property (nonatomic, copy) void(^deleteEmploy)(void);

@property (nonatomic, copy) NSString *createUserId;


@end

NS_ASSUME_NONNULL_END
