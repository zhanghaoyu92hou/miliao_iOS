//
//  WH_JXLink_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2017/8/17.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"

@interface WH_JXLink_WHCell : WH_JXBaseChat_WHCell

@property (nonatomic,strong) UIImageView * imageBackground;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UIImageView *headImageView;


- (void)sp_getMediaFailed:(NSString *)mediaCount;
@end
