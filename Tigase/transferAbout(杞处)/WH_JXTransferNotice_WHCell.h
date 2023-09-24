//
//  WH_JXTransferNotice_WHCell.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_JXTransferNoticeModel;

@interface WH_JXTransferNotice_WHCell : UITableViewCell


- (void)setDataWithMsg:(WH_JXMessageObject *)msg model:(id)tModel;


+ (float)getChatCellHeight:(WH_JXMessageObject *)msg;

@end
