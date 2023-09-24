//
//  WH_JXRecordTB_WHCell.m
//  Tigase_imChatT
//
//  Created by Apple on 16/9/6.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXRecordTB_WHCell.h"

@implementation WH_JXRecordTB_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
//    [_titleLabel release];
//    [_timeLabel release];
//    [_moneyLabel release];
//    [_refundLabel release];
//    [super dealloc];
}

- (void)sp_getUserFollowSuccess {
    NSLog(@"Check your Network");
}
@end
