//
//  WH_JXSetChatBackground_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/12/8.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@class WH_JXSetChatBackground_WHVC;
@protocol WH_JXSetChatBackground_WHVCDelegate <NSObject>

- (void)setChatBackgroundVC:(WH_JXSetChatBackground_WHVC *)setChatBgVC image:(UIImage *)image;

@end

@interface WH_JXSetChatBackground_WHVC : WH_admob_WHViewController

@property (nonatomic, weak) id<WH_JXSetChatBackground_WHVCDelegate>delegate;
@property (nonatomic, copy) NSString *userId;


- (void)sp_getUsersMostLikedSuccess;
@end
