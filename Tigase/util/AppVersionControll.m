//
//  AppVersionControll.m
//  Tigase
//
//  Created by 齐科 on 2019/9/24.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "AppVersionControll.h"
@interface AppVersionControll()
{
    UIView *alertView;
    NSDictionary *infoDic;
}
@end

@implementation AppVersionControll
- (void)requestVersion {
    BOOL isAppStore = (IS_APP_STORE_VERSION == 1);
    [g_server newVersionReqWithIsAppStore:isAppStore toView:self];
}


#pragma mark ------ Handle Data

- (void)openSafariWithUrl:(NSURL *)safariUrl {
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:safariUrl];
    if (canOpen) {
        [[UIApplication sharedApplication] openURL:safariUrl];
    }else {
        NSLog(@"打开浏览器失败");
    }
}

#pragma mark ----- Show Alert
- (void)loadAlertView {
    alertView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    alertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    UIView *whiteBackView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, JX_SCREEN_WIDTH-40, 200)];
    whiteBackView.backgroundColor = UIColor.whiteColor;
    whiteBackView.layer.cornerRadius = 10;
    whiteBackView.layer.borderWidth = 0.5;
    whiteBackView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    whiteBackView.centerY = alertView.centerY;
    [alertView addSubview:whiteBackView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, whiteBackView.width, 20)];
    titleLabel.font = pingFangMediumFontWithSize(18);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = Localized(@"AppUpdate");
    titleLabel.textColor = UIColor.blackColor;
    [whiteBackView addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, titleLabel.bottom+5, whiteBackView.width-30, whiteBackView.height-titleLabel.bottom-10-60)];
    contentLabel.font = pingFangRegularFontWithSize(14);
    contentLabel.textColor = HEXCOLOR(0x333333);
    contentLabel.text = infoDic[@"updateContent"];
    [whiteBackView addSubview:contentLabel];
    
    CGFloat buttonWidth = (whiteBackView.width- 15*3)/2;
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15, whiteBackView.height-54, buttonWidth, 44)];
    [cancelButton setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelButton setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
    cancelButton.backgroundColor = UIColor.whiteColor;
    [cancelButton addTarget:self action:@selector(dismissAlert) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cancelButton.layer.borderWidth = g_factory.cardBorderWithd;
    cancelButton.layer.cornerRadius = 10;
    [whiteBackView addSubview:cancelButton];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(cancelButton.right+15, whiteBackView.height-54, buttonWidth, 44)];
    [confirmButton setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [confirmButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(openSafari) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.backgroundColor = HEXCOLOR(0x0093FF);
    confirmButton.layer.masksToBounds = YES;
    confirmButton.layer.borderColor = g_factory.cardBorderColor.CGColor;
    confirmButton.layer.borderWidth = g_factory.cardBorderWithd;
    confirmButton.layer.cornerRadius = 10;
    [whiteBackView addSubview:confirmButton];
    
    BOOL isForce = [infoDic[@"forceStatus"] boolValue]; //!< 是否强制更新
    if (isForce) {
        cancelButton.hidden = YES;
        confirmButton.centerX = whiteBackView.width/2;
        confirmButton.width = buttonWidth;
    }
}

#pragma mark ---- Button Action
- (void)openSafari {
    if (infoDic[@"thirdLoadURL"]) {
        NSURL *loadUrl = [NSURL URLWithString:infoDic[@"thirdLoadURL"]];
        [self openSafariWithUrl:loadUrl];
    }
}
- (void)dismissAlert {
    [alertView removeFromSuperview];
}
- (void)showAlert {
    [g_window addSubview:alertView];
}
- (BOOL)showVersionAlert {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSInteger isNeedUpdate = [self compareVersion:appVersion greaterThan:infoDic[@"versionName"]];
    return (isNeedUpdate == -1 );
}

#pragma mark -------
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    [[ATMHud sharedInstance] hide];
    infoDic = dict;
    if ([self showVersionAlert]) {
        [self loadAlertView];
        [self showAlert];
    }
}
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    [[ATMHud sharedInstance] hide];
    return WH_show_error;
}
#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error {//error为空时，代表超时
    [[ATMHud sharedInstance] hide];
    return WH_show_error;
}
#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload {
    [[ATMHud sharedInstance] show];
}

/**
 比较两个版本号的大小
 
 @param v1 第一个版本号
 @param v2 第二个版本号
 @return 版本号相等,返回0; v1小于v2,返回-1; 否则返回1.
 */
- (NSInteger)compareVersion:(NSString *)v1 greaterThan:(NSString *)v2 {
    // 都为空，相等，返回0
    if (!v1 && !v2) {
        return 0;
    }
    
    // v1为空，v2不为空，返回-1
    if (!v1 && v2) {
        return -1;
    }
    
    // v2为空，v1不为空，返回1
    if (v1 && !v2) {
        return 1;
    }
    // 获取版本号字段
    NSArray *v1Array = [v1 componentsSeparatedByString:@"."];
    NSArray *v2Array = [v2 componentsSeparatedByString:@"."];
    // 取字段最少的，进行循环比较
    NSInteger smallCount = (v1Array.count > v2Array.count) ? v2Array.count : v1Array.count;
    
    for (int i = 0; i < smallCount; i++) {
        NSInteger value1 = [[v1Array objectAtIndex:i] integerValue];
        NSInteger value2 = [[v2Array objectAtIndex:i] integerValue];
        if (value1 > value2) {
            // v1版本字段大于v2版本字段，返回1
            return 1;
        } else if (value1 < value2) {
            // v2版本字段大于v1版本字段，返回-1
            return -1;
        }
        
        // 版本相等，继续循环。
    }
    
    // 版本可比较字段相等，则字段多的版本高于字段少的版本。
    if (v1Array.count > v2Array.count) {
        return 1;
    } else if (v1Array.count < v2Array.count) {
        return -1;
    } else {
        return 0;
    }
    return 0;
}
@end
