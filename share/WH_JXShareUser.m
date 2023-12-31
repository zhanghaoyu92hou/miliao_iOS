//
//  WH_JXShareUser.m
//  share
//
//  Created by 1 on 2019/3/21.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXShareUser.h"
#import "FMDatabase.h"

@implementation WH_JXShareUser
static WH_JXShareUser *_user = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _user = [[WH_JXShareUser alloc] init];
    });
    return _user;
}

- (NSArray *)WH_getAllUser {
    
    NSMutableArray *listArr = [[NSMutableArray alloc] init];
    
    NSString *userId = [share_defaults objectForKey:kMY_ShareExtensionUserId];
    //获取分组的共享目录
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *fileName = [NSString stringWithFormat:@"%@.db",userId];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:fileName];
    //写入文件
    //    [copyPath writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"------ path: %@",fileName.lastPathComponent);
    //读取文件
    NSString *path = [fileURL.absoluteString substringFromIndex:7];
    NSLog(@"str = %@", path);
    FMDatabase *dataBase = [FMDatabase databaseWithPath:path];
    
    [dataBase open];
    NSString *queryString=[NSString stringWithFormat:@"select * from friend where (status=8 or  status=2) and length(content)>0 and userId != %@ order by topTime desc, timeSend desc", @"10001"];
    FMResultSet *result = [dataBase executeQuery:queryString];
    while ([result next]) {
        WH_JXShareUser *user=[[WH_JXShareUser alloc]init];
        [user userFromDataset:user rs:result];
        [listArr addObject:user];
    }
    return [listArr mutableCopy];
}

- (void)userFromDataset:(WH_JXShareUser*)obj rs:(FMResultSet*)rs{
    obj.wh_userId=[rs stringForColumn:@"userId"];
    obj.wh_roomId=[rs stringForColumn:@"roomId"];
    obj.wh_userNickname=[rs stringForColumn:@"userNickname"];
    obj.wh_remarkName=[rs stringForColumn:@"remarkName"];
    obj.wh_role=[rs objectForColumnName:@"role"];
}


// 搜索聊天记录
-(NSArray <WH_JXShareUser *>*)WH_fetchSearchUserWithString:(NSString *)str {

    NSString *userId = [share_defaults objectForKey:kMY_ShareExtensionUserId];
    //获取分组的共享目录
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *fileName = [NSString stringWithFormat:@"%@.db",userId];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:fileName];
    //写入文件
    //    [copyPath writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"------ path: %@",fileName.lastPathComponent);
    //读取文件
    NSString *path = [fileURL.absoluteString substringFromIndex:7];
    NSLog(@"str = %@", path);
    FMDatabase *dataBase = [FMDatabase databaseWithPath:path];
    
    [dataBase open];
    NSString *queryString=[NSString stringWithFormat:@"select * from friend where userNickname like '%%%@%%' order by timeSend desc", str];
    FMResultSet *rs=[dataBase executeQuery:queryString];
    
    NSMutableArray * resultArray = [NSMutableArray array];
    while ([rs next]) {
        WH_JXShareUser *p=[[WH_JXShareUser alloc]init];
        [p userFromDataset:p rs:rs];
        [resultArray addObject:p];
    }
    return resultArray;
}



@end
