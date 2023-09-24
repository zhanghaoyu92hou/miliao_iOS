//
//  WH_AdvertisingViewController.h
//  Tigase
//
//  Created by Apple on 2019/10/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *advertisingImageUrl = @"advertisingImageUrl";

@interface WH_AdvertisingViewController : UIViewController
@property (nonatomic, copy) void(^skipActionBlock)(void); //传递view的点击时机
@end

NS_ASSUME_NONNULL_END
