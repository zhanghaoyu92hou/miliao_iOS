//
//  WH_AddBankCard_WHView.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AddBankCard_WHView.h"

@implementation WH_PopViewInput_WHView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = HEXCOLOR(0xF6F7FB);
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = HEXCOLOR(0xE8E8EA).CGColor;
    self.layer.borderWidth = 1;
    
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.centerY.offset(0);
    }];
    _titleLabel.textColor = HEXCOLOR(0x3A404C);
    _titleLabel.font = sysFontWithSize(15);
    [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _inputTF = [[UITextField alloc] init];
    [self addSubview:_inputTF];
    [_inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).offset(27);
        make.top.bottom.offset(0);
        make.right.offset(-10);
    }];
    if (@available(iOS 10, *)) {
        _inputTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0xD1D6E0)}];
    } else {
        [_inputTF setValue:HEXCOLOR(0xD1D6E0) forKeyPath:@"_placeholderLabel.textColor"];
    }
    _inputTF.font = sysFontWithSize(15);
    [_inputTF addTarget:self action:@selector(inputTFEditChanged:) forControlEvents:UIControlEventEditingChanged];
}
- (void)inputTFEditChanged:(UITextField *)inputTF{
    if (_onInputTFEditChanged) {
        _onInputTFEditChanged(inputTF);
    }
}

@end

@implementation WH_AddBankCard_WHView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _coverView = [UIView new];
    [self addSubview:_coverView];
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
    _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverView:)]];
    
    _bgView = [UIView new];
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.centerY.offset(0);
        make.height.offset(330);
    }];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 15;
    _bgView.layer.masksToBounds = YES;
    [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBgView:)]];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bgView addSubview:_closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(12);
        make.top.offset(14);
    }];
    [_closeBtn setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];

    _titleLabel = [UILabel new];
    [_bgView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(15);
    }];
    _titleLabel.textColor = HEXCOLOR(0x8C9AB8);
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 18];
    _titleLabel.text = @"添加银行卡";
    
    UIView *lineView = [UIView new];
    [_bgView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.equalTo(_titleLabel.mas_bottom).offset(15);
        make.height.offset(0.5);
    }];
    lineView.backgroundColor = HEXCOLOR(0xE8E8E8);
    
    _namePopView = [[WH_PopViewInput_WHView alloc] initWithFrame:CGRectZero];
    [_bgView addSubview:_namePopView];
    [_namePopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(12);
        make.right.offset(-12);
        make.top.equalTo(lineView.mas_bottom).offset(20);
        make.height.offset(55);
    }];
    _namePopView.titleLabel.text = @"账户姓名";
    _namePopView.inputTF.placeholder = @"请输入账户名字";
    
    _cardNumPopView = [[WH_PopViewInput_WHView alloc] initWithFrame:CGRectZero];
    [_bgView addSubview:_cardNumPopView];
    [_cardNumPopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_namePopView);
        make.top.equalTo(_namePopView.mas_bottom).offset(8);
        make.height.offset(55);
    }];
    _cardNumPopView.titleLabel.text = @"银行卡号";
    _cardNumPopView.inputTF.placeholder = @"请输入银行卡号";
    _cardNumPopView.inputTF.keyboardType = UIKeyboardTypeNumberPad;
    
    _promptLabel = [UILabel new];
    [_bgView addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_namePopView);
        make.top.equalTo(_cardNumPopView.mas_bottom).offset(8);
    }];
    _promptLabel.numberOfLines = 0;
    _promptLabel.font = sysFontWithSize(14);
    _promptLabel.textColor = HEXCOLOR(0x969696);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    _promptLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@"提示：银行卡号请务必输入正确，输入错误将无法到账"attributes: @{NSFontAttributeName: sysFontWithSize(14),NSForegroundColorAttributeName: [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0],NSParagraphStyleAttributeName:style}];
    
    UIView *lineView2 = [UIView new];
    [_bgView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.equalTo(_promptLabel.mas_bottom).offset(20);
        make.height.offset(0.5);
    }];
    lineView2.backgroundColor = lineView.backgroundColor;
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bgView addSubview:_submitBtn];
    [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(12);
        make.right.offset(-12);
        make.top.equalTo(lineView2.mas_bottom).offset(14);
        make.height.offset(44);
    }];
    _submitBtn.backgroundColor = HEXCOLOR(0x0093FF);
    _submitBtn.layer.cornerRadius = 10;
    _submitBtn.layer.masksToBounds = YES;
    [_submitBtn addTarget:self action:@selector(clickSubmitBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
}

- (void)clickCloseBtn{
    [self dismiss];
}

- (void)clickCoverView:(UITapGestureRecognizer *)tap{
    [self dismiss];
}
- (void)clickBgView:(UITapGestureRecognizer *)tap {
    [_cardNumPopView.inputTF resignFirstResponder];
    [_namePopView.inputTF resignFirstResponder];
}

- (void)dismiss{
    [self removeFromSuperview];
}

- (void)clickSubmitBtn:(UIButton *)submitBtn{
    [_cardNumPopView.inputTF resignFirstResponder];
    [_namePopView.inputTF resignFirstResponder];
    
    if ([_namePopView.inputTF.text length] <= 0) {
        [GKMessageTool showText:@"请输入账户名字"];
        return;
    }
    
    if ([_cardNumPopView.inputTF.text length] <= 0) {
        [GKMessageTool showText:@"请输入银行卡号"];
        return;
    }
    
    if (_onClickSubmitBtn) {
        _onClickSubmitBtn(self,submitBtn);
    }
}
@end
