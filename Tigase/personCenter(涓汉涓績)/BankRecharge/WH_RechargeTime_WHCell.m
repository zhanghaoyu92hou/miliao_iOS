//
//  WH_RechargeTime_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_RechargeTime_WHCell.h"

@implementation WH_RechargeTime_WHCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor clearColor];
    
    _bgView = [UIView new];
    [self.contentView addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(13, 10, 13, 10));
    }];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = g_factory.cardCornerRadius;
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.borderWidth = g_factory.cardBorderWithd;
    _bgView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    
    _iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_BankRecharge_Time_WHIcon"]];
    [_bgView addSubview:_iconImgView];
    [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(15);
    }];
    
    _promptLabel = [UILabel new];
    [_bgView addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.equalTo(_iconImgView.mas_bottom).offset(8);
    }];
    _promptLabel.textColor = HEXCOLOR(0x8F9CBB);
    _promptLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
    _promptLabel.text = @"请先添加银行卡";
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    
    _timeLabel = [UILabel new];
    [_bgView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_iconImgView);
        make.top.equalTo(_promptLabel.mas_bottom).offset(5);
    }];
    _timeLabel.textColor = HEXCOLOR(0x0093FF);
    _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 20];
}

- (void)startCutdown{
    [self releaseTimer];
    
    _promptLabel.text = @"请在10分钟内完成转账";
    _cutDownIndex = 10*60;
    [self updateTime];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeDown) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timeDown{
    _cutDownIndex --;
    if (_cutDownIndex <= 0) {
        [self releaseTimer];
        if (_onTimerCutToZero) {
            _onTimerCutToZero();
        }
    }
    [self updateTime];
}

- (void)releaseTimer{
    if (_timer) {
        [_timer invalidate], _timer = nil;
    }
}

- (void)updateTime{
    NSInteger min = _cutDownIndex / 60;
    NSInteger sec = _cutDownIndex % 60;
    _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)min,(long)sec];
}

@end
