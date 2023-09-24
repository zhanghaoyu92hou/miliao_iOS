//
//  WH_Addressbook_WHController.m
//  Tigase
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_Addressbook_WHController.h"
#import "WH_SegmentSwitch.h"
#import "WH_AddressbookSwitch_WHController.h"
#import "WH_JXFriend_WHViewController.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_JXGroup_WHViewController.h"
#import "WH_JXSearchUser_WHVC.h"
#import "WH_JX_SelectMenuView.h"
#import "WH_JXNear_WHVC.h"
#import "WH_AddFriend_WHController.h"
#import "WH_JXTabMenuView.h"

@interface WH_Addressbook_WHController () <JXSelectMenuViewDelegate>

@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) WH_AddressbookSwitch_WHController *switchVC;
@property (nonatomic, strong) WH_SegmentSwitch *addressSwitch;

@end

@implementation WH_Addressbook_WHController

- (id)init {
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = JX_SCREEN_BOTTOM;
        self.title = Localized(@"JX_MailList");
        [self createHeadAndFoot];
        [self setupSwitchVC];
        [self buildTop];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    current_chat_userId = nil;
}

-(void)buildTop{
    //刷新好友列表
    //    UIButton * getFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-35, JX_SCREEN_TOP - 34, 30, 30)];
    //    getFriendBtn.custom_acceptEventInterval = .25f;
    //    [getFriendBtn addTarget:self action:@selector(getFriend) forControlEvents:UIControlEventTouchUpInside];
    ////    [getFriendBtn setImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
    //    [getFriendBtn setBackgroundImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
    //    [self.wh_tableHeader addSubview:getFriendBtn];
    
    _addressSwitch = [[WH_SegmentSwitch alloc] initWithFrame:CGRectMake(92, JX_SCREEN_TOP - 8 - 28, 192, 28) titles:@[@"全部",@"群组",@"新朋友"] slideColor:HEXCOLOR(0x0093FF)];
    //[self.wh_tableHeader addSubview:_addressSwitch];//隐藏切换按钮
    __weak typeof(self) weakSelf = self;
    _addressSwitch.WH_onClickBtn = ^(NSInteger index) {
        weakSelf.switchVC.currentPageIndex = index;
        [weakSelf switchVCHandler];
        if (index == 0) {
            //全部
            current_chat_userId = nil;
        } else if (index == 1){
            //群组
            current_chat_userId = nil;
        } else {
            current_chat_userId = FRIEND_CENTER_USERID;
            //新朋友
            //消除小红点
            
            // 清空角标
            WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
            newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:FRIEND_CENTER_USERID];
            newobj.message = [[WH_JXMessageObject alloc] init];
            newobj.message.toUserId = FRIEND_CENTER_USERID;
            newobj.user.msgsNew = [NSNumber numberWithInt:0];
            [newobj.message WH_updateNewMsgsTo0];
            
            NSArray *friends = [[WH_JXFriendObject sharedInstance] WH_fetchAllFriendsFromLocal];
            for (NSInteger i = 0; i < friends.count; i ++) {
                WH_JXFriendObject *friend = friends[i];
                if ([friend.msgsNew integerValue] > 0) {
                    [friend updateNewMsgUserId:friend.userId num:0];
                }
            }
            
//            [friendVC showNewMsgCount:0];
            
            [weakSelf.addressSwitch WH_setRedDotWithSegmentIndex:2 isHidden:YES];
            [g_mainVC.tb wh_setBadge:1 title:@"0"];
        }
    };
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH -NAV_INSETS - 24-BTN_RANG_UP*2, JX_SCREEN_TOP - 34-BTN_RANG_UP, 24+BTN_RANG_UP*2, 24+BTN_RANG_UP*2)];
    [btn addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableHeader addSubview:btn];
    
    self.moreBtn = [UIFactory WH_create_WHButtonWithImage:@"WH_addressbook_add"
                                                      highlight:nil
                                                         target:self
                                                       selector:@selector(onMore:)];
    self.moreBtn.custom_acceptEventInterval = 1.0f;
    self.moreBtn.frame = CGRectMake(BTN_RANG_UP * 2, BTN_RANG_UP, NAV_BTN_SIZE, NAV_BTN_SIZE);
    [btn addSubview:self.moreBtn];
}

- (void)setupSwitchVC{
    _switchVC = [[WH_AddressbookSwitch_WHController alloc] init];
    [self.view addSubview:_switchVC.view];
    _switchVC.view.frame = CGRectMake(0, JX_SCREEN_TOP, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - JX_SCREEN_TOP - JX_SCREEN_BOTTOM);
    NSArray *vcNames = @[@"WH_JXFriend_WHViewController",@"WH_JXGroup_WHViewController",@"WH_JXNewFriend_WHViewController"];
    NSMutableArray *vcs = [NSMutableArray array];
    UIViewController *controller = nil;
    for (NSString *vcName in vcNames) {
        controller = [[NSClassFromString(vcName) alloc] init];
        controller.view.backgroundColor = g_factory.globalBgColor;
        [vcs addObject:controller];
    }
    [_switchVC setupViewControllers:vcs];
    __weak typeof(self) weakSelf = self;
    _switchVC.onCurrentIndexChange = ^(NSInteger currentPageIndex) {
        weakSelf.addressSwitch.wh_currentIndex = currentPageIndex;
        [weakSelf switchVCHandler];
    };
}

- (void)switchVCHandler{
    [_switchVC.view endEditing:YES];
}

- (void) showNewMsgCount:(NSInteger)friendNewMsgNum{
    [_addressSwitch WH_setRedDotWithSegmentIndex:2 isHidden:friendNewMsgNum <= 0];
}

#pragma mark 右上角更多
-(void)onMore:(UIButton *)sender{
    if ([g_config.hideSearchByFriends intValue] == 1 && ([g_config.isCommonFindFriends intValue] == 0 || g_myself.role.count > 0)) {
        [self onSearch];
    }else {
//        NSMutableArray *titles = [NSMutableArray arrayWithArray:@[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_Scan"), Localized(@"WaHu_JXNear_WaHuVC_NearPer"),Localized(@"JX_SearchPublicNumber")]];
//        NSMutableArray *images = [NSMutableArray arrayWithArray:@[@"message_creat_group_black", @"messaeg_scnning_black", @"message_near_person_black",@"message_search_publicNumber"]];
//        NSMutableArray *sels = [NSMutableArray arrayWithArray:@[@"onNewRoom", @"showScanViewController", @"onNear",@"searchPublicNumber"]];
//        if ([g_App.config.isCommonCreateGroup intValue] == 1 && role.count <= 0) {
//            [titles removeObject:Localized(@"JX_LaunchGroupChat")];
//            [images removeObject:@"message_creat_group_black"];
//            [sels removeObject:@"onNewRoom"];
//        }
//        if ([g_App.config.isOpenPositionService intValue] == 1) {
//            [titles removeObject:Localized(@"WaHu_JXNear_WaHuVC_NearPer")];
//            [images removeObject:@"message_near_person_black"];
//            [sels removeObject:@"onNear"];
//        }
//        WH_JX_SelectMenuView *menuView = [[WH_JX_SelectMenuView alloc] initWithTitle:titles image:images cellHeight:45];
//        menuView.sels = sels;
//        menuView.delegate = self;
//        [g_App.window addSubview:menuView];
        
        [self.moreBtn setHidden:YES];
    }
    
    //    _control.hidden = YES;
    //    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    //    CGRect moreFrame = [self.wh_tableHeader convertRect:self.moreBtn.frame toView:window];
    //
    //    WH_JX_SelectMenuView *menuView = [[WH_JX_SelectMenuView alloc] initWithTitle:@[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"WaHu_JXNear_WHVC_NearPer")] image:@[@"message_creat_group_black", @"message_add_friend_black", @"messaeg_scnning_black", @"message_near_person_black"] cellHeight:45];
    //    menuView.delegate = self;
    //    [g_App.window addSubview:menuView];
    
    //    WH_JX_DownListView * downListView = [[WH_JX_DownListView alloc] initWithFrame:self.view.bounds];
    //    downListView.listContents = @[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"WaHu_JXNear_WHVC_NearPer")];
    //    downListView.listImages = @[@"message_creat_group_black", @"message_add_friend_black", @"messaeg_scnning_black", @"message_near_person_black"];
    //
    //    __weak typeof(self) weakSelf = self;
    //    [downListView WH_downlistPopOption:^(NSInteger index, NSString *content) {
    //
    //        [weakSelf moreListActionWithIndex:index];
    //
    //    } whichFrame:moreFrame animate:YES];
    //    [downListView show];
    
    //    self.treeView.editing = !self.treeView.editing;
    
}

//搜索好友
-(void)onSearch{
//    WH_JXSearchUser_WHVC* vc = [WH_JXSearchUser_WHVC alloc];
//    vc.delegate  = self;
//    vc.didSelect = @selector(doSearch:);
//    vc.type = JXSearchTypeUser;
//    vc = [vc init];
    WH_AddFriend_WHController *vc = [[WH_AddFriend_WHController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
    
    [self WH_cancelBtnAction];
}

- (void) WH_cancelBtnAction {
//    if (_seekTextField.text.length > 0) {
//        _seekTextField.text = nil;
//        [self getArrayData];
//    }
//    [_seekTextField resignFirstResponder];
//    [self.tableView reloadData];
}

-(void)doSearch:(WH_SearchData*)p{
    
    WH_JXNear_WHVC *nearVC = [[WH_JXNear_WHVC alloc]init];
    nearVC.wh_isSearch = YES;
    [g_navigation pushViewController:nearVC animated:YES];
    [nearVC doSearch:p];
}



@end
