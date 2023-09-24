//
//  WH_RechargeBankInfo_WHCell.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_CardStyle_WHCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_RechargeBankInfo_WHCell : WH_CardStyle_WHCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentlabel;
@property (nonatomic, strong) UIButton *copiedBtn;

@property (nonatomic, copy) NSString *copiedStr;
@end

NS_ASSUME_NONNULL_END
