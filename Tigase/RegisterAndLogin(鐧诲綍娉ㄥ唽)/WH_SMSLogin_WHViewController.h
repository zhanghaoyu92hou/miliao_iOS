//
//  WH_SMSLogin_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/7/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

#import "WH_JXLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_SMSLogin_WHViewController : WH_admob_WHViewController<UITextFieldDelegate>

@property (nonatomic ,strong) UITextField *wh_imgCode;   //图片验证码
@property (nonatomic ,strong) UIButton *wh_graphicButton;
@property (nonatomic ,strong) WH_JXUserObject *wh_user;
@property (nonatomic ,strong) UITextField *wh_code;
@property (nonatomic ,strong) UIButton *    wh_send;
@property (nonatomic ,strong) NSString *wh_smsCode;
@property (nonatomic ,assign) NSInteger wh_seconds;
@property (nonatomic ,strong) UITextField *wh_phone;
@property (nonatomic ,strong) UIButton *wh_areaCodeBtn;
@property (nonatomic ,strong) NSTimer *wh_timer;

@property (nonatomic ,copy) NSString *wh_myToken;

@property (nonatomic ,assign) BOOL wh_isFirstLocation;

@property (nonatomic, strong) WH_JXLocation *wh_location;



NS_ASSUME_NONNULL_END
- (void)sp_didUserInfoFailed;
@end
