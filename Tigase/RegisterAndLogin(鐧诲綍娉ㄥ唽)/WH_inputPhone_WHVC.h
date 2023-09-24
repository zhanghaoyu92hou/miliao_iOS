//
//  WH_inputPhone_WHVC.h
//  Tigase_imChatT
//
//  Created by YZK on 19-6-7.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_inputPhone_WHVC : WH_admob_WHViewController{
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


- (void)sp_getUsersMostLikedSuccess;
@end
