//
//  WH_JXSearchImageLog_WHCell.m
//  Tigase_imChatT
//
//  Created by p on 2019/4/9.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXSearchImageLog_WHCell.h"
#import "NSString+ContainStr.h"

@interface WH_JXSearchImageLog_WHCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *pauseBtn;

@end

@implementation WH_JXSearchImageLog_WHCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self customViewWithFrame:frame];
    }
    
    return self;
}


- (void)customViewWithFrame:(CGRect)frame{
    self.contentView.clipsToBounds = YES;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.contentView addSubview:self.imageView];
    
    _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    _pauseBtn.center = CGPointMake(self.imageView.frame.size.width/2,self.imageView.frame.size.height/2);
    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"playvideo"] forState:UIControlStateNormal];
    //    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"pausevideo"] forState:UIControlStateSelected];
//    [_pauseBtn addTarget:self action:@selector(showTheVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:_pauseBtn];
}

- (void)setMsg:(WH_JXMessageObject *)msg {
    _msg = msg;
    
    if ([msg.type integerValue] == kWCMessageTypeImage) {
        self.pauseBtn.hidden = YES;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:msg.content] placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
    }else {
        self.pauseBtn.hidden = NO;
        if([self.msg.content isUrl]) {
            [FileInfo getFirstImageFromVideo:self.msg.fileName imageView:self.imageView];
        }else if (isFileExist(self.msg.fileName)) {
            [FileInfo getFirstImageFromVideo:self.msg.fileName imageView:self.imageView];
        }else {
            [FileInfo getFirstImageFromVideo:self.msg.content imageView:self.imageView];
        }
    }
    
}

- (void)showTheVideo {
   
}


- (void)sp_getUsersMostLikedSuccess:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
