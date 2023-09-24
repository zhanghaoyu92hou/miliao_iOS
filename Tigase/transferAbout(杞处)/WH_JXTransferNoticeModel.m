//
//  WH_JXTransferNoticeModel.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTransferNoticeModel.h"

@implementation WH_JXTransferNoticeModel

- (void)getTransferNoticeWithDict:(NSDictionary *)dict {
    self.userId = dict[@"userId"];
    self.userName = dict[@"userName"];
    self.toUserId = dict[@"toUserId"];
    self.toUserName  = dict[@"toUserName"];
    self.money = [dict[@"money"] doubleValue];
    self.type = [dict[@"type"] intValue];
    self.createTime  = [self getTime:dict[@"createTime"]];
}

- (NSString *)getTime:(NSString *)time {
    NSTimeInterval interval    = [time doubleValue];
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString*currentDateStr = [formatter stringFromDate: date];
    
    return currentDateStr;
}

@end
