//
//  DepartObject.h
//  Tigase_imChatT
//
//  Created by 1 on 17/5/11.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//


@interface WH_DepartObject : NSObject


@property (nonatomic,copy) NSString * departName;
@property (nonatomic,copy) NSString * departId;
/** 父节点Id */
@property (copy, nonatomic) NSString * parentId;

@property (copy, nonatomic) NSString * companyId;
@property (nonatomic,copy) NSString * createUserId;
@property (nonatomic,assign) NSInteger empNum;
/**  子员工数组 */
@property (nonatomic,strong) NSArray * employees;
/** 子部门数组 */
@property (nonatomic,strong) NSArray * departes;

/** 子节点数组,departes employees 的和 */
@property (strong, nonatomic) NSArray *children;

+(instancetype)WH_departmentObjectWith:(NSDictionary *)nodeDict allData:(NSMutableArray *)allDict;

- (void)WH_addChild:(id)child;
- (void)WH_removeChild:(id)child;

@end
