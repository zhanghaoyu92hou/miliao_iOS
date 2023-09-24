//
//  WH_JXAudioRecorder_WHViewController.h
//  Tigase_imChatT
//
//  Created by Apple on 17/1/3.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"
#import "ChatCacheFileUtil.h"


@interface WH_JXAudioRecorder_WHViewController : WH_admob_WHViewController<AVAudioRecorderDelegate,AVAudioPlayerDelegate>{
    BOOL _isRecording;
//    NSTimer *_peakTimer;
    
    AVAudioRecorder *_audioRecorder;
    NSURL *_pathURL;
    NSString* _lastRecordFile;
}

@property (nonatomic,weak) id delegate;
@property(nonatomic,assign) int wh_maxTime;
@property(nonatomic,assign) int wh_minTime;

@end

@protocol WH_AudioRecorderDelegate <NSObject>

- (void)WH_AudioRecorderDidFinish:(NSString *)filePath TimeLen:(int)timenlen;

@end
