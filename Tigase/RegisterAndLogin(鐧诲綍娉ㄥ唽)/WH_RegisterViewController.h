//
//  WH_Register_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/7/10.
//  Copyright © 2019 Reese. All rights reserved.
// 注册

#import "WH_admob_WHViewController.h"

#import "WH_CountryCodeViewController.h"

#import "WH_ResumeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_RegisterViewController :WH_admob_WHViewController<UITextFieldDelegate >

@property (nonatomic ,assign) NSInteger seconds;
@property (nonatomic ,strong) UIButton *sendSMSButton; //!< 发送验证码按钮
@property (nonatomic ,strong) NSString *smsCode;
@property (nonatomic ,strong) UITextField *smsVerifyTextfield; //!< 短信验证码输入框
@property (nonatomic ,strong) UITextField *phoneTextField; //!< 账号/手机号输入框
@property (nonatomic ,strong) UIButton *areaCodeBtn; //!< 电话国际区号按钮

@property (nonatomic ,strong) UITextField *imgVerifyTextField;   //!< 图片验证码
@property (nonatomic ,strong) UIButton *getGraphicButton; //!< 获取图片验证码按钮

@property (nonatomic ,strong) WH_JXUserObject *user;

@property (nonatomic ,strong) UIImage *graphicImage;

@property (nonatomic ,strong)  NSTimer *timer;

@property (nonatomic ,strong) NSString *imgCodeStr;
@property (nonatomic ,strong) NSString *phoneStr;

@property (nonatomic, assign) BOOL isCheckToSMS;  //!< YES:发送短信处验证手机号  NO:注册处验证手机号
@property (nonatomic, assign) BOOL isSkipSMS;
@property (nonatomic, assign) BOOL isSendFirst;

@property (nonatomic, assign) BOOL isSmsRegister;

@property (nonatomic, strong) NSNumber *iswWxinLogin; //!< 1.QQ 2.微信

@property (nonatomic, assign) BOOL isBindPhonePws;
@property (nonatomic, assign) NSInteger registType; //!< 0 手机号注册， 1用户名注册
@end

NS_ASSUME_NONNULL_END
