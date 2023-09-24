//
//  WH_JXCard_WHCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
@class WH_JXChat_WHViewController;
@interface WH_JXCard_WHCell : WH_JXBaseChat_WHCell

@property (nonatomic,strong) UIImageView * imageBackground;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UIImageView * cardHeadImage;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *title;


- (void)sp_getUserFollowSuccess;
@end
