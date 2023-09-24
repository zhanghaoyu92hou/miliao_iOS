//
//  WH_JXRecordModel.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/4/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXRecordModel.h"

@implementation WH_JXRecordModel

- (void)getDataWithDict:(NSDictionary *)dict {
    self.money = [[dict objectForKey:@"money"] doubleValue];
    self.desc = [dict objectForKey:@"desc"];
    self.payType = [[dict objectForKey:@"payType"] intValue];
    self.time = [[dict objectForKey:@"time"] longValue];
    self.status = [[dict objectForKey:@"status"] intValue];
}

@end
