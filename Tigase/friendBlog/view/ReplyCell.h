//
//  ReplyCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/6/25.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WH_HBCoreLabel.h"
@interface ReplyCell : UITableViewCell
//@property(nonatomic,retain) WH_HBCoreLabel * label;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;

@property(nonatomic,assign) int wh_pointIndex;


- (void)sp_checkNetWorking:(NSString *)isLogin;
@end
