//
//  GKDYPersonalModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WH_GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_GKDYUserModel : NSObject

@property (nonatomic, copy) NSString    *intro;
@property (nonatomic, copy) NSString    *age;
@property (nonatomic, copy) NSString    *nani_id;
@property (nonatomic, copy) NSString    *club_num;
@property (nonatomic, copy) NSString    *is_follow;
@property (nonatomic, copy) NSString    *fans_num;
@property (nonatomic, copy) NSString    *user_id;
@property (nonatomic, copy) NSString    *video_num;
@property (nonatomic, copy) NSString    *user_name;
@property (nonatomic, copy) NSString    *portrait;
@property (nonatomic, copy) NSString    *name_show;
@property (nonatomic, copy) NSString    *agree_num;
@property (nonatomic, copy) NSString    *favor_num;
@property (nonatomic, copy) NSString    *gender;
@property (nonatomic, copy) NSString    *follow_num;

@end

@interface WH_GKDYUserVideoList : NSObject

@property (nonatomic, copy) NSString        *has_more;
@property (nonatomic, strong) NSArray       *list;

@end

@interface WH_GKDYFavorVideoList : NSObject

@property (nonatomic, copy) NSString        *has_more;
@property (nonatomic, strong) NSArray       *list;

@end

@interface WH_GKDYPersonalModel : NSObject

@property (nonatomic, strong) WH_GKDYUserModel         *user;
@property (nonatomic, strong) WH_GKDYUserVideoList     *user_video_list;
@property (nonatomic, strong) WH_GKDYFavorVideoList    *favor_video_list;



NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostFollowerSuccess;
@end
