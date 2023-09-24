//
//  MiXin_JXLiveGift_MiXinObject.m
//  shiku_im
//
//  Created by 1 on 17/8/1.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "MiXin_JXLiveGift_MiXinObject.h"

@implementation MiXin_JXLiveGift_MiXinObject

+(instancetype)liveGiftObjectWith:(NSDictionary *)dataDict{
    return [[MiXin_JXLiveGift_MiXinObject alloc] initWith:dataDict];
}

-(instancetype)initWith:(NSDictionary *)dataDict{
    self = [super init];
    if (self) {
        if (dataDict[@"giftId"] != nil)
            self.giftId = dataDict[@"giftId"];
        if (dataDict[@"name"] != nil)
            self.name = dataDict[@"name"];
        if (dataDict[@"photo"] != nil)
            self.photo = dataDict[@"photo"];
        if (dataDict[@"price"] != nil)
            self.price = [NSString stringWithFormat:@"%@",dataDict[@"price"]];
        if (dataDict[@"type"] != nil)
            self.type = [NSString stringWithFormat:@"%@",dataDict[@"type"]];
        
    }
    return self;
}



@end
