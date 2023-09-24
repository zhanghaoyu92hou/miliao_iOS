//
//  WH_JXLiveMem_WHObject.m
//  Tigase_imChatT
//
//  Created by 1 on 17/8/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXLiveMem_WHObject.h"

@implementation WH_JXLiveMem_WHObject

+(instancetype)liveMemObjectWith:(NSDictionary *)dataDict{
    return [[WH_JXLiveMem_WHObject alloc] initWith:dataDict];
}

-(instancetype)initWith:(NSDictionary *)dataDict{
    self = [super init];
    if (self) {
        if (dataDict[@"createTime"] != nil)
            self.createTime = dataDict[@"createTime"];
        if (dataDict[@"id"] != nil)
            self.memId = dataDict[@"id"];
        if (dataDict[@"nickName"] != nil)
            self.nickName = dataDict[@"nickName"];
        if (dataDict[@"number"] != nil)
            self.number = dataDict[@"number"];
        if (dataDict[@"online"] != nil)
            self.online = dataDict[@"online"];
        if (dataDict[@"roomId"] != nil)
            self.roomId = dataDict[@"roomId"];
        if (dataDict[@"state"] != nil)
            self.state = dataDict[@"state"];
        if (dataDict[@"type"] != nil)
            self.type = dataDict[@"type"];
        if (dataDict[@"userId"] != nil)
            self.userId = [NSString stringWithFormat:@"%@",dataDict[@"userId"]];
        
    }
    return self;
}


@end
