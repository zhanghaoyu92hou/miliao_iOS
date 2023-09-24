//
//  WH_AudioSessionControl.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AudioSessionControl.h"

@implementation WH_AudioSessionControl


/*
 * 继续播放后台背景音乐, 取消激活当前应用的audio session
 * @param error 设置失败时的错误信息
 **/
+ (void)resumeBackgroundSoundWithError:(NSError **)error {
    //Deactivate audio session in current app
    //Activate audio session in others' app depending on wether they listen to the Category changed
    //See here https://developer.apple.com/library/content/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioGuidelinesByAppType/AudioGuidelinesByAppType.html#//apple_ref/doc/uid/TP40007875-CH11-SW1
    
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:error];
}

/*
 * 暂停后台背景音乐的播放，激活当前应用的audio
 * @param error 设置失败时的错误信息
 **/
+ (void)pauseBackgroundSoundWithError:(NSError **)error {
    
    //See here https://developer.apple.com/library/content/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/ConfiguringanAudioSession/ConfiguringanAudioSession.html#//apple_ref/doc/uid/TP40007875-CH2-SW1
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //Set AVAudioSessionCategoryPlayback category mode for current app
    [session setCategory:AVAudioSessionCategoryPlayback error:error];
    //Activate audio session in current app
    //Deactivate audio session in others' app
    [session setActive:YES error:error];
}

+ (void)pauseBackgroundSoundWithCategoryRecord {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
}

@end
