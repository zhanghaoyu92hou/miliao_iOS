//
//  WH_ChangeTheBoundPhoneNumber_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/21.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_ChangeTheBoundPhoneNumber_WHViewController : WH_admob_WHViewController<UITextFieldDelegate>

@property (nonatomic ,copy) NSString *topTitle;

@property (nonatomic ,strong) UITextField *phone;
@property (nonatomic ,strong) UIButton *areaCodeBtn;

@property (nonatomic ,strong) UITextField *imgCode;   //图片验证码
@property (nonatomic ,strong) UIButton *graphicButton;

@property (nonatomic ,strong) UIImage *graphicImage;

@property (nonatomic ,assign) NSInteger seconds;
@property (nonatomic ,strong) UIButton *send;
@property (nonatomic ,strong) NSString *smsCode;
@property (nonatomic ,strong) UITextField *code;
@property (nonatomic ,strong) NSString *imgCodeStr; //图片验证码

@property (nonatomic ,strong) UITextField *loginPwsTF;
@property (nonatomic ,strong) UITextField *loginConfirmPwsTF;


@property (nonatomic ,strong)  NSTimer *timer;

@property (nonatomic, assign) BOOL isSendFirst;

@end

NS_ASSUME_NONNULL_END
