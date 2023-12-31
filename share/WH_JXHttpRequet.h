//
//  WH_JXHttpRequet.h
//  share
//
//  Created by 1 on 2019/3/21.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXNetwork.h"

#define wh_act_UploadFile @"upload/UploadServlet" //上传文件
#define act_SendMsg    @"user/sendMsg" //发消息
#define wh_act_MsgAdd @"b/circle/msg/add" //发送生活圈

@interface WH_JXHttpRequet : NSObject

//上传文件
-(void)WH_uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView;
// 发送消息
- (void)WH_sendMsgToUserId:(NSString *)jid chatType:(int)chatType type:(int)type content:(NSString *)content fileName:(NSString *)fileName toView:(id)toView;
//发送生活圈
-(void)WH_addMessage:(NSString*)text type:(int)type data:(NSDictionary*)dict flag:(int)flag  toView:(id)toView;


// 返回图片本地路径
- (NSString *)WH_getDataUrlWithImage:(UIImage *)image;
// 返回视频本地路径
- (NSString *)WH_getDataUrlWithVideo:(NSData *)video;

// 获取视频第一帧图片
-(UIImage*)WH_getFirstImageFromVideo:(NSString*)video;
// 获取视频时长
- (CGFloat)WH_getVideoLength:(NSURL *)url;
//压缩
- (NSString *)WH_compressionVideoWithUlr:(NSURL *)url;

+ (instancetype)shareInstance;

@property (nonatomic, strong) NSString *wh_access_token;
@property (nonatomic, strong) NSString *wh_userId;
@property (nonatomic, strong) NSString *wh_userName;
@property (nonatomic, strong) NSString *wh_apiUrl;
@property (nonatomic, strong) NSString *wh_uploadUrl;

@end

