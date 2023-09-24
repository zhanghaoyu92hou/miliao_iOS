//
//  WH_JXRemind_WHCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
@interface WH_JXRemind_WHCell : WH_JXBaseChat_WHCell
@property (nonatomic,strong) UILabel* messageRemind;
@property (nonatomic, strong) UIButton *confirmBtn;

- (void)sp_upload;
@end
