//
//  WH_JXShareUser.h
//  share
//
//  Created by 1 on 2019/3/21.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WH_JXShareUser : NSObject
@property (nonatomic,strong) NSString* wh_userId;//房间时，等于roomJid
@property (nonatomic,strong) NSString* wh_roomId;//接口的roomId
@property (nonatomic,strong) NSString* wh_userNickname;
@property (nonatomic,strong) NSString* wh_remarkName;  // 备注
@property (nonatomic,strong) NSArray* wh_role; // 身份  1=游客（用于后台浏览数据）；2=公众号 ；3=机器账号，由系统自动生成；4=客服账号;5=管理员；6=超级管理员；7=财务；


+ (instancetype)shareInstance;

// 获取好友列表
- (NSMutableArray *)WH_getAllUser;

// 搜索聊天记录
-(NSArray <WH_JXShareUser *>*)WH_fetchSearchUserWithString:(NSString *)str;


@end

