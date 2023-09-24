//
//  JXSelectMusicModel.h
//  Tigase_imChatT
//
//  Created by p on 2018/12/17.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXSelectMusicModel: NSObject

@property (nonatomic, assign) CGFloat musicLength;
@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *nikeName;
@property (nonatomic, assign) int useCount;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *name;

+ (WH_JXSelectMusicModel *) setModelWithDict:(NSDictionary *)dict;



@end
