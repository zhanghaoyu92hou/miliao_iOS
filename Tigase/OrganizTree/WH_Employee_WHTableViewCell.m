//
//  WH_Employee_WHTableViewCell.m
//  Tigase_imChatT
//
//  Created by 1 on 17/5/18.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_Employee_WHTableViewCell.h"

@implementation WH_Employee_WHTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        
        [self customUI];
    }
    return self;
}

-(void)customUI{

    self.backgroundColor = [UIColor whiteColor];
    
    _wh_headImageView = [[UIImageView alloc]init];
    _wh_headImageView.frame = CGRectMake(10,8,30,30);
    [_wh_headImageView headRadiusWithAngle:_wh_headImageView.frame.size.width * 0.5];
    _wh_headImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.contentView addSubview:self.wh_headImageView];

    _wh_customTitleLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(45, 10, 100, 21) text:@"" font:pingFangRegularFontWithSize(15) textColor:[UIColor blackColor] backgroundColor:nil];
    _wh_customTitleLabel.textAlignment = NSTextAlignmentLeft;
    _wh_customTitleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_wh_customTitleLabel];
    
    
    _wh_positionLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetMaxX(_wh_customTitleLabel.frame)+2, CGRectGetMinY(_wh_customTitleLabel.frame), 20, 20) text:@"" font:sysFontWithSize(11) textColor:[UIColor whiteColor] backgroundColor:nil];
    _wh_positionLabel.layer.backgroundColor = [UIColor orangeColor].CGColor;
    _wh_positionLabel.layer.cornerRadius = 5;
    _wh_positionLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_wh_positionLabel];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    
}
- (void)prepareForReuse
{
    [super prepareForReuse];
}
//- (void)willTransitionToState:(UITableViewCellStateMask)state{
//    
//}

- (void)setupWithData:(WH_EmployeObject *)dataObj level:(NSInteger)level
{
    self.wh_customTitleLabel.text = dataObj.nickName;
    self.wh_positionLabel.text = dataObj.position;
    [g_server WH_getHeadImageSmallWIthUserId:dataObj.userId userName:dataObj.nickName imageView:_wh_headImageView];
    self.wh_employObject = dataObj;
    
   
    CGFloat left = 11 + 20 * level;
    
    CGRect titleFrame = self.wh_customTitleLabel.frame;
    CGRect headFrame = self.wh_headImageView.frame;
    headFrame.origin.x = left;
    self.wh_headImageView.frame = headFrame;
    
    CGSize nameSize =[dataObj.nickName sizeWithAttributes:@{NSFontAttributeName:self.wh_customTitleLabel.font}];
    titleFrame.origin.x = left + CGRectGetWidth(_wh_headImageView.frame) + 4;
    titleFrame.size = nameSize;
    self.wh_customTitleLabel.frame = titleFrame;
    self.wh_customTitleLabel.center = CGPointMake(_wh_customTitleLabel.center.x, self.wh_headImageView.center.y);
    
    CGSize positionSize =[dataObj.position sizeWithAttributes:@{NSFontAttributeName:self.wh_positionLabel.font}];
    if (positionSize.width >150)
        positionSize.width = 150;
    self.wh_positionLabel.frame = CGRectMake(CGRectGetMaxX(self.wh_customTitleLabel.frame)+2, CGRectGetMinY(self.wh_customTitleLabel.frame), positionSize.width+4, positionSize.height);
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
