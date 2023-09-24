//
//  MiXin_JXFriend_MiXinViewController.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "MiXin_JXFriend_MiXinViewController.h"
#import "MiXin_JXChat_MiXinViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "MiXin_JXImageView.h"
#import "MiXin_JX_MiXinCell.h"
#import "MiXin_JXRoomPool.h"
#import "JXTableView.h"
#import "MiXin_JXNewFriend_MiXinViewController.h"
#import "MiXin_menuImageView.h"
#import "FMDatabase.h"
#import "MiXin_JXProgress_MiXinVC.h"
#import "MiXin_JXTopSiftJobView.h"
#import "MiXin_JXUserInfo_MiXinVC.h"
#import "BMChineseSort.h"
#import "MiXin_JXGroup_MinXinViewController.h"
#import "MiXin_OrganizTree_MiXinViewController.h"
#import "MiXin_JXTabMenuView.h"
#import "MiXin_JXPublicNumber_MinXinVC.h"
#import "MiXin_JXBlackFriend_MinXinVC.h"
#import "MiXin_JX_DownListView.h"
#import "MiXin_JXNewRoom_MinXinVC.h"
#import "MiXin_JXNear_MiXinVC.h"
#import "MiXin_JXSearchUser_MiXinVC.h"
#import "MiXin_JXScanQR_MinXinViewController.h"
#import "MiXin_JXLabel_MinXinVC.h"
#import "MiXin_JXAddressBook_MiXinVC.h"
#import "WH_SegmentSwitch.h"
#import "UIButton+WH_Button.h"
#import "WH_BlackList_WHController.h"
#import "WH_Addressbook_WHController.h"
#import "MiXin_CompanyListController.h"

#define HEIGHT 60
#define IMAGE_HEIGHT  38  // 图片宽高
#define INSET_HEIGHT  10  // 图片文字间距


@interface MiXin_JXFriend_MiXinViewController ()<UITextFieldDelegate,JXSelectMenuViewDelegate>
@property (nonatomic, strong) MiXin_JXUserObject * currentUser;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;


@property (nonatomic, strong) UILabel *friendNewMsgNum;
@property (nonatomic, strong) UILabel *abNewMsgNum;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, assign) CGFloat btnHeight;  // 按钮的真实高度

@end

@implementation MiXin_JXFriend_MiXinViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isOneInit = YES;
        self.heightHeader = .0f;
        self.heightFooter = .0f;
        if (_isMyGoIn) {
            self.isGotoBack   = YES;
            self.heightFooter = 0;
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
//        self.title = Localized(@"MiXin_JXInput_MiXinVC_Friend");
        self.title = Localized(@"JX_MailList");
        [g_notify  addObserver:self selector:@selector(newFriend:) name:kXMPPNewFriendNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(newRequest:) name:kXMPPNewRequestNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceiptNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(MiXin_onSendTimeout:) name:kXMPPSendTimeOutNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(friendRemarkNotif:) name:kFriendRemark object:nil];
        
        [g_notify  addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(friendListRefresh:) name:kFriendListRefresh object:nil];
        [g_notify addObserver:self selector:@selector(refreshABNewMsgCount:) name:kRefreshAddressBookNotif object:nil];
        [g_notify addObserver:self selector:@selector(contactRegisterNotif:) name:kMsgComeContactRegister object:nil];
        [g_notify addObserver:self selector:@selector(newRequest:) name:kFriendPassNotif object:nil];
        
        self.isShowHeaderPull = NO;
        
        _table.backgroundColor = g_factory.globalBgColor;
        _table.sectionIndexColor = HEXCOLOR(0xAEAFB3);
    }
    return self;
}

- (void)friendListRefresh:(NSNotification *)notif {
    
    [self refresh];
}

- (void)contactRegisterNotif:(NSNotification *)notif {
    MiXin_JXMessageObject *msg = notif.object;
    
    NSDictionary *dict = (NSDictionary *)msg.content;
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
    MiXin_JXMsgAndUserObject* newobj = [[MiXin_JXMsgAndUserObject alloc]init];
    newobj.user = [[MiXin_JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    MiXin_JXMessageObject *msg = notifacation.object;
    if (![msg isAddFriendMsg]) {
        return;
    }
    
    NSString* s;
    s = [msg getTableName];
    MiXin_JXMsgAndUserObject* newobj = [[MiXin_JXMsgAndUserObject alloc]init];
    newobj.user = [[MiXin_JXUserObject sharedInstance] getUserById:s];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
    
}

- (void) showNewMsgCount:(NSInteger)friendNewMsgNum {
    if (friendNewMsgNum >= 10 && friendNewMsgNum <= 99) {
        self.friendNewMsgNum.font = SYSFONT(12);
    }else if (friendNewMsgNum > 0 && friendNewMsgNum < 10) {
        self.friendNewMsgNum.font = SYSFONT(13);
    }else if(friendNewMsgNum > 99){
        self.friendNewMsgNum.font = SYSFONT(9);
    }

    self.friendNewMsgNum.text = [NSString stringWithFormat:@"%ld",friendNewMsgNum];
    
    [g_mainVC.addressbookVC showNewMsgCount:friendNewMsgNum];
    
    if (friendNewMsgNum <= 0) {
        self.friendNewMsgNum.hidden = YES;
    }else{
        self.friendNewMsgNum.hidden = NO;
    }
    
    NSMutableArray *abUread = [[JXAddressBook sharedInstance] doFetchUnread];
    if (abUread.count >= 10 && abUread.count <= 99) {
        self.friendNewMsgNum.font = SYSFONT(12);
    }else if (abUread.count > 0 && abUread.count < 10) {
        self.friendNewMsgNum.font = SYSFONT(13);
    }else if(abUread.count > 99){
        self.friendNewMsgNum.font = SYSFONT(9);
    }

    self.abNewMsgNum.text = [NSString stringWithFormat:@"%ld",abUread.count];
    if (abUread.count <= 0) {
        self.abNewMsgNum.hidden = YES;
    }else {
        self.abNewMsgNum.hidden = NO;
    }
    
    NSInteger num = friendNewMsgNum + abUread.count;
    if (num <= 0) {
        [g_mainVC.tb setBadge:1 title:@"0"];
    }else {
        [g_mainVC.tb setBadge:1 title:[NSString stringWithFormat:@"%ld", num]];
    }
}

-(void)newRequest:(NSNotification *)notifacation
{
    [self getFriend];
}

- (void)MiXin_scrollToPageUp {
    [self getFriend];
}

-(void)buildTop{
    //刷新好友列表
//    UIButton * getFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-35, JX_SCREEN_TOP - 34, 30, 30)];
//    getFriendBtn.custom_acceptEventInterval = .25f;
//    [getFriendBtn addTarget:self action:@selector(getFriend) forControlEvents:UIControlEventTouchUpInside];
////    [getFriendBtn setImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
//    [getFriendBtn setBackgroundImage:[UIImage imageNamed:@"synchro_friends"] forState:UIControlStateNormal];
//    [self.tableHeader addSubview:getFriendBtn];
    
    WH_SegmentSwitch *addressSwitch = [[WH_SegmentSwitch alloc] initWithFrame:CGRectZero];
    [self.tableHeader addSubview:addressSwitch];
    [addressSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-8.f);
        make.width.offset(192.f);
        make.height.offset(28.f);
    }];
    __weak typeof(self) weakSelf = self;
    addressSwitch.onClickBtn = ^(NSInteger index) {
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
    [self.tableHeader addSubview:btn];

    self.moreBtn = [UIFactory MiXin_create_MiXinButtonWithImage:@"WH_addressbook_add"
                                          highlight:nil
                                             target:self
                                           selector:@selector(onMore:)];
    self.moreBtn.custom_acceptEventInterval = 1.0f;
    self.moreBtn.frame = CGRectMake(BTN_RANG_UP * 2, BTN_RANG_UP, NAV_BTN_SIZE, NAV_BTN_SIZE);
    [btn addSubview:self.moreBtn];
}

- (void)customView {
    //顶部筛选控件
//    _topSiftView = [[MiXin_JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 40)];
//    _topSiftView.delegate = self;
//    _topSiftView.isShowMoreParaBtn = NO;
//    _topSiftView.dataArray = [[NSArray alloc] initWithObjects:Localized(@"MiXin_JXInput_MiXinVC_FriendList"),Localized(@"JX_BlackList"), nil];
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
//    [cancelBtn addTarget:self action:@selector(MiXin_cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.titleLabel.font = SYSFONT(14.0);
//    [backView addSubview:cancelBtn];
    
    
//    self.seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(13, 12, backView.frame.size.width - 26, 30)];
//    self.seekTextField.placeholder = [NSString stringWithFormat:@"%@",Localized(@"JX_SearchFriends")];
//    self.seekTextField.textColor = HEXCOLOR(0x969696);
//    [self.seekTextField setFont:SYSFONT(17)];
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
    
    [self createSeekTextField:backView];
    
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.seekTextField.frame) + 7.f, JX_SCREEN_WIDTH, g_factory.cardBorderWithd)];
//    lineView.backgroundColor = g_factory.inputBorderColor;
//    [backView addSubview:lineView];
    
//    int h = 0;
//    MiXin_JXImageView* iv;
//    iv = [self MiXin_createMiXinButton:Localized(@"JXNewFriendVC_NewFirend") drawTop:NO drawBottom:YES icon:@"im_10001" click:@selector(newFriendAction:) superView:backView];
//    iv.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), JX_SCREEN_WIDTH, HEIGHT);
//    h = iv.frame.size.height + iv.frame.origin.y;
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.seekTextField.frame)+7.f, JX_SCREEN_WIDTH, 121.f)];
    [backView addSubview:_menuView];
    
//    int inset = 0;
    
//    int n = 0;
//    int m = 0;
//    int X = 0;
//    int Y = inset;
    
    /*UIButton *button;
    // 新的朋友
    button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JXNewFriendVC_NewFirend") icon:ThemeImageName(@"xinpengyou") action:@selector(newFriendAction:)];
    [_menuView addSubview:button];
    
    // 图片在button中的左右间隙
    int  leftInset = (button.frame.size.width - IMAGE_HEIGHT)/2;
    
    self.friendNewMsgNum = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.width-leftInset - 10, 20-5, 20, 20)];
    self.friendNewMsgNum.backgroundColor = [UIColor redColor];
    self.friendNewMsgNum.font = SYSFONT(12);
    self.friendNewMsgNum.textAlignment = NSTextAlignmentCenter;
    self.friendNewMsgNum.layer.cornerRadius = self.friendNewMsgNum.frame.size.width / 2;
    self.friendNewMsgNum.layer.masksToBounds = YES;
    self.friendNewMsgNum.textColor = [UIColor whiteColor];
    self.friendNewMsgNum.hidden = YES;
    self.friendNewMsgNum.text = @"99";
    [button addSubview:self.friendNewMsgNum];
    
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_ManyPerChat") drawTop:NO drawBottom:YES icon:@"function_icon_join_group_apply" click:@selector(myGroupAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
    
    
    // 公众号
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_PublicNumber") icon:ThemeImageName(@"gongzhonghao") action:@selector(publicNumberAction:)];
    [_menuView addSubview:button];
    
    // 我的设备
    BOOL isMultipleLogin = [g_myself.multipleDevices intValue] > 0 ? YES : NO;
    if (isMultipleLogin) {
        n = (n + 1) >= 4 ? 0 : n + 1;
        m += 1;
        X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
        Y = m >=4 ? button.frame.size.height+inset : inset;
        button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_MyDevices") icon:ThemeImageName(@"wodeshebei") action:@selector(myDeviceAction:)];
        [_menuView addSubview:button];
    }
    
    // 标签
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_Label") icon:ThemeImageName(@"biaoqian") action:@selector(labelAction:)];
    [_menuView addSubview:button];
    
    // 我的同事
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"OrganizVC_Organiz") icon:ThemeImageName(@"wodetongshi") action:@selector(myColleaguesAction:)];
    [_menuView addSubview:button];
    
    // 群组
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_ManyPerChat") icon:ThemeImageName(@"qunzu") action:@selector(myGroupAction:)];
    [_menuView addSubview:button];
    
    // 手机联系人
    n = (n + 1) >= 4 ? 0 : n + 1;
    m += 1;
    X = JX_SCREEN_WIDTH/4 * (n >= 4 ? 0 : n);
    Y = m >=4 ? button.frame.size.height+inset : inset;
    button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_MobilePhoneContacts") icon:ThemeImageName(@"shoujilianxiren") action:@selector(addressBookAction:)];
    [_menuView addSubview:button];
    
    self.abNewMsgNum = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.width-leftInset - 10, 20-5, 20, 20)];
    self.abNewMsgNum.backgroundColor = [UIColor redColor];
    self.abNewMsgNum.font = SYSFONT(12);
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
    button = [self MiXin_create_MiXinButtonWithFrame:CGRectMake(X, Y, JX_SCREEN_WIDTH/4, 0) title:Localized(@"JX_BlackList") icon:ThemeImageName(@"heimingdan") action:@selector(blackFriendAction:)];
    [_menuView addSubview:button];

    */

    

//    iv = [self MiXin_createMiXinButton:Localized(@"JX_Label") drawTop:NO drawBottom:YES icon:@"label" click:@selector(labelAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
//
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_PublicNumber") drawTop:NO drawBottom:YES icon:@"im_10000" click:@selector(publicNumberAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
    
//    BOOL isMultipleLogin = [[g_default objectForKey:kISMultipleLogin] boolValue];
//    BOOL isMultipleLogin = [g_myself.multipleDevices intValue] > 0 ? YES : NO;
//    if (isMultipleLogin) {
//        iv = [self MiXin_createMiXinButton:Localized(@"JX_MyDevices") drawTop:NO drawBottom:YES icon:@"feb" click:@selector(myDeviceAction:) superView:backView];
//        iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//        h += iv.frame.size.height;
//    }
    
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_BlackList") drawTop:NO drawBottom:YES icon:@"im_black" click:@selector(blackFriendAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
//
//    iv = [self MiXin_createMiXinButton:Localized(@"OrganizVC_Organiz") drawTop:NO drawBottom:YES icon:@"im_colleague" click:@selector(myColleaguesAction:) superView:backView];
//    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
//    h += iv.frame.size.height;
//
//    iv = [self MiXin_createMiXinButton:Localized(@"JX_MobilePhoneContacts") drawTop:NO drawBottom:YES icon:@"sk_ic_pc" click:@selector(addressBookAction:) superView:backView];
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
//        MiXin_JXMsgAndUserObject* newobj = [[MiXin_JXMsgAndUserObject alloc]init];
//        newobj.user = [[MiXin_JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
//        [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
//
//    });
//    _btnHeight = button.frame.size.height;
    
    NSArray *btnInfos = @[@{@"title":@"我的同事",@"image":@"WH_addressbook_new_friend"},
                          @{@"title":@"我的设备",@"image":@"WH_addressbook_my_device"},
                          @{@"title":@"黑名单",@"image":@"WH_addressbook_blacklist"},
                          @{@"title":@"标签",@"image":@"WH_addressbook_label"}];
    
    CGFloat btnEdgeInset = 28.f;
    CGFloat btnW = 60.f;
    CGFloat btnH = 42+8+20;
    CGFloat btnY = 26.f;
    CGFloat btnHInterval = (JX_SCREEN_WIDTH - btnEdgeInset*2 - btnInfos.count * btnW) / (btnInfos.count - 1);
    UIButton *button = nil;
    for (int i = 0; i < btnInfos.count; i++) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuView addSubview:button];
        button.frame = CGRectMake(btnEdgeInset+(btnW+btnHInterval)*i, btnY, btnW, btnH);
        [button setImage:[UIImage imageNamed:btnInfos[i][@"image"]] forState:UIControlStateNormal];
        [button setTitle:btnInfos[i][@"title"] forState:UIControlStateNormal];
        [button setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
        button.titleLabel.font = g_factory.font14;
        [button addTarget:self action:@selector(clickFuncButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i+10;
        [button layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextBottom imageTitleSpace:8.f];
    }
    
    [self showMenuView];
    if (_isMyGoIn) {
        [self hideMenuView];
    }
}
- (void)clickFuncButton:(UIButton *)button{
    if (button.tag == 10) {
        //我的同事
        [self myColleaguesAction:nil];
    } else if (button.tag == 11){
        //我的设备
        [self myDeviceAction:nil];
    } else if (button.tag == 12) {
        //黑名单
        [self blackFriendAction:nil];
    } else {
        //标签
        [self labelAction:nil];
    }
}


- (void)showMenuView { // 显示菜单栏
    _menuView.hidden = NO;
    CGRect backFrame = backView.frame;
    backFrame.size.height = 44+121;
    backView.frame = backFrame;
    
    CGRect menuFrame = _menuView.frame;
    menuFrame.size.height = 121.f;
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

- (void)didMenuView:(MiXin_JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    
    
    NSString *method = MenuView.sels[index];
    SEL _selector = NSSelectorFromString(method);
    [self performSelectorOnMainThread:_selector withObject:nil waitUntilDone:YES];
    
//    NSArray *role = MY_USER_ROLE;
//    // 显示搜索好友
//    BOOL isShowSearch = [g_App.config.hideSearchByFriends boolValue] && (![g_App.config.isCommonFindFriends boolValue] || role.count > 0);
//    //显示创建房间
//    BOOL isShowRoom = [g_App.config.isCommonCreateGroup intValue] == 0 || role.count > 0;
//    //显示附近的人
//    BOOL isShowPosition = [g_App.config.isOpenPositionService intValue] == 0;
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
    MiXin_JXSearchUser_MiXinVC *searchUserVC = [MiXin_JXSearchUser_MiXinVC alloc];
    searchUserVC.type = JXSearchTypePublicNumber;
    searchUserVC = [searchUserVC init];
    [g_navigation pushViewController:searchUserVC animated:YES];
}


- (void) moreListActionWithIndex:(NSInteger)index {
    
}

// 创建群组
-(void)onNewRoom{
    MiXin_JXNewRoom_MinXinVC* vc = [[MiXin_JXNewRoom_MinXinVC alloc]init];
    [g_navigation pushViewController:vc animated:YES];
}
// 附近的人
-(void)onNear{
    MiXin_JXNear_MiXinVC * nearVc = [[MiXin_JXNear_MiXinVC alloc] init];
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
    
    MiXin_JXScanQR_MinXinViewController * scanVC = [[MiXin_JXScanQR_MinXinViewController alloc] init];
    
    //    [g_window addSubview:scanVC.view];
    [g_navigation pushViewController:scanVC animated:YES];
}


// 新朋友
- (void)newFriendAction:(MiXin_JXImageView *)imageView {
    MiXin_JXNewFriend_MiXinViewController* vc = [[MiXin_JXNewFriend_MiXinViewController alloc]init];
    [g_navigation pushViewController:vc animated:YES];
    
}

// 群组
- (void)myGroupAction:(MiXin_JXImageView *)imageView {
    MiXin_JXGroup_MinXinViewController *vc = [[MiXin_JXGroup_MinXinViewController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 我的同事
- (void)myColleaguesAction:(MiXin_JXImageView *)imageView {
    MiXin_CompanyListController *vc = [[MiXin_CompanyListController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 公众号
- (void)publicNumberAction:(MiXin_JXImageView *)imageView {
    MiXin_JXPublicNumber_MinXinVC *vc = [[MiXin_JXPublicNumber_MinXinVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 黑名单
- (void)blackFriendAction:(MiXin_JXImageView *)imageView {
//    MiXin_JXBlackFriend_MinXinVC *vc = [[MiXin_JXBlackFriend_MinXinVC alloc] init];
//    vc.title = Localized(@"JX_BlackList");
//    [g_navigation pushViewController:vc animated:YES];
//    MiXin_OrganizTree_MiXinViewController *vc = [[MiXin_OrganizTree_MiXinViewController alloc] init];
    WH_BlackList_WHController *vc = [[WH_BlackList_WHController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 我的设备
- (void)myDeviceAction:(MiXin_JXImageView *)imageView {
    MiXin_JXBlackFriend_MinXinVC *vc = [[MiXin_JXBlackFriend_MinXinVC alloc] init];
    vc.isDevice = YES;
    vc.title = Localized(@"JX_MyDevices");
    [g_navigation pushViewController:vc animated:YES];
}

// 标签
- (void)labelAction:(MiXin_JXImageView *)imageView {
    
    MiXin_JXLabel_MinXinVC *vc = [[MiXin_JXLabel_MinXinVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 手机通讯录
- (void)addressBookAction:(MiXin_JXImageView *)imageView {
    
    MiXin_JXAddressBook_MiXinVC *vc = [[MiXin_JXAddressBook_MiXinVC alloc] init];
    NSMutableArray *arr = [[JXAddressBook sharedInstance] doFetchUnread];
    vc.abUreadArr = arr;
    [g_navigation pushViewController:vc animated:YES];
    [[JXAddressBook sharedInstance] updateUnread];
    
    MiXin_JXMsgAndUserObject* newobj = [[MiXin_JXMsgAndUserObject alloc]init];
    newobj.user = [[MiXin_JXUserObject sharedInstance] getUserById:FRIEND_CENTER_USERID];
    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
}

-(MiXin_JXImageView*)MiXin_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon click:(SEL)click superView:(UIView *)superView{
    MiXin_JXImageView* btn = [[MiXin_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    [superView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(42 + 14 + 14, 0, 200, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
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
        self.searchArray = [[MiXin_JXUserObject sharedInstance] MiXin_fetchFriendsFromLocalWhereLike:textField.text];
    }else if (_selMenu == 1){
        self.searchArray = [[MiXin_JXUserObject sharedInstance] MiXin_fetchBlackFromLocalWhereLike:textField.text];
    }
    
    [self.tableView reloadData];
}

-(void)onClick:(UIButton*)sender{
}

//筛选点击
- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
    [_topSiftView resetAllParaBtn];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    if (offsetX == 0) {
        _selMenu = 0;
    }else {
        _selMenu = 1;
    }
    [self MiXin_scrollToPageUp];
}

- (void)getFriend{
    [g_server listAttention:0 userId:MY_USER_ID toView:self];
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
    titleLbl.font = g_factory.font16m;
    
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
    MiXin_JXUserObject *user;
    if (self.seekTextField.text.length > 0) {
        user = self.searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
	MiXin_JX_MiXinCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        
        cell = [[MiXin_JX_MiXinCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [_table addToPool:cell];
        
//        cell.headImage   = user.userHead;
//        user = nil;
    }
    
//    cell.title = user.userNickname;
    cell.title = [self multipleLoginIsOnlineTitle:user];
//    cell.subtitle = user.userId;
    cell.index = (int)indexPath.row;
    cell.delegate = self;
    cell.didTouch = @selector(MiXin_on_MiXinHeadImage:);
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
    [cell MiXin_headImageViewImageWithUserId:user.userId roomId:nil];
    [cell setLineDisplayOrHidden:indexPath];
    return cell;
}

- (NSString *)multipleLoginIsOnlineTitle:(MiXin_JXUserObject *)user {
    NSString *isOnline;
    if ([user.isOnLine intValue] == 1) {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OnLine")];
    }else {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OffLine")];
    }
    NSString *title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
    if ([user.userId isEqualToString:ANDROID_USERID] || [user.userId isEqualToString:PC_USERID] || [user.userId isEqualToString:MAC_USERID]) {
        title = [title stringByAppendingString:isOnline];
    }
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    MiXin_JX_MiXinCell * cell = [_table cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    // 黑名单列表不能点击
    if (_selMenu == 1) {
        return;
    }
    
    MiXin_JXUserObject *user;
    if (self.seekTextField.text.length > 0) {
        user = self.searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    
    if([user.userId isEqualToString:FRIEND_CENTER_USERID]){
        MiXin_JXNewFriend_MiXinViewController* vc = [[MiXin_JXNewFriend_MiXinViewController alloc]init];
//        [g_App.window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
//        [vc release];
        return;
    }
    
    MiXin_JXChat_MiXinViewController *sendView=[MiXin_JXChat_MiXinViewController alloc];
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
            MiXin_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
            MiXin_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            _currentUser = user;
            [g_server delFriend:user.userId toView:self];
        }];
        
        return @[deleteBtn];
    }
    else {
        UITableViewRowAction *cancelBlackBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"REMOVE") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            MiXin_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            _currentUser = user;
            [g_server delBlacklist:user.userId toView:self];
        }];
        
        return @[cancelBlackBtn];
    }
   
}

//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (_selMenu == 0 && editingStyle == UITableViewCellEditingStyleDelete) {
//        MiXin_JXUserObject *user=_array[indexPath.row];
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
//            if (self.isOneInit) {//是否新建
//                [g_server listAttention:0 userId:MY_USER_ID toView:self];
//                self.isOneInit = NO;
//            }
            
            //从数据库获取好友staus为2且不是room的
            _array=[[MiXin_JXUserObject sharedInstance] MiXin_fetchAllFriendsFromLocal];
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
            self.isShowFooterPull = NO;
        }
            break;
        case 1:{
            //获取黑名單列表
            
            //从数据库获取好友staus为-1的
            _array=[[MiXin_JXUserObject sharedInstance] MiXin_fetchAllBlackFromLocal];
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
            _array=[[MiXin_JXUserObject sharedInstance] MiXin_fetchAllRoomsFromLocal];
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
-(void) MiXin_didServerResult_MiXinSucces:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    //更新本地好友
    if ([aDownload.action isEqualToString:act_AttentionList]) {
        [_wait stop];
        [self stopLoading];
        MiXin_JXProgress_MiXinVC * pv = [MiXin_JXProgress_MiXinVC alloc];
        // 服务端不会返回新朋友 ， 减去新朋友
        pv.dbFriends = (long)[_array count] - 1;
        pv.dataArray = array1;
        pv = [pv init];
//        [g_window addSubview:pv.view];
    }
    
    if ([aDownload.action isEqualToString:act_FriendDel]) {
        [_currentUser doSendMsg:XMPP_TYPE_DELALL content:nil];
    }
    
    if([aDownload.action isEqualToString:act_BlacklistDel]){
        [_currentUser doSendMsg:XMPP_TYPE_NOBLACK content:nil];
    }
    
    if( [aDownload.action isEqualToString:act_UserGet] ){
        [_wait stop];
        
        MiXin_JXUserObject* user = [[MiXin_JXUserObject alloc]init];
        [user MiXin_getDataFromDict:dict];
        
        MiXin_JXUserInfo_MiXinVC* vc = [MiXin_JXUserInfo_MiXinVC alloc];
        vc.user       = user;
        vc.fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }
}



#pragma mark - 请求失败回调
-(int) MiXin_didServerResult_MinXinFailed:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    [self stopLoading];
    return show_error;
}

#pragma mark - 请求出错回调
-(int) MiXin_didServerConnect_MiXinError:(MiXin_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [self stopLoading];
    return show_error;
}

#pragma mark - 开始请求服务器回调
-(void) MiXin_didServerConnect_MiXinStart:(MiXin_JXConnection*)aDownload{
    [_wait start];
}

-(void)refresh{
    [self stopLoading];
    _refreshCount++;
    [_array removeAllObjects];
//    [_array release];
    [self getArrayData];
    _friendArray = [g_server.myself MiXin_fetchAllFriendsOrNotFromLocal];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

//-(void)MiXin_scrollToPageUp{
//    [self refresh];
//}

-(void)newFriend:(NSObject*)sender{
    [self refresh];
}

-(void)MiXin_on_MiXinHeadImage:(id)dataObj{

    MiXin_JXUserObject *p = (MiXin_JXUserObject *)dataObj;
    if([p.userId isEqualToString:FRIEND_CENTER_USERID] || [p.userId isEqualToString:CALL_CENTER_USERID])
        return;
    
    _currentUser = p;
//    [g_server getUser:p.userId toView:self];
    
    MiXin_JXUserInfo_MiXinVC* vc = [MiXin_JXUserInfo_MiXinVC alloc];
    vc.userId       = p.userId;
    vc.fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];

    p = nil;
}

-(void)MiXin_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    //    NSLog(@"onSendTimeout");
    [_wait stop];
//    [g_App showAlert:Localized(@"JXAlert_SendFilad")];
    [JXMyTools showTipView:Localized(@"JXAlert_SendFilad")];
}

-(void)newReceipt:(NSNotification *)notifacation{//新回执
    //    NSLog(@"newReceipt");
    MiXin_JXMessageObject *msg     = (MiXin_JXMessageObject *)notifacation.object;
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
        for (MiXin_JXUserObject *obj in _array) {
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
        [MiXin_JXMessageObject msgWithFriendStatus:_currentUser.userId status:friend_status_friend];
        for (MiXin_JXUserObject *obj in _array) {
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
    
    MiXin_JXUserObject *user = notif.object;
    for (int i = 0; i < _array.count; i ++) {
        MiXin_JXUserObject *user1 = _array[i];
        if ([user.userId isEqualToString:user1.userId]) {
            user1.userNickname = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
            user1.remarkName = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
            [_table reloadData];
            break;
        }
    }
}

- (UIButton *)MiXin_create_MiXinButtonWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)iconName  action:(SEL)action {
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
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(14)} context:nil].size;
    UILabel *lab = [[UILabel alloc] init];
    lab.text = title;
    lab.font = SYSFONT(14);
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


@end
