//
//  WH_JXLiveChat_WHCell.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/26.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXMessageObject;

@interface WH_JXLiveChat_WHCell : UITableViewCell

-(void)setLiveChatCellData:(WH_JXMessageObject *)msg;

@end
