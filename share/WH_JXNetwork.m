//
//  WH_JXNetwork.m
//  WH_JXNetwork
//
//  Created by Hao Tan on 11-11-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WH_JXNetwork.h"
#import <CommonCrypto/CommonDigest.h>

//#import "NSDataEx.h"


//#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"
//#define MULTIPART @"multipart/form-data"
//#define MULTIPART @"application/x-www-form-urlencoded"

#define UploadDefultTimeout     60
#define NormalDefultTimeout     15

@interface WH_JXNetwork ()

@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) NSMutableDictionary *uploadDataDic;
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, assign) BOOL isUpload;

@end

@implementation WH_JXNetwork

@synthesize wh_action;
@synthesize wh_toView;
@synthesize wh_downloadFile;


static AFHTTPSessionManager *afManager;

-(AFHTTPSessionManager *)sharedHttpSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afManager = [AFHTTPSessionManager manager];
        afManager.requestSerializer.timeoutInterval = 30.0;
    });
    
    return afManager;
}

- (id) init {
    if (self = [super init]) {
        self.params = [NSMutableDictionary dictionary];
        self.uploadDataDic = [NSMutableDictionary dictionary];
        self.httpManager = [self sharedHttpSessionManager];
        self.httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];// 请求
        self.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];// 响应
//        self.httpManager.requestSerializer.timeoutInterval = WH_connect_timeout;
    }
    
    return self;
}

-(void)dealloc{
    self.wh_action = nil;
    self.wh_toView = nil;
//    self.userInfo = nil;
    self.delegate = nil;
    self.url = nil;
    self.wh_param = nil;
    self.params = nil;
    self.uploadDataDic = nil;
    self.wh_downloadFile = nil;
//    [self.httpManager release];
//    
//    [super dealloc];
}

-(BOOL)wh_isImage{
    return [wh_action rangeOfString:@".jpg"].location != NSNotFound || [wh_action rangeOfString:@".png"].location != NSNotFound || [wh_action rangeOfString:@".gif"].location != NSNotFound;
}

-(BOOL)wh_isVideo{
    NSString* s = [wh_action lowercaseString];
    BOOL b = [s rangeOfString:@".mp4"].location != NSNotFound
    || [s rangeOfString:@".qt"].location != NSNotFound
    || [s rangeOfString:@".mpg"].location != NSNotFound
    || [s rangeOfString:@".mov"].location != NSNotFound
    || [s rangeOfString:@".avi"].location != NSNotFound;
    return b;
}

-(BOOL)wh_isAudio{
    NSString* s = [wh_action lowercaseString];
    return [s rangeOfString:@".mp3"].location != NSNotFound || [s rangeOfString:@".amr"].location != NSNotFound|| [s rangeOfString:@".wav"].location != NSNotFound;
}

-(void)wh_go{
    
    if([self wh_isImage] || [self wh_isVideo] || [self wh_isAudio]) {
        self.isUpload = NO;
        [self downloadRequestData];
        
    }else {
        if (self.uploadDataDic.count > 0) {
            self.isUpload = YES;
            [self getSecret];
            [self upLoadRequestData];
        }else {
            self.isUpload = NO;
            [self getSecret];
            [self normalRequestData];
        }
    }
}

// 普通网络请求
- (void) normalRequestData {
    
    if (self.wh_timeout && self.wh_timeout > 0) {
        self.httpManager.requestSerializer.timeoutInterval = self.wh_timeout;
    }else {
        self.httpManager.requestSerializer.timeoutInterval = NormalDefultTimeout;
    }
    
    NSMutableString *urlStr = [NSMutableString string];
    if (YES) {
        NSRange range = [self.url rangeOfString:@"?"];
        if (range.location == NSNotFound) {
            
            urlStr = [NSMutableString stringWithFormat:@"%@?",self.url];
        }else{
            urlStr = [self.url mutableCopy];
        }
        for (NSString *key in self.params.allKeys) {
            NSString *str = [NSString stringWithFormat:@"&%@=%@",key, self.params[key]];
            [urlStr appendString:str];
        }
        
    }
    
    urlStr = [[urlStr stringByReplacingOccurrencesOfString:@" " withString:@""] copy];
    
    if ([self.wh_action isEqualToString:wh_act_Config]) {
        [self.httpManager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            // 转码
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            self.wh_responseData = string;
            NSLog(@"requestSuccess");
            if ([self.delegate respondsToSelector:@selector(WH_requestSuccess:)]) {
                [self.delegate WH_requestSuccess:self];
            }
            NSLog(@"urlStr = %@\nstring = %@", urlStr, string);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            self.wh_error = error;
            if ([self.delegate respondsToSelector:@selector(WH_requestError:)]) {
                [self.delegate WH_requestError:self];
            }
            NSLog(@"urlStr = %@\nerror = %@", urlStr, error);
        }];
    }else {
        [self.httpManager POST:self.url parameters:self.params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            // 转码
            NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            self.wh_responseData = string;
            NSLog(@"requestSuccess");
            if ([self.delegate respondsToSelector:@selector(WH_requestSuccess:)]) {
                [self.delegate WH_requestSuccess:self];
            }
            NSLog(@"urlStr = %@\nstring = %@", urlStr, string);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@:requestFailed",self.url);
            self.wh_error = error;
            if ([self.delegate respondsToSelector:@selector(WH_requestError:)]) {
                [self.delegate WH_requestError:self];
            }
            NSLog(@"urlStr = %@\nerror = %@", urlStr, error);
        }];
    }
}

// 上传
- (void) upLoadRequestData{
    
    if (self.wh_timeout && self.wh_timeout > 0) {
        self.httpManager.requestSerializer.timeoutInterval = self.wh_timeout;
    }else {
        NSUInteger dataLength = 0;
        for (NSString *key in self.uploadDataDic.allKeys) {
            NSData *data = self.uploadDataDic[key];
            dataLength = dataLength + data.length;
        }
        NSUInteger timeOut = dataLength / 1024 / 20;
        if (timeOut > UploadDefultTimeout) {
            self.httpManager.requestSerializer.timeoutInterval = timeOut;
        }else {
            self.httpManager.requestSerializer.timeoutInterval = UploadDefultTimeout;
        }
    }
    
    self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"image/gif",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"video/mp4",
                                                         @"video/quicktime",
                                                         nil];
    
    //上传图片/文字，只能同POST
    [self.httpManager POST:self.url parameters:self.params constructingBodyWithBlock:^(id  _Nonnull formData) {
        // 上传文件
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        for (NSString *key in self.uploadDataDic.allKeys) {
            NSData *data = self.uploadDataDic[key];
            NSString *mimeType = [self getUploadDataMimeType:key];
            [formData appendPartWithFileData:data name:key fileName:key mimeType:mimeType];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"---------- uploadProgress = %@",uploadProgress);
//        if (self.messageId.length > 0) {
//            [g_notify postNotificationName:kUploadFileProgressNotifaction object:@{@"uploadProgress":uploadProgress,@"file":self.messageId}];
//        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject = %@, task = %@",responseObject,task);
        
        // 转码
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        self.wh_responseData = string;
        
        NSLog(@"requestSuccess");
        if ([self.delegate respondsToSelector:@selector(WH_requestSuccess:)]) {
            [self.delegate WH_requestSuccess:self];
        }
        NSLog(@"urlStr = %@\nstring = %@", urlStr, string);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error = %@",error);
        self.wh_error = error;
        if ([self.delegate respondsToSelector:@selector(WH_requestError:)]) {
            [self.delegate WH_requestError:self];
        }
        NSLog(@"urlStr = %@\nerror = %@", urlStr, error);
    }];
}

// 下载
- (void) downloadRequestData {

    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *urlManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:conf];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.wh_action]];
    NSURLSessionDownloadTask *task = [urlManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
//        NSLog(@"文件下载进度:%lld/%lld",downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[targetPath lastPathComponent]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error ---- %@", error);
            self.wh_error = error;
            if ([self.delegate respondsToSelector:@selector(WH_requestError:)]) {
                [self.delegate WH_requestError:self];
            }
        }else {
            NSLog(@"downloadSuccess");
            NSString *downloadPath = [NSString stringWithFormat:@"%@", filePath];
            NSData *data = [NSData dataWithContentsOfURL:filePath];
            self.wh_responseData = data;
            if ([self.delegate respondsToSelector:@selector(WH_requestSuccess:)]) {
                [self.delegate WH_requestSuccess:self];
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
        }
    }];
    
    [task resume];

}

// 返回上传数据类型
- (NSString *) getUploadDataMimeType:(NSString *) key {
    NSString *mimeType = nil;
    key = [key lowercaseString];
    if ([key rangeOfString:@".jpg"].location != NSNotFound || [key rangeOfString:@"image"].location != NSNotFound) {
        mimeType = @"image/jpeg";
    }else if ([key rangeOfString:@".png"].location != NSNotFound) {
        mimeType = @"image/png";
        
    }else if ([key rangeOfString:@".mp3"].location != NSNotFound) {
        mimeType = @"audio/mpeg";
        
    }else if ([key rangeOfString:@".qt"].location != NSNotFound) {
        mimeType = @"video/quicktime";
        
    }else if ([key rangeOfString:@".mp4"].location != NSNotFound) {
        mimeType = @"video/mp4";
        
    }else if ([key rangeOfString:@".amr"].location != NSNotFound) {
        mimeType = @"audio/amr";
    }else if ([key rangeOfString:@".gif"].location != NSNotFound) {
        mimeType = @"image/gif";
    }else if ([key rangeOfString:@".mov"].location != NSNotFound) {
        mimeType = @"video/quicktime";
    }else if ([key rangeOfString:@".wav"].location != NSNotFound) {
        mimeType = @"audio/wav";
    }else {
        mimeType = @"";
    }
    
    return mimeType;
}

- (void)wh_stop{

    AFHTTPSessionManager *manager = [self sharedHttpSessionManager];
    [manager.operationQueue cancelAllOperations];
}

- (void)wh_setData:(NSData *)data forKey:(NSString *)key messageId:(NSString *)messageId
{
    if(data==nil)
        return;
    [self.uploadDataDic setObject:data forKey:key];
    self.wh_messageId = messageId;
    self.wh_uploadDataSize = data.length;
}

- (void)wh_setPostValue:(id <NSObject>)value forKey:(NSString *)key
{
    if(value==nil)
        return;
    [self.params setObject:value forKey:key];
}

// 接口加密
- (NSString *)getSecret {
    long time = (long)[[NSDate date] timeIntervalSince1970];
    [self wh_setPostValue:[NSString stringWithFormat:@"%ld",time] forKey:@"time"];
    
    NSString *secret;
    
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
    
    [str1 appendString:[[WH_JXHttpRequet shareInstance] wh_userId]];
    [str1 appendString:[[WH_JXHttpRequet shareInstance] wh_access_token]];
    secret = [self getMd5:str1];
    
    [self wh_setPostValue:secret forKey:@"secret"];
    
    return secret;
}

- (NSString *)getMd5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


@end
