//
//  MiXin_WithdrawStatus_MiXinCell.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_WithdrawStatus_MiXinCell.h"
#import "UIButton+WH_Button.h"

@implementation MiXin_WithdrawStatus_MiXinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_contactBtn];
    _contactBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 16 - 50, 21, 50, 40);
    [_contactBtn setImage:[UIImage imageNamed:@"MX_MyWallet_Contact"] forState:UIControlStateNormal];
    [_contactBtn setTitle:@"联系对方" forState:UIControlStateNormal];
    [_contactBtn addTarget:self action:@selector(clickContactBtn:) forControlEvents:UIControlEventTouchUpInside];
    _contactBtn.titleLabel.font = sysFontWithSize(12);
    [_contactBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    [_contactBtn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextBottom imageTitleSpace:3];
    
    _titleLabel = [UILabel new];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(16);
        make.top.bottom.offset(0);
        make.right.equalTo(_contactBtn.mas_left).offset(-5);
    }];
}

- (void)clickContactBtn:(UIButton *)contactBtn{
    if (_onClickContactBtn) {
        _onClickContactBtn(contactBtn);
    }
}

@end
