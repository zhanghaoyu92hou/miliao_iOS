//
//  MiXin_JXMain_MiXinViewController.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "MiXin_JXMain_MiXinViewController.h"
#import "MiXin_JXTabMenuView.h"
#import "MiXin_JXMsg_MiXinViewController.h"
#import "WH_Addressbook_WHController.h"
#import "AppDelegate.h"
#import "MiXin_JXNewFriend_MiXinViewController.h"
#import "MiXin_JXFriendObject.h"
#import "MiXin_PSMy_MiXinViewController.h"
#ifdef Live_Version
#import "MiXin_JXLive_MiXinViewController.h"
#endif

#import "WeiboViewControlle.h"
#import "JXSquareViewController.h"
#import "MiXin_JXProgress_MiXinVC.h"
#import "MiXin_JXGroup_MinXinViewController.h"
#import "MiXin_OrganizTree_MiXinViewController.h"
#import "MiXin_JXLabelObject.h"
#import "JXBlogRemind.h"

#import "WH_FindViewController.h"
#import "WH_MineViewController.h"
#import "MiXin_webpage_MiXinVC.h"

@implementation MiXin_JXMain_MiXinViewController
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
        
        [g_notify addObserver:self selector:@selector(MiXin_onXmppLoginChanged:) name:kXmppLoginNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(hasLoginOther:) name:kXMPPLoginOtherNotification object:nil];
        
        
#ifdef IS_SHOW_MENU
//        _squareVC = [[JXSquareViewController alloc] init];
        
        self.findVC = [[WH_FindViewController alloc] init];///发现
#else
        _weiboVC = [WeiboViewControlle alloc];
        _weiboVC.user = g_server.myself;
        _weiboVC = [_weiboVC init];
#endif
        _groupVC = [[MiXin_JXGroup_MinXinViewController alloc]init];
        _msgVc = [[MiXin_JXMsg_MiXinViewController alloc] init];
        _addressbookVC = [[WH_Addressbook_WHController alloc] init];
        _psMyviewVC = [[MiXin_PSMy_MiXinViewController alloc] init];
        
        _mineVC = [[WH_MineViewController alloc] init];
        
#ifdef IS_OPEN_CUSTOM_TAB
        NSDictionary *tabBarConfig = g_config.tabBarConfigList;
        if (tabBarConfig) {
            //有自定义tab
            self.customTabVC = [MiXin_webpage_MiXinVC alloc];
            NSString *tabBarLinkUrl = tabBarConfig[@"tabBarLinkUrl"];
            self.customTabVC.isGotoBack= NO;
            self.customTabVC.isSend = NO;
            self.customTabVC.url = tabBarLinkUrl;
            self.customTabVC.isCustomer = YES;
            self.customTabVC = [self.customTabVC init];
        }
#endif
//#ifdef Live_Version
//        _liveVC = [[MiXin_JXLive_MiXinViewController alloc]init];
//#else
//        _organizVC = [[MiXin_OrganizTree_MiXinViewController alloc] init];
//#endif
//
        
        [self doSelected:0];

        [g_notify addObserver:self selector:@selector(loginSynchronizeFriends:) name:kXmppClickLoginNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(appDidEnterForeground) name:kApplicationWillEnterForeground object:nil];
    }
    return self;
}

-(void)dealloc{
//    [_psMyviewVC.view release];
//    [_msgVc.view release];
    [g_notify  removeObserver:self name:kXmppLoginNotifaction object:nil];
    [g_notify  removeObserver:self name:kSystemLoginNotifaction object:nil];
    [g_notify  removeObserver:self name:kXmppClickLoginNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPLoginOtherNotification object:nil];
    [g_notify  removeObserver:self name:kApplicationWillEnterForeground object:nil];
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loginSynchronizeFriends:nil];
    
    // 同步标签
    [g_server friendGroupListToView:self];
    // 获取服务器时间
    [g_server getCurrentTimeToView:self];
}


- (void)appDidEnterForeground {
    // 获取服务器时间
    [g_server getCurrentTimeToView:self];
}

- (void)loginSynchronizeFriends:(NSNotification*)notification{
    //判断服务器好友数量是否与本地一致
    _friendArray = [g_server.myself MiXin_fetchAllFriendsOrNotFromLocal];
//    NSLog(@"%d -------%ld",[g_server.myself.friendCount intValue] , [_friendArray count]);
//    if ([g_server.myself.friendCount intValue] > [_friendArray count] && [g_server.myself.friendCount intValue] >0) {
//        [g_App showAlert:Localized(@"JXAlert_SynchFirendOK") delegate:self];
    if ([g_myself.isupdate intValue] == 1 || _friendArray.count <= 0) {
        [g_server listAttention:0 userId:MY_USER_ID toView:self];
    }else{
        
        [[JXXMPP sharedInstance] performSelector:@selector(login) withObject:nil afterDelay:2];//2秒后执行xmpp登录
    }
    
    [g_server listBlacklist:0 toView:self];
//    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10002) {
        [g_server performSelector:@selector(showLogin) withObject:nil afterDelay:0.5];
        return;
    }else if (buttonIndex == 1) {
        [g_server listAttention:0 userId:MY_USER_ID toView:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)buildTop{
    _tb = [MiXin_JXTabMenuView alloc];
#ifdef IS_OPEN_CUSTOM_TAB
    NSDictionary *tabBarConfig = g_config.tabBarConfigList;
    NSString *tabBarName = [tabBarConfig objectForKey:@"tabBarName"]?:@"";
    if (tabBarConfig && tabBarName.length> 0 && ![tabBarName isKindOfClass:[NSNull class]]) {
        //有自定义tab
        NSString *tabBarImg = tabBarConfig[@"tabBarImg"]?:@"";
        NSString *tabBarName = tabBarConfig[@"tabBarName"]?:@"";
        NSString *tabBarImg1 = tabBarConfig[@"tabBarImg1"]?:@"";
        
        NSString *selectImgName = tabBarImg1;
        if (selectImgName.length == 0) {
            selectImgName = tabBarImg;
        }
        
        _tb.items = [NSArray arrayWithObjects:Localized(@"MiXin_JXMain_MiXinViewController_Message"),Localized(@"JX_MailList"),tabBarName,Localized(@"MiXin_JXMain_MiXinViewController_Find"),Localized(@"JX_My"),nil];
        _tb.imagesNormal = [NSArray arrayWithObjects:@"xiaoximoren",@"tongxunlumoren",tabBarImg,@"guangchangmoren",@"wodemoren",nil];
        _tb.imagesSelect = [NSArray arrayWithObjects:@"xiaoxixuanzhong",@"tongxunluxuanzhong",selectImgName,@"guangchangxuanzhong",@"wodexuanzhong",nil];
    } else {
        _tb.items = [NSArray arrayWithObjects:Localized(@"MiXin_JXMain_MiXinViewController_Message"),Localized(@"JX_MailList"),Localized(@"MiXin_JXMain_MiXinViewController_Find"),Localized(@"JX_My"),nil];
        _tb.imagesNormal = [NSArray arrayWithObjects:@"xiaoximoren",@"tongxunlumoren",@"guangchangmoren",@"wodemoren",nil];
        _tb.imagesSelect = [NSArray arrayWithObjects:@"xiaoxixuanzhong",@"tongxunluxuanzhong",@"guangchangxuanzhong",@"wodexuanzhong",nil];
    }
#else
    _tb.items = [NSArray arrayWithObjects:Localized(@"MiXin_JXMain_MiXinViewController_Message"),Localized(@"JX_MailList"),Localized(@"MiXin_JXMain_MiXinViewController_Find"),Localized(@"JX_My"),nil];
    _tb.imagesNormal = [NSArray arrayWithObjects:@"xiaoximoren",@"tongxunlumoren",@"guangchangmoren",@"wodemoren",nil];
    _tb.imagesSelect = [NSArray arrayWithObjects:@"xiaoxixuanzhong",@"tongxunluxuanzhong",@"guangchangxuanzhong",@"wodexuanzhong",nil];
#endif
    
    _tb.delegate  = self;
    _tb.onDragout = @selector(onDragout:);
    [_tb setBackgroundImageName:@"MessageListCellBkg"];
    _tb.onClick  = @selector(actionSegment:);
    _tb = [_tb initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM)];
    [_bottomView addSubview:_tb];
    
    
    NSMutableArray *remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    [_tb setBadge:_tb.items.count == 5 ? 3 : 2 title:[NSString stringWithFormat:@"%lu",(unsigned long)remindArray.count]];
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
    
    [_tb selectOne:n];
    [_mainView addSubview:_selectVC.view];
}

#pragma mark 有自定义底部导航
- (void)hasCustomTabSelectedHandle:(int)n {
    switch (n){
        case 0:
            _selectVC = _msgVc;
            break;
        case 1:
            _selectVC = _addressbookVC;
            break;
        case 2:
            //自定义菜单
            _selectVC = self.customTabVC;
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
            //            _selectVC = _psMyviewVC;
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
            _selectVC = _customTabVC;
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
            //            _selectVC = _psMyviewVC;
            _selectVC = _mineVC;
            break;
    }
}

-(void)MiXin_onXmppLoginChanged:(NSNumber*)isLogin{
    if([JXXMPP sharedInstance].isLogined == login_status_yes)
        [self onAfterLogin];
    switch (_tb.selected){
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
//    [_msgVc MiXin_scrollToPageUp];
}

-(void)hasLoginOther:(NSNotification *)notifcation{
    [g_App showAlert:Localized(@"JXXMPP_Other") delegate:self tag:10002 onlyConfirm:YES];
}

#pragma mark - 请求成功回调
-(void) MiXin_didServerResult_MiXinSucces:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //更新本地好友
    if ([aDownload.action isEqualToString:act_AttentionList]) {
        MiXin_JXProgress_MiXinVC * pv = [MiXin_JXProgress_MiXinVC alloc];
        pv.dbFriends = (long)[_friendArray count];
        pv.dataArray = array1;
        pv = [pv init];
        if (array1.count > 300) {
            [g_navigation pushViewController:pv animated:YES];
        }
//        [self.view addSubview:pv.view];
        
    }
    
    if ([aDownload.action isEqualToString:act_BlacklistList]) {
        for (int i = 0; i< [array1 count]; i++) {
            NSDictionary * dict = array1[i];
            MiXin_JXUserObject * user = [[MiXin_JXUserObject alloc]init];
            //数据转为一个好友对象
            [user MiXin_getDataFromDictSmall:dict];
            //访问数据库是否存在改好友，没有则写入数据库
            if (user.userId.length > 5) {
                [user insertFriend];
            }
        }
    }
    
    // 同步标签
    if ([aDownload.action isEqualToString:act_FriendGroupList]) {
        
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            MiXin_JXLabelObject *labelObj = [[MiXin_JXLabelObject alloc] init];
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
        NSArray *arr = [[MiXin_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        for (NSInteger i = 0; i < arr.count; i ++) {
            MiXin_JXLabelObject *locLabel = arr[i];
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
}

#pragma mark - 请求失败回调
-(int) MiXin_didServerResult_MinXinFailed:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict{
    
    return hide_error;
}

#pragma mark - 请求出错回调
-(int) MiXin_didServerConnect_MiXinError:(MiXin_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    
    return hide_error;
}

@end
