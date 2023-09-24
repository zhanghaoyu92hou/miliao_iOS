//
//  JXSmallVideoViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/1/3.
//  Copyright © 2019年 Reese. All rights reserved.
//  短视频

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JXSmallVideoType) {
    JXSmallVideoTypeFood = 1,         // 美食
    JXSmallVideoTypeAttractions,      // 景点
    JXSmallVideoTypeCulture,          // 文化
    JXSmallVideoTypeToHaveFun,        // 玩乐
    JXSmallVideoTypeTheHotel,         // 酒店
    JXSmallVideoTypeShopping,         // 购物
    JXSmallVideoTypeMovement,         // 运动
    JXSmallVideoTypeOther,            // 其他
};

@interface JXSmallVideoViewController : UIViewController



@end
