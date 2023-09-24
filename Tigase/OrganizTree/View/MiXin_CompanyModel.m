//
//  MiXin_CompanyModel.m
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_CompanyModel.h"

@implementation MiXin_EmployeeModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"id"};
}
@end


@implementation MiXin_DepartModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"employees":[MiXin_EmployeeModel class]};
}
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"id"};
}
@end


@implementation MiXin_CompanyModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"departments":[MiXin_DepartModel class]};
}
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"id"};
}
@end
