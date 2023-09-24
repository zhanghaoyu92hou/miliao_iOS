//
//  JXServer.m
//  sjvodios
//
//  Created by  on 19-5-5-22.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import "JXServer.h"
#import "WH_JXConnection.h"
#import "AppDelegate.h"
#import "WH_JXImageView.h"
#import "WH_VersionManageTool.h"
//#import "MobClick.h"
#import "md5.h"
#import "WeiboReplyData.h"
#import "WH_LoginViewController.h"
#import "WH_webpage_WHVC.h"
#import "WH_SearchData.h"
#import "WH_RoomData.h"
#import "BPush.h"
#import "photo.h"
#import "WH_ResumeData.h"
#import "ATMHud.h"
#import "JXMyTools.h"
#import "WH_JXLocation.h"
#import "UIImageView+WebCache.h"
#import "UIImage+WH_Addtions.h"
#import "NSString+ContainStr.h"
#import "UIDevice+FCUUID.h"
#import <sys/utsname.h>
#import "SDImageCache.h"
#import "WH_JXUserObject+GetCurrentUser.h"
#import "RSA.h"
#import <CommonCrypto/CommonDigest.h>

@interface JXServer ()<JXLocationDelegate,WH_JXConnectionDelegate>

@property (nonatomic, assign) BOOL isGetSetting;

@end

@implementation JXServer
@synthesize isLoginWeibo,longitude,latitude;
@synthesize count_money;
@synthesize user_id;
@synthesize user_type;
@synthesize myself;
@synthesize access_token;
@synthesize isLogin;
@synthesize lastOfflineTime;
+ (instancetype)sharedServer {
    static JXServer *server = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[JXServer alloc] init];
    });
    return server;
}
-(id)init{
    self = [super init];
    _arrayConnections= [[NSMutableArray alloc] init];
    _dictWaitViews   = [[NSMutableDictionary alloc] init];
    _bAlreadyAutoLogin= NO;
    isLogin   = NO;
    
    //    latitude  = 22.6;
    //    longitude = 114.04;
    latitude  =  0;
    longitude =  0;
    
    _locationCount  = 0;
//    self.location = [[JXLocation alloc] init];
//    self.location.delegate = self;
//    [self locate];   //定位
    //    [self performSelector:@selector(startLocation) withObject:nil afterDelay:10];
    
    access_token = @"8864c3159c964c82bf0719ae0ade5ccd";//个人
    
    myself = [WH_JXUserObject sharedUserInstance];// [[WH_JXUserObject alloc] init];
    /*
    myself.userId = @"100003";
    myself.userNickname = Localized(@"JX_NickName");
    myself.userDescription = Localized(@"JX_GiftText");
    myself.birthday = [NSDate date];
    myself.companyId    = [NSNumber numberWithInt:1];
    myself.level        = [NSNumber numberWithInt:1];
    myself.fansCount    = [NSNumber numberWithInt:1000];
    myself.attCount     = [NSNumber numberWithInt:1000];
    myself.userHead     = @"http://image.tianjimedia.com/uploadImages/2013/231/KJQIZSVQ013Q.jpg";
    */
    [self readDefaultSetting];
    _hud = [[ATMHud alloc] initWithDelegate:self];
//    self.multipleLogin = [JXMultipleLogin sharedInstance];
    _config = [[WH_VersionManageTool alloc] init];
    return self;
}

-(void)dealloc{

}

-(WH_JXConnection*)addTask:(NSString*)action param:(id)param toView:(id)delegate{
    if([action length]<=0)
        return nil;
    if(param==nil)
        param = @"";
    
    NSString* url=nil;
    NSString* s=@"";
    
    WH_JXConnection *task = [[WH_JXConnection alloc] init];
    
    if([action rangeOfString:@"http://"].location == NSNotFound){
        if ([action isEqualToString:act_h5Payment]) {
            s = kH5PaymentBaseUrl;
        } else if([action isEqualToString:wh_act_UploadFile] || [action isEqualToString:wh_act_UploadHeadImage] || [action isEqualToString:wh_act_SetGroupAvatarServlet]){
            s = g_config.uploadUrl;
            
        }else {
            NSRange range = [g_config.apiUrl rangeOfString:@"config"];
            if (range.location != NSNotFound) {
                s = [g_config.apiUrl substringToIndex:range.location];
            }else {
                s = g_config.apiUrl;
            }
            
        }
    }
    url = [NSString stringWithFormat:@"%@%@%@",s,action,param];
    
    task.url = url;
    //    task.timeOutSeconds = WH_connect_timeout;
    task.param = param;
    task.delegate = self;
    task.action = action;
    task.toView  = delegate;
    //    [url1 release];
    
    if([task.toView respondsToSelector:@selector(WH_didServerConnect_WHStart:)])
        [task.toView WH_didServerConnect_WHStart:task];
    
    if([task isImage] || [task isAudio] || [task isVideo])
        [task go];
    
    [_arrayConnections addObject:task];
    //    [task release];
    return task;
}

-(void)stopConnection:(id)toView{
    for(NSInteger i=[_arrayConnections count]-1;i>=0;i--){
        WH_JXConnection* task = [_arrayConnections objectAtIndex:i];
        if(toView == task.toView){
            [_arrayConnections removeObjectAtIndex:i];
            [task stop];
        }
        task = nil;
    }
}

#pragma  mark   ------------------服务器数据成功----------------
-(void)requestSuccess:(WH_JXConnection*)task
{
    if( [task isImage] ){
        [self doSaveImage:task];
        return;
    }
    if ([task isAudio] || [task isVideo]) {
        [self doSaveVideoAudio:task];
        return;
    }
    
    @autoreleasepool {
        NSString* string = task.responseData;
        //    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString* error=nil;
        
        id resultObject = [string mj_JSONObject];
        //    id resultObject = [resultParser objectWithData:task.responseData];
        //    [resultParser release];
        
        if ([task.action isEqualToString:act_h5Payment]) {
            if( [resultObject isKindOfClass:[NSDictionary class]] ){
                int resultCode = [[resultObject objectForKey:@"resultCode"] intValue];
                if(resultCode != 1001)
                {
                    error = [resultObject objectForKey:@"resultMsg"];
                    if([error length]<=0)
                        error = Localized(@"JXServer_Error");
                }
            }else{
                error = Localized(@"JXServer_ErrorReturn");
                if([string length]>=6){
                    if([[string substringToIndex:6] isEqualToString:@"<html>"])
                        error = Localized(@"JXServer_ErrorSever");
                }
            }
        }else{
            if( [resultObject isKindOfClass:[NSDictionary class]] ){
                int resultCode = [[resultObject objectForKey:@"resultCode"] intValue];
                if(resultCode==0 || resultCode>=1000000)
                {
                    error = [resultObject objectForKey:@"resultMsg"];
                    if([error length]<=0)
                        error = Localized(@"JXServer_Error");
                }
            }else if([resultObject isKindOfClass:[NSArray class]]){
                NSLog(@"返回的是数组");
            }else{
                error = Localized(@"JXServer_ErrorReturn");
                if([string length]>=6){
                    if([[string substringToIndex:6] isEqualToString:@"<html>"])
                        error = Localized(@"JXServer_ErrorSever");
                }
            }
        }
        
        if(error){
            [self doError:task dict:resultObject resultMsg:string errorMsg:error];
        }else{
            MyLog(@"接口请求%@成功:%@",task.action,string);
            if ([task.action isEqualToString:act_h5Payment]) {
                if( [task.toView respondsToSelector:@selector(WH_didServerResult_WHSucces:dict:array:)] )
                    [task.toView WH_didServerResult_WHSucces:task dict:resultObject array:nil];
            }else  if ([task.action isEqualToString:wh_act_TransferToAdmin]) {
                if( [task.toView respondsToSelector:@selector(WH_didServerResult_WHSucces:dict:array:)] )
                    [task.toView WH_didServerResult_WHSucces:task dict:resultObject array:nil];
            }else {
                if ([task.action isEqualToString:wh_act_getCurrentTime] || [task.action isEqualToString:wh_act_Config]) {
                    // 获取服务器时间，然后对比当前客户端时间
                    // 两个接口调用，防止单个接口出现空值
                    if ([[resultObject objectForKey:@"currentTime"] doubleValue] > 0) {
                        self.serverCurrentTime = [[resultObject objectForKey:@"currentTime"] doubleValue];
                        self.timeDifference = self.serverCurrentTime - ([[NSDate date] timeIntervalSince1970] *1000);
                    }
                    NSLog(@"currentTime: %@ - %f",task.action,self.timeDifference);
                }
                
                NSDictionary * dict = nil;
                NSArray* array = nil;
                //如果是密保问题校验
                if ([task.action isEqualToString:act_pwdSecCheck]||[task.action isEqualToString:act_payGetOrderDetails]) {
                    dict = resultObject;
                }
                
                if ([task.action isEqualToString:wh_act_deleteMemebers]) {
                    dict = resultObject;
                }else{
                    
                    if( [resultObject isKindOfClass:[NSArray class]] ){
                        array = resultObject;
                    }else{
                        resultObject = [resultObject objectForKey:@"data"];
                        if( [resultObject isKindOfClass:[NSDictionary class]] )
                            dict  = resultObject;
                        if( [resultObject isKindOfClass:[NSArray class]] )
                            array = resultObject;
                    }
                }
                if( [task.toView respondsToSelector:@selector(WH_didServerResult_WHSucces:dict:array:)] )
                    [task.toView WH_didServerResult_WHSucces:task dict:dict array:array];
                
                dict = nil;
                array = nil;
            }
        }
        resultObject = nil;
        //    [pool release];
        [_arrayConnections removeObject:task];
    }
}

-(void)requestError:(WH_JXConnection *)task
{
    //    NSLog(@"http失败");
    [_arrayConnections removeObject:task];
    
    if( [task.toView respondsToSelector:@selector(WH_didServerConnect_WHError:error:)] ){
        int n = [task.toView WH_didServerConnect_WHError:task error:task.error];
        if(n != WH_hide_error){
            //            if(task.showError)
//            [g_App showAlert:[NSString stringWithFormat:@"%@%@%@",Localized(@"JXServer_ErrorNetwork"),task.error.localizedDescription,task.url]];
            [g_App showAlert:[NSString stringWithFormat:@"%@%@",Localized(@"JXServer_ErrorNetwork"),task.error.localizedDescription]];
        }
    }
}

-(void) doError:(WH_JXConnection*)task dict:(NSDictionary*)dict resultMsg:(NSString*)string errorMsg:(NSString*)errorMsg{
    NSLog(@"%@错误:%@",task.action,string);
    int resultCode = [[dict objectForKey:@"resultCode"] intValue];
    if(![task.action isEqualToString:wh_act_UserLogout] && ![task.action isEqualToString:wh_act_OutTime]){
        if(resultCode==0 || resultCode>=1000000)
        {
            if(resultCode == 1030101 || resultCode == 1030102){//未登陆时
                NSLog(@"登录过期，请重新登录");
                if (isLogin || [task.action isEqualToString:wh_act_UserLoginAuto]) {
                    // 自动登录失败后要清除token ，不然会影响到手动登录
                    g_server.access_token = nil;
                    [g_default removeObjectForKey:kMY_USER_TOKEN];
                    [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
                    [g_App showAlert:@"登录过期，请重新登录" delegate:self tag:11000 onlyConfirm:YES];
                }
                isLogin = NO;
                return;
            }
        }
    }
    
    int n=WH_show_error;
    if ([task.toView respondsToSelector:@selector(WH_didServerResult_WHFailed:dict:)])
        n= [task.toView WH_didServerResult_WHFailed:task dict:dict];
    if ([task.action isEqualToString:wh_act_OutTime]) {
        n = WH_hide_error;
    }
    if(n != WH_hide_error){
        //        if(task.showError)
        if (![errorMsg isEqualToString:@"授权认证失败"]) {
            [g_App showAlert:[NSString stringWithFormat:@"%@",errorMsg]];
        }
    }
}

-(void)doSaveImage:(WH_JXConnection*)task{
    @try {
        [_arrayConnections removeObject:task];
        UIImage* p = [[UIImage alloc]initWithData:task.responseData];
        
        if(p==nil)
            return;
        NSString* file = [[task.action lastPathComponent] stringByDeletingPathExtension];
        NSString* ext  = [[task.action lastPathComponent] pathExtension];
        NSString* filepath;
        if([task.action rangeOfString:@"/t/"].location == NSNotFound)
            filepath = [NSString stringWithFormat:@"%@o/",tempFilePath];
        else
            filepath = [NSString stringWithFormat:@"%@t/",tempFilePath];
        [FileInfo createDir:filepath];
        
        filepath = [NSString stringWithFormat:@"%@%@@2x.%@",filepath,file,ext];
        [task.responseData writeToFile:filepath atomically:YES];
        
        //为了双倍分辨率：
        //        [p release];
        p = [[UIImage alloc]initWithContentsOfFile:filepath];
        
        //显示图像
        if(task.toView){
            
            WH_JXImageView* iv = (WH_JXImageView*)task.toView;
            iv.image = p;
            iv = nil;
            
        }
        //        NSLog(@"%@成功:%@",task.action,filepath);
        
        //        [p release];
    }
    @catch (NSException *exception) {
    }
    return;
}

-(void) doSaveVideoAudio:(WH_JXConnection*)task{
    @try {
        NSString * filePath = [myTempFilePath stringByAppendingString:[[task.url stringByRemovingPercentEncoding] lastPathComponent]];
        task.downloadFile = filePath;
        BOOL success = [task.responseData writeToFile:filePath options:NSDataWritingAtomic error:nil];
        if (!success) {
            NSLog(@"文件写入失败");
        }else{
            if( [task.toView respondsToSelector:@selector(WH_didServerResult_WHSucces:dict:array:)] )
                [task.toView WH_didServerResult_WHSucces:task dict:nil array:nil];
            //            [g_notify postNotificationName:@"audiaoDownloadFinished" object:task];
        }
    } @catch (NSException *exception) {
    } @finally {
        [_arrayConnections removeObject:task];
    }
}

-(NSString*)WH_getHeadImageOUrlWithUserId:(NSString*)userId{
    NSString* dir  = [NSString stringWithFormat:@"%d",[userId intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir,userId];
    return url;
}

-(NSString*)WH_getHeadImageTUrlWithUserId:(NSString*)userId{
    NSString* dir  = [NSString stringWithFormat:@"%d",[userId intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,userId];
    return url;
}

-(void)WH_getHeadImageSmallWIthUserId:(NSString*)userId userName:(NSString *)userName imageView:(UIImageView*)iv{
    for (UIView *subView in iv.subviews) {
        [subView removeFromSuperview];
    }
    //    客服头像
    if([userId intValue]<10100 && [userId intValue]>=10000){
        //以前客服头像写死,现在客服头像从后台获取
//        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"im_10000"]];
//        return;
    }
    // 支付公众号
    if ([userId intValue] == [WAHU_TRANSFER intValue]) {
        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_wahu_transfer"]];
        return;
    }
     NSString* s;
    if([userId isKindOfClass:[NSNumber class]])
        s = [(NSNumber*)userId stringValue];
    else
        s = userId;
//    if([s length]<=0)
//        return;
    
    // 我的其他手机设备头像
    if ([s isEqualToString:ANDROID_USERID] || [s isEqualToString:IOS_USERID]) {
        iv.image = [UIImage imageNamed:@"WH_addressbook_phone_contact"];
        return;
    }
    // 我的电脑端头像
    if ([s isEqualToString:PC_USERID] || [s isEqualToString:MAC_USERID] || [s isEqualToString:WEB_USERID]) {
        iv.image = [UIImage imageNamed:@"WH_addressbook_compute"];
        return;
    }
    
    UIImage *placeholderImage = [UIImage imageNamed:@"avatar_normal"];
    if (iv.image) {
        placeholderImage = iv.image;
    }
    
    NSString* dir  = [NSString stringWithFormat:@"%d",[s intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,s];
//    [iv sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"avatar_normal"] options:SDWebImageRetryFailed];
    [self getDefultHeadImage:[NSURL URLWithString:url] userId:userId userName:userName  placeholderImage:placeholderImage iv:iv];
}

-(void)WH_getHeadImageLargeWithUserId:(NSString*)userId userName:(NSString *)userName imageView:(UIImageView*)iv{
    for (UIView *subView in iv.subviews) {
        [subView removeFromSuperview];
    }
    //    客服头像
    if([userId intValue]<10100 && [userId intValue]>=10000){
        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"im_10000"]];
        if ([userId intValue] == 10005) {
            iv.image = [UIImage imageNamed:@"积分机器人"];
        }
        return;
    }
    // 支付公众号
    if ([userId intValue] == [WAHU_TRANSFER intValue]) {
        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_wahu_transfer"]];
        return;
    }
    NSString* s;
    if([userId isKindOfClass:[NSNumber class]])
        s = [(NSNumber*)userId stringValue];
    else
        s = userId;
//    if([s length]<=0)
//        return;
    // 我的其他手机设备头像
    if ([s isEqualToString:ANDROID_USERID]) {
        iv.image = [UIImage imageNamed:@"fdy"];
        return;
    }
    // 我的电脑端头像
    if ([s isEqualToString:PC_USERID] || [s isEqualToString:MAC_USERID]) {
        iv.image = [UIImage imageNamed:@"feb"];
        return;
    }
    NSString* dir  = [NSString stringWithFormat:@"%d",[s intValue] % 10000];
    NSString* url  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir,s];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"avatar_normal"];
    if (iv.image) {
        placeholderImage = iv.image;
    }
    
//    [iv sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    [self getDefultHeadImage:[NSURL URLWithString:url] userId:userId userName:userName placeholderImage:placeholderImage iv:iv];
}

-(void)WH_getRoomHeadImageSmallWithUserId:(NSString*)userId roomId:(NSString *)roomId imageView:(UIImageView*)iv{
    if (IsStringNull(roomId)) {
        return;
    }
    for (UIView *subView in iv.subviews) {
        [subView removeFromSuperview];
    }

   
    int hashCode = [self gethashCode:userId];
    int a = abs(hashCode % 10000);
    int b = abs(hashCode % 20000);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@avatar/o/%d/%d/%@.jpg",g_config.downloadAvatarUrl,a,b,userId];
    [iv sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[self roomHeadImage:userId roomId:roomId] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
}

-(UIImage *)roomHeadImage:(NSString *)userId roomId:(NSString *)roomId{
    NSString *groupImagePath = [NSString stringWithFormat:@"%@%@/%@.%@",NSTemporaryDirectory(),g_myself.userId,userId,@"jpg"];
    if (groupImagePath && [[NSFileManager defaultManager] fileExistsAtPath:groupImagePath]) {
        return [UIImage imageWithContentsOfFile:groupImagePath];
    }
    
    //获取全部
    NSArray * allMem = [memberData fetchAllMembers:roomId];
    if(!allMem || allMem.count <= 1 || userId.length  <= 0){
        if (MainHeadType) {//圆形
            return [UIImage imageNamed:@"groupImage"];//数据库没有值
        }else{
            return [UIImage imageNamed:@"fangxinggroupImagePlaceholder"];//数据库没有值
        }
    }
    
    NSMutableArray * userIdArr = [[NSMutableArray alloc] init];
    NSMutableArray * downLoadImageArr = [[NSMutableArray alloc] init];
    NSString * roomIdStr = [userId mutableCopy];
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //webcache
        SDWebImageManager * manager = [SDWebImageManager sharedManager];
    
        NSInteger maxHeadCount = MainHeadType ? 5 : 9; //!< 最大获取图片张数
        for (int i = 0; (i<allMem.count) && (i<10); i++) {
            memberData * member = allMem[i];
            //取userId
            long longUserId = member.userId;
            if (longUserId >= 10000000) {
                [userIdArr addObject:[NSNumber numberWithLong:longUserId]];
                if (userIdArr.count == maxHeadCount) {
                    break;
                }
            }
        }
    __block UIImage *groupHeadImage = nil;
    __block NSMutableArray *headImageArrBlock = downLoadImageArr;
        for (NSNumber * userIdNum in userIdArr) {
            NSString* dir  = [NSString stringWithFormat:@"%ld",[userIdNum longValue] % 10000];
            NSString* url  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,userIdNum];
            
            [manager loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if(image){
                    [headImageArrBlock addObject:image];
                }else if(error){
                    NSLog(@"获取群成员头像失败：%@", error.localizedDescription);
                    UIImage * defaultImage = [UIImage imageNamed:@"userhead"];
                    [headImageArrBlock addObject:defaultImage];
                }
                if (headImageArrBlock.count == userIdArr.count) {
                    //生成群头像
                    groupHeadImage = [self combineImages:headImageArrBlock];
                    [self saveGroupHeadImage:groupHeadImage roomId:roomIdStr];
                }
            }];
        }

//    });
    return groupHeadImage;
}
- (void)saveGroupHeadImage:(UIImage *)headImage roomId:(NSString *)roomIdStr {
    NSDictionary * groupDict = @{@"groupHeadImage":headImage,@"roomJid":roomIdStr};
    [g_notify postNotificationName:kGroupHeadImageModifyNotifaction object:groupDict];
    
    NSString *groupImagePath = [NSString stringWithFormat:@"%@%@/%@.%@",NSTemporaryDirectory(),g_myself.userId,roomIdStr,@"jpg"];
    if (groupImagePath && [[NSFileManager defaultManager] fileExistsAtPath:groupImagePath]) {
        NSError * error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:groupImagePath error:&error];
        if (error)
            NSLog(@"删除群组头像文件错误:%@",error);
    }
    [g_server WH_saveImageToFileWithImage:headImage file:groupImagePath isOriginal:NO];
}
- (UIImage *)combineImages:(NSArray <UIImage *>*)imageArray {
    if (MainHeadType) {//圆形头像
        UIView *view5 = [JJHeaders createHeaderView:140
                                             images:imageArray];
        view5.center = CGPointMake(235, 390);
        view5.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        
        
        CGSize s = view5.bounds.size;
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
        UIGraphicsBeginImageContextWithOptions(s, YES, 1.0);
        [view5.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }else{//方形
        UIImage *image = [UIImage groupIconWith:imageArray bgColor:HEXCOLOR(0xdddee0)];
        return image;
    }
    
}



-(int)gethashCode:(NSString *)str {
    // 字符串转hash
    int hash = 0;
    for (int i = 0; i<[str length]; i++) {
        NSString *s = [str substringWithRange:NSMakeRange(i, 1)];
        char *unicode = (char *)[s cStringUsingEncoding:NSUnicodeStringEncoding];
        int charactorUnicode = 0;
        size_t length = strlen(unicode);
        for (int n = 0; n < length; n ++) {
            charactorUnicode += (int)((unicode[n] & 0xff) << (n * sizeof(char) * 8));
        }
        hash = hash * 31 + charactorUnicode;
    }
    return hash;
}

- (void)getDefultHeadImage:(NSURL *)url userId:(NSString *)userId userName:(NSString *)userName placeholderImage:(UIImage *)placeholderImage iv:(UIImageView *)iv {
    
    [iv sd_setImageWithURL:url placeholderImage:placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if (error) {
            WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:userId];
            if (user.roomId.length > 0) {
                return;
            }else {
                NSString *nameStr = [NSString string];
                
                UILabel *name = [[UILabel alloc] initWithFrame:iv.bounds];
                name.layer.backgroundColor = THEMECOLOR.CGColor;
                name.textColor = [UIColor whiteColor];
                name.textAlignment = NSTextAlignmentCenter;
                name.font = sysFontWithSize(name.frame.size.width/3);
                if (userName.length <= 0) {
                    if ([userId intValue] == [MY_USER_ID intValue]) {
                        nameStr = MY_USER_NAME;
                    }else {
                        nameStr = user.userNickname;
                    }
                }else {
                    nameStr = userName;
                }
                name.text = [self subTextString:nameStr len:2];
                
                [iv addSubview:name];
                
                if (nameStr.length <= 0) {
                    [name removeFromSuperview];
                    iv.image = placeholderImage;
                }
            }

        }
        
//        if (iv.image.size.width != iv.image.size.height) {
//            CGRect rect;//然后，将此部分从图片中剪切出来
//            if (iv.image.size.width > iv.image.size.height) {
//                rect = CGRectMake((iv.image.size.width - iv.image.size.height) / 2, 0, iv.image.size.height, iv.image.size.height);
//            }else {
//                rect = CGRectMake(0, (iv.image.size.height - iv.image.size.width) / 2, iv.image.size.width, iv.image.size.width);
//            }
//
//            CGImageRef imageRef = CGImageCreateWithImageInRect([iv.image CGImage], rect);
//
//            UIImage *image1 = [UIImage imageWithCGImage:imageRef];
//
//            iv.image = image1;
//        }
        
    }];
    
}

-(NSString*)subTextString:(NSString*)str len:(NSInteger)len{
    if(str.length<=len)return str;
    int count=0;
    NSMutableString *sb = [NSMutableString string];
    for (NSUInteger i=str.length-1; i>0; i--) {
        NSRange range = NSMakeRange(i, 1) ;
        NSString *aStr = [str substringWithRange:range];
        count += [aStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1?2:1;
        [sb insertString:aStr atIndex:0];
        if(count >= len*2-1) {
            if (sb.length <= 2) {
                return [sb copy];
            }
            if (count >= len*2) {
                return [sb copy];
            }
        }
    }
    return str;
}

-(void)WH_getImageWithUrl:(NSString*)url imageView:(UIImageView*)iv{
    for (UIView *subView in iv.subviews) {
        [subView removeFromSuperview];
    }
    
    [iv sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"avatar_normal"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if (iv.image.size.width != iv.image.size.height) {
            CGRect rect;//然后，将此部分从图片中剪切出来
            if (iv.image.size.width > iv.image.size.height) {
                rect = CGRectMake((iv.image.size.width - iv.image.size.height) / 2, 0, iv.image.size.height, iv.image.size.height);
            }else {
                rect = CGRectMake(0, (iv.image.size.height - iv.image.size.width) / 2, iv.image.size.width, iv.image.size.width);
            }
            
            CGImageRef imageRef = CGImageCreateWithImageInRect([iv.image CGImage], rect);
            
            UIImage *image1 = [UIImage imageWithCGImage:imageRef];
            
            iv.image = image1;
        }
    }];
    
//    //按比例缩小iv
//    float count = iv.frame.size.height / iv.image.size.height;
//
//    iv.frame = CGRectMake(0, iv.frame.origin.y, iv.image.size.width * count, iv.frame.size.height);
//
//    iv.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)WH_delHeadImageWithUserId:(NSString*)userId{
    
    NSString* s1;
    //获取userId
    if([userId isKindOfClass:[NSNumber class]])
        s1 = [(NSNumber*)userId stringValue];
    else
        s1 = userId;
    
    NSString* dir1 = [NSString stringWithFormat:@"%lld",[s1 longLongValue] % 10000];
    //头像网址
    NSString* url1  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir1,s1];
    NSString* url2  = [NSString stringWithFormat:@"%@avatar/o/%@/%@.jpg",g_config.downloadAvatarUrl,dir1,s1];
    if ([url1 isUrl]) {
        [[SDImageCache sharedImageCache] removeImageForKey:url1 withCompletion:nil];
    }
    if ([url2 isUrl]) {
        [[SDImageCache sharedImageCache] removeImageForKey:url2 withCompletion:nil];
    }
    
//    [[SDImageCache sharedImageCache] removeImageForKey:url1];
//    [[SDImageCache sharedImageCache] removeImageForKey:url2];
}


-(void)waitStart:(UIView*)view{
    [self waitEnd:view];
    
    UIActivityIndicatorView* aiv;
    aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.center = view.center;
    //aiv.center = CGPointMake(view.bounds.size.width / 2.0f, view.bounds.size.height/2 + 30.0f);
    [aiv startAnimating];
    [view addSubview:aiv];
    //    [aiv release];
    [self performSelector:@selector(waitFree:) withObject:view afterDelay:WH_connect_timeout];
    
    [_dictWaitViews setObject:aiv forKey:[NSString stringWithFormat:@"%ld",view.tag]];
    //    NSLog(@"_dictWaitViews=%d",[_dictWaitViews count]);
}

-(void)waitEnd:(UIView*)view{
    UIActivityIndicatorView* aiv = [_dictWaitViews objectForKey:[NSString stringWithFormat:@"%ld",view.tag]];
    if(aiv)
        @try {
            [aiv stopAnimating];
            aiv.hidden = YES;
        }
    @catch (NSException *exception) {
    }
    aiv =nil;
}

-(void)waitFree:(UIView*)sender{
    NSString* s=[NSString stringWithFormat:@"%ld",sender.tag];
    UIActivityIndicatorView* aiv = [_dictWaitViews objectForKey:s];
    [_dictWaitViews removeObjectForKey:s];
    //    NSLog(@"_dictWaitViews=%d",[_dictWaitViews count]);
    
    [aiv stopAnimating];
    [aiv removeFromSuperview];
    aiv = nil;
}

-(void)showMsg:(NSString*)s{
    [g_window addSubview:_hud.view];
    [_hud setCaption:s];
    [_hud show];
    [_hud hideAfter:1.0];
}

-(void)showMsg:(NSString*)s delay:(float)delay{
    [g_window addSubview:_hud.view];
    [_hud setCaption:s];
    [_hud show];
    if (delay)
        [_hud hideAfter:delay];
    else
        [_hud hideAfter:1.0];
}

-(NSString*)getString:(NSString*)s{
    if(s == nil || ![s isKindOfClass:[NSString class]])
        return @"";
    else
        return s;
}

//获取服务器当前时间
- (void)getCurrentTimeToView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_getCurrentTime param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
//第二通道新增接口  2020/05/21 by:hlx
-(void)syncMessages:(NSString*)theUserId orDelete:(NSString*)isDelete withUrl:(NSString*)url toView:(id)toView{
    WH_JXConnection* p = [self addTask:url param:nil toView:toView];
    [p setPostValue:@"youjob" forKey:@"device"];
    [p setPostValue:access_token forKey:@"token"];
    [p setPostValue:isDelete forKey:@"delete"];
    [p go];
}
#pragma mark 群签到详情 签到详情
- (void)requestSignInDetailsWithRoomId:(NSString *)roomId toView:(id)toView {
    WH_JXConnection* p = [self addTask:act_SignInDetails param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

#pragma mark 立即签到
- (void)requestSignInRightNowWithRoomId:(NSString *)roomId nickName:(NSString *)nickName toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_SignInRightNow param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:nickName forKey:@"nickName"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
    
}

#pragma mark 群签到日期
- (void)requestSignInDateWithRoomId:(NSString *)roomId monthStr:(NSString *)monthStr toView:(id)toView {
    WH_JXConnection* p = [self addTask:act_SignInDate param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:monthStr forKey:@"monthStr"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

#pragma mark 签到列表
- (void)requestSignInDetailsListWithRoomId:(NSString *)roomId toView:(id)toView {
    WH_JXConnection* p = [self addTask:act_SignInDetailsRoom param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

#pragma mark 兑换礼物
- (void)requestExchangeGiftWithData:(NSString *)data toView:(id)toView {
    WH_JXConnection *p = [self addTask:act_ExchangeGift param:nil toView:toView];
    [p setPostValue:data forKey:@"requestData"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

#pragma mark-----登录加密
-(void)login:(WH_JXUserObject*)user loginType:(NSInteger)type toView:(id)toView {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    WH_JXConnection* p = [self addTask:wh_act_UserLogin param:nil toView:toView];
    if  (type == 1) {
        if (user.account) {
            NSString *md5Str = [self WH_getMD5StringWithStr:user.account];
            [p setPostValue:md5Str forKey:@"telephone"];
        }
    }else {
        if (user.phone) {
            NSString *md5Str = [self WH_getMD5StringWithStr:user.phone];
            [p setPostValue:md5Str forKey:@"telephone"];
        }
    }
    
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"registerType"];
    [p setPostValue:user.areaCode?:@"" forKey:@"areaCode"];
    [p setPostValue:user.password?:@"" forKey:@"password"];
    [p setPostValue:user.verificationCode?:@"" forKey:@"verificationCode"];
    [p setPostValue:@"client_credentials" forKey:@"grant_type"];
    [p setPostValue:user.model?:@"" forKey:@"model"];
    [p setPostValue:user.osVersion?:@"" forKey:@"osVersion"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    [p setPostValue:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    [p setPostValue:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
    [p setPostValue:user.location?:@"" forKey:@"location"];
    [p setPostValue:identifier forKey:@"appId"];
    [p setPostValue:@"iOS" forKey:@"appBrand"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"xmppVersion"];
    
    // 登录类型 0：账号密码登录，1：短信验证码登录
    if (user.verificationCode.length > 0) {
        [p setPostValue:@1 forKey:@"loginType"];
    }else {
        [p setPostValue:@0 forKey:@"loginType"];
    }
    // 是否开启集群
    if ([g_config.isOpenCluster integerValue] == 1) {
        NSString *area = [g_default objectForKey:kLocationArea];
        [p setPostValue:area?:@"" forKey:@"area"];
    }
    [p go];
}

-(void)login:(WH_JXUserObject*)user toView:(id)toView{
    
    NSLog(@"%@",g_macAddress);
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    WH_JXConnection* p = [self addTask:wh_act_UserLogin param:nil toView:toView];
    
    [p setPostValue:[self WH_getMD5StringWithStr:user.telephone] forKey:@"telephone"];
    [p setPostValue:user.areaCode forKey:@"areaCode"];
    [p setPostValue:user.password forKey:@"password"];
    [p setPostValue:user.verificationCode forKey:@"verificationCode"];
    [p setPostValue:@"client_credentials" forKey:@"grant_type"];
    [p setPostValue:user.model forKey:@"model"];
    [p setPostValue:user.osVersion forKey:@"osVersion"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    [p setPostValue:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    [p setPostValue:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
    [p setPostValue:user.location forKey:@"location"];
    [p setPostValue:identifier forKey:@"appId"];
    [p setPostValue:@"iOS" forKey:@"appBrand"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"xmppVersion"];
    
    // 登录类型 0：账号密码登录，1：短信验证码登录
    if (user.verificationCode.length > 0) {
        [p setPostValue:@1 forKey:@"loginType"];
    }else {
        [p setPostValue:@0 forKey:@"loginType"];
    }
    // 是否开启集群
    if ([g_config.isOpenCluster integerValue] == 1) {
        NSString *area = [g_default objectForKey:kLocationArea];
        [p setPostValue:area forKey:@"area"];
    }
    [p go];
}

-(BOOL)autoLogin:(id)toView{
    NSString * userId = MY_USER_ID;
    NSString * token = [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_TOKEN];
    NSString * userName = MY_USER_NAME;
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if([token length]<=0)
        return NO;
    
    myself.userId = userId;
    myself.userNickname = userName;
    self.access_token = token;
    
    WH_JXConnection* p = [self addTask:wh_act_UserLoginAuto param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:token forKey:@"access_token"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    [p setPostValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [p setPostValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [p setPostValue:identifier forKey:@"appId"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"xmppVersion"];
    [p setPostValue:@"iOS" forKey:@"appBrand"];
    // 是否开启集群
    if ([g_config.isOpenCluster integerValue] == 1) {
        NSString *area = [g_default objectForKey:kLocationArea];
        [p setPostValue:area forKey:@"area"];
    }
    [p go];
    return YES;
}

#pragma makr -- 获取启动图的广告图
- (void)getStartUpImageToView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_AppStartupImage param:nil toView:toView];
    
    [p go];
}

#pragma mark----登出
-(void)logout:(NSString *)areaCode toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_UserLogout param:nil toView:toView];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    [p setPostValue:access_token forKey:@"access_token"];
    
    [p setPostValue:[self WH_getMD5StringWithStr:myself.telephone] forKey:@"telephone"];
    [p setPostValue:areaCode forKey:@"areaCode"];
    [p setPostValue:myself.userId forKey:@"userId"];
    [p setPostValue:myself.model forKey:@"model"];
    [p setPostValue:myself.osVersion forKey:@"osVersion"];
    [p setPostValue:myself.serialNumber forKey:@"serialNumber"];
    [p setPostValue:myself.latitude forKey:@"latitude"];
    [p setPostValue:myself.longitude forKey:@"longitude"];
    [p setPostValue:myself.location forKey:@"location"];
    [p setPostValue:identifier forKey:@"appId"];
    [p setPostValue:@"ios" forKey:@"deviceKey"];
    [p go];
    
    self.lastOfflineTime = [[NSDate date] timeIntervalSince1970];
//    [g_default setBool:NO forKey:WH_ThirdPartyLogins];
    [g_default setObject:[NSNumber numberWithLongLong:self.lastOfflineTime] forKey:kLastOfflineTime];
    [g_default synchronize];
}

-(void)outTime:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_OutTime param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:myself.userId forKey:@"userId"];
    
    [p go];
    
    self.lastOfflineTime = [[NSDate date] timeIntervalSince1970];
    [g_default setObject:[NSNumber numberWithLongLong:self.lastOfflineTime] forKey:kLastOfflineTime];
    [g_default synchronize];
}



-(void)doGetUserIdList:(NSMutableDictionary*)map array:(NSArray*)array{
    //    for(int i=0;i<[map count];i++){
    //        [[[map allValues] objectAtIndex:i] release];
    //        [[[map allKeys] objectAtIndex:i] release];
    //    }
    [map removeAllObjects];
    
    for(int i=0;i<[array count];i++){
        NSDictionary* p = [array objectAtIndex:i];
        [map setObject:[[p objectForKey:@"keyId"] copy] forKey:[[p objectForKey:@"userId"] copy]];
        p = nil;
    }
}

-(void)doLoginOK:(NSDictionary*)dict user:(WH_JXUserObject*)user{
    
    isLogin = YES;
    if (user != nil) {
        myself.password = user.password;
        myself.telephone = user.telephone;
        myself.userId = user.userId;
        myself.companyId = user.companyId;
        myself.userNickname = user.userNickname;
        myself.areaCode = [NSString stringWithFormat:@"%@",user.areaCode];
        myself.myInviteCode = user.myInviteCode;
        myself.role = user.role;
    }
    if (dict != nil && dict.allKeys.count) {
        [self doSaveUser:dict];//保存用户信息
    }
    
    [self performSelector:@selector(setPushChannelId:) withObject:[BPush getChannelId] afterDelay:2];
    if([dict objectForKey:@"access_token"])
        self.access_token = [dict objectForKey:@"access_token"];
    
    [self saveDefaultSetting];//写到配置表
    
    // 创建系统号
    [[WH_JXUserObject sharedUserInstance] WH_createSystemFriend];
    self.multipleLogin = [JXMultipleLogin sharedInstance];
    [FileInfo createDir:myTempFilePath];
#if TAR_IM
#ifdef Meeting_Version
    [g_meeting WH_startMeeting];
    if ([g_default objectForKey:@"voipToken"]) {
        [g_server pkpushSetToken:[g_default objectForKey:@"voipToken"] deviceId:nil isVoip:1 toView:nil];
    }
#endif
#endif
    
    // 上传推送apnsToken
    if ([g_default objectForKey:@"apnsToken"]) {
        
        [g_server pkpushSetToken:[g_default objectForKey:@"apnsToken"] deviceId:nil isVoip:0 toView:nil];
    }
    
    if ([g_myself.telephone isEqualToString:@"18938880001"]) {
        myself.phoneDic = [myself getPhoneDic];
    }
    
    // 登录成功后清除过期聊天记录
    [[WH_JXUserObject sharedUserInstance] WH_deleteUserChatRecordTimeOutMsg];
    
    // 上传通讯录
    _addressBook = [JXAddressBook sharedInstance];
    [_addressBook uploadAddressBookContacts];
    
    
    // 系统登录成功
    [g_notify postNotificationName:kSystemLogin_WHNotifaction object:self userInfo:nil];
}

-(void)doSaveUser:(NSDictionary*)dict{
    if([dict objectForKey:@"userId"])
        myself.userId = [[dict objectForKey:@"userId"] stringValue];
    if([dict objectForKey:@"nickname"])
        myself.userNickname = [dict objectForKey:@"nickname"];
    if([dict objectForKey:@"companyId"])
        myself.companyId = [dict objectForKey:@"companyId"];
    if([dict objectForKey:@"password"])
        myself.password = [dict objectForKey:@"password"];
    NSString *passwordsalt = [NSString stringWithFormat:@"%@",[dict objectForKey:@"salt"]];
    if (passwordsalt.length) {
        [g_default setObject:passwordsalt forKey:kMY_USER_PASSWORDSalt];
        [g_default synchronize];
    }
    if([dict objectForKey:@"telephone"])
        myself.telephone = [dict objectForKey:@"telephone"];
    if([dict objectForKey:@"areaCode"])
        myself.areaCode = [dict objectForKey:@"areaCode"];
    if([dict objectForKey:@"myInviteCode"])
        myself.myInviteCode = [dict objectForKey:@"myInviteCode"];
    if ([dict objectForKey:@"role"]) {
        myself.role = [dict objectForKey:@"role"];
    }
    if([[dict objectForKey:@"login"] objectForKey:@"offlineTime"]){
        long long lastOfflineTime = [[g_default objectForKey:kLastOfflineTime] longLongValue];
        if (lastOfflineTime > 0) {
            self.lastOfflineTime = lastOfflineTime;
        }else {
            self.lastOfflineTime = [[[dict objectForKey:@"login"] objectForKey:@"offlineTime"] longLongValue];
        }
    }
    if ([dict objectForKey:@"friendCount"]) {
        myself.friendCount   = [dict objectForKey:@"friendCount"];
    }
    
    if ([dict objectForKey:@"settings"]) {
        myself.chatRecordTimeOut = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"chatRecordTimeOut"]];
        if (IS_ChatMsgSyncForever_Open) {
            myself.chatSyncTimeLen = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"chatSyncTimeLen"]];
            myself.groupChatSyncTimeLen = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"groupChatSyncTimeLen"]];
        }
        
        myself.friendsVerify = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"friendsVerify"]];
        myself.isEncrypt = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"isEncrypt"]];
        myself.isTyping = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"isTyping"]];
        myself.isVibration = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"isVibration"]];
        myself.multipleDevices = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"multipleDevices"]];
        myself.isUseGoogleMap = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"settings"] objectForKey:@"isUseGoogleMap"]];
    }
    
    myself.countryId = [dict objectForKey:@"countryId"];
    myself.provinceId = [dict objectForKey:@"provinceId"];
    myself.cityId = [dict objectForKey:@"cityId"];
    myself.areaId = [dict objectForKey:@"areaId"];
    myself.level = [dict objectForKey:@"level"];
    myself.vip = [dict objectForKey:@"vip"];
    myself.userType = [dict objectForKey:@"userType"];
    myself.status = [dict objectForKey:@"status"];
    myself.attCount = [dict objectForKey:@"attCount"];
    myself.fansCount = [dict objectForKey:@"fansCount"];
    myself.sex    = [dict objectForKey:@"sex"];
    myself.userDescription   = [dict objectForKey:@"description"];
    myself.isupdate = [dict objectForKey:@"isupdate"];
//    myself.isMultipleLogin = [dict objectForKey:@"multipleDevices"];
    myself.isPayPassword = [dict objectForKey:@"payPassword"];
    myself.questions = dict[@"questions"];
    myself.birthday = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"birthday"] longLongValue]];
    myself.timeCreate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"createTime"] longLongValue]];
    if (dict[@"account"]) {
        myself.account = dict[@"account"];
    }else {
        myself.account = dict[@"userId"];
    }
     [dict objectForKey:@"account"];
    myself.setAccountCount = [dict objectForKey:@"setAccountCount"];
}

-(void)saveDefaultSetting{
    //    [g_App saveMeetingId:myself.userId];
    //初始化一个供App Groups使用的NSUserDefaults对象
    //写入数据
    [g_default setObject:self.access_token forKey:kMY_USER_TOKEN];
    [share_defaults setValue:self.access_token forKey:kMY_ShareExtensionToken];
    [g_default synchronize]; //防止登录成功进入主界面了,但是token还没有存好
    if (!IsObjectNull(myself.password)) {
        [g_default setObject:myself.password forKey:kMY_USER_PASSWORD];
        [share_defaults setValue:myself.password forKey:kMY_ShareExtensionPassword];
        [g_default synchronize];
    }
    if (!IsStringNull(myself.userId)) {
        [g_default setObject:myself.userId forKey:kMY_USER_ID];
        [share_defaults setValue:myself.userId forKey:kMY_ShareExtensionUserId];
    }
    if (!IsObjectNull(myself.areaCode)) {
        [g_default setObject:myself.areaCode forKey:kMY_USER_AREACODE];
    }
    [g_default setObject:myself.companyId forKey:kMY_USER_COMPANY_ID];
    [g_default setObject:myself.userNickname forKey:kMY_USER_NICKNAME];
    [g_default setObject:myself.myInviteCode forKey:kMY_USER_INVITECODE];
    [g_default setObject:myself.role forKey:kMY_USER_ROLE];
    [g_default setObject:myself.account forKey:kMY_USER_ACCOUNT];
}

-(void)readDefaultSetting{
    myself.password = [g_default objectForKey:kMY_USER_PASSWORD];
    myself.telephone = [g_default objectForKey:kMY_USER_LoginName];
    myself.userId = [g_default objectForKey:kMY_USER_ID];
//    myself.companyId =[g_default objectForKey:kMY_USER_COMPANY_ID];
    self.access_token = [g_default objectForKey:kMY_USER_TOKEN];
    myself.myInviteCode = [g_default objectForKey:kMY_USER_INVITECODE];
//    myself.role = [g_default objectForKey:kMY_USER_ROLE];
//    myself.userNickname = MY_USER_NAME;
//    myself.account = [g_default objectForKey:kMY_USER_ACCOUNT];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    
    if (alertView.tag == 11000) {
        [g_xmpp.reconnectTimer invalidate];
        g_xmpp.reconnectTimer = nil;
        g_xmpp.isReconnect = NO;
        [g_xmpp logout];
        NSLog(@"XMPP ---- jxserver");
        
        if (![g_navigation.rootViewController isKindOfClass:[WH_LoginViewController class]]) {
            
            [self showLogin];
        }else {
            
            }
    }else {
        NSString * URLString = AppStoreString;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    }
}


-(long)getUserIdFromDict:(NSDictionary*)dict key:(NSString*)key{
    NSArray* p=[dict allKeys];
    long j=-1;
    for(int i=0;i<[p count];i++){
        if([key isEqualToString:[p objectAtIndex:i]]){
            j=i;
            break;
        }
    }
    
    if(j<[p count] && j>=0)
        j = [[[dict allValues] objectAtIndex:j] intValue];
    else
        j = 0;
    p = nil;
    return j;
}

-(void) showAddMoney:(NSDictionary*)dict msg:(NSString*)s autoHide:(BOOL)autoHide{
    if(s == nil)
        s = Localized(@"JXServer_OK");
    if([dict objectForKey:@"thisMoney"] != nil){
        int n = [[dict objectForKey:@"thisMoney"] intValue];
        self.count_money += n;
        if(self.count_money<0)
            self.count_money = 0;
        if(n>=0)
            s = [NSString stringWithFormat:@"%@,%@%d%@%ld",s,Localized(@"JXServer_SystemSend1"),n,Localized(@"JXServer_SystemSend2"),self.count_money];
        else
            s = [NSString stringWithFormat:@"%@,%@%d%@%ld",s,Localized(@"JXServer_SystemSend3"),n,Localized(@"JXServer_SystemSend2"),self.count_money];
    }
    if(autoHide)
        [self showMsg:s];
    else
        [g_App showAlert:s];
}


-(void)bindUser:(NSString*)blogId type:(int)type toView:(id)toView{
    [self addTask:wh_act_BindUser param:[NSString stringWithFormat:@"?blogId=%@&type=%d",blogId,type] toView:toView];
}

-(void)unBindUser:(NSString*)blogId type:(int)type toView:(id)toView{
    [self addTask:wh_act_unbindUser param:[NSString stringWithFormat:@"?blogId=%@&type=%d",blogId,type] toView:toView];
}

-(void)selectBindUser:(id)toView{
}

#pragma mark 发现界面自定义菜单
- (void)requestCustomMenuWithToView:(id)toView {
     WH_JXConnection* p = [self addTask:wh_act_CustomMenu param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInteger:1] forKey:@"user"];
    [p go];
}

- (void)wh_deleteMembersWithRoomId:(NSString *)roomId userId:(NSString *)userId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_deleteMemebers param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_checkPhoneWithPhoneNum:(NSString*)phone areaCode:(NSString *)areaCode verifyType:(int)verifyType toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_CheckPhone param:nil toView:toView];
    [p setPostValue:phone forKey:@"telephone"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    [p setPostValue:areaCode forKey:@"areaCode"];
    if (verifyType > 0) {
        [p setPostValue:[NSNumber numberWithInt:verifyType] forKey:@"verifyType"];
    }
    [p go];
}

-(NSString*)WH_getMD5StringWithStr:(NSString*)s{
    if(IsStringNull(s))
        return nil;
//    if(s.length == 32){
//        return s;
//    }
    const char *buf = [s cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char md[MD5_DIGEST_LENGTH];
    unsigned long n = strlen(buf);
    MD5(buf, n, md);
    
//    printf("%s md5: ", buf);
    char t[50]="",p[50]="";
    int i;
    for(i = 0; i< MD5_DIGEST_LENGTH; i++){
        sprintf(t, "%02x", md[i]);
        strcat(p, t);
        printf("%02x", md[i]);
    }
    s = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
    printf("/n");
    //    NSLog(@"%@",s);
    return s;
}

- (NSString *)MD5WithStr:(NSString *)str AndSalt:(NSString *)salt
{
    
    NSString *S0 = [salt substringWithRange:NSMakeRange(0, 1)];
    NSString *S2 = [salt substringWithRange:NSMakeRange(2, 1)];
    NSString *S5 = [salt substringWithRange:NSMakeRange(5, 1)];
    NSString *S4 = [salt substringWithRange:NSMakeRange(4, 1)];
    
    NSString *saltStr = [NSString stringWithFormat:@"%@%@%@%@%@",S0,S2,str,S5,S4];
    
    return [self WH_getMD5StringWithStr:saltStr];
}
//sha1加密方式
- (NSString *)sha1:(NSString *)input
{
    //这两句容易造成 、中文字符串转data时会造成数据丢失
    //const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [NSData dataWithBytes:cstr length:input.length];
    //instead of
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

#pragma mark-----注册密码加密
-(void)WH_registerUserWithUserData:(WH_JXUserObject*)user inviteCode:(NSString *)inviteCode workexp:(int)workexp diploma:(int)diploma isSmsRegister:(BOOL)isSmsRegister toView:(id)toView{
    WH_JXConnection* p;
    if (self.openId.length <= 0) {
        p = [self addTask:wh_act_Register param:nil toView:toView];
    }else {
        p = [self addTask:wh_act_RegisterSDK param:nil toView:toView];
        [p setPostValue:[NSNumber numberWithInteger:self.thirdType] forKey:@"type"];
        [p setPostValue:self.openId forKey:@"loginInfo"];
    }
    [p setPostValue:user.telephone forKey:@"telephone"];
    [p setPostValue:user.password forKey:@"password"];
    [p setPostValue:user.areaCode forKey:@"areaCode"];
    [p setPostValue:user.userType forKey:@"userType"];
    [p setPostValue:user.userNickname forKey:@"nickname"];
    [p setPostValue:user.userDescription forKey:@"description"];
    [p setPostValue:[NSNumber numberWithLongLong:[user.birthday timeIntervalSince1970]] forKey:@"birthday"];
    [p setPostValue:user.sex forKey:@"sex"];
    [p setPostValue:user.companyId forKey:@"companyId"];
    [p setPostValue:user.countryId forKey:@"countryId"];
    [p setPostValue:user.provinceId forKey:@"provinceId"];
    if ([user.cityId integerValue] > 0) {
        [p setPostValue:user.cityId forKey:@"cityId"];
    }else {
        [p setPostValue:[NSNumber numberWithInt:self.cityId] forKey:@"cityId"];
    }
    [p setPostValue:user.areaId forKey:@"areaId"];
    [p setPostValue:user.model forKey:@"model"];
    [p setPostValue:user.osVersion forKey:@"osVersion"];
    [p setPostValue:user.serialNumber forKey:@"serialNumber"];
    [p setPostValue:user.latitude forKey:@"latitude"];
    [p setPostValue:user.longitude forKey:@"longitude"];
    [p setPostValue:user.location forKey:@"location"];
    [p setPostValue:[NSNumber numberWithInt:workexp] forKey:@"w"];
    [p setPostValue:[NSNumber numberWithInt:diploma] forKey:@"d"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"xmppVersion"];
    [p setPostValue:[NSNumber numberWithInt:(isSmsRegister ? 1 : 0)] forKey:@"isSmsRegister"];
    [p setPostValue:inviteCode forKey:@"inviteCode"];
    [p go];
}
-(void)registerUser:(WH_JXUserObject*)user inviteCode:(NSString *)inviteCode  isSmsRegister:(BOOL)isSmsRegister registType:(NSInteger)registType passSecurity:(NSString *)passSecurity smsCode:(NSString *)smsCode toView:(id)toView{
    WH_JXConnection* p;
    if (self.openId.length <= 0) {
        p = [self addTask:wh_act_Register param:nil toView:toView];
    }else {
        p = [self addTask:wh_act_RegisterSDK param:nil toView:toView];
        [p setPostValue:[NSNumber numberWithInteger:self.thirdType] forKey:@"type"];
        [p setPostValue:self.openId forKey:@"loginInfo"];
    }
    if (registType == 1 && !IsStringNull(passSecurity)) {
        [p setPostValue:passSecurity forKey:@"questions"];
    }
    [p setPostValue:smsCode forKey:@"smsCode"];
    [p setPostValue:[NSNumber numberWithInteger:registType] forKey:@"registerType"];
    [p setPostValue:user.telephone forKey:@"telephone"];
    [p setPostValue:user.password forKey:@"password"];
    [p setPostValue:user.areaCode forKey:@"areaCode"];
    [p setPostValue:user.userType forKey:@"userType"];
    [p setPostValue:user.userNickname forKey:@"nickname"];
    [p setPostValue:user.userDescription forKey:@"description"];
    [p setPostValue:[NSNumber numberWithLongLong:[user.birthday timeIntervalSince1970]] forKey:@"birthday"];
    [p setPostValue:user.sex forKey:@"sex"];
    //    [p setPostValue:user.companyId forKey:@"companyId"];
    //    [p setPostValue:user.countryId forKey:@"countryId"];
    //    [p setPostValue:user.provinceId forKey:@"provinceId"];
    if ([user.cityId integerValue] > 0) {
        [p setPostValue:user.cityId forKey:@"cityId"];
    }else {
        [p setPostValue:[NSNumber numberWithInt:self.cityId] forKey:@"cityId"];
    }
    [p setPostValue:user.areaId forKey:@"areaId"];
    [p setPostValue:user.model forKey:@"model"];
    [p setPostValue:user.osVersion forKey:@"osVersion"];
    [p setPostValue:user.serialNumber forKey:@"serialNumber"];
    [p setPostValue:user.latitude forKey:@"latitude"];
    [p setPostValue:user.longitude forKey:@"longitude"];
    [p setPostValue:user.location forKey:@"location"];
    //    [p setPostValue:[NSNumber numberWithInt:workexp] forKey:@"w"];
    //    [p setPostValue:[NSNumber numberWithInt:diploma] forKey:@"d"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"xmppVersion"];
    [p setPostValue:[NSNumber numberWithInt:(isSmsRegister ? 1 : 0)] forKey:@"isSmsRegister"];
    [p setPostValue:inviteCode forKey:@"inviteCode"];
    [p go];
}
-(void)WH_checkPhoneWithPhoneNum:(NSString*)phone toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_CheckPhone param:nil toView:toView];
    [p setPostValue:phone forKey:@"telephone"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_checkPhoneWithPhoneNum:(NSString*)phone inviteCode:(NSString *)inviteCode toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_CheckPhone param:nil toView:toView];
    [p setPostValue:phone forKey:@"telephone"];
    [p setPostValue:inviteCode forKey:@"inviteCode"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
- (void)checkPhone:(NSString*)phone registerType:(NSInteger)registerType smsCode:(NSString *)smsCode inviteCode:(NSString *)inviteCode toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_CheckPhone param:nil toView:toView];
    [p setPostValue:phone forKey:@"telephone"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:smsCode forKey:@"smsCode"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    if (!IsStringNull(inviteCode)) {
        [p setPostValue:inviteCode forKey:@"inviteCode"];
    }
    [p setPostValue:[NSNumber numberWithInteger:registerType] forKey:@"registerType"];
    [p go];
}
- (void)checkUser:(NSString *)userName inviteCode:(NSString *)inviteCode toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_CheckPhone param:nil toView:toView];
    [p setPostValue:userName forKey:@"telephone"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    if (!IsStringNull(inviteCode)) {
        [p setPostValue:inviteCode forKey:@"inviteCode"];
    }
    [p setPostValue:@(1) forKey:@"registerType"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
- (void)checkPhoneNum:(NSDictionary *)params toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_CheckPhone param:nil toView:toView];
    [p setPostValue:params[@"telephone"] forKey:@"telephone"];
    [p setPostValue:params[@"smsCode"] forKey:@"smsCode"];
    [p setPostValue:params[@"areaCode"] forKey:@"areaCode"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    NSString *inviteCode = params[@"inviteCode"];
    if (!IsStringNull(inviteCode)) {
        [p setPostValue:inviteCode forKey:@"inviteCode"];
    }
    [p setPostValue:@(0) forKey:@"registerType"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


-(NSString *)getImgCode:(NSString*)telephone areaCode:(NSString *)areaCode{
    if(telephone==nil)
        return nil;
    //    http://192.168.0.168:8080/getImgCode?telephone=8618318722019
    NSString *s;
    NSRange range = [g_config.apiUrl rangeOfString:@"config"];
    if (range.location != NSNotFound) {
        s = [g_config.apiUrl substringToIndex:range.location];
    }else {
        s = g_config.apiUrl;
    }
    return [NSString stringWithFormat:@"%@%@?telephone=%@%@",s,wh_act_GetCode,areaCode,telephone];
}

-(void)WH_updateUser:(WH_JXUserObject*)user toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_UserUpdate param:nil toView:toView];
    if ([user.userType intValue]) {
        [p setPostValue:user.userType forKey:@"userType"];
    }
    if (user.userNickname) {
        [p setPostValue:user.userNickname forKey:@"nickname"];
    }
    if (user.userDescription) {
        [p setPostValue:user.userDescription forKey:@"description"];
    }
    if (user.birthday) {
        [p setPostValue:[NSNumber numberWithLongLong:[user.birthday timeIntervalSince1970]] forKey:@"birthday"];
    }
    if (user.sex != nil) {
        [p setPostValue:user.sex forKey:@"sex"];
    }
    if ([user.countryId intValue]) {
        [p setPostValue:user.countryId forKey:@"countryId"];
    }
    
    if ([user.provinceId intValue]) {
        [p setPostValue:user.provinceId forKey:@"provinceId"];
    }
    if ([user.cityId intValue]) {
        [p setPostValue:user.cityId forKey:@"cityId"];
    }
    if ([user.areaId intValue]) {
        [p setPostValue:user.areaId forKey:@"areaId"];
    }
    if (user.payPassword) {
        [p setPostValue:[self WH_getMD5StringWithStr:user.payPassword] forKey:@"payPassword"];
    }
    if (user.msgBackGroundUrl) {
        [p setPostValue:user.msgBackGroundUrl forKey:@"msgBackGroundUrl"];
    }
    
    [p setPostValue:access_token forKey:@"access_token"];
    //    [p setPostValue:user.isMultipleLogin forKey:@"multipleDevices"];
    [p go];
}

-(void)WH_updateWaHuNum:(WH_JXUserObject*)user toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_UserUpdate param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:user.account forKey:@"account"];
    [p go];
}

-(void)getUser:(NSString*)theUserId toView:(id)toView{
    if(theUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_UserGet param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:theUserId forKey:@"userId"];
    [p go];
}

// 搜索公众号列表
- (void)WH_searchPublicWithKeyWorld:(NSString *)keyWorld limit:(int)limit page:(int)page toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_PublicSearch param:nil toView:toView];
    [p setPostValue:keyWorld forKey:@"keyWorld"];
    [p setPostValue:[NSNumber numberWithInt:limit] forKey:@"limit"];
    [p setPostValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


-(void)WH_reportUserWithToUserId:(NSString *)toUserId roomId:(NSString *)roomId webUrl:(NSString *)webUrl reasonId:(NSNumber *)reasonId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_Report param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:reasonId forKey:@"reason"];
    [p setPostValue:webUrl forKey:@"webUrl"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_saveImageToFileWithImage:(UIImage*)image file:(NSString*)file isOriginal:(BOOL)isOriginal{
    if(![[NSFileManager defaultManager] fileExistsAtPath:file]){
        NSData *data = [Photo image2Data:image isOriginal:isOriginal];
        [data writeToFile:file atomically:YES];
        data = nil;
    }
}

-(void)WH_saveDataToFileWithData:(NSData*)data file:(NSString*)file{
    if(![[NSFileManager defaultManager] fileExistsAtPath:file]){
        [data writeToFile:file atomically:YES];
        data = nil;
    }
}


-(void)uploadFile:(NSArray*)files audio:(NSString*)audio video:(NSString*)video file:(NSString*)file type:(int)type validTime:(NSString *)validTime timeLen:(int)timeLen toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_UploadFile param:nil toView:toView];
//    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"uploadFlag"];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:myself.userId forKey:@"userId"];
    if (!validTime) {
        validTime = @"-1";
    }
    [p setPostValue:validTime forKey:@"validTime"];
    NSString* s;
    for(int i=0;i<[files count];i++){
        s = [NSString stringWithFormat:@"file%d.jpg",i+1];
        [p setData:UIImageJPEGRepresentation([files objectAtIndex:i], 0.5) forKey:s messageId:nil];
    }
    [p setPostValue:@(timeLen) forKey:@"length"];
    [p setData:[NSData dataWithContentsOfFile:audio] forKey:[audio lastPathComponent] messageId:nil];
    if ([NSData dataWithContentsOfFile:video]) {
        [p setData:[NSData dataWithContentsOfFile:video] forKey:[video lastPathComponent] messageId:nil];
    }else {
        [p setData:[NSData dataWithContentsOfURL:[NSURL URLWithString:video]] forKey:[video lastPathComponent] messageId:nil];
    }
    [p setData:[NSData dataWithContentsOfFile:file] forKey:[file lastPathComponent] messageId:nil];
    [p go];
}
//上传文件到服务器（传路径）
-(void)uploadFile:(NSString*)file validTime:(NSString *)validTime messageId:(NSString *)messageId toView:(id)toView{
    if(!file)
        return;
    if(![[NSFileManager defaultManager] fileExistsAtPath:file])
        return;
    
    WH_JXConnection* p = [self addTask:wh_act_UploadFile param:nil toView:toView];
//    [p setPostValue:[NSNumber numberWithInt:2] forKey:@"uploadFlag"];
    [p setPostValue:MY_USER_ID forKey:@"userId"];
    if (!validTime) {
        validTime = @"-1";
    }
    [p setPostValue:validTime forKey:@"validTime"];
    [p setData:[NSData dataWithContentsOfFile:file] forKey:[file lastPathComponent] messageId:nil];
    p.userData = [file lastPathComponent];
    p.messageId = messageId;
    [p go];
}

// 上传文件（传data）
-(void)uploadFileData:(NSData*)data key:(NSString *)key toView:(id)toView{
    if(!data)
        return;
    if (!key) {
        return;
    }
    
    WH_JXConnection* p = [self addTask:wh_act_UploadFile param:nil toView:toView];
    //    [p setPostValue:[NSNumber numberWithInt:2] forKey:@"uploadFlag"];
    [p setPostValue:myself.userId forKey:@"userId"];
    [p setData:data forKey:key messageId:nil];
    p.userData = key;
    [p go];
}

-(void)WH_uploadHeadImageWithUserId:(NSString*)userId image:(UIImage*)image toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_UploadHeadImage param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setData:UIImageJPEGRepresentation(image, 0.5) forKey:@"file.jpg" messageId:nil];
    [p go];
}

#pragma mark 用户签到
- (void)requestUserSignInWithUserId:(NSString *)userId  toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_UserSign param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:[[UIDevice currentDevice] uuid] forKey:@"device"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

#pragma mark 签到信息
- (void)requestUserSignHandle7DaySignWithUserId:(NSString *)userId toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_SingWeek param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

#pragma mark 获取用户某月签到信息
- (void)requestUserSignMothWithUserId:(NSString *)userId monthStr:(NSString *)monthStr toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_SingMouth param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:monthStr forKey:@"monthStr"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//获取用户余额
-(void)WH_getUserMoenyToView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_getUserMoeny param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    
    [p go];
}

//获取签名
- (void)WH_getPaySignWithPrice:(NSString *)price payType:(NSInteger)payType toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_getSign param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:price forKey:@"price"];
    [p setPostValue:[NSNumber numberWithInteger:payType] forKey:@"payType"];
    [p go];
}

//用户余额充值(黑马交易用)
- (void)hmTransactionPayWithPrice:(NSString *)price payType:(NSInteger)payType payWap:(NSString *)payWap userIp:(NSString *)userIp toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_getSign param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:price forKey:@"price"];
    [p setPostValue:[NSNumber numberWithInteger:payType] forKey:@"payType"];
    [p setPostValue:payWap forKey:@"payWay"];
    [p setPostValue:userIp forKey:@"userIp"];
    [p go];
}

//获取支付宝授权authInfo
- (void)WH_getAliPayAuthInfoToView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_getAliPayAuthInfo param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
//保存支付宝用户Id
- (void)WH_safeAliPayUserIdWithUserId:(NSString *)aliUserId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_aliPayUserId param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:aliUserId forKey:@"aliUserId"];
    [p go];
}
//支付宝提现
- (void)WH_alipayTransferWithAmount:(NSString *)amount secret:(NSString *)secret time:(NSNumber *)time toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_alipayTransfer param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:amount forKey:@"amount"];
    [p setPostValue:secret forKey:@"secret"];
    [p setPostValue:time forKey:@"time"];
    [p go];
}

//二维码支付
- (void)WH_codePaymentWithCodeUrlStr:(NSString *)paymentCode money:(NSString *)money time:(long)time desc:(NSString *)desc secret:(NSString *)secret toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_codePayment param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:paymentCode forKey:@"paymentCode"];
    [p setPostValue:money forKey:@"money"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p setPostValue:desc forKey:@"desc"];
    [p setPostValue:secret forKey:@"secret"];

    [p go];
}

//二维码收款
- (void)WH_codeReceiptWithUserId:(NSString *)toUserId money:(NSString *)money time:(long)time desc:(NSString *)desc secret:(NSString *)secret toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_codeReceipt param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:money forKey:@"money"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p setPostValue:desc forKey:@"desc"];
    [p setPostValue:secret forKey:@"secret"];
    
    [p go];
}


//接受转账
- (void)WH_getTransferWithTransferId:(NSString *)transferId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_receiveTransfer param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:transferId forKey:@"id"];
    [p go];
}

//获取转账信息
- (void)WH_transferDetailWithTransId:(NSString *)transferId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_getTransferInfo param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:transferId forKey:@"id"];
    [p go];
}

//好友交易记录明细
- (void)WH_getConsumeRecordListInfoWithToUserId:(NSString *)toUserId pageIndex:(int)pageIndex pageSize:(int)pageSize toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_getConsumeRecordList param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];

    [p go];
}


//转账
- (void)WH_transferToPeopleWithUserId:(NSString *)toUserId money:(NSString *)money remark:(NSString *)remark time:(long)time secret:(NSString *)secret toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_sendTransfer param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:money forKey:@"money"];
    [p setPostValue:remark forKey:@"remark"];
    [p setPostValue:[NSString stringWithFormat:@"%ld",time] forKey:@"time"];
    [p setPostValue:secret forKey:@"secret"];
    [p go];
}




//发红包
- (void)WH_sendRedPacketWithMoneyNum:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId time:(long)time secret:(NSString *)secret toView:(id)toView{
    WH_JXConnection *p = [self addTask:act_sendRedPacket param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:roomJid forKey:@"roomJid"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:[NSNumber numberWithDouble:money] forKey:@"money"];
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [p setPostValue:[NSNumber numberWithInteger:count] forKey:@"count"];
    [p setPostValue:greet forKey:@"greetings"];
    [p setPostValue:[NSString stringWithFormat:@"%ld",time] forKey:@"time"];
    [p setPostValue:secret forKey:@"secret"];
    [p go];
}


//发红包(新版)
- (void)WH_sendRedPacketV1WithMoneyNum:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId time:(long)time secret:(NSString *)secret toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_sendRedPacketV1 param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:roomJid forKey:@"roomJid"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:[NSNumber numberWithDouble:money] forKey:@"moneyStr"];
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [p setPostValue:[NSNumber numberWithInteger:count] forKey:@"count"];
    [p setPostValue:greet forKey:@"greetings"];
    [p setPostValue:[NSString stringWithFormat:@"%ld",time] forKey:@"time"];
    [p setPostValue:secret forKey:@"secret"];
    [p go];
}

//指定联系人发红包
- (void)WH_sendRedPacketV1WithMoneyNum:(double)money type:(int)type count:(int)count greetings:(NSString *)greet roomJid:(NSString*)roomJid toUserId:(NSString *)toUserId toUserIds:(NSString *)toUserIds time:(long)time secret:(NSString *)secret toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_sendRedPacketV1 param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:roomJid forKey:@"roomJid"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:toUserIds forKey:@"toUserIds"];
    [p setPostValue:[NSNumber numberWithDouble:money] forKey:@"moneyStr"];
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [p setPostValue:[NSNumber numberWithInteger:count] forKey:@"count"];
    [p setPostValue:greet forKey:@"greetings"];
    [p setPostValue:[NSString stringWithFormat:@"%ld",time] forKey:@"time"];
    [p setPostValue:secret forKey:@"secret"];
    [p go];
}

//交易记录
- (void)WH_getConsumeRecordWithIndex:(NSInteger)pageIndex toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_consumeRecord param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    //    [p setPostValue:[NSNumber numberWithInteger:10] forKey:@"pageSize"];
    [p go];
}

// 获得发送的红包
- (void)WH_redPacketGetSendRedPacketListIndex:(NSInteger)index toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_redPacketGetSendRedPacketList param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInteger:index] forKey:@"pageIndex"];
    //    [p setPostValue:[NSNumber numberWithInteger:10] forKey:@"pageSize"];
    [p go];
}
// 获得接收的红包
- (void)WH_redPacketGetRedReceiveListIndex:(NSInteger)index toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_redPacketGetRedReceiveList param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInteger:index] forKey:@"pageIndex"];

    [p go];
}
// 红包回复
- (void)WH_redPacketReplyWithRedPacketid:(NSString *)redPacketId content:(NSString *)content toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_redPacketReply param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:redPacketId forKey:@"id"];
    [p setPostValue:content forKey:@"reply"];

    [p go];
}

// 增加提现账号
- (void)WH_addWithdrawalAccountWithParam:(NSDictionary *)param toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_userWithdrawMethodSet param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"type"]] forKey:@"type"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"alipayName"]] forKey:@"alipayName"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"alipayNumber"]] forKey:@"alipayNumber"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"bankUserName"]] forKey:@"bankUserName"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"bankCardNo"]] forKey:@"bankCardNo"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"bankName"]] forKey:@"bankName"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"subBankName"]] forKey:@"subBankName"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"remarks"]] forKey:@"remarks"];

    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"otherNode1"]] forKey:@"otherNode1"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"otherNode2"]] forKey:@"otherNode2"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"otherNode3"]] forKey:@"otherNode3"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"otherNode4"]] forKey:@"otherNode4"];
    [p setPostValue:[NSString stringWithFormat:@"%@", param[@"otherNode5"]] forKey:@"otherNode5"];
    [p go];
}

// 获取提现账号列表
- (void)WH_getWithdrawalAccountListWithParam:(NSDictionary *)param toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_userWithdrawMethodGet param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

// 删除提现账号
- (void)WH_deleteWithdrawalAccountWithAccountId:(NSString *)accountId accountType:(NSString *)type toView:(id)toView {
    WH_JXConnection *p = [self addTask:wh_act_userWithdrawMethodDelete param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:type forKey:@"type"];
    [p setPostValue:accountId forKey:@"id"];
    [p go];
}

- (void)WH_getRedPacketWithMsg:(NSString *)redPacketId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_getRedPacket param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:redPacketId forKey:@"id"];
    [p go];
}

- (void)WH_openRedPacketWithRedPacketId:(NSString *)redPacketId money:(NSString *)moneyStr toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_openRedPacket param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:redPacketId forKey:@"id"];
    if (!IsStringNull(moneyStr)) {
        [p setPostValue:moneyStr forKey:@"money"];
    }
    [p go];
}

-(void)addPhoto:(NSString*)photos toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_PhotoAdd param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:photos forKey:@"photos"];
    [p go];
}

-(void)delPhoto:(NSString*)photoId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_PhotoDel param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:photoId forKey:@"photoId"];
    [p go];
}

-(void)updatePhoto:(NSString*)photoId oUrl:(NSString*)oUrl tUrl:(NSString*)tUrl toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_PhotoMod param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:photoId forKey:@"photoId"];
    [p setPostValue:oUrl forKey:@"oUrl"];
    [p setPostValue:tUrl forKey:@"tUrl"];
    [p go];
}

-(void)listPhoto:(NSString*)theUserId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_PhotoList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:theUserId forKey:@"userId"];
    [p go];
}

-(void)setHeadImage:(NSString*)photoId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_SetHeadImage param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:photoId forKey:@"photoId"];
    [p go];
}

-(void)setGroupAvatarServlet:(NSString*)roomId image:(UIImage *)image toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_SetGroupAvatarServlet param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:roomId forKey:@"jid"];
    [p setData:UIImageJPEGRepresentation(image, 0.5) forKey:@"file.jpg" messageId:nil];
    [p go];
}

- (NSString *) getPhotoLocalPath:(NSString*)s
{
    return [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), [s lastPathComponent]];
}
- (void)resetPwd:(NSString*)telephone areaCode:(NSString *)areaCode randcode:(NSString*)randcode newPwd:(NSString*)newPassword registerType:(NSInteger)registerType toView:(id)toView {
    
    if(telephone==nil || newPassword==nil || randcode==nil)
        return;
    
    WH_JXConnection* p = [self addTask:wh_act_PwdReset param:nil toView:toView];
    [p setPostValue:telephone forKey:@"telephone"];
    [p setPostValue:randcode forKey:@"randcode"];
    [p setPostValue:areaCode forKey:@"areaCode"];
    [p setPostValue:[NSNumber numberWithInteger:registerType] forKey:@"registerType"];
    [p setPostValue:[self WH_getMD5StringWithStr:newPassword] forKey:@"newPassword"];
    [p go];
}
-(void)WH_resetPwd:(NSString*)telephone areaCode:(NSString *)areaCode randcode:(NSString*)randcode newPwd:(NSString*)newPassword toView:(id)toView{

    if(telephone==nil || newPassword==nil || randcode==nil)
        return;

    WH_JXConnection* p = [self addTask:wh_act_PwdReset param:nil toView:toView];
    [p setPostValue:telephone forKey:@"telephone"];
    [p setPostValue:randcode forKey:@"randcode"];
    [p setPostValue:areaCode forKey:@"areaCode"];
    [p setPostValue:[self WH_getMD5StringWithStr:newPassword] forKey:@"newPassword"];
    [p go];
}

-(void)WH_updatePwd:(NSString*)telephone areaCode:(NSString *)areaCode oldPwd:(NSString*)oldPassword newPwd:(NSString*)newPassword toView:(id)toView{
    if(telephone==nil || newPassword==nil || oldPassword==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_PwdUpdate param:nil toView:toView];
    [p setPostValue:telephone forKey:@"telephone"];
    [p setPostValue:areaCode forKey:@"areaCode"];
    [p setPostValue:[self WH_getMD5StringWithStr:oldPassword] forKey:@"oldPassword"];
    [p setPostValue:[self WH_getMD5StringWithStr:newPassword] forKey:@"newPassword"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

#pragma mark---发送验证码
-(void)WH_sendSMSCodeWithTel:(NSString*)telephone areaCode:(NSString *)areaCode isRegister:(BOOL)isRegister imgCode:(NSString *)imgCode toView:(id)toView{
    if(telephone==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_SendSMS param:nil toView:toView];
    [p setPostValue:telephone forKey:@"telephone"];
    [p setPostValue:areaCode forKey:@"areaCode"];
    NSString *language;
    if ([g_constant.sysLanguage isEqualToString:@"en"]) {
        language = @"en";
    }else{
        language = @"zh";
    }
    [p setPostValue:language forKey:@"language"];
    p.timeout = 30;
    [p setPostValue:[NSNumber numberWithBool:isRegister] forKey:@"isRegister"];
    if(imgCode==nil || imgCode.length <= 0)
        return;
    [p setPostValue:imgCode forKey:@"imgCode"];
    [p setPostValue:@"1" forKey:@"version"];
    [p go];
    
}
#pragma mark---创建公司
- (void)WH_createCompanyWithCompanyName:(NSString *)companyName toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_creatCompany param:nil toView:toView];
    [p setPostValue:companyName forKey:@"companyName"];
    [p setPostValue:g_myself.userId forKey:@"createUserId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---退出公司/解散公司
- (void)WH_quitCompanyWithCompanyId:(NSString *)companyId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_companyQuit param:nil toView:toView];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---自动查找公司
- (void)WH_getAutoSearchCompany:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_getCompany param:nil toView:toView];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---设置管理员
- (void)settingAdministrator:(NSString *)userId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_setManager param:nil toView:toView];
    [p setPostValue:userId forKey:@"managerId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---管理员列表
- (void)WH_getCompanyAdminListWithCompanyId:(NSString *)companyId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_managerList param:nil toView:toView];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


#pragma mark---修改公司名
- (void)WH_updataCompanyNameWithCompanyName:(NSString *)companyName companyId:(NSString *)companyId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_updataCompanyName param:nil toView:toView];
    [p setPostValue:companyName forKey:@"companyName"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}


#pragma mark---更改公司公告
- (void)WH_updataCompanyNoticeWithContent:(NSString *)noticeContent companyId:(NSString *)companyId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_changeNotice param:nil toView:toView];
    [p setPostValue:noticeContent forKey:@"noticeContent"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---查找公司
- (void)WH_seachCompanyWithKeywordId:(NSString *)keyworld toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_seachCompany param:nil toView:toView];
    [p setPostValue:keyworld forKey:@"keyworld"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---删除公司
- (void)WH_deleteCompanyWithCompanyId:(NSString *)companyId userId:(NSString *)userId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_deleteCompany param:nil toView:toView];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---创建部门
- (void)WH_createDepartmentWithCompanyId:(NSString *)companyId parentId:(NSString *)parentId departName:(NSString *)departName createUserId:(NSString *)createUserId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_createDepartment param:nil toView:toView];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:parentId forKey:@"parentId"];
    [p setPostValue:g_myself.userId forKey:@"createUserId"];
    [p setPostValue:departName forKey:@"departName"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---修改部门名
- (void)WH_updataCompanyDepartmentNameWithName:(NSString *)departmentName departmentId:(NSString *)departmentId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_updataDepartmentName param:nil toView:toView];
    [p setPostValue:departmentName forKey:@"dpartmentName"];
    [p setPostValue:departmentId forKey:@"departmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---删除部门
- (void)WH_deleteDepartmentWithId:(NSString *)departmentId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_deleteDepartment param:nil toView:toView];
    [p setPostValue:departmentId forKey:@"departmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---添加员工
- (void)WH_addEmployeeWithIdArr:(NSArray *)userIdArray companyId:(NSString *)companyId departmentId:(NSString *)departmentId roleArray:(NSArray *)roleArray toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_addEmployee param:nil toView:toView];
    [p setPostValue:[userIdArray componentsJoinedByString:@","] forKey:@"userId"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:departmentId forKey:@"departmentId"];
    if (roleArray) {
        [p setPostValue:roleArray forKey:@"roleArray"];
    }
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---删除员工
- (void)WH_deleteEmployeeWithDepartmentId:(NSString *)departmentId userId:(NSString *)userId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_deleteEmployee param:nil toView:toView];
    [p setPostValue:userId forKey:@"userIds"];
    [p setPostValue:departmentId forKey:@"departmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---更改员工部门
- (void)WH_modifyDpartWithUserId:(NSString *)userId companyId:(NSString *)companyId newDepartmentId:(NSString *)newDepartmentId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_modifyDpart param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:newDepartmentId forKey:@"newDepartmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---部门员工列表
- (void)WH_getEmpListWithDepartmentId:(NSString *)departmentId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_empList param:nil toView:toView];
    [p setPostValue:departmentId forKey:@"departmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---更改员工角色
- (void)WH_modifyRoleWithUserId:(NSString *)userId companyId:(NSString *)companyId role:(NSNumber *)role toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_modifyRole param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:role forKey:@"role"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---更改员工职位(头衔)
- (void)WH_modifyPosition:(NSString *)position companyId:(NSString *)companyId userId:(NSString *)userId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_modifyPosition param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:position forKey:@"position"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---公司列表
- (void)WH_companyListPageWithPageIndex:(NSNumber *)pageIndex toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_companyList param:nil toView:toView];
    [p setPostValue:pageIndex forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInt:12] forKey:@"pageSize"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---部门列表
- (void)WH_getDepartmentListPageWithPageIndex:(NSNumber *)pageIndex companyId:(NSString *)companyId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_departmentList param:nil toView:toView];
    [p setPostValue:pageIndex forKey:@"pageIndex"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---员工列表
- (void)employeeListPage:(NSNumber *)pageIndex companyId:(NSString *)companyId departmentId:(NSString *)departmentId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_employeeList param:nil toView:toView];
    [p setPostValue:pageIndex forKey:@"pageIndex"];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:departmentId forKey:@"departmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---获取公司详情
- (void)getCompanyInfo:(NSString *)companyId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_companyInfo param:nil toView:toView];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---员工详情
- (void)getEmployeeInfo:(NSString *)userId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_employeeInfo param:nil toView:toView];
    [p setPostValue:userId forKey:@"employeeId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---部门详情
- (void)getDepartmentInfo:(NSString *)departmentId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_dpartmentInfo param:nil toView:toView];
    [p setPostValue:departmentId forKey:@"departmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
#pragma mark---公司员工数
- (void)getCompanyCount:(NSString *)companyId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_companyNum param:nil toView:toView];
    [p setPostValue:companyId forKey:@"companyId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark---部门员工数
- (void)getDepartmentCount:(NSString *)departmentId toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_dpartmentNum param:nil toView:toView];
    [p setPostValue:departmentId forKey:@"departmentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//获取消息
-(void)WH_getMessageWithMsgId:(NSString*)messageId toView:(id)toView{
    if([messageId length]<=0)
        return;
    WH_JXConnection* p = [self addTask:wh_act_MsgGet param:nil toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//获取生活圈列表
-(void)WH_getMessageWithMsgId:(int)type messageId:(NSString*)messageId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_MsgList param:[NSString stringWithFormat:@"?pageSize=%d",WH_page_size] toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_addMessage:(NSString*)text type:(int)type data:(NSDictionary*)dict flag:(int)flag visible:(int)visible lookArray:(NSArray *)lookArray coor:(CLLocationCoordinate2D)coor location:(NSString *)location remindArray:(NSArray *)remindArray lable:(NSString *)lable isAllowComment:(int)isAllowComment toView:(id)toView{
    if(text==nil)
        return;
    NSMutableArray* array = [NSMutableArray array];
    //1
    NSString * jsonFiles=nil;
    
    NSString * jsonVideos=nil;
    NSString * jsonImages = nil;
    NSString * jsonAudios=nil;
    
    NSArray *imagAr = [dict objectForKey:@"images"];
    if (imagAr.count > 0) {
        [array removeAllObjects];
        for (NSDictionary *dic in imagAr) {
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [array addObject:tempDic];
        }
        
        if([array count]>0){
            [self doCheckUploadResult:array];
            jsonImages = [array mj_JSONString];
            jsonFiles = jsonImages;
        }
    }
    
    //2
    
    NSArray *videosAr = [dict objectForKey:@"videos"];
    if (videosAr.count >0) {
        [array removeAllObjects];
        for (NSDictionary *dic in videosAr) {
            
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [array addObject:tempDic];
        }
        
        if([array count]>0){
            [self doCheckUploadResult:array];
            jsonVideos = [array mj_JSONString];
            jsonFiles = jsonVideos;
        }
    }
    
    //3
    //    array = [dict objectForKey:@"audios"];
    NSArray *audiosAr = [dict objectForKey:@"audios"];
    if (audiosAr.count > 0) {
        [array removeAllObjects];
        
        for (NSDictionary *dic in audiosAr) {
            [array removeAllObjects];
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [array addObject:tempDic];
        }
        
        if([array count]>0){
            [self doCheckUploadResult:array];
            jsonAudios = [array mj_JSONString];
            jsonFiles = jsonAudios;
        }
    }
    
    NSArray *filesAr = [dict objectForKey:@"others"];
    if (filesAr.count > 0) {
        [array removeAllObjects];
        
        for (NSDictionary *dic in filesAr) {
            //        [array removeAllObjects];
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [array addObject:tempDic];
        }
        
        if([array count]>0){
            [self doCheckUploadResult:array];
            jsonFiles = [array mj_JSONString];
        }
    }
    
    array = nil;
    
    WH_JXConnection* p = [self addTask:wh_act_MsgAdd param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:[NSNumber numberWithInt:flag] forKey:@"flag"];
    [p setPostValue:[NSNumber numberWithInt:visible] forKey:@"visible"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"cityId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:text forKey:@"text"];
    if (type == 5) {
        [p setPostValue:jsonFiles forKey:@"files"];
    }else if (type == 6) {
        [p setPostValue:[dict objectForKey:@"sdkUrl"] forKey:@"sdkUrl"];
        [p setPostValue:[dict objectForKey:@"sdkIcon"] forKey:@"sdkIcon"];
        [p setPostValue:[dict objectForKey:@"sdkTitle"] forKey:@"sdkTitle"];
    }
    else {
        [p setPostValue:jsonImages forKey:@"images"];
        [p setPostValue:jsonAudios forKey:@"audios"];
        [p setPostValue:jsonVideos forKey:@"videos"];
    }
    [p setPostValue:myself.model forKey:@"model"];
    [p setPostValue:myself.osVersion forKey:@"osVersion"];
    [p setPostValue:myself.serialNumber forKey:@"serialNumber"];
    [p setPostValue:lable forKey:@"lable"];
    [p setPostValue:[NSNumber numberWithInt:isAllowComment] forKey:@"isAllowComment"];
    
    if (location.length > 0) {
        [p setPostValue:[NSNumber numberWithDouble:coor.latitude] forKey:@"latitude"];
        [p setPostValue:[NSNumber numberWithDouble:coor.longitude] forKey:@"longitude"];
        [p setPostValue:location forKey:@"location"];
    }
    
    if (lookArray.count >0 && (visible == 3 || visible == 4)) {
        NSString * lookStr = [lookArray componentsJoinedByString:@","];
        NSString * arrayTitle = nil;
        switch (visible) {
            case 3:
                arrayTitle = @"userLook";
                break;
            case 4:
                arrayTitle = @"userNotLook";
                break;
                //            case 5:
                //                arrayTitle = @"userRemindLook";
                //                break;
                
            default:
                arrayTitle = @"";
                break;
        }
        [p setPostValue:lookStr forKey:arrayTitle];
    }
    
    if (remindArray.count > 0) {
        [p setPostValue:[remindArray componentsJoinedByString:@","] forKey:@"userRemindLook"];
    }
    
    [p go];
}

//删除消息
-(void)WH_deleteMessageWithMsgId:(NSString*)messageId toView:(id)toView{
    if(messageId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_MsgDel param:nil toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
//获取评论数
-(void)WH_listCommentWithMsgId:(NSString*)messageId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize commentId:(NSString*)commentId  toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_CommentList param:nil toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    if (pageIndex == 0) { // 第一次请求才传该参数
        [p setPostValue:commentId forKey:@"commentId"];
    }
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
//获取点赞数
-(void)WH_listPraiseWithMsgId:(NSString*)messageId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize praiseId:(NSString*)praiseId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_PraiseList param:nil toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    if (pageIndex == 0) { // 第一次请求才传该参数
        [p setPostValue:praiseId forKey:@"praiseId"];
    }
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


//点赞操作
-(void)WH_addPraiseWithMsgId:(NSString*)messageId toView:(id)toView{
    if(messageId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_PraiseAdd param:nil toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//删除点赞操作
-(void)WH_delPraiseWithMsgId:(NSString*)messageId toView:(id)toView{
    if(messageId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_PraiseDel param:nil toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//使用数据添加评论
-(void)WH_addCommentWithData:(WeiboReplyData*)reply toView:(id)toView{
    if(reply.messageId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_CommentAdd param:nil toView:toView];
    [p setPostValue:reply.messageId forKey:@"messageId"];
    [p setPostValue:reply.body forKey:@"body"];
    [p setPostValue:reply.toUserId forKey:@"toUserId"];
    [p setPostValue:reply.toNickName forKey:@"toNickname"];
    [p setPostValue:reply.toBody forKey:@"toBody"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//使用msgId删除评论
-(void)WH_delCommentWithMsgId:(NSString*)messageId commentId:(NSString*)commentId toView:(id)toView{
    if(messageId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_CommentDel param:nil toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:commentId forKey:@"commentId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


-(void)delFriend:(NSString*)toUserId toView:(id)toView{
    if(toUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_FriendDel param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


-(void)WH_listAttentionWithPage:(int)page userId:(NSString*)userId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_AttentionList param:[NSString stringWithFormat:@"?pageIndex=%d&pageSize=%d",page,WH_page_size] toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}



//添加好友请求
-(void)WH_addAttentionWithUserId:(NSString*)toUserId fromAddType:(int)fromAddType toView:(id)toView{
    if(toUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_AttentionAdd param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:@(fromAddType) forKey:@"fromAddType"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_delAttentionWithToUserId:(NSString*)toUserId toView:(id)toView{
    if(toUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_AttentionDel param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_addBlacklistWithToUserId:(NSString*)toUserId toView:(id)toView{
    if(toUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_BlacklistAdd param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_delBlacklistWithToUserId:(NSString*)toUserId toView:(id)toView{
    if(toUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_BlacklistDel param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_listBlacklistWithPage:(int)page toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_BlacklistList param:[NSString stringWithFormat:@"?pageIndex=%d&pageSize=%d",page,WH_page_size] toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_setFriendNameWithToUserId:(NSString*)toUserId noteName:(NSString*)noteName describe:(NSString *)describe toView:(id)toView{
    if(toUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_FriendRemark param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:noteName forKey:@"remarkName"];
    [p setPostValue:describe forKey:@"describe"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

// 修改好友的聊天记录过期时间
-(void)friendsUpdate:(NSString *)toUserId chatRecordTimeOut:(NSString *)chatRecordTimeOut toView:(id)toView {
    if(toUserId==nil)
        return;
    WH_JXConnection* p = [self addTask:wh_act_FriendsUpdate param:nil toView:toView];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:chatRecordTimeOut forKey:@"chatRecordTimeOut"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)getNewMessage:(NSString*)messageId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_MsgListNew param:[NSString stringWithFormat:@"?pageSize=%d",WH_page_size*5] toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//设置是否需要好友验证
-(void)WH_changeFriendSettingWithFriendsVerify:(NSString *)friendsVerify allowAtt:(NSString *)allowAtt allowGreet:(NSString*)allowGreet key:(NSString *)key value:(NSString *)value toView:(id)toView{
    WH_JXConnection * p = [self addTask:wh_act_SettingsUpdate param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:friendsVerify forKey:@"friendsVerify"];
    [p setPostValue:allowAtt forKey:@"allowAtt"];
    [p setPostValue:allowGreet forKey:@"allowGreet"];
    [p setPostValue:value forKey:key];
    [p go];
}
//获取好友验证设置
- (void)WH_getFriendSettingsWithUserId:(NSString *)userID toView:(id)toView{
    WH_JXConnection * p = [self addTask:wh_act_Settings param:nil toView:toView];
    [p setPostValue:userID forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)getUserMessage:(NSString*)userId messageId:(NSString*)messageId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_MsgListUser param:[NSString stringWithFormat:@"?pageSize=%d",WH_page_size*5] toView:toView];
    [p setPostValue:messageId forKey:@"messageId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)getSetting:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_Config param:nil toView:toView];
    NSString *area = [g_default objectForKey:kLocationArea];
    area = [self httpDataStr:area];
    [p setPostValue:area forKey:@"area"];
    [p go];
    
}

//http传输过程的数据转换
- (NSString *)httpDataStr:(NSString *)str {
    
    NSString *outputStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)str,NULL,(CFStringRef)@"!*'();:@&=+$/?%#[] ",kCFStringEncodingUTF8));
    return outputStr;
}

-(long)user_id{
    return [myself.userId intValue];
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
//        [p removeObjectForKey:@"oFileName"];
    }
}

-(void)showLogin{
    // 显示手动登录界面， 隐藏悬浮窗
    g_App.subTopWindow.hidden = YES;
    g_App.isHaveTopWindow = YES;

    [g_default removeObjectForKey:kMY_USER_PASSWORD];
    [g_default removeObjectForKey:kMY_USER_TOKEN];
    [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
//    WH_LoginViewController* vc = [WH_LoginViewController alloc];
//    vc.isAutoLogin = NO;
//    vc.isSwitchUser= NO;
//    vc = [vc init];
//    g_navigation.rootViewController = vc;
    
    WH_LoginViewController *loginVC = [[WH_LoginViewController alloc] init];
//    loginVC.isAutoLogin = YES;
    loginVC.isSwitchUser= NO;
    loginVC.isPushEntering = YES;
    g_navigation.rootViewController = loginVC;
    
    
//    [g_navigation.subViews removeAllObjects];
//    g_mainVC = nil;
//    [g_navigation pushViewController:vc];
//    g_App.window.rootViewController = vc;
//    [g_App.window makeKeyAndVisible];

//    WH_LoginViewController* vc = [WH_LoginViewController alloc];
//    vc.isAutoLogin = NO;
//    vc.isSwitchUser= YES;
//    vc = [vc init];
//    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc];
}

-(void)showWebPage:(NSString*)url title:(NSString*)s{
    WH_webpage_WHVC* webVC = [WH_webpage_WHVC alloc];
    webVC.title = s;
    webVC.isSend = YES;
    webVC.url   = url;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:vc animated:YES];
}


-(void)order:(int)goodId count:(int)count type:(int)rechargeType toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_payBuy param:nil toView:toView];
    [p setPostValue:[NSString stringWithFormat:@"%d",goodId] forKey:@"goodsId"];
    [p setPostValue:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [p setPostValue:[NSString stringWithFormat:@"%d",rechargeType] forKey:@"rechargeType"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)listBizs:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_bizList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)buy:(int)goodId count:(int)count toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_bizBuy param:nil toView:toView];
    [p setPostValue:[NSString stringWithFormat:@"%d",goodId] forKey:@"goodsId"];
    [p setPostValue:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
#pragma mark----新用户
- (void)WH_nearbyNewUserWithData:(WH_SearchData*)search nearOnly:(BOOL)bNearOnly page:(int)page toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_nearNewUser param:[NSString stringWithFormat:@"?pageSize=%d&pageIndex=%d",WH_page_size,page] toView:toView];
    [p setPostValue:[NSNumber numberWithInt:search.minAge] forKey:@"minAge"];
    [p setPostValue:[NSNumber numberWithInt:search.maxAge] forKey:@"maxAge"];
    if(search.sex != -1)
        [p setPostValue:[NSNumber numberWithInt:search.sex] forKey:@"sex"];
    if(bNearOnly){
        [p setPostValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
        [p setPostValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    }
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}

-(void)nearbyUser:(WH_SearchData*)search nearOnly:(BOOL)bNearOnly lat:(double)lat lng:(double)lng page:(int)page toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_nearbyUser param:[NSString stringWithFormat:@"?pageSize=%d&pageIndex=%d",12,page] toView:toView];
    if (search) {
        [p setPostValue:search.name forKey:@"nickname"];
//        [p setPostValue:[NSNumber numberWithInt:search.minAge] forKey:@"minAge"];
//        [p setPostValue:[NSNumber numberWithInt:search.maxAge] forKey:@"maxAge"];
        if(search.sex != -1)
            [p setPostValue:[NSNumber numberWithInt:search.sex] forKey:@"sex"];
    }
    
    if(bNearOnly && (lat != 0) &&(lng != 0)){
        [p setPostValue:[NSNumber numberWithDouble:lng] forKey:@"longitude"];
        [p setPostValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
    }else if (bNearOnly){
        [p setPostValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
        [p setPostValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    }
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}

-(void)addRoom:(WH_RoomData*)room isPublic:(BOOL)isPublic isNeedVerify:(BOOL)isNeedVerify category:(NSInteger)category toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomAdd param:nil toView:toView];
    [p setPostValue:room.roomJid forKey:@"jid"];
    [p setPostValue:room.name forKey:@"name"];
    [p setPostValue:room.desc forKey:@"desc"];
    [p setPostValue:[NSNumber numberWithInt:(isPublic ? 1:0)] forKey:@"isLook"];
    [p setPostValue:[NSNumber numberWithInt:(isNeedVerify ? 1:0)] forKey:@"isNeedVerify"];
    [p setPostValue:[NSNumber numberWithInt:(room.showMember ? 1:0)] forKey:@"showMember"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowSendCard ? 1:0)] forKey:@"allowSendCard"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowInviteFriend ? 1:0)] forKey:@"allowInviteFriend"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowUploadFile ? 1:0)] forKey:@"allowUploadFile"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowConference ? 1:0)] forKey:@"allowConference"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowSpeakCourse ? 1:0)] forKey:@"allowSpeakCourse"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowHostUpdate ? 1:0)] forKey:@"allowHostUpdate"];
    if (room.showRead) {
        [p setPostValue:[NSNumber numberWithInt:1] forKey:@"showRead"];
    }else{
        [p setPostValue:[NSNumber numberWithInt:0] forKey:@"showRead"];
    }
    [p setPostValue:[NSNumber numberWithInt:room.countryId] forKey:@"countryId"];
    [p setPostValue:[NSNumber numberWithInt:room.provinceId] forKey:@"provinceId"];
    [p setPostValue:[NSNumber numberWithInt:room.cityId] forKey:@"cityId"];
    [p setPostValue:[NSNumber numberWithInt:room.areaId] forKey:@"areaId"];
    [p setPostValue:[NSNumber numberWithDouble:room.longitude] forKey:@"longitude"];
    [p setPostValue:[NSNumber numberWithDouble:room.latitude] forKey:@"latitude"];
    [p setPostValue:[NSNumber numberWithInteger:category] forKey:@"category"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)addRoom:(WH_RoomData*)room userArray:(NSArray*)array isPublic:(BOOL)isPublic isNeedVerify:(BOOL)isNeedVerify category:(NSInteger)category toView:(id)toView {
    NSString * text;
    if([array count]<=0)
        return;
    
    text = [array mj_JSONString];
    
    WH_JXConnection* p = [self addTask:wh_act_roomAdd param:nil toView:toView];
    [p setPostValue:room.roomJid forKey:@"jid"];
    [p setPostValue:room.name forKey:@"name"];
    [p setPostValue:room.desc forKey:@"desc"];
    [p setPostValue:[NSNumber numberWithInt:(isPublic ? 1:0)] forKey:@"isLook"];
    [p setPostValue:[NSNumber numberWithInt:(isNeedVerify ? 1:0)] forKey:@"isNeedVerify"];
    [p setPostValue:[NSNumber numberWithInt:(room.showMember ? 1:0)] forKey:@"showMember"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowSendCard ? 1:0)] forKey:@"allowSendCard"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowInviteFriend ? 1:0)] forKey:@"allowInviteFriend"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowUploadFile ? 1:0)] forKey:@"allowUploadFile"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowConference ? 1:0)] forKey:@"allowConference"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowSpeakCourse ? 1:0)] forKey:@"allowSpeakCourse"];
    [p setPostValue:[NSNumber numberWithInt:(room.allowHostUpdate ? 1:0)] forKey:@"allowHostUpdate"];
    if (room.showRead) {
        [p setPostValue:[NSNumber numberWithInt:1] forKey:@"showRead"];
    }else{
        [p setPostValue:[NSNumber numberWithInt:0] forKey:@"showRead"];
    }
    [p setPostValue:[NSNumber numberWithInt:room.countryId] forKey:@"countryId"];
    [p setPostValue:[NSNumber numberWithInt:room.provinceId] forKey:@"provinceId"];
    [p setPostValue:[NSNumber numberWithInt:room.cityId] forKey:@"cityId"];
    [p setPostValue:[NSNumber numberWithInt:room.areaId] forKey:@"areaId"];
    [p setPostValue:[NSNumber numberWithDouble:room.longitude] forKey:@"longitude"];
    [p setPostValue:[NSNumber numberWithDouble:room.latitude] forKey:@"latitude"];
    [p setPostValue:[NSNumber numberWithInteger:category] forKey:@"category"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:text forKey:@"text"];
    [p go];
}

-(void)delRoom:(NSString*)roomId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomDel param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)getRoom:(NSString*)roomId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomGet param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithInt:kRoomMemberListNum] forKey:@"pageSize"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)updateRoom:(WH_RoomData*)room toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomSet param:nil toView:toView];
    [p setPostValue:room.roomId forKey:@"roomId"];
    [p setPostValue:room.name forKey:@"roomName"];
    [p setPostValue:room.chatRecordTimeOut forKey:@"chatRecordTimeOut"];
    [p setPostValue:[NSNumber numberWithLong:room.talkTime] forKey:@"talkTime"];
    [p setPostValue:[NSNumber numberWithInt:room.maxCount] forKey:@"maxUserSize"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_updateRoomMaxUserSizeWithRoom:(WH_RoomData*)room toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomSet param:nil toView:toView];
    [p setPostValue:room.roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithInt:room.maxCount] forKey:@"maxUserSize"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

- (void)updateRoom:(WH_RoomData *)room key:(NSString *)key value:(NSString *)value toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_roomSet param:nil toView:toView];
    [p setPostValue:room.roomId forKey:@"roomId"];
    [p setPostValue:access_token forKey:@"access_token"];
    if (value) {
        [p setPostValue:value forKey:key];
    }
    
    [p go];
}

-(void)updateRoomShowRead:(WH_RoomData*)room key:(NSString *)key value:(BOOL)value toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomSet param:nil toView:toView];
    [p setPostValue:room.roomId forKey:@"roomId"];
    if (value) {
        [p setPostValue:[NSNumber numberWithInt:1] forKey:key];
    }else {
        [p setPostValue:[NSNumber numberWithInt:0] forKey:key];
    }
    
//
//    if (room.showRead)
//        [p setPostValue:[NSNumber numberWithInt:1] forKey:@"showRead"];
//    else
//        [p setPostValue:[NSNumber numberWithInt:0] forKey:@"showRead"];
//
//
//    [p setPostValue:[NSNumber numberWithInt:room.isLook ? 1 : 0] forKey:@"isLook"];
//    [p setPostValue:[NSNumber numberWithInt:room.isNeedVerify ? 1 : 0] forKey:@"isNeedVerify"];
//    [p setPostValue:[NSNumber numberWithInt:room.showMember ? 1 : 0] forKey:@"showMember"];
//    [p setPostValue:[NSNumber numberWithInt:room.allowSendCard ? 1 : 0] forKey:@"allowSendCard"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_updateRoomDescWithRoom:(WH_RoomData*)room toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomSet param:nil toView:toView];
    [p setPostValue:room.roomId forKey:@"roomId"];
    [p setPostValue:room.desc forKey:@"desc"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_updateRoomNotifyWithRoom:(WH_RoomData*)room toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomSet param:nil toView:toView];
    [p setPostValue:room.roomId forKey:@"roomId"];
    [p setPostValue:room.note forKey:@"notice"];
    [p setPostValue:[NSString stringWithFormat:@"%d",room.allowForceNotice] forKey:@"allowForceNotice"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)listRoom:(int)page roomName:(NSString *)roomName toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomList param:[NSString stringWithFormat:@"?pageIndex=%d",page] toView:toView];
    [p setPostValue:roomName forKey:@"roomName"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_listHisRoomWithPage:(int)page pageSize:(int)pageSize toView:(id)toView{
    
    //    WH_JXConnection* p = [self addTask:wh_act_roomListHis param:[NSString stringWithFormat:@"?pageSize=%d&pageIndex=%d",WH_page_size,page] toView:toView];
    WH_JXConnection* p = [self addTask:wh_act_roomListHis param:[NSString stringWithFormat:@"?pageSize=%d&pageIndex=%d",pageSize,page] toView:toView];
    [p setPostValue:[NSNumber numberWithInt:0] forKey:@"type"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


-(void)WH_getRoomMemberWithRoomId:(NSString*)roomId userId:(long)userId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomMemberGet param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithLong:userId] forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_delRoomMemberWithRoomId:(NSString*)roomId userId:(long)userId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomMemberDel param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithLong:userId] forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_setRoomMemberWithRoomId:(NSString*)roomId member:(memberData*)member toView:(id)toView{
    if(!member)
        return;
    WH_JXConnection* p = [self addTask:wh_act_roomMemberSet param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithLong:member.userId] forKey:@"userId"];
    //    [p setPostValue:[NSNumber numberWithInt:member.role] forKey:@"role"];
    //    [p setPostValue:[NSNumber numberWithInt:member.sub] forKey:@"sub"];
    if (member.lordRemarkName.length > 0) {
        [p setPostValue:member.lordRemarkName forKey:@"remarkName"];
    }else {
        [p setPostValue:member.userNickName forKey:@"nickname"];
    }
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_setDisableSayWithRoomId:(NSString*)roomId member:(memberData*)member  toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomMemberSet param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithLongLong:member.talkTime] forKey:@"talkTime"];
    [p setPostValue:[NSNumber numberWithLong:member.userId] forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_setRoomAdminWithRoomId:(NSString*)roomId userId:(NSString*)userId type:(int)type  toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomSetAdmin param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"touserId"];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
// 指定监控人、隐身人
-(void)WH_setRoomInvisibleGuardianWithRoomId:(NSString*)roomId userId:(NSString*)userId type:(int)type toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomSetInvisibleGuardian param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"touserId"];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

// 转让群主
- (void)WH_roomTransferWithRoomId:(NSString *)roomId toUserId:(NSString *)toUserId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_roomTransfer param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_addRoomMemberWithRoomId:(NSString*)roomId userId:(NSString*)userId nickName:(NSString*)nickName toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_roomMemberSet param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:nickName forKey:@"nickname"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

-(void)WH_addRoomMemberWithRoomId:(NSString*)roomId userArray:(NSArray*)array toView:(id)toView{
    NSString * text;
    if([array count]<=0)
        return;

    text = [array mj_JSONString];

    WH_JXConnection* p = [self addTask:wh_act_roomMemberSet param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:text forKey:@"text"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

/**添加共享文件*/
-(void)WH_roomShareAddRoomId:(NSString *)roomId url:(NSString *)fileUrl fileName:(NSString *)fileName size:(NSNumber *)size type:(NSInteger)type toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_shareAdd param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:fileUrl forKey:@"url"];
    [p setPostValue:fileName forKey:@"name"];
    [p setPostValue:size forKey:@"size"];
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
/**获取文件列表*/
-(void)WH_roomShareListRoomIdWithRoomId:(NSString *)roomId userId:(NSString *)userId pageSize:(int)pageSize pageIndex:(int)pageIndex toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_shareList param:[NSString stringWithFormat:@"?pageSize=%d&pageIndex=%d",WH_page_size,pageIndex] toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    if (userId.length > 0) {
        [p setPostValue:g_myself.userId forKey:@"userId"];
    }
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

/**删除文件*/
-(void)WH_roomShareDeleteRoomIdWithRoomId:(NSString *)roomId shareId:(NSString *)shareId toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_shareDelete param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:shareId forKey:@"shareId"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


// 群成员分页获取
- (void)WH_roomMemberGetMemberListByPageWithRoomId:(NSString *)roomId joinTime:(long)joinTime toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_roomMemberGetMemberListByPage param:nil toView:toView];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:[NSNumber numberWithLong:joinTime] forKey:@"joinTime"];
    [p setPostValue:[NSNumber numberWithInt:kRoomMemberListNum] forKey:@"pageSize"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


-(void)setPushChannelId:(NSString*)channelId{
    if(channelId==nil)
        return;
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    WH_JXConnection* p = [self addTask:wh_act_setPushChannelId param:nil toView:nil];
    [p setPostValue:@"2" forKey:@"deviceId"];
    [p setPostValue:channelId forKey:@"channelId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:identifier forKey:@"appId"];
    [p go];
}

//简历接口：
-(void)updateResume:(NSString*)resumeId nodeName:(NSString*)nodeName text:(NSString*)text toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_resumeUpdate param:nil toView:toView];
    [p setPostValue:resumeId forKey:@"resumeId"];
    [p setPostValue:nodeName forKey:@"nodeName"];
    [p setPostValue:text forKey:@"text"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

- (void)locate {
    
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        //        _location = [[CLLocationManager alloc] init] ;
        //        _location.delegate = self;
        //        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        ////            [_location requestAlwaysAuthorization];//始终允许访问位置信息,必须关闭
        //            [_location requestWhenInUseAuthorization];//使用应用程序期间允许访问位置数据
        //        }
        
        
        [self.location locationStart];
        
    }else {
    }
    
    // 没开启定位
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        [self.location getLocationWithIp];
    }
}

#pragma mark JXLocationDelegate
//- (void)location:(JXLocation *)location CountryCode:(NSString *)countryCode CityName:(NSString *)cityName CityId:(NSString *)cityId Address:(NSString *)address Latitude:(double)lat Longitude:(double)lon{
//    self.countryCode = countryCode;
//    self.cityName = cityName;
//    self.cityId = [cityId intValue];
//    self.address = address;
//    self.latitude = lat;
//    self.longitude = lon;
//    
//    if (isLogin || _isGetSetting) {
//        //[self getSetting:self];//根据城市不同返回不同配置
//    }
//}


-(double)WH_getLocationWithLatitude:(double)latitude1 longitude:(double)longitude1{
    if (latitude1 == 0 || longitude1 == 0) {
        return 0;
    }
    CLLocation * hisLocation=[[CLLocation alloc] initWithLatitude:latitude1 longitude:longitude1];//在手机上测试
    CLLocation *myLocation=[[CLLocation alloc] initWithLatitude:latitude longitude:longitude];//在simulator上测试，成功获得位置:22.602976,114.052067
    double n = [myLocation distanceFromLocation:hisLocation];//[myLocation getDistanceFrom:hisLocation];
    //    [hisLocation release];
    //    [myLocation release];
    return n;
}

//  获取首页的最近一条的聊天记录列表
- (void)WH_getLastChatListWithStartTime:(NSNumber *)startTime toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_tigaseGetLastChatList param:nil toView:toView];
    [p setPostValue:startTime forKey:@"startTime"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

// 获取单聊漫游聊天记录
- (void)WH_tigaseMsgsWithReceiver:(NSString *)receiver StartTime:(long)startTime EndTime:(long)endTime PageIndex:(int)pageIndex toView:(id)toView; {
    WH_JXConnection* p = [self addTask:wh_act_tigaseMsgs param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInt:10000] forKey:@"pageSize"];
    [p setPostValue:[NSNumber numberWithLong:startTime] forKey:@"startTime"];
    [p setPostValue:[NSNumber numberWithLong:endTime] forKey:@"endTime"];
    [p setPostValue:receiver forKey:@"receiver"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

// 获取群聊漫游聊天记录
- (void)WH_tigaseMucMsgsWithRoomId:(NSString *)roomId StartTime:(long)startTime EndTime:(long)endTime PageIndex:(int)pageIndex PageSize:(int)pageSize toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_tigaseMucMsgs param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
    [p setPostValue:[NSNumber numberWithLong:startTime] forKey:@"startTime"];
    [p setPostValue:[NSNumber numberWithLong:endTime] forKey:@"endTime"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

// 公众号菜单
- (void)WH_getPublicMenuListWithUserId:(NSString *)userId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_publicMenuList param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//双向撤回
- (void)wh_twoWayDelectRoomMsg:(NSString *)userId roomId:(NSString *)roomId toView:(id)toView {
    WH_JXConnection* p = [self addTask:act_delectRoomMsg param:nil toView:toView];
//    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

// 删除&撤回聊天记录
- (void)WH_tigaseDeleteMsgWithMsgId:(NSString *)msgId type:(int)type deleteType:(int)deleteType roomJid:(NSString *)roomJid toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_tigaseDeleteMsg param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:msgId forKey:@"messageId"];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:[NSNumber numberWithInt:deleteType] forKey:@"delete"];
    if (roomJid) {
        [p setPostValue:roomJid forKey:@"roomJid"];
    }
    [p go];
}

// 通用接口请求，只是单纯的请求接口，不做其他操作
- (void)requestWithUrl:(NSString *)url toView:(id)toView {
    WH_JXConnection* p = [self addTask:url param:nil toView:toView];
    [p go];
}
// 消息免打扰
- (void)WH_friendsUpdateOfflineNoPushMsgUserId:(NSString *)userId toUserId:(NSString *)toUserId offlineNoPushMsg:(int)offlineNoPushMsg toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_FriendsUpdateOfflineNoPushMsg param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:[NSNumber numberWithInt:offlineNoPushMsg] forKey:@"offlineNoPushMsg"];
    [p go];
}

-(void)pkpushSetToken:(NSString *)token deviceId:(NSString *)deviceId isVoip:(int)isVoip toView:(id)toView{
    
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    WH_JXConnection* p = [self addTask:wh_act_PKPushSetToken param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:token forKey:@"token"];
    [p setPostValue:@"2" forKey:@"deviceId"];
    [p setPostValue:[NSNumber numberWithInt:isVoip] forKey:@"isVoip"];
    [p setPostValue:identifier forKey:@"appId"];
    [p go];
}

//我的下载表情列表

#pragma mark - 自定义表情相关
//表情商店
- (void)getEmjioStoreListWithPageIndex:(int)pageIndex toView:(id)toView
{
    WH_JXConnection* p = [self addTask:wh_act_emojiStoreList param:nil toView:toView];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInt:20] forKey:@"pageSize"];
    [p go];
}
//我的下载表情列表
- (void)getMyEmjioListWithPageIndex:(int)pageIndex toView:(id)toView
{
    WH_JXConnection* p = [self addTask:wh_act_emojiMyDownListPage param:nil toView:toView];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInt:20] forKey:@"pageSize"];
    [p go];
}

//移除我的下载表情
- (void)deleteMyEmjioListWithCustomEmoId:(NSString *)customEmoId toView:(id)toView
{
    WH_JXConnection* p = [self addTask:wh_act_emojiUserListDelete param:nil toView:toView];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p setPostValue:customEmoId forKey:@"customEmoId"];
    [p go];
}

//添加我的下载表情
- (void)AddEmjioListToMineWithCustomEmoId:(NSString *)customEmoId toView:(id)toView
{
    WH_JXConnection* p = [self addTask:wh_act_emojiUserListAdd param:nil toView:toView];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p setPostValue:customEmoId forKey:@"customEmoId"];
    [p go];
}

//添加收藏
-(void)WH_addFavoriteWithEmoji:(NSMutableArray *)emoji toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_userEmojiAdd param:nil toView:toView];
//    NSMutableArray *emoji = [[NSMutableArray alloc] init];
//    NSDictionary *dict = [[NSDictionary alloc] init];
//    if ([type length] > 0)
//        [dict setValue:type forKey:@"type"];
//
//    if ([type intValue] == 6) {
//        [dict setValue:url forKey:@"url"];
//    }else {
//        [dict setValue:msgId forKey:@"msgId"];
//        if (roomJid) {
//            [dict setValue:roomJid forKey:@"roomJid"];
//        }
//    }
//    [emoji addObject:dict];
   
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:[emoji mj_JSONString] forKey:@"emoji"];

    [p go];
}

////添加收藏
//-(void)addFavoriteWithContent:(NSString *)contentStr type:(int)type toView:(id)toView{
//    WH_JXConnection* p = [self addTask:wh_act_userEmojiAdd param:nil toView:toView];
//    [p setPostValue:access_token forKey:@"access_token"];
//    [p setPostValue:contentStr forKey:@"url"];
//    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
//    [p go];
//}

// 收藏表情
//- (void)userEmojiAddWithUrl:(NSString *)url toView:(id)toView {
//    WH_JXConnection* p = [self addTask:wh_act_userEmojiAdd param:nil toView:toView];
//    [p setPostValue:access_token forKey:@"access_token"];
//    [p setPostValue:url forKey:@"url"];
//    [p go];
//}

// 取消收藏
- (void)WH_userEmojiDeleteWithId:(NSString *)emojiId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userEmojiDelete param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:emojiId forKey:@"emojiId"];
    [p go];
}

// 朋友圈里面取消收藏
- (void)WH_userPengYouQunEmojiDeleteWithId:(NSString *)messageId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_ShengHuoQuanDeleteCollect param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:messageId forKey:@"messageId"];
    [p go];
}


// 收藏列表
-(void)WH_userCollectionListWithType:(int)type pageIndex:(int)pageIndex toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_userCollectionList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    if (type > 0)
        [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInteger:1000] forKey:@"pageSize"];
    [p go];
}
//收藏的表情列表
- (void)WH_userEmojiListWithPageIndex:(int)pageIndex toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userEmojiList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInteger:1000] forKey:@"pageSize"];
    [p go];
}

// 添加课程
- (void)WH_userCourseAddWithMessageIds:(NSString *)messageIds CourseName:(NSString *)courseName RoomJid:(NSString *)roomJid toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userCourseAdd param:nil toView:toView];
    if (roomJid.length > 0) {
        [p setPostValue:roomJid forKey:@"roomJid"];
    }
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p setPostValue:messageIds forKey:@"messageIds"];
    [p setPostValue:courseName forKey:@"courseName"];
    long long time = [[NSDate date] timeIntervalSince1970];
    [p setPostValue:[NSString stringWithFormat:@"%lld",time] forKey:@"createTime"];
    [p go];
}
// 查询课程
- (void)WH_userCourseList:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userCourseList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:g_myself.userId forKey:@"userId"];
    [p go];
}
// 修改课程
- (void)WH_userCourseUpdateWithCourseId:(NSString *)courseId MessageIds:(NSString *)messageIds CourseName:(NSString *)courseName CourseMessageId:(NSString *)courseMessageId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userCourseUpdate param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    if (courseId.length > 0) {
        [p setPostValue:courseId forKey:@"courseId"];
    }
    if (messageIds.length > 0) {
        [p setPostValue:messageIds forKey:@"messageIds"];
    }
    if (courseName.length > 0) {
        [p setPostValue:courseName forKey:@"courseName"];
    }
    if (courseMessageId.length > 0) {
        [p setPostValue:courseMessageId forKey:@"courseMessageId"];
    }
    
    long long time = [[NSDate date] timeIntervalSince1970];
    [p setPostValue:[NSString stringWithFormat:@"%lld",time] forKey:@"updateTime"];
    [p go];
}
// 删除课程
- (void)WH_userCourseDeleteWithCourseId:(NSString *)courseId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userCourseDelete param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:courseId forKey:@"courseId"];
    [p go];
}
// 课程详情
- (void)WH_userCourseGetWithCourseId:(NSString *)courseId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userCourseGet param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:courseId forKey:@"courseId"];
    [p go];
}

// 更新角标
- (void)WH_userChangeMsgNum:(NSInteger)num toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_userChangeMsgNum param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInteger:num] forKey:@"num"];
    [p go];
}

// 设置群消息免打扰
- (void)WH_roomMemberSetOfflineNoPushMsgWithRoomId:(NSString *)roomId userId:(NSString *)userId offlineNoPushMsg:(int)offlineNoPushMsg toView:(id)toView{
    
    WH_JXConnection* p = [self addTask:wh_act_roomMemberSetOfflineNoPushMsg param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:[NSNumber numberWithInt:offlineNoPushMsg] forKey:@"offlineNoPushMsg"];
    [p go];
}

// 添加标签
- (void)WH_friendGroupAdd:(NSString *)groupName toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_FriendGroupAdd param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:groupName forKey:@"groupName"];
    [p go];
}

// 修改好友标签
- (void)WH_friendGroupUpdateGroupUserListWithGroupId:(NSString *)groupId userIdListStr:(NSString *)userIdListStr toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_FriendGroupUpdateGroupUserList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:groupId forKey:@"groupId"];
    [p setPostValue:userIdListStr forKey:@"userIdListStr"];
    [p go];
}

// 更新标签名
- (void)WH_friendGroupUpdateWithGroupId:(NSString *)groupId groupName:(NSString *)groupName toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_FriendGroupUpdate param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:groupId forKey:@"groupId"];
    [p setPostValue:groupName forKey:@"groupName"];
    [p go];
}

// 删除标签
- (void)WH_friendGroupDeleteWithGroupId:(NSString *)groupId toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_FriendGroupDelete param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:groupId forKey:@"groupId"];
    [p go];
}

// 标签列表
- (void)WH_friendGroupListToView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_FriendGroupList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

// 修改好友的分组列表
- (void)WH_friendGroupUpdateFriendToUserId:(NSString *)toUserId groupIdStr:(NSString *)groupIdStr toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_FriendGroupUpdateFriend param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:groupIdStr forKey:@"groupIdStr"];
    [p go];
}

// 删除群组公告
- (void)WH_roomDeleteNoticeWithRoomId:(NSString *)roomId noticeId:(NSString *)noticeId ToView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_roomDeleteNotice param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:noticeId forKey:@"noticeId"];
    [p go];
}

// 拷贝文件
- (void)WH_uploadCopyFileServletWithPaths:(NSString *)paths validTime:(NSString *)validTime toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_UploadCopyFileServlet param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:validTime forKey:@"validTime"];
    [p setPostValue:paths forKey:@"paths"];
    [p go];
}

// 清空聊天记录
- (void)WH_emptyMsgWithTouserId:(NSString *)toUserId type:(NSNumber *)type toView:(id)toView {
    //Type 3 群组 1 全部 0 单聊
    WH_JXConnection* p = [self addTask:wh_act_EmptyMsg param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p setPostValue:type forKey:@"type"];
    [p go];
}

//清空群组聊天记录
- (void)WH_ClearGroupChatHistoryWithRoomId:(NSString *)roomId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_EmptyMsg param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:@"3" forKey:@"type"];
    [p go];
}

// 获取通讯录所有号码
- (void)WH_getUserAllAddressBook:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_AddressBookGetAll param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
// 上传通讯录
- (void)WH_uploadAddressBookWithUploadStr:(NSString *)uploadStr toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_AddressBookUpload param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:uploadStr forKey:@"uploadJsonStr"];
    [p go];
}
// 添加手机联系人好友
- (void)WH_friendsAttentionBatchAddToUserIds:(NSString *)toUserIds toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_FriendsAttentionBatchAdd param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:toUserIds forKey:@"toUserIds"];
    [p go];
}


// 用户绑定微信code，获取openid
- (void)WH_userBindWXCodeWithCode:(NSString *)code toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_UserBindWXCode param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:code forKey:@"code"];
    [p go];
}

/**
 * 余额微信提现
 * amout -- 提现金额，0.3=30，单位为分，最少0.5
 * secret -- 提现秘钥
 * time -- 请求时间，服务器检查，允许5分钟时差
 */
- (void)WH_transferWXPayWithAmount:(NSString *)amount secret:(NSString *)secret time:(NSNumber *)time toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_TransferWXPay param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:amount forKey:@"amount"];
    [p setPostValue:secret forKey:@"secret"];
    [p setPostValue:time forKey:@"time"];
    [p go];
}

// 检查支付密码是否正确
- (void)WH_checkPayPasswordWithUser:(WH_JXUserObject *)user toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_CheckPayPassword param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[self WH_getMD5StringWithStr:user.payPassword] forKey:@"payPassword"];
    [p go];
}


// 更新支付密码
- (void)WH_updatePayPasswordWithUser:(WH_JXUserObject *)user toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_UpdatePayPassword param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[self WH_getMD5StringWithStr:user.payPassword] forKey:@"payPassword"];
    [p setPostValue:user.oldPayPassword ? [self WH_getMD5StringWithStr:user.oldPayPassword] : @"" forKey:@"oldPayPassword"];
    [p go];
}

// 获取集群音视频服务地址
- (void)WH_userOpenMeetWithToUserId:(NSString *)toUserId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_UserOpenMeet param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    NSString *area = [g_default objectForKey:kLocationArea];
    [p setPostValue:area forKey:@"area"];
    [p setPostValue:toUserId forKey:@"toUserId"];
    [p go];
}

// 获取群组信息
- (void)WH_roomGetRoom:(NSString *)roomId toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_roomGetRoom param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p go];
}

// 朋友圈纯视频接口
- (void)WH_circleMsgPureVideoPageIndex:(NSInteger)pageIndex lable:(NSString *)lable toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_CircleMsgPureVideo param:nil toView:toView];

    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:lable forKey:@"lable"];
    [p setPostValue:[NSNumber numberWithInteger:20] forKey:@"pageSize"];
    [p go];
}

// 获取音乐列表
- (void)WH_musicListPageIndex:(NSInteger)pageIndex keyword:(NSString *)keyword toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_MusicList param:nil toView:toView];
    
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [p setPostValue:[NSNumber numberWithInteger:20] forKey:@"pageSize"];
    [p setPostValue:keyword forKey:@"keyword"];
    [p go];
}

// 第三方认证
- (void)WH_openOpenAuthInterfaceWithUserId:(NSString *)userId appId:(NSString *)appId appSecret:(NSString *)appSecret type:(NSInteger)type toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_OpenAuthInterface param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:appId forKey:@"appId"];
    [p setPostValue:appSecret forKey:@"appSecret"];
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    
    long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    
    NSString *str1 = [g_server WH_getMD5StringWithStr:appSecret];
    
    NSMutableString *str2 = [NSMutableString string];
    [str2 appendString:self.access_token];
    [str2 appendString:[NSString stringWithFormat:@"%ld",time]];
    str2 = [[g_server WH_getMD5StringWithStr:str2] mutableCopy];
    
    NSMutableString *str3 = [NSMutableString string];
    [str3 appendString:APIKEY];
    [str3 appendString:appId];
    [str3 appendString:userId];
    [str3 appendString:str2];
    [str3 appendString:str1];
    str3 = [[g_server WH_getMD5StringWithStr:str3] mutableCopy];
    
    [p setPostValue:str3 forKey:@"secret"];
    
    [p go];
}


// 获取微信登录openid
- (void)WH_getWxOpenId:(NSString *)code toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_GetWxOpenId param:nil toView:toView];
    [p setPostValue:code forKey:@"code"];
    [p go];
}

- (void)WH_wxSdkLogin:(WH_JXUserObject *)user type:(NSInteger)type openId:(NSString *)openId toView:(id)toView {
    WH_JXConnection* p = [self addTask:act_sdkLogin param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [p setPostValue:openId forKey:@"loginInfo"];
    [p setPostValue:user forKey:@"UserExample"];
    [p go];
}

//第三方登录接口 test
- (void)WH_otherLogin:(WH_JXUserObject *)user type:(NSInteger)type openId:(NSString *)openId toView:(id)toView token:(NSString *)token{
//    1: QQ  2: 微信
    WH_JXConnection* p = [self addTask:act_otherLogin param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"otherType"];
    

    if (type == 1) {//QQ
        [p setPostValue:openId forKey:@"code"];
        [p setPostValue:token forKey:@"otherToken"];
    }else if (type == 2) { //微信
        [p setPostValue:openId forKey:@"code"];
    }
    
    if (!user.model) {
        //手机型号
        user.model = [self deviceVersion];
    }
    
    if (!user.osVersion) {
        //系统版本号
        NSString * iponeM = [[UIDevice currentDevice] systemVersion];
        user.osVersion = iponeM;
    }
    
    
//    [p setPostValue:@"client_credentials" forKey:@"grant_type"];
//    [p setPostValue:user.model forKey:@"model"];
    [p setPostValue:user.osVersion forKey:@"osVersion"];
    [p setPostValue:g_macAddress forKey:@"serial"];
    [p setPostValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [p setPostValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [p setPostValue:user.location forKey:@"location"];
    [p setPostValue:[NSNumber numberWithInt:1] forKey:@"xmppVersion"];
    [p setPostValue:@"iOS" forKey:@"appBrand"];
    // 是否开启集群
    if ([g_config.isOpenCluster integerValue] == 1) {
        NSString *area = [g_default objectForKey:kLocationArea];
        [p setPostValue:area forKey:@"area"];
    }
    
    long time = (long)[[NSDate date] timeIntervalSince1970];
    [p setPostValue:[self getSecretWithText:APIKEY time:time] forKey:@"secret"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p setPostValue:access_token forKey:@"access_token"];
    
    [p go];
}

- (NSString *)getSecretWithText:(NSString *)text time:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
//    [str1 appendString:g_myself.userId];
//    [str1 appendString:g_server.access_token];
//    NSMutableString *str2 = [NSMutableString string];
//    str2 = [[g_server WH_getMD5StringWithStr:text] mutableCopy];
//    [str1 appendString:str2];
//    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    return [str1 copy];
    
}
- (void)WH_bindPhonePassWord:(NSString *)phone pws:(NSString *)pws areaCode:(NSString *)areaCode smsCode:(NSString *)smsCode loginType:(NSString *)loginType toView:(id)toView
{
    WH_JXConnection* p = [self addTask:act_otherBindPhonePassWord param:nil toView:toView];
    
    [p setPostValue:phone forKey:@"telePhone"];
    [p setPostValue:areaCode forKey:@"areaCode"];
    [p setPostValue:pws forKey:@"passWord"];
    [p setPostValue:pws forKey:@"confirmPassWord"];
    [p setPostValue:smsCode forKey:@"smsCode"];
    [p setPostValue:loginType forKey:@"loginType"];
    long time = (long)[[NSDate date] timeIntervalSince1970];
    [p setPostValue:[self getSecretWithText:APIKEY time:time] forKey:@"secret"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    
    [p go];
}

// 第三方登录设置邀请码（新版）
- (void)WH_otherSetInviteCode:(NSString *)inviteCode access_token:(NSString *)access_token userId:(NSString *)userId toView:(id)toView
{
    WH_JXConnection* p = [self addTask:act_otherSetInviteCode param:nil toView:toView];
    if (!IsStringNull(inviteCode)) {
        [p setPostValue:inviteCode forKey:@"inviteCode"];
    }
    long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    [p setPostValue:[self getSecretWithTime:[NSString stringWithFormat:@"%ld",(long)time] userId:userId access_token:access_token] forKey:@"secret"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p setPostValue:access_token forKey:@"access_token"];
    
    [p go];
}

- (NSString *)getSecretWithTime:(NSString *)time userId:(NSString *)userId access_token:(NSString *)access_token
{
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:time];
    
    [str1 appendString:userId];
    [str1 appendString:access_token];
    
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    return [str1 copy];
    
}

#pragma mark - 第三方登录
//绑定第三方账号
- (void)WH_otherBindUserInfoWithOpenId:(NSString *)openId otherToken:(NSString *)otherToken otherType:(NSString *)otherType toView:(id)toView
{
    WH_JXConnection* p = [self addTask:act_otherBindUserInfo param:nil toView:toView];
    
    if ([otherType intValue] == 1) { //QQ
        [p setPostValue:openId forKey:@"code"];
        [p setPostValue:otherToken forKey:@"otherToken"];
    }else if ([otherType intValue] == 2) { //微信
        [p setPostValue:openId forKey:@"code"];
    }
    [p setPostValue:otherType forKey:@"otherType"];
    long time = (long)[[NSDate date] timeIntervalSince1970];
    [p setPostValue:[self getSecretWithText:APIKEY time:time] forKey:@"secret"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    
    [p go];
}

// 第三方绑定手机号
-(void)WH_thirdLogin:(WH_JXUserObject*)user type:(NSInteger)type openId:(NSString *)openId isLogin:(BOOL)isLogin toView:(id)toView{
    //  type  第三方登录类型  1: QQ  2: 微信
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    WH_JXConnection* p = [self addTask:wh_act_thirdLogin param:nil toView:toView];
    
    [p setPostValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [p setPostValue:openId forKey:@"loginInfo"];
    if (self.openId.length > 0 ) {
        NSString *tel = [NSString stringWithFormat:@"%@%@",user.areaCode,user.telephone];
        [p setPostValue:tel forKey:@"telephone"];
    }else {
        [p setPostValue:user.telephone forKey:@"telephone"];
    }
    [p setPostValue:user.password forKey:@"password"];
    // 没有在登录后 绑定 才需要传下面的参数
    if (!isLogin) {
        [p setPostValue:user.areaCode forKey:@"areaCode"];
        [p setPostValue:@"client_credentials" forKey:@"grant_type"];
        [p setPostValue:user.model forKey:@"model"];
        [p setPostValue:user.osVersion forKey:@"osVersion"];
        [p setPostValue:g_macAddress forKey:@"serial"];
        [p setPostValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
        [p setPostValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
        [p setPostValue:user.location forKey:@"location"];
        [p setPostValue:identifier forKey:@"appId"];
        [p setPostValue:[NSNumber numberWithInt:1] forKey:@"xmppVersion"];
        // 是否开启集群
        if ([g_config.isOpenCluster integerValue] == 1) {
            NSString *area = [g_default objectForKey:kLocationArea];
            [p setPostValue:area forKey:@"area"];
        }
    }
    
    [p go];
}

// 第三方网页授权
- (void)WH_openCodeAuthorCheckAppId:(NSString *)appId state:(NSString *)state callbackUrl:(NSString *)callbackUrl toView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_openCodeAuthorCheck param:nil toView:toView];
    [p setPostValue:appId forKey:@"appId"];
    [p setPostValue:state forKey:@"state"];
    [p setPostValue:callbackUrl forKey:@"callbackUrl"];
    [p go];
}

// 检查网址是否被锁定
- (void)WH_userCheckReportUrl:(NSString *)webUrl toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_userCheckReportUrl param:nil toView:toView];
    [p setPostValue:webUrl forKey:@"webUrl"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

// 第三方解绑
- (void)WH_setAccountUnbind:(int)type toView:(id)toView {
    //  type  第三方登录类型  1: QQ  2: 微信
    WH_JXConnection* p = [self addTask:wh_act_unbind param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

// 获取用户绑定信息接口
- (void)WH_getUserBindInfo:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_getBindInfo param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

// 面对面建群
//面对面建群查询
- (void)WH_roomLocationQueryWithIsQuery:(int)isQuery password:(NSString *)password toView:(id)toView{
    
    WH_JXConnection* p = [self addTask:wh_act_RoomLocationQuery param:nil toView:toView];
    [p setPostValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [p setPostValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [p setPostValue:[NSNumber numberWithInt:isQuery] forKey:@"isQuery"];
    [p setPostValue:password forKey:@"password"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
//面对面建群加入
- (void)WH_roomLocationJoinWithJid:(NSString *)jid toView:(id)toView{
    
    WH_JXConnection* p = [self addTask:wh_act_RoomLocationJoin param:nil toView:toView];
    [p setPostValue:jid forKey:@"jid"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
//面对面建群退出
- (void)WH_roomLocationExitWithJid:(NSString *)jid toView:(id)toView{
    
    WH_JXConnection* p = [self addTask:wh_act_RoomLocationExit param:nil toView:toView];
    [p setPostValue:jid forKey:@"jid"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

// Tigase支付
// 接口获取订单信息
- (void)WH_payGetOrderInfoWithAppId:(NSString *)appId prepayId:(NSString *)prepayId toView:(id)toView{
    
    WH_JXConnection* p = [self addTask:wh_act_PayGetOrderInfo param:nil toView:toView];
    [p setPostValue:appId forKey:@"appId"];
    [p setPostValue:prepayId forKey:@"prepayId"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

// 输入密码后支付接口
- (void)payPasswordPaymentWithAppId:(NSString *)appId prepayId:(NSString *)prepayId sign:(NSString *)sign time:(NSString *)time secret:(NSString *)secret toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:wh_act_PayPasswordPayment param:nil toView:toView];
    [p setPostValue:appId forKey:@"appId"];
    [p setPostValue:prepayId forKey:@"prepayId"];
    [p setPostValue:sign forKey:@"sign"];
    [p setPostValue:secret forKey:@"secret"];
    [p setPostValue:time forKey:@"time"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
//朋友圈搜索
- (void)searchCircleWithUserId:(NSString *)userId keyWord:(NSString *)keyWord monthStr:(NSString *)monthStr pageIndex:(NSString *)pageIndex pageSize:(NSString *)pageSize type:(NSString *)type toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:act_getCircleWithCondition param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:keyWord forKey:@"keyWord"];
    [p setPostValue:monthStr forKey:@"monthStr"];
    [p setPostValue:pageIndex forKey:@"pageIndex"];
    [p setPostValue:pageSize forKey:@"pageSize"];
    [p setPostValue:type forKey:@"type"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}
//群聊积分机器人
- (void)roomSignInGroupWithUserId:(NSString *)uId fraction:(NSString *)fraction roomId:(NSString *)roomId type:(NSString *)type toView:(id)toView {
    
    WH_JXConnection* p = [self addTask:act_roomSignInGroup param:nil toView:toView];
    [p setPostValue:uId forKey:@"uIds"];
    [p setPostValue:fraction forKey:@"fraction"];
    [p setPostValue:roomId forKey:@"roomId"];
    [p setPostValue:type forKey:@"type"];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p go];
}

#pragma mark - 推广邀请
//查询用户邀请码信息
- (void)QueryUserInvitationCodeInformationWithUserId:(NSString *)userId toView:(id)toView
{
    WH_JXConnection *p = [self addTask:wh_act_InviteGetUserInviteInfo param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
//查询用户通证列表（分页）
- (void)QueryUserInvitePassCardWithUserId:(NSString *)userId PageIndex:(int)pageIndex toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_InviteFindUserPassCard param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [p setPostValue:[NSNumber numberWithInteger:10] forKey:@"limit"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}
//清除已使用状态的通证
- (void)ClearHaveUsedPassCardWithUserId:(NSString *)userId toView:(id)toView
{
    WH_JXConnection *p = [self addTask:wh_act_InviteDelUserPassCard param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
    
}
//查询用户邀请人记录（分页）
- (void)FindUserInviteMemberWithUserId:(NSString *)userId PageIndex:(int)pageIndex toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_InviteFindUserInviteMember param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [p setPostValue:[NSNumber numberWithInteger:10] forKey:@"limit"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


/**
 新版本请求

 @param isAppStore 是否是appStore YES: appStore NO: 企业包
 @param toView 代理
 */
- (void)newVersionReqWithIsAppStore:(BOOL)isAppStore toView:(id)toView{
    WH_JXConnection *p = [self addTask:wh_act_NewVersion param:nil toView:toView];
    [p setPostValue:isAppStore ? @"3" : @"2" forKey:@"appType"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

//用户提现
- (void)userWithdrawalWithUserId:(NSString *)userId amount:(NSString *)amount secret:(NSString *)secret context:(NSString *)context accountType:(NSString *)type toView:(id)toView time:(NSString *)time {
    WH_JXConnection* p = [self addTask:wh_act_TransferToAdmin param:nil toView:toView];
    [p setPostValue:userId forKey:@"userId"];
    [p setPostValue:amount forKey:@"amount"];
//    NSString *secretStr = [[g_server WH_getMD5StringWithStr:@"1234567890"] mutableCopy];
    [p setPostValue:secret forKey:@"secret"];
    [p setPostValue:context forKey:@"context"]; //会员信息
    [p setPostValue:type forKey:@"type"]; //提现方式
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:time forKey:@"time"];
    [p go];
}

/**
 * 提现到后台的提现方式
 */
- (void)userWithdrawWayWithToView:(id)toView {
    WH_JXConnection* p = [self addTask:wh_act_withdrawWay param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

/**
 忘记支付密码

 @param modifyType 修改类型 1=支付
 @param oldPassword 登录密码
 @param newPassword 新支付密码
 @param toView 代理
 */
- (void)forgetPayPswWithModifyType:(NSString *)modifyType oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_forgetPayPassword param:nil toView:toView];
    [p setPostValue:modifyType forKey:@"modifyType"];
    [p setPostValue:[self WH_getMD5StringWithStr:oldPassword] forKey:@"oldPassword"];
    [p setPostValue:[self WH_getMD5StringWithStr:newPassword] forKey:@"newPassword"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}




/**
 登录公众号

 @param qcCodeToken 公众号二维码扫码结果
 @param toView 代理
 */
- (void)loginPublicAccountReqWithQrCodeToken:(NSString *)qcCodeToken toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_consoleLoginPublicAcc param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:qcCodeToken forKey:@"qcCodeToken"];
    [p go];
}

/**
 登录开放平台
 
 @param qcCodeToken 公众号二维码扫码结果
 @param toView 代理
 */
- (void)openLoginPublicOpenAccReqWithQrCodeToken:(NSString *)qcCodeToken toView:(id)toView{
    WH_JXConnection* p = [self addTask:wh_act_openLoginPublicOpenAcc param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:qcCodeToken forKey:@"qcCodeToken"];
    [p go];
}

#pragma mark 扫码登录
- (void)requestScanLoginWithScanContent:(NSString *)scanContent toView:(id)toView {
    WH_JXConnection *p = [self addTask:act_ScanLogin param:nil toView:toView];
    [p setPostValue:scanContent forKey:@"qcCodeToken"];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}

#pragma mark - 支付系统
/**
 获取支付银行列表
 */
- (void)getPayBankListWithView:(id)toView{
    WH_JXConnection* p = [self addTask:act_getPayMethod param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


/**
 银行卡充值
 
 @param serialAmount 金额
 @param toView 代理
 */
- (void)payGetOrderDetailsReqWithSerialAmount:(NSString *)serialAmount toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_payGetOrderDetails param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:serialAmount forKey:@"serialAmount"];
    //    [p setPostValue:drawee forKey:@"drawee"];
    //    [p setPostValue:payNumber forKey:@"payNumber"];
    //    [p setPostValue:paymentChannels forKey:@"paymentChannels"];
    [p go];
}


/**
 获取绑定银行卡信息
 
 @param toView 代理
 */
- (void)getBankInfoByUserIdReqWithToView:(id)toView{
    WH_JXConnection* p = [self addTask:act_getBankInfoByUserId param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    
    long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    [p setPostValue:[self getBankPaySecretWithTime:time] forKey:@"secret"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p go];
}


/**
 删除绑定的银行卡
 
 @param bankId 银行卡id
 @param toView 代理
 */
- (void)deleteBankInfoByIdReqWithBankId:(NSString *)bankId toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_deleteBankInfoById param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:bankId forKey:@"bankId"];
    
    long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    [p setPostValue:[self getBankPaySecretWithTime:time] forKey:@"secret"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p go];
}


/**
 添加银行卡
 
 @param realName 账户姓名
 @param cardNumber 银行卡号
 @param toView 代理
 */
- (void)userBindBankInfoReqWithRealName:(NSString *)realName cardNum:(NSString *)cardNum toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_userBindBandInfo param:nil toView:toView];
    [p setPostValue:access_token forKey:@"access_token"];
    [p setPostValue:realName forKey:@"realName"];
    [p setPostValue:cardNum forKey:@"cardNum"];
    
    long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
    [p setPostValue:[self getBankPaySecretWithTime:time] forKey:@"secret"];
    [p setPostValue:[NSNumber numberWithLong:time] forKey:@"time"];
    [p go];
}

//生成银行卡相关的secret
- (NSString *)getBankPaySecretWithTime:(long)time {
    NSMutableString *str1 = [NSMutableString string];
    [str1 appendString:APIKEY];
    [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
    str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
    
    [str1 appendString:g_myself.userId];
    [str1 appendString:g_server.access_token];
    return [[g_server WH_getMD5StringWithStr:str1] copy];
}


/**
 获取支付类型
 
 @param toView 代理
 */
- (void)paySystem_getPayTypeToView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetZhxx param:nil toView:toView];
    //    [p setPostValue:access_token forKey:@"access_token"];
    [p go];
}


/**
 提交充值订单
 
 @param money 金额
 @param zfid 支付类型id
 @param zfzh zfzh:支付账号，会员输入充值的账号
 @param toView 代理
 */
- (void)paySystem_commitRechargeOrderWithMoney:(NSString *)money zfid:(NSString *)zfid zfzh:(NSString *)zfzh toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexPostCz param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:money forKey:@"money"];
    [p setPostValue:zfid forKey:@"zfid"];
    [p setPostValue:zfzh forKey:@"zfzh"];
    [p go];
}


/**
 获取订单
 
 @param toView 代理
 */
- (void)paySystem_getOrderWithToView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetOrder param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p go];
}


/**
 获取取消订单
 
 @param ordernum 订单号
 @param toView 代理
 */
- (void)paySystem_getCancelOrderWithOrderNum:(NSString *)ordernum toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetCancelOrder param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:ordernum forKey:@"ordernum"];
    [p go];
}


/**
 获取我已付款
 
 @param ordernum 订单号
 @param toView 代理
 */
- (void)paySystem_getPayOrderWithOrderNum:(NSString *)ordernum toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetPayOrder param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:ordernum forKey:@"ordernum"];
    [p go];
}


/**
 获取充值订单列表
 
 @param types 不传默认为全部订单
 @param pagenum 页码,分页使用，默认一页10条
 @param toView 代理
 */
- (void)paySystem_getOrderListWithTypes:(NSString *)types pagenum:(NSString *)pagenum toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetOrderList param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:types forKey:@"types"];
    [p setPostValue:pagenum forKey:@"pagenum"];
    [p go];
}


/**
 获取订单详情接口
 
 @param ID 订单id
 @param toView 代理
 */
- (void)paySystem_getOrderDetailWithId:(NSString *)ID toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetOrderDetail param:nil toView:toView];
    //    [p setPostValue:longToStr(user_id) forKey:@"userId"];
    [p setPostValue:ID forKey:@"id"];
    [p go];
}


/**
 提币生成订单接口
 
 @param nums 提币数量
 @param address 提币地址
 @param toView 提币地址
 */
- (void)paySystem_withdrawCoinWithNums:(NSString *)nums address:(NSString *)address toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexPostTb param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:nums forKey:@"nums"];
    [p setPostValue:address forKey:@"address"];
    [p go];
}


/**
 获取提币信息 等待付币、确认收币、已完成详情接口
 
 @param orderid 订单id
 @param toView 代理
 */
- (void)paySystem_getWithdrawCoinInfoWithOrderid:(NSString *)orderid toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetTbinfo param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:orderid forKey:@"orderid"];
    [p go];
}


/**
 确认提币
 
 @param orderid 订单id
 @param toView 代理
 */
- (void)paySystem_getConfirmWithdrawCoinWithOrderid:(NSString *)orderid toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetQrtb param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:orderid forKey:@"orderid"];
    [p go];
}

/**
 确认收币
 
 @param orderid 订单id
 @param toView 代理
 */
- (void)paySystem_getConfirmAcceptCoinWithOrderid:(NSString *)orderid toView:(NSString *)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetQrsb param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:orderid forKey:@"orderid"];
    [p go];
}


/**
 提币列表
 
 @param pagenum 页码
 @param types 不传默认全部
 0全部
 1待放行
 2待放行
 3已取消
 4待付币
 @param toView 代理
 */
- (void)paySystem_getMyOrderWithPagenum:(NSString *)pagenum types:(NSString *)types toView:(id)toView{
    WH_JXConnection* p = [self addTask:act_portalIndexGetMyorder param:nil toView:toView];
    [p setPostValue:access_token forKey:@"accessToken"];
    [p setPostValue:pagenum forKey:@"pagenum"];
    [p setPostValue:types forKey:@"types"];
    [p go];
}






//手机型号
- (NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return deviceString;
    
}

#pragma mark -------------- Tigase连接日志上报
- (void)logReportWithLogContext:(NSString *)logContext toView:(id)toView
{
    WH_JXConnection *p = [self addTask:act_LogReport param:nil toView:toView];
    [p setPostValue:logContext forKey:@"logContext"];
    [p setPostValue:@"ios" forKey:@"type"];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p go];
}

#pragma mark - 密保问题
- (void)getPasswordSecListWithUserName:(NSString *)userName toDelegate:(id)delegate {
    WH_JXConnection *p = [self addTask:act_pwsSecList param:nil toView:delegate];
    [p setPostValue:userName forKey:@"userName"];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p go];
}
- (void)getPasswordSecListData:(id)toView {
    WH_JXConnection *p = [self addTask:act_pwsSecList param:nil toView:toView];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p go];
}
- (void)checkPwdSecAnswer:(NSDictionary *)params toDelegate:(id)delegate {
    WH_JXConnection *p = [self addTask:act_pwdSecCheck param:nil toView:delegate];
    [p setPostValue:params[@"userName"] forKey:@"userName"];
    [p setPostValue:params[@"qid"] forKey:@"qid"];
    [p setPostValue:params[@"answer"] forKey:@"answer"];
    [p setPostValue:g_server.access_token forKey:@"access_token"];
    [p go];
}
- (void)setPasswordSecQuesAns:(NSString *)ans toView:(id)toView {
    WH_JXConnection *p = [self addTask:act_pwsSecSet param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:myself.userId forKey:@"userId"];
    [p setPostValue:ans forKey:@"questions"];
    [p setPostValue:myself.telephone forKey:@"phone"];
    [p go];
}


- (void)WH_DeleteOneLastChatWithToUser:(NSString *)toUser toView:(id)toView
{
    WH_JXConnection *p = [self addTask:act_deleteOneLastChat param:nil toView:toView];
    [p setPostValue:self.access_token forKey:@"access_token"];
    [p setPostValue:toUser forKey:@"jid"];
    [p go];
}

/*
 h5充值
 */
- (void)h5PaymentWithMoney:(NSString *)money notifyUrl:(NSString *)notifyUrl tradeNo:(NSString *)tradeNo pId:(NSString *)pId returnUrl:(NSString *)returnUrl sign:(NSString *)sign type:(NSString *)type userId:(NSString *)userId userIp:(NSString *)userIp toView:(id)toView; {
    WH_JXConnection *p = [self addTask:act_h5Payment param:nil toView:toView];
    [p setPostValue:money forKey:@"money"];
    [p setPostValue:notifyUrl forKey:@"notify_url"];
    [p setPostValue:tradeNo forKey:@"out_trade_no"] ;
    [p setPostValue:pId forKey:@"pid"];
    [p setPostValue:returnUrl forKey:@"return_url"];
    [p setPostValue:sign forKey:@"sign"];
    [p setPostValue:type forKey:@"type"];
    [p setPostValue:userId forKey:@"userid"];
    [p setPostValue:userIp forKey:@"userip"];
    [p go];
}

@end
