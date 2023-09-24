//
//  WH_JXMsgAndUserObject.h
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXMsgAndUserObject : NSObject
@property (nonatomic,strong) WH_JXMessageObject* message;
@property (nonatomic,strong) WH_JXUserObject* user;

+(WH_JXMsgAndUserObject *)unionWithMessage:(WH_JXMessageObject *)aMessage andUser:(WH_JXUserObject *)aUser;
@end
