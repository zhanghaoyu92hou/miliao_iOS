//
//  WH_Recharge_TableViewCell.h
//  Tigase
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_Recharge_TableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *wh_checkButton;

@property (nonatomic ,strong) UIImageView *wh_iconImg;
@property (nonatomic ,strong) UILabel *wh_nameLabel;

@property (nonatomic ,strong) NSDictionary *wh_data;



NS_ASSUME_NONNULL_END
- (void)sp_getLoginState;

- (void)sp_getMediaFailed;
@end
