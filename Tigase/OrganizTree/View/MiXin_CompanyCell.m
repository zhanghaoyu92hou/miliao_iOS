//
//  MiXin_CompanyCell.m
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_CompanyCell.h"

@implementation MiXin_CompanyCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _icon = [[UIImageView alloc]initWithFrame:CGRectMake(20, 22, 46, 46)];
        _icon.image = [UIImage imageNamed:@"comlogo"];
        [self.contentView addSubview:_icon];
        
        _name = [self createLab:CGRectMake(80, 22, JX_SCREEN_WIDTH-130, 46) font:sysFontWithSize(16) color:HEXCOLOR(0x333333) text:@""];
        [self.contentView addSubview:_name];
        
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(_name.right, 39, 7, 12)];
        arrow.image = [UIImage imageNamed:@"WH_Back"];
        [self.contentView addSubview:arrow];
    }
    return self;
}

- (void)refresh:(MiXin_CompanyModel *)model {
    _name.text = model.companyName;
    //[_icon sd_setImageWithURL:[NSURL URLWithString:model.companyName]];
   
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
