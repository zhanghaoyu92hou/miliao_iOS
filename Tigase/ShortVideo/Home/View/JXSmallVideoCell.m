//
//  JXSmallVideoCell.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/1/3.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSmallVideoCell.h"
#import "WH_GKDYVideoModel.h"

@interface JXSmallVideoCell ()
@property (nonatomic, strong) UIImageView *videoImgView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UIButton *likeBtn;

@end

@implementation JXSmallVideoCell




- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        _videoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 316)];
//        _videoImgView.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:_videoImgView];
        
        _detail = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_videoImgView.frame), self.contentView.frame.size.width, 20)];
        _detail.numberOfLines = 3;
        _detail.font = sysFontWithSize(13);
        _detail.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _detail.textColor = [UIColor whiteColor];
        [_videoImgView addSubview:_detail];

        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_videoImgView.frame)+10, 26, 26)];
        _icon.layer.masksToBounds = YES;
        _icon.layer.cornerRadius = _icon.frame.size.width/2;
        [self.contentView addSubview:_icon];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_icon.frame)+3, CGRectGetMinY(_icon.frame)+3, 60, 20)];
        _name.text = MY_USER_NAME;
        _name.font = sysFontWithSize(13);
        _name.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_name];
        
        _likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 70, CGRectGetMinY(_icon.frame)+3, 60, 20)];
        [_likeBtn.titleLabel setFont:sysFontWithSize(13)];
        [_likeBtn setImage:[UIImage imageNamed:@"small_video_heart"] forState:UIControlStateNormal];
        [self.contentView addSubview:_likeBtn];
    }
    
    return self;
}


- (void)dealloc {
    self.videoImgView = nil;
    self.icon = nil;
    self.detail = nil;
    self.name = nil;
    self.likeBtn = nil;
}

- (void)setupDataWithModel:(WH_GKDYVideoModel *)model {
    _videoImgView.image = nil;
    _icon.image = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        [FileInfo getFirstImageFromVideo:model.video_url imageView:_videoImgView];
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
        });

    });
    [g_server WH_getHeadImageLargeWithUserId:model.userId userName:model.author.wh_name_show imageView:_icon];
    _detail.text = model.title;
    _detail.hidden = model.title.length <= 0;
    _name.text = model.author.wh_name_show;
    [_likeBtn setTitle:model.agree_num forState:UIControlStateNormal];
    _detail.frame = CGRectMake(0, CGRectGetMaxY(_videoImgView.frame)-model.height, self.contentView.frame.size.width, model.height);
}





@end
