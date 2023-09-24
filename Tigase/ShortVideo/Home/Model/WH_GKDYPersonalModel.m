//
//  GKDYPersonalModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYPersonalModel.h"

@implementation WH_GKDYUserModel

@end

@implementation WH_GKDYUserVideoList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [WH_GKDYVideoModel class] };
}

@end

@implementation WH_GKDYFavorVideoList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [WH_GKDYVideoModel class] };
}

@end

@implementation WH_GKDYPersonalModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"user"            : [WH_GKDYUserModel class],
             @"user_video_list" : [WH_GKDYUserVideoList class],
             @"favor_video_list": [WH_GKDYFavorVideoList class] };
}


- (void)sp_getUsersMostFollowerSuccess {
    NSLog(@"Get Info Success");
}
@end
