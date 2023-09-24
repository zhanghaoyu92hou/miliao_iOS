//
//  AddressBookFriendCell.m
//  Tigase
//
//  Created by 政委 on 2020/6/3.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "AddressBookFriendCell.h"

@implementation AddressBookFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self customSubviews];
    }
    return self;
}

- (void)customSubviews {
    
    //头像
    UIImageView *icon = [[UIImageView alloc] init];
    [self.contentView addSubview:icon];
    icon.contentMode = UIViewContentModeScaleAspectFill;
    icon.layer.cornerRadius = 17.5;
    icon.layer.masksToBounds = YES;
    self.iconImageView = icon;
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(12.5);
        make.width.height.mas_equalTo(35);
    }];
    //备注
    UILabel *remark = [[UILabel alloc] init];
    remark.textColor = HEXCOLOR(0x3A404C);
    remark.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    remark.text = @"备注";
    [self.contentView addSubview:remark];
    self.remarkLabel = remark;
    [remark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(12);
        make.top.mas_equalTo(7.5);
        make.width.mas_lessThanOrEqualTo(JX_SCREEN_WIDTH - 80);
        make.height.mas_equalTo(20);
    }];
    //昵称
    UILabel *nick = [[UILabel alloc] init];
    nick.textColor = HEXCOLOR(0x969696);
    nick.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    nick.text = @"昵称：好久不见";
    [self.contentView addSubview:nick];
    self.nicknameLabel = nick;
    [nick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(12);
        make.top.mas_equalTo(remark.mas_bottom).offset(5);
        make.width.mas_lessThanOrEqualTo(JX_SCREEN_WIDTH - 80);
        make.height.mas_equalTo(20);
    }];
    //仅有昵称
    UILabel *nickName = [[UILabel alloc] init];
    nickName.textColor = HEXCOLOR(0x3A404C);
    nickName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    nickName.text = @"昵称：好久不见";
    [self.contentView addSubview:nickName];
    self.contentLabel = nickName;
    [nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(12);
        make.top.mas_equalTo(20);
        make.width.mas_lessThanOrEqualTo(JX_SCREEN_WIDTH - 80);
        make.height.mas_equalTo(20);
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 59, JX_SCREEN_WIDTH, 1)];
    line.backgroundColor = HEXCOLOR(0xEBECEF);
    [self.contentView addSubview:line];
    
}
@end
