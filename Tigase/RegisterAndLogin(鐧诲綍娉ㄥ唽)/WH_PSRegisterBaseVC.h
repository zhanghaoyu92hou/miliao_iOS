//
//  MiXin_PSRegisterBase_MiXinVC.h
//  wahu_im
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_PSRegisterBaseVC : WH_admob_WHViewController

@property (nonatomic,strong) NSString *resumeId;
@property (nonatomic,strong) WH_JXUserObject *user;
@property (nonatomic,assign) BOOL isSmsRegister;
@property (nonatomic, assign) BOOL isBindPhonePws;
@property (nonatomic ,strong) NSString *inviteCode; //!< 邀请码
@property (nonatomic, strong) NSNumber *iswWxinLogin; //1.微信。2.qq
@property (nonatomic, assign) NSInteger registType; //!< 0 手机号; 1用户名
@property (nonatomic, strong) NSString *smsCode; //!< 短信验证码
@end
