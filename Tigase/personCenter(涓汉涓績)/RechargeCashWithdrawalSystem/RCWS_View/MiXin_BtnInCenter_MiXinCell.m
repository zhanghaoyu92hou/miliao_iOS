//
//  MiXin_BtnInCenter_MiXinCell.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_BtnInCenter_MiXinCell.h"

@implementation MiXin_BtnInCenter_MiXinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(16);
        make.right.offset(-16);
        make.centerY.offset(0);
        make.height.offset(44);
    }];
    [_button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    _button.backgroundColor = HEXCOLOR(0x007EFF);
    _button.layer.cornerRadius = 44 / 2.f;
    _button.layer.masksToBounds = YES;
    _button.titleLabel.font = sysFontWithSize(17);
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)clickButton:(UIButton *)button{
    if (_onClickButton) {
        _onClickButton(self,button);
    }
}

@end
