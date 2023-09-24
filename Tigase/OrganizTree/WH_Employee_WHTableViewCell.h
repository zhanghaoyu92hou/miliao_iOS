//
//  WH_Employee_WHTableViewCell.h
//  Tigase_imChatT
//
//  Created by 1 on 17/5/18.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_EmployeObject.h"

@interface WH_Employee_WHTableViewCell : UITableViewCell

//@property (strong, nonatomic) UILabel *detailedLabel;
@property (strong, nonatomic) UILabel *wh_customTitleLabel;
@property (strong, nonatomic) UIImageView * wh_headImageView;
@property (strong, nonatomic) UILabel * wh_positionLabel;

@property (strong, nonatomic) WH_EmployeObject *wh_employObject;


- (void)setupWithData:(WH_EmployeObject *)dataObj level:(NSInteger)level;

@end
