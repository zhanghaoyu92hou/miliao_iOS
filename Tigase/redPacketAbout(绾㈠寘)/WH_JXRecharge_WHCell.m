//
//  WH_JXRecharge_WHCell.m
//  Tigase_imChatT
//
//  Created by 1 on 17/10/30.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXRecharge_WHCell.h"

@implementation WH_JXRecharge_WHCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self customSubviews];
    }
    return self;
}

-(void)customSubviews{
    
//    self.backgroundColor = [UIColor whiteColor];
//    self.contentView.backgroundColor = [UIColor clearColor];
//    //职位信息
//    _bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, JX_SCREEN_WIDTH-20, 80)];
//    _bgView.backgroundColor = [UIColor whiteColor];
//    _bgView.layer.masksToBounds = YES;
//    _bgView.layer.cornerRadius = 5;
//    _bgView.layer.borderWidth = 0.8;
//    _bgView.layer.borderColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor];
//    [self.contentView addSubview:_bgView];
    
    
    _wh_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wh_checkButton.frame = CGRectMake(JX_SCREEN_WIDTH-15-40, 0, 40, 40);
    _wh_checkButton.center = CGPointMake(_wh_checkButton.center.x, 65/2);
    [_wh_checkButton setImage:[UIImage imageNamed:@"unchecked_round"] forState:UIControlStateNormal];
    [_wh_checkButton setImage:[UIImage imageNamed:@"checked_round"] forState:UIControlStateSelected];
    //    _checkButton.tag = index;
    _wh_checkButton.userInteractionEnabled = NO;
    //    [checkButton addTarget:self action:@selector(checkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_wh_checkButton];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _wh_checkButton.frame = CGRectMake(JX_SCREEN_WIDTH-15-40, 0, 40, 40);
    _wh_checkButton.center = CGPointMake(_wh_checkButton.center.x, 65/2);
    [self.contentView bringSubviewToFront:_wh_checkButton];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.wh_checkButton.selected = NO;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)sp_didUserInfoFailed {
    NSLog(@"Get Info Failed");
}
@end
