//
//  MiXin_TitleWithContent_MiXinCell.m
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_TitleWithContent_MiXinCell.h"

@implementation MiXin_TitleWithContent_MiXinCell

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
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = sysFontWithSize(16);
    [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _contentLabel = [UILabel new];
    [self.contentView addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-16);
        make.centerY.offset(0);
        make.left.equalTo(_titleLabel.mas_right);
    }];
    _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.textAlignment = NSTextAlignmentRight;
    
    _lineView = [UIView new];
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.right.equalTo(_contentLabel);
        make.bottom.offset(0);
        make.height.offset(0.5);
    }];
    _lineView.backgroundColor = HEXCOLOR(0xDBE0E7);
}

@end
