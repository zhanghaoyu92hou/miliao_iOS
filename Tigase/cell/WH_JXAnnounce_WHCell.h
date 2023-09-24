//
//  WH_JXAnnounce_WHCell.h
//  Tigase_imChatT
//
//  Created by 1 on 2018/8/17.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXAnnounce_WHCell : UITableViewCell

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UILabel *content;



- (void)setCellHeightWithText:(NSString *)text;


- (void)sp_getUsersMostFollowerSuccess;
@end
