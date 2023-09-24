//
//  WH_JXFriend_WHViewController.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXFriend_WHViewController.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "WH_JX_WHCell.h"
#import "WH_JXRoomPool.h"
#import "JXTableView.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_menuImageView.h"
#import "FMDatabase.h"
#import "WH_JXProgress_WHVC.h"
#import "WH_JXTopSiftJobView.h"
#import "WH_JXUserInfo_WHVC.h"
#import "BMChineseSort.h"
#import "WH_JXGroup_WHViewController.h"
#import "WH_OrganizTree_WHViewController.h"
#import "WH_JXTabMenuView.h"
#import "WH_JXPublicNumber_WHVC.h"
#import "WH_JXBlackFriend_WHVC.h"
#import "WH_JX_DownListView.h"
#import "WH_JXNewRoom_WHVC.h"
#import "WH_JXNear_WHVC.h"
#import "WH_JXSearchUser_WHVC.h"
#import "WH_JXScanQR_WHViewController.h"
#import "WH_JXLabel_WHVC.h"
#import "WH_JXAddressBook_WHVC.h"
#import "WH_SegmentSwitch.h"
#import "UIButton+WH_Button.h"
#import "WH_BlackList_WHController.h"
#import "WH_Addressbook_WHController.h"
#import "MiXin_CompanyListController.h"

#define HEIGHT 60
#define IMAGE_HEIGHT  38  // 图片宽高
#define INSET_HEIGHT  10  // 图片文字间距


@interface WH_JXFriend_WHViewController ()<UITextFieldDelegate,JXSelectMenuViewDelegate>
@property (nonatomic, strong) WH_JXUserObject * currentUser;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;


@property (nonatomic, strong) UILabel *friendNewMsgNum;
@property (nonatomic, strong) UILabel *abNewMsgNum;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIButton *friendNewNumberButton;

@property (nonatomic, assign) CGFloat btnHeight;  // 按钮的真实高度

@end

@implementation WH_JXFriend_WHViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isOneInit = YES;
        self.wh_heightHeader = .0f;
        self.wh_heightFooter = .0f;
        if (_isMyGoIn) {
            self.wh_isGotoBack   = YES;
            self.wh_heightFooter = 0;
        }
//        self.view.frame = g_window.bounds;
//        [self createHeadAndFoot];
//        [self buildTop];
//        CGRect frame = self.tableView.frame;
//        frame.origin.y += 40;
//        frame.size.height -= 40;
//        self.tableView.frame = frame;
        [self customView];

        _selMenu = 0;
//        self.title = Localized(@"WaHu_JXInput_WHVC_Friend");
        self.title = Localized(@"JX_MailList");
        [g_notify  addObserver:self selector:@selector(newFriend:) name:kXMPPNewFriend_WHNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(newRequest:) name:kXMPPNewRequest_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(WH_onSendTimeout:) name:kXMPPSendTimeOut_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(friendRemarkNotif:) name:kFriendRemark object:nil];
        
        [g_notify  addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsg_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(friendListRefresh:) name:kFriendListRefresh_WHNotification object:nil];
        [g_notify addObserver:self selector:@selector(refreshABNewMsgCount:) name:kRefreshAddressBookNotif object:nil];
        [g_notify addObserver:self selector:@selector(contactRegisterNotif:) name:kMsgComeContactRegister object:nil];
        [g_notify addObserver:self selector:@selector(newRequest:) name:kFriendPassNotif object:nil];
        [g_notify addObserver:self selector:@selector(WH_scrollToPageUp) name:kFriendListRefresh222_WHNotification object:nil];
        
        self.wh_isShowHeaderPull = YES;
        
        _table.backgroundColor = g_factory.globalBgColor;
        _table.sectionIndexColor = HEXCOLOR(0xAEAFB3);
    }
    return self;
}

- (void)friendListRefresh:(NSNotification *)notif {
    
    [self refresh];
}

- (void)contactRegisterNotif:(NSNotification *)notif {
    WH_JXMessageObject *msg = notif.object;
    
    NSDictionary *dict;
    if ([msg.content isKindOfClass:[NSDictionary class]]) {
        dict = (NSDictionary *)msg.content;
    }else if ([msg.content isKindOfClass:[NSString class]]) {
        dict = [msg.content mj_JSONObject];
    }
    
    JXAddressBook *addressBook = [[JXAddressBook alloc] init];
    addressBook.toUserId = [NSString stringWithFormat:@"%@",dict[@"toUserId"]];
    addressBook.toUserName = dict[@"toUserName"];
    addressBook.toTelephone = dict[@"toTelephone"];
    addressBook.telephone = dict[@"telephone"];
    addressBook.registerEd = dict[@"registerEd"];
    addressBook.registerTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"registerTime"] longLongValue]];
    addressBook.isRead = [NSNumber numberWithBool:0];
    [addressBook insert];
    
    [self refreshABNewMsgCount:nil];
}

- (void)refreshABNewMsgCount:(NSNotification *)notif {
    [self refresh];
    WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
    newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:FRIEND_CENTER_USERID];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    WH_JXMessageObject *msg = notifacation.object;
    if (![msg isAddFriendMsg]) {
        return;
    }
    if ([msg.type intValue] == 516) {
        return;
    }
    NSString* s;
    s = [msg getTableName];
    WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
    newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:s];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
    
}

- (void)showNewMsgCount:(NSInteger)friendNewMsgNum {
    if (friendNewMsgNum >= 10 && friendNewMsgNum <= 99) {
        self.friendNewMsgNum.font = sysFontWithSize(12);
    }else if (friendNewMsgNum > 0 && friendNewMsgNum < 10) {
        self.friendNewMsgNum.font = sysFontWithSize(13);
    }else if(friendNewMsgNum > 99){
        self.friendNewMsgNum.font = sysFontWithSize(9);
    }
    self.friendNewMsgNum.text = [NSString stringWithFormat:@"%ld",friendNewMsgNum];
    
    [g_mainVC.addressbookVC showNewMsgCount:friendNewMsgNum];
    [self.friendNewNumberButton setTitle:[NSString stringWithFormat:@"%ld",friendNewMsgNum] forState:UIControlStateNormal];
    
    if (friendNewMsgNum <= 0) {
        self.friendNewMsgNum.hidden = YES;
        self.friendNewNumberButton.hidden = YES;
    }else{
        self.friendNewMsgNum.hidden = NO;
        self.friendNewNumberButton.hidden = NO;
    }
    
    NSMutableArray *abUread = [[JXAddressBook sharedInstance] doFetchUnread];
    if (abUread.count >= 10 && abUread.count <= 99) {
        self.friendNewMsgNum.font = sysFontWithSize(12);
    }else if (abUread.count > 0 && abUread.count < 10) {
        self.friendNewMsgNum.font = sysFontWithSize(13);
    }else if(abUread.count > 99){
        self.friendNewMsgNum.font = sysFontWithSize(9);
    }

    self.abNewMsgNum.text = [NSString stringWithFormat:@"%ld",abUread.count];
    if (abUread.count <= 0) {
        self.abNewMsgNum.hidden = YES;
    }else {
        self.abNewMsgNum.hidden = NO;
    }
    
    NSInteger num = friendNewMsgNum + abUread.count;
    if (num <= 0) {
        [g_mainVC.tb wh_setBadge:1 title:@"0"];
    }else {
        [g_mainVC.tb wh_setBadge:1 title:[NSString stringWithFormat:@"%ld", num]];
    }
}

// 清空角标
- (void)clearNewMsgCount {
    
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
    
    self.friendNewNumberButton.hidden = YES;
    [g_mainVC.tb wh_setBadge:1 title:@"0"];
}

-(void)newRequest:(NSNotification *)notifacation
{
    [self getFriend];
}

- (void)WH_scrollToPageUp {
    [self getFriend];
}

-(void)buildTop{
    //刷新好友列表
//    UIButton * getFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-35, JX_SCREEN_TOP - 34, 30, 30)];
//    getFriendBtn.custom_acceptEventInterval = .25f;
//    [getFriendBtn addTarget:self action:@selector(getFriend) forControlEvents:UIControlEventTouchUpInside];
////    [getFriendBtn setImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
//    [getFriendBtn setBackgroundImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
//    [self.wh_tableHeader addSubview:getFriendBtn];
    
    WH_SegmentSwitch *addressSwitch = [[WH_SegmentSwitch alloc] initWithFrame:CGRectZero];
    [self.wh_tableHeader addSubview:addressSwitch];
    [addressSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-8.f);
        make.width.offset(192.f);
        make.height.offset(28.f);
    }];
    __weak typeof(self) weakSelf = self;
    addressSwitch.WH_onClickBtn = ^(NSInteger index) {
        if (index == 0) {
            //全部
            
        } else if (index == 1){
            //群组
            
        } else {
            //新朋友
            
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

- (void)customView {
    //顶部筛选控件
//    _topSiftView = [[WH_JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 40)];
//    _topSiftView.delegate = self;
//    _topSiftView.isShowMoreParaBtn = NO;
//    _topSiftView.dataArray = [[NSArray alloc] initWithObjects:Localized(@"WaHu_JXInput_WHVC_FriendList"),Localized(@"JX_BlackList"), nil];
//    //    _topSiftView.searchForType = SearchForPos;
//    [self.view addSubview:_topSiftView];
    
    //搜索输入框
    
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 44+121)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    self.tableView.tableHeaderView = backView;
    //    [seekImgView release];
    
//    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
//    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(WH_cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.titleLabel.font = sysFontWithSize(14.0);
//    [backView addSubview:cancelBtn];
    
    
//    self.seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(13, 12, backView.frame.size.width - 26, 30)];
//    self.seekTextField.placeholder = [NSString stringWithFormat:@"%@",Localized(@"JX_SearchFriends")];
//    self.seekTextField.textColor = HEXCOLOR(0x969696);
//    [self.seekTextField setFont:sysFontWithSize(17)];
//    self.seekTextField.layer.cornerRadius = 5;
//    self.seekTextField.layer.masksToBounds = YES;
//    self.seekTextField.layer.borderWidth = 0.5;
//    self.seekTextField.layer.borderColor = HEXCOLOR(0xE9E9E9).CGColor;
//    self.seekTextField.backgroundColor = HEXCOLOR(0xF2F3F6);
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
//    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    //    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
//    imageView.center = leftView.center;
//    [leftView addSubview:imageView];
//    self.seekTextField.leftView = leftView;
//    self.seekTextField.leftViewMode = UITextFieldViewModeAlways;
//    self.seekTextField.borderStyle = UITextBorderStyleNone;
//    self.seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.seekTextField.delegate = self;
//    self.seekTextField.returnKeyType = UIReturnKeyGoogle;
//    [backView addSubview:self.seekTextField];
//    [self.seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self createSeekTextField:backView isFriend:YES];
    
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.seekTextField.frame) + 7.f, JX_SCREEN_WIDTH, g_factory.cardBorderWithd)];
//    lineView.backgroundColor = g_factory.inputBorderColor;
//    [backView addSubview:lineView];
    
//    int h = 0;
//    WH_JXImageView* iv;
//    iv = [self WH_createMiXinButton:Localized(@"JXNewFriendVC_NewFirend") drawTop:NO drawBottom:YES icon:@"im_10001" click:@selector(newFriendAction:) superView:backView];
//    iv.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), JX_SCREEN_WIDTH, HEIGHT);
//    h = iv.frame.size.height + iv.frame.origin.y;
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.seekTextField.frame)+9.f, JX_SCREEN_WIDTH, 242.f)];
    [backView addSubview:_menuView];
    
//    int inset = 0;
    
//    int n = 0;
//    int m = 0;
//    int X = 0;
//    int Y = inset;
    
    /*UIButton *button;
    // 新的朋友
    button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JXNewFriendVC_NewFirend") icon:ThemeImageName(@"xinpengyou") action:@selector(newFriendAction:)];
    [_menuView addSubview:button];
    
    // 图片在button中的左右间隙
    int  leftInset = (button.frame.size.width - IMAGE_HEIGHT)/2;
    
    self.friendNewMsgNum = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.width-leftInset - 10, 20-5, 20, 20)];
    self.friendNewMsgNum.backgroundColor = [UIColor redColor];
    self.friendNewMsgNum.font = sysFontWithSize(12);
    self.friendNewMsgNum.textAlignment = NSTextAlignmentCenter;
    self.friendNewMsgNum.layer.cornerRadius = self.friendNewMsgNum.frame.size.width / 2;
    self.friendNewMsgNum.layer.masksToBounds = YES;
    self.friendNewMsgNum.textColor = [UIColor whiteColor];
    self.friendNewMsgNum.hidden = YES;
    self.friendNewMsgNum.text = @"99";
    [button addSubview:self.friendNewMsgNum];
    
//    iv = [self WH_createMiXinButton:Localized(@"JX_ManyPerChat") drawTop:NO drawBottom:YES icon:@"function_icon_join_group_apply" click:@selector(myGroupAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
    
    
    // 公众号
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_PublicNumber") icon:ThemeImageName(@"gongzhonghao") action:@selector(publicNumberAction:)];
    [_menuView addSubview:button];
    
    // 我的设备
    BOOL isMultipleLogin = [g_myself.multipleDevices intValue] > 0 ? YES : NO;
    if (isMultipleLogin) {
        n = (n + 1) >= 4 ? 0 : n + 1;
        m += 1;
        X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
        Y = m >=4 ? button.frame.size.height+inset : inset;
        button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_MyDevices") icon:ThemeImageName(@"wodeshebei") action:@selector(myDeviceAction:)];
        [_menuView addSubview:button];
    }
    
    // 标签
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_Label") icon:ThemeImageName(@"biaoqian") action:@selector(labelAction:)];
    [_menuView addSubview:button];
    
    // 我的同事
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"OrganizVC_Organiz") icon:ThemeImageName(@"wodetongshi") action:@selector(myColleaguesAction:)];
    [_menuView addSubview:button];
    
    // 群组
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_ManyPerChat") icon:ThemeImageName(@"qunzu") action:@selector(myGroupAction:)];
    [_menuView addSubview:button];
    
    // 手机联系人
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_MobilePhoneContacts") icon:ThemeImageName(@"shoujilianxiren") action:@selector(addressBookAction:)];
    [_menuView addSubview:button];
    
    self.abNewMsgNum = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.width-leftInset - 10, 20-5, 20, 20)];
    self.abNewMsgNum.backgroundColor = [UIColor redColor];
    self.abNewMsgNum.font = sysFontWithSize(12);
    self.abNewMsgNum.textAlignment = NSTextAlignmentCenter;
    self.abNewMsgNum.layer.cornerRadius = self.abNewMsgNum.frame.size.width / 2;
    self.abNewMsgNum.layer.masksToBounds = YES;
    self.abNewMsgNum.textColor = [UIColor whiteColor];
    self.abNewMsgNum.hidden = YES;
    self.abNewMsgNum.text = @"99";
    [button addSubview:self.abNewMsgNum];
    

    // 黑名单
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self WH_create_WHButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_BlackList") icon:ThemeImageName(@"heimingdan") action:@selector(blackFriendAction:)];
    [_menuView addSubview:button];

    */

    

//    iv = [self WH_createMiXinButton:Localized(@"JX_Label") drawTop:NO drawBottom:YES icon:@"label" click:@selector(labelAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
//
//    iv = [self WH_createMiXinButton:Localized(@"JX_PublicNumber") drawTop:NO drawBottom:YES icon:@"im_10000" click:@selector(publicNumberAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
    
//    BOOL isMultipleLogin = [[g_default objectForKey:kISMultipleLogin] boolValue];
//    BOOL isMultipleLogin = [g_myself.multipleDevices intValue] > 0 ? YES : NO;
//    if (isMultipleLogin) {
//        iv = [self WH_createMiXinButton:Localized(@"JX_MyDevices") drawTop:NO drawBottom:YES icon:@"feb" click:@selector(myDeviceAction:) superView:backView];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        h += iv.frame.size.height;
//    }
    
//    iv = [self WH_createMiXinButton:Localized(@"JX_BlackList") drawTop:NO drawBottom:YES icon:@"im_black" click:@selector(blackFriendAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
//
//    iv = [self WH_createMiXinButton:Localized(@"OrganizVC_Organiz") drawTop:NO drawBottom:YES icon:@"im_colleague" click:@selector(myColleaguesAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
//
//    iv = [self WH_createMiXinButton:Localized(@"JX_MobilePhoneContacts") drawTop:NO drawBottom:YES icon:@"sk_ic_pc" click:@selector(addressBookAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
    
//    self.abNewMsgNum = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 35, (HEIGHT - 15) / 2, 15, 15)];
//    self.abNewMsgNum.backgroundColor = [UIColor redColor];
//    self.abNewMsgNum.font = [UIFont systemFontOfSize:11.0];
//    self.abNewMsgNum.textAlignment = NSTextAlignmentCenter;
//    self.abNewMsgNum.layer.cornerRadius = self.abNewMsgNum.frame.size.width / 2;
//    self.abNewMsgNum.layer.masksToBounds = YES;
//    self.abNewMsgNum.textColor = [UIColor whiteColor];
//    self.abNewMsgNum.text = @"99";
//    [iv addSubview:self.abNewMsgNum];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
//        newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:FRIEND_CENTER_USERID];
//        [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
//
//    });
//    _btnHeight = button.frame.size.height;
    
//    NSArray *btnInfos = @[@{@"title":@"我的同事",@"image":@"WH_addressbook_new_friend"},
//                          @{@"title":@"我的设备",@"image":@"WH_addressbook_my_device"},
//                          @{@"title":@"黑名单",@"image":@"WH_addressbook_blacklist"},
//                          @{@"title":@"标签",@"image":@"WH_addressbook_label"}];
//
//    CGFloat btnEdgeInset = 28.f;
//    CGFloat btnW = 60.f;
//    CGFloat btnH = 42+8+20;
//    CGFloat btnY = 26.f;
//    CGFloat btnHInterval = (JX_SCREEN_WIDTH - btnEdgeInset*2 - btnInfos.count * btnW) / (btnInfos.count - 1);
//    UIButton *button = nil;
//    for (int i = 0; i < btnInfos.count; i++) {
//        button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_menuView addSubview:button];
//        button.frame = CGRectMake(btnEdgeInset+(btnW+btnHInterval)*i, btnY, btnW, btnH);
//        [button setImage:[UIImage imageNamed:btnInfos[i][@"image"]] forState:UIControlStateNormal];
//        [button setTitle:btnInfos[i][@"title"] forState:UIControlStateNormal];
//        [button setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
//        button.titleLabel.font = sysFontWithSize(14);
//        [button addTarget:self action:@selector(clickFuncButton:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = i+10;
//        [button layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextBottom imageTitleSpace:8.f];
//    }
    
    NSArray *buttonInfoArray = @[@{@"title":@"新的朋友",@"image":@"WH_addressbook_new_friend"},
                          @{@"title":@"群组",@"image":@"WH_addressbook_group"},
                          @{@"title":@"标签",@"image":@"WH_addressbook_label"},
                          @{@"title":@"我的同事",@"image":@"WH_addressbook_colleague"}];
    CGFloat buttonSpace = 7.5f;
    CGFloat buttonWidth = 48.f;
    CGFloat buttonHeight = 48;
    CGFloat buttonY = 9.f;
    CGFloat buttonLeft = 12;
    UIButton *button = nil;
    for (int i = 0; i < buttonInfoArray.count; i++) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuView addSubview:button];
        button.frame = CGRectMake(buttonLeft, buttonY + (buttonSpace + buttonHeight) * i, buttonWidth, buttonHeight);
        [button setImage:[UIImage imageNamed:buttonInfoArray[i][@"image"]] forState:UIControlStateNormal];
        [button layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextRight imageTitleSpace:5.f];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame) + 5, CGRectGetMinY(button.frame), 100, buttonHeight)];
        titleLabel.textColor = HEXCOLOR(0x222222);
        titleLabel.text = buttonInfoArray[i][@"title"];
        titleLabel.font = sysFontWithSize(14);
        [_menuView addSubview:titleLabel];
        
        if (i == 0) {
            UIButton *numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
            numberButton.frame = CGRectMake(JX_SCREEN_WIDTH - buttonLeft - 20, CGRectGetMinY(button.frame) + (buttonHeight - 20) / 2, 20, 20);
            numberButton.layer.cornerRadius = 10;
            numberButton.layer.masksToBounds = YES;
            numberButton.backgroundColor = HEXCOLOR(0xED6350);
            numberButton.titleLabel.font = sysFontWithSize(13);
            [numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [numberButton addTarget:self action:@selector(clickFuncButton:) forControlEvents:UIControlEventTouchUpInside];
            numberButton.hidden = YES;
            self.friendNewNumberButton = numberButton;
            [_menuView addSubview:numberButton];
        }
        
        UIButton *coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        coverButton.frame = CGRectMake(buttonLeft, CGRectGetMinY(button.frame), JX_SCREEN_WIDTH - buttonLeft * 2, buttonHeight);
        [coverButton addTarget:self action:@selector(clickFuncButton:) forControlEvents:UIControlEventTouchUpInside];
        coverButton.tag = i+10;
        [_menuView addSubview:coverButton];
        
    }
    
    [self showMenuView];
    if (_isMyGoIn) {
        [self hideMenuView];
    }
}
- (void)clickFuncButton:(UIButton *)button{
    if (button.tag == 10) {
        //新的朋友
        [self newFriendAction:nil];
    } else if (button.tag == 11){
        //群组
        [self myGroupAction:nil];
    } else if (button.tag == 12) {
        //标签
        [self labelAction:nil];
    } else if (button.tag == 13) {
        //我的同事
        [self myColleaguesAction:nil];
    } else {
        //黑名单
        [self blackFriendAction:nil];
    }
}


- (void)showMenuView { // 显示菜单栏
    _menuView.hidden = NO;
    CGRect backFrame = backView.frame;
    backFrame.size.height = 44+242;
    backView.frame = backFrame;
    
    CGRect menuFrame = _menuView.frame;
    menuFrame.size.height = 242.f;
    _menuView.frame = menuFrame;
    self.tableView.tableHeaderView = backView;
}

- (void)hideMenuView { // 隐藏菜单栏
    _menuView.hidden = YES;
    CGRect backFrame = backView.frame;
    backFrame.size.height = 44;
    backView.frame = backFrame;
    self.tableView.tableHeaderView = backView;
}

- (void)didMenuView:(WH_JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    
    
    NSString *method = MenuView.sels[index];
    SEL _selector = NSSelectorFromString(method);
    [self performSelectorOnMainThread:_selector withObject:nil waitUntilDone:YES];
    
//    NSArray *role = MY_USER_ROLE;
//    // 显示搜索好友
//    BOOL isShowSearch = [g_config.hideSearchByFriends boolValue] && (![g_config.isCommonFindFriends boolValue] || role.count > 0);
//    //显示创建房间
//    BOOL isShowRoom = [g_config.isCommonCreateGroup intValue] == 0 || role.count > 0;
//    //显示附近的人
//    BOOL isShowPosition = [g_config.isOpenPositionService intValue] == 0;
//    switch (index) {
//        case 0:
//            if (isShowRoom) {
//                [self onNewRoom];
//            }else {
//                if (isShowSearch) {
//                    [self onSearch];
//                }else {
//                    [self showScanViewController];
//                }
//            }
//            break;
//        case 1:
//            if (isShowRoom && isShowSearch) {
//                [self onSearch];
//            }else {
//                if ((isShowRoom && !isShowSearch) || (!isShowRoom && isShowSearch)) {
//                    [self showScanViewController];
//                }else if (!isShowRoom && !isShowSearch) {
//                    if (isShowPosition) {
//                        [self onNear];
//                    }else {
//                        [self searchPublicNumber];
//                    }
//                }
//            }
//            break;
//        case 2:
//            if (isShowSearch && isShowRoom) {
//                [self showScanViewController];
//            }else {
//                if ((isShowRoom && !isShowSearch) || (!isShowRoom && isShowSearch)) {
//                    if (isShowPosition) {
//                        [self onNear];
//                    }else {
//                        [self searchPublicNumber];
//                    }
//                }
//            }
//            break;
//        case 3:
//            if (isShowPosition) {
//                [self onNear];
//            }else {
//                [self searchPublicNumber];
//            }
//            break;
//        case 4:
//            [self searchPublicNumber];
//            break;
//        default:
//            break;
//    }
}

// 搜索公众号
- (void)searchPublicNumber {
    WH_JXSearchUser_WHVC *searchUserVC = [WH_JXSearchUser_WHVC alloc];
    searchUserVC.type = JXSearchTypePublicNumber;
    searchUserVC = [searchUserVC init];
    [g_navigation pushViewController:searchUserVC animated:YES];
}


- (void) moreListActionWithIndex:(NSInteger)index {
    
}

// 创建群组
-(void)onNewRoom{
    WH_JXNewRoom_WHVC* vc = [[WH_JXNewRoom_WHVC alloc]init];
    [g_navigation pushViewController:vc animated:YES];
}
// 附近的人
-(void)onNear{
    WH_JXNear_WHVC * nearVc = [[WH_JXNear_WHVC alloc] init];
    [g_navigation pushViewController:nearVc animated:YES];
}
// 扫一扫
-(void)showScanViewController{
//    button.enabled = NO;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        button.enabled = YES;
//    });
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
        return;
    }
    
    WH_JXScanQR_WHViewController * scanVC = [[WH_JXScanQR_WHViewController alloc] init];
    
    //    [g_window addSubview:scanVC.view];
    [g_navigation pushViewController:scanVC animated:YES];
}


// 新朋友
- (void)newFriendAction:(WH_JXImageView *)imageView {
    [self clearNewMsgCount];//清除角标
    WH_JXNewFriend_WHViewController* vc = [[WH_JXNewFriend_WHViewController alloc]init];
    [g_navigation pushViewController:vc animated:YES];
    
}

// 群组
- (void)myGroupAction:(WH_JXImageView *)imageView {
    WH_JXGroup_WHViewController *vc = [[WH_JXGroup_WHViewController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 我的同事
- (void)myColleaguesAction:(WH_JXImageView *)imageView {
//    WH_OrganizTree_WHViewController *vc = [[WH_OrganizTree_WHViewController alloc] init];
//    [g_navigation pushViewController:vc animated:YES];
    MiXin_CompanyListController *vc = [[MiXin_CompanyListController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 公众号
- (void)publicNumberAction:(WH_JXImageView *)imageView {
    WH_JXPublicNumber_WHVC *vc = [[WH_JXPublicNumber_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 黑名单
- (void)blackFriendAction:(WH_JXImageView *)imageView {
//    WH_JXBlackFriend_WHVC *vc = [[WH_JXBlackFriend_WHVC alloc] init];
//    vc.title = Localized(@"JX_BlackList");
//    [g_navigation pushViewController:vc animated:YES];
    
    WH_BlackList_WHController *vc = [[WH_BlackList_WHController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 我的设备
- (void)myDeviceAction:(WH_JXImageView *)imageView {
    WH_JXBlackFriend_WHVC *vc = [[WH_JXBlackFriend_WHVC alloc] init];
    vc.isDevice = YES;
    vc.title = Localized(@"JX_MyDevices");
    [g_navigation pushViewController:vc animated:YES];
}

// 标签
- (void)labelAction:(WH_JXImageView *)imageView {
    
    WH_JXLabel_WHVC *vc = [[WH_JXLabel_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 手机通讯录
- (void)addressBookAction:(WH_JXImageView *)imageView {
    
    WH_JXAddressBook_WHVC *vc = [[WH_JXAddressBook_WHVC alloc] init];
    NSMutableArray *arr = [[JXAddressBook sharedInstance] doFetchUnread];
    vc.abUreadArr = arr;
    [g_navigation pushViewController:vc animated:YES];
    [[JXAddressBook sharedInstance] updateUnread];
    
    WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
    newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:FRIEND_CENTER_USERID];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click superView:(UIView *)superView{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [superView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(42 + 14 + 14, 0, 200, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(16);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    //    p.delegate = self;
    //    p.didTouch = click;
    [btn addSubview:p];
    
    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(14, (HEIGHT-42)/2, 42, 42)];
        iv.image = [UIImage imageNamed:icon];
        
        [iv headRadiusWithAngle:iv.frame.size.width* 0.5];
        iv.layer.masksToBounds = YES;
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
    }
    
//    if(click){
//        UIImageView* iv;
//        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 16, 20, 20)];
//        iv.image = [UIImage imageNamed:@"set_list_next"];
//        [btn addSubview:iv];
//
//    }
    return btn;
}

- (void) textFieldDidChange:(UITextField *)textField {
    [super textFieldDidChange:textField];
    if (textField.text.length <= 0) {
        if (!self.isMyGoIn) {
            [self showMenuView];
        }
        [self getArrayData];
        [self.tableView reloadData];
        return;
    }else {
        [self hideMenuView];
    }
    
    [self.searchArray removeAllObjects];
    if (_selMenu == 0) {
        self.searchArray = [[WH_JXUserObject sharedUserInstance] WH_fetchFriendsFromLocalWhereLike:textField.text];
    }else if (_selMenu == 1){
        self.searchArray = [[WH_JXUserObject sharedUserInstance] WH_fetchBlackFromLocalWhereLike:textField.text];
    }
    
    [self.tableView reloadData];
}

-(void)onClick:(UIButton*)sender{
}

//筛选点击
- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
    [_topSiftView WH_resetAllParaBtn];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    if (offsetX == 0) {
        _selMenu = 0;
    }else {
        _selMenu = 1;
    }
    [self WH_scrollToPageUp];
}

- (void)getFriend{
    [g_server WH_listAttentionWithPage:0 userId:MY_USER_ID toView:self];
}

//-(void)actionSegment:(UISegmentedControl*)sender{
//    _selMenu = (int)sender.selectedSegmentIndex;
//    [self refresh];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _array=[[NSMutableArray alloc] init];
    [self refresh];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 离开时重置_isMyGoIn
    if (_isMyGoIn) {
        _isMyGoIn = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.seekTextField.text.length > 0) {
        return 1;
    }
    return [self.indexArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 31;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [UIView new];
    UILabel *titleLbl = [UILabel new];
    [header addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.centerY.offset(0);
    }];
    titleLbl.textColor = HEXCOLOR(0x8C9AB8);
    titleLbl.font = pingFangMediumFontWithSize(16);
    
    NSString *title = nil;
    if (self.seekTextField.text.length > 0) {
        title = Localized(@"JXFriend_searchTitle");
    } else {
        title = [self.indexArray objectAtIndex:section];
    }
    titleLbl.text = title;
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.seekTextField.text.length > 0) {
        return self.searchArray.count;
    }
    return [[self.letterResultArr objectAtIndex:section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.seekTextField.text.length > 0) {
        return nil;
    }
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXUserObject *user;
    if (self.seekTextField.text.length > 0) {
        user = self.searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
	WH_JX_WHCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        
        cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [_table WH_addToPool:cell];
        
//        cell.headImage   = user.userHead;
//        user = nil;
    }
    
//    cell.title = user.userNickname;
    cell.title = [self multipleLoginIsOnlineTitle:user];
//    cell.subtitle = user.userId;
    cell.index = (int)indexPath.row;
    cell.delegate = self;
    cell.didTouch = @selector(WH_on_WHHeadImage:);
//    cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
//    [cell setForTimeLabel:[TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"]];
    cell.timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 120-20, 9, 115, 20);
    cell.userId = user.userId;
    if (self.seekTextField.text.length){
        NSMutableAttributedString *lbAtt = [[NSMutableAttributedString alloc] initWithString:cell.title attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x3A404C),NSFontAttributeName:cell.lbTitle.font}];
        NSRange keyRange = [cell.title rangeOfString:self.seekTextField.text options:NSCaseInsensitiveSearch];
        [lbAtt setAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(0xED6350),NSFontAttributeName:cell.lbTitle.font} range:keyRange];
        [cell.lbTitle setText:nil];
        cell.lbTitle.attributedText = lbAtt;
    } else {
        cell.lbTitle.attributedText = nil;
        [cell.lbTitle setText:cell.title];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.dataObj = user;
//    cell.headImageView.tag = (int)indexPath.row;
//    cell.headImageView.delegate = cell.delegate;
//    cell.headImageView.didTouch = cell.didTouch;
    
    cell.isSmall = YES;
    [cell WH_headImageViewImageWithUserId:user.userId roomId:nil];
    [cell setLineDisplayOrHidden:indexPath];
    return cell;
}

- (NSString *)multipleLoginIsOnlineTitle:(WH_JXUserObject *)user {
    NSString *isOnline;
    if ([user.isOnLine intValue] == 1) {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OnLine")];
    }else {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OffLine")];
    }
    NSString *title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
//    if ([user.userId isEqualToString:ANDROID_USERID] || [user.userId isEqualToString:PC_USERID] || [user.userId isEqualToString:MAC_USERID]) {
//        title = [title stringByAppendingString:isOnline];
//    }
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    WH_JX_WHCell * cell = [_table cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    // 黑名单列表不能点击
    if (_selMenu == 1) {
        return;
    }
    
    WH_JXUserObject *user;
    if (self.seekTextField.text.length > 0) {
        user = self.searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    
    if([user.userId isEqualToString:FRIEND_CENTER_USERID]){
        WH_JXNewFriend_WHViewController* vc = [[WH_JXNewFriend_WHViewController alloc]init];
//        [g_App.window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
//        [vc release];
        return;
    }
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    if([user.roomFlag intValue] > 0  || user.roomId.length > 0){
        sendView.roomJid = user.userId;
        sendView.roomId = user.roomId;
        [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname isNew:NO];
    }
    sendView.title = user.remarkName.length > 0  ? user.remarkName : user.userNickname;
    sendView.chatPerson = user;
    sendView = [sendView init];
//    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
//    [sendView release];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.seekTextField.text.length <= 0){
        if (_selMenu == 0) {
            WH_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            if (user.userId.length <= 5) {
                return NO;
            }else{
                return YES;
            }
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (_selMenu == 0) {
//        return UITableViewCellEditingStyleDelete;
//    }else{
//        return UITableViewCellEditingStyleNone;
//    }
//}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selMenu == 0) {
        UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            WH_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            _currentUser = user;
            [g_server delFriend:user.userId toView:self];
        }];
        
        return @[deleteBtn];
    }
    else {
        UITableViewRowAction *cancelBlackBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"REMOVE") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            WH_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            _currentUser = user;
            [g_server WH_delBlacklistWithToUserId:user.userId toView:self];
        }];
        
        return @[cancelBlackBtn];
    }
   
}

//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (_selMenu == 0 && editingStyle == UITableViewCellEditingStyleDelete) {
//        WH_JXUserObject *user=_array[indexPath.row];
//        _currentUser = user;
//        [g_server delFriend:user.userId toView:self];
//    }
//}

- (void)dealloc {
    [g_notify removeObserver:self];
//    [_table release];
    [_array removeAllObjects];
//    [_array release];
//    [super dealloc];
}

-(void)getArrayData{
    switch (_selMenu) {
        case 0:{
            //获取好友列表
            
            //从数据库获取好友staus为2且不是room的
            _array=[[WH_JXUserObject sharedUserInstance] WH_fetchAllFriendsFromLocal];
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];

//            //根据Person对象的 name 属性 按中文 对 Person数组 排序
//            self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//            self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//
            self.wh_isShowFooterPull = NO;
        }
            break;
        case 1:{
            //获取黑名單列表
            
            //从数据库获取好友staus为-1的
            _array=[[WH_JXUserObject sharedUserInstance] WH_fetchAllBlackFromLocal];
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];
            //根据Person对象的 name 属性 按中文 对 Person数组 排序
//            self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//            self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
        }
            break;
        case 2:{
            _array=[[WH_JXUserObject sharedUserInstance] WH_fetchAllRoomsFromLocal];
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];
        }
//            //根据Person对象的 name 属性 按中文 对 Person数组 排序
//            self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//            self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
            break;
    }
}
//服务器返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    //更新本地好友
    if ([aDownload.action isEqualToString:wh_act_AttentionList]) {
        [_wait stop];
        [self WH_stopLoading];
        WH_JXProgress_WHVC * pv = [WH_JXProgress_WHVC alloc];
        // 服务端不会返回新朋友 ， 减去新朋友
        pv.dbFriends = (long)[_array count] - 1;
        pv.dataArray = array1;
        pv = [pv init];
//        [g_window addSubview:pv.view];
    }
    
    if ([aDownload.action isEqualToString:wh_act_FriendDel]) {
        [_currentUser doSendMsg:XMPP_TYPE_DELALL content:nil];
    }
    
    if([aDownload.action isEqualToString:wh_act_BlacklistDel]){
        [_currentUser doSendMsg:XMPP_TYPE_NOBLACK content:nil];
    }
    
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        [_wait stop];
        
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = user;
        vc.isAddFriend = user.isAddFirend;
        vc.wh_fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }
}



#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    [self WH_stopLoading];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [self WH_stopLoading];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

-(void)refresh{
    [self WH_stopLoading];
    _refreshCount++;
    [_array removeAllObjects];
//    [_array release];
    [self getArrayData];
    _friendArray = [g_myself WH_fetchAllFriendsOrNotFromLocal];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

//-(void)WH_scrollToPageUp{
//    [self refresh];
//}

-(void)newFriend:(NSObject*)sender{
    [self refresh];
}

-(void)WH_on_WHHeadImage:(id)dataObj{

    WH_JXUserObject *p = (WH_JXUserObject *)dataObj;
    if([p.userId isEqualToString:FRIEND_CENTER_USERID] || [p.userId isEqualToString:CALL_CENTER_USERID])
        return;
    
    _currentUser = p;
//    [g_server getUser:p.userId toView:self];
    
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = p.userId;
    vc.isAddFriend = p.isAddFirend;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];

    p = nil;
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
    [_wait stop];
    if([msg.type intValue] == XMPP_TYPE_DELALL){
        if([msg.toUserId isEqualToString:_currentUser.userId] || [msg.fromUserId isEqualToString:_currentUser.userId]){
            [_array removeObject:_currentUser];
            _currentUser = nil;
            [self getArrayData];
            [_table reloadData];
//            [g_App showAlert:Localized(@"JXAlert_DeleteFirend")];
        }
    }
    
    if([msg.type intValue] == XMPP_TYPE_BLACK){//拉黑
        for (WH_JXUserObject *obj in _array) {
            if ([obj.userId isEqualToString:_currentUser.userId]) {
                [_array removeObject:obj];
                break;
            }
        }
        
        [self getArrayData];
        [self.tableView reloadData];
    }
    
    if([msg.type intValue] == XMPP_TYPE_NOBLACK){
//        _currentUser.status = [NSNumber numberWithInt:friend_status_friend];
//        int status = [_currentUser.status intValue];
//        [_currentUser update];
        
        if (!_currentUser) {
            return;
        }
        [[JXXMPP sharedInstance].blackList removeObject:_currentUser.userId];
        [WH_JXMessageObject msgWithFriendStatus:_currentUser.userId status:friend_status_friend];
        for (WH_JXUserObject *obj in _array) {
            if ([obj.userId isEqualToString:_currentUser.userId]) {
                [_array removeObject:obj];
                break;
            }
        }
    
        [self getArrayData];
        [self.tableView reloadData];
//        [g_App showAlert:Localized(@"JXAlert_MoveBlackList")];
    }
    
    if([msg.type intValue] == XMPP_TYPE_PASS){//通过
        [self getFriend];
    }
}

- (void)friendRemarkNotif:(NSNotification *)notif {
    
    WH_JXUserObject *user = notif.object;
    for (int i = 0; i < _array.count; i ++) {
        WH_JXUserObject *user1 = _array[i];
        if ([user.userId isEqualToString:user1.userId]) {
            user1.userNickname = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
            user1.remarkName = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
            [_table reloadData];
            break;
        }
    }
}

- (UIButton *)WH_create_WHButtonWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)iconName  action:(SEL)action {
    UIButton *button = [[UIButton alloc] init];
    button.frame = frame;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.frame = CGRectMake((button.frame.size.width-IMAGE_HEIGHT)/2, 20, IMAGE_HEIGHT, IMAGE_HEIGHT);
//    [imgV headRadiusWithAngle:IMAGE_HEIGHT * 0.5];
//    imgV.layer.cornerRadius = IMAGE_HEIGHT * 40 / 104;
//    imgV.layer.masksToBounds = YES;
//    [imgV setBackgroundColor:[UIColor brownColor]];
    imgV.image = [UIImage imageNamed:iconName];
    [button addSubview:imgV];
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(14)} context:nil].size;
    UILabel *lab = [[UILabel alloc] init];
    lab.text = title;
    lab.font = sysFontWithSize(14);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = HEXCOLOR(0x323232);
    if (size.width >= button.frame.size.width) {
        size.width = button.frame.size.width-20;
    }
    lab.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame)+INSET_HEIGHT, size.width, size.height);
    CGPoint center = lab.center;
    center.x = imgV.center.x;
    lab.center = center;
    
    CGRect btnFrame = button.frame;
    btnFrame.size.height = CGRectGetMaxY(imgV.frame)+INSET_HEIGHT+size.height;
    button.frame = btnFrame;
    
    [button addSubview:lab];
    
    return button;
}

- (void)onMore:(UIButton *)btn {
    
}


- (void)sp_getUsersMostFollowerSuccess:(NSString *)mediaCount {
    NSLog(@"Check your Network");
}
@end
