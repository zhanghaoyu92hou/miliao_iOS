//
//  WH_AddBankCard_WHView.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_PopViewInput_WHView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputTF;

@property (nonatomic, copy) void (^onInputTFEditChanged)(UITextField *inputTF);

@end

@interface WH_AddBankCard_WHView : UIView

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) WH_PopViewInput_WHView *namePopView;
@property (nonatomic, strong) WH_PopViewInput_WHView *cardNumPopView;

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIButton *submitBtn;

@property (nonatomic, copy) void (^onClickSubmitBtn)(WH_AddBankCard_WHView *view,UIButton *submitBtn);

@end

NS_ASSUME_NONNULL_END
