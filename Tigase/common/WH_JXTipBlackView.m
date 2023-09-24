//
//  TipBlackView.m
//  Tigase_imChatT
//
//  Created by MacZ on 16/4/18.
//  Copyright (c) 2016年 Reese. All rights reserved.
//

#import "WH_JXTipBlackView.h"

@implementation WH_JXTipBlackView

- (id)initWithTitle:(NSString *)title{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 50)];
    if (self) {
        self.center = CGPointMake(JX_SCREEN_WIDTH/2, JX_SCREEN_HEIGHT/2);
        
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.text = title;
        _titleLabel.backgroundColor = [UIColor blackColor];
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.layer.cornerRadius = _titleLabel.frame.size.height/2;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = sysFontWithSize(14);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.alpha = 0.6;
        [self addSubview:_titleLabel];
//        [_titleLabel release];
    }
    return self;
}

- (void)show{
    [UIView animateWithDuration:1.0 delay:0.6 options:UIViewAnimationOptionTransitionNone animations:^{
        _titleLabel.alpha = 0;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
