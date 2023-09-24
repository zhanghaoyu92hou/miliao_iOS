//
//  WW_StrongReminderView.m
//  WaHu
//
//  Created by Apple on 2019/5/17.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WH_StrongReminderView.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
//#import "WWGroupModel.h"

@interface WH_StrongReminderView ()

// 播放器
@property (nonatomic , strong) AVAudioPlayer * player;

@end

@implementation WH_StrongReminderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        
        //震动
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        

        
        [self playAudio];
//        [[RBDMuteSwitch sharedInstance] setDelegate:self];
//        [[RBDMuteSwitch sharedInstance] detectMuteSwitch];
//        [self createContentViewWithFrame:frame];
    }
    return self;
}

void systemAudioCallback()

{
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}


//- (void)isMuted:(BOOL)muted {
//    if (muted) {
//        NSLog(@"静音");
//    }else{
//        NSLog(@"非静音");
//    }
//}

- (void)setupUI{
    [self createContentViewWithFrame:self.frame];
}

- (void)createContentViewWithFrame:(CGRect)frame {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = frame;
    [self addSubview:effectView];
    
    UIView *tView = [[UIView alloc] initWithFrame:CGRectMake(12, 50, CGRectGetWidth(self.frame) - 24, 50)];
    [self addSubview:tView];
    
    UIImageView *headeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [headeImage sd_setImageWithURL:[NSURL URLWithString:_headUrl?:@""] placeholderImage:[UIImage imageNamed:@"circleUser"]];
    [tView addSubview:headeImage];
    [headeImage headRadiusWithAngle:headeImage.bounds.size.height / 2.0f];
    
    UILabel *nLabel = [[UILabel alloc] initWithFrame:CGRectMake(headeImage.frame.origin.x + 10 + CGRectGetWidth(headeImage.frame), 0, CGRectGetWidth(tView.frame) - headeImage.frame.origin.x - CGRectGetWidth(headeImage.frame) - 20, 25)];
    [nLabel setText:_name?:@""];
    [nLabel setTextColor:HEXCOLOR(0xffffff)];
    [nLabel setFont: [UIFont fontWithName:@"PingFangSC-Medium" size:17]];
    [tView addSubview:nLabel];
    
    UILabel *ggLabel = [[UILabel alloc] initWithFrame:CGRectMake(headeImage.frame.origin.x + 10+ CGRectGetWidth(headeImage.frame), CGRectGetHeight(nLabel.frame), CGRectGetWidth(tView.frame) - headeImage.frame.origin.x - CGRectGetWidth(headeImage.frame) - 20, 25)];
    
//    NSArray *groupModels = [[WWFMDBGroupDataModel sharedInstance] queryDataFromDataBaseWithGroupId:_notice[@"groupId"]?:@""];
//    if (groupModels.count) {
//        WWGroupModel *groupModel = groupModels.firstObject;
//        [ggLabel setText:[NSString stringWithFormat:@"%@%@%@",Localized(@"来自于"),groupModel.name,Localized(@"的群")]];
//    }
    [ggLabel setTextColor:HEXCOLOR(0xDCDCDC)];
    [ggLabel setFont:[UIFont systemFontOfSize:15]];
    [tView addSubview:ggLabel];
    
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(12, tView.frame.origin.y + CGRectGetHeight(tView.frame) + 25, CGRectGetWidth(self.frame) - 24, 20)];
    [self addSubview:lView];
    
    NSLog(@"%@", [NSString stringWithFormat:@"%ld", (NSInteger)[[NSDate date] timeIntervalSince1970]]);
    UILabel *timeLb = [UILabel new];
    timeLb.textColor = [UIColor whiteColor];
    [tView addSubview:timeLb];
    NSString *timeStr = @"";
    if ([_notice isKindOfClass:[NSDictionary class]]) {
        if (_notice[@"time"]) {
            timeStr =  [self timestampToDate:[_notice[@"time"] longLongValue]];
        }
    }
    timeLb.text = timeStr;
    
    [timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(headeImage);
        make.left.mas_equalTo(nLabel.mas_left);
    }];

    
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(lView.frame), CGRectGetHeight(lView.frame))];
    [label setTextColor:HEXCOLOR(0xFFFFFF)];
    [label setText:@"最新公告"];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [lView addSubview:label];
    
    for (int i = 0; i < 2; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i*((CGRectGetWidth(lView.frame) - 88)/2 + 88), (CGRectGetHeight(lView.frame) - 5)/2, (CGRectGetWidth(lView.frame) - 88)/2, 5)];
        [lineView setBackgroundColor:HEXCOLOR(0xffffff)];
        [lView addSubview:lineView];
        [lineView radiusWithAngle:2.5];
        
        CGFloat yuan_orginY = 0.0f;
        if (i == 0) {
            yuan_orginY = CGRectGetWidth(lineView.frame) + lineView.frame.origin.x + 5;
        } else {
            yuan_orginY = CGRectGetWidth(lView.frame) - CGRectGetWidth(lineView.frame) - 10;
        }
        
        UIImageView *yuanImgView = [[UIImageView alloc] initWithFrame:CGRectMake(yuan_orginY, (CGRectGetHeight(lView.frame) - 5)/2, 5, 5)];
        [yuanImgView setImage:[UIImage imageNamed:@"video_yuan"]];
        [lView addSubview:yuanImgView];
    }
    
    //底部视图
    UIView *btmView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 149, JX_SCREEN_WIDTH, 149)];
    [self addSubview:btmView];
    
    UILabel *bLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(btmView.frame) - 118)/2, CGRectGetHeight(btmView.frame) - 36, 118, 20)];
    [bLabel setText:Localized(@"我该如何关闭提醒")];
    [bLabel setTextColor:HEXCOLOR(0xCCCCCC)];
    [bLabel setFont:[UIFont systemFontOfSize:13]];
    [bLabel setTextAlignment:NSTextAlignmentCenter];
    [btmView addSubview:bLabel];
    bLabel.userInteractionEnabled = YES;
    [bLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(questionMarkMethod)]];
    
    UIButton *wBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [wBtn setFrame:CGRectMake(bLabel.frame.origin.x + CGRectGetWidth(bLabel.frame) + 9, bLabel.frame.origin.y + 2.5, 15, 15)];
    [wBtn setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [btmView addSubview:wBtn];
    [wBtn addTarget:self action:@selector(questionMarkMethod) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *btnArray = @[@{@"btnImage":@"ignoreReminder" ,@"btnName":@"忽略提醒"} ,@{@"btnImage":@"intoGroup" ,@"btnName":@"进群"}];
    for (int i = 0; i < btnArray.count; i++) {
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(63 + i*((CGRectGetWidth(btmView.frame) - 63 - 65 - 63)), 0, 55, 83)];
        [btmView addSubview:btnView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 55, 55)];
        btn.tag = i;
        [btn setImage:[UIImage imageNamed:[[btnArray objectAtIndex:i] objectForKey:@"btnImage"]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[[btnArray objectAtIndex:i] objectForKey:@"btnImage"]] forState:UIControlStateHighlighted];
        [btnView addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *bLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(btn.frame)+8, CGRectGetWidth(btnView.frame), 20)];
        [bLabel setText:[[btnArray objectAtIndex:i] objectForKey:@"btnName"]];
        [bLabel setTextColor:HEXCOLOR(0xFFFFFF)];
        [bLabel setFont:[UIFont systemFontOfSize:13]];
        [bLabel setTextAlignment:NSTextAlignmentCenter];
        [btnView addSubview:bLabel];
    }
    
    UIView *contenView = [[UIView alloc] initWithFrame:CGRectMake(0, lView.frame.origin.y + CGRectGetHeight(lView.frame) + 12, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - lView.frame.origin.y - CGRectGetHeight(lView.frame) - 12 - CGRectGetHeight(btmView.frame) - 12)];
    [self addSubview:contenView];
    
    UITextView *cTextView = [[UITextView alloc] initWithFrame:CGRectMake(12, 0, CGRectGetWidth(contenView.frame) - 24, CGRectGetHeight(contenView.frame))];
    [cTextView setBackgroundColor:[UIColor clearColor]];
    cTextView.text = _notice[@"text"]?:@"";
    [cTextView setTextColor:HEXCOLOR(0xffffff)];
    [cTextView setFont:[UIFont systemFontOfSize:16]];
    cTextView.editable = NO;
    cTextView.userInteractionEnabled = YES;
    cTextView.scrollEnabled = YES;
    cTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [contenView addSubview:cTextView];
}

- (void)btnClick:(UIButton *)btn {
    NSInteger btnTag = btn.tag;
    if (btnTag == 0) {
        [self close];
    }else{
        NSLog(@"进群");
        if (self.entryGroupCallback) {
            self.entryGroupCallback(self);
        }
    }
}
//如何关闭提醒事件
- (void)questionMarkMethod {
    //CGRectGetHeight(self.frame) - 44 - 50
    UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(47.5, CGRectGetHeight(self.frame) , CGRectGetWidth(self.frame) - 95, 50)];
    [mView setBackgroundColor:HEXCOLOR(0x646464)];
    [self addSubview:mView];
    [mView radiusWithAngle:5];

    UILabel *mLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, CGRectGetWidth(mView.frame) - 24, CGRectGetHeight(mView.frame) - 10)];
    [mLabel setText:Localized(@"您可以进入相应的群，在右上角选择“群提醒”选择关闭")];
    [mLabel setTextColor:HEXCOLOR(0xFFFFFF)];
    [mLabel setNumberOfLines:0];
    [mLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
    [mView addSubview:mLabel];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = mView.frame;
        frame.origin.y -= 94;
        mView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:3 animations:^{
            mLabel.alpha -= 10/3;
            mView.alpha -= 10/2.5;
            
        }];
    }];
}

- (void)show {
    [g_window addSubview:self];
    
}
- (void)close {
    //关闭系统震动
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    [self destoryPlayer];
    [self removeFromSuperview];
}

//播放
- (void)playAudio{
    [self.player stop];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"group_strong_reminder" withExtension:@"wav"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 6;
    [self.player play];
}

- (void)dealloc{
    [self destoryPlayer];
}

- (void)destoryPlayer{
    [self.player stop];
    self.player = nil;
}
//将时间戳转换为时间
- (NSString *)timestampToDate:(CGFloat)timestamp {
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:timestamp];
    
    //解决8小时时差问题
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    [dateFormatter setTimeZone:tz];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* result=[dateFormatter stringFromDate:localeDate];
    
    
    return result;
}

@end
