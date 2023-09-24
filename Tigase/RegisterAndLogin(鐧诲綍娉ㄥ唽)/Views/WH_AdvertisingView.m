//
//  WH_AdvertisingView.m
//  Tigase
//
//  Created by Apple on 2019/10/10.
//  Copyright © 2019 Reese. All rights reserved.
//  启动页的广告图

#import "WH_AdvertisingView.h"

@interface WH_AdvertisingView ()
@property (nonatomic, strong) id adImage; //图片
@property (nonatomic, strong) UIButton *timeButton; //倒计时按钮
@end

@implementation WH_AdvertisingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame withImage:(id)image showSkipButton:(BOOL)isShow {
    self = [super initWithFrame:frame];
    if (self) {
        self.adImage = image;
        self.showSkipButton = isShow;
        [self bulidSubviews];
    }
    return self;
}

- (void)bulidSubviews {
    //广告图
    UIImageView *adImageView = [[UIImageView alloc] initWithFrame:self.frame];
    adImageView.contentMode = UIViewContentModeScaleAspectFill;
    adImageView.clipsToBounds = YES;
    [self addSubview:adImageView];
    if ([self.adImage isKindOfClass:[UIImage class]]) {
        adImageView.image = self.adImage;
    } else if ([self.adImage isKindOfClass:[NSString class]]) {
        [adImageView sd_setImageWithURL:[NSURL URLWithString:self.adImage] placeholderImage:[UIImage new]];
    }
    
    //倒计时按钮
    UIButton *timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    timeButton.frame = CGRectMake(JX_SCREEN_WIDTH - 60, JX_SCREEN_TOP, 40, 40);
    timeButton.layer.cornerRadius = 20;
    timeButton.layer.masksToBounds = YES;
    timeButton.hidden = !self.isShowSkipButton;
    timeButton.backgroundColor = [HEXCOLOR(0X000000) colorWithAlphaComponent:0.3];
    [timeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [timeButton addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    self.timeButton = timeButton;
    [self addSubview:timeButton];
}

- (void)setCountTime:(NSInteger)countTime {
    _countTime = countTime;
    //显示倒计时
    [self.timeButton setTitle:[NSString stringWithFormat:@"%lds", countTime] forState:UIControlStateNormal];
}

#pragma makr -- 跳过
- (void)skipAction {
    
    //调用跳过时机
    if (self.skipAdBlock) {
        self.skipAdBlock();
    }
    //从父视图移除，优化内存
    [self removeFromSuperview];
}

@end
