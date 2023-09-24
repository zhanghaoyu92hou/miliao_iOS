//
//  JXMapData.m
//  CustomMKAnnotationView
//
//  Created by JianYe on 14-2-8.
//  Copyright (c) 2014年 Jian-Ye. All rights reserved.
//

#import "JXMapData.h"
#import "JXPlaceMarkModel.h"

@implementation JXMapData
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.latitude = [dictionary objectForKey:@"latitude"];
        self.longitude = [dictionary objectForKey:@"longitude"];
        self.title = [dictionary objectForKey:@"title"];
        self.subtitle = [dictionary objectForKey:@"subtitle"];
//        self.imageUrl = ;
    }
    return self;
}
+ (JXMapData *)modelWithJXPlaceMarkModel:(JXPlaceMarkModel *)model
{
    JXMapData *model0 = [[JXMapData alloc] init];
    /*
     @property (nonatomic,copy)NSString *latitude;
     @property (nonatomic,copy)NSString *longitude;
     @property (nonatomic,copy)NSString *title;
     @property (nonatomic,copy)NSString *subtitle;
     @property (nonatomic,copy)NSString *imageUrl;
     */
    model0.latitude = [NSString stringWithFormat:@"%f",model.latitude];
    model0.longitude = [NSString stringWithFormat:@"%f",model.longitude];
    model0.title = model.name;
    model0.subtitle = model.address; //去掉国家名
    model0.imageUrl = model.imageUrl;   //去掉省份名
    
    return model0;
}

-(CLLocationCoordinate2D)coordinate2D{
    double latitude = [self.latitude doubleValue];
    double longitude = [self.longitude doubleValue];
    CLLocationCoordinate2D coor = (CLLocationCoordinate2D){latitude,longitude};
    return coor;
}
@end
