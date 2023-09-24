//
//  WH_SelectBank_WHCell.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_CardStyle_WHCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_SelectBank_WHItem : UICollectionViewCell

@property (nonatomic, strong) UIButton *checkBtn;

@end

@interface WH_SelectBank_WHCell : WH_CardStyle_WHCell

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, copy) void (^onClickItem)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
