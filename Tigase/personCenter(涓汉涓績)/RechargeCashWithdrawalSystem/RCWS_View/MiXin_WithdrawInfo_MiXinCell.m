//
//  MiXin_WithdrawInfo_MiXinCell.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_WithdrawInfo_MiXinCell.h"

@implementation MiXin_WithdrawInfo_MiXinCell

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
        make.centerY.offset(0);
    }];
    _titleLabel.font = sysFontWithSize(14);
    _titleLabel.textColor = HEXCOLOR(0x8292B3);
    
    _copiedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_copiedBtn];
    [_copiedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).offset(22);
        make.centerY.equalTo(_titleLabel);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [_copiedBtn setImage:[UIImage imageNamed:@"MX_MyWallet_Copy"] forState:UIControlStateNormal];
    [_copiedBtn addTarget:self action:@selector(clickCopyBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setIsShowCopy:(BOOL)isShowCopy{
    _isShowCopy = isShowCopy;
    _copiedBtn.hidden = !_isShowCopy;
}

- (void)clickCopyBtn:(UIButton *)copyBtn{
    UIPasteboard*pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _copiedStr;
    
    [GKMessageTool showText:@"已拷贝至剪切板"];
}

@end
