//
//  WH_FindTableViewCell.h
//  Tigase
//
//  Created by Apple on 2019/6/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_FindTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIImageView *iconImg;

@property (nonatomic ,strong) UILabel *label;

+ (instancetype)cellWithTableView:(UITableView *)tableView;




NS_ASSUME_NONNULL_END

@end
