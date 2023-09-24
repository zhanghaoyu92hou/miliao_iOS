//
//  WH_Organiz_WHObject.h
//  Tigase_imChatT
//
//  Created by 1 on 17/5/11.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class WH_JXUserObject;

@interface WH_Organiz_WHObject : NSObject

/** 节点名 */
@property (copy, nonatomic) NSString *nodeName;
/** 节点Id */
@property (copy, nonatomic) NSString *nodeId;
/** 父节点Id */
@property (copy, nonatomic) NSString * parentId;

/** 类型 */
@property (assign, nonatomic) int type;

/** 节点为员工时有值,否则为nil */
@property (copy, nonatomic) NSString *userId;

/** 子节点数组 */
@property (strong, nonatomic) NSArray *children;


- (id)initWithDict:(NSDictionary *)nodeDict;

+ (id)WH_organizObjectWithDict:(NSDictionary *)nodeDict;


- (void)WH_addChild:(id)child;
- (void)WH_removeChild:(id)child;


@end
