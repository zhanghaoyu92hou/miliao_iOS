//
//  WH_RechargeBankInfo_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_RechargeBankInfo_WHCell.h"

@implementation WH_RechargeBankInfo_WHCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _titleLabel = [UILabel new];
    [self.bgView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(16);
        make.centerY.offset(0);
        make.width.offset(85);
    }];
    _titleLabel.textColor = HEXCOLOR(0x8F9CBB);
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    
    _copiedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bgView addSubview:_copiedBtn];
    [_copiedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-16);
        make.top.bottom.offset(0);
        make.width.offset(36);
    }];
    [_copiedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_copiedBtn addTarget:self action:@selector(clickCopiedBtn:) forControlEvents:UIControlEventTouchUpInside];
    _copiedBtn.titleLabel.font = sysFontWithSize(16);
    [_copiedBtn setImage:[UIImage imageNamed:@"WH_BankRecharge_Copy_WHIcon"] forState:UIControlStateNormal];
    [_copiedBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _contentlabel = [UILabel new];
    [self.bgView addSubview:_contentlabel];
    [_contentlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right);
        make.right.equalTo(_copiedBtn.mas_left);
        make.top.bottom.offset(0);
    }];
    _contentlabel.textColor = _titleLabel.textColor;
    _contentlabel.font = _titleLabel.font;
}

- (void)clickCopiedBtn:(UIButton *)copiedBtn{
    if (_copiedStr) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _copiedStr;
        
        [GKMessageTool showText:@"已复制到剪切板"];
    }
}

- (void)setCopiedStr:(NSString *)copiedStr{
    _copiedStr = [copiedStr copy];
    _copiedBtn.hidden = !copiedStr;
}

@end
