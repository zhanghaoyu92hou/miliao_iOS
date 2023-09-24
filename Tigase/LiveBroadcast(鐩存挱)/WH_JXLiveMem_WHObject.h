//
//  WH_JXLiveMem_WHObject.h
//  Tigase_imChatT
//
//  Created by 1 on 17/8/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXLiveMem_WHObject : NSObject

@property (nonatomic, copy) NSNumber * createTime;

@property (nonatomic, copy) NSString * memId;

@property (nonatomic, copy) NSString * nickName;
@property (nonatomic, copy) NSNumber * number;

@property (nonatomic, copy) NSNumber * online;

@property (nonatomic, copy) NSString * roomId;

@property (nonatomic, copy) NSNumber * state;

@property (nonatomic, copy) NSNumber * type;

@property (nonatomic, copy) NSString * userId;

+(instancetype)liveMemObjectWith:(NSDictionary *)dataDict;

@end
