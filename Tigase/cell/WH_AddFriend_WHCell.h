//
//  WH_AddFriend_WHCell.h
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_CardStyle_WHCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WHSettingCellType) {
    WHSettingCellTypeCommon = 1, // icon title and content accessory
    WHSettingCellTypeIconWithTitle,// icon and title
    WHSettingCellTypeIconWithTextField, //icon and textField
    WHSettingCellTypeTitleWithContent, // title and content
    WHSettingCellTypeTitleWithRightContent, // title and content
};

@interface WH_AddFriend_WHCell : WH_CardStyle_WHCell <UITextFieldDelegate>

@property (nonatomic, assign) WHSettingCellType type;

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;

@property (nonatomic, assign) CGFloat verticalEdge;

@property (nonatomic, copy) void (^onTextFieldReturnKeyPress)(WH_AddFriend_WHCell *cell,UITextField *textField);

@end

NS_ASSUME_NONNULL_END
