//
//  WH_Recharge_TableViewCell.m
//  Tigase
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_Recharge_TableViewCell.h"

@implementation WH_Recharge_TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self customSubviews];
        
    }
    return self;
}

- (void)customSubviews {
    _wh_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wh_checkButton.frame = CGRectMake(20, 20, 20, 20);
    [_wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_unselected"] forState:UIControlStateNormal];
    [_wh_checkButton setImage:[UIImage imageNamed:@"WH_addressbook_selected"] forState:UIControlStateHighlighted];
    _wh_checkButton.userInteractionEnabled = NO;
    [self.contentView addSubview:_wh_checkButton];
    
    _wh_iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_wh_checkButton.frame) + 20, (60 - 25)/2, 25, 25)];
    [self.contentView addSubview:_wh_iconImg];
    
    _wh_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_wh_iconImg.frame) + 12, (60 - 24)/2, 120, 24)];
    [_wh_nameLabel setTextColor:HEXCOLOR(0x3A404C)];
    [_wh_nameLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 17]];
    [self.contentView addSubview:_wh_nameLabel];
}
- (void)setWh_data:(NSDictionary *)wh_data {
    _wh_data = wh_data;
    [_wh_iconImg setImage:[UIImage imageNamed:[wh_data objectForKey:@"icon"]]];
    
    [_wh_nameLabel setText:[wh_data objectForKey:@"name"]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.wh_checkButton.selected = NO;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_getLoginState {
    NSLog(@"Get Info Failed");
}

- (void)sp_getMediaFailed {
    NSLog(@"Get Info Success");
}
@end
