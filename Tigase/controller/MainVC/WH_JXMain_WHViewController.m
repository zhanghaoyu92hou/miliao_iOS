//
//  WH_JXMain_WHViewController.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXMain_WHViewController.h"
#import "WH_JXTabMenuView.h"
#import "WH_JXMsg_WHViewController.h"
#import "WH_Addressbook_WHController.h"
#import "AppDelegate.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_JXFriendObject.h"
#ifdef Live_Version
#import "WH_JXLive_WHViewController.h"
#endif

#import "WH_WeiboViewControlle.h"
#import "JXSquareViewController.h"
#import "WH_JXProgress_WHVC.h"
#import "WH_JXGroup_WHViewController.h"
#import "WH_OrganizTree_WHViewController.h"
#import "WH_JXLabelObject.h"
#import "JXBlogRemind.h"

#import "WH_FindViewController.h"
#import "WH_MineViewController.h"
#import "WH_webpage_WHVC.h"

#import "WH_WKWebView_JXViewController.h"

@implementation WH_JXMain_WHViewController
@synthesize tb=_tb;

@synthesize btn=_btn,mainView=_mainView;
@synthesize IS_HR_MODE;

@synthesize psMyviewVC=_psMyviewVC;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [UIColor clearColor];
        
//        g_navigation.lastVC = nil;
//        [g_navigation.subViews removeAllObjects];
//        [g_navigation pushViewController:self animated:YES];
//        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
        //        [self.view addSubview:_topView];

        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM)];
        [self.view addSubview:_mainView];

        
        //底部TabBar的(容器)
        _bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
        _bottomView.userInteractionEnabled = YES;
        [self.view addSubview:_bottomView];

        
        [self buildTop];
        
        [g_notify addObserver:self selector:@selector(WH_onXmppLoginChanged:) name:kXmppLogin_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(hasLoginOther:) name:kXMPPLoginOther_WHNotification object:nil];
        
        
#ifdef IS_SHOW_MENU
//        _squareVC = [[JXSquareViewController alloc] init];
        
        self.findVC = [[WH_FindViewController alloc] init];///发现
#else
        _weiboVC = [WeiboViewControlle alloc];
        _weiboVC.user = g_myself;
        _weiboVC = [_weiboVC init];
#endif
        _groupVC = [[WH_JXGroup_WHViewController alloc]init];
        _msgVc = [[WH_JXMsg_WHViewController alloc] init];
        _addressbookVC = [[WH_Addressbook_WHController alloc] init];
        
        _mineVC = [[WH_MineViewController alloc] init];
        
#ifdef IS_OPEN_CUSTOM_TAB
        NSDictionary *tabBarConfig = g_config.tabBarConfigList;
        if (tabBarConfig) {
            //有自定义tab
//            self.customTabVC = [WH_webpage_WHVC alloc];
//            NSString *tabBarLinkUrl = tabBarConfig[@"tabBarLinkUrl"];
//            self.customTabVC.wh_isGotoBack = NO;
//            self.customTabVC.isSend = NO;
//            self.customTabVC.url = tabBarLinkUrl;
//            self.customTabVC.isOnMainVC = YES;
//            self.customTabVC = [self.customTabVC init];
            
            self.wkWebViewVC = [[WH_WKWebView_JXViewController alloc] init];
            NSString *tabBarLinkUrl = tabBarConfig[@"tabBarLinkUrl"];
            self.wkWebViewVC.url = tabBarLinkUrl;
        }
#endif
//#ifdef Live_Version
//        _liveVC = [[WH_JXLive_WHViewController alloc]init];
//#else
//        _organizVC = [[WH_OrganizTree_WHViewController alloc] init];
//#endif
//
        
        [self doSelected:0];

        [g_notify addObserver:self selector:@selector(loginSynchronizeFriends:) name:kXmppClickLogin_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(appDidEnterForeground) name:kApplicationWillEnterForeground object:nil];
        
        [g_notify addObserver:self selector:@selector(tongBuQuanZu) name:kJinQianTaiTongBuQuanZu_WHNotifaction object:nil];
        
        
    }
    return self;
}

- (void)tongBuQuanZu
{
    [g_server WH_listHisRoomWithPage:0 pageSize:5000 toView:self];
}

-(void)dealloc{
    
    [g_notify  removeObserver:self name:kXmppLogin_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kSystemLogin_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXmppClickLogin_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPLoginOther_WHNotification object:nil];
    [g_notify  removeObserver:self name:kApplicationWillEnterForeground object:nil];
    [g_notify removeObserver:self name:kJinQianTaiTongBuQuanZu_WHNotifaction object:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loginSynchronizeFriends:nil];
    
    //获取个人信息
    [g_server getUser:MY_USER_ID toView:self];
    
    // 同步标签
    [g_server WH_friendGroupListToView:self];
    // 获取服务器时间
    [g_server getCurrentTimeToView:self];
}


- (void)appDidEnterForeground {
    // 获取服务器时间
    [g_server getCurrentTimeToView:self];
}

- (void)loginSynchronizeFriends:(NSNotification*)notification{
    //判断服务器好友数量是否与本地一致
    _friendArray = [g_myself WH_fetchAllFriendsOrNotFromLocal];
//    NSLog(@"%d -------%ld",[g_myself.friendCount intValue] , [_friendArray count]);
//    if ([g_myself.friendCount intValue] > [_friendArray count] && [g_myself.friendCount intValue] >0) {
//        [g_App showAlert:Localized(@"JXAlert_SynchFirendOK") delegate:self];
    if ([g_myself.isupdate intValue] == 1 || _friendArray.count <= 0) {
        [g_server WH_listAttentionWithPage:0 userId:MY_USER_ID toView:self];
    }else{
        
        [[JXXMPP sharedInstance] performSelector:@selector(login) withObject:nil afterDelay:2];//2秒后执行xmpp登录
    }
    
    [g_server WH_listBlacklistWithPage:0 toView:self];
//    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10002) {
        [g_server performSelector:@selector(showLogin) withObject:nil afterDelay:0.5];
        return;
    }else if (buttonIndex == 1) {
        [g_server WH_listAttentionWithPage:0 userId:MY_USER_ID toView:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)buildTop{
    _tb = [WH_JXTabMenuView alloc];
#ifdef IS_OPEN_CUSTOM_TAB
    NSDictionary *tabBarConfig = g_config.tabBarConfigList;
    NSString *tabBarName = [tabBarConfig objectForKey:@"tabBarName"]?:@"";
    if (tabBarConfig && tabBarName.length> 0 && ![tabBarName isKindOfClass:[NSNull class]]) {
        //有自定义tab
        NSString *tabBarImg = tabBarConfig[@"tabBarImg"]?:@"wk";
        NSString *tabBarName = tabBarConfig[@"tabBarName"]?:@"";
        NSString *tabBarImg1 = tabBarConfig[@"tabBarImg1"]?:@"wk";
        
        NSString *selectImgName = tabBarImg1;
        if (selectImgName.length == 0) {
            selectImgName = tabBarImg;
        }
        
        _tb.wh_items = [NSArray arrayWithObjects:Localized(@"WaHu_JXMain_WaHuViewController_Message"),Localized(@"JX_MailList"),tabBarName,Localized(@"WaHu_JXMain_WaHuViewController_Find"),Localized(@"JX_My"),nil];
        _tb.wh_imagesNormal = [NSArray arrayWithObjects:@"xiaoximoren",@"tongxunlumoren",tabBarImg,@"guangchangmoren",@"wodemoren",nil];
        _tb.wh_imagesSelect = [NSArray arrayWithObjects:@"xiaoxixuanzhong",@"tongxunluxuanzhong",selectImgName,@"guangchangxuanzhong",@"wodexuanzhong",nil];
    } else {
        _tb.wh_items = [NSArray arrayWithObjects:Localized(@"WaHu_JXMain_WaHuViewController_Message"),Localized(@"JX_MailList"),Localized(@"WaHu_JXMain_WaHuViewController_Find"),Localized(@"JX_My"),nil];
        _tb.wh_imagesNormal = [NSArray arrayWithObjects:@"xiaoximoren",@"tongxunlumoren",@"guangchangmoren",@"wodemoren",nil];
        _tb.wh_imagesSelect = [NSArray arrayWithObjects:@"xiaoxixuanzhong",@"tongxunluxuanzhong",@"guangchangxuanzhong",@"wodexuanzhong",nil];
    }
#else
    _tb.items = [NSArray arrayWithObjects:Localized(@"WaHu_JXMain_WaHuViewController_Message"),Localized(@"JX_MailList"),Localized(@"WaHu_JXMain_WaHuViewController_Find"),Localized(@"JX_My"),nil];
    _tb.imagesNormal = [NSArray arrayWithObjects:@"xiaoximoren",@"tongxunlumoren",@"guangchangmoren",@"wodemoren",nil];
    _tb.imagesSelect = [NSArray arrayWithObjects:@"xiaoxixuanzhong",@"tongxunluxuanzhong",@"guangchangxuanzhong",@"wodexuanzhong",nil];
#endif
    
    _tb.wh_delegate  = self;
    _tb.wh_onDragout = @selector(wh_onDragout:);
    [_tb setWh_backgroundImageName:@"MessageListCellBkg"];
    _tb.wh_onClick  = @selector(actionSegment:);
    _tb = [_tb initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
    [_bottomView addSubview:_tb];
    
    
    NSMutableArray *remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    [_tb wh_setBadge:_tb.wh_items.count == 5 ? 3 : 2 title:[NSString stringWithFormat:@"%lu",(unsigned long)remindArray.count]];
}


-(void)actionSegment:(UIButton*)sender{
    [self doSelected:(int)sender.tag];
}

-(void)doSelected:(int)n{
    [_selectVC.view removeFromSuperview];
    
#ifdef IS_OPEN_CUSTOM_TAB
    NSDictionary *tabBarConfig = g_config.tabBarConfigList;
    NSString *tabBarName = [tabBarConfig objectForKey:@"tabBarName"]?:@"";
    if (tabBarConfig && tabBarName.length > 0 && ![tabBarName isKindOfClass:[NSNull class]]) {
        //有自定义tab
        [self hasCustomTabSelectedHandle:n];
    } else {
        [self noCustomTabSelectedHandler:n];
    }
#else
    [self noCustomTabSelectedHandler:n];
#endif
    
    [_tb wh_selectOne:n];
    [_mainView addSubview:_selectVC.view];
}

#pragma mark 有自定义底部导航
- (void)hasCustomTabSelectedHandle:(int)n {
    
    if (self.selTabBarIndex == n && n == 2) {
        //重复点击tabBar网站
        [self.customTabVC.webView reload];
        return;
    }

    switch (n){
        case 0:
            _selectVC = _msgVc;
            break;
        case 1:
            _selectVC = _addressbookVC;
            break;
        case 2:
            //自定义菜单
//            _selectVC = self.customTabVC;
            _selectVC = self.wkWebViewVC;
            break;
        case 3:
            //发现
#ifdef IS_SHOW_MENU
            _selectVC = _findVC;
#else
            _selectVC = _weiboVC;
#endif
            break;
            
        case 4:
            //我的
            _selectVC = _mineVC;
            break;
    }
    
    self.selTabBarIndex = n;

}

//无自定义tab
- (void)noCustomTabSelectedHandler:(int)n{
    switch (n){
        case 0:
            _selectVC = _msgVc;
            break;
        case 1:
            _selectVC = _addressbookVC;
            break;
        case 2:
#ifdef IS_SHOW_MENU
            //            _selectVC = _squareVC;
            _selectVC = _findVC;
#else
            _selectVC = _weiboVC;
#endif
            break;
        case 3:
            _selectVC = _mineVC;
            break;
    }
}

//有自定义tab
- (void)haveCustomTabSelectedHandler:(int)n{
    switch (n){
        case 0:
            _selectVC = _msgVc;
            break;
        case 1:
            _selectVC = _addressbookVC;
            break;
        case 2:
//            _selectVC = _customTabVC;
            _selectVC = self.wkWebViewVC;
            break;
        case 3:
#ifdef IS_SHOW_MENU
            //            _selectVC = _squareVC;
            _selectVC = _findVC;
#else
            _selectVC = _weiboVC;
#endif
            break;
        case 4:
            _selectVC = _mineVC;
            break;
    }
}

-(void)WH_onXmppLoginChanged:(NSNumber*)isLogin{
    if([JXXMPP sharedInstance].isLogined == login_status_yes)
        [self onAfterLogin];
    switch (_tb.wh_selected){
        case 0:
            _btn.hidden = [JXXMPP sharedInstance].isLogined;
            break;
        case 1:
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            break;
        case 2:
            _btn.hidden = NO;
            break;
        case 3:
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            break;
    }
}

-(void)onAfterLogin{
//    [_msgVc WH_scrollToPageUp];
}

-(void)hasLoginOther:(NSNotification *)notifcation{
    [g_App showAlert:Localized(@"JXXMPP_Other") delegate:self tag:10002 onlyConfirm:YES];
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if ([aDownload.action isEqualToString:wh_act_UserGet]) {
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        [g_myself WH_getDataFromDict:dict];
        g_constant.isAddFriend = user.isAddFirend;
    }
    //更新本地好友
    if ([aDownload.action isEqualToString:wh_act_AttentionList]) {
        WH_JXProgress_WHVC * pv = [WH_JXProgress_WHVC alloc];
        pv.dbFriends = (long)[_friendArray count];
        pv.dataArray = array1;
        pv = [pv init];
        if (array1.count > 300) {
            [g_navigation pushViewController:pv animated:YES];
        }
//        [self.view addSubview:pv.view];
        
    }
    
    if ([aDownload.action isEqualToString:wh_act_BlacklistList]) {
        for (int i = 0; i< [array1 count]; i++) {
            NSDictionary * dict = array1[i];
            WH_JXUserObject * user = [[WH_JXUserObject alloc]init];
            //数据转为一个好友对象
            [user WH_getDataFromDictSmall:dict];
            //访问数据库是否存在改好友，没有则写入数据库
            if (user.userId.length > 5) {
                [user insertFriend];
            }
        }
    }
    
    // 同步标签
    if ([aDownload.action isEqualToString:wh_act_FriendGroupList]) {
        
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            WH_JXLabelObject *labelObj = [[WH_JXLabelObject alloc] init];
            labelObj.groupId = dict[@"groupId"];
            labelObj.groupName = dict[@"groupName"];
            labelObj.userId = dict[@"userId"];
            
            NSArray *userIdList = dict[@"userIdList"];
            NSString *userIdListStr = [userIdList componentsJoinedByString:@","];
            if (userIdListStr.length > 0) {
                labelObj.userIdList = [NSString stringWithFormat:@"%@", userIdListStr];
            }
            [labelObj insert];
        }
        
        // 删除服务器上已经删除的
        NSArray *arr = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        for (NSInteger i = 0; i < arr.count; i ++) {
            WH_JXLabelObject *locLabel = arr[i];
            BOOL flag = NO;
            for (NSInteger j = 0; j < array1.count; j ++) {
                NSDictionary * dict = array1[j];
               
                if ([locLabel.groupId isEqualToString:dict[@"groupId"]]) {
                    flag = YES;
                    break;
                }
            }
            
            if (!flag) {
                [locLabel delete];
            }
        }
    }
    
    
    //保存所有进入过的房间
    if ([aDownload.action isEqualToString:wh_act_roomListHis]) {
        for (int i = 0; i < [array1 count]; i++) {
            NSDictionary *dict=array1[i];
            
            WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
            user.userNickname = [dict objectForKey:@"name"];
            user.userId = [dict objectForKey:@"jid"];
            user.userDescription = [dict objectForKey:@"desc"];
            user.roomId = [dict objectForKey:@"id"];
            user.showRead = [dict objectForKey:@"showRead"];
            user.showMember = [dict objectForKey:@"showMember"];
            user.allowSendCard = [dict objectForKey:@"allowSendCard"];
            user.chatRecordTimeOut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"chatRecordTimeOut"]];
            user.offlineNoPushMsg = [[dict objectForKey:@"member"] objectForKey:@"offlineNoPushMsg"];
            user.talkTime = [dict objectForKey:@"talkTime"];
            user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
            user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
            user.allowConference = [dict objectForKey:@"allowConference"];
            user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
            user.category = [dict objectForKey:@"category"];
            user.createUserId = [dict objectForKey:@"userId"];
            
            if (![user haveTheUser]){
                [user insertRoom];
            }else {
                [user WH_updateUserNickname];
            }
            
        }
        
        [g_notify postNotificationName:kJinQianTaiTongBuQuanZuComplete_WHNotifaction object:nil];
    }
    
    
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    if ([aDownload.action isEqualToString:wh_act_roomListHis]){
        [g_notify postNotificationName:kJinQianTaiTongBuQuanZuComplete_WHNotifaction object:nil];
    }
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    if ([aDownload.action isEqualToString:wh_act_roomListHis]){
        [g_notify postNotificationName:kJinQianTaiTongBuQuanZuComplete_WHNotifaction object:nil];
    }
    return WH_hide_error;
}


- (void)sp_getUsersMostLiked {
    NSLog(@"Check your Network");
}
@end
