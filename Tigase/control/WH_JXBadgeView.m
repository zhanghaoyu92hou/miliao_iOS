//
//  WH_JXBadgeView.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 15-1-10.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "WH_JXBadgeView.h"

@implementation WH_JXBadgeView
@synthesize wh_badgeString;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.image = [UIImage imageNamed:@"little_red_dot"];
        self.backgroundColor = g_factory.badgeBgColor;
        self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0f;
        self.hidden = YES;

        _wh_lb=[[UILabel alloc]initWithFrame:CGRectZero];
        _wh_lb.userInteractionEnabled = NO;
        _wh_lb.frame = CGRectMake(0,0, frame.size.width, frame.size.height);
        _wh_lb.backgroundColor = [UIColor clearColor];
        _wh_lb.textAlignment = NSTextAlignmentCenter;
        _wh_lb.textColor = [UIColor whiteColor];
        _wh_lb.font = sysBoldFontWithSize(9);
        [self addSubview:_wh_lb];
        [_wh_lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsZero);
        }];
//        [_wh_lb release];
    }
    return self;
}

-(void)setWh_badgeString:(NSString *)s{
    if([s isEqualToString:wh_badgeString] && s)
        return;
//    [badgeString release];
//    badgeString = [s retain];
    wh_badgeString = s;
    _wh_lb.hidden = NO;
    if([s intValue]<=0){
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    if([s intValue]>99)
        s = @"99+";

    if([s length]>=3)
        _wh_lb.font = sysFontWithSize(9);
    else
        if([s length]>=2)
            _wh_lb.font = sysFontWithSize(12);
        else
            _wh_lb.font = sysFontWithSize(13);
    _wh_lb.text = s;
    
    CGRect frame = self.frame;
    NSInteger num = s.integerValue;
    if (num < 10) {
        //一位数小红点
        frame.size.width = 17;
    } else if (num < 100){
        //两位数
        frame.size.width = 24;
    } else {
        //三位数
        frame.size.width = 26;
    }
    self.frame = frame;
}

@end
