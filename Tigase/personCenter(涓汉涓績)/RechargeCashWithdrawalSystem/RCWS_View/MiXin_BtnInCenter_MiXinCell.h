//
//  MiXin_BtnInCenter_MiXinCell.h
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MiXin_BtnInCenter_MiXinCell : UITableViewCell


@property (nonatomic, strong) UIButton *button;

@property (nonatomic, copy) void (^onClickButton)(MiXin_BtnInCenter_MiXinCell *cell,UIButton *button);

@end

NS_ASSUME_NONNULL_END
