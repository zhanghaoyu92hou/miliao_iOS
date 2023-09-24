//
//  WH_JXLive_WHCell.m
//  Tigase_imChatT
//
//  Created by MacZ on 2016/10/20.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXLive_WHCell.h"
#import "WH_JXVideoPlayer.h"

@interface WH_JXLive_WHCell ()

@property (nonatomic,strong) UIImageView * coverView;//封面
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *noticeLabel;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UIImageView *playImgV;

@property (nonatomic,strong) WH_JXImageView *headImg;
@property (nonatomic,strong) UILabel * nickNameLabel;

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *livinglabel;


//头像上性别
@property (nonatomic,strong) UIImageView *sexImgview;


@end

@implementation WH_JXLive_WHCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self customViewWithFrame:frame];
    }
    
    return self;
}

- (void)customViewWithFrame:(CGRect)frame{
    self.contentView.clipsToBounds = YES;
    
    _coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-60)];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
//    _coverView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-frame.size.height+60)/2, 0, frame.size.height-60, frame.size.height-60)];
//    _coverView.center = CGPointMake(frame.size.width/2, frame.size.height-60/2);
    _coverView.image = [UIImage imageNamed:@"loading"];
    _coverView.layer.masksToBounds = YES;
    [self.contentView addSubview:_coverView];
    

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _coverView.frame.size.height + 5, frame.size.width - 5*2, 15)];
    _titleLabel.text = @"";
    _titleLabel.font = sysFontWithSize(14);
    _titleLabel.textColor = THEMECOLOR;
    [self.contentView addSubview:_titleLabel];
    
    
    _headImg = [[WH_JXImageView alloc] init];
    _headImg.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 5, 33, 33);
    _headImg.userInteractionEnabled = NO;
    [_headImg headRadiusWithAngle:_headImg.frame.size.width * 0.5];
    
    _headImg.image = [UIImage imageNamed:@"avatar_normal"];
    [self.contentView addSubview:_headImg];
    
//    if (!_sexImgview) {
//        _sexImgview = [[UIImageView alloc] initWithFrame:CGRectMake(_headImg.frame.origin.x+_headImg.frame.size.width-8, _headImg.frame.origin.y-2, 10, 10)];
//        [self.contentView addSubview:_sexImgview];
//    }
    
    _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.frame.origin.x + _headImg.frame.size.width + 5, _headImg.frame.origin.y, 75, 15)];
    _nickNameLabel.text = @"";
    _nickNameLabel.font = sysFontWithSize(12);
    [self.contentView addSubview:_nickNameLabel];


    _timeLabel = [self labelWithTitle:@"--:--" textColor:[UIColor blackColor] font:sysFontWithSize(11)];
    _timeLabel.frame = CGRectMake(_nickNameLabel.frame.origin.x, _nickNameLabel.frame.origin.y+_nickNameLabel.frame.size.height+3, 80, 12);
    [self.contentView addSubview:_timeLabel];

    
    _countLabel = [self labelWithTitle:@"1w" textColor:[UIColor blackColor] font:sysFontWithSize(11)];
    _countLabel.frame = CGRectMake(frame.size.width -85, CGRectGetMinY(_nickNameLabel.frame), 80, 13);
    _countLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_countLabel];
    
    
    _livinglabel = [self labelWithTitle:@"" textColor:[UIColor redColor] font:sysFontWithSize(13)];
    _livinglabel.frame = CGRectMake(frame.size.width -45, CGRectGetMaxY(_countLabel.frame)+3, 45, 15);
    _livinglabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_livinglabel];
    
    _wh_btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _wh_btnDelete.frame = CGRectMake(frame.size.width - 30, 0, 30, 30);
    [_wh_btnDelete setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [_wh_btnDelete setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateHighlighted];
    _wh_btnDelete.hidden = YES;
    [self.contentView addSubview:_wh_btnDelete];
    
}
- (UILabel *)labelWithTitle:(NSString *)title textColor:(UIColor *)color font:(UIFont *)font{
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = color;
    label.font = font;
    
    return label;
}
- (void)doRefreshNearExpert:(NSDictionary *)dict{
    
    if (!dict) {
        return;
    }
    _headImg.wh_delegate = _delegate;
    _headImg.didTouch = _didTouch;
    _wh_btnDelete.hidden = YES;
//    NSString *videoUrl = [[dict objectForKey:@"videoUrl"] rangeOfString:@"http"].location == NSNotFound ? nil : [dict objectForKey:@"videoUrl"];
    
    
    [g_server WH_getHeadImageLargeWithUserId:[dict objectForKey:@"userId"] userName:[dict objectForKey:@"name"] imageView:_coverView];

//    [_imgview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [g_server WH_getHeadImageLargeWithUserId:[dict objectForKey:@"userId"] userName:[dict objectForKey:@"name"] imageView:_headImg];
    
    NSTimeInterval startTime = [[dict objectForKey:@"createTime"] longLongValue];
    _timeLabel.text = [TimeUtil getTimeStrStyle1:startTime];
    
    NSString * titleStr = [dict objectForKey:@"name"];
    if ([dict objectForKey:@"notice"]){
        titleStr = [titleStr stringByAppendingString:@" : "];
        titleStr = [titleStr stringByAppendingString:[dict objectForKey:@"notice"]];
    }
    
    _titleLabel.text = titleStr;
    _nickNameLabel.text = [dict objectForKey:@"nickName"];
    _countLabel.text = [NSString stringWithFormat:@"%ld%@",[[dict objectForKey:@"numbers"] longValue],Localized(@"JXLiveVC_countPeople")];
    if ([dict[@"status"] intValue] == 1){
        _livinglabel.text = Localized(@"JXLive_inLiving");
        _livinglabel.hidden = NO;
    }else{
        _livinglabel.text = @"";
        _livinglabel.hidden = YES;
    }
    
}

@end
