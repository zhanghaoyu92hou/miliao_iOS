//
//  WH_JXRoomMember_WHVC.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//  群组聊天进入的 --> 设置界面

#import "WH_JXRoomMember_WHVC.h"
//#import "WH_selectTreeVC_WHVC.h"
#import "WH_selectValue_WHVC.h"
#import "WH_selectProvince_WHVC.h"
#import "ImageResize.h"
#import "WH_RoomData.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXRoomObject.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXRoomObject.h"
#import "WH_JXRoomRemind.h"
#import "WH_JXInputValue_WHVC.h"
#import "XMPPRoom.h"
#import "WH_JXFile_WHViewController.h"
#import "WH_JXQRCode_WHViewController.h"
#import "WH_JXGroupManagement_WHVC.h"
#import "WH_JXInput_WHVC.h"
#import "WH_JXRoomMemberList_WHVC.h"
#import "WH_JXSearchChatLog_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "WH_JXReportUser_WHVC.h"
#import "WH_JXRoomPool.h"
#import "WH_JXAnnounce_WHViewController.h"
#import "JXSynTask.h"
#import "WH_JXCamera_WHVC.h"
#import "ImageResize.h"
#import "WH_JXMsg_WHViewController.h"


#import "UIView+WH_CustomAlertView.h"
#import "WH_CustomActionSheetView.h"

#import "WH_QRCode_WHViewController.h"

#import "WH_SetGroupHeads_WHView.h"
#import "WH_ContentModification_WHView.h"
#import "WH_GroupSignIn_WHViewController.h"

#import "WH_DeleteRoomMembers_ViewController.h"

#define HEIGHT 55
#define IMGSIZE 170
#define TAG_LABEL 1999
#define leftRightMargin 10
#define topBottomMargin 12

@interface WH_JXRoomMember_WHVC ()<UITextFieldDelegate, UIPickerViewDelegate, WH_JXRoomMemberList_WHVCDelegate,WH_JXCamera_WHVCDelegate,WH_JXActionSheet_WHVCDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate ,DeleteRoomMembersDelegate>

@property (nonatomic,strong) UIImageView *topOneView;
@property (nonatomic,strong) UIImageView *topTwoView;
@property (nonatomic,strong) UIImageView *topThreeView;
@property (nonatomic,strong) UIImageView *topFourView;
@property (nonatomic,strong) UIImageView *topFiveView;
@property (nonatomic,strong) UIImageView *topSixView;
@property (nonatomic,strong) UIImageView *topSevenView;
@property (nonatomic,strong) UIButton *exitBtn;

@property (nonatomic,strong) WH_JXImageView * unfoldView;
@property (nonatomic,strong) UIImageView * memberView;
@property (nonatomic,assign) BOOL          isMyRoom;
@property (nonatomic,strong) memberData  * currentMember;

@property (nonatomic, strong) NSMutableArray *selFriendUserIds;
@property (nonatomic, strong) NSMutableArray *selFriendUserNames;

@property (nonatomic, strong) WH_JXUserObject *user;
@property (nonatomic, strong) NSNumber *updateType;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerArr;
@property (nonatomic, strong) JXLabel *chatRecordTimeOutLabel;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSString *setNickName;
@property (nonatomic, assign) int userSize;

@property (nonatomic, strong) UIImage *roomHead;



@end

@implementation WH_JXRoomMember_WHVC
@synthesize wh_room,wh_chatRoom;


- (id)init
{
    self = [super init];
    if (self) {
        
        _modifyType = 0;
        _images  = [[NSMutableArray alloc] init];
        _names   = [[NSMutableArray alloc] init];
        _deleteArr = [[NSMutableArray alloc] init];
//        _noticeArr = [[NSMutableArray alloc] init];
        _delMode = NO;
        _allowEdit = YES;
        _delete = -1;
        memberData *data = [self.wh_room getMember:g_myself.userId];
        _isAdmin = [data.role intValue] == 1 ? YES : NO;
//        _isAdmin = YES;
        _unfoldMode = YES;//默认收起
        _user = [[WH_JXUserObject sharedUserInstance] getUserById:wh_chatRoom.roomJid];
        if ([g_myself.userId longLongValue] == wh_room.userId) {
            _isMyRoom = YES;
        }else{
            _isMyRoom = NO;
        }
        
        _pickerArr = @[Localized(@"JX_Forever"), Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear")];
        
        self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
        self.wh_tableBody.showsVerticalScrollIndicator = NO;
        self.wh_tableBody.showsHorizontalScrollIndicator = NO;
        
        self.user = [[WH_JXUserObject sharedUserInstance] getUserById:wh_room.roomJid];

        self.wh_isGotoBack   = YES;
        self.title = Localized(@"WaHu_JXRoomMember_WaHuVC_RoomInfo");
        self.wh_heightFooter = 0;
        self.wh_heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        
        self.wh_tableBody.scrollEnabled = YES;
        self.wh_tableBody.contentSize = CGSizeMake(self_width, JX_SCREEN_HEIGHT*1.2);
        self.wh_tableBody.showsVerticalScrollIndicator = YES;
        int height = 0;

        self.wh_iv = [[WH_JXImageView alloc]init];
        self.wh_iv.frame = self.wh_tableBody.bounds;
        ///当前背景色
        self.wh_iv.backgroundColor = g_factory.globalBgColor;;
//        iv.delegate = self;
//        iv.didTouch = @selector(hideKeyboard);
        [self.wh_tableBody addSubview:self.wh_iv];
//        [self.iv release];
        
//        if (_isAdmin || room.showMember) {
        
//        height = [self createImages];
//        }
        
//        [self setDeleteMode:YES];
        height+=topBottomMargin;
        int membHei = [self createRoomMember:height];
        height += membHei;
        
//        int memHeadHei = [self createImages];
//        height += memHeadHei;
        [self setRoomframeWithHeight:height];
        
        [g_notify addObserver:self selector:@selector(onReceiveRoomRemind:) name:kXMPPRoom_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(redrawView222) name:WHGroupSignInState_WHNotification object:nil]; //群签到变化时 更新界面
        [g_notify addObserver:self selector:@selector(redrawView222) name:kTransferOwner_WHNotifaction object:nil];
        
        [self createPickerView];
        
//        self.isStartEnter = YES;
//        [g_server getRoom:self.wh_roomId toView:self];
        
//        [g_notify addObserver:self selector:@selector(reSetData:) name:@"ReloadRoomInfo" object:nil];
    }
    return self;
}

#pragma 界面重绘方法
- (void)redrawView
{
//    [g_server getRoom:self.roomId toView:self];
    
    int height = 0;
    height+=topBottomMargin;
    int membHei = [self createRoomMember:height];
    height += membHei;
    height += 50;
    [self setRoomframeWithHeight:height];
}

- (void)redrawView222
{
    self.isStartEnter = NO;
    [g_server getRoom:self.wh_roomId toView:self];
}

- (void)createPickerView {
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, JX_SCREEN_WIDTH, 220)];
    _selectView.backgroundColor = HEXCOLOR(0xf0eff4);
    _selectView.hidden = YES;
    [self.view addSubview:_selectView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(_selectView.frame.size.width - 80, 20, 60, 20)];
    [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 20)];
    [btn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(WH_cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:btn];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, _selectView.frame.size.width, _selectView.frame.size.height - 40)];
    _pickerView.delegate = self;
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSInteger index = 0;
    if (outTime <= 0) {
        index = 0;
    }else if (outTime == 0.04) {
        index = 1;
    }else if (outTime == 1) {
        index = 2;
    }else if (outTime == 7) {
        index = 3;
    }else if (outTime == 30) {
        index = 4;
    }else if (outTime == 90) {
        index = 5;
    }else{
        index = 6;
    }
    
    [_pickerView selectRow:index inComponent:0 animated:NO];
    [_selectView addSubview:_pickerView];
}


- (void)btnAction:(UIButton *)btn {
    _selectView.hidden = YES;
    NSInteger row = [_pickerView selectedRowInComponent:0];
    _chatRecordTimeOutLabel.text = _pickerArr[row];
    
    NSString *str = [NSString stringWithFormat:@"%ld",(long)row];
    switch (row) {
        case 0:
            str = @"-1";
            break;
        case 1:
            str = @"0.04";
            break;
        case 2:
            str = @"1";
            break;
        case 3:
            str = @"7";
            break;
        case 4:
            str = @"30";
            break;
        case 5:
            str = @"90";
            break;
        case 6:
            str = @"365";
            break;
            
        default:
            break;
    }
    self.user.chatRecordTimeOut = str;
    [self.user WH_updateUserChatRecordTimeOut];
    wh_room.chatRecordTimeOut = str;

    [g_server updateRoom:wh_room key:@"chatRecordTimeOut" value:str toView:self];
}

- (void)WH_cancelBtnAction:(UIButton *)btn {
    _selectView.hidden = YES;
}


- (void)chatRecordTimeOutAction {
    double outTime = [self.user.chatRecordTimeOut doubleValue];
    NSInteger index = 0;
    if (outTime <= 0) {
        index = 0;
    }else if (outTime == 0.04) {
        index = 1;
    }else if (outTime == 1) {
        index = 2;
    }else if (outTime == 7) {
        index = 3;
    }else if (outTime == 30) {
        index = 4;
    }else if (outTime == 90) {
        index = 5;
    }else{
        index = 6;
    }
    [_pickerView selectRow:index inComponent:0 animated:NO];
    _selectView.hidden = NO;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerArr[row];
}

-(void)dealloc{
//    NSLog(@"WH_JXRoomMember_WHVC.dealloc");
    [g_notify  removeObserver:self name:kXMPPRoom_WHNotifaction object:nil];
    [_names removeAllObjects];
//    [_names release];
    [_deleteArr removeAllObjects];
//    [_deleteArr release];
    [_images removeAllObjects];
//    [_images release];
//    [_user release];
    wh_chatRoom.delegate = nil;
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
        return YES;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        [wh_room setNickNameForUser:user];
        
//        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
//        vc.user       = user;
//        vc = [vc init];
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//        [user release];
    }
    if( [aDownload.action isEqualToString:wh_act_roomSet] ){
        
        WH_JXUserObject * user = [[WH_JXUserObject alloc]init];
        user = [user getUserById:wh_room.roomJid];
        user.showRead = [NSNumber numberWithBool:_readSwitch.on];
        user.showMember = [NSNumber numberWithBool:wh_room.showMember];
        user.allowSendCard = [NSNumber numberWithBool:wh_room.allowSendCard];
        user.chatRecordTimeOut = wh_room.chatRecordTimeOut;
        user.talkTime = [NSNumber numberWithLong:wh_room.talkTime];
        user.allowInviteFriend = [NSNumber numberWithBool:wh_room.allowInviteFriend];
        user.allowUploadFile = [NSNumber numberWithBool:wh_room.allowUploadFile];
        user.allowConference = [NSNumber numberWithBool:wh_room.allowConference];
        user.allowSpeakCourse = [NSNumber numberWithBool:wh_room.allowSpeakCourse];
        [user update];
        
        NSString *alertStr = nil;
        if ([self.updateType intValue] == kRoomRemind_ShowRead || [self.updateType intValue] == kRoomRemind_ShowMember || [self.updateType intValue] == kRoomRemind_allowSendCard || [self.updateType intValue] == kRoomRemind_RoomAllBanned || [self.updateType integerValue] == kRoomRemind_GroupSignIn) {
            
            WH_JXRoomRemind* p = [[WH_JXRoomRemind alloc] init];
            p.objectId = wh_room.roomJid;
            switch ([self.updateType intValue]) {
                case kRoomRemind_ShowRead: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowRead];
                    p.content = [NSString stringWithFormat:@"%d",_readSwitch.on];
                    if (_readSwitch.on) {
                        alertStr = Localized(@"JX_EnabledShowRead");
                    }else {
                        alertStr = Localized(@"JX_DisabledShowRead");
                    }
    
                }
                    
                    break;
                    
                case kRoomRemind_GroupSignIn:
                    p.type = [NSNumber numberWithInteger:kRoomRemind_GroupSignIn];
                    p.content = [NSString stringWithFormat:@"%ld" ,(long)wh_room.isShowSignIn];
                    break;
                    
                case kRoomRemind_ShowMember: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_ShowMember];
                    p.content = [NSString stringWithFormat:@"%d",wh_room.showMember];
                    if (wh_room.showMember) {
                        alertStr = Localized(@"JX_EnabledShowIcon");
                    }else {
                        alertStr = Localized(@"JX_DisabledShowIcon");
                    }
                }
                    
                    break;
                    
                case kRoomRemind_allowSendCard: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_allowSendCard];
                    p.content = [NSString stringWithFormat:@"%d",wh_room.allowSendCard];
                    if (wh_room.allowSendCard) {
                        alertStr = Localized(@"JX_EnabledShowCard");
                    }else {
                        alertStr = Localized(@"JX_DisabledShowCard");
                    }
                }
                    
                    break;
                case kRoomRemind_RoomAllBanned: {
                    
                    p.type = [NSNumber numberWithInt:kRoomRemind_RoomAllBanned];
                    p.content = [NSString stringWithFormat:@"%d",wh_room.allowSendCard];
                    if (wh_room.talkTime > 0) {
                        alertStr = Localized(@"JX_EnabledAllBanned");
                    }else {
                        alertStr = Localized(@"JX_DisabledAllBanned");
                    }
                }
                    
                    break;
                default:
                    break;
            }
            [p notify];
        }
        
        if ([self.updateType intValue] == kRoomRemind_NeedVerify) {
            if (wh_room.isNeedVerify) {
                alertStr = Localized(@"JX_EnabledIntoGroup");
            }else {
                alertStr = Localized(@"JX_DisabledIntoGroup");
            }
            
        }else if ([self.updateType intValue] == 2457) {
            if (wh_room.isLook) {
                alertStr = Localized(@"JX_EnabledSearch");
            }else {
                alertStr = Localized(@"JX_DisabledSearch");
            }
        }else {
            
            _roomName.text = wh_room.name;
            _note.text = wh_room.note ? wh_room.note : Localized(@"JX_NotAch");
            _desc.text = wh_room.desc;
            _roomNum.text = [NSString stringWithFormat:@"%d",wh_room.maxCount];
            alertStr = Localized(@"JXAlert_UpdateOK");
        }
        
        //[g_App showAlert:alertStr];
    }
    if( [aDownload.action isEqualToString:wh_act_roomMemberSet] ){
        if(_modifyType == kRoomRemind_NickName){
//            [self sendSelfMsg:_modifyType content:_content];
            [self redrawView];
        }
        
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    if( [aDownload.action isEqualToString:wh_act_roomDel] ){
        //        [WH_JXUserObject deleteUserAndMsg:wh_room.roomJid];
        [WH_JXUserObject deleteRoom:wh_room.roomJid];

        wh_chatRoom.delegate = self;
        [wh_chatRoom.xmppRoom destroyRoom];
    }
    if ([aDownload.action isEqualToString:wh_act_roomMemberList]) {
        [wh_room.members removeAllObjects];
        
        for (int i = 0; i < [array1 count]; i++) {
            WH_RoomData * rData = [[WH_RoomData alloc]init];
            [rData WH_getDataFromDict:array1[i]];
            [wh_room.members addObject:rData];
//            [rData release];
        }

        [self redrawView];
        _memberCount.text = [NSString stringWithFormat:@"%d/2000",[_memberCount.text intValue] +1];
    }


    //
    if( [aDownload.action isEqualToString:wh_act_roomMemberDel] ){
        memberData* member=nil;
        if(_delete == -1){
            wh_chatRoom.delegate = self;
            [wh_chatRoom.xmppRoom leaveRoom];
            member = [wh_room getMember:MY_USER_ID];
        }else{
            if (_delete == -2) {
                return;
            }
            member = [wh_room.members objectAtIndex:_delete];
        }
        //在xmpp中删除成员
        [wh_chatRoom removeUser:member];
        [wh_room.members removeObject:member];
        [member remove];
        [self redrawView];

        //通知自己界面
        [self onAfterDelMember:member];
        member = nil;
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
//        [_currentMember update];
        [g_server showMsg:str];
    }
    
    if ([aDownload.action isEqualToString:wh_act_roomMemberSetOfflineNoPushMsg]) {
        self.user.offlineNoPushMsg = [NSNumber numberWithBool:_messageFreeSwitch.isOn];
        [self.user updateOfflineNoPushMsg];
        [g_notify postNotificationName:kChatViewDisappear_WHNotification object:nil];
        //[g_App showAlert:Localized(@"JXAlert_SetOK")];
    }
    
    if([aDownload.action isEqualToString:wh_act_Report]){
        [_wait stop];
        [g_App showAlert:Localized(@"WaHu_JXUserInfo_WaHuVC_ReportSuccess")];
    }
    if([aDownload.action isEqualToString:wh_act_SetGroupAvatarServlet]){
        [_wait stop];
        
        int hashCode = [self gethashCode:self.wh_room.roomJid];
        int a = abs(hashCode % 10000);
        int b = abs(hashCode % 20000);
        // 删除sdwebimage 缓存
        NSString *urlStr = [NSString stringWithFormat:@"%@avatar/o/%d/%d/%@.jpg",g_config.downloadAvatarUrl,a,b,self.wh_room.roomJid];
        [[SDImageCache sharedImageCache] removeImageForKey:urlStr withCompletion:^{
            [g_server showMsg:Localized(@"JX_GroupAvatarUpdatedSuccessfully") delay:0.5];
        }];
//        NSDictionary * groupDict = @{@"groupHeadImage":self.roomHead,@"roomJid":self.room.roomJid,@"setUpdate":@1};
//        [g_notify postNotificationName:kGroupHeadImageModifyNotifaction object:groupDict];
    }
    
    if ([aDownload.action isEqualToString:wh_act_EmptyMsg]) {
        //清空群组内容
        
    }

    if( [aDownload.action isEqualToString:wh_act_roomGet] ){
        memberData *memberD  = [[memberData alloc] init];
        memberD.roomId = self.wh_room.roomId;
        [memberD deleteRoomMemeber];
        NSArray *tempArr = dict[@"notices"];
        if (IsArrayNull(tempArr)) {
            self.noticeArr = [NSMutableArray arrayWithArray:tempArr];
        }
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        NSDictionary * groupDict = [user toDictionary];
        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
        [roomdata WH_getDataFromDict:groupDict];
        
        [roomdata WH_getDataFromDict:dict];
        
        self.wh_chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:roomdata.roomJid title:roomdata.name isNew:NO];
        self.wh_room       = roomdata;
        
        
        memberData *data = [self.wh_room getMember:g_myself.userId];
        _isAdmin = [data.role intValue] == 1 ? YES : NO;
        _user = [[WH_JXUserObject sharedUserInstance] getUserById:wh_chatRoom.roomJid];
        if ([g_myself.userId longLongValue] == wh_room.userId) {
            _isMyRoom = YES;
        }else{
            _isMyRoom = NO;
        }
        self.user = [[WH_JXUserObject sharedUserInstance] getUserById:wh_room.roomJid];
        self.userSize = [dict[@"userSize"] intValue];
        
        
        
        [self redrawView];
        
        [self.seeAllBtn setTitle:[NSString stringWithFormat:@"查看全部群成员(%ld)",self.wh_room.members.count] forState:UIControlStateNormal];//self.userSize
        //        }
        
        //        [self setDeleteMode:YES];
        
        [g_notify postNotificationName:kRoomMembersRefresh_WHNotification object:[NSNumber numberWithInt:self.userSize]];
        
    }
    
    
}

- (void)onAfterDelMember:(memberData *)member{
    _modifyType = kRoomRemind_DelMember;
    _toUserId = [NSString stringWithFormat:@"%ld",member.userId];
    _toUserName = member.userNickName;
//    [self sendSelfMsg:_modifyType content:nil];
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
//    [_wait start];
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click ParentView:(UIView *)parent{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.wh_delegate = self;
    [parent addSubview:btn];
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
    //前面的说明label
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, 200, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    p.tag = TAG_LABEL;
    [btn addSubview:p];
//    [p release];
    //分割线
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,parent.frame.size.width,1)];
        line.backgroundColor = HEXCOLOR(0xF8F8F7);
        [btn addSubview:line];
//        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-1,parent.frame.size.width,1)];
        line.backgroundColor = HEXCOLOR(0xF8F8F7);
        [btn addSubview:line];
//        [line release];
    }
    //这个选择器仅用于判断，之后会修改为不可点击
    SEL check = @selector(switchAction:);
    //创建switch
    if(click == check){
        CGFloat switchY = (HEIGHT - 31) / 2.f;
        UISwitch * switchView = [[UISwitch alloc]initWithFrame:CGRectMake(parent.frame.size.width-INSETS-51, switchY, 20, 20)];
        if ([title isEqualToString:Localized(@"WaHu_JXRoomMember_WaHuVC_NotTalk")]) {
            switchView.tag = 15460;
            switchView.on =NO;
        }else if ([title isEqualToString:Localized(@"WaHu_JXRoomMember_WaHuVC_NotMessage")]) {
            if ([_user.status intValue] == friend_status_black) {
                switchView.on = YES;
            }else{
                switchView.on = NO;
            }
        }else if ([title isEqualToString:Localized(@"JX_TotalSilence")]) {
            switchView.tag = 15461;
            switchView.on = wh_room.talkTime > 0 ? YES : NO;
        }else if ([title isEqualToString:Localized(@"WaHu_JXRoomMember_WaHuVC_CloseStrongReminder")]) {
            //强提醒
            switchView.tag = 15462;
            NSNumber *isCloseStrongReminder = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_group_strong_reminder_%@",g_myself.userId,wh_room.roomJid]];
            BOOL isClose = [isCloseStrongReminder boolValue];
            switchView.on = isClose;
        }
        
        switchView.onTintColor = THEMECOLOR;
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        [btn addSubview:switchView];
        //取消调用switchAction
        btn.didTouch = @selector(hideKeyboard);
        
    }else if(click){
        btn.frame = CGRectMake(btn.frame.origin.x -20, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
        
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(parent.frame.size.width - 19, (HEIGHT-12)/2.f, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [btn addSubview:iv];
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
    p.textColor = [UIColor lightGrayColor];
    p.placeholder = hint;
    p.font = sysFontWithSize(15);
    [parent addSubview:p];
//    [p release];
    return p;
}

-(JXLabel*)WH_createLabel:(UIView*)parent default:(NSString*)s isClick:(BOOL) boo{
    JXLabel * p;
    if (boo) {
        CGFloat w = (parent.frame.size.width - INSETS)/2 ;
        p = [[JXLabel alloc] initWithFrame:CGRectMake(parent.frame.size.width - 12 - 7 - 8 - w,INSETS,w,HEIGHT-INSETS*2)];
    }else{
        p = [[JXLabel alloc] initWithFrame:CGRectMake(parent.frame.size.width/2 ,INSETS,parent.frame.size.width/2 - INSETS,HEIGHT-INSETS*2)];
    }
    
    p.userInteractionEnabled = NO;
    p.text = s;
    p.textColor = [UIColor lightGrayColor];
    p.font = sysFontWithSize(15);
    p.textAlignment = NSTextAlignmentRight;
    [parent addSubview:p];
//    [p release];
    return p;
}

-(void)onUpdate{
    if(![self getInputValue])
        return;
}

-(BOOL)getInputValue{
    if([_roomName.text length]<=0){
        [g_App showAlert:Localized(@"JX_InputName")];
        return NO;
    }
    return  YES;
}

-(BOOL)hideKeyboard{
//    BOOL b = _roomName.editing || _desc.editing || _userName.editing;
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)createUserList{
    WH_JXImageView* q=[[WH_JXImageView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT)];
    q.userInteractionEnabled = YES;
    if(_isAdmin){
        q.wh_delegate = self;
        q.didTouch = @selector(onNewNote);
    }
    [_heads addSubview:q];
    
    [_images addObject:q];
    
    
    WH_JXImageView *p = [self WH_createMiXinButton:Localized(@"JX_GroupChatMembers") drawTop:YES drawBottom:NO must:NO click:@selector(onShowMembers) ParentView:q];
    p.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, HEIGHT);
    _note = [self WH_createLabel:p default:[NSString stringWithFormat:Localized(@"JX_Have%dPeople"),self.userSize] isClick:YES];
    [_images addObject:p];
    [_images addObject:_note];
    
//    [q release];
//    JXLabel* p=[[JXLabel alloc]initWithFrame:CGRectMake(20, 0, 60, 75)];
//    p.backgroundColor = [UIColor whiteColor];
//    p.textAlignment = NSTextAlignmentRight;
//    p.font = sysFontWithSize(13);
//    p.textColor = [UIColor blackColor];
//    p.text = Localized(@"WaHu_JXRoomMember_WHVC_RoomAdv");
//    p.userInteractionEnabled = NO;
//    [q addSubview:p];
//    [p release];
//    [_images addObject:p];
    
//    _note=[[UILabel alloc]initWithFrame:CGRectMake(95, 0, JX_SCREEN_WIDTH-105, 75)];
//    _note.backgroundColor = [UIColor whiteColor];
//    _note.numberOfLines = 0;
////    _note.lineBreakMode = UILineBreakModeWordWrap;
//    _note.font = sysFontWithSize(13);
////    _note.offset = -15;
//    _note.text = room.note;
//    _note.textColor = [UIColor blackColor];
//    _note.userInteractionEnabled = NO;
//    [q addSubview:_note];
//    [_note release];
//    [_images addObject:_note];

//    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,_note.frame.size.height,JX_SCREEN_WIDTH,0.5)];
//    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
//    [q addSubview:line];
////    [line release];
//    [_images addObject:line];
}

#pragma mark 显示群成员
- (void)onShowMembers {
    
    WH_JXRoomMemberList_WHVC *vc = [[WH_JXRoomMemberList_WHVC alloc] init];
    vc.title = Localized(@"JX_GroupMembers");
    vc.room = self.wh_room;
    vc.type = Type_Default;
    [g_navigation pushViewController:vc animated:YES];
}
#pragma mark -- 创建群组信息控件
-(int)createRoomMember:(int) height{
    [self.topOneView removeFromSuperview];
    UIImageView *topOneView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, height, JX_SCREEN_WIDTH-leftRightMargin*2, HEIGHT * 4)];
    topOneView.userInteractionEnabled = YES;
    topOneView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:topOneView];
    topOneView.layer.cornerRadius = g_factory.cardCornerRadius;
    topOneView.layer.masksToBounds = YES;
    topOneView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    topOneView.layer.borderWidth = g_factory.cardBorderWithd;
    self.topOneView = topOneView;
    
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    int membHeight = 0;
    
    //群组名称
    self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_RoomName") drawTop:YES drawBottom:YES must:NO click:@selector(onRoomName) ParentView:topOneView];
    self.wh_iv.frame = CGRectMake(0, membHeight, topOneView.frame.size.width, HEIGHT);
    _roomName = [self WH_createLabel:self.wh_iv default:wh_room.name isClick:YES];
    membHeight+=self.wh_iv.frame.size.height;
    
    //群说明(2019.11.26去掉群说明)
//    self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_RoomExplain") drawTop:NO drawBottom:YES must:NO click:@selector(onRoomDesc) ParentView:topOneView];
//    self.wh_iv.frame = CGRectMake(0, membHeight, topOneView.frame.size.width, HEIGHT);
//    _desc = [self WH_createLabel:self.wh_iv default:wh_room.desc isClick:YES];
//    membHeight+=self.wh_iv.frame.size.height;
    
//    if (([data.role intValue] == 1 || [data.role intValue] == 2) && ([g_myself.role containsObject:@5] || [g_myself.role containsObject:@6])) {
//        self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_MaximumPeople") drawTop:NO drawBottom:YES must:NO click:@selector(onRoomNumber) ParentView:topOneView];
//        self.wh_iv.frame = CGRectMake(0, membHeight, topOneView.frame.size.width, HEIGHT);
//        _roomNum = [self WH_createLabel:self.wh_iv default:[NSString stringWithFormat:@"%d",wh_room.maxCount] isClick:YES];
//        membHeight+=self.wh_iv.frame.size.height;
//    }
    
    //群公告
    self.wh_iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WaHuVC_RoomAdv") drawTop:NO drawBottom:YES must:NO click:@selector(onNewNote) ParentView:topOneView];
    self.wh_iv.frame = CGRectMake(0, membHeight, topOneView.frame.size.width, HEIGHT);
    _note = [self WH_createLabel:self.wh_iv default:wh_room.note ? wh_room.note : Localized(@"JX_NotAch") isClick:YES];
    membHeight+=self.wh_iv.frame.size.height;
    
    NSDictionary *notiDict = self.noticeArr.firstObject; // 这四行代码为避免当公告为空时，进入群设置列表群公告显示存在公告
    NSString *notiText = [notiDict objectForKey:@"text"];
    _note.text = notiText ? notiText : Localized(@"JX_NotAch");
    wh_room.note = notiText ? notiText : Localized(@"JX_NotAch");
    
    self.wh_iv = [self WH_createMiXinButton:Localized(@"JXQR_QRImage") drawTop:NO drawBottom:YES must:NO click:@selector(showUserQRCode) ParentView:topOneView];
    self.wh_iv.frame = CGRectMake(0, membHeight, topOneView.frame.size.width, HEIGHT);
    UIImageView * qrView = [[UIImageView alloc] init];
    qrView.frame = CGRectMake(self.wh_iv.frame.size.width-12-7-8-30, (CGRectGetHeight(self.wh_iv.frame) - 30) / 2.f, 30, 30);
    qrView.image = [UIImage imageNamed:@"qrcodeImage"];
    [self.wh_iv addSubview:qrView];

    
    membHeight+=self.wh_iv.frame.size.height;
    
    NSString *btnTitle = _isAdmin ? Localized(@"JX_ModifyFullNickname") : Localized(@"WaHu_JXRoomMember_WaHuVC_NickName");
    self.wh_iv = [self WH_createMiXinButton:btnTitle drawTop:NO drawBottom:YES must:NO click:@selector(onNickName) ParentView:topOneView];
    self.wh_iv.frame = CGRectMake(0, membHeight, topOneView.frame.size.width, HEIGHT);
    if (!_isAdmin) {
        _userName = [self WH_createLabel:self.wh_iv default:[wh_room getNickNameInRoom] isClick:YES];
    }
    membHeight+=self.wh_iv.frame.size.height;
    membHeight+=topBottomMargin;
    
    CGFloat viewOrginY = membHeight + height;

    if (self.wh_room.isShowSignIn == 1 && IS_SHOW_GROUPSIGNIN) {
        //群签到
        UIImageView *tView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, membHeight + height, JX_SCREEN_WIDTH - leftRightMargin*2, HEIGHT)];
        tView.userInteractionEnabled = YES;
        tView.backgroundColor = [UIColor whiteColor];
        [self.wh_tableBody addSubview:tView];
        tView.layer.masksToBounds = YES;
        tView.layer.cornerRadius = g_factory.cardCornerRadius;
        tView.layer.borderWidth = g_factory.cardBorderWithd;
        tView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        
        self.wh_iv = [self WH_createMiXinButton:@"群签到" drawTop:NO drawBottom:NO must:NO click:@selector(groupSignInMethod) ParentView:tView];
        [self.wh_iv setFrame:CGRectMake(0, 0, tView.frame.size.width, CGRectGetHeight(tView.frame))];
        
        membHeight+=tView.frame.size.height;
        membHeight+=topBottomMargin;
        
        viewOrginY = CGRectGetMaxY(tView.frame) + topBottomMargin;
    }
    
    //群成员
    int imageHei = [self createImagesWithHeight:viewOrginY];
    membHeight+=imageHei;
    membHeight+=topBottomMargin;
    
    if(_isAdmin){
//        membHeight += topBottomMargin;
        [self.topSixView removeFromSuperview];
        UIImageView *topSixView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, membHeight+height, JX_SCREEN_WIDTH-leftRightMargin*2, HEIGHT)];
        topSixView.userInteractionEnabled = YES;
        topSixView.backgroundColor = [UIColor whiteColor];
        [self.wh_tableBody addSubview:topSixView];
        topSixView.layer.cornerRadius = g_factory.cardCornerRadius;
        topSixView.layer.masksToBounds = YES;
        topSixView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        topSixView.layer.borderWidth = g_factory.cardBorderWithd;
        self.topSixView = topSixView;
        ///群管理
        self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_GroupManagement") drawTop:NO drawBottom:YES must:NO click:@selector(groupManagement) ParentView:topSixView];
        self.wh_iv.frame = CGRectMake(0, 0, topSixView.frame.size.width, HEIGHT);
        membHeight+=self.wh_iv.frame.size.height;
    }
    
    if ([data.role intValue] == 1 || [data.role intValue] == 2) {
        ///禁言
        membHeight+=topBottomMargin;
        [self.topFiveView removeFromSuperview];
        UIImageView *topFiveView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, membHeight + topBottomMargin, JX_SCREEN_WIDTH-leftRightMargin*2, HEIGHT * 2)];
        topFiveView.userInteractionEnabled = YES;
        topFiveView.backgroundColor = [UIColor whiteColor];
        [self.wh_tableBody addSubview:topFiveView];
        topFiveView.layer.cornerRadius = g_factory.cardCornerRadius;
        topFiveView.layer.masksToBounds = YES;
        topFiveView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        topFiveView.layer.borderWidth = g_factory.cardBorderWithd;
        self.topFiveView = topFiveView;
        self.wh_iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WaHuVC_NotTalk") drawTop:NO drawBottom:YES must:NO click:@selector(notTalkAction) ParentView:topFiveView];
        self.wh_iv.frame = CGRectMake(0, 0, topFiveView.frame.size.width, HEIGHT);
        membHeight+=self.wh_iv.frame.size.height;
        ///全体禁言
        self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_TotalSilence") drawTop:NO drawBottom:YES must:NO click:@selector(switchAction:) ParentView:topFiveView];
        self.wh_iv.frame = CGRectMake(0, HEIGHT, topFiveView.frame.size.width, HEIGHT);
        membHeight+=self.wh_iv.frame.size.height;
    }
    else {
        membHeight -= topBottomMargin;
    }

    [self.topTwoView removeFromSuperview];
    UIImageView *topTwoView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, membHeight+topBottomMargin+topBottomMargin, JX_SCREEN_WIDTH-leftRightMargin*2, HEIGHT)];
    topTwoView.userInteractionEnabled = YES;
    topTwoView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:topTwoView];
    topTwoView.layer.cornerRadius = g_factory.cardCornerRadius;
    topTwoView.layer.masksToBounds = YES;
    topTwoView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    topTwoView.layer.borderWidth = g_factory.cardBorderWithd;
    self.topTwoView = topTwoView;
    
    int topTwoHei = 0;
    if ([data.role intValue] == 1 || [data.role intValue] == 2) {
        //设置群头像
        self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_SetGroupAvatar") drawTop:NO drawBottom:YES must:NO click:@selector(settingRoomIcon) ParentView:self.topTwoView];
        self.wh_iv.frame = CGRectMake(0, topTwoHei, topTwoView.frame.size.width, HEIGHT);
        //    _userName = [self WH_createLabel:self.iv default:[room getNickNameInRoom] isClick:YES];
        membHeight+=self.wh_iv.frame.size.height;
        topTwoHei +=self.wh_iv.frame.size.height;
    }

    //群文件
    self.wh_iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WaHuVC_ShareFile") drawTop:NO drawBottom:YES must:NO click:@selector(shareFileAction) ParentView:self.topTwoView];
    self.wh_iv.frame = CGRectMake(0, topTwoHei, topTwoView.frame.size.width, HEIGHT);
    //    _userName = [self WH_createLabel:self.iv default:[room getNickNameInRoom] isClick:YES];
    membHeight+=self.wh_iv.frame.size.height;
    membHeight+=topBottomMargin;
    topTwoHei +=self.wh_iv.frame.size.height;
    
    CGRect twoFrame = topTwoView.frame;
    twoFrame.size.height = topTwoHei;
    topTwoView.frame = twoFrame;
    
    
    [self.topThreeView removeFromSuperview];
    UIImageView *topThreeView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, membHeight+topBottomMargin + topBottomMargin, JX_SCREEN_WIDTH-leftRightMargin*2, HEIGHT * 4)];
    topThreeView.userInteractionEnabled = YES;
    topThreeView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:topThreeView];
    topThreeView.layer.cornerRadius = g_factory.cardCornerRadius;
    topThreeView.layer.masksToBounds = YES;
    topThreeView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    topThreeView.layer.borderWidth = g_factory.cardBorderWithd;
    self.topThreeView = topThreeView;
    
    CGFloat switchY = (HEIGHT - 31) / 2.f;
    //置顶聊天
    self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_ChatAtTheTop") drawTop:NO drawBottom:YES must:NO click:nil ParentView:topThreeView];
    self.wh_iv.frame = CGRectMake(0, 0, topThreeView.frame.size.width, HEIGHT);
    UISwitch *topSwitch = [[UISwitch alloc] init];
    topSwitch.onTintColor = THEMECOLOR;
    topSwitch.frame = CGRectMake(topThreeView.frame.size.width-INSETS-51, switchY, 0, 0);
    topSwitch.center = CGPointMake(topSwitch.center.x, self.wh_iv.frame.size.height/2);
    [topSwitch addTarget:self action:@selector(topSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [topSwitch setOn:self.user.topTime];
    [self.wh_iv addSubview:topSwitch];
    membHeight+=self.wh_iv.frame.size.height;
    
    //消息免打扰
    self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_MessageFree") drawTop:NO drawBottom:YES must:NO click:nil ParentView:topThreeView];
    self.wh_iv.frame = CGRectMake(0, HEIGHT, topThreeView.frame.size.width, HEIGHT);
    _messageFreeSwitch = [[UISwitch alloc] init];
    _messageFreeSwitch.onTintColor = THEMECOLOR;
    _messageFreeSwitch.frame = CGRectMake(topThreeView.frame.size.width-INSETS-51, switchY, 0, 0);
    _messageFreeSwitch.center = CGPointMake(_messageFreeSwitch.center.x, self.wh_iv.frame.size.height/2);
    [_messageFreeSwitch addTarget:self action:@selector(messageFreeSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_iv addSubview:_messageFreeSwitch];
    membHeight+=self.wh_iv.frame.size.height;
    
//    for (memberData *data in room.members) {
//
//        if ([[NSString stringWithFormat:@"%ld",data.userId] isEqualToString: MY_USER_ID]) {
//            [_messageFreeSwitch setOn:data.offlineNoPushMsg > 0 ? YES : NO];
//
//            break;
//        }
//    }
    //设置免打扰初始值
    [_messageFreeSwitch setOn:self.user.offlineNoPushMsg.boolValue];
    
    //屏蔽群消息
    NSString * s = Localized(@"WaHu_JXRoomMember_WaHuVC_NotMessage");
    self.wh_iv = [self WH_createMiXinButton:s drawTop:NO drawBottom:NO must:NO click:@selector(switchAction:) ParentView:topThreeView];
    self.wh_iv.frame = CGRectMake(0, HEIGHT *2, topThreeView.frame.size.width, HEIGHT);
    membHeight+=self.wh_iv.frame.size.height;
    _blackBtn = self.wh_iv;
    
    
    
    //关闭强提醒
    self.wh_iv = [self WH_createMiXinButton:Localized(@"WaHu_JXRoomMember_WaHuVC_CloseStrongReminder") drawTop:NO drawBottom:YES must:NO click:@selector(switchAction:) ParentView:topThreeView];
    self.wh_iv.frame = CGRectMake(0, HEIGHT *3, topThreeView.frame.size.width, HEIGHT);
    membHeight+=self.wh_iv.frame.size.height;
    
    
    membHeight += topBottomMargin;
    
    [self.topFourView removeFromSuperview];
    UIImageView *topFourView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, membHeight+topBottomMargin + topBottomMargin, JX_SCREEN_WIDTH-leftRightMargin*2, HEIGHT * 3)];
    topFourView.userInteractionEnabled = YES;
    topFourView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:topFourView];
    topFourView.layer.cornerRadius = g_factory.cardCornerRadius;
    topFourView.layer.masksToBounds = YES;
    topFourView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    topFourView.layer.borderWidth = g_factory.cardBorderWithd;
    self.topFourView = topFourView;
    //消息过期自动销毁
    int fourViewHei = 0;
    /** 消息过期自动销毁功能隐藏 19.09.24 hanf
     if(_isAdmin){
        self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_MessageAutoDestroyed") drawTop:NO drawBottom:YES must:NO click:@selector(chatRecordTimeOutAction) ParentView:topFourView];
        self.wh_iv.frame = CGRectMake(0, fourViewHei, topFourView.frame.size.width, HEIGHT);
        double outTime = [self.user.chatRecordTimeOut doubleValue];
        NSString *str;
        if (outTime <= 0) {
            str = _pickerArr[0];
        }else if (outTime == 0.04) {
            str = _pickerArr[1];
        }else if (outTime == 1) {
            str = _pickerArr[2];
        }else if (outTime == 7) {
            str = _pickerArr[3];
        }else if (outTime == 30) {
            str = _pickerArr[4];
        }else if (outTime == 90) {
            str = _pickerArr[5];
        }else{
            str = _pickerArr[6];
        }
        _chatRecordTimeOutLabel = [self WH_createLabel:self.wh_iv default:str isClick:YES];
        membHeight+=self.wh_iv.frame.size.height;
        fourViewHei += self.wh_iv.frame.size.height;
    }*/
    
    ///查找聊天记录
    self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_LookupChatRecords") drawTop:NO drawBottom:YES must:NO click:@selector(searchChatLog) ParentView:topFourView];
    self.wh_iv.frame = CGRectMake(0, fourViewHei, topFourView.frame.size.width, HEIGHT);
    //    _userName = [self WH_createLabel:self.iv default:[room getNickNameInRoom] isClick:YES];
    membHeight+=self.wh_iv.frame.size.height;
    fourViewHei += self.wh_iv.frame.size.height;
    
    ///清空聊天记录
    self.wh_iv = [self WH_createMiXinButton:Localized(@"JX_EmptyChatRecords") drawTop:NO drawBottom:YES must:NO click:@selector(cleanMessageLog) ParentView:topFourView];
    self.wh_iv.frame = CGRectMake(0, fourViewHei, topFourView.frame.size.width, HEIGHT);
    membHeight+=self.wh_iv.frame.size.height;
    fourViewHei += self.wh_iv.frame.size.height;
    
    CGRect fourFrame = topFourView.frame;
    fourFrame.size.height = fourViewHei;
    topFourView.frame = fourFrame;
    
    ///举报
    membHeight += topBottomMargin;
    [self.topSevenView removeFromSuperview];
    UIImageView *topSevenView = [[UIImageView alloc] initWithFrame:CGRectMake(leftRightMargin, membHeight+topBottomMargin + topBottomMargin, JX_SCREEN_WIDTH-leftRightMargin*2, HEIGHT)];
    topSevenView.userInteractionEnabled = YES;
    topSevenView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:topSevenView];
    topSevenView.layer.cornerRadius = g_factory.cardCornerRadius;
    topSevenView.layer.masksToBounds = YES;
    topSevenView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    topSevenView.layer.borderWidth = g_factory.cardBorderWithd;
    self.topSevenView = topSevenView;
    self.wh_iv = [self WH_createMiXinButton:Localized(@"WaHu_JXUserInfo_WaHuVC_Report") drawTop:NO drawBottom:YES must:NO click:@selector(reportUserView) ParentView:topSevenView];
    self.wh_iv.frame = CGRectMake(0, 0, topSevenView.frame.size.width, HEIGHT);
    membHeight+=self.wh_iv.frame.size.height;
    
    if(_isAdmin){
        
        
//        self.iv = [self WH_createMiXinButton:Localized(@"JX_RoomShowRead") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        _readSwitch = [[UISwitch alloc] init];
//        _readSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        _readSwitch.center = CGPointMake(_readSwitch.center.x, self.iv.frame.size.height/2);
//        [_readSwitch addTarget:self action:@selector(readSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.iv addSubview:_readSwitch];
//        membHeight+=self.iv.frame.size.height;
//
//        _readSwitch.on = room.showRead;
//
//        self.iv = [self WH_createMiXinButton:Localized(@"JX_PublicGroups") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *lookSwitch = [[UISwitch alloc] init];
//        lookSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        lookSwitch.center = CGPointMake(lookSwitch.center.x, self.iv.frame.size.height/2);
//        [lookSwitch addTarget:self action:@selector(lookSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [lookSwitch setOn:!room.isLook];
//        [self.iv addSubview:lookSwitch];
//        membHeight+=self.iv.frame.size.height;
//
//        self.iv = [self WH_createMiXinButton:Localized(@"JX_OpenGroupValidation") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *needVerifySwitch = [[UISwitch alloc] init];
//        needVerifySwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        needVerifySwitch.center = CGPointMake(needVerifySwitch.center.x, self.iv.frame.size.height/2);
//        [needVerifySwitch addTarget:self action:@selector(needVerifySwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [needVerifySwitch setOn:room.isNeedVerify];
//        [self.iv addSubview:needVerifySwitch];
//        membHeight+=self.iv.frame.size.height;
//
//        self.iv = [self WH_createMiXinButton:Localized(@"JX_DisplayGroupMemberList") drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *showMemberSwitch = [[UISwitch alloc] init];
//        showMemberSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        showMemberSwitch.center = CGPointMake(_readSwitch.center.x, self.iv.frame.size.height/2);
//        [showMemberSwitch addTarget:self action:@selector(showMemberSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.iv addSubview:showMemberSwitch];
//        [showMemberSwitch setOn:room.showMember];
//        membHeight+=self.iv.frame.size.height;
//
//        self.iv = [self WH_createMiXinButton:@"允许群成员在群组内发送名片" drawTop:NO drawBottom:YES must:NO click:nil ParentView:_memberView];
//        self.iv.frame = CGRectMake(0, membHeight, JX_SCREEN_WIDTH, HEIGHT);
//        UISwitch *allowSendCardSwitch = [[UISwitch alloc] init];
//        allowSendCardSwitch.frame = CGRectMake(JX_SCREEN_WIDTH-INSETS-51, 6, 0, 0);
//        allowSendCardSwitch.center = CGPointMake(allowSendCardSwitch.center.x, self.iv.frame.size.height/2);
//        [allowSendCardSwitch addTarget:self action:@selector(allowSendCardSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [allowSendCardSwitch setOn:room.allowSendCard];
//        [self.iv addSubview:allowSendCardSwitch];
//        membHeight+=self.iv.frame.size.height;
    }
    
    
    membHeight+=topBottomMargin;
    
    [self.exitBtn removeFromSuperview];
    UIButton* _btn;
    if(_isMyRoom)
        _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JX_DeleteRoom") target:self action:@selector(onDelRoom)];
    else
        _btn = [UIFactory WH_create_WHCommonButton:Localized(@"WaHu_JXRoomMember_WaHuVC_OutPutRoom") target:self action:@selector(onQuitRoom)];
    _btn.frame = CGRectMake(INSETS, membHeight+topBottomMargin + topBottomMargin, WIDTH, HEIGHT);
    _btn.userInteractionEnabled = YES;
    _btn.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:_btn];
    _btn.layer.cornerRadius = g_factory.cardCornerRadius;
    _btn.layer.masksToBounds = YES;
    _btn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    _btn.layer.borderWidth = g_factory.cardBorderWithd;
    
    [_btn setBackgroundImage:nil forState:UIControlStateNormal];
    [_btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    _btn.backgroundColor = [UIColor whiteColor];
    [_btn setTitleColor:HEXCOLOR(0xED6350) forState:UIControlStateNormal];
    [self.wh_tableBody addSubview:_btn];
    self.exitBtn = _btn;
    return membHeight;
}

#pragma mark 群签到
- (void)groupSignInMethod {
    WH_GroupSignIn_WHViewController *gsiVC = [[WH_GroupSignIn_WHViewController alloc] init];
    gsiVC.room = self.wh_room;
    [g_navigation pushViewController:gsiVC animated:YES];
}

- (void)settingRoomIcon {
    CGFloat viewH = 191;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 191+24;
    }
    
    self.wh_setGroupHeadsview = [[WH_SetGroupHeads_WHView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH)];
    [self.wh_setGroupHeadsview showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(self.wh_setGroupHeadsview) weakShare = self.wh_setGroupHeadsview;
    __weak typeof(self) weakSelf = self;
    [self.wh_setGroupHeadsview setWh_selectActionBlock:^(NSInteger buttonTag) {
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
    
//    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
//    actionVC.delegate = self;
//    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        //选择图片模式
        ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
        //    [g_window addSubview:ipc.view];
        if (IS_PAD) {
            UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
            [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else {
            [self presentViewController:ipc animated:YES completion:nil];
        }
        
    }else {
        WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
        vc.cameraDelegate = self;
        vc.isPhoto = YES;
        vc = [vc init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    self.roomHead = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    if (!IsStringNull(self.wh_chatRoom.roomId)) {
        [g_server setGroupAvatarServlet:self.wh_chatRoom.roomJid image:self.roomHead toView:self];
    } else {
        [g_server setGroupAvatarServlet:self.wh_room.roomJid image:self.roomHead toView:self];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.roomHead = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
    if (!IsStringNull(self.wh_chatRoom.roomId)) {
        [g_server setGroupAvatarServlet:self.wh_chatRoom.roomJid image:self.roomHead toView:self];
    } else {
        [g_server setGroupAvatarServlet:self.wh_room.roomJid image:self.roomHead toView:self];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:nil];
}

/**
 重置 self.wh_tableBody.contentSize

 @param height <#height description#>
 */
- (void)setRoomframeWithHeight:(int)height {
    /// 设置scrollview的content大小
    float bottomMargin = THE_DEVICE_HAVE_HEAD ? 59 - JX_SCREEN_BOTTOM + 12 : 12;
    if (height + JX_SCREEN_TOP > JX_SCREEN_HEIGHT) {
        self.wh_tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, height + JX_SCREEN_TOP + bottomMargin);
    }
    else {
        self.wh_tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_TOP);
    }
}

-(int)createImagesWithHeight:(int)height{
    
    if (wh_room == nil) {
        NSDictionary * groupDict = [self.pData.user toDictionary];
        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
        [roomdata WH_getDataFromDict:groupDict];
//        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
//        NSDictionary * groupDict = [user toDictionary];
//        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
//        [roomdata WH_getDataFromDict:groupDict];
        NSArray * allMem = [memberData fetchAllMembers:self.pData.user.roomId];
        roomdata.members = [allMem mutableCopy];
        self.wh_room = roomdata;
    }
    
    //如果没有群成员数据,去请求获取数据
    if (wh_room.members.count == 0) {
        [self redrawView222];
        
    }
    //群成员数据排序
    for (NSInteger i = 0; i < wh_room.members.count; i ++) {
        memberData *data1 = wh_room.members[i];
            for (NSInteger j = i + 1; j < wh_room.members.count; j ++) {
                memberData *data2 = wh_room.members[j];
                
                if ([data2.role intValue] < [data1.role intValue]) {
                    memberData *temp = data1;
                    data1 = data2;
                    wh_room.members[i] = data2;
                    wh_room.members[j] = temp;
                }
        }
    }
    
//    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    BOOL isShow = YES;
//    BOOL isShow = NO;
//    if ([data.role intValue] == 1 || [data.role intValue] == 2 || wh_room.showMember){
//        //showMember 显示群成员给普通用户，1：显示  0：不显示 默认显示
//        //role 角色 1创建者,2管理员,3成员,4隐身人,5监控人
//        isShow = YES;
//    }
    
    for(NSInteger i=[_images count]-1;i>=0;i--){
        UIView* iv = [_images objectAtIndex:i];
        [iv removeFromSuperview];
        iv = nil;
    }
    [_images removeAllObjects];
    [_names removeAllObjects];
    [_deleteArr removeAllObjects];
    
    [_heads removeFromSuperview];
    _heads = [[UIView alloc] initWithFrame:CGRectMake(INSETS, 0, JX_SCREEN_WIDTH-INSETS*2, 52)];
    _heads.backgroundColor = [UIColor whiteColor];
    _heads.layer.cornerRadius = g_factory.cardCornerRadius;
    _heads.layer.masksToBounds = YES;
    _heads.layer.borderColor = g_factory.cardBorderColor.CGColor;
    _heads.layer.borderWidth = g_factory.cardBorderWithd;
    
    [self.wh_tableBody addSubview:_heads];
//    [_heads release];
    [_images addObject:_heads];
    
    //动态分配行数，且居中
    int screenWidth = JX_SCREEN_WIDTH-INSETS*2;
    //+126让间隙变大，更美观
//    float widthInset = (screenWidth%37 +126)/(screenWidth/52.0);
    float widthInset = (screenWidth-37*5)/6;
    
    float x = widthInset;
    int y = 16;
    //收起状态显示两行10个+两个系统图标
    unsigned long maxShow = ([wh_room.members count]>8 && _unfoldMode) ? 8 : [wh_room.members count];
    
    /// 获取当前登录用户
    memberData *loginMember = [self getCurrentLoginMerber];
    /// 当前登录用户是不是管理者
    BOOL isManger = [self isManger:loginMember];
    
    for(int i=0;i<maxShow+2;i++){
        //用于判断创建是头像还是系统图标
        long n ;
        memberData* user = nil;
        if(i<maxShow){
            user = [wh_room.members objectAtIndex:i];
            n = user.userId;
        }
        if (i < maxShow && !wh_room.showMember) {
            if (![[NSString stringWithFormat:@"%ld",user.userId] isEqualToString:MY_USER_ID] && ![[NSString stringWithFormat:@"%ld",user.userId] isEqualToString:[NSString stringWithFormat:@"%ld",self.wh_room.userId]] && ([user.role integerValue] != 1)  && ([user.role integerValue] != 2)) {
                continue;
            }
        }
        if(i==maxShow)
            n = 0;
        if(i>maxShow)
            n = -1;
        WH_JXImageView* p = [self createImage:n index:i name:user.userNickName];
        if(p){
            
            if(x +37 >= JX_SCREEN_WIDTH){
                y += 72+10;
                x = widthInset;
            }
            
            p.frame = CGRectMake(x, y, 37, 37);
            if (n != 0 && n != -1) {
                [g_server WH_getHeadImageSmallWIthUserId:[NSString stringWithFormat:@"%ld",n] userName:user.userNickName imageView:p];
            }
            x = x+37+widthInset;
            if(n>0){
                JXLabel* b = [[JXLabel alloc]initWithFrame:CGRectMake( p.frame.origin.x-5, p.frame.origin.y+p.frame.size.height+3, 37+10, 15)];
                
                NSString *name = [NSString string];
                WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
                allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",user.userId]];
                if (_isAdmin) {
                    name = user.lordRemarkName.length > 0  ? user.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : user.userNickName;
                }else {
                    name = allUser.remarkName.length > 0  ? allUser.remarkName : user.userNickName;
                }
                
//                if (!self.wh_room.allowSendCard && [user.role intValue] != 1 && [user.role intValue] != 2) {
//                    name = [name substringToIndex:[name length]-1];
//                    name = [name stringByAppendingString:@"*"];
//                }
                /// 当前登录用户不是管理者 并且开启了不允许群成员私聊 进入判断
                if (!isManger && !self.wh_room.allowSendCard) {
                    /// 被点击用户不是自己 进入判断
                    if (user.userId != loginMember.userId && ![self isManger:user]) {
                        if (GroupMemberShowPlaceholderString) {
                            name = [name substringToIndex:[name length]-1];
                            name = [name stringByAppendingString:@"*"];
                        }
                        
                    }
                }

                b.text = name;
                b.font = sysFontWithSize(12);
                b.textColor = HEXCOLOR(0x555555);
                b.textAlignment = NSTextAlignmentCenter;
                [_heads addSubview:b];
//                [b release];
                [_names addObject:b];
            }
        }

        memberData *data = [self.wh_room getMember:g_myself.userId];
        BOOL flag = NO;
        if ([data.role intValue] == 1) {
            flag = [user.role intValue] != 1;
        }else if([data.role intValue] == 2){
            flag = [user.role intValue] != 1 && [user.role intValue] != 2;
        }
        if(n != [g_myself.userId intValue] && n>0 && flag){
            WH_JXImageView* iv = [[WH_JXImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(p.frame) - 15, p.frame.origin.y - 5, 20, 20)];
            iv.didTouch = @selector(onDelete:);
            iv.wh_delegate = self;
            iv.tag = i;
            iv.image = [UIImage imageNamed:@"delete"];
            iv.hidden = !_delMode;
            [_heads addSubview:iv];
            //        [iv release];
            
            [_deleteArr addObject:iv];
        }
        
        user = nil;
    }
    //换行后添加高度
    int n = y;
    if(x > widthInset)
        n += 72+10;
    
    if (isShow) {
        //创建公告
        self.seeAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.seeAllBtn.frame = CGRectMake(0, n, _heads.frame.size.width, 30);
        [self.seeAllBtn setTitle:[NSString stringWithFormat:@"查看全部群成员(%ld)",(self.membersNum > 0)?self.membersNum:self.wh_room.members.count] forState:UIControlStateNormal];//self.userSize
        [self.seeAllBtn setTitleColor:HEXCOLOR(0x969696) forState:UIControlStateNormal];
        [self.seeAllBtn addTarget:self action:@selector(onShowMembers) forControlEvents:UIControlEventTouchUpInside];
        self.seeAllBtn.titleLabel.font = sysFontWithSize(14);
        [_heads addSubview:self.seeAllBtn];
        n+=40;//收起箭头
    }
    
    
//    if (room.members.count > 8 && isShow) {
//        _unfoldView = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, n-5, 25, 25)];
//        _unfoldView.center = CGPointMake(screenWidth/2, _unfoldView.center.y);
//        if (_unfoldMode) {
//            _unfoldView.image = [UIImage imageNamed:@"room_unfold"];
//        }else{
//            _unfoldView.image = [UIImage imageNamed:@"pack_up_1"];
//        }
//        _unfoldView.delegate = self;
//        _unfoldView.didTouch = @selector(unfoldViewAction);
//        [_heads addSubview:_unfoldView];
//
//        n+=20;//收起箭头
//    }
    _heads.frame = CGRectMake(INSETS, height, JX_SCREEN_WIDTH-INSETS*2, n);
    
    [self setRoomframeWithHeight:n + 10 + CGRectGetHeight(_memberView.frame)];
    
   return n;
}

/**
 获取当前登录用户

 @return <#return value description#>
 */
- (memberData *)getCurrentLoginMerber {
    memberData *currentMember = nil;
    WH_JXUserObject *currentUser = g_myself;
    for (memberData *member in self.wh_room.members) {
        if (member.userId == [currentUser.userId longLongValue]) {
            currentMember = member;
            break;
        }
    }
    return currentMember;
}

/**
 是否是管理员 群组(role : 1)/管理员(role : 2)均 视为 管理员

 @param user <#user description#>
 @return <#return value description#>
 */
- (BOOL)isManger:(memberData *)user {
    return [user.role intValue] == 1 || [user.role intValue] == 2;
}

-(WH_JXImageView*)createImage:(long)userId index:(int)index name:(NSString*)name{
//    memberData *data = [self.room getMember:g_myself.userId];
//    if(userId == -1){
//        if(!([data.role intValue] == 1 || [data.role intValue] == 2))
//            return nil;
//    }
//    if (userId == 0) {
//        if ([data.role intValue] == 4) {
//            return nil;
//        }
//    }
    WH_JXImageView* p = [[WH_JXImageView alloc]init];
    p.didTouch = @selector(onImage:);
    p.wh_delegate = self;
    [p headRadiusWithAngle:18.5];
    p.tag = index;
    switch (userId) {
        case 0:
            p.image = [UIImage imageNamed:@"WH_icon_group_add"];
            p.didTouch = @selector(onShowAdd);
            break;
        case -1:
            p.image = [UIImage imageNamed:@"WH_icon_reduce"];
            p.didTouch = @selector(onShowDel);
            break;
        default:{
            p.didTouch = @selector(onUser:);

            break;
        }
    }
    [_heads addSubview:p];
//    [p release];
    
    [_images addObject:p];
    return p;
}

- (void)onImage:(WH_JXImageView *)imageView {
    memberData *data = [self.wh_room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
        [g_App showAlert:Localized(@"JX_OnlyManagerSeeInfo")];
        return;
    }
    memberData *user = wh_room.members[imageView.tag];
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = [NSString stringWithFormat:@"%ld", user.userId];
    vc.wh_fromAddType = 3;
    vc.isAddFriend = data.isAddFirend;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

// 置顶
- (void)topSwitchAction:(UISwitch *)topSwitch {
    if (topSwitch.isOn) {
        self.user.topTime = [NSDate date];
    }else {
        self.user.topTime = nil;
    }
    
    [self.user WH_updateTopTime];
    
    [g_notify postNotificationName:kChatViewDisappear_WHNotification object:nil];
}

// 公开群组
- (void)lookSwitchAction:(UISwitch *)lookSwitch {
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [lookSwitch setOn:!lookSwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:2457];
    wh_room.isLook = lookSwitch.on;
    [g_server updateRoomShowRead:wh_room key:@"isLook" value:wh_room.isLook toView:self];
}

// 进群验证
- (void)needVerifySwitchAction:(UISwitch *)needVerifySwitch {
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [needVerifySwitch setOn:!needVerifySwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    wh_room.isNeedVerify = needVerifySwitch.on;
    [g_server updateRoomShowRead:wh_room key:@"isNeedVerify" value:wh_room.isNeedVerify toView:self];
}

// 显示群成员列表
- (void)showMemberSwitchAction:(UISwitch *)showMemberSwitch {
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [showMemberSwitch setOn:!showMemberSwitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_ShowMember];
    wh_room.showMember = showMemberSwitch.on;
    [g_server updateRoomShowRead:wh_room key:@"showMember" value:wh_room.showMember toView:self];
}

// 允许发送名片
- (void)allowSendCardSwitchAction:(UISwitch *)allowSendCardSwitch {
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [allowSendCardSwitch setOn:!allowSendCardSwitch.isOn];
        return;
    }
    
    self.updateType = [NSNumber numberWithInt:kRoomRemind_allowSendCard];
    wh_room.allowSendCard = allowSendCardSwitch.on;
    [g_server updateRoomShowRead:wh_room key:@"allowSendCard" value:wh_room.allowSendCard toView:self];
}

#pragma mark 清除聊天记录
- (void)cleanMessageLog {
    
    CGFloat viewH = 206;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 206+24;
    }
    WH_CustomActionSheetView *share = [[WH_CustomActionSheetView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH) WithTitle:Localized(@"JX_ConfirmDeleteGroupChatMsg")];
    
    [share showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(share) weakShare = share;
    __weak typeof(self) weakSelf = self;
    share.wh_okActionBlock = ^{
        [weakShare hideView];
        // 清除聊天记
        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
        msg.isGroup = YES;
        msg.toUserId = weakSelf.user.userId;
        [msg deleteAll];
        [g_server showMsg:Localized(@"JXAlert_DeleteOK") delay:.5];
        [g_notify postNotificationName:kRefreshChatLogNotif object:nil];
        
        // 清除本群所有任务
        [[JXSynTask sharedInstance] deleteTaskWithRoomId:weakSelf.wh_roomId];
        
//        [g_server WH_emptyMsgWithTouserId:self.user.userId type:[NSNumber numberWithInt:0] toView:self];
        [g_server WH_ClearGroupChatHistoryWithRoomId:self.wh_room.roomId toView:self];
        
    };
    share.wh_cancelActionBlock = ^{
        [weakShare hideView];
    };
    
}

// 禁言
- (void)notTalkAction {
    
    WH_JXRoomMemberList_WHVC *vc = [[WH_JXRoomMemberList_WHVC alloc] init];
    vc.title = Localized(@"JX_SilenceOfGroupMembers");
    vc.room = self.wh_room;
    vc.type = Type_NotTalk;
    [g_navigation pushViewController:vc animated:YES];
    
}

-(void)unfoldViewAction{
    _unfoldMode = !_unfoldMode;
    
    int height = [self createImagesWithHeight:0];
    height+=10;
    height += CGRectGetHeight(_memberView.frame);
    
    [UIView animateWithDuration:0.4 animations:^{
        [self setRoomframeWithHeight:height];
    }];
}

-(void)setDeleteMode:(BOOL)b{
    if(!_isAdmin)
        return;
    for(int i=0;i<[_deleteArr count];i++){
        WH_JXImageView* iv = [_deleteArr objectAtIndex:i];
        iv.didTouch = @selector(onDelete:);
        iv.hidden = !b;
        iv = nil;
    }
}

-(void)setDisableMode:(BOOL)b{
    for(int i=0;i<[_deleteArr count];i++){
        WH_JXImageView* iv = [_deleteArr objectAtIndex:i];
        iv.didTouch = @selector(onDisableSay:);
        iv.hidden = !b;
        iv = nil;
    }
}

#pragma mark - 点击减号
-(void)onShowDel{
    memberData *data = [self.wh_room getMember:g_myself.userId];
    if (([data.role intValue] == 1 || [data.role intValue] == 2)) {
//        _delMode = !_delMode;
//        [self setDeleteMode:_delMode];
        self.wh_chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:self.wh_room.roomJid title:self.wh_room.name isNew:NO];
        
//        WH_JXRoomMemberList_WHVC *vc = [[WH_JXRoomMemberList_WHVC alloc] init];
//        vc.title = Localized(@"JX_DeleteGroupMemebers");
//        vc.room = self.wh_room;
//        vc.delegate = self;
//        vc.type = Type_DelMember;
//        vc.chatRoom = self.wh_chatRoom;
//        [g_navigation pushViewController:vc animated:YES];
        
        WH_DeleteRoomMembers_ViewController *vc = [[WH_DeleteRoomMembers_ViewController alloc] init];
        vc.room = self.wh_room;
        vc.delegate = self;
        vc.chatRoom = self.wh_chatRoom;
        [g_navigation pushViewController:vc animated:YES];
        
    }else{
        //不是管理员
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotAdminCannotDoThis")];
    }
    
}

- (void)deleteRoomMembers:(WH_DeleteRoomMembers_ViewController *)vc members:(NSArray *)members {
    //刷新界面
    [self redrawView222];
}

#pragma mark - 点击加号
-(void)onShowAdd{
    
    self.wh_chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:self.wh_room.roomJid title:self.wh_room.name isNew:NO];
    
    memberData *data = [self.wh_room getMember:g_myself.userId];
    BOOL flag = [data.role intValue] == 1 || [data.role intValue] == 2;
    if (!flag && !self.wh_room.allowInviteFriend) {
        [g_App showAlert:Localized(@"JX_DisabledInviteFriends")];
        return;
    }
    if([data.role intValue] == 4) {
        [g_App showAlert:Localized(@"JX_InvisibleCan'tInviteMembers")];
        return;
    }
    WH_JXSelectFriends_WHVC* vc = [WH_JXSelectFriends_WHVC alloc];
    vc.isNewRoom = NO;
    vc.chatRoom = wh_chatRoom;
    vc.room = wh_room;
    vc.delegate = self;
    vc.didSelect = @selector(onAfterAddMember:);
    vc = [vc init];
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

//群组删除群成员调用
- (void)roomMemberList:(WH_JXRoomMemberList_WHVC *)vc delMember:(memberData *)member {
    
    [self redrawView222];
    //通知自己界面
    [self onAfterDelMember:member];
}

#pragma mark 批量删除群成员
- (void)roomMemberList:(WH_JXRoomMemberList_WHVC *)vc delMembers:(NSArray *)members {
    [self redrawView222];
    
//    [self.seeAllBtn setTitle:[NSString stringWithFormat:@"查看全部群成员(%ld)",(self.membersNum > 0)?self.membersNum:self.wh_room.members.count] forState:UIControlStateNormal];//self.userSize
}

#pragma mark 点击群成员头像事件
-(void)onUser:(WH_JXImageView*)sender{
    /**
     * allowSendCard  允许私聊，1：允许  0：不允许  默认允许
     * role 角色 1创建者,2管理员,3成员,4隐身人,5监控人
     */
    
    /// 被点击用户
    memberData *data = wh_room.members[sender.tag];
    /// 获取当前登录用户
    memberData *loginMember = [self getCurrentLoginMerber];
    /// 当前登录用户是不是管理者
    BOOL isManger = [self isManger:loginMember];
    
    /// 当前登录用户不是管理者 并且开启了不允许群成员私聊 进入判断
    if (!isManger && !self.wh_room.allowSendCard) {
        /// 被点击用户不是自己 进入判断
        if (data.userId != loginMember.userId && ![self isManger:data]) {
            return;
        }
    }
//    if (([data.role intValue] != 1 && [data.role intValue] != 2) && !self.wh_room.allowSendCard) {
//        [g_App showAlert:Localized(@"JX_NotAllowMembersSeeInfo")];
//        return;
//    }
    
    if(sender.tag >= [wh_room.members count])
        return;
    memberData* member = [wh_room.members objectAtIndex:sender.tag];
    [g_server getUser:[NSString stringWithFormat:@"%ld",member.userId] toView:self];
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = [NSString stringWithFormat:@"%ld",member.userId];
    vc.wh_fromAddType = 3;
    vc.isAddFriend = data.isAddFirend;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
    member = nil;
    
}

-(void)onDelete:(WH_JXImageView*)sender{
    if(!_isAdmin)
        return;
    if(sender.tag >= [wh_room.members count])
        return;
    _delete = (int)sender.tag;

    memberData* member = [wh_room.members objectAtIndex:sender.tag];
    
    [g_server WH_delRoomMemberWithRoomId:wh_room.roomId userId:member.userId toView:self];
    member = nil;
}



- (void)xmppRoomDidDestroy:(XMPPRoom *)sender{
    [g_notify postNotificationName:kQuitRoom_WHNotifaction object:wh_chatRoom userInfo:nil];
    [self actionQuit];
}

#pragma mark - 解散群组
-(void)onDelRoom{
    CGFloat viewH = 206;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 206+24;
    }
    WH_CustomActionSheetView *share = [[WH_CustomActionSheetView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH) WithTitle:@"你确定要解散群聊，并且删除此群的聊天记录？"];
    
    [share showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(share) weakShare = share;
    __weak typeof(self) weakSelf = self;
    share.wh_okActionBlock = ^{
        [weakShare hideView];
        [g_server delRoom:wh_room.roomId toView:weakSelf];
        
    };
    share.wh_cancelActionBlock = ^{
        [weakShare hideView];
    };
    
    
}

#pragma mark - 退出群组
-(void)onQuitRoom{
    CGFloat viewH = 206;
    if (THE_DEVICE_HAVE_HEAD) {
        viewH = 206+24;
    }
    WH_CustomActionSheetView *share = [[WH_CustomActionSheetView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH) WithTitle:@"你确定要退出群聊，并且删除此群的聊天记录？"];
    [share showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
    __weak typeof(share) weakShare = share;
    __weak typeof(self) weakSelf = self;
    share.wh_okActionBlock = ^{
        [weakShare hideView];
        _delete = -1;
        [WH_JXUserObject deleteUserAndMsg:wh_room.roomJid];
        [g_server WH_delRoomMemberWithRoomId:wh_room.roomId userId:[g_myself.userId intValue] toView:weakSelf];
        
    };
    share.wh_cancelActionBlock = ^{
        [weakShare hideView];
    };
    
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    [g_notify postNotificationName:kQuitRoom_WHNotifaction object:wh_chatRoom userInfo:nil];
    [self actionQuit];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return _allowEdit;
}

-(void)actionQuit{
    _allowEdit = NO;
    [self.view endEditing:YES];
    if (g_mainVC.msgVc.wh_array.count > 0) {
        [g_mainVC.msgVc.tableView WH_reloadRow:self.wh_rowIndex section:0];
    }

    [super actionQuit];
}

-(void)onReceiveRoomRemind:(NSNotification *)notifacation//退出房间
{
    WH_JXRoomRemind* p     = (WH_JXRoomRemind *)notifacation.object;
    if([p.objectId isEqualToString:wh_room.roomJid]){
        if([p.type intValue] == kRoomRemind_RoomName){
            self.title = p.content;
//            _userName.text = p.content;
            wh_room.name = p.content;
        }
        if([p.type intValue] == kRoomRemind_NickName){
            for(int i=0;i<[wh_room.members count];i++){
                memberData* m = [wh_room.members objectAtIndex:i];
                if(m.userId == [p.toUserId intValue]){
                    m.userNickName = p.content;
                    if (_names.count > i) {
                        UILabel* b = [_names objectAtIndex:i];
                        b.text = p.content;
                    }
                    if([p.toUserId isEqualToString:MY_USER_ID])
                        _userName.text = p.content;
                    break;
                }
                m = nil;
            }
        }
        if([p.type intValue] == kRoomRemind_DelMember){
            for(int i=0;i<[wh_room.members count];i++){
                memberData* m = [wh_room.members objectAtIndex:i];
                if(m.userId == [p.toUserId intValue]){
                    _delete = -2;
                    [wh_chatRoom removeUser:m];
                    [wh_room.members removeObjectAtIndex:i];
                    [m remove];
                    _memberCount.text = [NSString stringWithFormat:@"%d/2000",[_memberCount.text intValue] -1];
                    [self redrawView];
                    //通知自己界面
                    [self onAfterDelMember:m];
                    break;
                }
                if([p.toUserId isEqualToString:MY_USER_ID])
                    [self actionQuit];
                m = nil;
            }
        }
        if([p.type intValue] == kRoomRemind_DelRoom){
            if([p.toUserId isEqualToString:MY_USER_ID])
                [self actionQuit];
        }
        if([p.type intValue] == kRoomRemind_NewNotice){
//            _note.text = p.content ? p.content : Localized(@"JX_NotAch");
//            room.note = p.content ? p.content : Localized(@"JX_NotAch");
            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:[p.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            _note.text = p.content ? contentDic[@"text"] : Localized(@"JX_NotAch");
            if (contentDic[@"text"]) {
                _note.text = contentDic[@"text"];
            }else{
                _note.text = p.content ? p.content :Localized(@"JX_NotAch");
            }
            wh_room.note = p.content ? contentDic[@"text"] : Localized(@"JX_NotAch");
        }
        if([p.type intValue] == kRoomRemind_AddMember){
            
             [g_server WH_setRoomMemberWithRoomId:wh_room.roomId member:_currentMember toView:self];
            
        }
        
        if ([p.type intValue] == kRoomRemind_RoomTransfer) {
//            if ([p.fromUserId isEqualToString:MY_USER_ID]) {
////                [self actionQuit];
//            }
        }
        
        if ([p.type intValue] == kRoomRemind_NeedVerify) {
            if ([p.content isEqualToString:@"1"]) {
                self.wh_room.isNeedVerify = YES;
            }else {
                self.wh_room.isNeedVerify = NO;
            }
        }
    }
}

-(void)onNewNote{
    memberData *data = [self.wh_room getMember:g_myself.userId];
//    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
//        //不是管理员
//        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WHVC_NotAdminCannotDoThis")];
//        return;
//    }
    WH_JXAnnounce_WHViewController* vc = [WH_JXAnnounce_WHViewController alloc];
//    vc.value = room.note;
//    vc.dataArray = [[NSMutableArray alloc] init];
    vc.dataArray = [NSMutableArray arrayWithArray:self.noticeArr];
    vc.delegate  = self;
    if (([data.role intValue] == 1 || [data.role intValue] == 2)) {
        vc.isAdmin = YES; // 是群主和管理
    }else {
        vc.isAdmin = NO;  // 不是群主和管理
    }
    vc.room = wh_room;
    vc.title = Localized(@"WaHu_JXRoomMember_WaHuVC_UpdateAdv");
    vc.didSelect = @selector(onSaveNote:);
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];

//    WH_JXInputValue_WHVC* vc = [WH_JXInputValue_WHVC alloc];
//    vc.value = room.note;
//    vc.delegate  = self;
//    vc.title = Localized(@"WaHu_JXRoomMember_WHVC_UpdateAdv");
//    vc.didSelect = @selector(onSaveNote:);
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSaveNote:(WH_JXAnnounce_WHViewController*)vc{
    _modifyType = kRoomRemind_NewNotice;
    _content = vc.value;
    wh_room.note = vc.value ? vc.value : Localized(@"JX_NotAch");
    _note.text = wh_room.note ? wh_room.note : Localized(@"JX_NotAch");

}

-(void)onRoomName{
    memberData *data = [self.wh_room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotAdminCannotDoThis")];
        return;
    }
    
    WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:Localized(@"WaHu_JXRoomMember_WaHuVC_UpdateRoomName") content:wh_room.name isEdit:YES isLimit:YES];
    [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(cmView) weakShare = cmView;
    __weak typeof(self) weakSelf = self;
    [cmView setCloseBlock:^{
        [weakShare hideView];
    }];
    [cmView setSelectActionBlock:^(NSInteger buttonTag, NSString * _Nonnull content) {
        if (buttonTag == 0) {
            [weakShare hideView];
        }else{
            [weakShare hideView];
            
            _modifyType = kRoomRemind_RoomName;
            _content = content;
            wh_room.name = content;
            
            [g_server updateRoom:wh_room key:@"roomName" value:wh_room.name toView:weakSelf];
        }
    }];
    
//    WH_JXInputValue_WHVC* vc = [WH_JXInputValue_WHVC alloc];
//    vc.value = room.name;
//    vc.title = Localized(@"WaHu_JXRoomMember_WHVC_UpdateRoomName");
//    vc.delegate  = self;
//    vc.didSelect = @selector(onSaveRoomName:);
//    vc.isLimit = YES;
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
}

-(void)onSaveRoomName:(WH_JXInputValue_WHVC*)vc{
    _modifyType = kRoomRemind_RoomName;
    _content = vc.value;

    wh_room.name = vc.value;
    
    [g_server updateRoom:wh_room key:@"roomName" value:wh_room.name toView:self];

}

-(void)onRoomDesc{
    memberData *data = [self.wh_room getMember:g_myself.userId];
    if (([data.role intValue] != 1 && [data.role intValue] != 2)) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotAdminCannotDoThis")];
        return;
    }
//    WH_JXInputValue_WHVC* vc = [WH_JXInputValue_WHVC alloc];
//    vc.value = wh_room.desc;
//    vc.title = Localized(@"WaHu_JXRoomMember_WaHuVC_UpdateExplain");
//    vc.delegate  = self;
//    vc.didSelect = @selector(onSaveRoomDesc:);
//    vc = [vc init];
//    [g_navigation pushViewController:vc animated:YES];
    
    WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:@"修改群组说明" content:wh_room.desc isEdit:YES isLimit:NO];
    [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
    
    __weak typeof(cmView) weakShare = cmView;
//    __weak typeof(self) weakSelf = self;
    [cmView setCloseBlock:^{
        [weakShare hideView];
    }];
    [cmView setSelectActionBlock:^(NSInteger buttonTag, NSString * _Nonnull content) {
        if (buttonTag == 0) {
            [weakShare hideView];
        }else{
            [weakShare hideView];
            
            wh_room.desc = content;
            [g_server WH_updateRoomDescWithRoom:wh_room toView:self];
        }
    }];
}

//-(void)onSaveRoomDesc:(WH_JXInputValue_WHVC*)vc{
//    wh_room.desc = vc.value;
//    [g_server WH_updateRoomDescWithRoom:wh_room toView:self];
//}

- (void)onRoomNumber {
    memberData *data = [self.wh_room getMember:g_myself.userId];
    if (([data.role intValue] == 1 || [data.role intValue] == 2) && ([g_myself.role containsObject:@5] || [g_myself.role containsObject:@6])) {
        WH_JXInputValue_WHVC* vc = [WH_JXInputValue_WHVC alloc];
        vc.value = wh_room.desc;
        vc.title = Localized(@"JX_MaximumPeople");
        vc.isRoomNum = YES;
        vc.delegate  = self;
        vc.didSelect = @selector(onSetupRoomNumber:);
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        return;
    }
    [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotAdminCannotDoThis")];
}

- (void)onSetupRoomNumber:(WH_JXInputValue_WHVC*)vc {
    wh_room.maxCount = [vc.value intValue];
    [g_server WH_updateRoomMaxUserSizeWithRoom:wh_room toView:self];
}

-(void)onNickName{
    if (self.isMyRoom) {
        WH_JXRoomMemberList_WHVC *listVC = [[WH_JXRoomMemberList_WHVC alloc] init];
        listVC.type = Type_AddNotes;
        listVC.room = self.wh_room;
        listVC.title = Localized(@"JX_ModifyFullNickname");
        listVC.delegate = self;
        [g_navigation pushViewController:listVC animated:YES];
    } else {
        WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:Localized(@"WaHu_JXRoomMember_WaHuVC_UpdateNickName") content:[wh_room getNickNameInRoom] isEdit:YES isLimit:YES];
        [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
        
        __weak typeof(cmView) weakShare = cmView;
        __weak typeof(self) weakSelf = self;
        [cmView setCloseBlock:^{
            [weakShare hideView];
        }];
        [cmView setSelectActionBlock:^(NSInteger buttonTag, NSString * _Nonnull content) {
            if (buttonTag == 0) {
                [weakShare hideView];
            }else{
                [weakShare hideView];
                
                _modifyType = kRoomRemind_NickName;
                _content = content;
                
                _userName.text = content;
                memberData* p = [wh_room getMember:g_myself.userId];
                p.userNickName = content;
                
                if ([weakSelf.delegate respondsToSelector:@selector(setWh_nickName:)]) {
                    [weakSelf.delegate setNickName:content];
                }
                
                [g_server WH_setRoomMemberWithRoomId:wh_room.roomId member:p toView:weakSelf];
                p = nil;
            }
        }];
    }

}

-(void)shareFileAction{
    WH_JXFile_WHViewController * fileVC  = [[WH_JXFile_WHViewController alloc] init];
    fileVC.room = wh_room;
//    [g_window addSubview:fileVC.view];
    [g_navigation pushViewController:fileVC animated:YES];
}

// 查找聊天内容
- (void)searchChatLog {
    
    WH_JXSearchChatLog_WHVC *vc = [[WH_JXSearchChatLog_WHVC alloc] init];
    vc.user = self.user;
    vc.isGroup = YES;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)roomMemberList:(WH_JXRoomMemberList_WHVC *)selfVC addNotesVC:(WH_JXInputValue_WHVC *)vc {
    _modifyType = kRoomRemind_NickName;
//    _content = vc.value;
    
    _setNickName = vc.value;
    memberData* p = [wh_room getMember:vc.userId];
    if (_isAdmin) {
        p.userNickName = vc.value;
        if ([self.delegate respondsToSelector:@selector(setWh_nickName:)]) {
            [self.delegate setNickName:vc.value];
        }
    }else {
        p.lordRemarkName = vc.value;
    }
    
    [g_server WH_setRoomMemberWithRoomId:wh_room.roomId member:p toView:self];
    [p update];
    p = nil;
}

-(void)onSaveNickName:(WH_JXInputValue_WHVC*)vc{
    _modifyType = kRoomRemind_NickName;
    _content = vc.value;
    
    _userName.text = vc.value;
    memberData* p = [wh_room getMember:g_myself.userId];
    p.userNickName = vc.value;
    
    if ([self.delegate respondsToSelector:@selector(setWh_nickName:)]) {
        [self.delegate setNickName:vc.value];
    }

    [g_server WH_setRoomMemberWithRoomId:wh_room.roomId member:p toView:self];
    p = nil;
}

#pragma mark 选取好友
-(void)onAfterAddMember:(WH_JXSelectFriends_WHVC*)vc{
    if (self.wh_room.isNeedVerify && self.wh_room.userId != [g_myself.userId longLongValue]) {
        self.selFriendUserIds = vc.userIds;
        self.selFriendUserNames = vc.userNames;
        
//        WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
//        vc.delegate = self;
//        vc.didTouch = @selector(onInputHello:);
//        vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
//        vc.titleColor = [UIColor lightGrayColor];
//        vc.titleFont = [UIFont systemFontOfSize:13.0];
//        vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
////        vc.inputText = Localized(@"JXNewFriendVC_Iam");
//        vc = [vc init];
//        [g_window addSubview:vc.view];
        
        WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 308)/2, JX_SCREEN_WIDTH - 40, 308) title:@"进群验证" promptContent:Localized(@"JX_GroupOwnersHaveEnabled") content:Localized(@"JX_PleaseEnterTheReason") isEdit:YES isLimit:NO];
        [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO cancelGestur:YES];
        
        
        __weak typeof(cmView) weakShare = cmView;
        __weak typeof(self) weakSelf = self;
        [cmView setCloseBlock:^{
            [weakShare hideView];
        }];
        [cmView setSelectActionBlock:^(NSInteger buttonTag, NSString * _Nonnull content) {
            if (buttonTag == 0) {
                [weakShare hideView];
            }else{
                [weakShare hideView];
                
                [weakSelf onInputHello:content];
            }
        }];
        
    }else {
        _delMode = NO;
        [self redrawView222];
        
//        [self.seeAllBtn setTitle:[NSString stringWithFormat:@"查看全部群成员(%ld)",(self.membersNum > 0)?self.membersNum:self.wh_room.members.count] forState:UIControlStateNormal];//self.userSiz
    }

//    _modifyType = kRoomRemind_AddMember;
//    _toUserId = [NSString stringWithFormat:@"%ld",vc.member.userId];
//    _toUserName = vc.member.userNickName;
//    _currentMember = vc.member;
//    [self sendSelfMsg:_modifyType content:nil];
}

- (void)onInputHello:(NSString *)reason {
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.fromUserId = MY_USER_ID;
    msg.toUserId = [NSString stringWithFormat:@"%ld", wh_room.userId];
    msg.fromUserName = MY_USER_NAME;
    msg.toUserName = wh_room.userNickName;
    msg.timeSend = [NSDate date];
    msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    NSString *userIds = [self.selFriendUserIds componentsJoinedByString:@","];
    NSString *userNames = [self.selFriendUserNames componentsJoinedByString:@","];
    NSDictionary *dict = @{
                           @"userIds" : userIds,
                           @"userNames" : userNames,
                           @"roomJid" : wh_room.roomJid,
                           @"reason" : reason,
                           @"isInvite" : [NSNumber numberWithBool:NO]
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    msg.objectId = jsonStr;
    [g_xmpp sendMessage:msg roomName:nil];
    
    msg.fromUserId = wh_room.roomJid;
    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
    msg.content = Localized(@"JX_WaitGroupConfirm");
    [msg insert:wh_room.roomJid];
    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
        [GKMessageTool showText:@"群聊邀请已发送给群主！"];
        [self.delegate needVerify:msg];
    }
}

-(void)onDisableSay{
    _disableMode = !_disableMode;
    [self setDisableMode:_disableMode];
    if (_disableMode) {
        [self.wh_tableBody setContentOffset:CGPointMake(0, 0)];
        [g_App showAlert:Localized(@"JXAlert_GagLong")];
    }
}

-(void)onDisableSay:(WH_JXImageView*)sender{
    if(sender.tag >= [wh_room.members count])
        return;
    _disable = (int)sender.tag;

    LXActionSheet* _menu = [[LXActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:Localized(@"JX_Cencal")
                            otherButtonTitles:@[Localized(@"JXAlert_NotGag"),Localized(@"JXAlert_GagTenMinute"),Localized(@"JXAlert_GagOneHour"),Localized(@"JXAlert_GagOne"),Localized(@"JXAlert_GagThere"),Localized(@"JXAlert_GagOneWeek"),Localized(@"JXAlert_GagOver")]];
    [g_window addSubview:_menu];
//    [_menu release];
    
}

- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
    if(buttonIndex==0)
        return;
    NSTimeInterval n = [[NSDate date] timeIntervalSince1970];
    memberData* member = [wh_room.members objectAtIndex:_disable];
    switch (buttonIndex) {
        case 1:
            member.talkTime = 0;
            break;
        case 2:
            member.talkTime = 10*60+n;
            break;
        case 3:
            member.talkTime = 1*3600+n;
            break;
        case 4:
            member.talkTime = 24*3600+n;
            break;
        case 5:
            member.talkTime = 3*24*3600+n;
            break;
        case 6:
            member.talkTime = 7*24*3600+n;
            break;
        case 7:
            member.talkTime = 3000*24*3600+n;
            break;
    }
    [g_server WH_setDisableSayWithRoomId:wh_room.roomId member:member toView:self];

    _modifyType = kRoomRemind_DisableSay;
    _toUserId = [NSString stringWithFormat:@"%ld",member.userId];
    _toUserName = member.userNickName;
//    [self sendSelfMsg:_modifyType content:[NSString stringWithFormat:@"%f",member.talkTime]];

    member = nil;
}
-(void)switchAction:(id) sender{
//    UILabel* p = (UILabel*)[_blackBtn viewWithTag:TAG_LABEL];
    UISwitch *switchButton = (UISwitch*)sender;
    if ((switchButton.tag == 15460)) {  //禁言
        
        memberData *data = [self.wh_room getMember:g_myself.userId];
        if (([data.role intValue] == 1 || [data.role intValue] == 2)) {
            [self onDisableSay];
            return;
        }
        if (switchButton.on) {
            [sender setOn:NO];
            //不是管理员
            [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotAdminCannotDoThis")];
        }
        
    }else if (switchButton.tag == 15461) {  // 全部禁言
        
        NSTimeInterval n = [[NSDate date] timeIntervalSince1970];
        if (switchButton.on) {
            wh_room.talkTime = 15*24*3600+n;
        }else {
            wh_room.talkTime = 0;
        }
        
        self.user.talkTime = [NSNumber numberWithLong:wh_room.talkTime];
        [self.user WH_updateGroupTalkTime];
        
        self.updateType = [NSNumber numberWithInt:kRoomRemind_RoomAllBanned];
//        [g_server updateRoom:room toView:self];
        [g_server updateRoom:wh_room key:@"talkTime" value:[NSString stringWithFormat:@"%lld",wh_room.talkTime] toView:self];
    }else if (switchButton.tag == 15462){
        //关闭强提醒
        [[NSUserDefaults standardUserDefaults] setObject:@(switchButton.isOn) forKey:[NSString stringWithFormat:@"%@_group_strong_reminder_%@",g_myself.userId,wh_room.roomJid]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        //    BOOL isButtonOn = [switchButton isOn];
        if ([_user.status intValue] == friend_status_black) {
            _user.status = [NSNumber numberWithInt:friend_status_friend];
            [[JXXMPP sharedInstance].blackList removeObject:_user.userId];
            //        [g_App showAlert:@"开启接收群消息"];
            
        }else {
            _user.status = [NSNumber numberWithInt:friend_status_black];
            [[JXXMPP sharedInstance].blackList addObject:_user.userId];
            //        [g_App showAlert:@"已屏蔽群消息"];
            [_messageFreeSwitch setOn:YES];
            [self messageFreeSwitchAction:_messageFreeSwitch];
        }
        
        //    p = nil;
        [_user update];
        [WH_JXMessageObject msgWithFriendStatus:_user.userId status:[_user.status intValue]];
    }

}
//弃用
-(void)onBlacklist{
    UILabel* p = (UILabel*)[_blackBtn viewWithTag:TAG_LABEL];
    if([_user.status intValue] == friend_status_black){
        _user.status = [NSNumber numberWithInt:friend_status_friend];
        [[JXXMPP sharedInstance].blackList removeObject:_user.userId];
        p.text = Localized(@"WaHu_JXRoomMember_WaHuVC_NotMessage");
    }
    else{
        _user.status = [NSNumber numberWithInt:friend_status_black];
        [[JXXMPP sharedInstance].blackList addObject:_user.userId];
        p.text = Localized(@"WaHu_JXRoomMember_WaHuVC_Accept");
    }
    p = nil;
    [_user update];
    [WH_JXMessageObject msgWithFriendStatus:_user.userId status:[_user.status intValue]];
}

-(void)sendSelfMsg:(int)type content:(NSString*)content{
    if(_modifyType<=0)
        return;
    WH_JXMessageObject* p = [[WH_JXMessageObject alloc]init];
    p.fromUserId = MY_USER_ID;
    p.fromUserName = MY_USER_NAME;
    p.objectId = self.wh_room.roomJid;
    p.fromId = MY_USER_ID;
    p.type = [NSNumber numberWithInt:type];
    p.content = content;
    p.toUserId = _toUserId;
    p.toUserName = _toUserName;
    p.timeSend = [NSDate date];
    [p insert:p.fromId];
    [p notifyNewMsg];
    
    _toUserId = nil;
    _toUserName = nil;
    _modifyType = 0;
}

-(void)specifyAdministrator{
    
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        return;
    }
    
    WH_JXSelFriend_WHVC * selVC = [[WH_JXSelFriend_WHVC alloc] init];
    selVC.type = JXSelUserTypeSpecifyAdmin;
    selVC.room = wh_room;
    selVC.delegate = self;
    selVC.didSelect = @selector(specifyAdministratorDelegate:);
//    [g_window addSubview:selVC.view];
    [g_navigation pushViewController:selVC animated:YES];
}

#pragma mark 群管理
- (void)groupManagement {
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        return;
    }
    
    WH_JXGroupManagement_WHVC *vc = [[WH_JXGroupManagement_WHVC alloc] init];
    vc.room = self.wh_room;
    [g_navigation pushViewController:vc animated:YES];
}

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

-(void)readSwitchAction:(UISwitch *)readswitch{
    memberData *data = [self.wh_room getMember:g_myself.userId];
    
    if ([data.role intValue] != 1) {
        [g_App showAlert:Localized(@"WaHu_JXRoomMember_WaHuVC_NotGroupMarsterCannotDoThis")];
        [readswitch setOn:!readswitch.isOn];
        return;
    }
    self.updateType = [NSNumber numberWithInt:kRoomRemind_ShowRead];
    wh_room.showRead = _readSwitch.on;
    [g_server updateRoomShowRead:wh_room key:@"showRead" value:wh_room.showRead toView:self];
}

- (void)messageFreeSwitchAction:(UISwitch *)messageFreeSwitch {
    
    [g_server WH_roomMemberSetOfflineNoPushMsgWithRoomId:wh_room.roomId userId:MY_USER_ID offlineNoPushMsg:_messageFreeSwitch.isOn toView:self];
}

/**
 群二维码
 */
- (void)showUserQRCode {
    
    /// 获取当前登录用户
    memberData *loginMember = [self getCurrentLoginMerber];
    /// 当前登录用户是不是管理者
    BOOL isManger = [self isManger:loginMember];
    if (!isManger && !self.wh_room.allowInviteFriend) {
        return;
    }
    
    WH_QRCode_WHViewController *qrVC = [[WH_QRCode_WHViewController alloc] init];
    qrVC.type = QR_GroupType;
    qrVC.wh_userId = wh_room.roomId;
    qrVC.wh_nickName = wh_room.name;
    qrVC.wh_roomJId = wh_room.roomJid;
    qrVC.wh_groupNum = self.wh_groupNum;
    qrVC.groupRoom = self.wh_room;
    [self presentViewController:qrVC animated:YES completion:nil];
    
//    WH_JXQRCode_WHViewController * qrVC = [[WH_JXQRCode_WHViewController alloc] init];
//    qrVC.type = QRGroupType;
//    qrVC.userId = room.roomId;
//    qrVC.nickName = room.name;
//    qrVC.roomJId = room.roomJid;
////    [g_window addSubview:qrVC.view];
//    [g_navigation pushViewController:qrVC animated:YES];
}

-(void)reportUserView{
    WH_JXReportUser_WHVC * reportVC = [[WH_JXReportUser_WHVC alloc] init];
    reportVC.user = self.user;
    reportVC.delegate = self;
    [g_navigation pushViewController:reportVC animated:YES];
    
}

- (void)report:(WH_JXUserObject *)reportUser reasonId:(NSNumber *)reasonId {
    [g_server WH_reportUserWithToUserId:nil roomId:reportUser.roomId webUrl:nil reasonId:reasonId toView:self];
}

#pragma mark - 弹框代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
    }
}



-(int)gethashCode:(NSString *)str {
    // 字符串转hash
    int hash = 0;
    for (int i = 0; i<[str length]; i++) {
        NSString *s = [str substringWithRange:NSMakeRange(i, 1)];
        char *unicode = (char *)[s cStringUsingEncoding:NSUnicodeStringEncoding];
        int charactorUnicode = 0;
        size_t length = strlen(unicode);
        for (int n = 0; n < length; n ++) {
            charactorUnicode += (int)((unicode[n] & 0xff) << (n * sizeof(char) * 8));
        }
        hash = hash * 31 + charactorUnicode;
    }
    return hash;
}



- (void)sp_checkUserInfo {
    NSLog(@"Get Info Failed");
}
@end
