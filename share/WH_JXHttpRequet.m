//
//  WH_JXHttpRequet.m
//  share
//
//  Created by 1 on 2019/3/21.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXHttpRequet.h"
#import "WH_JXCustomShareVC.h"

@interface WH_JXHttpRequet ()<WH_JXNetworkDelegate>
@property (nonatomic, strong) NSString *urlPath;

@end


@implementation WH_JXHttpRequet
static WH_JXHttpRequet *_httpRequet = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _httpRequet = [[WH_JXHttpRequet alloc] init];
    });
    return _httpRequet;
}


- (instancetype)init {
    if (self = [super init]) {
        self.wh_access_token = [share_defaults objectForKey:kMY_ShareExtensionToken];
        self.wh_userId = [share_defaults objectForKey:kMY_ShareExtensionUserId];
        self.wh_apiUrl = [share_defaults objectForKey:kApiUrl];
        self.wh_uploadUrl = [share_defaults objectForKey:kUploadUrl];

    }
    return self;
}

//上传文件到服务器（传路径）
-(void)WH_uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView{
    if(!file)
        return;
    if(![[NSFileManager defaultManager] fileExistsAtPath:file])
        return;
    
    WH_JXNetwork* p = [self addTask:wh_act_UploadFile param:nil toView:toView];

    [p wh_setPostValue:self.wh_userId forKey:@"userId"];
    if (!validTime) {
        validTime = @"-1";
    }
    [p wh_setPostValue:validTime forKey:@"validTime"];
    [p wh_setData:[NSData dataWithContentsOfFile:file] forKey:[file lastPathComponent] messageId:nil];
    p.wh_userData = [file lastPathComponent];
    p.wh_messageId = messageId;
    [p wh_go];
}


// 发送消息
- (void)WH_sendMsgToUserId:(NSString *)jid chatType:(int)chatType type:(int)type content:(NSString *)content fileName:(NSString *)fileName toView:(id)toView{
    WH_JXNetwork* p = [self addTask:act_SendMsg param:nil toView:toView];
    [p wh_setPostValue:jid forKey:@"jid"];
    [p wh_setPostValue:[NSNumber numberWithInt:chatType] forKey:@"chatType"];
    [p wh_setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p wh_setPostValue:content forKey:@"content"];
    [p wh_setPostValue:fileName forKey:@"fileName"];
    [p wh_setPostValue:self.wh_access_token forKey:@"access_token"];
    
    [p wh_go];
}


// 发送生活圈
-(void)WH_addMessage:(NSString*)text type:(int)type data:(NSDictionary*)dict flag:(int)flag toView:(id)toView{
    NSMutableArray* array;
    
    NSString * jsonFiles=nil;
    //    NSMutableArray* a=[[NSMutableArray alloc]init];
    
    array = [dict objectForKey:@"images"];
    NSString * jsonImages = nil;
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonImages = [array mj_JSONString];
        jsonFiles = jsonImages;
    }
    
    array = [dict objectForKey:@"videos"];
    NSString * jsonVideos=nil;
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonVideos = [array mj_JSONString];
        jsonFiles = jsonVideos;
        //        for(int i =0;i<[array count];i++)
        //            [a addObject:[[array objectAtIndex:i] objectForKey:@"oUrl"]];
        //        jsonVideos = [OderJsonwriter stringWithObject:a];
    }
    
    array = [dict objectForKey:@"audios"];
    NSString * jsonAudios=nil;
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonAudios = [array mj_JSONString];
        jsonFiles = jsonAudios;
        //        for(int i =0;i<[array count];i++)
        //            [a addObject:[[array objectAtIndex:i] objectForKey:@"oUrl"]];
        //        jsonAudios = [OderJsonwriter stringWithObject:a];
    }
    
    array = [dict objectForKey:@"files"];
    if([array count]>0){
        [self doCheckUploadResult:array];
        jsonFiles = [array mj_JSONString];
        //        for(int i =0;i<[array count];i++)
        //            [a addObject:[[array objectAtIndex:i] objectForKey:@"oUrl"]];
        //        jsonAudios = [OderJsonwriter stringWithObject:a];
    }
    
    
    array = nil;
    
    WH_JXNetwork* p = [self addTask:wh_act_MsgAdd param:nil toView:toView];
    [p wh_setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p wh_setPostValue:[NSNumber numberWithInt:flag] forKey:@"flag"];
//    [p setPostValue:[NSNumber numberWithInt:visible] forKey:@"visible"];
    [p wh_setPostValue:[NSNumber numberWithInt:1] forKey:@"cityId"];
    [p wh_setPostValue:self.wh_access_token forKey:@"access_token"];
    [p wh_setPostValue:text forKey:@"text"];
    if (type == 5) {
        [p wh_setPostValue:jsonFiles forKey:@"files"];
    }else if (type == 6) {
        [p wh_setPostValue:[dict objectForKey:@"sdkUrl"] forKey:@"sdkUrl"];
        [p wh_setPostValue:[dict objectForKey:@"sdkIcon"] forKey:@"sdkIcon"];
        [p wh_setPostValue:[dict objectForKey:@"sdkTitle"] forKey:@"sdkTitle"];
    }
    else {
        [p wh_setPostValue:jsonImages forKey:@"images"];
        [p wh_setPostValue:jsonAudios forKey:@"audios"];
        [p wh_setPostValue:jsonVideos forKey:@"videos"];
    }
//    [p setPostValue:myself.model forKey:@"model"];
//    [p setPostValue:myself.osVersion forKey:@"osVersion"];
//    [p setPostValue:myself.serialNumber forKey:@"serialNumber"];
//    [p setPostValue:lable forKey:@"lable"];
//
//    if (location.length > 0) {
//        [p setPostValue:[NSNumber numberWithDouble:coor.latitude] forKey:@"latitude"];
//        [p setPostValue:[NSNumber numberWithDouble:coor.longitude] forKey:@"longitude"];
//        [p setPostValue:location forKey:@"location"];
//    }
    
//    if (lookArray.count >0 && (visible == 3 || visible == 4)) {
//        NSString * lookStr = [lookArray componentsJoinedByString:@","];
//        NSString * arrayTitle = nil;
//        switch (visible) {
//            case 3:
//                arrayTitle = @"userLook";
//                break;
//            case 4:
//                arrayTitle = @"userNotLook";
//                break;
//            default:
//                arrayTitle = @"";
//                break;
//        }
//        [p setPostValue:lookStr forKey:arrayTitle];
//    }
    
//    if (remindArray.count > 0) {
//        [p setPostValue:[remindArray componentsJoinedByString:@","] forKey:@"userRemindLook"];
//    }
    
    [p wh_go];
}

-(void)doCheckUploadResult:(NSMutableArray*)a{
    NSMutableDictionary* p;
    for(NSInteger i=[a count]-1;i>=0;i--){
        p = [a objectAtIndex:i];
        if([[p objectForKey:@"status"]intValue]!=1){
            [a removeObjectAtIndex:i];
            continue;
        }
        [p removeObjectForKey:@"status"];

    }
}


-(WH_JXNetwork*)addTask:(NSString*)action param:(id)param toView:(id)delegate{
    if([action length]<=0)
        return nil;
    if(param==nil)
        param = @"";
    
    NSString* url=nil;
    NSString* s=@"";
    
    WH_JXNetwork *task = [[WH_JXNetwork alloc] init];
    
    if([action rangeOfString:@"http://"].location == NSNotFound){
        if([action isEqualToString:wh_act_UploadFile]){
            s = self.wh_uploadUrl;
        }else {
            NSRange range = [self.wh_apiUrl rangeOfString:@"config"];
            if (range.location != NSNotFound) {
                s = [self.wh_apiUrl substringToIndex:range.location];
            }else {
                s = self.wh_apiUrl;
            }
        }
    }
    url = [NSString stringWithFormat:@"%@%@%@",s,action,param];
    
    task.url = url;
    task.wh_param = param;
    task.delegate = self;
    task.wh_action = action;
    task.wh_toView  = delegate;
    //    [url1 release];
    
    if([task.wh_toView respondsToSelector:@selector(WH_didServerNetworkStart:)])
        [task.wh_toView WH_didServerNetworkStart:task];
    
    if([task wh_isImage] || [task wh_isAudio] || [task wh_isVideo])
        [task wh_go];
    
//    [_arrayConnections addObject:task];
    //    [task release];
    return task;
}


- (void)WH_requestSuccess:(WH_JXNetwork *)task {
    
    @autoreleasepool {
        NSString* string = task.wh_responseData;
        //    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString* error=nil;
        
        id resultObject = [string mj_JSONObject];
        //    id resultObject = [resultParser objectWithData:task.responseData];
        //    [resultParser release];
        
        if( [resultObject isKindOfClass:[NSDictionary class]] ){
            int resultCode = [[resultObject objectForKey:@"resultCode"] intValue];
            if(resultCode==0 || resultCode>=1000000)
            {
                error = [resultObject objectForKey:@"resultMsg"];
                if(IsStringNull(error))
                    error = @"出错拉";
//                    error
            }
        }else{
            error = @"不能识别返回值";
            if([string length]>=6){
                if([[string substringToIndex:6] isEqualToString:@"<html>"])
                    error = @"服务器好像有点问题";
            }
        }
        
        if(error){
            [self doError:task dict:resultObject resultMsg:string errorMsg:error];
        }else{
            MyLog(@"接口请求%@成功:%@",task.wh_action,string);
            resultObject = [resultObject objectForKey:@"data"];
            NSDictionary * dict = nil;
            NSArray* array = nil;
            
            if( [resultObject isKindOfClass:[NSDictionary class]] )
                dict  = resultObject;
            if( [resultObject isKindOfClass:[NSArray class]] )
                array = resultObject;
            
            if( [task.wh_toView respondsToSelector:@selector(WH_didServerNetworkResultSucces:dict:array:)] )
                [task.wh_toView WH_didServerNetworkResultSucces:task dict:dict array:array];
            
            dict = nil;
            array = nil;
        }
        resultObject = nil;
        //    [pool release];
//        [_arrayConnections removeObject:task];
    }
}


- (void)WH_requestError:(WH_JXNetwork *)task {
    if([task.wh_toView respondsToSelector:@selector(WH_didServerNetworkError:error:)] ){
        [task.wh_toView WH_didServerNetworkError:task error:task.wh_error];
    }
}


-(void) doError:(WH_JXNetwork*)task dict:(NSDictionary*)dict resultMsg:(NSString*)string errorMsg:(NSString*)errorMsg{

    if ([task.wh_toView respondsToSelector:@selector(WH_didServerNetworkResultFailed:dict:)])
        [task.wh_toView WH_didServerNetworkResultFailed:task dict:dict];
}



- (NSString *)WH_getDataUrlWithImage:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    
    NSString *fileName = [self generateUUID];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *filePath = [NSString stringWithFormat:@"%@.jpg",fileName];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:filePath];
    NSString *path = [fileURL.absoluteString substringFromIndex:7];
    [data writeToFile:path atomically:YES];
    
    return path;
}

- (NSString *)WH_getDataUrlWithVideo:(NSData *)video {
    
    NSString *fileName = [self generateUUID];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *filePath = [NSString stringWithFormat:@"%@.mp4",fileName];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:filePath];
    NSString *path = [fileURL.absoluteString substringFromIndex:7];
    [video writeToFile:path atomically:YES];
    
    return path;
}


- (NSString *)generateUUID
{
    return [NSUUID UUID].UUIDString;
}


-(UIImage*)WH_getFirstImageFromVideo:(NSString*)video {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *path = [groupURL.absoluteString substringFromIndex:7];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@.jpg",path,[[video lastPathComponent] stringByDeletingPathExtension]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return [UIImage imageWithContentsOfFile:filePath];
    
    NSURL* url;
    if( [video rangeOfString:@"http://"].location == NSNotFound && [video rangeOfString:@"https://"].location == NSNotFound)
        url = [NSURL fileURLWithPath:video];
    else
        url = [NSURL URLWithString:video];
    
    //获取视频的首帧作为缩略图
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef cgImage = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    if (!cgImage) {
        NSLog(@"获取视频第一帧图片失败:%@",error);
        return nil;
    }
    //保存图片到本地
    NSData * imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:cgImage], 1);
    NSError *imageerror =nil;
    BOOL isSuccess = [imageData writeToFile:filePath atomically:YES];
    if (!isSuccess) {
        NSLog(@"获取视频第一帧图片写入失败,%@",imageerror);
    }
    
    return videoImage;
}
// 获取视频时长
- (CGFloat)WH_getVideoLength:(NSURL *)url{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:url];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}

//压缩
- (NSString *)WH_compressionVideoWithUlr:(NSURL *)url{
//    NSLog(@"压缩前大小 %f MB",[self fileSize:url]);

    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *groupURL = [manager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    NSString *fileName = [self generateUUID];
    
    NSString* path1 = [[groupURL.absoluteString substringFromIndex:7] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",fileName]];

    
    NSString *bakPath= path1; //新路径不能存在文件 如果存在是不能压缩成功的
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset1280x720];
    exportSession.outputURL = [NSURL fileURLWithPath:bakPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
//         BOOL goToUploadFile=NO;
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:{
                //压缩成功
                 self.urlPath = bakPath;
             }
                 break;
             case AVAssetExportSessionStatusFailed:
             {
                 NSError *error=exportSession.error;
                 if (error) {
                     
                 }
             }
                 
                 break;
             default:
                 
                 break;
         }
         
     }];
    if (self.urlPath.length > 0) {
        return self.urlPath;
    }
    return nil;
}

//计算压缩大小
- (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}


@end
