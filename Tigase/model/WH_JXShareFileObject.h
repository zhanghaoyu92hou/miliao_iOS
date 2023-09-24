//
//  WH_JXShareFileObject.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/6.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXShareFileObject : NSObject

@property (nonatomic,copy) NSString * createUserName;
@property (nonatomic,copy) NSString * roomId;
@property (nonatomic,copy) NSString * shareId;
@property (nonatomic,copy) NSString * size;
@property (nonatomic,copy) NSNumber * time;
@property (nonatomic,copy) NSNumber * type;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) NSString * userId;
@property (nonatomic,copy) NSString * fileName;

+(WH_JXShareFileObject *)shareFileWithDict:(NSDictionary *)dict;

@end
