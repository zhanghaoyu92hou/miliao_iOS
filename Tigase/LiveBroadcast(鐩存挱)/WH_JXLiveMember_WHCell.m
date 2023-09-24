//
//  WH_JXLiveMember_WHCell.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/26.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXLiveMember_WHCell.h"
#import "WH_JXLiveMem_WHObject.h"

@interface WH_JXLiveMember_WHCell ()

@property (nonatomic, strong) UIImageView *headImg;

@end

@implementation WH_JXLiveMember_WHCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self customUI];
    }
    return self;
}

-(void)customUI{
    //专家头像
    _headImg = [[UIImageView alloc] init];
    _headImg.frame = CGRectMake(0, 0, 33, 33);
    _headImg.userInteractionEnabled = NO;
    [_headImg headRadiusWithAngle:_headImg.frame.size.width*0.5];
    
    _headImg.image = [UIImage imageNamed:@"avatar_normal"];
    [self.contentView addSubview:_headImg];
}


-(void)setLiveMemberCelldata:(WH_JXLiveMem_WHObject *)memData{
    [g_server WH_getHeadImageSmallWIthUserId:memData.userId userName:memData.nickName imageView:_headImg];
}

@end
