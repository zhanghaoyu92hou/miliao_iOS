//
//  WH_JXTransfer_WHCell.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXBaseChat_WHCell.h"

@interface WH_JXTransfer_WHCell : WH_JXBaseChat_WHCell
@property (nonatomic, strong) WH_JXImageView* imageBackground;



- (void)sp_checkNetWorking:(NSString *)string;
@end
