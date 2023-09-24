//
//  OBSHanderTool.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "OBSHanderTool.h"
#import "RSA.h"
#import <OBS/OBS.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCore/QCloudCore.h>

#import<sys/ioctl.h>
#import<net/if.h>
#import<arpa/inet.h>
#include <ifaddrs.h>

static OBSClient *client;
@interface OBSHanderTool ()

@end
@implementation OBSHanderTool

//上传文件到服务器
+(void)handleUploadFile:(NSString *)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView success:(void(^)(int code,NSString * fileUrl,NSString * fileName)) success failed:(void(^) (NSError *error)) failed
{
    if(!file)
        return;
    if(![[NSFileManager defaultManager] fileExistsAtPath:file])
        return;
    
    NSDate *datenow = [NSDate date];
    NSString *startUploadStr = @"";
    
    NSString *ipAddress = @""; //用户IP
    NSString *fileSize = @""; //文件大小
    NSString *upload = @""; //网速
    if (IS_UploadOBSLog) {
        startUploadStr = [NSString stringWithFormat:@"%ld" ,(long)([datenow timeIntervalSince1970]*1000)];
        ipAddress = [self getDeviceIPAddresses];
        fileSize = [NSString stringWithFormat:@"%fM" ,(([self fileSizeAtPath:file])/(1024.0*1024.0))];
        upload = [self formatNetWork:[self getInterfaceBytes]];
    }
    
    if ([g_config.isOpenOSStatus integerValue]) {//使用obs上传
        if ([g_config.osType integerValue] == 1) {//华为云
            
            
            NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDg/CxgoI8m6EXa6QJsleT1k+X6Cg2cGC2aS9il05kW7zfIgoIUwqGO6EXlcIWsRFgJQWvxS94vtbbCWqC9Os4SvfazikT8TmyQtCNnfGSqM7eZKql/jR6XAGBEN4OIQOrtb8GdO4PSpi5NhBziaGEGeSC4LmmolFic9Fm6FHYD4wIDAQAB\n-----END PUBLIC KEY-----";
            
            NSString *access_key_id = [RSA decryptString:g_config.accessKeyId publicKey:pubkey];
            NSString *access_secret_key = [RSA decryptString:g_config.accessSecretKey publicKey:pubkey];
            NSString *end_point = g_config.endPoint;
            NSString *bucket_name = g_config.bucketName;
            
            NSString *fileName = file.lastPathComponent;
            NSString *fileExt = fileName.pathExtension;
            
            // 初始化身份验证
            OBSStaticCredentialProvider *credentailProvider = [[OBSStaticCredentialProvider alloc] initWithAccessKey:access_key_id secretKey:access_secret_key];
            NSString *endPointUrl = [NSString stringWithFormat:@"https://%@",end_point];
            
            // 初始化服务配置
            OBSServiceConfiguration *conf = [[OBSServiceConfiguration alloc] initWithURLString:endPointUrl credentialProvider:credentailProvider];
            
            if (conf) {
                // 初始化client
                            client = [[OBSClient alloc] initWithConfiguration:conf];
                            
                            
                            NSLog(@"=======file=%@",fileName);
                            // 创建列举对象请求
                            __block NSString *md5File = [NSString stringWithFormat:@"%@.%@",[self getFileMd5:fileName],fileExt];
                            NSLog(@"=======md5File=%@",md5File);
                            OBSPutObjectWithFileRequest *request = [[OBSPutObjectWithFileRequest alloc]initWithBucketName:bucket_name objectKey:md5File uploadFilePath:file];
                            // 开启后台上传，当应用退出到后台后，上传任务仍然会进行
                            request.background = YES;
                            request.objectACLPolicy = OBSACLPolicyPublicRead;
                            
                            // 上传对象
                            [client putObject:request completionHandler:^(OBSPutObjectResponse *response, NSError *error) {
                                client = nil;
                                NSDate *date = [NSDate date];
                                NSString *endUploadStr = @"";
                                if (IS_UploadOBSLog) {
                                    endUploadStr = [NSString stringWithFormat:@"%ld", (long)([date timeIntervalSince1970]*1000)];
                                    
                                }
                                
                                if (error) {
                                    // 处理错误,上传自己服务器
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [g_server uploadFile:file validTime:validTime messageId:messageId toView:toView];
                                    });
                                    failed(error);
                                    
                                }else{
                                    
                                    // 获取结果
                                    [self fileUrl:md5File competion:^(NSString *fileUrl) {
                                        success(1,fileUrl,fileName);
                                        
                                        if (IS_UploadOBSLog && [fileSize floatValue] > 5) {
                                            // 2.将时间转换为date
                //                            double tt = date2 - date1;
                                            long tt = [endUploadStr longLongValue] - [startUploadStr longLongValue];
                                            
                                            NSString *tmpDir = NSTemporaryDirectory();
                                            NSString *path = [NSString stringWithFormat:@"%@/%@" ,tmpDir ,@"dataFile"];
                                            NSString *txtPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_log.txt" ,g_myself.userId]];
                                            
                                            //写入文件
                                            NSString *content = [NSString stringWithFormat:@"用户IP:%@  \n用户网速:%@  \n上传的OBS文件路径:%@  \n文件大小:%@   \n上传文件开始时间:%@   \n上传文件结束时间:%@  \n上传文件用时:%ld毫秒" ,ipAddress , upload , fileUrl ,fileSize ,startUploadStr ,endUploadStr ,tt];
                                            NSFileManager *tempFileManager = [[NSFileManager alloc] init];
                                            if ([tempFileManager fileExistsAtPath:txtPath]) {
                                                //有该文件 删除
                                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                                BOOL isDelete = [fileManager removeItemAtPath:path error:nil];
                                                if (isDelete) {
                                                    NSLog(@"===删除成功");
                                                }else{
                                                    NSLog(@"===删除失败");
                                                }
                                            }
                                            
                                            if (![tempFileManager fileExistsAtPath:path]) {
                                                [tempFileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                                            }
                                            NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                                            [tempFileManager createFileAtPath:txtPath contents:data attributes:nil];
                                            
                //                            NSLog(@"=========logPath:%@" ,txtPath);
                                            [self handleUploadFile:txtPath obsType:g_config.osType validTime:validTime messageId:messageId toView:toView success:^(int code, NSString *fileUrl, NSString *fileName) {
                                                
                                            } failed:^(NSError *error) {
                                                
                                            }];
                                        }
                                        
                                    }];
                                    
                                }
                            }];
            }
            
        }else if ([g_config.osType integerValue] == 2) { //腾讯云
            
            //腾讯云os需要用bucketName拼接上osAppId作为bucket传递给sdk
            NSString *bucket_name = [NSString stringWithFormat:@"%@-%@",g_config.bucketName,g_config.osAppId];
            NSString *fileName = file.lastPathComponent;
            
            QCloudCOSXMLUploadObjectRequest *request = [QCloudCOSXMLUploadObjectRequest new];
            NSURL *url = [NSURL fileURLWithPath:file];
            request.object = fileName;
            request.bucket = bucket_name;
            request.body = url;
            
            [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
                NSDate *date = [NSDate date];
                NSString *endUploadStr = @"";
                if (IS_UploadOBSLog) {
                    endUploadStr = [NSString stringWithFormat:@"%ld", (long)([date timeIntervalSince1970]*1000)];
                }
                
                if (error) {
                    //obs上传失败,就走服务器
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [g_server uploadFile:file validTime:validTime messageId:messageId toView:toView];
                    });
                }else{
                    success(1,result.location,fileName);
                    
                    if (IS_UploadOBSLog && [fileSize floatValue] > 5) {
                        long tt = ([endUploadStr longLongValue] - [startUploadStr longLongValue]);
                        
                        NSString *tmpDir = NSTemporaryDirectory();
                        NSString *path = [NSString stringWithFormat:@"%@/%@" ,tmpDir ,@"dataFile"];
                        NSString *txtPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_log.txt" ,g_myself.userId ]];
                        
                        //写入文件
                        NSString *content = [NSString stringWithFormat:@"用户IP:%@  \n用户网速:%@  \n上传的OBS文件路径:%@  \n文件大小:%@   \n上传文件开始时间:%@   \n上传文件结束时间:%@ \n上传文件用时:%ld毫秒" ,ipAddress , upload , result.location ,fileSize ,startUploadStr ,endUploadStr ,tt];
                        NSFileManager *tempFileManager = [[NSFileManager alloc] init];
                        
                        if ([tempFileManager fileExistsAtPath:txtPath]) {
                            //有该文件 删除
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            BOOL isDelete = [fileManager removeItemAtPath:path error:nil];
                            if (isDelete) {
                                NSLog(@"===删除成功");
                            }else{
                                NSLog(@"===删除失败");
                            }
                        }
                        
                        if (![tempFileManager fileExistsAtPath:path]) {
                            [tempFileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                        [tempFileManager createFileAtPath:txtPath contents:data attributes:nil];
                        
//                        NSLog(@"=========logPath:%@" ,txtPath);
                        [self handleUploadFile:txtPath obsType:g_config.osType validTime:validTime messageId:messageId toView:toView success:^(int code, NSString *fileUrl, NSString *fileName) {
                            
                        } failed:^(NSError *error) {
                            
                        }];
                    }
                }
                
            }];
            [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
        }else{
            // obs配置获取失败,走服务器上传
            dispatch_async(dispatch_get_main_queue(), ^{
                [g_server uploadFile:file validTime:validTime messageId:messageId toView:toView];
            });
        }
        
        
        
    }else{
        // 后台未开启obs配置
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_server uploadFile:file validTime:validTime messageId:messageId toView:toView];
        });
    }
}

+(void)handleUploadFile:(NSArray*)files audio:(NSString*)audio video:(NSString*)video file:(NSString*)file type:(int)type validTime:(NSString *)validTime timeLen:(int)timeLen toView:(id)toView success:(void(^)(int code,NSDictionary * dict)) success failed:(void(^) (NSError *error)) failed
{
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    NSMutableArray *arr3 = [NSMutableArray array];
    if (files.count) {
        
        for (int i = 0; i < files.count; i ++) {
            NSString *fileStr = files[i];
            [self handleUploadFile:fileStr validTime:validTime messageId:@"" toView:toView success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
                            if (code == 1) {
                                [arr1 addObject:@{@"oFileName":fileUrl.lastPathComponent,@"oUrl":fileUrl,@"tUrl":fileUrl,@"status":@"1"}];
                                //将Object与md5加密前的fileName对应上，fileName为key，Object为value
                                if (![fileName isEqualToString:fileUrl.lastPathComponent]) {
                                    [tempDic setObject:@{@"oFileName":fileUrl.lastPathComponent,@"oUrl":fileUrl,@"tUrl":fileUrl,@"status":@"1"} forKey:fileName];
                                }
            //                    [tempDic setObject:arr1 forKey:@"images"];
                                int fileCount = (int)files.count;
                                if (video) {
                                    fileCount += 1;
                                }
                                if (audio) {
                                    fileCount += 1;
                                }
                                if (arr1.count+arr2.count+arr3.count == fileCount) {
                                    /*
                                     等所有的图片上传完成之后，按照本地上传时选择的顺序(files数组的顺序)，重新对所有的Object进行排序
                                     */
                                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                                    NSMutableArray *temp = [NSMutableArray array];
                                    for (NSInteger i = 0; i < files.count; i++) {
                                        NSString *FILE = [files[i] lastPathComponent];
                                        [temp addObject:[tempDic objectForKey:FILE]];
                                    }
                                    [dic setObject:temp forKey:@"images"];
                                    success(1,dic);
                                }
                            }
                        } failed:^(NSError * _Nonnull error) {
                            
                        }];
        }
    }
    
    
    
    if (video) {
        NSMutableArray *arr2 = [NSMutableArray array];
        [self handleUploadFile:video validTime:validTime messageId:@"" toView:toView success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                [arr2 addObject:@{@"oFileName":fileUrl.lastPathComponent,@"oUrl":fileUrl,@"status":@"1"}];
                [tempDic setObject:arr2 forKey:@"videos"];
                int fileCount = (int)files.count;
                if (video) {
                    fileCount += 1;
                }
                if (audio) {
                    fileCount += 1;
                }
                if (arr1.count+arr2.count+arr3.count == fileCount) {
                    
                    success(1,tempDic);
                }
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
    
    
    if (audio) {
        NSMutableArray *arr3 = [NSMutableArray array];
        [self handleUploadFile:audio validTime:validTime messageId:@"" toView:toView success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                [arr3 addObject:@{@"oFileName":fileUrl.lastPathComponent,@"oUrl":fileUrl,@"status":@"1"}];
                [tempDic setObject:arr3 forKey:@"audios"];
                int fileCount = 0;
                if ([files isKindOfClass:[NSArray class]]) {
                    fileCount += files.count;
                }
                if (video) {
                    fileCount += 1;
                }
                if (audio) {
                    fileCount += 1;
                }
                if (arr1.count+arr2.count+arr3.count == fileCount) {
                    
                    success(1,tempDic);
                }
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
    
}

//上传头像
+(void)WH_handleUploadOBSHeadImage:(NSString*)userId image:(UIImage*)image toView:(id)toView success:(void(^)(int code)) success failed:(void(^) (NSError *error)) failed
{
    if ([g_config.isOpenOSStatus integerValue]) {//使用obs上传
        if ([g_config.osType integerValue] == 1) {//华为云
            
            NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDg/CxgoI8m6EXa6QJsleT1k+X6Cg2cGC2aS9il05kW7zfIgoIUwqGO6EXlcIWsRFgJQWvxS94vtbbCWqC9Os4SvfazikT8TmyQtCNnfGSqM7eZKql/jR6XAGBEN4OIQOrtb8GdO4PSpi5NhBziaGEGeSC4LmmolFic9Fm6FHYD4wIDAQAB\n-----END PUBLIC KEY-----";
            
            NSString *access_key_id = [RSA decryptString:g_config.accessKeyId publicKey:pubkey];
            NSString *access_secret_key = [RSA decryptString:g_config.accessSecretKey publicKey:pubkey];
            NSString *end_point = g_config.endPoint;
            NSString *bucket_name = g_config.bucketName;
            
            // 初始化身份验证
            OBSStaticCredentialProvider *credentailProvider = [[OBSStaticCredentialProvider alloc] initWithAccessKey:access_key_id secretKey:access_secret_key];
            NSString *endPointUrl = [NSString stringWithFormat:@"https://%@",end_point];
            
            // 初始化服务配置
            OBSServiceConfiguration *conf = [[OBSServiceConfiguration alloc] initWithURLString:endPointUrl credentialProvider:credentailProvider];
            
            if (conf) {
                // 初始化client
                client = [[OBSClient alloc] initWithConfiguration:conf];
                
                NSString* dir  = [NSString stringWithFormat:@"%d",[userId intValue] % 10000];
                __block NSString* fileUrlStr1  = [NSString stringWithFormat:@"avatar/t/%@/%@.jpg",dir,userId];
                __block NSString* fileUrlStr2  = [NSString stringWithFormat:@"avatar/o/%@/%@.jpg",dir,userId];
                OBSPutObjectWithDataRequest *request1 = [[OBSPutObjectWithDataRequest alloc]initWithBucketName:bucket_name objectKey:fileUrlStr1 uploadData:UIImageJPEGRepresentation(image, 0.5)];
                OBSPutObjectWithDataRequest *request2 = [[OBSPutObjectWithDataRequest alloc]initWithBucketName:bucket_name objectKey:fileUrlStr2 uploadData:UIImageJPEGRepresentation(image, 0.5)];
                request1.objectACLPolicy = OBSACLPolicyPublicRead;
                request2.objectACLPolicy = OBSACLPolicyPublicRead;
                
                // 上传对象
                [client putObject:request1 completionHandler:^(OBSPutObjectResponse *response, NSError *error) {
                    
                    if (!error) {
                        // 上传大图
                        [client putObject:request2 completionHandler:^(OBSPutObjectResponse *response, NSError *error) {
                            client = nil;
                            if (!error) {
                                
                                success(1);
                                
                            }
                        }];
                        
                    }else{
                        // 处理错误,上传自己服务器
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [g_server WH_uploadHeadImageWithUserId:userId image:image toView:toView];
                        });
                        failed(error);
                    }
                }];

            }
                        
        } else if ([g_config.osType integerValue] == 2) {
            
            NSString* dir  = [NSString stringWithFormat:@"%d",[userId intValue] % 10000];
            __block NSString* fileUrlStr1  = [NSString stringWithFormat:@"avatar/t/%@/%@.jpg",dir,userId];
            __block NSString* fileUrlStr2  = [NSString stringWithFormat:@"avatar/o/%@/%@.jpg",dir,userId];
            
            //腾讯云os需要用bucketName拼接上osAppId作为bucket传递给sdk
            __block NSString *bucket_name = [NSString stringWithFormat:@"%@-%@",g_config.bucketName,g_config.osAppId];
//            NSString *fileName = file.lastPathComponent;
            
            QCloudCOSXMLUploadObjectRequest *request = [QCloudCOSXMLUploadObjectRequest new];
            request.object = fileUrlStr1;
            request.bucket = bucket_name;
            request.body = UIImageJPEGRepresentation(image, 0.5);
            
            [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
                if (error) {
                    //obs上传失败,就走服务器
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [g_server WH_uploadHeadImageWithUserId:userId image:image toView:toView];
                    });
                }else{

                    QCloudCOSXMLUploadObjectRequest *request = [QCloudCOSXMLUploadObjectRequest new];
                    request.object = fileUrlStr2;
                    request.bucket = bucket_name;
                    request.body = UIImageJPEGRepresentation(image, 0.5);
                    [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
                        if (error) {
                            
                        }else{
                            success(1);
                        }
                    }];
                    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
                }
                
            }];
            [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
        }else{
            // obs配置获取失败,走服务器上传
            dispatch_async(dispatch_get_main_queue(), ^{
                [g_server WH_uploadHeadImageWithUserId:userId image:image toView:toView];
            });
        }
        
    }else{
        // 后台未开启obs配置
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_server WH_uploadHeadImageWithUserId:userId image:image toView:toView];
        });
    }
}

+ (void)fileUrl:(NSString *)fileMd5 competion:(void(^)(NSString *fileUrl))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        completion([NSString stringWithFormat:@"https://%@.%@/%@",g_config.bucketName,g_config.endPoint,fileMd5]);
    });
}

// 普通的获取文件md5的方法
+ (NSString *)getFileMd5:(NSString *) fileName{
//    // 实例化NSDateFormatter
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    // 设置日期格式
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    // 获取当前日期
//    NSDate *currentDate = [NSDate date];
//    NSString *currentDateString = [formatter stringFromDate:currentDate];
//    return [self md5String:currentDateString];
    return [g_server WH_getMD5StringWithStr:fileName];
}

+ ( NSString *)md5String:( NSString *)str {
    
    const char *myPasswd = [str UTF8String ];
    unsigned char mdc[ 16 ];
    CC_MD5 (myPasswd, ( CC_LONG ) strlen (myPasswd), mdc);
    NSMutableString *md5String = [ NSMutableString string ];
    
    for ( int i = 0 ; i< 16 ; i++) {
        [md5String appendFormat : @"%02x" ,mdc[i]];
    }
    return md5String;
}



#pragma mark 获取客户ip
+ (NSString *)getDeviceIPAddresses {
    
    int sockfd =socket(AF_INET,SOCK_DGRAM, 0);
    NSMutableArray *ips = [NSMutableArray array];
    int BUFFERSIZE =4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd,SIOCGIFCONF, &ifc) >= 0) {
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            ifr = (struct ifreq *)ptr;
            int len =sizeof(struct sockaddr);
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family !=AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name,':')) != NULL) *cptr =0;
            if (strncmp(lastname, ifr->ifr_name,IFNAMSIZ) == 0)continue;
            memcpy(lastname, ifr->ifr_name,IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd,SIOCGIFFLAGS, &ifrcopy);
            if ((ifrcopy.ifr_flags &IFF_UP) == 0)continue;
            NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    
    close(sockfd);
    
    NSString *deviceIP =@"";
    
    for (int i=0; i < ips.count; i++) {
        
        if (ips.count >0) {
            
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    NSLog(@"deviceIP========%@",deviceIP);
    return deviceIP;
}

#pragma mark 获取本地文件大小
+ (long long) fileSizeAtPath:(NSString*)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
    }else{
        NSLog(@"计算文件大小：文件不存在");
    }
    
    return 0;
}

+ (long long) getInterfaceBytes

{
    
    struct ifaddrs *ifa_list = 0, *ifa;
    
    if (getifaddrs(&ifa_list) == -1)
        
    {
        
        return 0;
        
    }
    
    
    
    uint32_t iBytes = 0;
    
    uint32_t oBytes = 0;
    
    
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
        
    {
        
        if (AF_LINK != ifa->ifa_addr->sa_family)
            
            continue;
        
        
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            
            continue;
        
        
        
        if (ifa->ifa_data == 0)
            
            continue;
        
        
        
        /* Not a loopback device. */
        
        if (strncmp(ifa->ifa_name, "lo", 2))
            
        {
            
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            
            
            iBytes += if_data->ifi_ibytes;
            
            oBytes += if_data->ifi_obytes;
            
        }
        
    }
    
    freeifaddrs(ifa_list);
    
    
    
    NSLog(@"\n[getInterfaceBytes-Total]%d,%d",iBytes,oBytes);
    
    return iBytes + oBytes;
    
}

+ (NSString *)formatNetWork:(long long int)rate {
    if (rate <1024) {
        return [NSString stringWithFormat:@"%lldB/秒", rate];
    } else if (rate >=1024&& rate <1024*1024) {
        return [NSString stringWithFormat:@"%.1fKB/秒", (double)rate /1024];
    } else if (rate >=1024*1024&& rate <1024*1024*1024) {
        return [NSString stringWithFormat:@"%.2fMB/秒", (double)rate / (1024*1024)];
    } else {
        return@"10Kb/秒";
    };
}

//上传文件
+(void)handleUploadFile:(NSString *)file obsType:(NSString *)oType validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView success:(void(^)(int code,NSString * fileUrl,NSString * fileName)) success failed:(void(^) (NSError *error)) failed {
    if(!file)
        return;
    if(![[NSFileManager defaultManager] fileExistsAtPath:file])
        return;
    
    if ([oType integerValue] == 1) {//华为云
        
        
        NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDg/CxgoI8m6EXa6QJsleT1k+X6Cg2cGC2aS9il05kW7zfIgoIUwqGO6EXlcIWsRFgJQWvxS94vtbbCWqC9Os4SvfazikT8TmyQtCNnfGSqM7eZKql/jR6XAGBEN4OIQOrtb8GdO4PSpi5NhBziaGEGeSC4LmmolFic9Fm6FHYD4wIDAQAB\n-----END PUBLIC KEY-----";
        
        NSString *access_key_id = [RSA decryptString:g_config.accessKeyId publicKey:pubkey];
        NSString *access_secret_key = [RSA decryptString:g_config.accessSecretKey publicKey:pubkey];
        NSString *end_point = g_config.endPoint;
        NSString *bucket_name = g_config.bucketName;
        
        NSString *fileName = file.lastPathComponent;
        NSString *fileExt = fileName.pathExtension;
        
        // 初始化身份验证
        OBSStaticCredentialProvider *credentailProvider = [[OBSStaticCredentialProvider alloc] initWithAccessKey:access_key_id secretKey:access_secret_key];
        NSString *endPointUrl = [NSString stringWithFormat:@"https://%@",end_point];
        
        // 初始化服务配置
        OBSServiceConfiguration *conf = [[OBSServiceConfiguration alloc] initWithURLString:endPointUrl credentialProvider:credentailProvider];
        
        if (conf) {
            // 初始化client
                    client = [[OBSClient alloc] initWithConfiguration:conf];
                    
                    
                    NSLog(@"=======file=%@",fileName);
                    // 创建列举对象请求
                    __block NSString *md5File = [NSString stringWithFormat:@"%@.%@",[self getFileMd5:fileName],fileExt];
                    NSLog(@"=======md5File=%@",md5File);
                    OBSPutObjectWithFileRequest *request = [[OBSPutObjectWithFileRequest alloc]initWithBucketName:bucket_name objectKey:md5File uploadFilePath:file];
                    // 开启后台上传，当应用退出到后台后，上传任务仍然会进行
                    request.background = YES;
                    request.objectACLPolicy = OBSACLPolicyPublicRead;
                    
                    // 上传对象
                    [client putObject:request completionHandler:^(OBSPutObjectResponse *response, NSError *error) {
                        client = nil;
                        
                        if (error) {
                            // 处理错误,上传自己服务器
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //                    [g_server uploadFile:file validTime:validTime messageId:messageId toView:toView];
            //                });
            //                failed(error);
                            NSLog(@"华为云文件上传失败");
                        }else{
                            // 获取结果
                            [self fileUrl:md5File competion:^(NSString *fileUrl) {
            //                    success(1,fileUrl,fileName);
                                NSLog(@"华为云文件上传成功");
                            }];
                            
                        }
                    }];
        }
        
    }else if ([oType integerValue] == 2) { //腾讯云
        
        //腾讯云os需要用bucketName拼接上osAppId作为bucket传递给sdk
        NSString *bucket_name = [NSString stringWithFormat:@"%@-%@",g_config.bucketName,g_config.osAppId];
        NSString *fileName = file.lastPathComponent;
        
        QCloudCOSXMLUploadObjectRequest *request = [QCloudCOSXMLUploadObjectRequest new];
        NSURL *url = [NSURL fileURLWithPath:file];
        request.object = fileName;
        request.bucket = bucket_name;
        request.body = url;
        
        [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
            if (error) {
                //obs上传失败,就走服务器
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [g_server uploadFile:file validTime:validTime messageId:messageId toView:toView];
//                });
                NSLog(@"腾讯云文件上传失败");
            }else{
//                success(1,result.location,fileName);
                NSLog(@"result:%@" ,result);
                NSLog(@"result.location:%@  fileName:%@" ,result.location ,fileName);
                NSLog(@"腾讯云文件上传成功");
            }
            
        }];
        [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
    }else{
        // obs配置获取失败,走服务器上传
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [g_server uploadFile:file validTime:validTime messageId:messageId toView:toView];
//        });
    }
}

@end
