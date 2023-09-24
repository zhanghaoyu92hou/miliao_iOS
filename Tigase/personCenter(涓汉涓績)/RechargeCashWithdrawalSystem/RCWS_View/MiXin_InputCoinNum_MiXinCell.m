//
//  MiXin_InputCoinNum_MiXinCell.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_InputCoinNum_MiXinCell.h"

@implementation MiXin_InputCoinNum_MiXinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _titleLabel = [UILabel new];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(16);
        make.top.offset(15);
        make.right.offset(-16);
    }];
    _titleLabel.textColor = HEXCOLOR(0x3A404C);
    _titleLabel.font = sysFontWithSize(17);
    
    _unitLabel = [UILabel new];
    [self.contentView addSubview:_unitLabel];
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-16);
        make.top.offset(72);
    }];
    _unitLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 18];
    _unitLabel.textColor = HEXCOLOR(0x3A404C);
    [_unitLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _unitLabel.text = @"WA币";
    
    _inputTF = [[UITextField alloc] init];
    [self.contentView addSubview:_inputTF];
    [_inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom).offset(35);
        make.right.equalTo(_unitLabel.mas_left).offset(-15);
        make.height.offset(40);
    }];
    if (@available(iOS 10, *)) {
        _inputTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x999999)}];
    } else {
        [_inputTF setValue:HEXCOLOR(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    }
    _inputTF.font = sysFontWithSize(16);
    [_inputTF addTarget:self action:@selector(inputTFEditChanged:) forControlEvents:UIControlEventEditingChanged];
}
- (void)inputTFEditChanged:(UITextField *)inputTF{
    if (_onInputTFEditChanged) {
        _onInputTFEditChanged(inputTF);
    }
}

@end
