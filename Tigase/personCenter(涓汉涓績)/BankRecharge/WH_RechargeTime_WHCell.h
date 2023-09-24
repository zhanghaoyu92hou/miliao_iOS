//
//  WH_RechargeTime_WHCell.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_RechargeTime_WHCell : UITableViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger cutDownIndex;

@property (nonatomic, copy) void (^onTimerCutToZero)(void);

- (void)startCutdown;

@end

NS_ASSUME_NONNULL_END
