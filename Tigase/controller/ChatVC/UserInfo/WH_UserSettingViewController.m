//
//  WH_UserSettingViewController.m
//  Tigase
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_UserSettingViewController.h"
#import "WH_JXReportUser_WHVC.h"
#import "WH_JXSetNoteAndLabel_WHVC.h"
#import "WH_JXChat_WHViewController.h"

#define TOP_SPACE 16

@interface WH_UserSettingViewController ()

@end

@implementation WH_UserSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_isGotoBack   = YES;
    self.title = @"资料设置";
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    [self createHeadAndFoot];
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
    
     self.wh_tableBody.scrollEnabled = YES;
    
    [self createContentView];
}

- (void)createContentView {
    
//    NSMutableArray *titleArr = [[NSMutableArray alloc] init];
    
    NSString *blackStatus = @"";
//    NSString *friendStatus = @"";
    
    if(self.wh_friendStatus == friend_status_friend){
        if(self.wh_friendStatus == friend_status_black)
            //取消黑名单
            blackStatus = Localized(@"WaHu_JXUserInfo_WaHuVC_CancelBlackList");
        else
            if(![self.wh_user.isBeenBlack boolValue]) {
                //加入黑名单
                blackStatus = Localized(@"WaHu_JXUserInfo_WaHuVC_AddBlackList");
            }
        if(![self.wh_user.isBeenBlack boolValue]){
            if(self.wh_friendStatus == friend_status_friend)
                //删除好友
                self.wh_fStatus = Localized(@"JX_Delete");
            else
                //添加好友
                self.wh_fStatus = Localized(@"JX_Add");
        }
    }
    
    //设置备注和标签
    UIButton *bbBtn = [self commonViewWithOrginY:TOP_SPACE buttonHeight:55 title:Localized(@"JX_SetNotesAndLabels") isNext:YES radius:g_factory.cardCornerRadius isAlignmentCenter:NO subView:self.wh_tableBody];
    [bbBtn addTarget:self action:@selector(createMarkAndSignle) forControlEvents:UIControlEventTouchUpInside];
    
    //加入黑名单和举报
    NSArray *array ;
    if (blackStatus.length > 0) {
        array = @[blackStatus ,Localized(@"WaHu_JXUserInfo_WaHuVC_Report")];
    }else{
       array = @[Localized(@"WaHu_JXUserInfo_WaHuVC_Report")];
    }
    
    UIButton *btn = [self commonViewWithOrginY:bbBtn.frame.origin.y + bbBtn.frame.size.height +TOP_SPACE buttonHeight:array.count*55 title:nil isNext:NO radius:g_factory.cardCornerRadius isAlignmentCenter:NO subView:self.wh_tableBody];
    
    for (int i = 0; i < array.count; i++) {
        Boolean isNext ;
        if (array.count > 1) {
            isNext = (i == 0)?NO:YES;
        }else{
            isNext = YES;
        }
        
        UIButton *hjBtn = [self commonViewWithOrginY:i*55 buttonHeight:55 title:[array objectAtIndex:i] isNext:isNext radius:0 isAlignmentCenter:NO subView:btn];
        [hjBtn setBackgroundColor:[UIColor clearColor]];
        [btn addSubview:hjBtn];
        
        if (array.count > 1) {
            if (i == 0) {
                //加入黑名单
                
                UISwitch *switchView = [[UISwitch alloc] init];
                switchView.frame = CGRectMake(btn.frame.size.width - 61 - 12, 6, 0, 0);
                [switchView addTarget:self action:@selector(blackMethod) forControlEvents:UIControlEventTouchUpInside];
                switchView.onTintColor = THEMECOLOR;
                [switchView setOn:NO];
                [hjBtn addSubview:switchView];
                
//                [btn addTarget:self action:@selector(blackMethod) forControlEvents:UIControlEventTouchUpInside];
            }else{
                //举报
                [hjBtn addTarget:self action:@selector(juBaoMethod) forControlEvents:UIControlEventTouchUpInside];
            }
        }else{
            [hjBtn addTarget:self action:@selector(juBaoMethod) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, CGRectGetWidth(btn.frame), 1)];
    [lView setBackgroundColor:HEXCOLOR(0xF8F8F7)];
    [btn addSubview:lView];
   
    //添加/删除好友
    if (self.wh_fStatus.length > 0) {
        UIButton *delBtn = [self commonViewWithOrginY:btn.frame.origin.y + btn.frame.size.height + TOP_SPACE buttonHeight:55 title:self.wh_fStatus isNext:NO radius:g_factory.cardCornerRadius isAlignmentCenter:YES subView:self.wh_tableBody];
        [delBtn addTarget:self action:@selector(friendMethod) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}

//设置标签和备注
- (void)createMarkAndSignle {
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
//    [self setLabelAndDescribe];
    
    [g_server WH_setFriendNameWithToUserId:self.wh_user.userId noteName:user.remarkName describe:user.describe toView:self];
}

//添加,删除好友
- (void)friendMethod {
    if ([self.wh_fStatus isEqualToString:Localized(@"JX_Delete")]) {
        //删除好友
        [g_App showAlert:@"确定要删除该好友吗?" delegate:self tag:1 onlyConfirm:NO];
//        [self onDeleteFriend];
    }else{
        //添加好友
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self onDeleteFriend];
    }
}

//举报
- (void)juBaoMethod {
    WH_JXReportUser_WHVC * reportVC = [[WH_JXReportUser_WHVC alloc] init];
    reportVC.user = self.wh_user;
    reportVC.delegate = self;
    [g_navigation pushViewController:reportVC animated:YES];
}

//WH_JXReportUser_WHVC delegate
- (void)report:(WH_JXUserObject *)reportUser reasonId:(NSNumber *)reasonId {
    [g_server WH_reportUserWithToUserId:reportUser.userId roomId:nil webUrl:nil reasonId:reasonId toView:self];
}

- (void)blackMethod {
    [g_server WH_addBlacklistWithToUserId:self.wh_user.userId toView:self];
}

//删除好友
-(void)onDeleteFriend{
    [g_server delFriend:self.wh_user.userId toView:self];
}
#pragma mark - 添加好友操作
-(void)WH_actionWithAddFriendAction:(UIView*)sender{
    
    // 验证XMPP是否在线
    if(g_xmpp.isLogined != 1){
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
    if([self.wh_user.isBeenBlack boolValue]){
        [g_App showAlert:Localized(@"TO_BLACKLIST")];
        return;
    }
    switch (_wh_friendStatus) {
        case friend_status_black:{
            
            [self onDelBlack];
            
            
        }
            break;
        case friend_status_none:
        case friend_status_see:
            [g_server WH_addAttentionWithUserId:self.wh_user.userId fromAddType:self.wh_fromAddType toView:self];
            break;
        case friend_status_friend:{//发消息
            if([self.wh_user haveTheUser])
                [self.wh_user insert];
            else
                [self.wh_user update];
            
            [self actionQuit];
            [g_notify postNotificationName:kActionRelayQuitVC_WHNotification object:nil];
            
            WH_JXChat_WHViewController *chatVC=[WH_JXChat_WHViewController alloc];
            chatVC.title = self.wh_user.userNickname;
            chatVC.chatPerson = self.wh_user;
            chatVC = [chatVC init];
            //            [g_App.window addSubview:chatVC.view];
            [g_navigation pushViewController:chatVC animated:YES];
        }
            break;
    }
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if([aDownload.action isEqualToString:wh_act_AttentionAdd]){//加好友
        int n = [[dict objectForKey:@"type"] intValue];
        if( n==2 || n==4)
            _wh_friendStatus = friend_status_friend;//成为好友，一般是无需验证
      
        if(_wh_friendStatus == friend_status_friend){
            [_wait stop];
            [self doMakeFriend];
        }
        else
            [self doSayHello];
    }
    if ([aDownload.action isEqualToString:wh_act_FriendDel]) {//删除好友
        [self.wh_user doSendMsg:XMPP_TYPE_DELALL content:nil];
        
        [self actionQuit];
    }
    if([aDownload.action isEqualToString:wh_act_BlacklistAdd]){//拉黑
        [self.wh_user doSendMsg:XMPP_TYPE_BLACK content:nil];
        
//        [g_navigation popToRootViewController];
        [self actionQuit];
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
        //更新用户信息
//        [self setUserInfo:user];
    }
    
}

-(void)doMakeFriend{
    self.wh_friendStatus = friend_status_friend;
    
    [self.wh_user doSendMsg:XMPP_TYPE_FRIEND content:nil];
    [WH_JXMessageObject msgWithFriendStatus:self.wh_user.userId status:self.wh_friendStatus];
//    [self showAddFriend];
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

-(void)doSayHello{//打招呼
    self.wh_xmppMsgId = [self.wh_user doSendMsg:XMPP_TYPE_SAYHELLO content:Localized(@"WaHu_JXUserInfo_WaHuVC_Hello")];
}

-(void)WH_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    [_wait stop];
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
        self.wh_user.status = [NSNumber numberWithInt:friend_status_black];
        _wh_friendStatus = [self.wh_user.status intValue];
        [[JXXMPP sharedInstance].blackList addObject:self.wh_user.userId];
        [self.wh_user update];
//        [self showAddFriend];
        [g_App showAlert:Localized(@"JXAlert_AddBlackList")];
        
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
        //        [WH_JXMessageObject msgWithFriendStatus:user.userId status:_friendStatus];
        //        [user notifyDelFriend];
    }
    
    if([msg.type intValue] == XMPP_TYPE_DELSEE){//删除关注，弃用
        _wh_friendStatus = friend_status_none;
//        [self showAddFriend];
        [WH_JXMessageObject msgWithFriendStatus:self.wh_user.userId status:_wh_friendStatus];
        [g_App showAlert:Localized(@"JXAlert_CencalFollow")];
    }
    
    if([msg.type intValue] == XMPP_TYPE_DELALL){//删除好友
        _wh_friendStatus = friend_status_none;
//        [self showAddFriend];
        
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
        [g_App showAlert:Localized(@"JXAlert_DeleteFirend")];
    }
    
    if([msg.type intValue] == XMPP_TYPE_NOBLACK){//取消拉黑
        self.wh_user.status = [NSNumber numberWithInt:friend_status_friend];
        [self.wh_user WH_updateStatus];
        
        _wh_friendStatus = friend_status_friend;
//        [self showAddFriend];
        if ([[JXXMPP sharedInstance].blackList containsObject:self.wh_user.userId]) {
            [[JXXMPP sharedInstance].blackList removeObject:self.wh_user.userId];
            [WH_JXMessageObject msgWithFriendStatus:self.wh_user.userId status:friend_status_friend];
        }
        [g_App showAlert:Localized(@"JXAlert_MoveBlackList")];
        
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
    }
    if([msg.type intValue] == XMPP_TYPE_FRIEND){//无验证加好友
        if (![g_myself.telephone isEqualToString:@"18938880001"]) {
            [g_App showAlert:Localized(@"JX_AddSuccess")];
        }
        self.wh_user.status = [NSNumber numberWithInt:2];
        [g_notify postNotificationName:kXMPPNewFriend_WHNotifaction object:nil];
    }
}

-(void)onAddBlack{
    [g_server WH_addBlacklistWithToUserId:self.wh_user.userId toView:self];
}

-(void)onDelBlack{
    [g_server WH_delBlacklistWithToUserId:self.wh_user.userId toView:self];
}

-(void)onCancelSee{
    [g_server WH_delAttentionWithToUserId:self.wh_user.userId toView:self];
}

- (UIButton *)commonViewWithOrginY:(CGFloat)orginY buttonHeight:(CGFloat)height title:(NSString *)title isNext:(BOOL)next radius:(CGFloat)radius isAlignmentCenter:(Boolean)center subView:(UIView *)view{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((radius > 0)?g_factory.globelEdgeInset:0, orginY, (radius > 0)?(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset):(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset), height)];
    
    [view addSubview:button];
    if (radius > 0) {
        [button setBackgroundColor:HEXCOLOR(0xffffff)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = g_factory.cardCornerRadius;
        button.layer.borderColor = g_factory.cardBorderColor.CGColor;
        button.layer.borderWidth = g_factory.cardBorderWithd;
    }else{
        [button setBackgroundColor:[UIColor clearColor]];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (center)?(CGRectGetWidth(button.frame) - 40):CGRectGetWidth(button.frame) - 62 - 20, CGRectGetHeight(button.frame))];
    [label setText:title];
    [label setTextColor:(!center)?HEXCOLOR(0x3A404C):HEXCOLOR(0xED6350)];
    [label setTextAlignment:(center)?NSTextAlignmentCenter:NSTextAlignmentLeft];
    [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
    [button addSubview:label];
    
    if (next) {
        UIImageView *nextImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(button.frame) - 19, (CGRectGetHeight(button.frame) - 12)/2, 7, 12)];
        [nextImg setImage:[UIImage imageNamed:@"WH_Back"]];
        [button addSubview:nextImg];
    }
    
    return button;
}



- (void)sp_getUserName {
    NSLog(@"Get Info Failed");
}
@end
