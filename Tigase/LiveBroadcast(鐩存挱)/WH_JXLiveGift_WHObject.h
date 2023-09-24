//
//  WH_JXLiveGift_WHObject.h
//  Tigase_imChatT
//
//  Created by 1 on 17/8/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXLiveGift_WHObject : NSObject

@property (nonatomic,copy) NSString * wh_giftId;
@property (nonatomic,copy) NSString * wh_name;
@property (nonatomic,copy) NSString * wh_photo;
@property (nonatomic,copy) NSString * price;
@property (nonatomic,copy) NSString * type;

//@property (nonatomic)


+(instancetype)liveGiftObjectWith:(NSDictionary *)dataDict;
@end
