//
//  MiXin_forgetPwd_MiXinVC.h
//  wahu_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"


@interface MiXin_forgetPwd_MiXinVC : WH_admob_WHViewController{
    UITextField* _phone;
    UITextField* _oldPwd;
    UITextField* _pwd;
    UITextField* _repeat;
    UITextField* _code;
    UIButton* _send;
    NSString* _smsCode;
    int _seconds;
}

/**
 修改密码
 */
@property (nonatomic, assign) BOOL isModify;
@property (nonatomic, assign) NSInteger forgetType; //!< 忘记/修改密码类型 0 手机号码 1 用户名
@end
