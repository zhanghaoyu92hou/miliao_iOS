//
//  WH_InputCaptcha_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_InputCaptcha_WHCell.h"

@implementation WH_InputCaptcha_WHCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _captchaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_captchaBtn];
    [_captchaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-10);
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(115, 51));
    }];
    [_captchaBtn setTitleColor:HEXCOLOR(0x8F9CBB) forState:UIControlStateNormal];
    _captchaBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    [_captchaBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    _captchaBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    _captchaBtn.layer.masksToBounds = YES;
    _captchaBtn.layer.borderWidth = 1;
    _captchaBtn.layer.borderColor = HEXCOLOR(0xDBE0E7).CGColor;
    
    UIView *inputBgV = [UIView new];
    [self.contentView addSubview:inputBgV];
    [inputBgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.centerY.offset(0);
        make.height.offset(51);
        make.right.equalTo(_captchaBtn.mas_left).offset(-10);
    }];
    inputBgV.layer.cornerRadius = g_factory.cardCornerRadius;
    inputBgV.layer.masksToBounds = YES;
    inputBgV.layer.borderColor = _captchaBtn.layer.borderColor;
    inputBgV.layer.borderWidth = 1;
    
    _inputTextField = [[UITextField alloc] init];
    [inputBgV addSubview:_inputTextField];
    [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(16);
        make.top.right.bottom.offset(0);
    }];
    if (@available(iOS 10, *)) {
        _inputTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入验证码" attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0xcccccc)}];
    } else {
        [_inputTextField setValue:HEXCOLOR(0xcccccc) forKey:@"_placeholderLabel.textColor"];
    }
    _inputTextField.font = sysFontWithSize(15);
    _inputTextField.placeholder = @"输入验证码";
    [_inputTextField addTarget:self action:@selector(inputTextFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
}
- (void)inputTextFieldEditChanged:(UITextField *)inputTextField{
    
}
@end
