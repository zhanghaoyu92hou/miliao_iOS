//
//  WH_JXBadgeView.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 15-1-10.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXBadgeView : WH_JXImageView
    
    
@property (nonatomic, strong) UILabel *wh_lb;
@property (nonatomic, strong) NSString *wh_badgeString;
@property (nonatomic, assign) int wh_fontsize;

@end
