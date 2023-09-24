//
//  WH_JXLiveGift_WHObject.m
//  Tigase_imChatT
//
//  Created by 1 on 17/8/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXLiveGift_WHObject.h"

@implementation WH_JXLiveGift_WHObject

+(instancetype)liveGiftObjectWith:(NSDictionary *)dataDict{
    return [[WH_JXLiveGift_WHObject alloc] initWith:dataDict];
}

-(instancetype)initWith:(NSDictionary *)dataDict{
    self = [super init];
    if (self) {
        if (dataDict[@"giftId"] != nil)
            self.wh_giftId = dataDict[@"giftId"];
        if (dataDict[@"name"] != nil)
            self.wh_name = dataDict[@"name"];
        if (dataDict[@"photo"] != nil)
            self.wh_photo = dataDict[@"photo"];
        if (dataDict[@"price"] != nil)
            self.price = [NSString stringWithFormat:@"%@",dataDict[@"price"]];
        if (dataDict[@"type"] != nil)
            self.type = [NSString stringWithFormat:@"%@",dataDict[@"type"]];
        
    }
    return self;
}



@end
