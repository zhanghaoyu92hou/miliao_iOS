//
//  JXMapData.h
//  CustomMKAnnotationView
//
//  Created by JianYe on 14-2-8.
//  Copyright (c) 2014年 Jian-Ye. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JXPlaceMarkModel;
@interface JXMapData : NSObject

@property (nonatomic,copy)NSString *latitude;
@property (nonatomic,copy)NSString *longitude;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *subtitle;
@property (nonatomic,copy)NSString *imageUrl;
- (id)initWithDictionary:(NSDictionary *)dictionary;
-(CLLocationCoordinate2D)coordinate2D;
+ (JXMapData *)modelWithJXPlaceMarkModel:(JXPlaceMarkModel *)model;
@end
