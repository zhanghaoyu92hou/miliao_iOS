//
//  WH_forgetPwd_WHVC.h
//  Tigase_imChatT
//
//  Created by YZK on 19-6-7.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"


@interface WH_forgetPwd_WHVC : WH_admob_WHViewController{
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
@property (nonatomic, assign) BOOL wh_isModify;

- (void)sp_upload;
@end
