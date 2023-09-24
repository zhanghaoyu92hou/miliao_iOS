//
//  WH_JXShake_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2018/5/30.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXBaseChat_WHCell.h"

@interface WH_JXShake_WHCell : WH_JXBaseChat_WHCell

@property (nonatomic, strong) UIImageView *shakeImageView;



- (void)sp_getUserName:(NSString *)mediaInfo;
@end
