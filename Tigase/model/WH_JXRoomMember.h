//
//  JXRoomMember.h
//  Tigase_imChatT
//
//  Created by 1 on 17/6/27.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXRoomMember : NSObject{
    NSString* _tableName;
}


//@property (nonatomic, strong) WH_JXUserObject * user;
@property (nonatomic, strong) NSString * roomId;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, assign) NSUInteger isAdmin;

@end
