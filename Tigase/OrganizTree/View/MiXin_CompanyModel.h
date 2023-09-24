//
//  MiXin_CompanyModel.h
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MiXin_CompanyModel : NSObject
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *createUserId;
@property (nonatomic, copy) NSString *deleteTime;
@property (nonatomic, copy) NSString *deleteUserId;

@property (nonatomic, copy) NSString *empNum;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *noticeContent;
@property (nonatomic, copy) NSString *noticeTime;
@property (nonatomic, copy) NSString *type;


@property (nonatomic, strong) NSArray *rootDpartId;
@property (nonatomic, strong) NSArray *departments;

@end

@interface MiXin_DepartModel : NSObject
@property (nonatomic, copy) NSString *companyId;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *createUserId;
@property (nonatomic, copy) NSString *departName;
@property (nonatomic, copy) NSString *empNum;

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, strong) NSArray *employees;

@property (nonatomic, assign) BOOL isChoose;
@end


@interface MiXin_EmployeeModel : NSObject
@property (nonatomic, copy) NSString *chatNum;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *departmentId;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *isCustomer;
@property (nonatomic, copy) NSString *isPause;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *companyId;
@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *operationType;


@end
NS_ASSUME_NONNULL_END
