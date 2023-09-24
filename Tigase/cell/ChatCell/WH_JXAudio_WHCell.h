//
//  MiXin_JXAudio_MiXinCell.h
//  wahu_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
#import <AVFoundation/AVFoundation.h>
@class WH_JXChat_WHViewController;

@interface WH_JXAudio_WHCell : WH_JXBaseChat_WHCell{
//    WH_AudioPlayerTool* _audioPlayer;
}

@property (nonatomic,strong) UILabel * timeLen;
@property (nonatomic,strong) UIImageView * voice;
@property (nonatomic,strong) NSArray * array;
@property (nonatomic,strong) WH_AudioPlayerTool* audioPlayer;
@property (nonatomic,copy)   NSString *oldFileName;
- (void)deleteMsg;
//- (void)timeGo:(NSString *)fileName;
@end
