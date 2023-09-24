//
//  WH_FindTableViewCell.m
//  Tigase
//
//  Created by Apple on 2019/6/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_FindTableViewCell.h"

#define Cell_Height 55
#define Cell_Width JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset

@implementation WH_FindTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"cell";
    WH_FindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_FindTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        [cell setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //图标
        self.iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, (Cell_Height - 20)/2, 20, 20)];
        [self addSubview:self.iconImg];
        
        //名称
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImg.frame.origin.x + CGRectGetWidth(self.iconImg.frame) + 20, 0, Cell_Width - self.iconImg.frame.origin.x - CGRectGetWidth(self.iconImg.frame) - 20 - 29, Cell_Height)];
        [self.label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
        [self.label setTextColor:HEXCOLOR(0x3A404C)];
        [self addSubview:self.label];
        
        //图标
        UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(Cell_Width - 19, (Cell_Height - 12)/2, 7, 12)];
        [markImg setImage:[UIImage imageNamed:@"WH_Back"]];
        [self addSubview:markImg];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}



@end
