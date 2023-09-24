//
//  AudioMeetingViewController.h
//  shiku_im
//
//  Created by 1 on 17/3/28.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"

typedef NS_OPTIONS(NSInteger, AudioMeetingType) {
    AudioMeetingTypeGroupCall   = 1 << 0,
    AudioMeetingTypeNumberByUserSelf = 1 << 1,
};
@interface AudioMeetingViewController : admobViewController

@property (nonatomic, copy) NSString * call;
@property (nonatomic, assign) AudioMeetingType type;

@end
