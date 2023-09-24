//
//  WH_JXUserInfo_WHVC.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//  "基本信息"控制器

#import "WH_JXUserInfo_WHVC.h"
//#import "WH_selectTreeVC_WHVC.h"
#import "WH_selectValue_WHVC.h"
#import "WH_selectProvince_WHVC.h"
#import "ImageResize.h"
#import "WH_JXChat_WHViewController.h"
#import "JXLocationVC.h"
#import "JXMapData.h"
#import "WH_JXInputValue_WHVC.h"
#import "FMDatabase.h"
#import "userWeiboVC.h"
#import "WH_JXReportUser_WHVC.h"
#import "WH_JXQRCode_WHViewController.h"
#import "WH_JXImageScroll_WHVC.h"
#import "DMScaleTransition.h"
#import "WH_JXSetLabel_WHVC.h"
#import "WH_JXLabelObject.h"
#import "WH_JXSetNoteAndLabel_WHVC.h"

#import "WH_UserSettingViewController.h"

#define HEIGHT 55
//#define IMGSIZE 150

#define TopHeight 7
#define CellHeight 45

#define TopSpace 12

#define TEXT_FONT [UIFont fontWithName:@"PingFangSC-Regular" size:15]
#define ShowLastLoginTime   0 //0不显示 1显示
#define ShowTelephoneNum    0 //0不显示 1显示

@interface WH_JXUserInfo_WHVC ()<JXReportUserDelegate,UITextFieldDelegate,JXSelectMenuViewDelegate>

@end

@implementation WH_JXUserInfo_WHVC
@synthesize wh_user;

- (id)init
{
    self = [super init];
    if (self) {
        _titleArr = [[NSMutableArray alloc]init];
        _friendStatus = [wh_user.status intValue];
        _latitude  = [wh_user.latitude doubleValue];
        _longitude = [wh_user.longitude doubleValue];
        
        self.wh_isGotoBack   = YES;
        self.title = Localized(@"JX_BaseInfo");
        self.wh_heightFooter = 0;
        self.wh_heightHeader = JX_SCREEN_TOP;
        [self createHeadAndFoot];
        self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
        self.wh_tableBody.scrollEnabled = YES;
        
        if([self.wh_userId isKindOfClass:[NSNumber class]])
            self.wh_userId = [(NSNumber*)self.wh_userId stringValue];
        
        [g_server getUser:self.wh_userId toView:self];

        [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(WH_onSendTimeout:) name:kXMPPSendTimeOut_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(friendPassNotif:) name:kFriendPassNotif object:nil];
        [g_notify addObserver:self selector:@selector(newRequest:) name:kXMPPNewRequest_WHNotifaction object:nil];
        
        [self createViews];
    }
    return self;
}

- (void)createViews {
//    int h = 0;
    self.cViewOrginY = 0;
    NSString* s;
    
    WH_JXImageView * iv;
    
    // 更新头像缓存
    [g_server WH_delHeadImageWithUserId:self.wh_userId];
    
    int Head_height = 126;
    self.wh_headView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), Head_height)];
    self.wh_headView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:self.wh_headView];
    self.wh_headView.layer.cornerRadius = g_factory.cardCornerRadius;
    self.wh_headView.layer.masksToBounds = YES;
    self.wh_headView.layer.borderColor = g_factory.cardBorderColor.CGColor ;
    self.wh_headView.layer.borderWidth = g_factory.cardBorderWithd;
    
    _head = [[WH_JXImageView alloc]initWithFrame:CGRectMake(INSETS*2, INSETS*2, 45, 45)];
    [_head headRadiusWithAngle:_head.frame.size.width* 0.5];
    _head.didTouch = @selector(WH_on_WHHeadImage);
    _head.wh_delegate = self;
    _head.image = [UIImage imageNamed:@"avatar_normal"];
    [self.wh_headView addSubview:_head];
    [g_server WH_getHeadImageLargeWithUserId:self.wh_userId userName:self.wh_user.userNickname imageView:_head];

    // 名字
    _remarkName = [[UILabel alloc] init];
    _remarkName.frame = CGRectMake(CGRectGetMaxX(_head.frame)+INSETS*2, INSETS*2, 70, 20);
    _remarkName.textColor = HEXCOLOR(0x3A404C);
    _remarkName.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    [self.wh_headView addSubview:_remarkName];
    
    _sex = [[UIImageView alloc] init];
    _sex.frame = CGRectMake(CGRectGetMaxX(_remarkName.frame)+3, INSETS*2+3, 14, 14);
    _sex.image = [UIImage imageNamed:@"basic_famale"];
    [self.wh_headView addSubview:_sex];

    // 昵称
    _name = [[UILabel alloc] init];
    _name.textColor = HEXCOLOR(0x969696);
    _name.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    _name.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_NickName"),@"--"];
    [self.wh_headView addSubview:_name];
    
    //通讯号
    _account = [[UILabel alloc] init];
    _account.textColor = HEXCOLOR(0x969696);
    _account.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    _account.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_Communication"),@"--"];
    [self.wh_headView addSubview:_account];
    
    // 地区
    _city = [[UILabel alloc] init];
    _city.textColor = HEXCOLOR(0x969696);
    _city.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    _city.text = [NSString stringWithFormat:@"%@ : %@",@"地区",@"--"];
    [self.wh_headView addSubview:_city];

    self.cViewOrginY = CGRectGetHeight(self.wh_headView.frame) + self.wh_headView.frame.origin.y;
    
    if ([self.wh_userId intValue] != [MY_USER_ID intValue]) {
        //标签
        if (self.wh_markAndTagView) {
            [self.wh_markAndTagView removeFromSuperview];
        }
        self.wh_markAndTagView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, self.cViewOrginY, CGRectGetWidth(self.wh_headView.frame), HEIGHT)];
        [self.wh_tableBody addSubview:self.wh_markAndTagView];
        [self.wh_markAndTagView setBackgroundColor:HEXCOLOR(0xffffff)];
        self.wh_markAndTagView.layer.cornerRadius = g_factory.cardCornerRadius;
        self.wh_markAndTagView.layer.masksToBounds = YES;
        self.wh_markAndTagView.layer.borderWidth = g_factory.cardBorderWithd;
        self.wh_markAndTagView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        
        //JX_SetNotesAndLabels
        iv = [self WH_createMiXinButton:Localized(@"JX_SetNotesAndLabels") drawTop:YES drawBottom:YES must:NO click:@selector(onRemark) superView:self.wh_markAndTagView];
        iv.frame = CGRectMake(0, 0, CGRectGetWidth(self.wh_markAndTagView.frame), HEIGHT);

//        self.cViewOrginY += self.wh_markAndTagView.frame.size.height ;
        
        self.cViewOrginY = CGRectGetHeight(self.wh_markAndTagView.frame) + self.wh_markAndTagView.frame.origin.y;
    }
    self.wh_cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, self.cViewOrginY, CGRectGetWidth(self.wh_headView.frame), 55*4)];
    [self.wh_cView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_tableBody addSubview:self.wh_cView];
    self.wh_cView.layer.cornerRadius = g_factory.cardCornerRadius;
    self.wh_cView.layer.masksToBounds = YES;
    self.wh_cView.layer.borderColor = g_factory.cardBorderColor.CGColor ;
    self.wh_cView.layer.borderWidth = g_factory.cardBorderWithd;
    
    // 生活圈
    iv = [self WH_createMiXinButton:Localized(@"JX_LifeCircle") drawTop:NO drawBottom:YES must:NO click:@selector(onMyBlog) superView:self.wh_cView];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(self.wh_cView.frame), HEIGHT);
    
//    h+=iv.frame.size.height;
    _lifeImgV = iv;
    
    // 生日
    iv = [self WH_createMiXinButton:Localized(@"JX_BirthDay") drawTop:NO drawBottom:YES must:NO click:nil superView:self.wh_cView];
    iv.frame = CGRectMake(0, HEIGHT, CGRectGetWidth(self.wh_cView.frame), HEIGHT);
    _date = [self WH_createLabel:iv default:[TimeUtil formatDate:wh_user.birthday format:@"yyyy-MM-dd"]];
//    h+=iv.frame.size.height;
    _birthdayImgV = iv;

    // 在线时间
    iv = [self WH_createMiXinButton:Localized(@"JX_LastOnlineTime") drawTop:NO drawBottom:YES must:NO click:nil superView:self.wh_cView];
    iv.frame = CGRectMake(0, 2*(HEIGHT), CGRectGetWidth(self.wh_cView.frame), HEIGHT);
    _lastTImgV = iv;
    _lastTime = [self WH_createLabel:iv default:[self dateTimeDifferenceWithStartTime:self.wh_user.lastLoginTime]];
//    h+=iv.frame.size.height;
    
    // 显示手机号
    iv = [self WH_createMiXinButton:Localized(@"JX_MobilePhoneNo.") drawTop:NO drawBottom:YES must:NO click:nil superView:self.wh_cView];
    iv.frame = CGRectMake(0, 3*(HEIGHT), CGRectGetWidth(self.wh_cView.frame), HEIGHT);
    _showNImgV = iv;
    NSLog(@"self.user.telephone:%@" ,self.wh_user.telephone);
    _showNum = [self WH_createLabel:iv default:self.wh_user.telephone];
    
//    h+=iv.frame.size.height;
//
//    h+=INSETS;
    
    _baseView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, self.wh_cView.frame.origin.y + self.wh_cView.frame.size.height + TopSpace , JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 0)];
//    [self.wh_tableBody addSubview:_baseView];
    int h  = 0;

    if ([g_config.isOpenPositionService intValue] == 0) {
        if (!self.wh_isJustShow) {
            iv = [self WH_createMiXinButton:Localized(@"WaHu_JXUserInfo_WaHuVC_Loation") drawTop:YES drawBottom:YES must:NO click:@selector(actionMap) superView:_baseView];
            iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
            h+=iv.frame.size.height;
        }
    }
#pragma mark 消息免打扰
    //        if (_friendStatus == friend_status_friend && ![user.isBeenBlack boolValue]) {
    
    //            iv = [self WH_createMiXinButton:Localized(@"JX_MessageFree") drawTop:NO drawBottom:YES must:NO click:@selector(switchAction:)];
    //            iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    //            h+=iv.frame.size.height;
    //        }
    //@"18938880001"
    if ([g_myself.telephone isEqualToString:@"18938880001"]) {
        
        iv = [self WH_createMiXinButton:Localized(@"JX_MobilePhoneNo.") drawTop:NO drawBottom:YES must:NO click:@selector(callNumber) superView:_baseView];
        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
        
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
        [iv addGestureRecognizer:longTap];
        
        _tel = [[UILabel alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH - INSETS - 20 - 5,HEIGHT-INSETS*2)];
        _tel.userInteractionEnabled = NO;
        _tel.text = s;
        _tel.font = sysFontWithSize(16);
        _tel.textAlignment = NSTextAlignmentRight;
        [iv addSubview:_tel];
        
        NSString *subString = [wh_user.telephone substringToIndex:2];
        if ([subString isEqualToString:@"86"]) {
            NSDate *date = [g_myself.phoneDic objectForKey:[wh_user.telephone substringFromIndex:2]];
            if (date) {
                long long n = (long long)[date timeIntervalSince1970];
                NSString *time = [TimeUtil getTimeStrStyle1:n];
                NSString *str = [NSString stringWithFormat:@"%@,%@:%@",[wh_user.telephone substringFromIndex:2],Localized(@"JX_HaveToDial"),time];
                _tel.text = str;
            }else {
                _tel.text = [wh_user.telephone substringFromIndex:2];
            }
            
        }else {
            _tel.text = wh_user.telephone;
        }
        h+=iv.frame.size.height;
    }
    
    h+=INSETS;
    h+=40;
    
    // && ([g_constant.isAddFriend integerValue] == 1 || _friendStatus == friend_status_friend)
#pragma mark 是否显示添加好友按钮
    if (!self.wh_isJustShow) {
        NSLog(@"g_constant.isAddFriend == %@", g_constant.isAddFriend);
        if(([self.wh_userId intValue] != [MY_USER_ID intValue]) || [g_constant.isAddFriend integerValue] == 1 || [self.wh_user.friends count] > 0){
            _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JX_AddFriend") target:self action:@selector(WH_actionWithAddFriendAction:)];
            _btn.frame = CGRectMake(g_factory.globelEdgeInset, CGRectGetHeight(self.wh_cView.frame) + self.wh_cView.frame.origin.y + TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), 44);
            _btn.layer.masksToBounds = YES;
            _btn.layer.cornerRadius = g_factory.cardCornerRadius;
            [self.wh_tableBody addSubview:_btn];
//            [_baseView addSubview:_btn];
            [self showAddFriend];
            h+=_btn.frame.size.height;
            h+=44;
        }
        
        //如果是自己，则不现实按钮
        // 自己/公众号/厂家不删除
        if (![self.wh_userId isEqualToString:MY_USER_ID] && ![self.wh_userId isEqualToString:CALL_CENTER_USERID] && ![self.wh_userId isEqualToString:@"10004476"]) {
            UIButton *btn = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal" highlight:nil target:self selector:@selector(onMore)];
            btn.frame = CGRectMake(JX_SCREEN_WIDTH-52, JX_SCREEN_TOP - 47, 40, 40);
            [self.wh_tableHeader addSubview:btn];
        }
        
    }
    CGRect frame = _baseView.frame;
    frame.size.height = CGRectGetHeight(self.wh_cView.frame) + self.wh_cView.frame.origin.y + TopSpace ;
    _baseView.frame = frame;
    
    if (self.wh_tableBody.frame.size.height < CGRectGetMaxY(_baseView.frame)+30) {
        self.wh_tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, CGRectGetMaxY(_baseView.frame)+30);
    }
    
//    WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:_userId];
//    [self setUserInfo:user];
}

- (void)newRequest:(NSNotification *)notif {
    [g_server getUser:self.wh_userId toView:self];
}

- (void) setUserInfo:(WH_JXUserObject *)user {
    if (self.wh_user.content) {
        user.content = self.wh_user.content;
    }
    self.wh_user = user;
    
    // 更新用户信息
    [user WH_updateUserNickname];
    
    _friendStatus = [user.status intValue];
    _latitude  = [user.latitude doubleValue];
    _longitude = [user.longitude doubleValue];
    
    // 设置用户名字、备注、通讯号、地区等...
    [self setLabelAndDescribe];
    
    
    
    CGFloat imgOrginY = 0;
    if (ShowLastLoginTime && [user.lastLoginTime intValue] > 0 && [user.userType intValue] != 2) {
        _lastTime.text = [self dateTimeDifferenceWithStartTime:user.lastLoginTime];
        imgOrginY = 3*HEIGHT;
    }else {
        imgOrginY = 2*HEIGHT;
        _lastTImgV.hidden = YES;
        [self.wh_cView setFrame:CGRectMake(g_factory.globelEdgeInset, self.cViewOrginY, CGRectGetWidth(self.wh_headView.frame), 55*3)];
        [_btn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.wh_cView.frame) + TopSpace, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    }
    
    CGFloat viewHight = CGRectGetHeight(self.wh_cView.frame);
    
    if (_friendStatus == friend_status_black) {
        //        self.wh_cView.height = viewHight - 55;
        [_lifeImgV setHidden:YES];
        self.wh_cView.frame = CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.wh_markAndTagView.frame) + TopSpace, CGRectGetWidth(self.wh_headView.frame), viewHight - 55);
        [_birthdayImgV setFrame:CGRectMake(0, 0, CGRectGetWidth(self.wh_cView.frame), HEIGHT)];
        
    }else{
        [_lifeImgV setHidden:NO];
        self.wh_cView.frame = CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.wh_markAndTagView.frame) + TopSpace, CGRectGetWidth(self.wh_headView.frame), viewHight);
        [_birthdayImgV setFrame:CGRectMake(0, CGRectGetMaxY(_lifeImgV.frame), CGRectGetWidth(self.wh_cView.frame), HEIGHT)];
    }
    self.cViewOrginY = CGRectGetMaxY(self.wh_markAndTagView.frame) + TopSpace;
    
    imgOrginY = CGRectGetMaxY(_birthdayImgV.frame);
    
    
    if (g_config.isOpenTelnum.intValue == 1 && user.phone.length > 0 && [user.userType intValue] != 2) {
        _showNum.text = user.phone;
        [_showNImgV setFrame:CGRectMake(0, imgOrginY, CGRectGetWidth(self.wh_cView.frame), HEIGHT)];
    }else {
        _showNImgV.hidden = YES;
        CGFloat vFloat = CGRectGetHeight(self.wh_cView.frame);
        [self.wh_cView setFrame:CGRectMake(g_factory.globelEdgeInset, self.cViewOrginY, CGRectGetWidth(self.wh_headView.frame), vFloat - HEIGHT)];
        [_btn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.wh_cView.frame) + TopSpace, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    }
    
    _btn.frame = CGRectMake(g_factory.globelEdgeInset, CGRectGetHeight(self.wh_cView.frame) + self.wh_cView.frame.origin.y + TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), 44);

    if (self.wh_tableBody.frame.size.height < CGRectGetMaxY(_baseView.frame)+30) {
        self.wh_tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, CGRectGetMaxY(_baseView.frame)+30);
    }

    _date.text = [TimeUtil formatDate:user.birthday format:@"yyyy-MM-dd"];
    
    
    if ([user.offlineNoPushMsg intValue] == 1) {
        [_messageFreeSwitch setOn:YES];
    }else {
        [_messageFreeSwitch setOn:NO];
    }
    
    if (_tel) {
        NSString *subString = [user.telephone substringToIndex:2];
        if ([subString isEqualToString:@"86"]) {
            NSDate *date = [g_myself.phoneDic objectForKey:[user.telephone substringFromIndex:2]];
            if (date) {
                long long n = (long long)[date timeIntervalSince1970];
                NSString *time = [TimeUtil getTimeStrStyle1:n];
                NSString *str = [NSString stringWithFormat:@"%@,%@:%@",[user.telephone substringFromIndex:2],Localized(@"JX_HaveToDial"),time];
                _tel.text = str;
            }else {
                _tel.text = [user.telephone substringFromIndex:2];
            }
            
        }else {
            _tel.text = user.telephone;
        }
    }
    
    [self showAddFriend];
    
    if (([self.wh_userId intValue] == [MY_USER_ID intValue])) {
        [_btn setHidden:YES];
    }else if (([user.userType integerValue] != 2 && [user.userType integerValue] != 4 && [g_constant.isAddFriend integerValue] != 1)) {
        if ([self.wh_user.friends count] <= 0) {
            [_btn setHidden:YES];
        }
    }else{
        if (_btn) {
            [_btn setHidden:NO];
            if ([user.userType integerValue] == 2 || [user.type integerValue] == 4) {
                [_btn setTitle:Localized(@"WaHu_JXUserInfo_WaHuVC_SendMseeage") forState:UIControlStateNormal];
            }
        }else{
            _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JX_AddFriend") target:self action:@selector(WH_actionWithAddFriendAction:)];
            _btn.frame = CGRectMake(g_factory.globelEdgeInset, CGRectGetHeight(self.wh_cView.frame) + self.wh_cView.frame.origin.y + TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), 44);
            _btn.layer.masksToBounds = YES;
            _btn.layer.cornerRadius = g_factory.cardCornerRadius;
            [self.wh_tableBody addSubview:_btn];
            //            [_baseView addSubview:_btn];
            [self showAddFriend];
        }
    }
}

- (void)setLabelAndDescribe {
    NSString* city = [g_constant getAddressForNumber:wh_user.provinceId cityId:wh_user.cityId areaId:wh_user.areaId];

    _remarkName.text = wh_user.remarkName.length > 0 ? wh_user.remarkName : wh_user.userNickname;
    CGSize sizeN = [_remarkName.text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    _remarkName.frame = CGRectMake(CGRectGetMaxX(_head.frame)+INSETS*2, INSETS*2, sizeN.width, 20);
    
    CGFloat viewHieght = CGRectGetHeight(self.wh_headView.frame);
    
    _sex.frame = CGRectMake(CGRectGetMaxX(_remarkName.frame)+3, INSETS*2+3, 14, 14);
    if ([wh_user.sex intValue] == 0) {// 女
        _sex.image = [UIImage imageNamed:@"basic_famale"];
    }else {// 男
        _sex.image = [UIImage imageNamed:@"basic_male"];
    }
    
    if (wh_user.remarkName.length > 0) {
        _name.hidden = NO;
        _name.frame = CGRectMake(CGRectGetMinX(_remarkName.frame), CGRectGetMaxY(_remarkName.frame)+3, 200, 20);
        _account.frame = CGRectMake(CGRectGetMinX(_remarkName.frame), CGRectGetMaxY(_name.frame)+3, 200, 20);
        
        _name.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_NickName"),wh_user.userNickname];
    }else {
        _name.hidden = YES;
//        [self.headView setHeight:CGRectGetHeight(self.headView.frame) - 20];
        
        [self.wh_headView setFrame:CGRectMake(g_factory.globelEdgeInset, TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), viewHieght - 20)];
        
        _account.frame = CGRectMake(CGRectGetMinX(_remarkName.frame), CGRectGetMaxY(_remarkName.frame)+3, 200, 20);
    }
    if (wh_user.account.length > 0) {
        _account.hidden = NO;
        _city.frame = CGRectMake(CGRectGetMinX(_remarkName.frame), CGRectGetMaxY(_account.frame)+3, 200, 20);
        _account.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_Communication"),wh_user.account.length > 0 ? wh_user.account : @"--"];
    }else {
        _account.hidden = YES;
//        [self.headView setHeight:CGRectGetHeight(self.headView.frame) - 20];
        
        [self.wh_headView setFrame:CGRectMake(g_factory.globelEdgeInset, TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), viewHieght - 20)];
        
        _city.frame = CGRectMake(CGRectGetMinX(_remarkName.frame), wh_user.remarkName.length > 0 ? CGRectGetMaxY(_name.frame)+3 :CGRectGetMaxY(_remarkName.frame)+3, 200, 20);
    }
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        _city.text = [NSString stringWithFormat:@"%@ : %@",@"地区",city.length > 0 ? city : @"--"];
    }else{
        _city.text = [NSString stringWithFormat:@"%@ : %@",@"地区", @"--"];
    }
    
    _describe.text = self.wh_user.describe;
    
    CGFloat vHeight = CGRectGetMaxY(self.wh_headView.frame);
//
    if ([self.wh_userId intValue] != [MY_USER_ID intValue]) {
        [self.wh_markAndTagView setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetHeight(self.wh_headView.frame) + TopSpace + TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), HEIGHT)];

        vHeight = CGRectGetMaxY(self.wh_markAndTagView.frame);
        
        self.cViewOrginY = vHeight + TopSpace;
    }
    
    [self.wh_cView setFrame:CGRectMake(g_factory.globelEdgeInset, vHeight + TopSpace, CGRectGetWidth(self.wh_headView.frame), 55*4)];
    [_btn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(self.wh_cView.frame) + TopSpace, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
//
//    [self.cView setHeight:vHeight+TopSpace];
    
    // 标签
    NSMutableArray *array = [[WH_JXLabelObject sharedInstance] fetchLabelsWithUserId:self.wh_user.userId];
    NSMutableString *labelsName = [NSMutableString string];
    for (NSInteger i = 0; i < array.count; i ++) {
        WH_JXLabelObject *labelObj = array[i];
        if (i == 0) {
            [labelsName appendString:labelObj.groupName];
        }else {
            [labelsName appendFormat:@",%@",labelObj.groupName];
        }
    }
    if (labelsName.length > 0 && self.wh_user.describe.length <= 0) {
        _labelLab.text = Localized(@"JX_Label");
        _label.text = labelsName;
        [self updateSubviewFrameIsHide:YES];
        _describeImgV.hidden = YES;
    }
    else if (labelsName.length > 0 && self.wh_user.describe.length > 0) {
        _labelLab.text = Localized(@"JX_Label");
        _label.text = labelsName;
        [self updateSubviewFrameIsHide:NO];
        _describeImgV.hidden = NO;
    }
    else if (self.wh_user.describe.length > 0 && labelsName.length <= 0) {
        _labelLab.text = Localized(@"JX_UserInfoDescribe");
        _label.text = self.wh_user.describe;
        [self updateSubviewFrameIsHide:YES];
        _describeImgV.hidden = YES;
    }
    else {
        _labelLab.text = Localized(@"JX_SetNotesAndLabels");
        _label.text = @"";
        [self updateSubviewFrameIsHide:YES];
        _describeImgV.hidden = YES;
    }

}


- (void)updateSubviewFrameIsHide:(BOOL)isHide {
    
    int y = 0;
    if ([self.wh_userId intValue] == [MY_USER_ID intValue]) {
        y = 233 - 100- TopSpace;
    }else {
        if(isHide) {
            y = 233-HEIGHT;
        }else {
            y = 233;
        }

    }
    
    //HEIGHT
//    _lifeImgV.frame = CGRectMake(g_factory.globelEdgeInset, 126+2*TopSpace+55, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), HEIGHT);
    
    y += HEIGHT;
////    _birthdayImgV.frame = CGRectMake(0, y, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), HEIGHT);
//    if ([user.lastLoginTime intValue] > 0 && [user.userType intValue] != 2){
//        y += HEIGHT;
//        _lastTImgV.frame = CGRectMake(0, y, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), HEIGHT);
//    }
//    if (user.telephone.length > 0 && [user.userType intValue] != 2 && [g_config.regeditPhoneOrName intValue] == 0) {
//        y += HEIGHT;
//        _showNImgV.frame = CGRectMake(0, y, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), HEIGHT);
//    }
    y += HEIGHT;
    _baseView.frame = CGRectMake(0, y+INSETS, JX_SCREEN_WIDTH, _baseView.frame.size.height);

}


- (void)friendPassNotif:(NSNotification *)notif {
    WH_JXFriendObject *user = notif.object;
    if ([user.userId isEqualToString:self.wh_userId]) {
        _friendStatus = friend_status_friend;
        [self showAddFriend];
    }
}

- (void)callNumber {
    NSMutableString* str;
    NSString *subString = [wh_user.telephone substringToIndex:2];
    if ([subString isEqualToString:@"86"]) {
        str = [[NSMutableString alloc]initWithFormat:@"telprompt://%@",[wh_user.telephone substringFromIndex:2]];
        [g_myself insertPhone:[wh_user.telephone substringFromIndex:2] time:[NSDate date]];
        [g_myself.phoneDic setObject:[NSDate date] forKey:[wh_user.telephone substringFromIndex:2]];
        
        NSDate *date = [g_myself.phoneDic objectForKey:[wh_user.telephone substringFromIndex:2]];
        if (date) {
            long long n = (long long)[date timeIntervalSince1970];
            NSString *time = [TimeUtil getTimeStrStyle1:n];
            NSString *str = [NSString stringWithFormat:@"%@,%@:%@",[wh_user.telephone substringFromIndex:2],Localized(@"JX_HaveToDial"),time];
            _tel.text = str;
        }else {
            _tel.text = [wh_user.telephone substringFromIndex:2];
        }
        
    }else {
        str = [[NSMutableString alloc]initWithFormat:@"telprompt://%@",wh_user.telephone];
        [g_myself insertPhone:wh_user.telephone time:[NSDate date]];
        [g_myself.phoneDic setObject:[NSDate date] forKey:wh_user.telephone];
        
        _tel.text = wh_user.telephone;
    }
    
    [g_notify postNotificationName:kNearRefreshCallPhone object:nil];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
}

- (void) longTapAction:(UILongPressGestureRecognizer *)longTap {
    if(longTap.state == UIGestureRecognizerStateBegan)
    {
        NSString *subString = [wh_user.telephone substringToIndex:2];
        if ([subString isEqualToString:@"86"]) {
            [g_myself deletePhone:[wh_user.telephone substringFromIndex:2]];
            [g_myself.phoneDic removeObjectForKey:[wh_user.telephone substringFromIndex:2]];

            _tel.text = [wh_user.telephone substringFromIndex:2];
            
        }else {
            [g_myself deletePhone:wh_user.telephone];
            [g_myself.phoneDic removeObjectForKey:wh_user.telephone];
            
            _tel.text = wh_user.telephone;
        }
        
        [g_notify postNotificationName:kNearRefreshCallPhone object:nil];
    }
}

-(void)switchAction:(UISwitch *) sender{

    if (_friendStatus == friend_status_friend && ![wh_user.isBeenBlack boolValue]) {
        
        int offlineNoPushMsg = sender.isOn;
        [g_server WH_friendsUpdateOfflineNoPushMsgUserId:g_myself.userId toUserId:wh_user.userId offlineNoPushMsg:offlineNoPushMsg toView:self];
    }else {
        [sender setOn:!sender.isOn];
        [g_App showAlert:Localized(@"JX_PleaseAddAsFriendFirst")];
    }
    
}

-(void)WH_on_WHHeadImage{
    [g_server WH_delHeadImageWithUserId:self.wh_user.userId];
    
    WH_JXImageScroll_WHVC * imageVC = [[WH_JXImageScroll_WHVC alloc]init];
    
    imageVC.imageSize = CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_WIDTH);
    
    imageVC.iv = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_WIDTH)];
    
    imageVC.iv.center = imageVC.view.center;
    
    [g_server WH_getHeadImageLargeWithUserId:self.wh_user.userId userName:self.wh_user.userNickname imageView:imageVC.iv];
    
    
    if (@available(iOS 13.0, *)) {
        imageVC.modalPresentationStyle = UIModalPresentationFullScreen;
    }else{
        [self WH_addTransition:imageVC];
    }

    [self presentViewController:imageVC animated:YES completion:^{
        
    }];
    
}

//添加VC转场动画
- (void) WH_addTransition:(WH_JXImageScroll_WHVC *) siv
{
    _scaleTransition = [[DMScaleTransition alloc]init];
    [siv setTransitioningDelegate:_scaleTransition];
    
}

-(void)dealloc{
    NSLog(@"WH_JXUserInfo_WHVC.dealloc");
    [g_notify  removeObserver:self name:kXMPPSendTimeOut_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPReceipt_WHNotifaction object:nil];
    [g_notify removeObserver:self];
    self.wh_user = nil;
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if([aDownload.action isEqualToString:wh_act_AttentionAdd]){//加好友
        int n = [[dict objectForKey:@"type"] intValue];
        if( n==2 || n==4)
            _friendStatus = friend_status_friend;//成为好友，一般是无需验证
//        else
//            _friendStatus = friend_status_see;//单向关注

        if(_friendStatus == friend_status_friend){
            [_wait stop];
            [self doMakeFriend];
        }
        else
            [self doSayHello];
    }
    if ([aDownload.action isEqualToString:wh_act_FriendDel]) {//删除好友
        [self.wh_user doSendMsg:XMPP_TYPE_DELALL content:nil];
    }
    if([aDownload.action isEqualToString:wh_act_BlacklistAdd]){//拉黑
        [self.wh_user doSendMsg:XMPP_TYPE_BLACK content:nil];
    }

    if([aDownload.action isEqualToString:wh_act_FriendRemark]){
        [_wait stop];
        WH_JXUserObject* user1 = [[WH_JXUserObject sharedUserInstance] getUserById:wh_user.userId];
        user1.userNickname = wh_user.remarkName;
        user1.remarkName = wh_user.remarkName;
        user1.describe = wh_user.describe;
        // 修改备注后实时刷新
        [wh_user update];
        [g_notify postNotificationName:kFriendRemark object:user1];
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if([aDownload.action isEqualToString:wh_act_BlacklistDel]){
        [self.wh_user doSendMsg:XMPP_TYPE_NOBLACK content:nil];
    }
    
    if([aDownload.action isEqualToString:wh_act_AttentionDel]){
        [wh_user doSendMsg:XMPP_TYPE_DELSEE content:nil];
    }
    
    if([aDownload.action isEqualToString:wh_act_Report]){
        [_wait stop];
        [g_App showAlert:Localized(@"WaHu_JXUserInfo_WaHuVC_ReportSuccess")];
    }
    
    if([aDownload.action isEqualToString:wh_act_FriendsUpdateOfflineNoPushMsg]){
        [_wait stop];
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        [user insertFriend];
        [self setUserInfo:user];
    }
    
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        [_wait stop];
        return;
    }
    [_wait start];
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click superView:(UIView *)superView{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor clearColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [superView addSubview:btn];
//    [btn release];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = sysFontWithSize(18);
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
//        [p release];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, 130, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    if (@selector(onRemark) == click) {
        _labelLab = p;
    }
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
    
    //这个选择器仅用于判断，之后会修改为不可点击
    SEL check = @selector(switchAction:);
    //创建switch
    if(click == check){
        UISwitch * switchView = [[UISwitch alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 20, 20)];
        if ([title isEqualToString:Localized(@"JX_MessageFree")]) {
            _messageFreeSwitch = switchView;
            if ([wh_user.offlineNoPushMsg intValue] == 1) {
                [_messageFreeSwitch setOn:YES];
            }else {
                [_messageFreeSwitch setOn:NO];
            }
        }
        
        switchView.onTintColor = THEMECOLOR;
        
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn addSubview:switchView];
        //取消调用switchAction
        btn.didTouch = @selector(hideKeyboard);
        
    }else if(click){
//        btn.frame = CGRectMake(btn.frame.origin.x -20, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
        
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(btn.frame) - 12 - 7, (HEIGHT - 12)/2.f, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}

-(UITextField*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = sysFontWithSize(14);
    [parent addSubview:p];
//    [p release];
    return p;
}

-(UILabel*)WH_createLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(200,1,CGRectGetWidth(parent.frame) - 212 ,CGRectGetHeight(parent.frame)-2)];
    p.userInteractionEnabled = NO;
    [p setBackgroundColor:[UIColor whiteColor]];
    p.text = s;
    p.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    p.textColor = HEXCOLOR(0x969696);
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
//    [p release];
    return p;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
#pragma mark - 添加好友操作
-(void)WH_actionWithAddFriendAction:(UIView*)sender{
    
    // 验证XMPP是否在线
    if(g_xmpp.isLogined != 1){
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
    if([wh_user.isBeenBlack boolValue]){
        [g_App showAlert:Localized(@"TO_BLACKLIST")];
        return;
    }
    switch (_friendStatus) {
        case friend_status_black:{
            
            [self onDelBlack];

            
        }
            break;
        case friend_status_none:
        case friend_status_see:
            [g_server WH_addAttentionWithUserId:wh_user.userId fromAddType:self.wh_fromAddType toView:self];
            break;
        case friend_status_friend:{//发消息
            if([wh_user haveTheUser])
                [wh_user insert];
            else
                [wh_user update];
            
            [self actionQuit];
            [g_notify postNotificationName:kActionRelayQuitVC_WHNotification object:nil];
            
            WH_JXChat_WHViewController *chatVC=[WH_JXChat_WHViewController alloc];
            chatVC.title = wh_user.userNickname;
            chatVC.chatPerson = self.wh_user;
            chatVC = [chatVC init];
//            [g_App.window addSubview:chatVC.view];
            [g_navigation pushViewController:chatVC animated:YES];
        }
            break;
    }
}

-(void)doSayHello{//打招呼
    _xmppMsgId = [self.wh_user doSendMsg:XMPP_TYPE_SAYHELLO content:Localized(@"WaHu_JXUserInfo_WaHuVC_Hello")];
}

-(void)WH_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
//    NSLog(@"onSendTimeout");
    [_wait stop];
//    [g_App showAlert:Localized(@"JXAlert_SendFilad")];
    [JXMyTools showTipView:Localized(@"JXAlert_SendFilad")];
}

-(void)newReceipt:(NSNotification *)notifacation{//新回执
//    NSLog(@"newReceipt");
    WH_JXMessageObject *msg     = (WH_JXMessageObject *)notifacation.object;
    if(msg == nil)
        return;
    if(![msg isAddFriendMsg])
        return;
    if(![msg.toUserId isEqualToString:self.wh_user.userId])
        return;
    [_wait stop];
    if([msg.type intValue] == XMPP_TYPE_SAYHELLO){//打招呼
        [g_App showAlert:Localized(@"JXAlert_SayHiOK")];
    }
    
    if([msg.type intValue] == XMPP_TYPE_BLACK){//拉黑
        wh_user.status = [NSNumber numberWithInt:friend_status_black];
        _friendStatus = [wh_user.status intValue];
        [[JXXMPP sharedInstance].blackList addObject:wh_user.userId];
        [wh_user update];
        [self setUserInfo:wh_user];

        [self showAddFriend];
        [g_App showAlert:Localized(@"JXAlert_AddBlackList")];
        
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
//        [WH_JXMessageObject msgWithFriendStatus:user.userId status:_friendStatus];
//        [user notifyDelFriend];
    }
    
    if([msg.type intValue] == XMPP_TYPE_DELSEE){//删除关注，弃用
        _friendStatus = friend_status_none;
        [self showAddFriend];
        [WH_JXMessageObject msgWithFriendStatus:wh_user.userId status:_friendStatus];
        [g_App showAlert:Localized(@"JXAlert_CencalFollow")];
    }
    
    if([msg.type intValue] == XMPP_TYPE_DELALL){//删除好友
        _friendStatus = friend_status_none;
        [self showAddFriend];
        
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
        [g_App showAlert:Localized(@"JXAlert_DeleteFirend")];
    }
    
    if([msg.type intValue] == XMPP_TYPE_NOBLACK){//取消拉黑
        wh_user.status = [NSNumber numberWithInt:friend_status_friend];
        [wh_user WH_updateStatus];
        [self setUserInfo:wh_user];

        _friendStatus = friend_status_friend;
        [self showAddFriend];
        if ([[JXXMPP sharedInstance].blackList containsObject:wh_user.userId]) {
            [[JXXMPP sharedInstance].blackList removeObject:wh_user.userId];
            [WH_JXMessageObject msgWithFriendStatus:wh_user.userId status:friend_status_friend];
        }
        [g_App showAlert:Localized(@"JXAlert_MoveBlackList")];
        
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
    }
    if([msg.type intValue] == XMPP_TYPE_FRIEND){//无验证加好友
        if (![g_myself.telephone isEqualToString:@"18938880001"]) {
            [g_App showAlert:Localized(@"JX_AddSuccess")];
        }
        wh_user.status = [NSNumber numberWithInt:2];
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
    }
}

-(void)showAddFriend{
//    _btn.hidden = NO;
    switch (_friendStatus) {
        case friend_status_hisBlack:
            break;
        case friend_status_black://黑名单则不显示
            [_btn setTitle:Localized(@"WaHu_JXUserInfo_WaHuVC_CancelBlackList") forState:UIControlStateNormal];
            break;
        case friend_status_none:
        case friend_status_see:
            if([wh_user.isBeenBlack boolValue])
                [_btn setTitle:Localized(@"TO_BLACKLIST") forState:UIControlStateNormal];
            else
                [_btn setTitle:Localized(@"JX_AddFriend") forState:UIControlStateNormal];
            break;
        case friend_status_friend:
            if([wh_user.isBeenBlack boolValue])
                [_btn setTitle:Localized(@"TO_BLACKLIST") forState:UIControlStateNormal];
            else
                [_btn setTitle:Localized(@"WaHu_JXUserInfo_WaHuVC_SendMseeage") forState:UIControlStateNormal];
            break;
    }
}

-(void)onMyBlog{
    userWeiboVC* vc = [userWeiboVC alloc];
    vc.user = wh_user;
    vc.wh_isGotoBack = YES;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
    
}

-(void)actionMap{
    
    
    if (_longitude <=0 && _latitude <= 0) {
        [g_App showAlert:Localized(@"JX_NotShareLocation")];
        return;
    }
    
    JXMapData * mapData = [[JXMapData alloc] init];
    mapData.latitude = [NSString stringWithFormat:@"%f",_longitude];
    mapData.longitude = [NSString stringWithFormat:@"%f",_latitude];
    NSArray * locations = @[mapData];
    BOOL isShowGoo = [g_myself.isUseGoogleMap intValue] > 0 ? YES : NO;
    if (isShowGoo) {
        _gooMap = [JXGoogleMapVC alloc] ;
        _gooMap.locations = [NSMutableArray arrayWithArray:locations];
        _gooMap.locationType = JXGooLocationTypeShowStaticLocation;
        _gooMap = [_gooMap init];
        [g_navigation pushViewController:_gooMap animated:YES];
    }else {
        JXLocationVC * vc = [JXLocationVC alloc];
        vc.locations = [NSMutableArray arrayWithArray:locations];
        vc.locationType = JXLocationTypeShowStaticLocation;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }
    
//    JXLocationVC* vc = [JXLocationVC alloc];
//    vc.isSend = NO;
//    vc.locationType = JXLocationTypeShowStaticLocation;
//    NSMutableArray * locationsArray = [[NSMutableArray alloc]init];
//
//    JXMapData* p = [[JXMapData alloc]init];
//    p.latitude = [NSString stringWithFormat:@"%f",_latitude];
//    p.longitude = [NSString stringWithFormat:@"%f",_longitude];
//    p.title = _name.text;
//    p.subtitle = _city.text;
//    [locationsArray addObject:p];
//    vc.locations = locationsArray;
//
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];

}
-(void)reportUserView{
    WH_JXReportUser_WHVC * reportVC = [[WH_JXReportUser_WHVC alloc] init];
    reportVC.user = wh_user;
    reportVC.delegate = self;
//    [g_window addSubview:reportVC.view];
    [g_navigation pushViewController:reportVC animated:YES];
    
}

- (void)report:(WH_JXUserObject *)reportUser reasonId:(NSNumber *)reasonId {
    [g_server WH_reportUserWithToUserId:reportUser.userId roomId:nil webUrl:nil reasonId:reasonId toView:self];
}

- (void)onMore{
    WH_UserSettingViewController *settingVC = [[WH_UserSettingViewController alloc] init];
    settingVC.wh_friendStatus = _friendStatus;
    settingVC.wh_fromAddType = self.wh_fromAddType;
    settingVC.wh_user = self.wh_user;
    [g_navigation pushViewController:settingVC animated:YES];
    
//    int n = _friendStatus;
//    //标题数组
//    [_titleArr removeAllObjects];
//    [_titleArr addObject:Localized(@"WaHu_JXUserInfo_WHVC_Report")];
//    [_titleArr addObject:Localized(@"JX_SetNotesAndDescriptions")];
//    if(n == friend_status_friend){
//        if(n == friend_status_black)
//            [_titleArr addObject:Localized(@"WaHu_JXUserInfo_WHVC_CancelBlackList")];
//        else
//            if(![user.isBeenBlack boolValue]) {
//                [_titleArr addObject:Localized(@"WaHu_JXUserInfo_WHVC_AddBlackList")];
//            }
//        if(![user.isBeenBlack boolValue]){
//            if(n == friend_status_friend)
//                [_titleArr addObject:Localized(@"WaHu_JXUserInfo_WHVC_DeleteFirend")];
//            else
//                [_titleArr addObject:Localized(@"JX_AddFriend")];
//        }
//    }
//
////    //模糊背景
////    _bgBlackAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
////    _bgBlackAlpha.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
////    [self.view addSubview:_bgBlackAlpha];
//////    [_bgBlackAlpha release];
//
//    //自定义View
//    _selectView = [[WH_JX_SelectMenuView alloc] initWithTitle:_titleArr image:@[] cellHeight:CellHeight];
//    _selectView.alpha = 0.0;
//    _selectView.delegate = self;
//    [self.view addSubview:_selectView];
////    [_selectView release];
//    //动画
//    [UIView animateWithDuration:0.3 animations:^{
//        _selectView.alpha = 1;
//    }];
}

- (void)didMenuView:(WH_JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    long n = _friendStatus;//好友状态
//    if(n>[_titleArr count]-1)
//        return;
    switch (index) {
        case 0:
            [self reportUserView];
            [self viewDisMissAction];
            break;
        case 1:
            [self onRemark];
            [self viewDisMissAction];
            break;
        case 2:
            if(n == friend_status_black){
                [self onDelBlack];
                [self viewDisMissAction];
            }else{
                [self onAddBlack];
                [self viewDisMissAction];
            }
            break;
        case 3:
            if(n == friend_status_see || n == friend_status_friend){
                //                [self onCancelSee];
                //                [self viewDisMissAction];
                [self onDeleteFriend];
                [self viewDisMissAction];
            }else{
                [self WH_actionWithAddFriendAction:nil];
                [self viewDisMissAction];
            }
            
            break;
            
        default:
            [self viewDisMissAction];
            break;
    }

}

- (void)viewDisMissAction{
    [UIView animateWithDuration:0.4 animations:^{
        _wh_bgBlackAlpha.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_wh_selectView removeFromSuperview];
        _wh_selectView = nil;
        [_wh_bgBlackAlpha removeFromSuperview];
    }];
}

#pragma mark ---------------创建设置好友备注页面----------------
-(void)onRemark{
//    WH_JXInputValue_WHVC* vc = [WH_JXInputValue_WHVC alloc];
//    vc.value = user.remarkName;
//    vc.title = Localized(@"WaHu_JXUserInfo_WHVC_SetName");
//    vc.delegate  = self;
//    vc.isLimit = YES;
//    vc.didSelect = @selector(onSaveNickName:);
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
    
    WH_JXSetNoteAndLabel_WHVC *vc = [[WH_JXSetNoteAndLabel_WHVC alloc] init];
    vc.title = @"设置备注和标签";
    vc.delegate = self;
    vc.didSelect = @selector(WH_refreshLabel:);
    vc.user = self.wh_user;
    [g_navigation pushViewController:vc animated:YES];
}


- (void)WH_refreshLabel:(WH_JXUserObject *)user {

    self.wh_user.remarkName = user.remarkName;
    self.wh_user.describe = user.describe;
    
//    CGSize sizeN = [user.remarkName sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
//    _remarkName.frame = CGRectMake(_remarkName.frame.origin.x, _remarkName.frame.origin.y, sizeN.width, _remarkName.frame.size.height);
//    _sex.frame = CGRectMake(CGRectGetMaxX(_remarkName.frame)+3, _sex.frame.origin.y, _sex.frame.size.width, _sex.frame.size.height);
//
//    _remarkName.text = user.remarkName.length > 0 ? user.remarkName : user.userNickname;

    [self setLabelAndDescribe];
    
    [g_server WH_setFriendNameWithToUserId:self.wh_user.userId noteName:user.remarkName describe:user.describe toView:self];
}


-(void)onSaveNickName:(WH_JXInputValue_WHVC*)vc{
    _remarkName.text = [NSString stringWithFormat:@"昵称:%@" ,vc.value];
    wh_user.remarkName = vc.value;
    [g_server WH_setFriendNameWithToUserId:wh_user.userId noteName:vc.value describe:nil toView:self];
}

-(void)onAddBlack{
    [g_server WH_addBlacklistWithToUserId:wh_user.userId toView:self];
}

-(void)onDelBlack{
    [g_server WH_delBlacklistWithToUserId:wh_user.userId toView:self];
}

-(void)onCancelSee{
    [g_server WH_delAttentionWithToUserId:wh_user.userId toView:self];
}

-(void)onDeleteFriend{

    [g_server delFriend:wh_user.userId toView:self];
}

-(void)doMakeFriend{
    _friendStatus = friend_status_friend;
    [self.wh_user doSendMsg:XMPP_TYPE_FRIEND content:nil];
    [WH_JXMessageObject msgWithFriendStatus:wh_user.userId status:_friendStatus];
    [self showAddFriend];
}

-(void)showUserQRCode{
    WH_JXQRCode_WHViewController * qrVC = [[WH_JXQRCode_WHViewController alloc] init];
    qrVC.type = QRUserType;
    qrVC.userId = wh_user.userId;
    qrVC.nickName = wh_user.userNickname;
//    [g_window addSubview:qrVC.view];
    [g_navigation pushViewController:qrVC animated:YES];
}

- (NSString *)dateTimeDifferenceWithStartTime:(NSNumber *)compareDate {
    NSInteger timeInterval = [[NSDate date] timeIntervalSince1970] - [compareDate integerValue];
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"%d%@",(int)timeInterval,Localized(@"SECONDS_AGO")];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"MINUTES_AGO")];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_HoursAgo")];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_DaysAgo")];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_MonthAgo")];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld%@",temp,Localized(@"JX_YearsAgo")];
    }
    
    return  result;
}




@end
