//
//  WH_UserInfoViewController.h
//  Tigase
//
//  Created by Apple on 2019/6/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

#import "WH_JXUserObject.h"

#import "DMScaleTransition.h"
#import "WH_JXUserObject.h"
#import "JXGoogleMapVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_UserInfoViewController : WH_admob_WHViewController
{
    double _latitude;
    double _longitude;
    
    int _friendStatus;
    NSString*   _xmppMsgId;
    UIButton* _btn;
    BOOL _deleleMode;
    NSMutableArray * _titleArr;
//    DMScaleTransition *_scaleTransition;
    JXGoogleMapVC *_gooMap;
}

@property (nonatomic, copy) NSString *wh_userId;

@property (nonatomic,strong) WH_JXUserObject *wh_user;

@property (nonatomic ,strong) WH_JXImageView *wh_head;
@property (nonatomic ,strong) UILabel *wh_remarkName;
@property (nonatomic ,strong) UIImageView *wh_sex;
@property (nonatomic ,strong) UILabel *wh_name;
@property (nonatomic ,strong) UILabel *wh_account;
@property (nonatomic ,strong) UILabel *wh_city;

@property (nonatomic ,strong) DMScaleTransition *wh_scaleTransition;

@property (nonatomic ,strong) UILabel *wh_birthdayLabel;
@property (nonatomic ,strong) UILabel *wh_lastOnLineTime;
@property (nonatomic ,strong) UILabel *wh_phoneNumLabel;

@property (nonatomic ,strong) UIButton *wh_sendBtn;



NS_ASSUME_NONNULL_END

@end
