//
//  WH_UserInfoViewController.m
//  Tigase
//
//  Created by Apple on 2019/6/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_UserInfoViewController.h"

#import "WH_JXImageScroll_WHVC.h"
#import "WH_JXSetNoteAndLabel_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXLabelObject.h"
#import "userWeiboVC.h"

#define TopSpace 16

@interface WH_UserInfoViewController ()

@end

@implementation WH_UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _latitude  = [self.wh_user.latitude doubleValue];
    _longitude = [self.wh_user.longitude doubleValue];
    
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
    
//    _pickerArr = @[Localized(@"JX_Forever"), Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear")];
    
    if([self.wh_userId isKindOfClass:[NSNumber class]])
        self.wh_userId = [(NSNumber*)self.wh_userId stringValue];
    
    [g_server getUser:self.wh_userId toView:self];
    
    [self contentView];
    
//    [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
//    [g_notify addObserver:self selector:@selector(WH_onSendTimeout:) name:kXMPPSendTimeOut_WHNotifaction object:nil];
//    [g_notify addObserver:self selector:@selector(friendPassNotif:) name:kFriendPassNotif object:nil];
//    [g_notify addObserver:self selector:@selector(newRequest:) name:kXMPPNewRequest_WHNotifaction object:nil];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
//    if([aDownload.action isEqualToString:wh_act_AttentionAdd]){//加好友
//        int n = [[dict objectForKey:@"type"] intValue];
//        if( n==2 || n==4)
//            _friendStatus = friend_status_friend;//成为好友，一般是无需验证
//        //        else
//        //            _friendStatus = friend_status_see;//单向关注
//
//        if(_friendStatus == friend_status_friend){
//            [_wait stop];
//            [self doMakeFriend];
//        }
//        else
//            [self doSayHello];
//    }
    if ([aDownload.action isEqualToString:wh_act_FriendDel]) {//删除好友
        [self.wh_user doSendMsg:XMPP_TYPE_DELALL content:nil];
    }
    if([aDownload.action isEqualToString:wh_act_BlacklistAdd]){//拉黑
        [self.wh_user doSendMsg:XMPP_TYPE_BLACK content:nil];
    }
    
    if([aDownload.action isEqualToString:wh_act_FriendRemark]){
        [_wait stop];
        WH_JXUserObject* user1 = [[WH_JXUserObject sharedUserInstance] getUserById:self.wh_user.userId];
        user1.userNickname = self.wh_user.remarkName;
        user1.remarkName = self.wh_user.remarkName;
        user1.describe = self.wh_user.describe;
        // 修改备注后实时刷新
        [self.wh_user update];
        [g_notify postNotificationName:kFriendRemark object:user1];
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if([aDownload.action isEqualToString:wh_act_BlacklistDel]){
        [self.wh_user doSendMsg:XMPP_TYPE_NOBLACK content:nil];
    }
    
    if([aDownload.action isEqualToString:wh_act_AttentionDel]){
        [self.wh_user doSendMsg:XMPP_TYPE_DELSEE content:nil];
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

- (void)contentView {
//    int h = 0;
//    NSString* s;
    
//    WH_JXImageView * iv;
//
    // 更新头像缓存
    [g_server WH_delHeadImageWithUserId:self.wh_userId];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, TopSpace, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset), 126)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:headView];
    headView.layer.cornerRadius = g_factory.cardCornerRadius;
    headView.layer.masksToBounds = YES;
    headView.layer.borderColor = g_factory.cardBorderColor.CGColor ;
    headView.layer.borderWidth = g_factory.cardBorderWithd;
    
    _wh_head = [[WH_JXImageView alloc]initWithFrame:CGRectMake(INSETS*2, INSETS*2, 45, 45)];
    [_wh_head headRadiusWithAngle:_wh_head.frame.size.width* 0.5];
    _wh_head.didTouch = @selector(WH_on_WHHeadImage);
    _wh_head.wh_delegate = self;
    _wh_head.image = [UIImage imageNamed:@"avatar_normal"];
    [headView addSubview:_wh_head];
    [g_server WH_getHeadImageLargeWithUserId:self.wh_userId userName:self.wh_user.userNickname imageView:_wh_head];
    
    // 名字
     _wh_remarkName = [[UILabel alloc] init];
    //     _wh_remarkName.font = [UIFont boldSystemFontOfSize:16];
    //     _wh_remarkName.textColor = [UIColor blackColor];
     _wh_remarkName.frame = CGRectMake(CGRectGetMaxX(_wh_head.frame)+INSETS*2, INSETS*2, 70, 20);
    //     _wh_remarkName.text = @"哈哈哈哈";
     _wh_remarkName.textColor = HEXCOLOR(0x969696);
     _wh_remarkName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [headView addSubview: _wh_remarkName];
    
    _wh_sex = [[UIImageView alloc] init];
    _wh_sex.frame = CGRectMake(CGRectGetMaxX( _wh_remarkName.frame)+3, INSETS*2+3, 14, 14);
    _wh_sex.image = [UIImage imageNamed:@"basic_famale"];
    [headView addSubview:_wh_sex];
    
    // 昵称
    _wh_name = [[UILabel alloc] init];
    //    _wh_name.font = sysFontWithSize(15);
    //    _wh_name.textColor = [UIColor grayColor];
    _wh_name.textColor = HEXCOLOR(0x969696);
    _wh_name.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    _wh_name.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_NickName"),@"--"];
    [headView addSubview:_wh_name];
    
    //通讯号
    _wh_account = [[UILabel alloc] init];
    //    _wh_account.font = sysFontWithSize(15);
    //    _wh_account.textColor = [UIColor grayColor];
    _wh_account.textColor = HEXCOLOR(0x969696);
    _wh_account.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    _wh_account.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_Communication"),@"--"];
    [headView addSubview:_wh_account];
    
    // 地区
    _wh_city = [[UILabel alloc] init];
    //    _wh_city.font = sysFontWithSize(15);
    //    _wh_city.textColor = [UIColor grayColor];
    _wh_city.textColor = HEXCOLOR(0x969696);
    _wh_city.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    _wh_city.text = [NSString stringWithFormat:@"%@ : %@",@"地区",@"--"];
    [headView addSubview:_wh_city];
    
    UIImageView *nexImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(headView.frame) - 29, (CGRectGetHeight(headView.frame) - 12)/2, 7, 12)];
    [nexImg setImage:[UIImage imageNamed:@"WH_Back"]];
    [headView addSubview:nexImg];
    
    //设置备注和标签
    UIView *markAndTagView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetHeight(headView.frame) + 2*TopSpace, CGRectGetWidth(headView.frame), 55)];
    [self.wh_tableBody addSubview:markAndTagView];
    [markAndTagView setBackgroundColor:HEXCOLOR(0xffffff)];
    markAndTagView.layer.cornerRadius = g_factory.cardCornerRadius;
    markAndTagView.layer.masksToBounds = YES;
    markAndTagView.layer.borderWidth = g_factory.cardBorderWithd;
    markAndTagView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    
    UIButton *pyqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pyqBtn setFrame:CGRectMake(0, 0, CGRectGetWidth(markAndTagView.frame), CGRectGetHeight(markAndTagView.frame))];
    [markAndTagView addSubview:pyqBtn];
    [pyqBtn addTarget:self action:@selector(whSetMarkAndSign) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *pyqLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(pyqBtn.frame) - 50, CGRectGetHeight(pyqBtn.frame))];
    [pyqLabel setText:Localized(@"JX_SetNotesAndLabels")];
    [pyqLabel setTextColor:HEXCOLOR(0x3A404C)];
    [pyqLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    [pyqBtn addSubview:pyqLabel];
    
    UIImageView *nexImg2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(pyqBtn.frame) - 29, (CGRectGetHeight(pyqBtn.frame) - 12)/2, 7, 12)];
    [nexImg2 setImage:[UIImage imageNamed:@"WH_Back"]];
    [markAndTagView addSubview:nexImg2];
    
    UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetHeight(markAndTagView.frame) + markAndTagView.frame.origin.y + TopSpace, CGRectGetWidth(markAndTagView.frame), 55*4)];
    [self.wh_tableBody addSubview:cView];
    [cView setBackgroundColor:HEXCOLOR(0xffffff)];
    cView.layer.cornerRadius = g_factory.cardCornerRadius;
    cView.layer.masksToBounds = YES;
    cView.layer.borderWidth = g_factory.cardBorderWithd;
    cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    
    NSArray *nArray = @[Localized(@"JX_LifeCircle") ,Localized(@"JX_BirthDay") ,Localized(@"JX_LastOnlineTime") ,Localized(@"JX_MobilePhoneNo.")];
    for (int i = 0; i < nArray.count; i++) {
        if ( i == 0) {
            UIButton *pBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [pBtn setFrame:CGRectMake(0, 0, (CGRectGetWidth(cView.frame)), 55)];
            [cView addSubview:pBtn];
            [pBtn addTarget:self action:@selector(onMyBlog) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(pBtn.frame) - 50, CGRectGetHeight(pBtn.frame))];
            [pLabel setText:[nArray objectAtIndex:i]];
            [pLabel setTextColor:HEXCOLOR(0x3A404C)];
            [pLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
            [pBtn addSubview:pLabel];
            
            UIImageView *nexImg3 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(pBtn.frame) - 29, (CGRectGetHeight(pBtn.frame) - 12)/2, 7, 12)];
            [nexImg3 setImage:[UIImage imageNamed:@"WH_Back"]];
            [pBtn addSubview:nexImg3];
        }else{
            UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, i*55, (CGRectGetWidth(cView.frame)), 55)];
            [cView addSubview:lView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(lView.frame)/2 - 20, 55)];
            [label setText:[nArray objectAtIndex:i]];
            [label setTextColor:HEXCOLOR(0x3A404C)];
            [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
            [lView addSubview:label];
            
            if (i == 1) {
                //出生日期
                self.wh_birthdayLabel = [self wh_CreateLabel:lView default:[TimeUtil formatDate:self.wh_user.birthday format:@"yyyy-MM-dd"]];
            }else if (i == 2) {
                //在线时间
                //[self WH_createLabel:iv default:[self dateTimeDifferenceWithStartTime:self.wh_user.lastLoginTime]];
                self.wh_lastOnLineTime = [self wh_CreateLabel:lView default:[self dateTimeDifferenceWithStartTime:self.wh_user.lastLoginTime]];
            }else{
                //手机号
                self.wh_phoneNumLabel = [self wh_CreateLabel:lView default:self.wh_user.telephone];
            }
        }
    }
    
    //发送消息界面
    self.wh_sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.wh_sendBtn setFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetHeight(cView.frame) + cView.frame.origin.y + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44)];
    [self.wh_sendBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    [self.wh_sendBtn setTitle:@"发送消息" forState:UIControlStateNormal];
    [self.wh_sendBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [self.wh_sendBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [self.wh_tableBody addSubview:self.wh_sendBtn];
    self.wh_sendBtn.layer.cornerRadius = 10;
    [self.wh_sendBtn addTarget:self action:@selector(sendMethod) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 头像点击事件
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
    _wh_scaleTransition = [[DMScaleTransition alloc] init];
    [siv setTransitioningDelegate:_wh_scaleTransition];
    
}

#pragma mark 备注和标签
- (void)whSetMarkAndSign {
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
    [self setLabelAndDescribe];
    
    [g_server WH_setFriendNameWithToUserId:self.wh_user.userId noteName:user.remarkName describe:user.describe toView:self];
}

- (void)setLabelAndDescribe {
    NSString* city = [g_constant getAddressForNumber:self.wh_user.provinceId cityId:self.wh_user.cityId areaId:self.wh_user.areaId];
    
     _wh_remarkName.text = self.wh_user.remarkName.length > 0 ? self.wh_user.remarkName : self.wh_user.userNickname;
    CGSize sizeN = [ _wh_remarkName.text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
     _wh_remarkName.frame = CGRectMake(CGRectGetMaxX(_wh_head.frame)+INSETS*2, INSETS*2, sizeN.width, 20);
    
    _wh_sex.frame = CGRectMake(CGRectGetMaxX( _wh_remarkName.frame)+3, INSETS*2+3, 14, 14);
    if ([self.wh_user.sex intValue] == 0) {// 女
        _wh_sex.image = [UIImage imageNamed:@"basic_famale"];
    }else {// 男
        _wh_sex.image = [UIImage imageNamed:@"basic_male"];
    }
    
    if (self.wh_user.remarkName.length > 0) {
        _wh_name.hidden = NO;
        _wh_name.frame = CGRectMake(CGRectGetMinX( _wh_remarkName.frame), CGRectGetMaxY( _wh_remarkName.frame)+3, 200, 20);
        _wh_account.frame = CGRectMake(CGRectGetMinX( _wh_remarkName.frame), CGRectGetMaxY(_wh_name.frame)+3, 200, 20);
        
        _wh_name.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_NickName"),self.wh_user.userNickname];
    }else {
        _wh_name.hidden = YES;
        _wh_account.frame = CGRectMake(CGRectGetMinX( _wh_remarkName.frame), CGRectGetMaxY( _wh_remarkName.frame)+3, 200, 20);
    }
    if (self.wh_user.account.length > 0) {
        _wh_account.hidden = NO;
        _wh_city.frame = CGRectMake(CGRectGetMinX( _wh_remarkName.frame), CGRectGetMaxY(_wh_account.frame)+3, 200, 20);
        _wh_account.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_Communication"),self.wh_user.account.length > 0 ? self.wh_user.account : @"--"];
    }else {
        _wh_account.hidden = YES;
        _wh_city.frame = CGRectMake(CGRectGetMinX( _wh_remarkName.frame), self.wh_user.remarkName.length > 0 ? CGRectGetMaxY(_wh_name.frame)+3 :CGRectGetMaxY( _wh_remarkName.frame)+3, 200, 20);
    }
    
    _wh_city.text = [NSString stringWithFormat:@"%@ : %@",@"地区",city.length > 0 ? city : @"--"];
    
    
//    _describe.text = self.wh_user.describe;
    
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
//    if (labelsName.length > 0 && self.wh_user.describe.length <= 0) {
//        _labelLab.text = Localized(@"JX_Label");
//        _label.text = labelsName;
////        [self updateSubviewFrameIsHide:YES];
//        _describeImgV.hidden = YES;
//    }
//    else if (labelsName.length > 0 && self.wh_user.describe.length > 0) {
//        _labelLab.text = Localized(@"JX_Label");
//        _label.text = labelsName;
////        [self updateSubviewFrameIsHide:NO];
//        _describeImgV.hidden = NO;
//    }
////    else if (self.wh_user.describe.length > 0 && labelsName.length <= 0) {
////        _labelLab.text = Localized(@"JX_UserInfoDescribe");
////        _label.text = self.wh_user.describe;
//////        [self updateSubviewFrameIsHide:YES];
////        _describeImgV.hidden = YES;
////    }
//    else {
//        _labelLab.text = Localized(@"JX_SetNotesAndLabels");
//        _label.text = @"";
//        [self updateSubviewFrameIsHide:YES];
//        _describeImgV.hidden = YES;
//    }
    
}

#pragma mark 朋友圈
-(void)onMyBlog{
    userWeiboVC* vc = [userWeiboVC alloc];
    vc.user = self.wh_user;
    vc.wh_isGotoBack = YES;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
}

#pragma mark 发送消息
- (void)sendMethod {
    WH_JXChat_WHViewController *chatVC=[WH_JXChat_WHViewController alloc];
    chatVC.title = self.wh_user.userNickname;
    chatVC.chatPerson = self.wh_user;
    chatVC = [chatVC init];
    [g_navigation pushViewController:chatVC animated:YES];
}

- (void) setUserInfo:(WH_JXUserObject *)user {
    if (self.wh_user.content) {
        user.content = self.wh_user.content;
    }
//    self.wh_user = user;
    self.wh_user = user;
    
    // 更新用户信息
    [user WH_updateUserNickname];
    
    _friendStatus = [user.status intValue];
    _latitude  = [user.latitude doubleValue];
    _longitude = [user.longitude doubleValue];
    
    // 设置用户名字、备注、通讯号、地区等...
    [self setLabelAndDescribe];
    
    if ([user.lastLoginTime intValue] > 0 && [user.userType intValue] != 2) {
        self.wh_lastOnLineTime.text = [self dateTimeDifferenceWithStartTime:user.lastLoginTime];
    }else {
        self.wh_lastOnLineTime.hidden = YES;
        
    }
    if (user.telephone.length > 0 && [user.userType intValue] != 2) {
        self.wh_phoneNumLabel.text = user.phone;
    }else {
        self.wh_phoneNumLabel.hidden = YES;
    }
    
    if (self.wh_tableBody.frame.size.height < CGRectGetMaxY(self.wh_sendBtn.frame)+30) {
        self.wh_tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, CGRectGetMaxY(self.wh_sendBtn.frame)+30);
    }
    
    self.wh_birthdayLabel.text = [TimeUtil formatDate:user.birthday format:@"yyyy-MM-dd"];
    
    
//    if ([user.offlineNoPushMsg intValue] == 1) {
//        [_messageFreeSwitch setOn:YES];
//    }else {
//        [_messageFreeSwitch setOn:NO];
//    }
    
//    if (_tel) {
//        NSString *subString = [user.telephone substringToIndex:2];
//        if ([subString isEqualToString:@"86"]) {
//            NSDate *date = [g_myself.phoneDic objectForKey:[user.telephone substringFromIndex:2]];
//            if (date) {
//                long long n = (long long)[date timeIntervalSince1970];
//                NSString *time = [TimeUtil getTimeStrStyle1:n];
//                NSString *str = [NSString stringWithFormat:@"%@,%@:%@",[user.telephone substringFromIndex:2],Localized(@"JX_HaveToDial"),time];
//                _tel.text = str;
//            }else {
//                _tel.text = [user.telephone substringFromIndex:2];
//            }
//            
//        }else {
//            _tel.text = user.telephone;
//        }
//    }
    
//    [self showAddFriend];
}

-(UILabel*)wh_CreateLabel:(UIView*)parent default:(NSString*)s{
    UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(parent.frame)/2, 0, CGRectGetWidth(parent.frame)/2 - 10, CGRectGetHeight(parent.frame))];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.textColor = HEXCOLOR(0x969696);
    p.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
    //    [p release];
    return p;
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
