//
//  WH_JXLiveGift_WHCell.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/28.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXLiveGift_WHCell.h"

@implementation WH_JXLiveGift_WHCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self customSubviews];
    }
    return self;
}

-(void)customSubviews{
    self.backgroundColor = [UIColor clearColor];
    _wh_giftImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-75)/2, 0, 75, 65)];
    [self.contentView addSubview:_wh_giftImgView];
    
    _wh_priceLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(_wh_giftImgView.frame), CGRectGetWidth(self.frame), 20) text:@""];
    _wh_priceLabel.textAlignment = NSTextAlignmentCenter;
    _wh_priceLabel.textColor = [UIColor whiteColor];
    _wh_priceLabel.font = sysFontWithSize(13);
    [self.contentView addSubview:_wh_priceLabel];
    
//    _nameLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, CGRectGetMaxY(_priceLabel.frame), CGRectGetWidth(self.frame), 20) text:@""];
//    _nameLabel.textAlignment = NSTextAlignmentCenter;
//    _nameLabel.textColor = [UIColor whiteColor];
//    [self.contentView addSubview:_nameLabel];
}

@end
