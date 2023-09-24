//
//  WH_JXRedPacket_WHCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
@class WH_JXChat_WHViewController;
@interface WH_JXRedPacket_WHCell : WH_JXBaseChat_WHCell

@property (nonatomic, strong) WH_JXImageView* imageBackground;
@property (nonatomic,strong) WH_JXEmoji * redPacketGreet;



- (void)sp_getMediaData;
@end
