//
//  MiXin_inputPhone_MiXinVC.h
//  wahu_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface MiXin_inputPhone_MiXinVC : WH_admob_WHViewController{
    UITextField* _area;
    UITextField* _phone;
    UITextField* _code;
    UITextField* _pwd;
    UITextField *inviteCode; //邀请码
    UIButton* _send;
    NSString* _smsCode;
    NSString* _imgCodeStr;
    NSString* _phoneStr;
    int _seconds;
}

@end
