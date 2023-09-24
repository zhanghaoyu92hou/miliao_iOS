//
//  WH_JXCamera_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/11/6.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_JXCamera_WHVC;
@protocol WH_JXCamera_WHVCDelegate <NSObject>

- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image;
- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithVideoPath:(NSString *)filePath timeLen:(NSInteger)timeLen;

@end

@interface WH_JXCamera_WHVC : UIViewController

@property (nonatomic, weak) id<WH_JXCamera_WHVCDelegate>cameraDelegate;


@property(nonatomic,assign) int maxTime;
@property(nonatomic,assign) int minTime;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didRecord;
@property (nonatomic,strong) NSString* outputFileName;//返回的video


/**
 * isVideo  YES:开启视频录制,若不需要即不需赋值
 * isPhoto  YES:开启照片拍摄,若不需要即不需赋值
 * 若需要 视频录制、照片拍摄同时开启，即都不赋值
 */
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, assign) BOOL isPhoto;



- (void)sp_getMediaData;
@end
