//
//  WH_CardStyle_WHCell.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WHSettingCellBgRoundType) {
    WHSettingCellBgRoundTypeNone = 1, //no round
    WHSettingCellBgRoundTypeAll, //top and bottom round
    WHSettingCellBgRoundTypeTop, // top round
    WHSettingCellBgRoundTypeBottom, //bottom round
};

@interface WH_CardStyle_WHCell : UITableViewCell

@property (nonatomic, assign) WHSettingCellBgRoundType bgRoundType;

@property (nonatomic, strong) UIView *bgView;

@end

NS_ASSUME_NONNULL_END
