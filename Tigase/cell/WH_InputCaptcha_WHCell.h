//
//  WH_InputCaptcha_WHCell.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_CardStyle_WHCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_InputCaptcha_WHCell : WH_CardStyle_WHCell

@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *captchaBtn;

@end

NS_ASSUME_NONNULL_END
