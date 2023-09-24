//
//  WH_JXMergeRelay_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2018/7/5.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXBaseChat_WHCell.h"

@interface WH_JXMergeRelay_WHCell : WH_JXBaseChat_WHCell

@property (nonatomic,strong) UIImageView * imageBackground;
@property (nonatomic,strong) UILabel * titleLabel;


- (void)sp_getUsersMostLiked;
@end
