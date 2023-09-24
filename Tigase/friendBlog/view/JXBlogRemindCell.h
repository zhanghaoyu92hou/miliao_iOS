//
//  JXBlogRemindCell.h
//  Tigase_imChatT
//
//  Created by p on 2017/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBlogRemind.h"

@interface JXBlogRemindCell : UITableViewCell

@property (nonatomic, strong) UIView *wh_toplineView;

-(void)WH_doRefresh:(JXBlogRemind *)br;


- (void)sp_checkUserInfo;
@end
