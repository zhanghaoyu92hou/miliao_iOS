//
//  GKDYVideoViewModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WH_GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_GKDYVideoViewModel_WH : NSObject

@property (nonatomic, assign) BOOL  has_more;

- (void)Tigase_refreshNewList_TigaseWithSuccess:(void(^)(NSArray *list))success
                            failure:(void(^)(NSError *error))failure;

- (void)Tigase_refreshMoreList_TigaseWithSuccess:(void(^)(NSArray *list))success
                            failure:(void(^)(NSError *error))failure;



NS_ASSUME_NONNULL_END
- (void)Tigase_sp_TigasegetUsersMostLikedSuccess;
@end
