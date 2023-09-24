//
//  WH_TopPrompt_WHView.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_TopPrompt_WHView.h"

@implementation WH_TopPrompt_WHView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB(249, 220, 218);
        [self setupUI];
    }
    return self;
}
- (void)setupUI{
    
    _wh_iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_NoInternetPrompt_WHIcon"]];
    [self addSubview:_wh_iconImgView];
    [_wh_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.centerY.offset(0);
    }];
    [_wh_iconImgView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    _wh_accessoryImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_right_arrow"]];
    [self addSubview:_wh_accessoryImgView];
    [_wh_accessoryImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-10);
        make.centerY.offset(0);
    }];
    [_wh_accessoryImgView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    _wh_promptLabel = [UILabel new];
    [self addSubview:_wh_promptLabel];
    [_wh_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_wh_iconImgView.mas_right).offset(10);
        make.top.bottom.offset(0);
        make.right.equalTo(_wh_accessoryImgView.mas_left).offset(-10);
    }];
    _wh_promptLabel.font = sysFontWithSize(15);
    _wh_promptLabel.textColor = HEXCOLOR(0x3A404C);
}



@end
