//
//  WH_PersonalData_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_PersonalData_WHViewController.h"

#import "WH_SetGroupHeads_WHView.h"

#import "UIView+WH_CustomAlertView.h"

#import "ImageResize.h"
#import "WH_QRCode_WHViewController.h"
#import "WH_selectProvince_WHVC.h"
#import "OBSHanderTool.h"

@interface WH_PersonalData_WHViewController ()

@end

@implementation WH_PersonalData_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.title = @"个人资料";
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    [self createContentView];
    
    [g_notify addObserver:self selector:@selector(wh_updateUserInfo:) name:kXMPPMessageUpdateUserInfo_WHNotification object:nil];
}

- (void)createContentView {
    //@[@[Localized(@"WaHu_HeadIcon_WaHu")]
    
    NSString *tStr = @"";
    if ([g_config.regeditPhoneOrName intValue] != 1) {
        // 0：使用手机号注册，1：使用用户名注册
        tStr = @"手机号";
    }else{
//        tStr = Localized(@"WaHu_UserName_WaHu");
        tStr = @"手机号";
    }
    NSMutableArray *mainArr = [NSMutableArray array];
    
    
    //1区
    [mainArr addObject:@[Localized(@"WaHu_HeadIcon_WaHu")]];
    
    
    //2区
    NSMutableArray *tempArr = [NSMutableArray array];
    [tempArr addObject:Localized(@"JX_NickName")];
    [tempArr addObject:Localized(@"JX_Sex")];
    [tempArr addObject:Localized(@"JX_BirthDay")];
    if ([g_config.isOpenPositionService intValue] == 0) {//是否开启位置相关服务 0：开启 1：关闭
        //[tempArr addObject:Localized(@"WaHu_JXUserInfo_WaHuVC_Address")];////现在不论位置服务是否开启,居住地选项全部不显示
    }
    if ([g_config.isOpenTwoBarCode intValue] == 1) {
        [tempArr addObject:Localized(@"JX_MyQRImage")];
    }
    
    [mainArr addObject:tempArr];
    
    
    //3区
    NSMutableArray *tempArr2 = [NSMutableArray array];
    if ([g_config.isOpenTelnum intValue] == 1) {
        [tempArr2 addObject:tStr];
    }
    [tempArr2 addObject:@"账号"];
    if ([g_config.registerInviteCode intValue]) {//注册邀请码   0：关闭,1:开启一对一邀请（一码一用，且必填），2:开启一对多邀请（一码多用，选填项）
        [tempArr2 addObject:Localized(@"JX_InvitationCode")];
    }
    [mainArr addObject:tempArr2];
    
    
    //4区
    [mainArr addObject:@[Localized(@"JX_Update")]];
    
    
    //给数据源赋值
    self.array = mainArr;
    
    
    
    
    self.wh_cTableView = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset),JX_SCREEN_HEIGHT - JX_SCREEN_TOP) style:UITableViewStylePlain];
    [self.wh_cTableView setDelegate:self];
    [self.wh_cTableView setDataSource:self];
    [self.wh_cTableView setBackgroundColor:self.wh_tableBody.backgroundColor];
    [self.wh_cTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_tableBody addSubview:self.wh_cTableView];
    
    [self createDatePicker];
}

#pragma mark 用户信息更改消息
- (void)wh_updateUserInfo:(NSNotification *)notification {
    [g_server getUser:MY_USER_ID toView:self];
}

- (void)createDatePicker {
    int height = 226;
    if (THE_DEVICE_HAVE_HEAD) {
        height = 235 + 26;
    }
    
    self.wh_date = [[WH_JXDatePicker alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
//    self.wh_date.wh_datePicker.datePickerMode = UIDatePickerModeDate;
    self.wh_date.wh_date = self.user.birthday;
    self.wh_date.wh_delegate = self;
    self.wh_date.wh_didChange = @selector(onDate:);
    self.wh_date.wh_didSelect = @selector(onDate:);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (indexPath.section < self.array.count - 1) {
        [cell setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
        
        cell.layer.cornerRadius = 10;
        cell.layer.masksToBounds = YES;
        cell.layer.borderColor = g_factory.cardBorderColor.CGColor;
        cell.layer.borderWidth = g_factory.cardBorderWithd;
    }else{
        [cell setBackgroundColor:self.wh_cTableView.backgroundColor];
        [cell.contentView setBackgroundColor:self.wh_cTableView.backgroundColor];
    }
    
    NSArray *nameArray = [self.array objectAtIndex:indexPath.section];
    if (indexPath.section == 0) {
        //头像
        UIButton *btn = [self createBGButtonWithHeight:80 orginY:0 buttonTag:0];
        [cell addSubview:btn];
        
        [btn addSubview:[self createNameLabelWithHeight:80 orginY:0 text:[nameArray objectAtIndex:indexPath.row]]];
        
        NSString* s;
        if (self.head) {
            [self.head removeFromSuperview];
        }
        self.head = [[WH_JXImageView alloc]initWithFrame:CGRectMake(self.wh_cTableView.frame.size.width - 27 - 40, 20, 40, 40)];
        [self.head headRadiusWithAngle:40 * 0.5];
        self.head.layer.borderWidth = 4.f;
        self.head.layer.borderColor = [UIColor whiteColor].CGColor;
        self.head.didTouch = @selector(pickImage);
        self.head.wh_delegate = self;
        //        _head.image = [UIImage imageNamed:@"avatar_normal"];
//        if (self.isRefresh) {
//            [g_server WH_getHeadImageSmallWIthUserId:g_myself.userId userName:g_myself.userNickname imageView:self.head];
//        }else{
//            self.head.image = self.wh_headImage;
//        }
        self.head.image = self.wh_headImage;
        [btn addSubview:self.head];
        
        s = self.user.userId;
        [g_server WH_getHeadImageLargeWithUserId:s userName:self.user.userNickname imageView:_head];
        
        UIImageView *markView = [[UIImageView alloc] initWithFrame:CGRectMake(self.wh_cTableView.frame.size.width - 19, (80 - 12)/2, 7, 12)];
        [markView setImage:[UIImage imageNamed:@"WH_Back"]];
        [btn addSubview:markView];
        
    }else if(indexPath.section == 1){
        for (int i = 0; i < nameArray.count; i++) {
            UIButton *btn = [self createBGButtonWithHeight:55 orginY:i*55  buttonTag:0];
            [cell addSubview:btn];
            [btn addSubview:[self createNameLabelWithHeight:CGRectGetHeight(btn.frame) orginY:0 text:[nameArray objectAtIndex:i]]];
            [btn addSubview:[self createLineViewWithOrginY:CGRectGetHeight(btn.frame) - g_factory.cardBorderWithd]];
            
            NSString *currentTitleString = nameArray[i];
            
            //Localized(@"JX_NickName"),,,,,手机号,账号,Localized(@"JX_InvitationCode")
            if ([currentTitleString isEqualToString:Localized(@"JX_NickName")]) {//昵称
                btn.tag = 11;
                if (self.wh_name) {
                    [self.wh_name removeFromSuperview];
                }
                self.wh_name = [self WH_createMiXinTextField:btn default:self.user.userNickname?:@"" hint:Localized(@"JX_InputName")];
                [self.wh_name addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            }else if ([currentTitleString isEqualToString:Localized(@"JX_Sex")]) {//性别
                btn.tag = 12;
                if (self.wh_sex) {
                    [self.wh_sex removeFromSuperview];
                }
                
                
                self.wh_sex = [[UISegmentedControl alloc] initWithItems:@[Localized(@"JX_Wuman"), Localized(@"JX_Man")]];
//                [self.wh_sex addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
                self.wh_sex.frame = CGRectMake(JX_SCREEN_WIDTH - 80 - 12 - g_factory.globelEdgeInset,INSETS+3, 80, 55-2*13);
                self.wh_sex.selectedSegmentIndex = 0;
                self.wh_sex.tintColor = THEMECOLOR;
                self.wh_sex.layer.cornerRadius = 5;
                self.wh_sex.layer.borderWidth = 1.5;
                self.wh_sex.layer.borderColor = [THEMECOLOR CGColor];
                self.wh_sex.clipsToBounds = YES;
                //设置文字属性
                self.wh_sex.selectedSegmentIndex = [self.user.sex boolValue];
                self.wh_sex.apportionsSegmentWidthsByContent = NO;
                [btn addSubview:self.wh_sex];
                
            } else if ([currentTitleString isEqualToString:Localized(@"JX_BirthDay")]) {//出生日期
                btn.tag = 13;
                if (self.wh_birthday) {
                    [self.wh_birthday removeFromSuperview];
                }
                self.wh_birthday = [self WH_createMiXinTextField:btn default:[TimeUtil getDateStr:[self.user.birthday timeIntervalSince1970]] hint:Localized(@"JX_BirthDay")];
            }else if ([currentTitleString isEqualToString:Localized(@"WaHu_JXUserInfo_WaHuVC_Address")]) {//居住地,数组中已经控制此项隐藏与展示
                btn.tag = 14;
                NSString* city = [g_constant getAddressForNumber:self.user.provinceId cityId:self.user.cityId areaId:self.user.areaId];
                if (self.wh_city) {
                    [self.wh_city removeFromSuperview];
                }
                self.wh_city = [self createLabelWithWidth:self.wh_cTableView.frame.size.width - 90 -22 text:city?:@""];
                [btn addSubview:self.wh_city];
                
                UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.wh_cTableView.frame.size.width - 19, (55 - 12)/2, 7, 12)];
                [markImg setImage:[UIImage imageNamed:@"WH_Back"]];
                [btn addSubview:markImg];
            }else if ([currentTitleString isEqualToString:Localized(@"JX_MyQRImage")]) {//我的二维码
                btn.tag = 15;
                UIImageView *qrImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.wh_cTableView.frame.size.width - 19 - 27, (55 - 20)/2, 20, 20)];
                [qrImg setImage:[UIImage imageNamed:@"WH_addressbook_qrcode"]];
                [btn addSubview:qrImg];
                
                UIImageView *markView = [[UIImageView alloc] initWithFrame:CGRectMake(self.wh_cTableView.frame.size.width - 19, (55 - 12)/2, 7, 12)];
                [markView setImage:[UIImage imageNamed:@"WH_Back"]];
                [btn addSubview:markView];
            }
            
            
        }
        
    }else if (indexPath.section == 2) {

        for (int i = 0; i < nameArray.count; i++) {
            UIButton *btn = [self createBGButtonWithHeight:55 orginY:i*55  buttonTag:0];
            [cell addSubview:btn];
            [btn addSubview:[self createNameLabelWithHeight:CGRectGetHeight(btn.frame) orginY:0 text:[nameArray objectAtIndex:i]]];
            [btn addSubview:[self createLineViewWithOrginY:CGRectGetHeight(btn.frame) - g_factory.cardBorderWithd]];
            
            NSString *currentTitleString = nameArray[i];
            //手机号账号Localized(@"JX_InvitationCode")
            if ([currentTitleString isEqualToString:@"手机号"]) {
                btn.tag = 101;
                //手机号
                [btn addSubview:[self createLabelWithWidth:self.wh_cTableView.frame.size.width - 90 -12 text:g_myself.telephone?:@""]];
            }else if ([currentTitleString isEqualToString:@"账号"]) {
                btn.tag = 102;
                //通讯号
                //通讯号次数 次数> 0 不编辑
                //                UILabel *label = [[UILabel alloc] init];
                if ([self.user.setAccountCount integerValue] > 0) {
                    [btn addSubview:[self createLabelWithWidth:self.wh_cTableView.frame.size.width - 90 -12 text:self.user.account?:@""]];
                }else{
                    [btn addSubview:[self createLabelWithWidth:self.wh_cTableView.frame.size.width - 90 -22 text:self.user.account?:@""]];
                    
                    UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.wh_cTableView.frame.size.width - 19, (55 - 12)/2, 7, 12)];
                    [markImg setImage:[UIImage imageNamed:@"WH_Back"]];
                    [btn addSubview:markImg];
                }
            }else if ([currentTitleString isEqualToString:Localized(@"JX_InvitationCode")]) {
                btn.tag = 103;
                //邀请码
                [btn addSubview:[self createLabelWithWidth:self.wh_cTableView.frame.size.width - 90 -12 text:g_myself.myInviteCode?:@""]];
            }
        }
    }else{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 8, self.wh_cTableView.frame.size.width, 44)];
        [btn setBackgroundColor:HEXCOLOR(0x0093FF)];
        btn.tag = 1001;
        
        [btn setTitle:[nameArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        [btn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = g_factory.cardCornerRadius;
        [cell addSubview:btn];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 80;
    }else if (indexPath.section == self.array.count - 1){
        return 8+44;
    } else {
        return [[self.array objectAtIndex:indexPath.section] count]*55;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.wh_cTableView.frame), 12)];
    [view setBackgroundColor:self.wh_tableBody.backgroundColor];
    return view;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:wh_act_UserGet]) {
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        self.user = user;
        
        [self.wh_cTableView reloadData];
        
        //[g_server WH_getHeadImageSmallWIthUserId:g_myself.userId userName:g_myself.userNickname imageView:self.wh_headImgView];
        
    }else if( [aDownload.action isEqualToString:wh_act_UploadHeadImage] ){
        _image = nil;
        
        [g_server WH_delHeadImageWithUserId:self.user.userId];
        if(self.isRegister){
            [g_App showMainUI];
            [g_App showAlert:Localized(@"JX_RegOK")];
        }else{
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
        }
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:self userInfo:nil];
        [self actionQuit];
    }else if( [aDownload.action isEqualToString:wh_act_UserUpdate] ){
        
        [self updateUserInfoSentToServer];
        if(self.image) {
            /*直接上传服务器,改为上传obs*/
            [OBSHanderTool WH_handleUploadOBSHeadImage:self.user.userId image:self.image toView:self success:^(int code) {
                if (code == 1) {
                    _image = nil;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [g_server WH_delHeadImageWithUserId:self.user.userId];
                        if(self.isRegister){
                            [g_App showMainUI];
                            [g_App showAlert:Localized(@"JX_RegOK")];
                        }else{
                            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
                        }
                        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:self userInfo:nil];
                        [self actionQuit];
                    });
                }
            } failed:^(NSError * _Nonnull error) {
                
            }];
        } else{
            self.user.userNickname = _wh_name.text;
            self.user.sex = [NSNumber numberWithInteger:_wh_sex.selectedSegmentIndex];
            self.user.birthday = _wh_date.wh_date;
//            self.user.cityId = [NSNumber numberWithInt:[_city.text intValue]];
            [g_App showAlert:Localized(@"JXAlert_UpdateOK")];
            g_myself.userNickname = self.user.userNickname;
            [g_myself saveCurrentUser:nil];
//            [g_default setObject:g_myself.userNickname forKey:kMY_USER_NICKNAME];
            [g_notify postNotificationName:kUpdateUser_WHNotifaction object:self userInfo:nil];
            [self actionQuit];
        }
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    
    if([aDownload.action isEqualToString:wh_act_UploadHeadImage] ){
        NSLog(@"=====");
    }
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    
    if([aDownload.action isEqualToString:wh_act_UploadHeadImage] ){
        NSLog(@"=====");
    }
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    if([aDownload.action isEqualToString:wh_act_UploadHeadImage] ){
        NSLog(@"=====");
    }
    [_wait start];
}

- (void)updateUserInfoSentToServer {
    WH_JXMessageObject * msg = [[WH_JXMessageObject alloc]init];
    msg.timeSend = [NSDate date];
    msg.fromUserId = MY_USER_ID;
    msg.fromUserName = g_myself.userNickname;
    msg.isGroup = NO;
    msg.type = [NSNumber numberWithInteger:kWCMessageTypeUpdateUserInfoSendToServer];
    [g_xmpp sendMessage:msg roomName:nil];
}

- (UIButton *)createBGButtonWithHeight:(CGFloat)height orginY:(CGFloat)orginY buttonTag:(NSInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, orginY, CGRectGetWidth(self.wh_cTableView.frame), height)];
    [btn setTag:tag];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}
- (UILabel *)createNameLabelWithHeight:(CGFloat)height orginY:(CGFloat)orginY text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, orginY, 80, height)];
    [label setTextColor:HEXCOLOR(0x3A404C)];
    [label setText:text];
    [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    return label;
}
- (UILabel *)createLabelWithWidth:(CGFloat)width text:(NSString *)text{
    UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, width, 55)];
    [telLabel setText:text];
    [telLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    [telLabel setTextColor:HEXCOLOR(0x969696)];
    [telLabel setTextAlignment:NSTextAlignmentRight];
    return telLabel;
}
- (UIView *)createLineViewWithOrginY:(CGFloat)orginY {
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, self.wh_cTableView.frame.size.width, g_factory.cardBorderWithd)];
    [lView setBackgroundColor:g_factory.cardBorderColor];
    return lView;
}

- (void)buttonClick:(UIButton *)btn {
    NSLog(@"button.tag:%ld" ,(long)btn.tag);
    switch (btn.tag) {
        case 0://选择头像
        {
            [self pickImage];
        }
            break;
        case 11://昵称
        {
            
        }
            break;
        case 12://性别
        {
            
        }
            break;
        case 13://出生日期
        {
            
        }
            break;
        case 14://居住地
        {
            //居住地
            WH_selectProvince_WHVC* vc = [WH_selectProvince_WHVC alloc];
            vc.delegate = self;
            vc.didSelect = @selector(WH_onSelCity:);
            vc.showCity = YES;
            vc.showArea = NO;
            vc.parentId = 1;
            vc = [vc init];
            //    [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
        }
            break;
        case 15://我的二维码
        {
            //我的二维码
            WH_QRCode_WHViewController *qrVC = [[WH_QRCode_WHViewController alloc] init];
            qrVC.type = QR_UserType;
            qrVC.wh_userId = self.user.userId;
            qrVC.wh_nickName = self.user.userNickname;
            //        qrVC.roomJId = room.roomJid;
            //        qrVC.groupNum = self.groupNum;
            [self presentViewController:qrVC animated:YES completion:nil];
        }
            break;
        case 101://手机号
        {
            
        }
            break;
        case 102://账号
        {
            //ID号
            if ([self.user.setAccountCount integerValue] > 0) {
                
            }else{
                WH_JXSetShikuNum_WHVC *vc = [[WH_JXSetShikuNum_WHVC alloc] init];
                vc.delegate = self;
                vc.user = self.user;
                [g_navigation pushViewController:vc animated:YES];
            }
        }
            break;
        case 103://邀请码
        {
            
        }
            break;
            
        case 1001://点击更新
        {
            [self onUpdate];
        }
            break;
        default:
            break;
    }

}

-(void)WH_onSelCity:(WH_selectProvince_WHVC*)sender{
//    if (self) {
//        [self resetViewFrame];
//    }
    self.user.cityId = [NSNumber numberWithInt:sender.cityId];
    self.user.provinceId = [NSNumber numberWithInt:sender.provinceId];
    self.user.areaId = [NSNumber numberWithInt:sender.areaId];
    self.user.countryId = [NSNumber numberWithInt:1];
    _wh_city.text = sender.selValue;
}

-(BOOL)getInputValue{
    if(self.image==nil && self.isRegister){
        [g_App showAlert:Localized(@"JX_SetHead")];
        return NO;
    }
    if([self.wh_name.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputName")];
        return NO;
    }
    if (self.wh_birthday.text.length <= 0) {
        [g_App showAlert:Localized(@"JX_SelectDateOfBirth")];
        return NO;
    }
    self.user.userNickname = self.wh_name.text;
    self.user.birthday = self.wh_date.wh_date;
    self.user.sex = [NSNumber numberWithBool:_wh_sex.selectedSegmentIndex];
    return  YES;
}

-(void)onUpdate{
    if(![self getInputValue])
        return;
    [g_server WH_updateUser:self.user toView:self];
}


- (void)setShikuNum:(WH_JXSetShikuNum_WHVC *)setShikuNumVC updateSuccessWithAccount:(NSString *)account {
    
    [self.wh_tableBody.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self createContentView];
//    [self WH_createCustomView];
}

- (void)pickImage {
    CGFloat viewH = 191;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 191+24;
    }
    
    WH_SetGroupHeads_WHView *setGroupHeadsview = [[WH_SetGroupHeads_WHView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH)];
    [setGroupHeadsview showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(setGroupHeadsview) weakShare = setGroupHeadsview;
    __weak typeof(self) weakSelf = self;
    [setGroupHeadsview setWh_selectActionBlock:^(NSInteger buttonTag) {
        if (buttonTag == 2) {
            //取消
            [weakShare hideView];
        }else if (buttonTag == 0) {
            //拍摄照片
            WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
            vc.cameraDelegate = weakSelf;
            vc.isPhoto = YES;
            vc = [vc init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [weakSelf presentViewController:vc animated:YES completion:nil];
            [weakShare hideView];
        }else {
            //选择照片
            
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            ipc.delegate = weakSelf;
            ipc.allowsEditing = YES;
            //选择图片模式
            ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
            //    [g_window addSubview:ipc.view];
            if (IS_PAD) {
                UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
                [pop presentPopoverFromRect:CGRectMake((weakSelf.view.frame.size.width - 320) / 2, 0, 300, 300) inView:weakSelf.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }else {
                [weakSelf presentViewController:ipc animated:YES completion:nil];
            }
            
            [weakShare hideView];
            
        }
    }];
}

- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    self.image = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    self.head.image = self.image;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
    self.head.image = self.image;
    if (self.image) {
    for (id label in self.head.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            [label removeFromSuperview];
        }
    }
        }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(UITextField*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(90,0,self.wh_cTableView.frame.size.width - 90 - 12 ,55)];
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
    p.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    p.textColor = HEXCOLOR(0x969696);
    [parent addSubview:p];
    
    return p;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == self.wh_birthday){
        [self.view endEditing:YES];
        [g_window addSubview:self.wh_date];
        self.wh_date.hidden = NO;
        return NO;
    }else{
        self.wh_date.hidden = YES;
        return YES;
    }
}
- (IBAction)onDate:(id)sender {
    NSDate *selected = [self.wh_date wh_date];
    self.user.birthday = selected;
    _wh_birthday.text = [TimeUtil formatDate:selected format:@"yyyy-MM-dd"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField{
    if (textField == self.wh_name) {
        [g_factory setTextFieldInputLengthLimit:textField maxLength:NAME_INPUT_MAX_LENGTH];
    }
}


- (void)sp_didUserInfoFailed {
    NSLog(@"Get Info Success");
}


@end
