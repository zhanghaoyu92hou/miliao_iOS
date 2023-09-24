//
//  GKDYVideoModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_GKDYVideoAuthorModel : NSObject

@property (nonatomic, copy) NSString        *wh_fans_num;
@property (nonatomic, copy) NSString        *wh_follow_num;
@property (nonatomic, copy) NSString        *wh_gender;
@property (nonatomic, copy) NSString        *wh_intro;
@property (nonatomic, copy) NSString        *wh_is_follow;
@property (nonatomic, copy) NSString        *wh_name_show;
@property (nonatomic, copy) NSString        *wh_portrait;
@property (nonatomic, copy) NSString        *wh_user_id;
@property (nonatomic, copy) NSString        *wh_user_name;

@end

@interface WH_GKDYVideoModel : NSObject

@property (nonatomic, copy) NSString        *agree_num;
@property (nonatomic, copy) NSString        *agreed_num;
@property (nonatomic, strong) WH_GKDYVideoAuthorModel   *author;
@property (nonatomic, copy) NSString        *comment_num;
@property (nonatomic, copy) NSString        *create_time;
@property (nonatomic, copy) NSString        *first_frame_cover;
@property (nonatomic, copy) NSString        *is_deleted;
@property (nonatomic, copy) NSString        *is_private;
@property (nonatomic, copy) NSString        *need_hide_title;
@property (nonatomic, copy) NSString        *play_count;
@property (nonatomic, copy) NSString        *post_id;
@property (nonatomic, copy) NSString        *share_num;
@property (nonatomic, copy) NSString        *tags;
@property (nonatomic, copy) NSString        *thread_id;
@property (nonatomic, copy) NSString        *thumbnail_height;
@property (nonatomic, copy) NSString        *thumbnail_url;
@property (nonatomic, copy) NSString        *thumbnail_width;
@property (nonatomic, copy) NSString        *title;
@property (nonatomic, copy) NSString        *video_duration;
@property (nonatomic, copy) NSString        *video_height;
@property (nonatomic, copy) NSString        *video_length;
@property (nonatomic, copy) NSString        *video_log_id;
@property (nonatomic, copy) NSString        *video_url;
@property (nonatomic, copy) NSString        *video_width;

@property (nonatomic, assign) BOOL isPraise;
@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSString *userId;
@property(nonatomic,strong) NSMutableArray * replys;
@property (nonatomic, assign) CGFloat height; // 分类短视频cell 高度


- (void)WH_getDataFromDict:(NSDictionary *)dict;



NS_ASSUME_NONNULL_END
- (void)sp_checkNetWorking;
@end
