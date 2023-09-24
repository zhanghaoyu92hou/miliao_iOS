//
//  MiXin_JXLiveGift_MiXinCell.m
//  shiku_im
//
//  Created by 1 on 17/7/28.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "MiXin_JXLiveGift_MiXinCell.h"

@implementation MiXin_JXLiveGift_MiXinCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self customSubviews];
    }
    return self;
}

-(void)customSubviews{
    self.backgroundColor = [UIColor clearColor];
    _giftImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-75)/2, 0, 75, 65)];
    [self.contentView addSubview:_giftImgView];
    
    _priceLabel = [UIFactory createLabelWith:CGRectMake(0, CGRectGetMaxY(_giftImgView.frame), CGRectGetWidth(self.frame), 20) text:@""];
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.font = g_factory.font13;
    [self.contentView addSubview:_priceLabel];
    
//    _nameLabel = [UIFactory createLabelWith:CGRectMake(0, CGRectGetMaxY(_priceLabel.frame), CGRectGetWidth(self.frame), 20) text:@""];
//    _nameLabel.textAlignment = NSTextAlignmentCenter;
//    _nameLabel.textColor = [UIColor whiteColor];
//    [self.contentView addSubview:_nameLabel];
}

@end
