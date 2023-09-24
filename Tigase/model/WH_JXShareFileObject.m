//
//  WH_JXShareFileObject.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/6.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXShareFileObject.h"

@implementation WH_JXShareFileObject


+(WH_JXShareFileObject *)shareFileWithDict:(NSDictionary *)dict{
    WH_JXShareFileObject * shareFile = [[WH_JXShareFileObject alloc] init];
    [shareFile WH_getDataFromDict:dict];
    return shareFile;
}
-(void)WH_getDataFromDict:(NSDictionary *)dict{
    if(dict[@"nickname"])
        self.createUserName = dict[@"nickname"];
    if(dict[@"roomId"])
        self.roomId = dict[@"roomId"];
    if(dict[@"shareId"])
        self.shareId = dict[@"shareId"];
    if(dict[@"size"])
        self.size = dict[@"size"];
    if(dict[@"time"])
        self.time = dict[@"time"];
    if(dict[@"type"])
        self.type = dict[@"type"];
    if(dict[@"url"])
        self.url = dict[@"url"];
    if(dict[@"userId"])
        self.userId = [NSString stringWithFormat:@"%@",dict[@"userId"]];
    if(dict[@"name"])
        self.fileName = dict[@"name"];
//    self.fileName = [self.url substringFromIndex:self.url.length-10];
    
}

@end
