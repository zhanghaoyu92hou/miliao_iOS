//
//  WH_JXRPacketList_WHCell.m
//  Tigase_imChatT
//
//  Created by Apple on 16/8/31.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXRPacketList_WHCell.h"

@implementation WH_JXRPacketList_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_headerImage headRadiusWithAngle:CGRectGetHeight(_headerImage.frame) / 2.f];
}


- (void)sp_checkNetWorking {
    NSLog(@"Check your Network");
}
@end
