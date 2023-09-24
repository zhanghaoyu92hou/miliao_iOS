//
//  MiXin_InputCoinAddress_MiXinCell.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_InputCoinAddress_MiXinCell.h"

@implementation MiXin_InputCoinAddress_MiXinCell

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
    _titleLabel.font = sysFontWithSize(17);
    _titleLabel.textColor = HEXCOLOR(0x3A404C);
    
    _inputTF = [[UITextField alloc] init];
    [self.contentView addSubview:_inputTF];
    [_inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        make.height.offset(40);
    }];
    _inputTF.font = sysFontWithSize(17);
    if (@available(iOS 10, *)) {
        _inputTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x999999)}];
    } else {
        [_inputTF setValue:HEXCOLOR(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    }
    [_inputTF addTarget:self action:@selector(inputTFEditChanged:) forControlEvents:UIControlEventEditingChanged];
    _inputTF.backgroundColor = HEXCOLOR(0xF8F8F8);
    _inputTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    _inputTF.leftViewMode = UITextFieldViewModeAlways;
    _inputTF.layer.cornerRadius = 5.f;
    _inputTF.layer.masksToBounds = YES;
    
    _promptLabel = [UILabel new];
    [self.contentView addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_titleLabel);
        make.top.equalTo(_inputTF.mas_bottom).offset(8);
    }];
    _promptLabel.numberOfLines = 0;
    _promptLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
    _promptLabel.textColor = HEXCOLOR(0x8292B3);
}

- (void)inputTFEditChanged:(UITextField *)inputTF{
    if (_onInpuTFEditChanged) {
        _onInpuTFEditChanged(inputTF);
    }
}

@end
