//
//  WH_Organiz_WHObject.m
//  Tigase_imChatT
//
//  Created by 1 on 17/5/11.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_Organiz_WHObject.h"
#import "WH_JXUserObject.h"

@implementation WH_Organiz_WHObject

-(id)initWithDict:(NSDictionary *)nodeDict
{
    self = [super init];
    if (self) {
        if (nodeDict[@"nickname"] != nil)
            self.nodeName = nodeDict[@"nickname"];
        if (nodeDict[@"userId"] != nil)
            self.userId = nodeDict[@"userId"];
//        if (nodeDict[@""] != nil)
//            self.parentId;
//        if (nodeDict[@"child"] != nil && [nodeDict[@"child"] count] > 0)
//            self.children = nodeDict[@"child"];
//        else
//            _children = @[];
    }
    return self;
}

//-(instancetype)initDepart:(NSDictionary *)nodeDict  allData:(NSDictionary *)allDict{
//    self = [super init];
//    if (self) {
//        
//        
//        if (nodeDict[@"departName"] != nil)
//            self.departName = nodeDict[@"departName"];
//            self.createUserId
//            self.empNum
//            self.employees
//            self.departId = nodeDict[@"id"];
//        {
//            "companyId": "591e5ea35da45bc34f99d940",
//            "createTime": 1495162531,
//            "createUserId": 10007882,
//            "departName": "跳跳糖",
//            "empNum": 1,
//            "employees": [
//                          {
//                              "companyId": "591e5ea35da45bc34f99d940",
//                              "departmentId": "591e5ea35da45bc34f99d941",
//                              "id": "591e5ea35da45bc34f99d942",
//                              "role": 3,
//                              "userId": 10007882
//                          }
//                          ],
//            "id": "591e5ea35da45bc34f99d941"
//        }
//    }
//    return self;
//}
//
///** 创建部门节点 */
//+(instancetype)WH_departmentObjectWith:(NSDictionary *)nodeDict allData:(NSDictionary *)allDict{
//    return [[self alloc] initDepart:nodeDict allData:allDict];
//}

-(void)setChildren:(NSArray *)children{
    if ([children[0] isKindOfClass:[WH_Organiz_WHObject class]]) {
        _children = children;
        return;
    }
    NSMutableArray *childArray = [NSMutableArray array];
    for (NSDictionary * childDict in children) {
        WH_Organiz_WHObject * organiz = [WH_Organiz_WHObject WH_organizObjectWithDict:childDict];
        [childArray addObject:organiz];
    }
    _children = [NSArray arrayWithArray:childArray];
}
+(id)WH_organizObjectWithDict:(NSDictionary *)nodeDict
{
    return [[self alloc] initWithDict:nodeDict];
}

- (void)WH_addChild:(id)child
{
    NSMutableArray *children = [self.children mutableCopy];
    [children insertObject:child atIndex:0];
    _children = [children copy];
}

- (void)WH_removeChild:(id)child
{
    NSMutableArray *children = [self.children mutableCopy];
    [children removeObject:child];
    _children = [children copy];
}


@end
