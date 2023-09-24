//
//  WH_PayCardHeader_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_PayCard_WHCell.h"
#import "UIButton+WH_Button.h"

@implementation WH_PayCard_WHCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor clearColor];
    _titleLabel = [UILabel new];
    [self.bgView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.centerY.offset(0);
    }];
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    _titleLabel.textColor = HEXCOLOR(0x3A404C);
    [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    CGFloat btnWidth = 30 + 6 + 15;
    _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bgView addSubview:_addBtn];
    _addBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 36 - btnWidth, 17, btnWidth, 21);
    [_addBtn setTitleColor:HEXCOLOR(0x969696) forState:UIControlStateNormal];
    _addBtn.titleLabel.font = sysFontWithSize(15);
    _addBtn.userInteractionEnabled = NO;
    [_addBtn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextRight imageTitleSpace:6];
}

- (void)setType:(WH_PayCardType)type{
    if (_type != type) {
        _type = type;
        if (_type == WH_PayCardTypeHeader) {
            _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        } else {
            _titleLabel.font = sysFontWithSize(15);
        }
    }
}

- (void)setAddBtnTitle:(NSString *)addBtnTitle{
    if (_addBtnTitle != addBtnTitle) {
        _addBtnTitle = [addBtnTitle copy];
        
        [_addBtn setTitle:addBtnTitle forState:UIControlStateNormal];
        [_addBtn setImage:[UIImage imageNamed:_type == WH_PayCardTypeHeader ? @"WH_BankRecharge_AddBtn_WHIcon" : @"WH_BankRecharge_Check_WHIcon"] forState:UIControlStateNormal];
        CGFloat btnWidth = [_addBtn sizeThatFits:CGSizeMake(JX_SCREEN_WIDTH, 30)].width;
        _addBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 36 - btnWidth, 17, btnWidth, 21);
        [_addBtn layoutButtonWithEdgeInsetsStyle:_type == WH_PayCardTypeHeader ? LLButtonStyleTextRight : LLButtonStyleTextLeft imageTitleSpace:6];
    }
}

@end
