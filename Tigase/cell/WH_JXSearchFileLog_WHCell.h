//
//  WH_JXSearchFileLog_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXSearchFileLog_WHVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXSearchFileLog_WHCell : UITableViewCell

@property (nonatomic, strong) WH_JXMessageObject *msg;

@property (nonatomic, assign) FileLogType type;



NS_ASSUME_NONNULL_END
- (void)sp_getMediaData;
@end
