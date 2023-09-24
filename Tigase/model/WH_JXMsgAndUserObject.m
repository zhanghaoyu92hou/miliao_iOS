//
//  WH_JXMsgAndUserObject.m
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WH_JXMsgAndUserObject.h"

@implementation WH_JXMsgAndUserObject
@synthesize message,user;


+(WH_JXMsgAndUserObject *)unionWithMessage:(WH_JXMessageObject *)aMessage andUser:(WH_JXUserObject *)aUser
{
    WH_JXMsgAndUserObject *unionObject=[[WH_JXMsgAndUserObject alloc]init];
    unionObject.user = aUser;
    unionObject.message = aMessage;
//    NSLog(@"%d,%d",aMessage.retainCount,aUser.retainCount);
    return unionObject;
}

-(void)dealloc{
//    NSLog(@"WH_JXMsgAndUserObject.dealloc");
    self.user = nil;
    self.message = nil;
//    [super dealloc];
}



@end
