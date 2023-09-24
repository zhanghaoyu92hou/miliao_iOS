//
//  OBSHanderTool.h
//  Tigase
//
//  Created by 闫振奎 on 2019/7/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface OBSHanderTool : NSObject
//uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView
+(void)handleUploadFile:(NSString *)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView success:(void(^)(int code,NSString * fileUrl,NSString *fileName)) success failed:(void(^) (NSError *error)) failed;

+(void)handleUploadFile:(NSArray*)files audio:(NSString*)audio video:(NSString*)video file:(NSString*)file type:(int)type validTime:(NSString *)validTime timeLen:(int)timeLen toView:(id)toView success:(void(^)(int code,NSDictionary * dict)) success failed:(void(^) (NSError *error)) failed;

/*
 * 上传头像
 */
+(void)WH_handleUploadOBSHeadImage:(NSString*)userId image:(UIImage*)image toView:(id)toView success:(void(^)(int code)) success failed:(void(^) (NSError *error)) failed;




NS_ASSUME_NONNULL_END
@end
