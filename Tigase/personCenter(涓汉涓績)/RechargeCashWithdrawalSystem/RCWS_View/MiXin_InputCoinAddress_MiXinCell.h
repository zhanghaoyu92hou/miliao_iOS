//
//  MiXin_InputCoinAddress_MiXinCell.h
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MiXin_InputCoinAddress_MiXinCell : UITableViewCell


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputTF;

@property (nonatomic, strong) UILabel *promptLabel;

@property (nonatomic, copy) void (^onInpuTFEditChanged)(UITextField *inputF);

@end

NS_ASSUME_NONNULL_END
