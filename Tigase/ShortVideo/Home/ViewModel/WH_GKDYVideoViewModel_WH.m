//
//  GKDYVideoViewModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYVideoViewModel_WH.h"
#import "WH_GKNetworking.h"
#import "NSObject+YYModel.h"

@interface WH_GKDYVideoViewModel_WH()

// 页码
@property (nonatomic, assign) NSInteger pn;

@end

@implementation WH_GKDYVideoViewModel_WH

- (void)Tigase_refreshNewList_TigaseWithSuccess:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    self.pn = 1;
    
    [self videoListRequestWithSuccess:success failure:failure];
}

- (void)Tigase_refreshMoreList_TigaseWithSuccess:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    self.pn ++;
    
    [self videoListRequestWithSuccess:success failure:failure];
}

- (void)videoListRequestWithSuccess:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"new_recommend_type"] = @"3";
    params[@"pn"] = @(self.pn);
    params[@"dl"] = @"505F80E58F3817291B7768CE59A90AF8";
    params[@"sign"] = @"3DD6882F963C25F5FA1ECA558F8CEF48";
    params[@"_timestamp"] = @"1537782764313";
    params[@"timestamp"] = @"1537782764313";
    params[@"net_type"] = @"1";
    
    // 推荐列表
    NSString *url = @"http://c.tieba.baidu.com/c/f/nani/recommend/list";
    
    [WH_GKNetworking get:url params:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"error_code"] integerValue] == 0) {
            NSDictionary *data = responseObject[@"data"];
            
            self.has_more = [data[@"has_more"] boolValue];
            
            NSMutableArray *array = [NSMutableArray new];
            for (NSDictionary *dic in data[@"video_list"]) {
                WH_GKDYVideoModel *model = [WH_GKDYVideoModel yy_modelWithDictionary:dic];
                [array addObject:model];
            }
            
            !success ? : success(array);
        }else {
            NSLog(@"%@", responseObject);
        }
    } failure:^(NSError * _Nonnull error) {
        !failure ? : failure(error);
    }];
}


- (void)Tigase_sp_TigasegetUsersMostLikedSuccess {
    NSLog(@"Get Info Failed");
}
@end
