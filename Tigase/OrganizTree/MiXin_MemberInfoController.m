//
//  MiXin_MemberInfoController.m
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//
#import "WH_JXAddDepart_WHViewController.h"
#import "MiXin_MemberInfoController.h"
#import "WH_JXChat_WHViewController.h"
#import "MiXin_DepartMentViewController.h"
#import "WH_JXUserBaseObj.h"
#import "UIAlertController+category.h"
@interface MiXin_MemberInfoController ()<AddDepartDelegate> {
    UIButton *_send;
    UILabel *_job;
    UILabel *_departlab;
}
@property (nonatomic, strong) MiXin_EmployeeModel *model;
@property (nonatomic, strong) WH_JXUserObject *user;
@end

@implementation MiXin_MemberInfoController
- (id)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = 0;
        self.wh_heightFooter = 0;
        
        self.wh_tableBody.backgroundColor = THEMEBACKCOLOR;
        self.wh_isGotoBack = YES;
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self createHeadAndFoot];
    //[g_server getEmployeeInfo:_employeeId companyId:_comId departmentId:_departId toView:self];
    if (@available(iOS 11.0, *)) {
        self.wh_tableBody.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [g_server getEmployeeInfo:_employeeId toView:self];
    [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
}

-(void)dealloc{
    [g_notify  removeObserver:self name:kXMPPReceipt_WHNotifaction object:nil];
    [g_notify removeObserver:self];
    self.user = nil;
}


- (void)clickBack {
    [self actionQuit];
}

- (void)clickMore{
    
}


- (void)createMain {
//    UIButton *right = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal" highlight:nil target:self selector:@selector(clickMore)];
//    right.frame = CGRectMake(JX_SCREEN_WIDTH-NAV_INSETS-30, JX_SCREEN_TOP - 38, 30, 30);
//    [self.view addSubview:right];
    UIButton *left = [UIFactory WH_create_WHButtonWithImage:@"newicon_nav_whiteback" highlight:nil target:self selector:@selector(clickBack)];
    left.frame = CGRectMake(NAV_INSETS, JX_SCREEN_TOP - 38, 30, 30);
    [self.view addSubview:left];
    
    
    UILabel *name = [self.wh_tableBody createLab:CGRectMake(0, 0, JX_SCREEN_WIDTH, 305) font:[UIFont boldSystemFontOfSize:36] color:[UIColor whiteColor] text:_model.nickname];
    name.backgroundColor = HEXCOLOR(0x0093FF);
    name.textAlignment = NSTextAlignmentCenter;
    [self.wh_tableBody addSubview:name];
    
    UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 305)];
    //imgv.image = [UIImage imageNamed:@""];
    //if (_model.icon) [imgv sd_setImageWithURL:[NSURL URLWithString:_model.icon]];
    [g_server WH_getHeadImageLargeWithUserId:_model.userId userName:_model.nickname imageView:imgv];
    imgv.contentMode = UIViewContentModeScaleAspectFill;
    imgv.clipsToBounds = YES;
    [self.wh_tableBody addSubview:imgv];
    
    UIView *ddd = [[UIView alloc]initWithFrame:imgv.frame];
    ddd.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [self.wh_tableBody addSubview:ddd];
    
    UILabel *nick = [ddd createLab:CGRectMake(10, ddd.bottom-95, JX_SCREEN_WIDTH-20, 41) font:sysBoldFontWithSize(28) color:[UIColor whiteColor] text:_model.nickname];
    [ddd addSubview:nick];
    
    UILabel *job = [ddd createLab:CGRectMake(10, nick.bottom+10, JX_SCREEN_WIDTH-20, 30) font:sysFontWithSize(16) color:HEXCOLOR(0x333333) text:_model.position];
    job.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.8];
    [job sizeToFit];
    job.height = 30;
    job.width+=30;
    [job setRadiu:15 color:nil];
    job.textAlignment = NSTextAlignmentCenter;
    [ddd addSubview:job];
    _job= job;
    
    
    NSArray *arr1 = @[@"企业/组织",@"部门"];
    NSArray *arr2 = @[_comname,_departname];
    for (int i = 0; i < arr1.count; i++) {
        UIView *fff = [[UIView alloc]initWithFrame:CGRectMake(0, imgv.bottom+71*i, JX_SCREEN_WIDTH, 70)];
        [self.wh_tableBody addSubview:fff];
        
        //for (int j = 0; j < 2; j++) {
        UILabel *lab1 = [fff createLab:CGRectMake(12, 12, 100, 20) font:sysFontWithSize(13) color:HEXCOLOR(0x666666) text:arr1[i]];
        [fff addSubview:lab1];
        
        UILabel *lab2 = [fff createLab:CGRectMake(12, lab1.bottom+4, JX_SCREEN_WIDTH-24, 24) font:sysFontWithSize(17) color:HEXCOLOR(0x333333) text:arr2[i]];
        if (i==1) _departlab = lab2;
        [fff addSubview:lab2];
        
        [fff createLine:CGRectMake(10, 69, fff.width-20, .5) color:HEXCOLOR(0xEBECEF) radio:0 border:nil sup:fff];
        
    }
    
    
    NSArray *arr = @[@"发消息",@"修改部门",@"修改职位",@"移出团队"];
    NSArray *turss;
    if ([_createUserId isEqualToString:MY_USER_ID]) {
        turss = @[@"发消息",@"修改部门",@"修改职位",@"移出团队"];
    }else {
        turss = @[@"发消息",@"修改部门黑色",@"修改职位黑色",@"移除团队黑色"];
    }
    for (int i = 0; i < arr.count; i++) {
        UIButton *fff = [UIButton buttonWithType:UIButtonTypeCustom];
        fff.frame = CGRectMake(i*JX_SCREEN_WIDTH/4+(JX_SCREEN_WIDTH/8-23), imgv.bottom+200, 46, 46);
        [fff setImage:[UIImage imageNamed:turss[i]] forState:UIControlStateNormal];
        [fff addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        fff.tag = 2351+i;
        [self.wh_tableBody addSubview:fff];
        
        UILabel *lab = [fff createLab:CGRectMake(i*JX_SCREEN_WIDTH/4, fff.bottom+10, JX_SCREEN_WIDTH/4, 20) font:sysFontWithSize(15) color:HEXCOLOR(0x0093FF) text:arr[i]];
        lab.textAlignment = NSTextAlignmentCenter;
        [self.wh_tableBody addSubview:lab];
        
        if (i==0) {
            _send= fff;
        }
        
    }
}

- (void)clickAction:(UIButton *)sender {
    if (sender.tag == 2351) {
        [self actionAddFriend];
    }
    
    if ([_createUserId isEqualToString:MY_USER_ID]) {
        if (sender.tag == 2352) {
            
            MiXin_DepartMentViewController *vc = [MiXin_DepartMentViewController new];
            vc.comId = _model.companyId;
            vc.ischoose = YES;
            vc.userId = _model.userId;
            vc.tname = _departname;
            vc.companyName = self.comname;
            vc.updateDepart = ^(NSString * _Nonnull str) {
                _departlab.text = str;
                if (self.deleteEmploy) self.deleteEmploy();
            };
            [g_navigation pushViewController:vc animated:YES];
        }else if (sender.tag == 2353) {
            WH_JXAddDepart_WHViewController * addDepartVC = [[WH_JXAddDepart_WHViewController alloc] init];
            addDepartVC.delegate = self;
            addDepartVC.type = OrganizModifyEmployeePosition;
            addDepartVC.oldName = _model.position;
            [g_navigation pushViewController:addDepartVC animated:YES];
        }else if (sender.tag == 2354) {          
            [UIAlertController showAlertViewWithTitle:@"确定删除该员工吗" message:nil controller:self block:^(NSInteger buttonIndex) {
                if (buttonIndex==1) {
                    
                    [g_server WH_deleteEmployeeWithDepartmentId:_model.departmentId userId:_model.userId toView:self];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
        }
    }
}

- (void)inputDelegateType:(OrganizAddType)organizType text:(NSString *)updateStr {
    if (organizType == OrganizModifyEmployeePosition) {
        [g_server WH_modifyPosition:updateStr companyId:_model.companyId userId:_model.userId toView:self];
    }
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    //[self stopLoading];
    if ([aDownload.action isEqualToString:wh_act_employeeInfo]) {
        _model = [MiXin_EmployeeModel mj_objectWithKeyValues:dict];
        [g_server getUser:_model.userId toView:self];
        if (!_job && !_send) {
            [self createMain];
        }
        
    }else if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        [user insertFriend];
        _user = user;
        [_send setTitle:user.status.intValue==2?@"发消息":@"添加好友" forState:UIControlStateNormal];
        [_send setImage:[UIImage imageNamed:user.status.intValue==2?@"发消息":@"添加好友"] forState:UIControlStateNormal];
    }else if( [aDownload.action isEqualToString:wh_act_modifyPosition] ){
        [g_server showMsg:@"修改职位成功"];
        if (self.deleteEmploy) self.deleteEmploy();
        
        _job.text = dict[@"position"];
        _model.position = _job.text;
        [_job sizeToFit];
        _job.height = 30;
        _job.width+=30;
    }else if( [aDownload.action isEqualToString:wh_act_deleteEmployee] ){
        [g_server showMsg:@"删除员工成功"];
        if (self.deleteEmploy) self.deleteEmploy();
        
        [self actionQuit];
    }else if([aDownload.action isEqualToString:wh_act_AttentionAdd]){//加好友
        int n = [[dict objectForKey:@"type"] intValue];
        //成为好友，一般是无需验证
        if( n==2 || n==4) _user.status = @(friend_status_friend);
        
        if([_user.status isEqual: @(friend_status_friend)]){
            [_wait stop];
            [self doMakeFriend];
        } else {
            [self doSayHello];
        }
    }
}

-(void)doMakeFriend{
    _user.status = @(friend_status_friend);
    [self.user doSendMsg:XMPP_TYPE_FRIEND content:nil];
    [WH_JXMessageObject msgWithFriendStatus:_user.userId status:_user.status.integerValue];
    [_send setTitle:@"发消息" forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:@"发消息"];
    [_send setImage:img forState:UIControlStateNormal];
}

-(void)doSayHello{
    //打招呼
    [self.user doSendMsg:XMPP_TYPE_SAYHELLO content:Localized(@"MiXin_JXUserInfo_MiXinVC_Hello")];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        [g_server showMsg:[NSString stringWithFormat:@"%@",dict[@"resultMsg"]]];
    }else if( [aDownload.action isEqualToString:wh_act_deleteEmployee] ){
        [g_server showMsg:dict[@"data"][@"resultMsg"]];
    }
    return WH_hide_error;
}
#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    
    return WH_show_error;
}


#pragma mark - 添加好友操作
-(void)actionAddFriend {
    if ([_user.userId isEqualToString:MY_USER_ID]) {
        [g_server showMsg:@"不能与自己聊天"];
        return;
    }
    // 验证XMPP是否在线
    if(g_xmpp.isLogined != 1){
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
    if([_user.isBeenBlack boolValue]){
        [g_App showAlert:Localized(@"TO_BLACKLIST")];
        return;
    }
    switch (_user.status.intValue) {
        case friend_status_see:
            [g_server WH_addAttentionWithUserId:_user.userId fromAddType:6 toView:self];
            break;
        case friend_status_none:
     
        case friend_status_friend:{
            //发消息
            if([_user haveTheUser])
                [_user insert];
            else
                [_user update];
            
            [self actionQuit];
            [g_notify postNotificationName:kActionRelayQuitVC_WHNotification object:nil];
            
            WH_JXChat_WHViewController *chatVC=[WH_JXChat_WHViewController alloc];
            chatVC.title = _user.userNickname;
            chatVC.chatPerson = self.user;
            chatVC = [chatVC init];
            [g_navigation pushViewController:chatVC animated:YES];
        }
            break;
    }
}


-(void)newReceipt:(NSNotification *)notifacation{
    //新回执
    WH_JXMessageObject *msg = (WH_JXMessageObject *)notifacation.object;
    if(msg == nil)
        return;
    if(![msg isAddFriendMsg])
        return;
    if(![msg.toUserId isEqualToString:self.user.userId])
        return;
    [_wait stop];

    if([msg.type intValue] == XMPP_TYPE_PASS){
        [_user doSendMsg:XMPP_TYPE_PASS content:nil];
    }
    [_send setTitle:msg.type.intValue == XMPP_TYPE_PASS?@"发消息":@"添加好友" forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:([msg.type intValue] == XMPP_TYPE_PASS)?@"发消息":@"添加好友"];
    [_send setImage:img forState:UIControlStateNormal];
}

-(void)WH_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    [_wait stop];
    [JXMyTools showTipView:Localized(@"JXAlert_SendFilad")];
}

@end
