//  WH_JXMsg_WHViewController.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXMsg_WHViewController.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "WH_JX_WH2Cell.h"
#import "WH_JXRoomPool.h"
#import "WH_JXRoomObject.h"
#import "JXTableView.h"
#import "WH_JXFriendObject.h"
#import "WH_inputPhone_WHVC.h"
#import "WH_InputPwdViewController.h"
#import "WH_WeiboViewControlle.h"
#import "addMsgVC.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXRoomObject.h"
#import "WH_JXRoomRemind.h"
#import "FMDatabase.h"
#import "WH_JXGroup_WHViewController.h"
#import "WH_JXSearchUser_WHVC.h"
#import "WH_JXNear_WHVC.h"
#import "WH_JXRoomMember_WHVC.h"
#import "WH_JXMain_WHViewController.h"
#import "WH_JXTabMenuView.h"
#import "WH_JXScanQR_WHViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WH_JX_DownListView.h"
#import "WH_JXNewRoom_WHVC.h"
#import "JXSynTask.h"
#ifdef Live_Version
#import "WH_JXLiveJid_WHManager.h"
#endif
#import "WH_JXPay_WHViewController.h"
#import "WH_JXTransferNotice_WHVC.h"
#import "WH_JXFaceCreateRoom_WHVC.h"

#import "WH_AddFriend_WHController.h"

#import "WH_TopPrompt_WHView.h"
#import "WH_NoInternet_WHController.h"

#import "WH_JXCollectMoney_WHVC.h"

#import "WH_JXInput_WHVC.h"
#import "WH_AuthViewController.h"
#import "WH_AppVersionUpdate.h"

#import "WH_JXSelectFriends_WHVC.h"
#import "WH_ContentModification_WHView.h"
#import "UIView+CustomAlertView.h"

#define baseViewHeight 167

@interface WH_JXMsg_WHViewController ()<UIAlertViewDelegate, UITextFieldDelegate,JXSelectMenuViewDelegate,UITextViewDelegate,WH_JXScanQR_WHViewControllerDelegate>
{
    NSDictionary * _dataDict;
}
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, assign) BOOL dalayAction;
@property (nonatomic, assign) int topNum;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) WH_JXRoomRemind *roomRemind;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, strong) NSMutableArray *taskArray;

@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *replayTitle;
@property (nonatomic, strong) UITextView *replayTextView;
@property (nonatomic, strong) WH_TopPrompt_WHView *topPrompV;
@property (nonatomic, assign) int replayNum;
@property (nonatomic, strong) WH_JXMessageObject *repalyMsg;
@property (nonatomic, strong) NSString *lastMsgInput;
@property (nonatomic, strong) NSString *replayRoomId;

@property (nonatomic, assign) BOOL isWeChatJoinGroup;

// 扫描到群组参数
@property (nonatomic, copy) NSString *roomJid;
@property (nonatomic, copy) NSString *roomUserId;
@property (nonatomic, copy) NSString *roomUserName;

@end

@implementation WH_JXMsg_WHViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = JX_SCREEN_BOTTOM;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM);
        [self WH_createHeadAndFoot];
        [self onLoginChanged:nil];

        _searchArray = [NSMutableArray array];
        _taskArray = [NSMutableArray array];
        
        [self customView];
        [self WH_setupReplayView];
        [g_notify  addObserver:self selector:@selector(allMsgCome) name:kXMPPAllMsg_WHNotifaction object:nil];//收到了所有消息,一次性刷新
        [g_notify  addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsg_WHNotifaction object:nil];//收到了一条新消息
        [g_notify  addObserver:self selector:@selector(newMsgSend:) name:kXMPPMyLastSend_WHNotifaction object:nil];//发送了一条消息
        [g_notify addObserver:self selector:@selector(newRequest:) name:kXMPPNewRequest_WHNotifaction object:nil];//收到了一个好友验证类消息
        [g_notify addObserver:self selector:@selector(onLoginChanged:) name:kXmppLogin_WHNotifaction object:nil];//登录状态变化了
        [g_notify addObserver:self selector:@selector(delFriend:) name:kDeleteUser_WHNotifaction object:nil];//删除了一个好友
        [g_notify addObserver:self selector:@selector(onReceiveRoomRemind:) name:kXMPPRoom_WHNotifaction object:nil];//收到了群控制消息
        [g_notify addObserver:self selector:@selector(onQuitRoom:) name:kQuitRoom_WHNotifaction object:nil];//退出了房间
        // 清除全部聊天记录
        [g_notify addObserver:self selector:@selector(delAllChatLogNotifi:) name:kDeleteAllChatLog_WHNotification object:nil];
        [g_notify addObserver:self selector:@selector(chatViewDisappear:) name:kChatViewDisappear_WHNotification object:nil];
        [g_notify addObserver:self selector:@selector(logoutNotifi:) name:kSystemLogout_WHNotifaction object:nil];
        // 撤回消息
        [g_notify addObserver:self selector:@selector(withdrawNotifi:) name:kXMPPMessageWithdraw_WHNotification object:nil];
        // 更改备注名
        [g_notify addObserver:self selector:@selector(friendRemarkNotif:) name:kFriendRemark object:nil];
        // 进入前台
        [g_notify addObserver:self selector:@selector(appEnterForegroundNotif:) name:kApplicationWillEnterForeground object:nil];
        [g_notify addObserver:self selector:@selector(friendPassNotif:) name:kFriendPassNotif object:nil];
        
        [g_notify addObserver:self selector:@selector(updateRoomHead:) name:@"updateRoomHead" object:nil];

        [g_notify addObserver:self selector:@selector(clearRoomChatRecord:) name:kClearRoomChatRecord object:nil];
        [g_notify addObserver:self selector:@selector(getLastChatList) name:kJinQianTaiTongBuQuanZuComplete_WHNotifaction object:nil];
//        [g_notify addObserver:self selector:@selector(WH_getServerData) name:kReadDelRefreshNotif object:nil
        
        [g_notify addObserver:self selector:@selector(clearData:) name:@"kReadDelRefreshNotif" object:nil];

        
        upOrDown = 0;
        
        //显示下拉刷新
        self.wh_isShowHeaderPull = NO;
    }
    return self;
}

- (void)clearData:(NSNotification *)notification{
    self.isTwoWithdrawal = YES;
    self.rJid = notification.object;
    
    [g_server WH_getLastChatListWithStartTime:0 toView:self];
}

- (void)clearRoomChatRecord:(NSNotification *)notify{
    NSString *userId = notify.object;
    for(NSInteger i=[_wh_array count]-1;i>=0;i--){
        WH_JXMsgAndUserObject *p=[_wh_array objectAtIndex:i];
        if([p.user.userId isEqualToString:userId]){
            [_wh_array removeObjectAtIndex:i];
            break;
        }
    }
    
    _refreshCount++;
    [_table reloadData];
    [self getTotalNewMsgCount];
}

- (void)updateRoomHead:(NSNotification *)notification {
//    NSDictionary *groupDict = notification.object;
//    
//    NSMutableArray *array;
//    if (_seekTextField.text.length > 0) {
//        array = _searchArray;
//    }else {
//        array = _array;
//    }
//    NSString *roomjid = [NSString stringWithFormat:@"%@",[groupDict objectForKey:@"roomJid"]];
//    NSInteger index = 0;
//    for (WH_JXMsgAndUserObject * dict in array) {
//        if ([dict.user.userId intValue] == [roomjid intValue]) {
//            index = [array indexOfObject:dict];
//        }
//    }
//    WH_JX_WH2Cell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//    cell.headImageView.image = [UIImage imageNamed:@"icon_wahu_transfer"];
//
//    [self.tableView reloadData];
}


-(void)dealloc{
    [g_notify removeObserver:self];
    [_wh_array removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isTwoWithdrawal = NO;

    [self WH_getServerData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //版本更新检查
        [[WH_AppVersionUpdate shared] checkVersion];
    });
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getTotalNewMsgCount];
    BOOL updateUser = [g_default boolForKey:@"PasswordHasModifyed"];
    if (updateUser) {
        [self updateUserInfoSentToServer];
        [g_default setBool:NO forKey:@"PasswordHasModifyed"];
        [g_default synchronize];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"beAuth"]) {
        WH_AuthViewController *vc = [[WH_AuthViewController alloc]init];
        [g_navigation pushViewController:vc animated:YES];
    }
}

#pragma mark 快捷回复
- (void)WH_setupReplayView {
    int height = 60;

    if (self.bigView) {
        [self.bigView removeFromSuperview];
    }
    
    self.bigView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.bigView.hidden = YES;
    [g_App.window addSubview:self.bigView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.bigView addGestureRecognizer:tap];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(20, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-40, baseViewHeight)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self.baseView.layer.cornerRadius = 15.f;
    [self.bigView addSubview:self.baseView];
    int n = 15;
    _replayTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.baseView.frame.size.width - 12*2, 54)];
    _replayTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _replayTitle.textColor = HEXCOLOR(0x8C9AB8);
    _replayTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 18];
    [self.baseView addSubview:_replayTitle];
    
    n += height;
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 54, self.baseView.frame.size.width, g_factory.cardBorderWithd)];
    [lView setBackgroundColor:g_factory.cardBorderColor];
    [self.baseView addSubview:lView];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.baseView.frame) - 72 - g_factory.cardBorderWithd, self.baseView.frame.size.width, 72)];
    [self.baseView addSubview:self.topView];
    
    self.replayTextView = [self WH_createMiXinTextField:self.baseView default:nil hint:nil];
//    self.replayTextView.frame = CGRectMake(10, CGRectGetMaxY(lView.frame) + 20, self.baseView.frame.size.width - 20, 60);
    [self.replayTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.baseView).offset(10);
        make.right.equalTo(self.baseView.mas_right).offset(-10);
        make.top.equalTo(lView).offset(20);
        make.bottom.equalTo(self.topView.mas_top).offset(-20);
    }];
    self.replayTextView.delegate = self;
    self.replayTextView.backgroundColor = HEXCOLOR(0xE8E8EA);
    self.replayTextView.textColor = HEXCOLOR(0x3A404C);
    self.replayTextView.layer.masksToBounds = YES;
    self.replayTextView.layer.cornerRadius = 10;
    
//    [self.replayTextView setBackgroundColor:[UIColor redColor]];
    
    n = n + INSETS + height;
    
    // 两条线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, g_factory.cardBorderWithd)];
    topLine.backgroundColor = g_factory.cardBorderColor;
    [self.topView addSubview:topLine];
    
//    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, 0, 0.5, self.topView.frame.size.height)];
//    botLine.backgroundColor = HEXCOLOR(0xD6D6D6);
//    [self.topView addSubview:botLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(12 , 14, self.baseView.frame.size.width/2 - 12 - 15, 44)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [cancelBtn setBackgroundColor:HEXCOLOR(0xffffff)];
    [cancelBtn addTarget:self action:@selector(hideBigView) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    cancelBtn.layer.borderWidth = g_factory.cardBorderWithd;
    cancelBtn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    [self.topView addSubview:cancelBtn];
    
    // 发送
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2 + 15, cancelBtn.frame.origin.y, self.baseView.frame.size.width/2 - 12 - 15, 44)];
    [sureBtn setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [sureBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    sureBtn.layer.masksToBounds = YES;
    sureBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    [sureBtn addTarget:self action:@selector(onRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:sureBtn];

}

- (void)hideBigView {
    [self resignKeyBoard];
}

- (void)onRelease {
    [self sendIt];
}

- (void)appEnterForegroundNotif:(NSNotification *)notif {
    
}

- (void)friendPassNotif:(NSNotification *)notif {
    WH_JXFriendObject *user = notif.object;
    [g_server getUser:user.userId toView:self];
}

- (void) customView {
    //进入主页后再监听网络状态,解决无网络切换到有网络时,无网络控件不消失问题
    [g_App networkStatusChange];
    
//    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    scanButton.frame = CGRectMake(8, JX_SCREEN_TOP - 38, 34, 34);
//    [scanButton setImage:[UIImage imageNamed:@"scanicon"] forState:UIControlStateNormal];
//    [scanButton setImage:[UIImage imageNamed:@"scanicon"] forState:UIControlStateHighlighted];
//    [scanButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    scanButton.custom_acceptEventInterval = 1.0f;
//    [scanButton addTarget:self action:@selector(showScanViewController:) forControlEvents:UIControlEventTouchUpInside];
//    [self.wh_tableHeader addSubview:scanButton];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 24-BTN_RANG_UP*2, JX_SCREEN_TOP - 34-BTN_RANG_UP, 24+BTN_RANG_UP*2, 24+BTN_RANG_UP*2)];
    [btn addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableHeader addSubview:btn];
    
    self.moreBtn = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal"
                                           highlight:nil
                                              target:self
                                            selector:@selector(onMore:)];
    self.moreBtn.custom_acceptEventInterval = 1.0f;
    self.moreBtn.frame = CGRectMake(BTN_RANG_UP * 2, BTN_RANG_UP, NAV_BTN_SIZE, NAV_BTN_SIZE);
    [btn addSubview:self.moreBtn];
    
    
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, _wh_isShowTopPromptV ? (50+50) : 50)];
//    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:backView];

    //    [seekImgView release];
    
//    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
//    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    cancelBtn.custom_acceptEventInterval = .25f;
//    [cancelBtn addTarget:self action:@selector(WH_cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.titleLabel.font = sysFontWithSize(14);
//    [backView addSubview:cancelBtn];
    
    UIView *bgView = [UIView new];
    [backView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.offset(0.5);
        make.height.offset(44);
    }];
    bgView.backgroundColor = [UIColor whiteColor];
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 8, backView.frame.size.width - 20, 30)];
    _seekTextField.placeholder = [NSString stringWithFormat:@"%@", Localized(@"JX_SearchChatLog")];
    _seekTextField.backgroundColor = g_factory.inputBackgroundColor;
    if (@available(iOS 10, *)) {
        _seekTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", Localized(@"JX_SearchChatLog")] attributes:@{NSForegroundColorAttributeName:g_factory.inputDefaultTextColor}];
    } else {
        [_seekTextField setValue:g_factory.inputDefaultTextColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    [_seekTextField setFont:g_factory.inputDefaultTextFont];
    _seekTextField.textColor = HEXCOLOR(0x333333);
    _seekTextField.layer.borderWidth = 0.5;
    _seekTextField.layer.borderColor = g_factory.inputBorderColor.CGColor;
    
    _seekTextField.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:251/255.0 blue:252/255.0 alpha:1.0].CGColor;
    _seekTextField.layer.cornerRadius = 15;
//    _seekTextField.layer.masksToBounds = YES;
//    _seekTextField.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, JX_SCREEN_WIDTH, .5)];
//    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [backView addSubview:lineView];
    
    if (_wh_isShowTopPromptV) {
        _topPrompV = [[WH_TopPrompt_WHView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_seekTextField.frame) + 8, CGRectGetWidth(backView.frame), 50)];
        _topPrompV.wh_promptLabel.text = @"网络不给力,请检查网络设置.";
        [backView addSubview:_topPrompV];
        [_topPrompV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopPromptV)]];
    }
    
    self.tableView.backgroundColor = g_factory.globalBgColor;
    
    self.tableView.tableHeaderView = backView;
}

- (void)clickTopPromptV{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
    WH_NoInternet_WHController *noInternetVC = [[WH_NoInternet_WHController alloc] init];
    [g_navigation pushViewController:noInternetVC animated:YES];
}

- (void)setWh_isShowTopPromptV:(BOOL)isShowTopPromptV{
    if (_wh_isShowTopPromptV != isShowTopPromptV) {
        _wh_isShowTopPromptV = isShowTopPromptV;
        
        [self customView];
    }
}

- (void)WH_actionTitle:(JXLabel *)sender {
    // 掉线后点击title重连
    if([JXXMPP sharedInstance].isLogined != login_status_yes){
        
        [g_xmpp showXmppOfflineAlert];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_Reconnect") message:nil delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
//        [alert show];
    }
}

// 更改备注名
- (void)friendRemarkNotif:(NSNotification *)notif {
    
    WH_JXUserObject *user = notif.object;
    
    for (int i = 0; i < _wh_array.count; i ++) {
        WH_JXMsgAndUserObject *obj = _wh_array[i];
        if ([obj.user.userId isEqualToString:user.userId]) {
            obj.user.remarkName = user.remarkName;
            [_table WH_reloadRow:i section:0];
            break;
        }
    }
}

// 消息撤回
- (void)withdrawNotifi:(NSNotification *) notif {
    WH_JXMessageObject *msg = notif.object;
    
    for(NSInteger i=[_wh_array count]-1;i>=0;i--){
        WH_JXMsgAndUserObject *p=[_wh_array objectAtIndex:i];
        if([p.user.userId isEqualToString:msg.fromUserId] && [p.message.messageId isEqualToString:msg.content]){//如果找到被撤回的那条消息
            int n = [p.user.msgsNew intValue];
            n--;
            if(n<0)
                n = 0;
            if(! [p.message queryIsRead] ){//如果未读
                p.user.msgsNew = [NSNumber numberWithInt:n];//未读数量减1
                [msg updateLastSend:UpdateLastSendType_Dec];
            }
            break;
        }
        p =nil;
    }
    [self WH_doRefresh:msg showNumber:YES];
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        [self WH_getServerData];
        return;
    }
    
    [_searchArray removeAllObjects];
    for (NSInteger i = 0; i < _wh_array.count; i ++) {
        
        NSMutableArray *arr = [_wh_array mutableCopy];
        WH_JXMsgAndUserObject *obj = arr[i];
        
        NSArray * resultArray = [obj.message fetchSearchMessageWithUserId:obj.user.userId String:textField.text];
        
        for (WH_JXMessageObject *msg in resultArray) {
            if(msg.content.length > 0) {
                WH_JXMsgAndUserObject *searchObj = [[WH_JXMsgAndUserObject alloc] init];
                searchObj.user = obj.user;
                searchObj.message = msg;
                [_searchArray addObject:searchObj];
            }
        }
    }
    [self.tableView reloadData];
    [self getTotalNewMsgCount];
}

#pragma mark 右上角更多
-(void)onMore:(UIButton *)sender{
    //    _control.hidden = YES;
//    UIWindow *window = [[UIApplication sharedApplication].delegate window];
//    CGRect moreFrame = [self.wh_tableHeader convertRect:self.moreBtn.frame toView:window];

    NSMutableArray *titles ;
    NSMutableArray *images;
    NSMutableArray *sels ;
    
//    if ([g_config.isOpenPositionService intValue] == 0) {
//        titles = [NSMutableArray arrayWithArray:@[Localized(@"JX_LaunchGroupChat"),Localized(@"JX_FaceToFaceGroup"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"WaHu_JXNear_WaHuVC_NearPer"),Localized(@"JX_Receiving"),Localized(@"JX_SearchPublicNumber")]];
//        images = [NSMutableArray arrayWithArray:@[@"icon_group_chat_entry", @"icon_face_to_face", @"icon_add_friend", @"icon_scan",@"message_near_person_black", @"icon_payment_received",@"message_near_receiving",@"message_search_publicNumber"]];
//        sels = [NSMutableArray arrayWithArray:@[@"onNewRoom", @"onFaceCreateRoom", @"onSearch", @"showScanViewController", @"onNear",@"onReceiving",@"searchPublicNumber"]];
//    }else {
//        titles = [NSMutableArray arrayWithArray:@[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"JX_Receiving"),Localized(@"JX_SearchPublicNumber")]];
//        images = [NSMutableArray arrayWithArray:@[@"icon_group_chat_entry",  @"icon_add_friend", @"icon_scan", @"icon_payment_received",@"message_near_receiving",@"message_search_publicNumber"]];
//        sels = [NSMutableArray arrayWithArray:@[@"onNewRoom", @"onSearch", @"showScanViewController",@"onReceiving",@"searchPublicNumber"]];
//    }
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        titles = [NSMutableArray arrayWithArray:@[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"WaHu_JXNear_WaHuVC_NearPer"),Localized(@"JX_Receiving"),Localized(@"JX_SearchPublicNumber")]];
        images = [NSMutableArray arrayWithArray:@[@"icon_group_chat_entry", @"icon_add_friend", @"icon_scan",@"message_near_person_black", @"icon_payment_received",@"message_near_receiving",@"message_search_publicNumber"]];
        sels = [NSMutableArray arrayWithArray:@[@"onNewRoom", @"onSearch", @"showScanViewController", @"onNear",@"onReceiving",@"searchPublicNumber"]];
    }else {
        titles = [NSMutableArray arrayWithArray:@[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"JX_Receiving"),Localized(@"JX_SearchPublicNumber")]];
        images = [NSMutableArray arrayWithArray:@[@"icon_group_chat_entry",  @"icon_add_friend", @"icon_scan", @"icon_payment_received",@"message_near_receiving",@"message_search_publicNumber"]];
        sels = [NSMutableArray arrayWithArray:@[@"onNewRoom", @"onSearch", @"showScanViewController",@"onReceiving",@"searchPublicNumber"]];
    }
    
    if ([g_config.hideSearchByFriends intValue] == 1 && ([g_config.isCommonFindFriends intValue] == 0 || g_myself.role.count > 0)) {
    }else {
        [titles removeObject:Localized(@"JX_AddFriends")];
        [images removeObject:@"message_add_friend_black"];
        [sels removeObject:@"onSearch"];
    }
    if ([g_config.isCommonCreateGroup intValue] == 1 && g_myself.role.count <= 0) {
        [titles removeObject:Localized(@"JX_LaunchGroupChat")];
        [images removeObject:@"message_creat_group_black"];
        [sels removeObject:@"onNewRoom"];
    }
    if ([g_config.isOpenPositionService intValue] == 1) {
        [titles removeObject:Localized(@"WaHu_JXNear_WaHuVC_NearPer")];
        [images removeObject:@"message_near_person_black"];
        [sels removeObject:@"onNear"];
    }
    if ([g_App.isShowRedPacket intValue] == 0) {
        [titles removeObject:Localized(@"JX_Receiving")];
        [images removeObject:@"message_near_receiving"];
        [sels removeObject:@"onReceiving"];
    }

    WH_JX_SelectMenuView *menuView = [[WH_JX_SelectMenuView alloc] initWithTitle:titles image:images cellHeight:45];
    menuView.sels = sels;
    menuView.delegate = self;
    [g_App.window addSubview:menuView];
//    WH_JX_DownListView * downListView = [[WH_JX_DownListView alloc] initWithFrame:self.view.bounds];
//    downListView.listContents = @[Localized(@"JX_LaunchGroupChat"), Localized(@"JX_AddFriends"), Localized(@"JX_Scan"), Localized(@"WH_JXNear_WHVC_NearPer")];
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

#pragma mark - 点击右上角菜单
- (void)didMenuView:(WH_JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    
    NSString *method = MenuView.sels[index];
    SEL _selector = NSSelectorFromString(method);
    [self performSelectorOnMainThread:_selector withObject:nil waitUntilDone:YES];
//    return;
//
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



- (void) moreListActionWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
            [self onNewRoom];
            break;
        case 1:
            [self onSearch];
            break;
        case 2:
            [self showScanViewController];
            break;
        case 3:
            [self onNear];
            break;
        default:
            break;
    }
}

// 搜索公众号
- (void)searchPublicNumber {
    WH_JXSearchUser_WHVC *searchUserVC = [WH_JXSearchUser_WHVC alloc];
    searchUserVC.type = JXSearchTypePublicNumber;
    searchUserVC = [searchUserVC init];
    [g_navigation pushViewController:searchUserVC animated:YES];
}

// 创建群组
-(void)onNewRoom{
//    WH_JXNewRoom_WHVC* vc = [[WH_JXNewRoom_WHVC alloc]init];
//    [g_navigation pushViewController:vc animated:YES];
    
    if ([g_config.isCommonCreateGroup intValue] == 1) {
        [g_App showAlert:Localized(@"JX_NotCreateNewRoom")];
        return;
    }
    
    _createRoom = [[WH_RoomData alloc] init];
    
    memberData *member = [[memberData alloc] init];
    member.userId = (long)[g_myself.userId longLongValue];
    member.userNickName = MY_USER_NAME;
    member.role = @1;
    [_createRoom.members addObject:member];
    
    self.user = [[WH_JXUserObject alloc] init];
    self.user.userId = g_myself.userId;
    self.user.userNickname = g_myself.userNickname;
    
    WH_JXSelectFriends_WHVC* vc = [WH_JXSelectFriends_WHVC alloc];
    vc.room = _createRoom;
    vc.isNewRoom = YES;
//    vc.isForRoom = YES;
    vc.forRoomUser = self.user;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

// 面对面建群
- (void)onFaceCreateRoom {
    
    WH_JXFaceCreateRoom_WHVC *vc = [[WH_JXFaceCreateRoom_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

// 附近的人
-(void)onNear{
    WH_JXNear_WHVC * nearVc = [[WH_JXNear_WHVC alloc] init];
    [g_navigation pushViewController:nearVc animated:YES];
}
// 收付款
- (void)onReceiving {
//    WH_JXPay_WHViewController *payVC = [[WH_JXPay_WHViewController alloc] init];
//    [g_navigation pushViewController:payVC animated:YES];
    
    WH_JXCollectMoney_WHVC * collVC = [[WH_JXCollectMoney_WHVC alloc] init];
    [g_navigation pushViewController:collVC animated:YES];
}

- (void) WH_cancelBtnAction {
    if (_seekTextField.text.length > 0) {
        _seekTextField.text = nil;
        [self WH_getServerData];
    }
    [_seekTextField resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
        [[JXXMPP sharedInstance] login];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) delAllChatLogNotifi:(NSNotification *)notif {
    [self WH_getServerData];
    self.wh_msgTotal = 0;
}


#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellName = [NSString stringWithFormat:@"msg"];
    
    WH_JX_WH2Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    NSMutableArray *array;
    if (_seekTextField.text.length > 0) {
        array = _searchArray;
    }else {
        array = _wh_array;
    }
    WH_JXMsgAndUserObject * dict = (WH_JXMsgAndUserObject*) [array objectAtIndex:indexPath.row];
    
    if(cell==nil){
        cell = [[WH_JX_WH2Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [_table WH_addToPool:cell];
    }
    cell.delegate = self;
    cell.didTouch = @selector(WH_on_WHHeadImage:);
    cell.didDragout=@selector(onDrag:);
    cell.didReplay = @selector(onReplay:);
    //    [cell msgCellDataSet:dict indexPath:indexPath];
    cell.title = dict.user.remarkName.length > 0 ? dict.user.remarkName : dict.user.userNickname;
    
    cell.user = dict.user;
    cell.userId = dict.user.userId;
    cell.bage = [NSString stringWithFormat:@"%d",[dict.user.msgsNew intValue]];
    //隐藏或显示快速回复按钮
    cell.isMsgVCCome = NO;
    cell.isStick = dict.user.topTime ? YES : NO;
    
    cell.index = (int)indexPath.row;
    cell.bottomTitle  = [TimeUtil getTimeStrStyle1:[dict.message.timeSend timeIntervalSince1970]];
    
    cell.headImageView.tag = (int)indexPath.row;
    cell.headImageView.wh_delegate = cell.delegate;
    cell.headImageView.didTouch = cell.didTouch;
    
    [cell.lbTitle setText:cell.title];
    cell.lbTitle.tag = cell.index;
    cell.isNotPush = [dict.user.offlineNoPushMsg boolValue];
    NSString *lastContet = [dict.message getLastContent];
    BOOL flag = NO;
    if ([dict.user.isAtMe intValue] == 1 && _seekTextField.text.length <= 0 && (dict.user.roomFlag || dict.user.roomId.length > 0)) {
        lastContet = [NSString stringWithFormat:@"%@%@",Localized(@"JX_Someone@Me"),[dict.message getLastContent]];
        flag = YES;
    }
    
    if(dict.user.lastInput.length > 0 && _seekTextField.text.length <= 0) {
        lastContet = [NSString stringWithFormat:@"%@%@",Localized(@"JX_Draft"),dict.user.lastInput];
        flag = YES;
//        NSString *str = Localized(@"JX_Draft");
//        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str, dict.user.lastInput]];
//        NSRange range = [[NSString stringWithFormat:@"%@%@",str, dict.user.lastInput] rangeOfString:str];
//        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
//        cell.lbSubTitle.attributedText = attr;
        
    }
    
    if ([dict.message.type intValue] == kWCMessageTypeText || flag) {

        [cell setSubtitle:lastContet];
    }else {
        cell.lbSubTitle.text = lastContet;
    }
    
    [cell.timeLabel setText:cell.bottomTitle];
    cell.bageNumber.wh_delegate = cell.delegate;
    cell.bageNumber.wh_didDragout = cell.didDragout;
    cell.bage = cell.bage;
    if ([dict.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        cell.bageNumber.wh_lb.hidden = YES;
//        CGRect frame = cell.bageNumber.frame;
//        frame.size = CGSizeMake(10, 10);
//        cell.bageNumber.frame = frame;
    }else {
        cell.bageNumber.wh_lb.hidden = NO;
//        CGRect frame = cell.bageNumber.frame;
//        frame.size = CGSizeMake(20, 20);
//        cell.bageNumber.frame = frame;
    }
    NSString * roomIdStr = dict.user.roomId;
    cell.roomId = roomIdStr;
    [cell WH_headImageViewImageWithUserId:dict.user.userId roomId:roomIdStr];
    cell.isSmall = NO;
    [self WH_doAutoScroll:indexPath];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.lineView.hidden = YES;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_seekTextField.text.length > 0) {
        return _searchArray.count;
    }
    return _wh_array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 64;
    return 85+8;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    WH_JXMessageObject *msg = notifacation.object;
    if(msg==nil)
        return;
    BOOL showNumber=YES;

#ifdef Live_Version
    if([[WH_JXLiveJid_WHManager shareArray] contains:msg.toUserId] || [[WH_JXLiveJid_WHManager shareArray] contains:msg.fromUserId])
        return;
#endif
    
    if ([msg.toUserId isEqualToString:self.rJid]) {
        self.isTwoWithdrawal = NO;
    }
    
    if([msg.toUserId isEqualToString:MY_USER_ID]){
        if([msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [msg.type intValue] == kWCMessageTypeVideoMeetingInvite)
            showNumber = NO;//一律不提醒
    }
    if(!msg.isVisible && ![msg isAddFriendMsg])
        return;
    if (!_audioPlayer) {
        _audioPlayer = [[WH_AudioPlayerTool alloc]init];
    }

    _audioPlayer.wh_isOpenProximityMonitoring = NO;
    NSString *userId = nil;
    if (msg.isGroup) {
        userId = msg.toUserId;
    }else {
        userId = msg.fromUserId;
    }
    
    WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:userId];
    
    
    if (msg.isGroup && msg.isDelay) {
        
        
        // 更新任务endTime
        for (NSInteger i = 0; i < _taskArray.count; i ++) {
            NSDictionary *taskDic = _taskArray[i];
            if ([user.userId isEqualToString:taskDic[@"userId"]]) {
                NSDate *startTime = taskDic[@"startTime"];
                if ([msg.timeSend timeIntervalSince1970] <= [startTime timeIntervalSince1970]) {
                    [_taskArray removeObjectAtIndex:i];
                    break;
                }
                if (![taskDic objectForKey:@"endTime"]) {
                    [taskDic setValue:msg.timeSend forKey:@"endTime"];
                    [taskDic setValue:msg.messageId forKey:@"endMsgId"];
                    
                    [self createSynTask:taskDic];
                }
                break;
            }
        }
        
    }
    
    if(msg.isRepeat){
        return;
    }
    
    
    if(![msg.fromUserId isEqualToString:MY_USER_ID] && !_audioPlayer.wh_isPlaying && ![userId isEqualToString:current_chat_userId] && [user.offlineNoPushMsg intValue] != 1){
        //播放系统提示音
        static NSDate *lastPlayerDate = nil;
        NSDate *nowDate = [NSDate date];
        if (!lastPlayerDate || fabs([lastPlayerDate timeIntervalSinceDate:nowDate]) > 1.f) {
            //最频繁一秒响一次
//            _audioPlayer.wh_audioFile = [imageFilePath stringByAppendingPathComponent:@"newmsgsys.mp3"];
//            _audioPlayer.wh_isNotStopLast = YES;
//            [_audioPlayer wh_open];
//            [_audioPlayer wh_play];
            
            SystemSoundID sound;
            
            NSString*path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",@"sms-received1",@"caf"];
            
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
            if(error != kAudioServicesNoError) {
                //sound = nil;
            }
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            AudioServicesPlaySystemSound(sound);
            
            lastPlayerDate = nowDate;
            if ([g_myself.isVibration intValue] > 0) {
                //AudioServicesPlaySystemSound(1007); //(最强震动,微信提示声音)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    }
    if (![msg.fromUserId isEqualToString:MY_USER_ID] && ![userId isEqualToString:current_chat_userId]) {
        
        if (msg.isGroup && msg.isAtMe) {
            WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
            user.userId = [msg getTableName];
            user.isAtMe = [NSNumber numberWithInt:1];
            [user updateIsAtMe];
        }
        
    }

    //[self WH_doRefresh:msg showNumber:showNumber];
    msg = nil;
}

- (void)createSynTask:(NSDictionary *)dict{
    JXSynTask *task = [[JXSynTask alloc] init];
    task.userId = dict[@"userId"];
    task.roomId = dict[@"roomId"];
    task.startTime = dict[@"startTime"];
    task.endTime = dict[@"endTime"];
    task.lastTime = dict[@"lastTime"];
    task.startMsgId = dict[@"startMsgId"];
    task.endMsgId = dict[@"endMsgId"];
    [task insert];
}

-(void)newMsgSend:(NSNotification *)notifacation
{
    WH_JXMessageObject *msg = notifacation.object;
    if(!msg.isVisible && ![msg isAddFriendMsg])
        return;
    if ([msg.type intValue] == kWCMessageTypeWithdraw) {
        msg.content = Localized(@"JX_AlreadyWithdraw");
    }
    [self WH_doRefresh:msg showNumber:NO];
    msg = nil;
}

-(void)newRequest:(NSNotification *)notifacation
{
    WH_JXFriendObject * friend = (WH_JXFriendObject*) notifacation.object;
    friend = nil;
}

#pragma --------------------新来的消息Badge计算---------------
-(void)WH_doRefresh:(WH_JXMessageObject*)msg showNumber:(BOOL)showNumber{
    NSString* s;
    s = [msg getTableName];
    
    if([s isEqualToString:FRIEND_CENTER_USERID])//假如是朋友验证消息，过滤
        return;
    
    WH_JXMsgAndUserObject *oldobj=nil;
    for(int i=0;i<[_wh_array count];i++){
        oldobj=[_wh_array objectAtIndex:i];
        if([oldobj.user.userId isEqualToString:s]){
            oldobj.message.content = [msg getLastContent];
            oldobj.message.type = msg.type;
            oldobj.message.timeSend = msg.timeSend;
            if([current_chat_userId isEqualToString:s] || msg.isMySend || !showNumber){//假如是我发送的，或正在这个界面，或不显示数量时
                if([current_chat_userId isEqualToString:s])//正在聊天时，置0;是我发送的消息时，不变化数量
                    oldobj.user.msgsNew = [NSNumber numberWithInt:0];
            }
            else{
                if ([msg.content rangeOfString:Localized(@"JX_OtherWithdraw")].location == NSNotFound) {
                    oldobj.user.msgsNew = [NSNumber numberWithInt:[oldobj.user.msgsNew intValue]+1];
                }
                
            }
            [_wh_array removeObjectAtIndex:i];
            break;
        }
        oldobj = nil;
    }
    NSString *userId = nil;
    if (msg.isGroup) {
        userId = msg.toUserId;
    }else {
        userId = msg.fromUserId;
    }
    
    if(oldobj){//列表中有此用户：
        
        if (![msg.fromUserId isEqualToString:MY_USER_ID] && ![userId isEqualToString:current_chat_userId]) {
            
            if (msg.isGroup && msg.isAtMe) {
                oldobj.user.isAtMe = [NSNumber numberWithInt:1];
                [oldobj.user updateIsAtMe];
            }
            
        }
        
        if (oldobj.user.topTime) {
            oldobj.user.topTime = [NSDate date];
            [oldobj.user WH_updateTopTime];
            [_wh_array insertObject:oldobj atIndex:0];
        }else if(oldobj.user){
            
            [_wh_array insertObject:oldobj atIndex:_topNum];
        }
        
        _refreshCount++;
        [_table reloadData];
    }else{
        //列表中没有此用户：
        WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
        newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:s];
        newobj.message = [msg copy];
        if([current_chat_userId isEqualToString:s] || msg.isMySend || !showNumber){//假如是我发送的，或正在这个界面，或不显示数量时
            if([current_chat_userId isEqualToString:s])//正在聊天时，置0;是我发送的消息时，不变化数量
                newobj.user.msgsNew = [NSNumber numberWithInt:0];
        }
        else
            if([s isEqualToString:FRIEND_CENTER_USERID])//假如是朋友验证消息，总为1
                return;
//                newobj.user.msgsNew = [NSNumber numberWithInt:1];
            else{
                newobj.user.msgsNew = [NSNumber numberWithInt:[newobj.user.msgsNew intValue]];
                if (msg.isGroup && msg.isAtMe) {
                    newobj.user.isAtMe = [NSNumber numberWithInt:1];
                    [newobj.user updateIsAtMe];
                }
            }
        
        if (newobj.user) {
            [_wh_array insertObject:newobj atIndex:_topNum];
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [indexPaths addObject:indexPath];
            
            [_table beginUpdates];
            [_table insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [_table endUpdates];
            [_table WH_gotoFirstRow:YES];
        }
        
        newobj = nil;
    }
    if(msg.isMySend || !showNumber)
        return;
    else
        [self getTotalNewMsgCount];
}

-(void)WH_getServerData
{
    [self WH_stopLoading];
    
    if(_wh_array==nil || _page == 0){
//        NSLog(@"%d",[[_array objectAtIndex:0] retainCount]);
        [_wh_array removeAllObjects];
//        [_array release];
        _wh_array = [[NSMutableArray alloc]init];
        _refreshCount++;
    }
    //访问DB获取好友消息列表
    NSMutableArray* p = [[WH_JXMessageObject sharedInstance] fetchRecentChat];
    _topNum = 0;
    // 查出置顶个数
    for (NSInteger i = 0; i < p.count; i ++) {
        WH_JXMsgAndUserObject * obj = (WH_JXMsgAndUserObject*) [p objectAtIndex:i];
        
        if (self.isTwoWithdrawal && !IsStringNull(self.rJid)) {
            if ([obj.user.userId isEqualToString:self.rJid]) {
                [p removeObject:obj];
                break;
            }
        }

        if (obj.user.topTime) {
            _topNum ++;
        }

    }
    
    if (p.count>0) {
        [_wh_array addObjectsFromArray:p];
        //让数组按时间排序
//        [self sortArrayWithTime];
        [_table WH_hideEmptyImage];
        [_table reloadData];
        self.wh_isShowFooterPull = NO;
    }
    
    if (_wh_array.count <=0) {
        [_table WH_showEmptyImage:EmptyTypeNoData];
        [_table reloadData];
    }
    
    [self getTotalNewMsgCount];
    
    [p removeAllObjects];
}



//数据（CELL）按时间顺序重新排列
- (void)sortArrayWithTime{

    for (int i = 0; i<[_wh_array count]; i++)
    {
        
        for (int j=i+1; j<[_wh_array count]; j++)
        {
            WH_JXMsgAndUserObject * dicta = (WH_JXMsgAndUserObject*) [_wh_array objectAtIndex:i];
            NSDate * a = dicta.message.timeSend ;
//            NSLog(@"a = %d",[dicta.user.msgsNew intValue]);
            WH_JXMsgAndUserObject * dictb = (WH_JXMsgAndUserObject*) [_wh_array objectAtIndex:j];
            NSDate * b = dictb.message.timeSend ;
            //                NSLog(@"b = %d",b);
            
            if ([[a laterDate:b] isEqualToDate:b])
            {
//                - (NSDate *)earlierDate:(NSDate *)anotherDate;
//                与anotherDate比较，返回较早的那个日期
//
//                - (NSDate *)laterDate:(NSDate *)anotherDate;
//                与anotherDate比较，返回较晚的那个日期
//                WH_JXMsgAndUserObject * dictc = dicta;
                
                [_wh_array replaceObjectAtIndex:i withObject:dictb];
                [_wh_array replaceObjectAtIndex:j withObject:dicta];
            }
            
        }
        
    }
    
}


//-(void)afterDalay{
//    _dalayAction = NO;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    NSLog(@"didSelectRowAtIndexPath.begin");
//    if (_dalayAction) {
//        return;
//    }else{
//        _dalayAction = YES;
//        [self performSelector:@selector(afterDalay) withObject:nil afterDelay:0.5];
//    }
    WH_JX_WH2Cell* cell = (WH_JX_WH2Cell*)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;
    
    //清除badge
    cell.bage = @"0";
    NSMutableArray *array;
    if (_seekTextField.text.length > 0) {
        array = _searchArray;
    }else {
        array = _wh_array;
    }
    WH_JXMsgAndUserObject *p=[array objectAtIndex:indexPath.row];
    if (![p.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        self.wh_msgTotal -= [cell.bage intValue];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - [p.user.msgsNew intValue];
//    [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
    
    int lineNum = 0;
    if (_seekTextField.text.length > 0) {
        lineNum = [p.message getLineNumWithUserId:p.user.userId];
    }
    
    if([p.user.userId isEqualToString:FRIEND_CENTER_USERID]){
        WH_JXNewFriend_WHViewController* vc = [[WH_JXNewFriend_WHViewController alloc]init];
//        [g_App.window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        return;
    }
    if ([p.user.userId intValue] == [WAHU_TRANSFER intValue]) {
        WH_JXTransferNotice_WHVC *noticeVC = [[WH_JXTransferNotice_WHVC alloc] init];
        [g_navigation pushViewController:noticeVC animated:YES];
        p.user.msgsNew = [NSNumber numberWithInt:0];
        [p.message WH_updateNewMsgsTo0];
        [self getTotalNewMsgCount];
        return;
    }
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    
    sendView.scrollLine = lineNum;
    sendView.title = p.user.remarkName.length > 0 ? p.user.remarkName : p.user.userNickname;
    if([p.user.roomFlag intValue] > 0 || p.user.roomId.length > 0){
//        if(g_xmpp.isLogined != 1){
//            // 掉线后点击title重连
//            [g_xmpp showXmppOfflineAlert];
//            return;
//        }
        
        sendView.roomJid = p.user.userId;
        sendView.roomId   = p.user.roomId;
        sendView.groupStatus = p.user.groupStatus;
        if ([p.user.groupStatus intValue] == 0) {
            
            sendView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:p.user.userId title:p.user.userNickname isNew:NO];
        } else if ([p.user.groupStatus intValue] == 1) {
            [GKMessageTool showError:@"你已被踢出群组"];
            return;
        } else if ([p.user.groupStatus intValue] == 2) {
            [GKMessageTool showError:@"该群已被群主解散"];
            return;
        } else {
            [GKMessageTool showError:@"该群组已被后台锁定"];
            return;
        }
        
        if (p.user.roomFlag || p.user.roomId.length > 0) {
            NSDictionary * groupDict = [p.user toDictionary];
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:groupDict];
            sendView.room = roomdata;
            sendView.newMsgCount = [p.user.msgsNew intValue];
            
            
            p.user.isAtMe = [NSNumber numberWithInt:0];
            [p.user updateIsAtMe];
        }
        
    }
    sendView.rowIndex = indexPath.row;
    sendView.lastMsg = p.message;
    sendView.chatPerson = p.user;
    sendView = [sendView init];
//    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.view.hidden = NO;
    
    p.user.msgsNew = [NSNumber numberWithInt:0];
    [p.message WH_updateNewMsgsTo0];
    
    [self WH_cancelBtnAction];
    
    [self getTotalNewMsgCount];
}

-(void)onLoginChanged:(NSNotification *)notifacation{
    
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.wh_tableHeader addSubview:_activity];
    }
    
    switch ([JXXMPP sharedInstance].isLogined){
        case login_status_ing:{
            self.title = Localized(@"WaHu_JXMsg_WaHuViewController_GoingOff");
            CGSize size = [self.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18.0]} context:nil].size;
            _activity.frame = CGRectMake(JX_SCREEN_WIDTH / 2 + size.width / 2 + 10, JX_SCREEN_TOP - 32, 20, 20);
            
            [_activity startAnimating];
        }
            break;
        case login_status_no:{
            self.title = Localized(@"WaHu_JXMsg_WaHuViewController_OffLine");
            if (g_xmpp.isPasswordError) {
                self.title = [NSString stringWithFormat:@"%@(%@)",Localized(@"WaHu_JXMain_WaHuViewController_Message"),Localized(@"JX_PasswordError")];
            }
            [_activity stopAnimating];
        }
            break;
        case login_status_yes:{
            self.title = Localized(@"WaHu_JXMsg_WaHuViewController_OnLine");
            
            [_activity stopAnimating];
            [g_notify postNotificationName:kJinQianTaiTongBuQuanZu_WHNotifaction object:nil];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                // 同步最近一条聊天记录
//                [self getLastChatList];
//            });
            
            NSDictionary *infoDdict = [g_default objectForKey:@"shareInfo"];
            if ([infoDdict count] > 0) {
                NSString *roomId = [NSString stringWithFormat:@"%@",infoDdict[@"roomId"]];
                if (roomId.length) {
                    [g_server getRoom:roomId toView:self];
                    self.isWeChatJoinGroup = YES;
                }else{
                    [GKMessageTool showText:@"获取房间ID失败"];
                }
                
                //        [g_server WH_listHisRoomWithPage:0 pageSize:1000 toView:self];
            }
            
        }

            break;
    }
}

- (void)getLastChatList {
    
    BOOL isFirstSync = [g_default boolForKey:kISFirstGetLastChatList];
    
    long long syncTimeLen;
    
    
    if (!isFirstSync) {
//        if ([g_myself.chatSyncTimeLen longLongValue] > [g_myself.groupChatSyncTimeLen longLongValue]) {
            syncTimeLen = [g_myself.chatSyncTimeLen longLongValue];
//        }else {
//            syncTimeLen = [g_myself.groupChatSyncTimeLen longLongValue];
//        }
        
        double m = syncTimeLen * 24 * 3600;
        syncTimeLen = [[NSDate date] timeIntervalSince1970] - m;
        
        if ([g_myself.chatSyncTimeLen longLongValue] == 0 || [g_myself.chatSyncTimeLen longLongValue] == -1) {
            syncTimeLen = 0;
        }
        
        [g_default setBool:YES forKey:kISFirstGetLastChatList];
        
    }else {
        syncTimeLen = g_server.lastOfflineTime;
    }
    
    if ([g_myself.chatSyncTimeLen longLongValue] == -2) {
        
        [g_xmpp.roomPool createAll];
        
    }else {
        if (syncTimeLen <= 0) {
            syncTimeLen = 3000;
        }
        [g_server WH_getLastChatListWithStartTime:[NSNumber numberWithLong:syncTimeLen - 3000] toView:self];
    }
    
}

//对选中的Cell根据editingStyle进行操作
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_seekTextField.text.length > 0) {
        return;
    }
    
    WH_JXMsgAndUserObject *p=[_wh_array objectAtIndex:indexPath.row];
    if (![p.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        self.wh_msgTotal -= [p.user.msgsNew intValue];
    }

    [p.user reset];
    [p.message deleteAll];
    p =nil;
    
    [_wh_array removeObjectAtIndex:indexPath.row];
    _refreshCount++;
    [_table reloadData];
    [self getTotalNewMsgCount];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WH_JXMsgAndUserObject *p=[_wh_array objectAtIndex:indexPath.row];
    UITableViewRowAction *readBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:[p.user.msgsNew intValue] > 0 ? Localized(@"JX_MsgMarkedRead") : Localized(@"JX_MsgMarkedUnread") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        WH_JX_WH2Cell* cell = (WH_JX_WH2Cell*)[tableView cellForRowAtIndexPath:indexPath];
        
        if ([p.user.msgsNew intValue] > 0) {
            //清除badge
            cell.bage = @"0";
            p.user.msgsNew = @0;
            if (![p.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
                self.wh_msgTotal -= [cell.bage intValue];
            }
            p.user.msgsNew = [NSNumber numberWithInt:0];
            [p.message WH_updateNewMsgsTo0];
        }else {
            cell.bage = @"1";
            p.user.msgsNew = @1;
            [p.user WH_updateNewMsgNum];
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - [p.user.msgsNew intValue];
//        [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];

        [self getTotalNewMsgCount];
    }];
    
    readBtn.backgroundColor = [UIColor orangeColor];

    UITableViewRowAction *delBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (_seekTextField.text.length > 0) {
            return;
        }
        
        WH_JXMsgAndUserObject *p=[_wh_array objectAtIndex:indexPath.row];
        if (![p.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
            self.wh_msgTotal -= [p.user.msgsNew intValue];
        }
        
        p.user.topTime = nil;
        if (_topNum > 0)
            _topNum --;
        
        [p.user WH_updateTopTime];
        
        [p.user reset];
        [g_notify postNotificationName:kFriendListRefresh_WHNotification object:nil];
        [g_server WH_DeleteOneLastChatWithToUser:p.message.fromUserId toView:self];
        [p.message deleteAll];
        p =nil;
        
        [_wh_array removeObjectAtIndex:indexPath.row];
        _refreshCount++;
        [_table reloadData];
        [self getTotalNewMsgCount];
        
        
        
    }];
    
    NSString *str;
    if (p.user.topTime) {
        str = Localized(@"JX_CancelTop");
    }else {
        str = Localized(@"JX_Top");
    }
    
    UITableViewRowAction *topBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:str handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [_wh_array removeObject:p];
        if (p.user.topTime) {
            p.user.topTime = nil;
            if (_topNum > 0)
                _topNum --;
            
            [_wh_array insertObject:p atIndex:_topNum];
        }else {
            p.user.topTime = [NSDate date];
            _topNum ++;
            [_wh_array insertObject:p atIndex:0];
        }
        
        [p.user WH_updateTopTime];
        
        [_table reloadData];
    }];
    
    return @[delBtn, readBtn, topBtn];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_seekTextField.text.length > 0) {
        return NO;
    }
    
    //将“新的消息”及“系统消息”设为不可编辑
    WH_JXMsgAndUserObject *p=[_wh_array objectAtIndex:indexPath.row];
    long n = [p.user.userId intValue];

    if(n == [FRIEND_CENTER_USERID intValue])
        return NO;
    if(n == BLOG_CENTER_INT)
        return NO;
//    if(n == CALL_CENTER_INT)
//        return NO;

    return YES;
}

-(void)delFriend:(NSNotification *)notifacation
{
//    NSLog(@"delFriend.notify");
    WH_JXUserObject* user = (WH_JXUserObject *)notifacation.object;
    NSString* userId = user.userId;
    if(userId==nil)
        return;

    for(NSInteger i=[_wh_array count]-1;i>=0;i--){
        WH_JXMsgAndUserObject *p=[_wh_array objectAtIndex:i];
        if([p.user.userId isEqualToString:userId]){
            
            [g_server WH_DeleteOneLastChatWithToUser:p.message.fromUserId toView:self];
            
            [_wh_array removeObjectAtIndex:i];
            break;
        }
        p =nil;
    }
    
    _refreshCount++;
    [_table reloadData];
    [self getTotalNewMsgCount];
}

#pragma mark 快速回复
- (void)onReplay:(WH_JX_WH2Cell *)cell {
    
    self.replayNum = cell.index;
    
    NSMutableArray *array;
    if (_seekTextField.text.length > 0) {
        array = _searchArray;
    }else {
        array = _wh_array;
    }
    WH_JXMsgAndUserObject * dict = (WH_JXMsgAndUserObject*) [array objectAtIndex:self.replayNum];
    
    if ([dict.user.userId isEqualToString:WAHU_TRANSFER]) {
        return;
    }
    
    if (dict.user.roomId.length > 0) {
        self.replayRoomId = dict.user.roomId;
        [g_server WH_roomGetRoom:self.replayRoomId toView:self];
    }else {
        [self showReplayView];
    }
}

- (void)showReplayView {
    NSMutableArray *array;
    if (_seekTextField.text.length > 0) {
        array = _searchArray;
    }else {
        array = _wh_array;
    }
    WH_JXMsgAndUserObject * dict = (WH_JXMsgAndUserObject*) [array objectAtIndex:self.replayNum];
    WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
    user = dict.user;
    if ([user.groupStatus intValue] == 1) {
        [g_App showAlert:Localized(@"JX_OutOfTheGroup1")];
        return;
    }
    if (self.replayTextView.text.length > 0) {
        self.replayTextView.text = nil;
    }
    self.bigView.hidden = NO;
    [self.replayTextView becomeFirstResponder];
    
    self.replayTitle.text = [NSString stringWithFormat:@"%@ : %@",Localized(@"JX_MsgTheQuickReply"),user.userNickname];
    self.lastMsgInput = [dict.message getLastContent]; // 记录最后一条消息
    
    self.replayTextView.textColor = HEXCOLOR(0x3A404C);
    self.replayTextView.text = self.lastMsgInput;
    self.replayTextView.selectedRange = NSMakeRange(0, 0);
    // 加载水印时调用textViewDidChange 高度自适应
    [self textViewDidChange:self.replayTextView];
    // 防止出现特殊符号自动换行问题
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size: 16],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor]
                                 };
    self.replayTextView.attributedText = [[NSAttributedString alloc] initWithString:self.lastMsgInput attributes:attributes];
    
    // 提前拿到数据防止cell.indexPath.row改变后导致发送消息错误
    self.repalyMsg = [[WH_JXMessageObject alloc] init];
    self.repalyMsg.fromUserId = MY_USER_ID;
    self.repalyMsg.fromUserName = MY_USER_NAME;
    self.repalyMsg.toUserId = dict.user.userId;
    self.repalyMsg.isGroup = dict.user.roomId.length > 0 ? YES : NO;
    self.repalyMsg.type = [NSNumber numberWithInt:kWCMessageTypeText];
    self.repalyMsg.timeSend = [NSDate date];
    self.repalyMsg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    self.repalyMsg.isRead       = [NSNumber numberWithBool:NO];
    self.repalyMsg.isReadDel    = [NSNumber numberWithInt:NO];
    self.repalyMsg.sendCount    = 3;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    //如果是提示内容，光标放置开始位置
    if (textView.textColor == [UIColor lightGrayColor]) {
        NSRange range;
        range.location = 0;
        range.length = 0;
        textView.selectedRange = range;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //如果不是delete响应,当前是提示信息，修改其属性
    if (![text isEqualToString:@""] && textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";//置空
        textView.textColor = HEXCOLOR(0x3A404C);
    }
//    if ([text isEqualToString:@"\n"]) {  //回车事件
//        if ([textView.text isEqualToString:@""])//如果直接回车，显示提示内容
//        {
//            textView.textColor = [UIColor lightGrayColor];
//            textView.text = self.lastMsgInput;
//        }
//        return NO;
//    }
//    int maxHeight = 70;
//    CGRect frame = textView.frame;
//    if (frame.size.height > maxHeight) {
//        frame.size.height = maxHeight;
//        textView.scrollEnabled = YES;
//    }else {
//        textView.scrollEnabled = NO;
//    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    static CGFloat maxHeight = 85.0f;

    
    //防止输入时在中文后输入英文过长直接中文和英文换行
    if ([textView.text isEqualToString:@""]) {
        textView.textColor = HEXCOLOR(0x969696);
        textView.text = self.lastMsgInput;
    }
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-40-INSETS*2, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }

    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, (size.height < 60)?size.height:size.height);
    NSLog(@"--------%@",NSStringFromCGRect(self.baseView.frame));

    self.baseView.frame = CGRectMake(20, JX_SCREEN_HEIGHT/4+35-size.height, JX_SCREEN_WIDTH-40, baseViewHeight+size.height);
//    self.topView.frame = CGRectMake(0, 118-35+size.height, self.baseView.frame.size.width, 60);
    self.topView.frame = CGRectMake(0, CGRectGetHeight(self.baseView.frame) - 72 - g_factory.cardBorderWithd, self.baseView.frame.size.width, 72);
}

- (void)sendIt {
    [self resignKeyBoard];
    NSString *roomName = self.repalyMsg.isGroup ? self.repalyMsg.toUserId : nil;
    self.repalyMsg.content = self.replayTextView.text;
    [self.repalyMsg insert:self.repalyMsg.toUserId];
    self.repalyMsg.updateLastContent = YES;
    [self.repalyMsg updateLastSend:UpdateLastSendType_None];
    WH_JX_WH2Cell* cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.replayNum inSection:0]];
    //清除badge
    cell.bage = @"0";
    
    NSMutableArray *array;
    if (_seekTextField.text.length > 0) {
        array = _searchArray;
    }else {
        array = _wh_array;
    }
    WH_JXMsgAndUserObject *p=[array objectAtIndex:self.replayNum];
    if (![p.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
        self.wh_msgTotal -= [cell.bage intValue];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - [p.user.msgsNew intValue];
//    [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
    
    [p.message WH_updateNewMsgsTo0];
    [_table WH_reloadRow:self.replayNum section:0];
    [g_xmpp sendMessage:self.repalyMsg roomName:roomName];
    [self WH_doRefresh:self.repalyMsg showNumber:NO];
}

#pragma mark - 头像按钮点击方法
-(void)WH_on_WHHeadImage:(UIView*)sender{
    NSMutableArray *array;
    if (_seekTextField.text.length > 0) {
        array = _searchArray;
    }else {
        array = _wh_array;
    }
    WH_JXMsgAndUserObject *p=[array objectAtIndex:sender.tag];
    if ([p.user.userId intValue] == 10005) {
        return;
    }
    if([p.user.userId isEqualToString:FRIEND_CENTER_USERID] || [p.user.userId isEqualToString:CALL_CENTER_USERID] || [p.user.userId isEqualToString:WAHU_TRANSFER])
        return;
    if([p.user.roomFlag boolValue] || p.user.roomId.length > 0) {
        NSString *s;
        switch ([p.user.groupStatus intValue]) {
            case 0:
                s = nil;
                break;
            case 1:
                s = Localized(@"JX_OutOfTheGroup1");
                break;
            case 2:
                s = Localized(@"JX_DissolutionGroup1");
                break;
                
            default:
                break;
        }
        
        if (s.length > 0) {
            [g_server showMsg:s];
        }else {
            
            WH_JXRoomMember_WHVC* vc = [WH_JXRoomMember_WHVC alloc];
//            vc.chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:roomdata.roomJid title:roomdata.name isNew:NO];
//            WH_RoomData * roomdata;
//            if([p.user.roomFlag intValue] > 0 || p.user.roomId.length > 0){
//                
//                
//                if (p.user.roomFlag || p.user.roomId.length > 0) {
//                    NSDictionary * groupDict = [p.user toDictionary];
//                    roomdata = [[WH_RoomData alloc] init];
//                    [roomdata WH_getDataFromDict:groupDict];
//                    
//                }
//                
//            }
//            vc.wh_room      = roomdata;
            vc.pData = p;
            vc.wh_roomId = p.user.roomId;
            vc.wh_rowIndex = (int)sender.tag;
            vc = [vc init];
            //        [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
//            [g_server getRoom:p.user.roomId toView:self];
        }
    }else {
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_userId       = p.user.userId;
        vc.wh_fromAddType = 6;
        vc.isAddFriend = p.user.isAddFirend;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        [self WH_cancelBtnAction];
//        [g_server getUser:p.user.userId toView:self];
    }
    p = nil;
}

-(void)getTotalNewMsgCount{
    int n = 0;
    for (WH_JXMsgAndUserObject * dict in _wh_array) {
        if (![dict.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
            n += [dict.user.msgsNew intValue];
//            NSLog(@"新消息=%d",[dict.user.msgsNew intValue]);
        }
    }
    self.wh_msgTotal =  n;
    [UIApplication sharedApplication].applicationIconBadgeNumber = n;
    if (g_xmpp.isLogined) {
        [g_server WH_userChangeMsgNum:[UIApplication sharedApplication].applicationIconBadgeNumber toView:self];
    }
}

- (void)chatViewDisappear:(NSNotification *)notif{
//    [_table reloadData];
//    [self getTotalNewMsgCount];
    [self WH_getServerData];
}

-(void)logoutNotifi:(NSNotification *)notif{
    [_wh_array removeAllObjects];
    [_table reloadData];
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
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if ([aDownload.action isEqualToString:wh_act_roomListHis]) {
        NSDictionary *infoDict = [g_default objectForKey:@"shareInfo"];
        self.invPeoRoomId = [infoDict objectForKey:@"roomId"]?:@"";
        self.invitePeopleId = [infoDict objectForKey:@"userId"]?:@"";
        self.invPeoNickName = [infoDict objectForKey:@"nickName"]?:@"";
        
        [g_default removeObjectForKey:@"shareInfo"];
        
        Boolean isHadThisGroup = NO;
        for (int i = 0; i < [array1 count]; i++) {
            NSDictionary *dict = array1[i];
            
            if (self.invPeoRoomId.length > 0 && [[dict objectForKey:@"id"] isEqualToString:self.invPeoRoomId]) {
                isHadThisGroup = YES;
            }
        }
        
        if (isHadThisGroup) {
            //有该群组
            
            self.sharePushType = 1;
            [g_server getRoom:self.invPeoRoomId toView:self];
            
        }else{
            //没有该群
//            self.sharePushType = 2;
            //                [g_server getRoom:self.invPeoRoomId toView:self];
            
            for (int i = 0; i < array1.count; i++) {
                NSDictionary *dicts = [array1 objectAtIndex:i];
                WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
                [user WH_getDataFromDict:dicts];
                
                NSDictionary * groupDict = [user toDictionary];
                WH_RoomData * roomdata = [[WH_RoomData alloc] init];
                [roomdata WH_getDataFromDict:groupDict];
                
                [roomdata WH_getDataFromDict:dicts];
                
                self.invPeoRoom = roomdata;
                
                memberData *data = [roomdata getMember:self.invitePeopleId];
                BOOL flag = [data.role intValue] == 1 || [data.role intValue] == 2;
                ////角色 1创建者,2管理员,3成员,4隐身人,5监控人
                if (!flag && !roomdata.allowInviteFriend) {
                    [g_App showAlert:Localized(@"JX_DisabledInviteFriends")];
                    return;
                }
                if([data.role intValue] == 4) {
                    [g_App showAlert:Localized(@"JX_InvisibleCan'tInviteMembers")];
                    return;
                }
            }
            
            [g_server WH_addRoomMemberWithRoomId:self.invPeoRoomId  userArray:@[g_myself.userId] toView:self];
        }
    }
    
    if ([aDownload.action isEqualToString:wh_act_roomMemberSet]) {
        if (self.invPeoRoom.isNeedVerify) {
            // 邀请进群是否需要验证，1：需要  0：不需要  默认不需要
            WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
            vc.delegate = self;
            vc.didTouch = @selector(onInputHello:);
            vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
            vc.titleColor = [UIColor lightGrayColor];
            vc.titleFont = [UIFont systemFontOfSize:13.0];
            vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
            //        vc.inputText = Localized(@"JXNewFriendVC_Iam");
            vc = [vc init];
            [g_window addSubview:vc.view];
        }else{
//            self.sharePushType = 2;
//            [g_server getRoom:self.invPeoRoomId toView:self];
            [self showChatView];
            self.isWeChatJoinGroup = NO;
        }
    }

    if( [aDownload.action isEqualToString:wh_act_roomGet] ){
        if (self.isWeChatJoinGroup) {

            [g_default removeObjectForKey:@"shareInfo"];
            _dataDict = dict;
            
            if(g_xmpp.isLogined != 1){
                // 掉线后点击title重连
                // 判断XMPP是否在线  不在线重连
                [g_xmpp showXmppOfflineAlert];
                return;
            }
            NSDictionary * dict = _dataDict;
            
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:dict];
            if (roomdata.isNeedVerify) {
                NSLog(@"+++++111");//kai
            }else{
                NSLog(@"+++++222");//guan
                _chatRoom = [g_xmpp.roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
            }
            
            
            WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:[dict objectForKey:@"jid"]];
            if(user && [user.groupStatus intValue] == 0){
                //老房间:
                _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
                //老房间:
                [self showChatView];
                
            }else{
                
                //
                //            _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
                BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
                long userId = [dict[@"userId"] longLongValue];
                if (isNeedVerify && userId != [g_myself.userId longLongValue]) {
                    
                    self.roomJid = [dict objectForKey:@"jid"];
                    self.roomUserName = [dict objectForKey:@"nickname"];
                    self.roomUserId = [dict objectForKey:@"userId"];
                    
#pragma mark 进群验证
                    //                WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:@"扫码进群验证" content:Localized(@"JX_GroupOwnersHaveEnabled") isEdit:NO isLimit:NO];
                    //                [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
                    
                    WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 289) title:@"扫码进群验证" promptContent:Localized(@"JX_GroupOwnersHaveEnabled") content:@"" isEdit:YES isLimit:NO];
                    //                [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
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
                            
                            WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
                            msg.fromUserId = MY_USER_ID;
                            msg.toUserId = [NSString stringWithFormat:@"%@", self.roomUserId];
                            msg.fromUserName = MY_USER_NAME;
                            msg.toUserName = self.roomUserName;
                            msg.timeSend = [NSDate date];
                            msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
                            NSString *userIds = g_myself.userId;
                            NSString *userNames = g_myself.userNickname;
                            NSDictionary *dict = @{
                                                   @"userIds" : userIds,
                                                   @"userNames" : userNames,
                                                   @"roomJid" : weakSelf.roomJid,
                                                   @"reason" : content,
                                                   @"isInvite" : [NSNumber numberWithBool:YES]
                                                   };
                            NSError *error = nil;
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
                            
                            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            msg.objectId = jsonStr;
                            [g_xmpp sendMessage:msg roomName:nil];
                            
                            msg.fromUserId = weakSelf.roomJid;
                            msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                            msg.content = Localized(@"JX_WaitGroupConfirm");
                            [msg insert:weakSelf.roomJid];
                            [GKMessageTool showText:@"群聊邀请已发送给群主！"];
                            
                            weakSelf.isWeChatJoinGroup = NO;
                        }
                    }];
                    
                    //
                    //                WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
                    //                vc.delegate = self;
                    //                vc.didTouch = @selector(onInputHello:);
                    //                vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
                    //                vc.titleColor = [UIColor lightGrayColor];
                    //                vc.titleFont = [UIFont systemFontOfSize:13.0];
                    //                vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
                    //                vc = [vc init];
                    //                [g_window addSubview:vc.view];
                }else {
                    
                    [_wait start:Localized(@"JXAlert_AddRoomIng") delay:30];
                    //新房间:
                    _chatRoom.delegate = self;
                    [_chatRoom joinRoom:YES];
                }
            }
            
            return;
            
        }
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        NSDictionary * groupDict = [user toDictionary];
        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
        [roomdata WH_getDataFromDict:groupDict];
        
        [roomdata WH_getDataFromDict:dict];
        
        if (self.sharePushType == 1) {
            WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
            //                sendView.scrollLine = 0;
            sendView.title = roomdata.name?:@"";
            sendView.chatPerson = user;
            sendView.roomJid = roomdata.roomJid;
            sendView.room = roomdata;
            sendView.roomId = roomdata.roomId;
            sendView.isQRCodePush = YES;
            
            WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:roomdata.roomJid];
            sendView.chatPerson = user;
            sendView = [sendView init];
            [g_navigation pushViewController:sendView animated:YES];
            
            [g_notify postNotificationName:kRoomMembersRefresh_WHNotification object:[NSNumber numberWithInt:[dict[@"userSize"] intValue]]];
            return;
        }else if(self.sharePushType == 2){
            //分享进群(群不需要验证)
            memberData *memberD  = [[memberData alloc] init];
            memberD.roomId = self.room.roomId;
            [memberD deleteRoomMemeber];
            
            self.noticeArr = [dict objectForKey:@"notices"];
            WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
            [user WH_getDataFromDict:dict];
            
            NSDictionary * groupDict = [user toDictionary];
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:groupDict];
            
            [roomdata WH_getDataFromDict:dict];
            
            self.chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:roomdata.roomJid title:roomdata.name isNew:NO];
            self.room       = roomdata;
            
            WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
            //                sendView.scrollLine = 0;
            sendView.title = roomdata.name?:@"";
            sendView.chatPerson = user;
            sendView.roomJid = roomdata.roomJid;
            sendView.room = roomdata;
            sendView.roomId = roomdata.roomId;
            sendView.isQRCodePush = YES;
            sendView = [sendView init];
            [g_navigation pushViewController:sendView animated:YES];
            
            [g_notify postNotificationName:kRoomMembersRefresh_WHNotification object:[NSNumber numberWithInt:[dict[@"userSize"] intValue]]];
            
            return;
        }else{
            WH_JXRoomMember_WHVC* vc = [WH_JXRoomMember_WHVC alloc];
            vc.wh_chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:roomdata.roomJid title:roomdata.name isNew:NO];
            vc.wh_room       = roomdata;
            vc = [vc init];
            //        [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
        }
    }
    
    //点击好友头像响应
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        [user updateUserType];
        [g_notify postNotificationName:kFriendListRefresh_WHNotification object:nil];
        
        //        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        //        vc.user       = user;
        //        vc = [vc init];
        ////        [g_window addSubview:vc.view];
        //        [g_navigation pushViewController:vc animated:YES];
        //        [self WH_cancelBtnAction];
    }
    
    if ([aDownload.action isEqualToString:wh_act_roomGetRoom]) {
        
        if ([dict objectForKey:@"jid"]) {
            
            if (![dict objectForKey:@"member"]) {
                [g_server showMsg:Localized(@"JX_YouOutOfGroup")];
            }else {
                int talkTime = [[dict objectForKey:@"talkTime"] intValue];
                if (talkTime > 0) {
                    int role = [[[dict objectForKey:@"member"] objectForKey:@"role"] intValue];
                    if (role == 1 || role == 2) {
                        [self showReplayView];
                    }else {
                        [g_App showAlert:Localized(@"JX_TotalSilence")];
                    }
                }else {
                    [g_server WH_getRoomMemberWithRoomId:self.replayRoomId userId:[g_myself.userId intValue] toView:self];
                }
            }
        }else {
            [g_server showMsg:Localized(@"JX_DissolutionGroup1")];
        }
        
    }
    if( [aDownload.action isEqualToString:wh_act_roomMemberGet] ){
        long long disableSay = [[dict objectForKey:@"talkTime"] longLongValue];
        if ([[NSDate date] timeIntervalSince1970] < disableSay) {
            [g_App showAlert:Localized(@"HAS_BEEN_BANNED")];
        }else {
            [self showReplayView];
        }
    }

    if ([aDownload.action isEqualToString:wh_act_tigaseGetLastChatList]) {
        
        [[WH_JXUserObject sharedUserInstance] WH_updateUserLastChatList:array1];
        if (array1.count > 0) {
            [self WH_getServerData];
        }
        
        [_taskArray removeAllObjects];
        // 获取到群组本地最后一条消息
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            if ([[dict objectForKey:@"isRoom"] intValue] == 1) {
                // 获取最近一条记录
                NSArray *arr = [[WH_JXMessageObject sharedInstance] fetchMessageListWithUser:[dict objectForKey:@"jid"] byAllNum:0 pageCount:20 startTime:[NSDate dateWithTimeIntervalSince1970:0]];
                WH_JXMessageObject *lastMsg = nil;
                for (NSInteger i = 0; i < arr.count; i ++) {
                    WH_JXMessageObject *firstMsg = arr[i];
                    if ([firstMsg.type integerValue] != kWCMessageTypeRemind) {
                        lastMsg = firstMsg;
                        break;
                    }
                }
                if (!lastMsg) {
                    continue;
                }
                WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:dict[@"jid"]];
                NSMutableDictionary *taskDic = [NSMutableDictionary dictionary];
                [taskDic setObject:[dict objectForKey:@"jid"] forKey:@"userId"];
                [taskDic setObject:[NSDate dateWithTimeIntervalSince1970:[dict[@"timeSend"] longLongValue]] forKey:@"lastTime"];
                if (lastMsg) {
                    if (lastMsg.timeSend) {
                        [taskDic setObject:lastMsg.timeSend forKey:@"startTime"];
                    }
                    
                    if (lastMsg.messageId) {
                        [taskDic setObject:lastMsg.messageId forKey:@"startMsgId"];
                    }
                    
                }
                if (user.roomId) {
                    [taskDic setObject:user.roomId forKey:@"roomId"];
                }
                
                [_taskArray addObject:taskDic];
            }
        }
        
        [g_xmpp.roomPool createAll];
    }
    
    //删除会话接口调用成功后调用删除聊天记录接口
    if ([aDownload.action isEqualToString:act_deleteOneLastChat]) {
        
        
        
    }
}

-(void)showChatView{
    [_wait stop];
    NSDictionary * dict = _dataDict;
    
    WH_RoomData * roomdata = [[WH_RoomData alloc] init];
    [roomdata WH_getDataFromDict:dict];
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    sendView.title = [dict objectForKey:@"name"];
    sendView.roomJid = [dict objectForKey:@"jid"];
    sendView.roomId = [dict objectForKey:@"id"];
    sendView.chatRoom = _chatRoom;
    sendView.room = roomdata;
    
    WH_JXUserObject * userObj = [[WH_JXUserObject alloc]init];
    userObj.userId = [dict objectForKey:@"jid"];
    userObj.showRead = [dict objectForKey:@"showRead"];
    userObj.userNickname = [dict objectForKey:@"name"];
    userObj.showMember = [dict objectForKey:@"showMember"];
    userObj.allowSendCard = [dict objectForKey:@"allowSendCard"];
    userObj.chatRecordTimeOut = roomdata.chatRecordTimeOut;
    userObj.talkTime = [dict objectForKey:@"talkTime"];
    userObj.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
    userObj.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
    userObj.allowConference = [dict objectForKey:@"allowConference"];
    userObj.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
    
    sendView.chatPerson = userObj;
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    
    dict = nil;
}


#pragma mark - kvo的回调方法(系统提供的回调方法)
//keyPath:属性名称
//object:被观察的对象
//change:变化前后的值都存储在change字典中
//context:注册观察者的时候,context传递过来的值
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    id oldName = [change objectForKey:NSKeyValueChangeOldKey];
    NSLog(@"oldName----------%@",oldName);
    id newName = [change objectForKey:NSKeyValueChangeNewKey];
    NSLog(@"newName-----------%@",newName);
    
    
    if ([newName integerValue] == 1) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary * dict = _dataDict;
        
//        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
//        [roomdata WH_getDataFromDict:dict];
//        if (roomdata.isNeedVerify) {
//            NSLog(@"+++++111");//kai
//        }else{
//            NSLog(@"+++++222");//guan
//            _chatRoom = [g_xmpp.roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
//        }
        
        
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:[dict objectForKey:@"jid"]];
        if(user && [user.groupStatus intValue] == 0){
            //老房间:
            _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
            //老房间:
            [self showChatView];
            
        }else{
            
            BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
            long userId = [dict[@"userId"] longLongValue];
            if (isNeedVerify && userId != [g_myself.userId longLongValue]) {
                
                self.roomJid = [dict objectForKey:@"jid"];
                self.roomUserName = [dict objectForKey:@"nickname"];
                self.roomUserId = [dict objectForKey:@"userId"];
                
#pragma mark 进群验证
                //                WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:@"扫码进群验证" content:Localized(@"JX_GroupOwnersHaveEnabled") isEdit:NO isLimit:NO];
                //                [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
                
                WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 289) title:@"扫码进群验证" promptContent:Localized(@"JX_GroupOwnersHaveEnabled") content:@"" isEdit:YES isLimit:NO];
                //                [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
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
                        
                        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
                        msg.fromUserId = MY_USER_ID;
                        msg.toUserId = [NSString stringWithFormat:@"%@", self.roomUserId];
                        msg.fromUserName = MY_USER_NAME;
                        msg.toUserName = self.roomUserName;
                        msg.timeSend = [NSDate date];
                        msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
                        NSString *userIds = g_myself.userId;
                        NSString *userNames = g_myself.userNickname;
                        NSDictionary *dict = @{
                                               @"userIds" : userIds,
                                               @"userNames" : userNames,
                                               @"roomJid" : weakSelf.roomJid,
                                               @"reason" : content,
                                               @"isInvite" : [NSNumber numberWithBool:YES]
                                               };
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
                        
                        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        msg.objectId = jsonStr;
                        [g_xmpp sendMessage:msg roomName:nil];
                        
                        msg.fromUserId = weakSelf.roomJid;
                        msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                        msg.content = Localized(@"JX_WaitGroupConfirm");
                        [msg insert:weakSelf.roomJid];
                        [GKMessageTool showText:@"群聊邀请已发送给群主！"];
                        
                        weakSelf.isWeChatJoinGroup = NO;
                    }
                }];
                
                //
                //                WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
                //                vc.delegate = self;
                //                vc.didTouch = @selector(onInputHello:);
                //                vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
                //                vc.titleColor = [UIColor lightGrayColor];
                //                vc.titleFont = [UIFont systemFontOfSize:13.0];
                //                vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
                //                vc = [vc init];
                //                [g_window addSubview:vc.view];
            }else {
                _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
                [_wait start:Localized(@"JXAlert_AddRoomIng") delay:30];
                //新房间:
                _chatRoom.delegate = self;
                [_chatRoom joinRoom:YES];
            }
        }
        
        //当界面要消失的时候,移除kvo
        [g_xmpp removeObserver:self forKeyPath:@"isLogined"];

    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WaHuFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    if ([aDownload.action isEqualToString:wh_act_tigaseGetLastChatList]) {
        
        [g_xmpp.roomPool createAll];
    }

    if (![aDownload.action isEqualToString:wh_act_userChangeMsgNum] && ![aDownload.action isEqualToString:wh_act_tigaseGetLastChatList]) {
        return WH_show_error;
    }
    
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];

    if (![aDownload.action isEqualToString:wh_act_userChangeMsgNum] && ![aDownload.action isEqualToString:wh_act_tigaseGetLastChatList] && ![aDownload.action isEqualToString:act_deleteOneLastChat]) {
        return WH_show_error;
    }
    
    
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    if (![aDownload.action isEqualToString:wh_act_userChangeMsgNum] && ![aDownload.action isEqualToString:wh_act_roomMemberGet] && ![aDownload.action isEqualToString:wh_act_roomGetRoom] && ![aDownload.action isEqualToString:act_deleteOneLastChat]) {
        [_wait start];
    }
}

-(void)onInputHello:(WH_JXInput_WHVC*)sender{
    
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.fromUserId = self.invitePeopleId;
    msg.toUserId = [NSString stringWithFormat:@"%ld", self.invPeoRoom.userId];
    msg.fromUserName = self.invPeoNickName;
    msg.toUserName = self.invPeoRoom.userNickName;
    msg.timeSend = [NSDate date];
    msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    //    NSString *userIds = [self.selFriendUserIds componentsJoinedByString:@","];
    //    NSString *userNames = [self.selFriendUserNames componentsJoinedByString:@","];
    NSDictionary *dict = @{
                           @"userIds" : MY_USER_ID,
                           @"userNames" : MY_USER_NAME,
                           @"roomJid" : self.invPeoRoom.roomJid,
                           @"reason" : sender.inputText,
                           @"isInvite" : [NSNumber numberWithBool:NO]
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    msg.objectId = jsonStr;
    [g_xmpp sendMessage:msg roomName:nil];
    
    msg.fromUserId = self.invPeoRoom.roomJid;
    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
    msg.content = Localized(@"JX_WaitGroupConfirm");
    [msg insert:self.invPeoRoom.roomJid];
    //    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
    //        [self.delegate needVerify:msg];
    //    }
}

-(void)onDrag:(UIView*)sender{
    
    sender.hidden = YES;
}

-(void)onReceiveRoomRemind:(NSNotification *)notifacation//
{
    WH_JXRoomRemind* p     = (WH_JXRoomRemind *)notifacation.object;
    WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];//如果能查到，说明是群组，否则是直播间
    
    BOOL bRefresh=NO;
    if([p.type intValue] == kRoomRemind_RoomName){
        if(!user)
            return;
        user.userNickname  = p.content;
        [user update];
        
        for(int i=0;i<[_wh_array count];i++){
            WH_JXMsgAndUserObject* room=[_wh_array objectAtIndex:i];
            if([room.user.userId isEqualToString:p.objectId]){
                room.user.userNickname = p.content;
                bRefresh = YES;
                break;
            }
            room = nil;
        }
    }
    if([p.type intValue] == kRoomRemind_NickName){
        memberData *data = [[memberData alloc] init];
        data.roomId = user.roomId;
        data.userNickName = p.content;
        data.userId = [p.toUserId longLongValue];
        [data WH_updateUserNickname];
    }
    
    //群签到开启或关闭
    if ([p.type integerValue] == kRoomRemind_GroupSignIn) {
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.isGroupSignIn = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.isGroupSignIn = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    
    if([p.type intValue] == kRoomRemind_DelMember){
        if(!user)
            return;
        if([p.toUserId rangeOfString:MY_USER_ID].location != NSNotFound){
            if ([p.fromUserId isEqualToString:MY_USER_ID]) {
                [WH_JXUserObject deleteUserAndMsg:user.userId];
            }
            user.groupStatus = [NSNumber numberWithInt:1];
            [user WH_updateGroupInvalid];
            for (WH_JXMsgAndUserObject *obj in _wh_array) {
                if ([obj.user.userId isEqualToString:user.userId]) {
                    obj.user.groupStatus = [NSNumber numberWithInt:1];
                    break;
                }
            }
            [g_xmpp.roomPool delRoom:user.userId];
        }else{
//            [[WH_JXMessageObject sharedInstance] deleteWithFromUser:p.toUserId roomId:user.userId];
            
            WH_JXMsgAndUserObject *userObj = nil;
            for (WH_JXMsgAndUserObject *obj in _wh_array) {
                if ([obj.user.userId isEqualToString:user.userId]) {
                    userObj = obj;
                    memberData* member = [[memberData alloc] init];
                    member.userId = [p.toUserId intValue];
                    member.userNickName = p.toUserName;
                    member.roomId = user.roomId;
                    [member remove];
                    
                    NSDictionary * groupDict = [user toDictionary];
                    WH_RoomData * roomdata = [[WH_RoomData alloc] init];
                    [roomdata WH_getDataFromDict:groupDict];
                    roomdata.roomId = user.roomId;
                    roomdata.members = roomdata.members;
                    break;
                }
            }
//            if ([p.fromUserId isEqualToString:MY_USER_ID]) {
//                [userObj.user delete];
//                [_array removeObject:userObj];
//                [_table reloadData];
//            }
            
        }
    }

    if([p.type intValue] == kRoomRemind_AddMember){
        if([p.toUserId isEqualToString:MY_USER_ID]){
            if(![g_xmpp.roomPool getRoom:p.objectId]){
                WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
                user.userNickname = p.content;
                user.userId = p.objectId;
                user.userDescription = p.content;
                user.roomId = p.roomId;
//                user.showRead = p.fileSize;
                NSDictionary *resultObject = [p.other mj_JSONObject];
                user.showMember = resultObject[@"showMember"];
                user.allowSendCard = resultObject[@"allowSendCard"];
                user.showRead = resultObject[@"showRead"];
                user.talkTime = resultObject[@"talkTime"];
                user.allowInviteFriend = resultObject[@"allowInviteFriend"];
                user.allowUploadFile = resultObject[@"allowUploadFile"];
                user.allowConference = resultObject[@"allowConference"];
                user.allowSpeakCourse = resultObject[@"allowSpeakCourse"];
                user.chatRecordTimeOut = resultObject[@"chatRecordTimeOut"];
                
                [user insertRoom];
                [g_xmpp.roomPool joinRoom:user.userId title:user.userNickname isNew:NO];
                bRefresh = YES;
                
            }
        }
        
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        user.userId = p.objectId;
        user.groupStatus = [NSNumber numberWithInt:0];
        [user WH_updateGroupInvalid];
        for (WH_JXMsgAndUserObject *obj in _wh_array) {
            if ([obj.user.userId isEqualToString:user.userId]) {
                obj.user.groupStatus = [NSNumber numberWithInt:0];
                break;
            }
        }
        
        for (WH_JXMsgAndUserObject *obj in _wh_array) {
            if ([obj.user.userId isEqualToString:user.userId]) {
                
                memberData* member = [[memberData alloc] init];
                member.userId = [p.toUserId intValue];
                member.userNickName = p.toUserName;
                member.roomId = p.roomId;
                [member insert];
                
                NSDictionary * groupDict = [obj.user toDictionary];
                WH_RoomData * roomdata = [[WH_RoomData alloc] init];
                [roomdata WH_getDataFromDict:groupDict];
                roomdata.roomId = obj.user.roomId;
                roomdata.members = roomdata.members;
                break;
            }
        }
        
        if ([p.fromUserId isEqualToString:MY_USER_ID]) {
            self.roomRemind = p;
            WH_JXRoomObject *chatRoom = [g_xmpp.roomPool joinRoom:p.objectId title:p.content isNew:YES];
            chatRoom.delegate = self;
            [chatRoom joinRoom:YES];
        }
        
        [self WH_getServerData];
    }
 
    if([p.type intValue] == kRoomRemind_DelRoom){
        if(!user)
            return;
        //        [WH_JXUserObject deleteUserAndMsg:user.userId];
        user.groupStatus = [NSNumber numberWithInt:2];
        [user WH_updateGroupInvalid];
        
        WH_JXMsgAndUserObject *userObj = nil;
        for (WH_JXMsgAndUserObject *obj in _wh_array) {
            if ([obj.user.userId isEqualToString:user.userId]) {
                userObj = obj;
                obj.user.groupStatus = [NSNumber numberWithInt:2];
                break;
            }
        }
        if ([p.fromUserId isEqualToString:MY_USER_ID]) {
            [userObj.user delete];
            [_wh_array removeObject:userObj];
            [_table reloadData];
        }
        [g_xmpp.roomPool delRoom:user.userId];
    }

    if([p.type intValue] == kRoomRemind_ShowRead){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.showRead = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.showRead = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    if ([p.type integerValue] == kRoomRemind_GroupSignIn) {
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.isGroupSignIn = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.isGroupSignIn = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    
    if([p.type intValue] == kRoomRemind_ShowMember){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.showMember = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.showMember = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    
    if([p.type intValue] == kRoomRemind_allowSendCard){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.allowSendCard = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.allowSendCard = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    
    if ([p.type intValue] == kRoomRemind_SetManage) {
        //设置群组管理员
        
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
        
        NSDictionary * groupDict = [user toDictionary];
        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
        [roomdata WH_getDataFromDict:groupDict];
        NSArray * allMem = [memberData fetchAllMembers:user.roomId];
        roomdata.members = [allMem mutableCopy];
        
        memberData *member = [roomdata getMember:p.toUserId];
        if ([member.role intValue] == 2) {
            member.role = [NSNumber numberWithInt:3];
        }else {
            member.role = [NSNumber numberWithInt:2];
        }
        [member update];
    }
    
    if([p.type intValue] == kRoomRemind_RoomAllBanned){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.talkTime = [NSNumber numberWithLong:[p.content longLongValue]];
                [obj.user WH_updateGroupTalkTime];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.talkTime = [NSNumber numberWithLong:[p.content longLongValue]];
            [user WH_updateGroupTalkTime];
        }
    }
    if([p.type intValue] == kRoomRemind_RoomAllowInviteFriend){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.allowInviteFriend = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.allowSendCard = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    if([p.type intValue] == kRoomRemind_RoomAllowUploadFile){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.allowUploadFile = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.allowUploadFile = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    if([p.type intValue] == kRoomRemind_RoomAllowConference){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.allowConference = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.allowConference = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    if([p.type intValue] == kRoomRemind_RoomAllowSpeakCourse){
        BOOL bFound=NO;
        WH_JXMsgAndUserObject *obj=nil;
        for(int i=0;i<[_wh_array count];i++){
            obj=[_wh_array objectAtIndex:i];
            if([obj.user.userId isEqualToString:p.objectId]){
                obj.user.allowSpeakCourse = [NSNumber numberWithInt:[p.content intValue]];
                [obj.user update];
                bFound = YES;
                break;
            }
        }
        if(!bFound){
            WH_JXUserObject* user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            user.allowSpeakCourse = [NSNumber numberWithInt:[p.content intValue]];
            [user update];
        }
    }
    
    if ([p.type intValue] == kRoomRemind_RoomTransfer) {
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
        memberData *data = [[memberData alloc] init];
        data.userId = [p.fromUserId longLongValue];
        data.roomId = user.roomId;
        data.role = [NSNumber numberWithInt:3];
        [data updateRole];
        
        data = [[memberData alloc] init];
        data.userId = [p.toUserId longLongValue];
        data.roomId = user.roomId;
        data.role = [NSNumber numberWithInt:1];
        [data updateRole];
    }
    
    if ([p.type intValue] == kRoomRemind_SetRecordTimeOut) {
        
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
        user.chatRecordTimeOut = p.content;
        [user WH_updateUserChatRecordTimeOut];
    }
    
    if(bRefresh){
        _refreshCount++;
        [_table reloadData];
        [self getTotalNewMsgCount];
    }
    p = nil;
}

-(void)xmppRoomDidJoin:(XMPPRoom *)sender{

    if (self.isWeChatJoinGroup) {
        NSDictionary * dict = _dataDict;
        
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        user.userNickname = [dict objectForKey:@"name"];
        user.userId = [dict objectForKey:@"jid"];
        user.userDescription = [dict objectForKey:@"desc"];
        user.roomId = [dict objectForKey:@"id"];
        user.showRead = [dict objectForKey:@"showRead"];
        user.showMember = [dict objectForKey:@"showMember"];
        user.allowSendCard = [dict objectForKey:@"allowSendCard"];
        user.chatRecordTimeOut = [dict objectForKey:@"chatRecordTimeOut"];
        user.talkTime = [dict objectForKey:@"talkTime"];
        user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
        user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
        user.allowConference = [dict objectForKey:@"allowConference"];
        user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
        
        if (![user haveTheUser])
            [user insertRoom];
        //    else
        //        [user update];
        //    [user release];
        
        [g_server WH_addRoomMemberWithRoomId:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
        
        dict = nil;
        _chatRoom.delegate = nil;
        
        return;
    }
    
    
    WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
    user.userNickname = self.roomRemind.content;
    user.userId = self.roomRemind.objectId;
    user.userDescription = nil;
    user.roomId = self.roomRemind.roomId;
    NSDictionary *resultObject = [self.roomRemind.other mj_JSONObject];
    user.showRead = [resultObject objectForKey:@"showRead"];
    user.showMember = [resultObject objectForKey:@"showMember"];
    user.allowSendCard = [resultObject objectForKey:@"allowSendCard"];
    user.talkTime = [resultObject objectForKey:@"talkTime"];
    user.allowInviteFriend = [resultObject objectForKey:@"allowInviteFriend"];
    user.allowUploadFile = [resultObject objectForKey:@"allowUploadFile"];
    user.allowConference = [resultObject objectForKey:@"allowConference"];
    user.allowSpeakCourse = [resultObject objectForKey:@"allowSpeakCourse"];
    user.chatRecordTimeOut = [resultObject objectForKey:@"chatRecordTimeOut"];
    
    if (![user haveTheUser])
        [user insertRoom];
//    else
//        [user update];

    
    
    
}

-(void)onQuitRoom:(NSNotification *)notifacation//超时未收到回执
{
    WH_JXRoomObject* p     = (WH_JXRoomObject *)notifacation.object;
    for(int i=0;i<[_wh_array count];i++){
        WH_JXMsgAndUserObject* room=[_wh_array objectAtIndex:i];
        if([room.user.userId isEqualToString:p.roomJid]){
            [_wh_array removeObjectAtIndex:i];
            _refreshCount++;
            [_table reloadData];
            [self getTotalNewMsgCount];
            break;
        }
        room = nil;
    }
    p = nil;
}

#pragma mark - 添加好友
-(void)onSearch{
    WH_AddFriend_WHController *vc = [[WH_AddFriend_WHController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
    
//    WH_JXSearchUser_WHVC* vc = [WH_JXSearchUser_WHVC alloc];
//    vc.delegate  = self;
//    vc.didSelect = @selector(doSearch:);
//    vc.type = JXSearchTypeUser;
////    [g_window addSubview:vc.view];
//    vc = [vc init];
//    [g_navigation pushViewController:vc animated:YES];
    
    [self WH_cancelBtnAction];
}
-(void)doSearch:(WH_SearchData*)p{

    WH_JXNear_WHVC *nearVC = [[WH_JXNear_WHVC alloc]init];
    nearVC.wh_isSearch = YES;
//    [g_window addSubview:nearVC.view];
    [g_navigation pushViewController:nearVC animated:YES];
//    nearVC.search = p;
//    nearVC.bNearOnly = NO;
//    nearVC.page = 0;;
//    nearVC.selMenu = 0;
//    [nearVC WH_getServerData];
    [nearVC doSearch:p];
}

-(void)allMsgCome{
    [self WH_getServerData];
}

-(void)showNewCount{//显示IM数量
    [g_mainVC.tb wh_setBadge:0 title:[NSString stringWithFormat:@"%d",self.wh_msgTotal]];
}

-(void)setWh_msgTotal:(int)n{
    if(n<0)
        n = 0;
    _wh_msgTotal = n;
    [self showNewCount];
}

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
    scanVC.delegate = self;
//    [g_window addSubview:scanVC.view];
    [g_navigation pushViewController:scanVC animated:YES];
}

- (void)needVerify:(WH_JXMessageObject *)msg {
    
}

- (void)resignKeyBoard {
    self.bigView.hidden = YES;
    [self hideKeyBoard];
    [self resetBigView];
}

- (void)resetBigView {
//    self.replayTextView.frame = CGRectMake(10, 64, self.baseView.frame.size.width - INSETS*2, 60);
//    self.replayTextView.frame.size.height = 60;
    self.baseView.frame = CGRectMake(20, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-40, baseViewHeight);
//    self.topView.frame = CGRectMake(0, 118, self.baseView.frame.size.width, 40);
    self.topView.frame = CGRectMake(0, CGRectGetHeight(self.baseView.frame) - 72 - g_factory.cardBorderWithd, self.baseView.frame.size.width, 72);
}

- (void)hideKeyBoard {
    if (self.replayTextView.isFirstResponder) {
        [self.replayTextView resignFirstResponder];
    }
}

-(UITextView*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextView* p = [[UITextView alloc] init];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
    [parent addSubview:p];
    return p;
}




- (void)sp_getMediaFailed {
    NSLog(@"Continue");
}
@end
