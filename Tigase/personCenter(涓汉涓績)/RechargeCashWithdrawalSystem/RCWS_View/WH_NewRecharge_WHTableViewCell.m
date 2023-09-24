//
//  WH_NewRecharge_WHTableViewCell.m
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_NewRecharge_WHTableViewCell.h"

#define Cell_Height 66

@implementation WH_NewRecharge_WHTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self customSubviews];
        
    }
    return self;
}

- (void)customSubviews {
    _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkButton.frame = CGRectMake(JX_SCREEN_WIDTH - 20 - 16, (Cell_Height - 20)/2, 20, 20);
    [_checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Default"] forState:UIControlStateNormal];
    [_checkButton setImage:[UIImage imageNamed:@"MX_MyWallet_Selected2"] forState:UIControlStateHighlighted];
    _checkButton.userInteractionEnabled = NO;
    [self.contentView addSubview:_checkButton];
    
    _iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(16, (Cell_Height - 25)/2, 25, 25)];
    [self.contentView addSubview:_iconImg];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconImg.frame) + 12, (Cell_Height - 24)/2, 120, 24)];
    [_nameLabel setTextColor:HEXCOLOR(0x3A404C)];
    [_nameLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 17]];
    [self.contentView addSubview:_nameLabel];
}

- (void)setData:(NSDictionary *)data {
    [_iconImg setImage:[UIImage imageNamed:[data objectForKey:@"icon"]]];
    
    [_nameLabel setText:[data objectForKey:@"name"]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.checkButton.selected = NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
