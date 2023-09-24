//
//  WH_AudioSessionControl.h
//  Tigase
//
//  Created by 闫振奎 on 2019/7/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_AudioSessionControl : NSObject

/*
 * 继续播放后台背景音乐, 取消激活当前应用的audio session
 * @param error 设置失败时的错误信息
 **/
+ (void)resumeBackgroundSoundWithError:(NSError **)error;

/*
 * 暂停后台背景音乐的播放，激活当前应用的audio
 * @param error 设置失败时的错误信息
 **/
+ (void)pauseBackgroundSoundWithError:(NSError **)error;

+ (void)pauseBackgroundSoundWithCategoryRecord;

@end

NS_ASSUME_NONNULL_END
