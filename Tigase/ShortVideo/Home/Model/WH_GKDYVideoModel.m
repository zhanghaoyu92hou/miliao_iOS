//
//  GKDYVideoModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "WH_GKDYVideoModel.h"

@implementation WH_GKDYVideoAuthorModel

@end

@implementation WH_GKDYVideoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"author" : [WH_GKDYVideoAuthorModel class]};
}

- (void)WH_getDataFromDict:(NSDictionary *)dict {
    self.title = [[dict objectForKey:@"body"] objectForKey:@"text"];
    NSArray *images = [[dict objectForKey:@"body"] objectForKey:@"images"];
    self.first_frame_cover = [images.firstObject objectForKey:@"oUrl"];
    self.thumbnail_url = self.first_frame_cover;
    
    NSArray *videos = [[dict objectForKey:@"body"] objectForKey:@"videos"];
    self.video_url = [videos.firstObject objectForKey:@"oUrl"];
    self.video_length = [videos.firstObject objectForKey:@"size"];
    self.video_duration = [NSString stringWithFormat:@"%ld",[[videos.firstObject objectForKey:@"length"] integerValue] / 1000];
    self.post_id = [dict objectForKey:@"msgId"];
    self.agree_num = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"count"] objectForKey:@"praise"]];
    self.comment_num = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"count"] objectForKey:@"comment"]];
    self.share_num = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"count"] objectForKey:@"share"]];
    
    self.isPraise = [[dict objectForKey:@"isPraise"] boolValue];
    self.msgId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msgId"]];
    
    NSString *s = [dict objectForKey:@"userId"];
    self.userId = s;
    NSString* dir  = [NSString stringWithFormat:@"%d",[s intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir,s];
    self.author = [[WH_GKDYVideoAuthorModel alloc] init];
    self.author.wh_portrait = url;
    self.author.wh_name_show = [dict objectForKey:@"nickname"];
    
    
    NSArray *p = [dict objectForKey:@"comments"];
    self.replys = [NSMutableArray array];
    for(NSInteger i = 0; i < p.count; i++){
        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
        reply.font = sysFontWithSize(15);
        reply.textColor = [UIColor whiteColor];
        reply.type=reply_data_comment;
        reply.addHeight = 0;
        reply.messageId=self.msgId;
        NSDictionary *row = [p objectAtIndex:i];
        [reply WH_getDataFromDict:row];
        [self.replys addObject:reply];
    }
    CGSize size = [self.title boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH/2-2, 45) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(13)} context:nil].size;
    self.height = size.height;
}



- (void)sp_checkNetWorking {
    NSLog(@"Get Info Failed");
}
@end
