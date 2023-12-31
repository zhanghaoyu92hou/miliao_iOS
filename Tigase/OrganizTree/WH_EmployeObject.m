//
//  EmployeObject.m
//  Tigase_imChatT
//
//  Created by 1 on 17/5/11.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_EmployeObject.h"


@implementation WH_EmployeObject

-(instancetype)initWithDict:(NSDictionary *)dataDict{
    self = [super init];
    if (self) {
        if (dataDict[@"companyId"]!=nil)
            self.companyId  = dataDict[@"companyId"];
        if (dataDict[@"departmentId"]!=nil)
            self.departmentId  = dataDict[@"departmentId"];
        if (dataDict[@"id"]!=nil)
            self.employeeId  = dataDict[@"id"];
        if (dataDict[@"role"]!=nil)
            self.role  = [dataDict[@"role"] integerValue];
        if (dataDict[@"userId"]!=nil)
            self.userId  = [NSString stringWithFormat:@"%@",dataDict[@"userId"]];
        if (dataDict[@"nickname"]!=nil)
            self.nickName  = dataDict[@"nickname"];
        if (dataDict[@"position"]!=nil)
            self.position = dataDict[@"position"];
        
    }
    
    return self;
}

+(instancetype)employWithDict:(NSDictionary *)dataDict{
    return [[WH_EmployeObject alloc] initWithDict:dataDict];
}
@end
