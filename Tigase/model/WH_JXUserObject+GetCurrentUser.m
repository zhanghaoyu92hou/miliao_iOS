//
//  WH_JXUserObject+GetCurrentUser.m
//  Tigase
//
//  Created by 齐科 on 2019/9/21.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXUserObject+GetCurrentUser.h"
#import <objc/runtime.h>
static NSString *completeKey = @"completeKey";
@implementation WH_JXUserObject (GetCurrentUser)
/**
 setter方法
 */
- (void)setComplete:(getCurrentUerComplete)complete {
    objc_setAssociatedObject(self, &completeKey, complete, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

/**
 getter方法
 */
- (getCurrentUerComplete)complete {
    return objc_getAssociatedObject(self, &completeKey);
}

- (void)getCurrentUser {
    [[ATMHud sharedInstance] show];
    [g_server getUser:self.userId toView:self];
}

#pragma mark ---- Http Result
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [self objectFromServerDictionary:dict];
    [self saveCurrentUser:nil];
    if (self.complete) {
        self.complete(HttpRequestSuccess, dict, nil);
    }
    [[ATMHud sharedInstance] hide];
}
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    
    if (self.complete) {
        self.complete(HttpRequestFailed, dict, nil);
    }
    return WH_show_error;
}
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    if (self.complete) {
        self.complete(HttpRequestError, nil, error);
    }
    [[ATMHud sharedInstance] hide];
    return WH_hide_error;
}
#pragma mark ---- Data Save&Read
- (void)saveCurrentUser:(NSDictionary *_Nullable)dict {
    if (!dict) {
        dict = [self objectToDictionary];
        NSLog(@"saveCurrentUser Dict Not Exsited userId == %@", dict[@"userId"]);
    }
    NSLog(@"saveCurrentUser userId == %@", dict[@"userId"]);
   BOOL saveResult = [dict writeToFile:[docFilePath stringByAppendingPathComponent:@"userInfo.plist"] atomically:YES];
    if (saveResult) {
        NSLog(@"保存成功");
    }else {
        NSLog(@"保存失败");
    }
}
- (void)getCurrentUserFromDocument {
    NSString *userDicPath = [docFilePath stringByAppendingPathComponent:@"userInfo.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:userDicPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:userDicPath];
        [self objectFromDocumentDictionary:dict];
    }else {
        NSLog(@"用户plist文件不存在");
    }
}

@end
