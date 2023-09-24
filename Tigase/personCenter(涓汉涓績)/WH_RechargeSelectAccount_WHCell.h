//
//  WH_RechargeSelectAccount_WHCell.h
//  Tigase
//
//  Created by lyj on 2019/11/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_RechargeSelectAccount_WHCell : UITableViewCell
@property (nonatomic, strong) id data;
@property (nonatomic, strong) UIImageView   *wh_iconImageView;
@property (nonatomic, strong) UILabel       *wh_withdrawalToAccountLabel;
@property (nonatomic, strong) UIButton      *wh_tapButton;//响应点击的button
@property (nonatomic, copy)   void(^selectAccountBlock)(void);
- (void)loadContent;//加载数据
@end

NS_ASSUME_NONNULL_END
