//
//  AppDelegate+ShareSDK.m
//  Tigase
//
//  Created by 齐科 on 2019/9/21.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "AppDelegate+ShareSDK.h"
#import "WH_AuthViewController.h"
#import "WH_JXRelay_WHVC.h"

@implementation AppDelegate (ShareSDK)

- (void)handleBLNShareWithUrl:(NSURL *)url {
    NSString *urlString = url.absoluteString.stringByRemovingPercentEncoding;
    NSString *identifier = [NSString stringWithFormat:@"%@/", SDKShareIdentifier];
    NSRange range = [urlString rangeOfString:identifier];
    if (range.location != NSNotFound) {
        NSString *contentString = [urlString substringFromIndex:(range.location + range.length)];
        NSDictionary *infoDic = [contentString.stringByRemovingPercentEncoding mj_JSONObject];
        NSLog(@"infoDic == %@", infoDic);
        //Verify = 0, Login=1, Text=2, Image=3, Link=4, Audio=5, Video=6, File=7
        if ([infoDic[@"type"] integerValue] == 1) {
            [self handleLoginWithInfoDic:infoDic url:url];
        }else {
            WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
            if ([infoDic[@"type"] integerValue] == 2){
                msg = [self handleTextWithInfoDic:infoDic url:url];
            }else if ([infoDic[@"type"] integerValue] == 4) {
                msg = [self handleLinkWithInfoDic:infoDic url:url];
            }else if ([infoDic[@"type"] integerValue] == 3){
                msg = [self handleImageWithInfoDic:infoDic url:url];
            }else if ([infoDic[@"type"] integerValue] == 5){
                msg = [self handleAudioWithInfoDic:infoDic url:url];
            }else if ([infoDic[@"type"] integerValue] == 6){
                msg = [self handleVideoWithInfoDic:infoDic url:url];
            }else if ([infoDic[@"type"] integerValue] == 7){
                msg = [self handleFileWithInfoDic:infoDic url:url];
            }
            [self pushToRelayViewController:msg url:url];
        }
    }
}

- (void)handleLoginWithInfoDic:(NSDictionary *)infoDic url:(NSURL *)url {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    UIImage *image;
    NSData *data = [pasteboard dataForPasteboardType:@"BLNLogin"];
    if (data) {
        image = [UIImage imageWithData:data];
    }
    if (g_server.isLogin) {
        NSLog(@"login status ----handleLoginWithInfoDic ");
        WH_AuthViewController *vc = [[WH_AuthViewController alloc] init];
        vc.infoDic = infoDic[@"info"];
        vc.sdkImage = image;
        vc.fromSchema = url.host;
        [g_navigation pushViewController:vc animated:YES];
    }else {
        NSDictionary *shareDic = @{@"info":infoDic[@"info"], @"url":url.absoluteString};
        [g_default setObject:shareDic forKey:@"beAuth"];
        NSLog(@"logout status ---- handleLoginWithInfoDic ");
    }
}
- (WH_JXMessageObject *)handleTextWithInfoDic:(NSDictionary *)infoDic url:(NSURL *)url{
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
    msg.content = infoDic[@"content"];
    return msg;
}

- (WH_JXMessageObject *)handleLinkWithInfoDic:(NSDictionary *)infoDic url:(NSURL *)url{
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.type = [NSNumber numberWithInt:kWCMessageTypeLink];
    msg.content = infoDic[@"content"];//Localized(@"JX_[Link]");
    
    return msg;
}
- (WH_JXMessageObject *)handleImageWithInfoDic:(NSDictionary *)infoDic url:(NSURL *)url{
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.type = [NSNumber numberWithInt:kWCMessageTypeImage];
    //若sdk中传的是本地图片，则用下面的处理方式
    //    NSString *filePath =  [self saveImageToDocument];
    //    msg.fileName = filePath;
    //    msg.content = [[filePath lastPathComponent] stringByDeletingPathExtension];
    msg.fileName = infoDic[@"content"];
    msg.content = infoDic[@"content"];
    
    return msg;
}
- (WH_JXMessageObject *)handleAudioWithInfoDic:(NSDictionary *)infoDic url:(NSURL *)url{
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.type = [NSNumber numberWithInt:kWCMessageTypeAudio];
    NSString *filePath =  infoDic[@"content"];// [self saveImageToDocument];
    msg.fileName = filePath;
    msg.content = [[filePath lastPathComponent] stringByDeletingPathExtension];
    return msg;
}
- (WH_JXMessageObject *)handleVideoWithInfoDic:(NSDictionary *)infoDic url:(NSURL *)url{
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.type = [NSNumber numberWithInt:kWCMessageTypeVideo];
    NSString *filePath =  infoDic[@"content"];// [self saveImageToDocument];
    msg.fileName = filePath;
    msg.content = [[filePath lastPathComponent] stringByDeletingPathExtension];
    return msg;
}
- (WH_JXMessageObject *)handleFileWithInfoDic:(NSDictionary *)infoDic url:(NSURL *)url{
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.type = [NSNumber numberWithInt:kWCMessageTypeFile];
    NSString *filePath =  infoDic[@"content"];
    msg.fileName = filePath;//[self saveImageToDocument];
    msg.content = [[filePath lastPathComponent] stringByDeletingPathExtension];
    return msg;
}
- (void)pushToRelayViewController:(WH_JXMessageObject *)message url:(NSURL *)url{
    
    WH_JXRelay_WHVC *relayVC = [[WH_JXRelay_WHVC alloc] init];
    relayVC.isSDKShare = YES;
    relayVC.isShare = YES;
    relayVC.shareUrl = url;
    NSMutableArray *array = [NSMutableArray arrayWithObject:message];
    relayVC.relayMsgArray = array;
    UIViewController *lastVC = (UIViewController *)g_navigation.subViews.lastObject;
    [lastVC presentViewController:relayVC animated:YES completion:nil];
}
- (NSString *)saveImageToDocument {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData *imageData = [pasteboard dataForPasteboardType:@"BLNImage"];
    UIImage *image = [UIImage imageWithData:imageData];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"sharedImage.png"]];  // 保存文件的名称
    
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath   atomically:YES]; // 保存成功会返回YES
    if (result == YES) {
        NSLog(@"保存成功");
        NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:@(0)];
        [pasteboard setData:dictData forPasteboardType:@"BLNImage"];
    }
    return filePath;
}

@end
