//
//  JXSelectMusicModel.m
//  Tigase_imChatT
//
//  Created by p on 2018/12/17.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXSelectMusicModel.h"

@implementation WH_JXSelectMusicModel : NSObject


+ (WH_JXSelectMusicModel *) setModelWithDict:(NSDictionary *)dict {
    WH_JXSelectMusicModel *model = [[WH_JXSelectMusicModel alloc] init];
    model.musicLength = [[dict objectForKey:@"length"] floatValue];
    model.musicId = [dict objectForKey:@"id"];
    model.nikeName = [dict objectForKey:@"nikeName"];
    model.useCount = [[dict objectForKey:@"useCount"] intValue];
    model.path = [dict objectForKey:@"path"];
    model.cover = [dict objectForKey:@"cover"];
    model.name = [dict objectForKey:@"name"];
    
    return model;
}



@end
