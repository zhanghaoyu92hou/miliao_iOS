//
//  WH_JXUserInfo_WHVC.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import "WH_JX_SelectMenuView.h"
#import "JXGoogleMapVC.h"

@class DMScaleTransition;

@interface WH_JXUserInfo_WHVC : WH_admob_WHViewController<LXActionSheetDelegate>{
    UILabel* _name;
    UILabel* _remarkName;
    UILabel* _describe;
    UILabel* _workexp;
    UILabel* _city;
    UILabel* _dip;
    UILabel* _date;
    UILabel* _tel;
    UILabel* _lastTime;
    UILabel* _showNum;
    UILabel* _account;
    UILabel* _label;
    UIImageView* _sex;
    JXLabel *_labelLab;

    UISwitch *_messageFreeSwitch;
    UIView *_baseView;
    
    WH_JXImageView *_describeImgV;
    WH_JXImageView *_lifeImgV;
    WH_JXImageView *_birthdayImgV;
    WH_JXImageView *_lastTImgV;
    WH_JXImageView *_showNImgV;

    double _latitude;
    double _longitude;
    
    WH_JXImageView* _head;
//    WH_JXImageView* _body;

    int _friendStatus;
    NSString*   _xmppMsgId;
    UIButton* _btn; //发消息按钮
    BOOL _deleleMode;
    NSMutableArray * _titleArr;
    DMScaleTransition *_scaleTransition;
    JXGoogleMapVC *_gooMap;
}

@property (nonatomic,strong) WH_JXUserObject* wh_user;
@property (nonatomic,strong) UIView * wh_bgBlackAlpha;
@property (nonatomic,strong) WH_JX_SelectMenuView * wh_selectView;
@property (nonatomic, assign) BOOL wh_isJustShow;
@property (nonatomic, copy) NSString *wh_userId;

@property (nonatomic, assign) int wh_fromAddType;

@property (nonatomic ,strong) UIView *wh_headView; //头部视图

@property (nonatomic ,strong) UIView *wh_markAndTagView;

@property (nonatomic ,strong) UIView *wh_cView ;

@property (nonatomic ,strong) NSNumber *isAddFriend; //是否有权限加好友 1、允许建群 0、禁止建群

@property (nonatomic ,assign) CGFloat cViewOrginY;


@end
