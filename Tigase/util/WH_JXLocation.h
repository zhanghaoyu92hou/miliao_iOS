//
//  JXLocation.h
//  Tigase_imChatT
//
//  Created by p on 2017/4/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WH_JXLocation;
@protocol JXLocationDelegate <NSObject>

// 定位后返回地理信息
- (void) location:(WH_JXLocation *)location CountryCode:(NSString *)countryCode CityName:(NSString *)cityName CityId:(NSString *)cityId Address:(NSString *)address Latitude:(double)lat Longitude:(double)lon;

- (void)location:(WH_JXLocation *)location getLocationWithIp:(NSDictionary *)dict;
- (void)location:(WH_JXLocation *)location getLocationError:(NSError *)error;

@end

@interface WH_JXLocation : NSObject

@property (nonatomic, weak) id<JXLocationDelegate> delegate;

// 开始定位
- (void) locationStart;

// 根据ip获取到地理位置
- (void) getLocationWithIp;


- (void)sp_getUsersMostFollowerSuccess;
@end
