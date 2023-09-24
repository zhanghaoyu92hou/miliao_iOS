//
//  WH_AppVersionUpdate.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AppVersionUpdate.h"

@implementation WH_AppVersionUpdate


/**
 单例

 @return 单例对象
 */
+ (instancetype)shared{
    static WH_AppVersionUpdate *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


/**
 检查版本更新
 */
- (void)checkVersion{
    BOOL isAppStore = NO;

    if (IS_APP_STORE_VERSION) {
        isAppStore = YES;
    }else{
        isAppStore = NO;
    }
    

    [g_server newVersionReqWithIsAppStore:isAppStore toView:self];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
//    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_NewVersion]){
        NSString *versionNum = dict[@"versionNum"];
        if (versionNum) {
            NSInteger lastVersion = [versionNum integerValue];
            NSInteger currentVersionNum = [self currentVersionNum];
            if (lastVersion > currentVersionNum) {
                //有新版本
                UIAlertController *updateAlert = [UIAlertController alertControllerWithTitle:dict[@"projectName"]?:@"" message:dict[@"updateContent"]?:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                    if (IS_APP_STORE_VERSION) {
                        //跳转appStore更新
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStoreString]];
                    }else{
                        NSString *downLoadUrl = [NSString stringWithFormat:@"%@",dict[@"downloadUrl"]?:@""];
                        if (downLoadUrl) {
                            if (downLoadUrl.length) {
                                //跳转第三方更新网站01
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downLoadUrl]];
                            }
                            
                        }else{
                            NSString *thdStr = [NSString stringWithFormat:@"%@",dict[@"thirdLoadURL"]?:@""];
                            if (thdStr.length) {
                                //跳转第三方更新网站02
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:thdStr]];
                            }
                        }
                    }

                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [updateAlert addAction:confirmAction];
                int forceStatus = [dict[@"forceStatus"] intValue];
                if (forceStatus == 1) {
                    //强制更新
                    
                } else {
                    //普通更新
                    [updateAlert addAction:cancelAction];
                }
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:updateAlert animated:YES completion:nil];
            }
        }
    }
}

/*
 appStore返回:
 {
 appStoreLoadUrl = "\U5927\U6492\U6cd5\U7684\U7b97\U6cd5\U7684";
 forceStatus = 0;
 projectName = "\U54c7\U547c";
 thirdLoadURL = 1121111111111;
 updateContent = "123456\n123456\n123456\n123456";
 versionName = "2.0.0";
 versionNum = 200;
 }
 
 企业包:
 {
 forceStatus = 1;
 iosPlist = "http://test-file-1259280364.cos.ap-hongkong.myqcloud.com/u/0/0/201907/eee0a271dfee4ec9bfec6403c504f38b.plist";
 projectName = "\U54c7\U547c";
 thirdLoadURL = 1121111111111;
 updateContent = "123456\n123456\n123456\n123456";
 versionName = "2.0.0";
 versionNum = 200;
 }
 */

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    if([aDownload.action isEqualToString:wh_act_NewVersion]){
        
    }
//    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
//    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
//    [_wait stop];
}

//转换格式进行对比
- (NSInteger)currentVersionNum{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray * numberArr = [currentVersion componentsSeparatedByString:@"."];
    NSString * numberVersion = [numberArr componentsJoinedByString:@""];
    //    version = [numberVersion substringToIndex:3];
    return [numberVersion integerValue];
}

-(void)exitApplication {
    UIWindow * window = g_window;
    [UIView animateWithDuration:2.0 animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0,window.bounds.size.width,0,0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

@end
