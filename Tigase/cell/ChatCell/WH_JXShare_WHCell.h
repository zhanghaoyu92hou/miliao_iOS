//
//  WH_JXShare_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2018/11/3.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXBaseChat_WHCell.h"

@interface WH_JXShare_WHCell : WH_JXBaseChat_WHCell

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subTitle;
@property (nonatomic, strong) UIImageView *shareImage;
@property (nonatomic, strong) UIImageView *skIcon;
@property (nonatomic, strong) UILabel *skLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView * imageBackground;


- (void)sp_getUserFollowSuccess;
@end
