//
//  WH_PayCardHeader_WHCell.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_CardStyle_WHCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WH_PayCardType) {
    WH_PayCardTypeHeader = 1, //头部
    WH_PayCardTypeList,   //列表
};

@interface WH_PayCard_WHCell : WH_CardStyle_WHCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, assign) WH_PayCardType type;

@property (nonatomic, copy) NSString *addBtnTitle; //设置添加按钮标题,要先设置cell.type

@end

NS_ASSUME_NONNULL_END
