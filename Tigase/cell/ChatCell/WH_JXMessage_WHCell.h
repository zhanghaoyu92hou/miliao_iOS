//
//  MiXin_JXMessage_MiXinCell.h
//  wahu_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBaseChat_WHCell.h"
//添加Cell被长按的处理
#import "QBPlasticPopupMenu.h"

@interface WH_JXMessage_WHCell : WH_JXBaseChat_WHCell{
    
}
@property (nonatomic,strong) WH_JXEmoji * messageConent;
@property (nonatomic, strong) UILabel *timeIndexLabel;

@property (nonatomic, assign) BOOL isDidMsgCell;

- (void)deleteMsg:(WH_JXMessageObject *)msg;


@end
