//
//  MiXin_JXLiveMember_MiXinCell.m
//  shiku_im
//
//  Created by 1 on 17/7/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "MiXin_JXLiveMember_MiXinCell.h"
#import "JXLiveMemObject.h"

@interface MiXin_JXLiveMember_MiXinCell ()

@property (nonatomic, strong) UIImageView *headImg;

@end

@implementation MiXin_JXLiveMember_MiXinCell

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


-(void)setLiveMemberCelldata:(JXLiveMemObject *)memData{
    [g_server getHeadImageSmall:memData.userId userName:memData.nickName imageView:_headImg];
}

@end
