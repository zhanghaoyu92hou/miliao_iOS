//
//  WH_JXGif_WHCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
#import "WH_SCGIFImageView.h"
@interface WH_JXGif_WHCell : WH_JXBaseChat_WHCell
@property (nonatomic,strong) WH_SCGIFImageView* gif;

- (void)sp_getUserName;
@end
