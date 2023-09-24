//
//  WH_ContactCell.m
//  Tigase
//
//  Created by 政委 on 2020/6/4.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_ContactCell.h"

@implementation WH_ContactCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self customSubviews];
    }
    
    return self;
}

- (void)customSubviews {
    
    //头像
    UIImageView *icon = [[UIImageView alloc] init];
    [self.contentView addSubview:icon];
    icon.contentMode = UIViewContentModeScaleAspectFill;
    icon.layer.cornerRadius = 32.5;
    icon.layer.masksToBounds = YES;
    self.iconImageView = icon;
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.width.height.mas_equalTo(65);
    }];
    //昵称
    UILabel *nick = [[UILabel alloc] init];
    nick.textColor = HEXCOLOR(0x333333);
    nick.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    nick.text = @"昵称：好久不见";
    nick.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:nick];
    self.nicknameLabel = nick;
    [nick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(icon.mas_bottom).offset(10);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(15);
    }];
    //备注
    UILabel *remark = [[UILabel alloc] init];
    remark.textColor = HEXCOLOR(0x333333);
    remark.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
    remark.text = @"备注";
    remark.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:remark];
    self.remarkLabel = remark;
    [remark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(nick.mas_bottom).offset(2);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(15);
    }];
}

@end
