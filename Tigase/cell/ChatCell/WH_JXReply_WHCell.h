//
//  MiXin_JXReply_MiXinCell.h
//  wahu_im
//
//  Created by 1 on 2019/3/30.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WH_JXBaseChat_WHCell.h"
//添加Cell被长按的处理
#import "QBPlasticPopupMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXReply_WHCell : WH_JXBaseChat_WHCell

@property (nonatomic,strong) WH_JXEmoji * messageConent;
@property (nonatomic,strong) WH_JXEmoji * replyConent;
@property (nonatomic, strong) UILabel *timeIndexLabel;
@property (nonatomic, assign) NSInteger timerIndex;
@property (nonatomic, strong) NSTimer *readDelTimer;

@property (nonatomic, assign) BOOL isDidMsgCell;

- (void)deleteMsg:(WH_JXMessageObject *)msg;

@end

NS_ASSUME_NONNULL_END
