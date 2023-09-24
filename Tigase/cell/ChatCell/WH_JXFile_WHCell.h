//
//  WH_JXFile_WHCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
@interface WH_JXFile_WHCell : WH_JXBaseChat_WHCell
@property (nonatomic,strong) UIImageView * imageBackground;
@property (nonatomic,strong) UILabel * fileNameLabel;

- (void)sp_didUserInfoFailed;
@end
