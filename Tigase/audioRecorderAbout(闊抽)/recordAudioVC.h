//
//  recordAudioVC.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-24.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "WH_AudioPlayerTool.h"
@class MixerHostAudio;
@class mediaOutput;

@interface recordAudioVC : UIViewController{
    MixerHostAudio* _mixRecorder;
    mediaOutput* outputer;
    IBOutlet UISegmentedControl* mFxType;

    BOOL _startOutput;
   
    WH_JXImageView* _input;
    WH_JXImageView* _volume;
    WH_JXImageView* _btnPlay;
    WH_JXImageView* _btnRecord;
    WH_JXImageView* _btnBack;
    WH_JXImageView* _btnDel;
    WH_JXImageView* _btnEnter;
    WH_JXImageView* _iv;
    UIScrollView* _effectType;
    UILabel* _lb;
    NSTimer* _timer;
    WH_AudioPlayerTool* _player;
    recordAudioVC* _pSelf;
}
@property(nonatomic,assign) int timeLen;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didRecord;
@property (nonatomic, strong) NSString* outputFileName;

@end
