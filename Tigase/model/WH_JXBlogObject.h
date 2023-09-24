//
//  WH_JXBlogObject.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-5-31.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBLOG_UserID @"userId"
#define kBLOG_MsgID  @"msgId"
#define kBLOG_Time   @"time"

#define XMPP_TYPE_NEWCHAT 600  //
#define XMPP_TYPE_NEWGIFT 601  //
#define XMPP_TYPE_NEWPRIASE 602  //
#define XMPP_TYPE_NEWBLOG 603  //

@interface WH_JXBlogObject : NSObject{
    NSString* _tableName;
}

@property (nonatomic,strong) NSString* userId;
@property (nonatomic,strong) NSString* msgId;
@property (nonatomic,strong) NSDate*   time;

//数据库增删改查
-(BOOL)insert;
-(BOOL)delete;
-(BOOL)update;

+(WH_JXBlogObject*)sharedInstance;


//将对象转换为字典
-(NSDictionary*)toDictionary;
-(void)fromDataset:(WH_JXBlogObject*)obj rs:(FMResultSet*)rs;
-(void)fromDictionary:(WH_JXBlogObject*)obj dict:(NSDictionary*)aDic;
-(void)fromObject:(WH_JXMessageObject*)message;
-(BOOL)checkTableCreatedInDb:(FMDatabase *)db;

@end
