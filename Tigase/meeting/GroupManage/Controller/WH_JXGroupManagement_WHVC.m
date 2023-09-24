//
//  WH_JXGroupManagement_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/5/28.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXGroupManagement_WHVC.h"
#import "WH_JXRoomRemind.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXMsg_WHViewController.h"

#import "WH_SignInRecord_WHViewController.h"

#define HEIGHT 55
#define IMGSIZE 170
#define TAG_LABEL 1999

@interface WH_JXGroupManagement_WHVC ()

@property (nonatomic,strong) memberData  * currentMember;
@property (nonatomic, strong) WH_JXImageView *GroupValidationBtn;
@property (nonatomic, strong) UISwitch *GroupValidationSwitch;
@property (nonatomic, strong) NSNumber *updateType;
@property (nonatomic, assign) BOOL isMonitorPeople;  //  YES：监控人  NO: 隐身人


@end

@implementation WH_JXGroupManagement_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.title = Localized(@"JX_GroupManagement");
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
    
    [self createContentView];
}

- (void)createContentView {
    if (self.cView) {
        [self.cView removeFromSuperview];
    }
    self.cView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    [self.cView setBackgroundColor:self.wh_tableBody.backgroundColor];
    [self.wh_tableBody addSubview:self.cView];
    
    int membHeight = 0;
    UIView *tView = [self createBGViewWithOrginY:12 height:HEIGHT*2 supView:self.cView];
    
    WH_JXImageView *iv;
    UILabel *label;
    // 群主管理权转让
    //    iv = [self WH_createMiXinButton:Localized(@"JX_ManagerAreTransferred") drawTop:NO drawBottom:YES must:NO click:@selector(roomTransferAction)];
    iv = [self WH_createMiXinButton:Localized(@"JX_ManagerAreTransferred") supView:tView drawTop:NO drawBottom:YES must:NO click:@selector(roomTransferAction)];
    iv.frame = CGRectMake(0, 0, tView.frame.size.width, HEIGHT);
    
    membHeight = CGRectGetMaxY(iv.frame);
    
    // 设置管理员
    iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WaHuVC_SetAdministrator") supView:tView drawTop:NO drawBottom:YES must:NO click:@selector(specifyAdministrator)];
    iv.frame = CGRectMake(0, membHeight, tView.frame.size.width, HEIGHT);
    membHeight = CGRectGetMaxY(iv.frame);
    // 设置隐身人
//    iv = [self WH_createMiXinButton:Localized(@"JXDesignatedStealthMan") supView:tView drawTop:NO drawBottom:NO must:NO click:@selector(specifyInvisibleMan)];
//    iv.frame = CGRectMake(0, membHeight, tView.frame.size.width, HEIGHT);
    
    membHeight = tView.frame.origin.y + tView.frame.size.height + 12;
    
    CGFloat viewOrginY = membHeight;
    NSLog(@"roomId:%@" ,self.room.roomId);
    NSLog(@"self.room.isShowSignIn:%li" ,(long)self.room.isShowSignIn);
    
    if (IS_SHOW_GROUPSIGNIN) {
        if (self.room.isShowSignIn == 1) {
            //群签到
            UIView *qqView = [self createBGViewWithOrginY:membHeight height:HEIGHT*2 supView:self.cView];
            iv = [self WH_createMiXinButton:@"群签到" supView:qqView drawTop:NO drawBottom:YES must:NO click:nil];
            iv.frame = CGRectMake(0, 0, CGRectGetWidth(qqView.frame), HEIGHT);
            [self createSwitchWithParent:iv tag:2500 isOn:YES];
            
            iv = [self WH_createMiXinButton:@"签到记录" supView:qqView drawTop:NO drawBottom:NO must:NO click:@selector(signInRecordMethod)];
            iv.frame = CGRectMake(0, HEIGHT, tView.frame.size.width, HEIGHT);
            
            viewOrginY = qqView.frame.size.height + qqView.frame.origin.y + 12;
        }else {
            UIView *qqView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
            iv = [self WH_createMiXinButton:@"群签到" supView:qqView drawTop:NO drawBottom:NO must:NO click:nil];
            iv.frame = CGRectMake(0, 0, CGRectGetWidth(qqView.frame), CGRectGetHeight(qqView.frame));
            [self createSwitchWithParent:iv tag:2500 isOn:NO];
            
            viewOrginY = qqView.frame.size.height + qqView.frame.origin.y + 12;
        }
    }
    
    //显示已读人数
//    UIView *ydView = [self createBGViewWithOrginY:viewOrginY height:HEIGHT supView:self.cView];
//    
//    iv = [self WH_createMiXinButton:Localized(@"JX_RoomShowRead") supView:ydView drawTop:NO drawBottom:NO must:NO click:nil];
//    iv.frame = CGRectMake(0, 0, CGRectGetWidth(ydView.frame), CGRectGetHeight(ydView.frame));
//    [self createSwitchWithParent:iv tag:2456 isOn:self.room.showRead];
//    label = [self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(ydView.frame) + 2 text:Localized(@"JX_ReadPeopleList")];
//    
//    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    // 群验证
    UIView *yzView = [self createBGViewWithOrginY:viewOrginY height:HEIGHT supView:self.cView];
    
    iv = [self WH_createMiXinButton:Localized(@"JX_GroupInvitationConfirmation")  supView:yzView drawTop:NO drawBottom:NO must:NO click:nil];
    
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(yzView.frame), CGRectGetHeight(yzView.frame));
    [self createSwitchWithParent:iv tag:2458 isOn:self.room.isNeedVerify];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(yzView.frame) + 2 text:Localized(@"JX_IntoGroupNeedManager")];
    
    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    // 显示群成员列表
    UIView *qlistView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
    //    iv = [self WH_createMiXinButton:Localized(@"JX_DisplayGroupMemberList") drawTop:NO drawBottom:YES must:NO click:nil];
    iv = [self WH_createMiXinButton:Localized(@"JX_DisplayGroupMemberList") supView:qlistView drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(qlistView.frame), CGRectGetHeight(qlistView.frame));
    [self createSwitchWithParent:iv tag:2459 isOn:self.room.showMember];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(qlistView.frame) + 2 text:Localized(@"JX_OnlyShowManager")];
    
    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    // 允许普通成员私聊
    UIView *xyslView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
    iv = [self WH_createMiXinButton:Localized(@"JX_AllowMemberChat") supView:xyslView drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(xyslView.frame), CGRectGetHeight(xyslView.frame));
    [self createSwitchWithParent:iv tag:2460 isOn:self.room.allowSendCard];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(xyslView.frame) + 2 text:Localized(@"JX_ShowDefaultIcon")];
    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    // 允许普通群成员邀请好友
    UIView *xyyqView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
    iv = [self WH_createMiXinButton:Localized(@"JX_AllowInviteFriend") supView:xyyqView drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(xyyqView.frame), CGRectGetHeight(xyyqView.frame));
    [self createSwitchWithParent:iv tag:2461 isOn:self.room.allowInviteFriend];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(xyyqView.frame) + 2 text:Localized(@"JX_NotInviteFunction")];
    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    // 允许普通群成员上传文件
    UIView *xyUploadView = [self createBGViewWithOrginY:membHeight height:HEIGHT  supView:self.cView];
    iv = [self WH_createMiXinButton:Localized(@"JX_AllowMemberToUpload") supView:xyUploadView drawTop:NO drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(xyUploadView.frame), CGRectGetHeight(xyUploadView.frame));
    [self createSwitchWithParent:iv tag:2462 isOn:self.room.allowUploadFile];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(xyUploadView.frame) + 2 text:Localized(@"JX_AllowMemberNotUpload")];
    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    
    // 允许普通群成员召开会议
    UIView *xyMettingView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
    iv = [self WH_createMiXinButton:Localized(@"JX_InitiateMeeting") supView:xyMettingView drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(xyMettingView.frame), CGRectGetHeight(xyMettingView.frame));
    [self createSwitchWithParent:iv tag:2463 isOn:self.room.allowConference];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(xyMettingView.frame) + 2 text:Localized(@"JX_NotInitiateMeeting")];
    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    // 允许普通群成员发起讲课
    UIView *xyjkView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
    iv = [self WH_createMiXinButton:Localized(@"JX_InitiateLectures") supView:xyjkView drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(xyjkView.frame), CGRectGetHeight(xyjkView.frame));
    [self createSwitchWithParent:iv tag:2464 isOn:self.room.allowSpeakCourse];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(xyjkView.frame) + 2 text:Localized(@"JX_NotInitiateLectures")];
    membHeight = CGRectGetMaxY(label.frame) + 12;
    
    /** 群组减员发送通知功能隐藏 19.09.24 hanf
    UIView *xytzView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
    iv = [self WH_createMiXinButton:Localized(@"JX_GroupReduction") supView:xytzView drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(xytzView.frame), CGRectGetHeight(xytzView.frame));
    [self createSwitchWithParent:iv tag:2465 isOn:self.room.isAttritionNotice];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(xytzView.frame) + 2 text:Localized(@"JX_NotGroupReduction")];
    membHeight = CGRectGetMaxY(label.frame) + 10;*/
    
    
    // 启用后，群内发送公告可以进行强提醒
    UIView *xyqtxView = [self createBGViewWithOrginY:membHeight height:HEIGHT supView:self.cView];
    iv = [self WH_createMiXinButton:Localized(@"JX_NoticeStrongReminderTitle") supView:xyqtxView drawTop:NO drawBottom:NO must:NO click:nil];
    iv.frame = CGRectMake(0, 0, CGRectGetWidth(xyqtxView.frame), CGRectGetHeight(xyqtxView.frame));
    [self createSwitchWithParent:iv tag:2466 isOn:self.room.isAttritionNotice];
    label =[self createLabelWithParent:self.wh_tableBody frameY:CGRectGetMaxY(xyqtxView.frame) + 2 text:@"启用后，群内发送公告可以进行强提醒"];
    membHeight = CGRectGetMaxY(label.frame) + 10;
    
    self.wh_tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(label.frame) + 40);
    self.cView.height = self.wh_tableBody.contentSize.height;
}

- (UIView *)createBGViewWithOrginY:(CGFloat)orginY height:(CGFloat)height supView:(UIView *)sView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, orginY, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset , height)];
    [view setBackgroundColor:g_factory.cardBackgroundColor];
//    [self.wh_tableBody addSubview:view];
    [sView addSubview:view];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = g_factory.cardCornerRadius;
    view.layer.borderWidth = g_factory.cardBorderWithd;
    view.layer.borderColor = g_factory.cardBorderColor.CGColor;
    return view;
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title supView:(UIView *)sView drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click {
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.wh_delegate = self;
    [sView addSubview:btn];
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
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    
    [btn addSubview:p];
    //    [p release];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset-19, (HEIGHT - 12)/2, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}
    

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.wh_delegate = self;
    [self.wh_tableBody addSubview:btn];
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
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    
    [btn addSubview:p];
    //    [p release];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 13, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}

- (UISwitch *)createSwitchWithParent:(UIView *)parent tag:(NSInteger)tag isOn:(BOOL)isOn{
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.frame = CGRectMake(CGRectGetWidth(parent.frame)-g_factory.globelEdgeInset-51,0,0,0);
    switchView.center = CGPointMake(switchView.center.x, parent.frame.size.height/2);
    switchView.tag = tag;
    switchView.on = isOn;
    switchView.onTintColor = THEMECOLOR;
    [switchView addTarget:self action:@selector(switchViewAction:) forControlEvents:UIControlEventValueChanged];
    [parent addSubview:switchView];
    
    return switchView;
}

- (UILabel *)createLabelWithParent:(UIView *)parent frameY:(CGFloat)framey text:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]} context:nil].size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, framey, JX_SCREEN_WIDTH - 20, size.height)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 0;
    label.text = text;
    [parent addSubview:label];
    
    return label;
}
// 设置管理员
-(void)specifyAdministrator{
    [self setManagerWithType:JXSelUserTypeSpecifyAdmin];
}
//设置隐身人
- (void)specifyInvisibleMan {
    [self setManagerWithType:JXSelUserTypeRoomInvisibleMan];
}

// 设置监控人
- (void)specifyMonitorPeople {
    [self setManagerWithType:JXSelUserTypeRoomMonitorPeople];
}

#pragma mark 签到记录
- (void)signInRecordMethod {
    WH_SignInRecord_WHViewController *recordVC = [[WH_SignInRecord_WHViewController alloc] init];
    recordVC.roomId = self.room.roomId;
    [g_navigation pushViewController:recordVC animated:YES];
}

- (void)setManagerWithType:(JXSelUserType)type {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        return;
    }
    
    WH_JXSelFriend_WHVC * selVC = [[WH_JXSelFriend_WHVC alloc] init];
    selVC.type = type;
    selVC.room = self.room;
    selVC.delegate = self;
    if (type == JXSelUserTypeSpecifyAdmin) {
        selVC.didSelect = @selector(specifyAdministratorDelegate:);
    }else if(type == JXSelUserTypeRoomInvisibleMan) {
        selVC.didSelect = @selector(specifyInvisibleManDelegate:);
    }else {
        selVC.didSelect = @selector(specifyMonitorPeopleDelegate:);
    }
    [g_navigation pushViewController:selVC animated:YES];
}

// 群主转让
- (void)roomTransferAction {
    WH_JXSelFriend_WHVC * selVC = [[WH_JXSelFriend_WHVC alloc] init];
    selVC.room = _room;
    selVC.type = JXSelUserTypeRoomTransfer;
    selVC.delegate = self;
    selVC.didSelect = @selector(atSelectMemberDelegate:);

    [g_navigation pushViewController:selVC animated:YES];
}

-(void)atSelectMemberDelegate:(memberData *)member{
    _currentMember = member;
    [g_server WH_roomTransferWithRoomId:_room.roomId toUserId:[NSString stringWithFormat:@"%ld",member.userId] toView:self];
    
    // 更新数据库
    WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
    user.userId = [NSString stringWithFormat:@"%ld",_room.userId];
    user.createUserId = [NSString stringWithFormat:@"%ld",member.userId];
    [user updateCreateUser];
}

// 指定管理员回调
-(void)specifyAdministratorDelegate:(memberData *)member{
    
    _currentMember = member;
    int type;
    if ([member.role intValue] == 2) {
        type = 3;
    }else {
        type = 2;
    }
    
    [g_server WH_setRoomAdminWithRoomId:member.roomId userId:[NSString stringWithFormat:@"%ld",member.userId] type:type toView:self];
}
// 指定隐身人回调
- (void)specifyInvisibleManDelegate:(memberData *)member {
    _currentMember = member;
    int type;
    if ([member.role intValue] == 3) {
        type = 4;
    }else {
        type = -1;
    }
    self.isMonitorPeople = NO;
    [g_server WH_setRoomInvisibleGuardianWithRoomId:member.roomId userId:[NSString stringWithFormat:@"%ld",member.userId] type:type toView:self];
}
//指定监控人回调
- (void)specifyMonitorPeopleDelegate:(memberData *)member {
    _currentMember = member;
    int type;
    if ([member.role intValue] == 3) {
        type = 5;
    }else {
        type = 0;
    }
    self.isMonitorPeople = YES;
    [g_server WH_setRoomInvisibleGuardianWithRoomId:member.roomId userId:[NSString stringWithFormat:@"%ld",member.userId] type:type toView:self];
}
- (void)switchViewAction:(UISwitch *)switchView {
    switch (switchView.tag) {
        case 2456:
            [self readSwitchAction:switchView];
            break;
        case 2457:
            [self lookSwitchAction:switchView];
            break;
        case 2458:
            [self needVerifySwitchAction:switchView];
            break;
        case 2459:
            [self showMemberSwitchAction:switchView];
            break;
        case 2460:
            [self allowSendCardSwitchAction:switchView];
            break;
        case 2461:
            [self allowInviteFriendSwitchAction:switchView];
            break;
        case 2462:
            [self allowUploadFileSwitchAction:switchView];
            break;
        case 2463:
            [self allowConferenceSwitchAction:switchView];
            break;
        case 2464:
            [self allowSpeakCourseSwitchAction:switchView];
            break;
        case 2465:
            [self isAttritionNoticeSwitchAction:switchView];
            break;
        case 2466:
            [self isStrongReminderSwitchAction:switchView];
            break;
        case 2500:
            [self isSignInRecordSwitchAction:switchView];
            break;
        default:
            break;
    }
}

// 显示已读人数
-(void)readSwitchAction:(UISwitch *)readswitch{
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [readswitch setOn:!readswitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_ShowRead];
    self.room.showRead = readswitch.on;
    [g_server updateRoomShowRead:self.room key:@"showRead" value:self.room.showRead toView:self];
}
// 进群验证
- (void)needVerifySwitchAction:(UISwitch *)needVerifySwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [needVerifySwitch setOn:!needVerifySwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    self.room.isNeedVerify = needVerifySwitch.on;
    [g_server updateRoomShowRead:self.room key:@"isNeedVerify" value:self.room.isNeedVerify toView:self];
}

// 私密群组群组
- (void)lookSwitchAction:(UISwitch *)lookSwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [lookSwitch setOn:!lookSwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:2457];
    self.room.isLook = lookSwitch.on;
    [g_server updateRoomShowRead:self.room key:@"isLook" value:self.room.isLook toView:self];
}


// 显示群成员列表
- (void)showMemberSwitchAction:(UISwitch *)showMemberSwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [showMemberSwitch setOn:!showMemberSwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_ShowMember];
    self.room.showMember = showMemberSwitch.on;
    [g_server updateRoomShowRead:self.room key:@"showMember" value:self.room.showMember toView:self];
}

// 允许发送名片
- (void)allowSendCardSwitchAction:(UISwitch *)allowSendCardSwitch {
    memberData *data = [self.room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [allowSendCardSwitch setOn:!allowSendCardSwitch.isOn];
        return;
    }
    
    self.updateType = [NSNumber numberWithInt:kRoomRemind_allowSendCard];
    self.room.allowSendCard = allowSendCardSwitch.on;
    [g_server updateRoomShowRead:self.room key:@"allowSendCard" value:self.room.allowSendCard toView:self];
}

// 允许普通成员邀请好友
- (void)allowInviteFriendSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowInviteFriend];
    self.room.allowInviteFriend = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowInviteFriend" value:self.room.allowInviteFriend toView:self];
}

// 允许普通成员上传文件
- (void)allowUploadFileSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowUploadFile];
    self.room.allowUploadFile = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowUploadFile" value:self.room.allowUploadFile toView:self];
}

// 允许普通成员召开会议
- (void)allowConferenceSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowConference];
    self.room.allowConference = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowConference" value:self.room.allowConference toView:self];
}
// 允许普通成员开启讲课
- (void)allowSpeakCourseSwitchAction:(UISwitch *)switchView {
    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowSpeakCourse];
    self.room.allowSpeakCourse = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowSpeakCourse" value:self.room.allowSpeakCourse toView:self];
}

// 群减员通知
- (void)isAttritionNoticeSwitchAction:(UISwitch *)switchView {
//    self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllowSpeakCourse];
    self.room.isAttritionNotice = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"isAttritionNotice" value:self.room.isAttritionNotice toView:self];
}
// 公告强提醒
- (void)isStrongReminderSwitchAction:(UISwitch *)switchView{
    self.room.allowForceNotice = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"allowForceNotice" value:self.room.allowForceNotice toView:self];
}

#pragma mark 群签到
- (void)isSignInRecordSwitchAction:(UISwitch *)switchView {
    self.isSignIn = YES;
    self.updateType = [NSNumber numberWithInt:kRoomRemind_GroupSignIn];
    self.room.isShowSignIn = switchView.on;
    [g_server updateRoomShowRead:self.room key:@"isShowSignIn" value:self.room.isShowSignIn toView:self];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        [self.room setNickNameForUser:user];
    }
    if( [aDownload.action isEqualToString:wh_act_roomSet] ){
        
        WH_JXUserObject * user = [[WH_JXUserObject alloc]init];
        user = [user getUserById:self.room.roomJid];
        user.showRead = [NSNumber numberWithBool:self.room.showRead];
        user.showMember = [NSNumber numberWithBool:self.room.showMember];
        user.allowSendCard = [NSNumber numberWithBool:self.room.allowSendCard];
        user.chatRecordTimeOut = self.room.chatRecordTimeOut;
        user.talkTime = [NSNumber numberWithLong:self.room.talkTime];
        user.allowInviteFriend = [NSNumber numberWithBool:self.room.allowInviteFriend];
        user.allowUploadFile = [NSNumber numberWithBool:self.room.allowUploadFile];
        user.allowConference = [NSNumber numberWithBool:self.room.allowConference];
        user.allowSpeakCourse = [NSNumber numberWithBool:self.room.allowSpeakCourse];
        [user update];
        
        if ([self.updateType intValue] == kRoomRemind_ShowRead || [self.updateType intValue] == kRoomRemind_ShowMember || [self.updateType intValue] == kRoomRemind_allowSendCard || [self.updateType intValue] == kRoomRemind_RoomAllowInviteFriend || [self.updateType intValue] == kRoomRemind_RoomAllowUploadFile || [self.updateType intValue] == kRoomRemind_RoomAllowConference || [self.updateType intValue] == kRoomRemind_RoomAllowSpeakCourse || [self.updateType integerValue] == kRoomRemind_GroupSignIn) {
            
            WH_JXRoomRemind* p = [[WH_JXRoomRemind alloc] init];
            p.objectId = self.room.roomJid;
            switch ([self.updateType intValue]) {
                case kRoomRemind_GroupSignIn:{
                    p.type = [NSNumber numberWithInt:kRoomRemind_GroupSignIn];
                    p.content = [NSString stringWithFormat:@"%ld" ,(long)self.room.isShowSignIn];
                    
                    [g_notify postNotificationName:WHGroupSignInState_WHNotification object:nil];
                }
                    break;
                case kRoomRemind_ShowRead: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowRead];
                    p.content = [NSString stringWithFormat:@"%d",self.room.showRead];
                }
                    break;
                    
                case kRoomRemind_ShowMember: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowMember];
                    p.content = [NSString stringWithFormat:@"%d",self.room.showMember];
                }
                    break;
                    
                case kRoomRemind_allowSendCard: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_allowSendCard];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowSendCard];
                }
                    break;
                case kRoomRemind_RoomAllowInviteFriend: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowInviteFriend];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowInviteFriend];
                }
                    break;
                case kRoomRemind_RoomAllowUploadFile: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowUploadFile];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowUploadFile];
                }
                    break;
                case kRoomRemind_RoomAllowConference: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowConference];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowConference];
                }
                    break;
                case kRoomRemind_RoomAllowSpeakCourse: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllowSpeakCourse];
                    p.content = [NSString stringWithFormat:@"%d",self.room.allowSpeakCourse];
                }
                    break;
                    
                default:
                    break;
            }
            [p notify];
        }
        if (self.isSignIn) {
            [g_server getRoom:self.room.roomId toView:self];
        }
        
        //[g_App showAlert:Localized(@"JXAlert_UpdateOK")];
    }
    
    if ([aDownload.action isEqualToString:wh_act_roomSetAdmin]) {
        //设置群组管理员
        NSString *str;
        if ([_currentMember.role intValue] == 2) {
            _currentMember.role = [NSNumber numberWithInt:3];
            str = Localized(@"WaHu_JXRoomMember_WaHuVC_CancelAdministratorSuccess");
        }else {
            _currentMember.role = [NSNumber numberWithInt:2];
            str = Localized(@"WaHu_JXRoomMember_WaHuVC_SetAdministratorSuccess");
        }
//        [_currentMember updateRole];
        [g_server showMsg:str];
    }
    
    if ([aDownload.action isEqualToString:wh_act_roomSetInvisibleGuardian]) {
        //设置群组隐身人、监控人
        NSString *str;
        if (self.isMonitorPeople) {
            if ([_currentMember.role intValue] == 3){
                _currentMember.role = [NSNumber numberWithInt:5];
                str = @"指定监控人成功";
            }else {
                _currentMember.role = [NSNumber numberWithInt:3];
                str = @"取消监控人成功";
            }
        }else {
            if ([_currentMember.role intValue] == 3) {
                _currentMember.role = [NSNumber numberWithInt:4];
                str = Localized(@"JX_SetInvisibleSuccessfully");
            }else{
                _currentMember.role = [NSNumber numberWithInt:3];
                str = Localized(@"JX_CancelInvisibleSuccessfully");
            }
        }
        [_currentMember updateRole];
        [g_server showMsg:str];
    }
   
    if ([aDownload.action isEqualToString:wh_act_roomTransfer]) {
        //转让群主
        
        memberData *groupOwner = [memberData searchGroupOwner:self.room.roomId];
        groupOwner.role = [NSNumber numberWithInt:3];
        _currentMember.role = [NSNumber numberWithInt:1];
        
        [g_server showMsg:Localized(@"JX_ManagerAssignment")];
        [g_navigation popToRootViewController];
        
    }
    if ([aDownload.action isEqualToString:wh_act_roomGet]) {
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        NSDictionary * groupDict = [user toDictionary];
        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
        [roomdata WH_getDataFromDict:groupDict];
        
        [roomdata WH_getDataFromDict:dict];
        
        self.room       = roomdata;
        
        [self createContentView]; //刷新界面
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
    [_wait start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_getUsersMostLikedSuccess {
    NSLog(@"Get Info Success");
}
@end
