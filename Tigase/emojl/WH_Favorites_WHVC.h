//
//  WH_Favorites_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/9/14.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

@protocol FavoritesVCDelegate <NSObject>

// 发送
- (void) selectFavoritWithString:(NSString *) str;
// 删除
- (void) deleteFavoritWithString:(NSString *) str;

@end

#import <UIKit/UIKit.h>

@interface WH_Favorites_WHVC : UIViewController

@property (nonatomic, weak) id<FavoritesVCDelegate>delegate;

@end
