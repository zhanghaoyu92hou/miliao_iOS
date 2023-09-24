//
//  WH_JXNetwork.h
//  WH_JXNetwork
//
//  Created by Hao Tan on 11-11-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WH_JXNetwork;

@protocol WH_JXNetworkDelegate <NSObject>

-(void)WH_requestSuccess:(WH_JXNetwork*)task;
-(void)WH_requestError:(WH_JXNetwork *)task;

@end


@interface WH_JXNetwork : NSObject


@property (nonatomic, strong) NSError *wh_error;
@property (nonatomic, strong) NSString *wh_action;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *wh_downloadFile;
@property (nonatomic, assign) NSInteger wh_timeout;
@property (nonatomic, assign) long wh_uploadDataSize;//只返回最后一个文件的大小

@property (nonatomic, weak) id wh_toView;
@property (nonatomic, strong) id wh_userData;
@property (nonatomic, strong) id wh_param;
@property (nonatomic, weak) id<WH_JXNetworkDelegate> delegate;
@property (nonatomic, strong) id wh_responseData;
@property (nonatomic, strong) NSString *wh_messageId;

- (void)wh_go;              //开始下载
- (void)wh_stop;           //停止下载
- (BOOL)wh_isImage;
- (BOOL)wh_isVideo;
- (BOOL)wh_isAudio;

- (id)init;
- (void)wh_setPostValue:(id <NSObject>)value forKey:(NSString *)key;
- (void)wh_setData:(NSData *)data forKey:(NSString *)key messageId:(NSString *)messageId;

@end
