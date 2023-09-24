//
//  WH_NewRecharge_WHTableViewCell.h
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_NewRecharge_WHTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton * checkButton;

@property (nonatomic ,strong) UIImageView *iconImg;
@property (nonatomic ,strong) UILabel *nameLabel;

@property (nonatomic ,strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
