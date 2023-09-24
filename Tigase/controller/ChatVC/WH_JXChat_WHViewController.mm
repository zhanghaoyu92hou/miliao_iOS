//
//  WH_JXChat_WHViewController.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
// ？

#import "WH_JXChat_WHViewController.h"
#import "XMPPMessage.h"
#import "ChatCacheFileUtil.h"
#import "VoiceConverter.h"
#import "Photo.h"
#import "NSData+XMPP.h"
#import "AppDelegate.h"
#import "WH_JXEmoji.h"
#import "WH_FaceView_WHController.h"
#import "WH_Gif_GHViewController.h"
#import "emojiViewController.h"
#import "WH_SCGIFImageView.h"
//#import "WH_JXImageView.h"
#import "WH_JXSelectImageView.h"
#import "JXTableView.h"
#import "LXActionSheet.h"
#import "WH_VolumeView.h"
#import "WH_myMedia_WHVC.h"
#import "WH_JXMediaObject.h"
#import "FMDatabase.h"
#import "JXMyTools.h"
#if TAR_IM
#ifdef Meeting_Version
#import "WH_JXMeetingObject.h"
#import "AskCallViewController.h"
#import "JXAVCallViewController.h"
#endif
#endif
#ifdef Live_Version
#import "WH_JXLiveJid_WHManager.h"
#endif
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXRoomMember_WHVC.h"
#import "WH_JXRoomObject.h"
#import "WH_JXRoomRemind.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXMyFile.h"
#import "WH_JXShareFileObject.h"
#import "WH_JXFileDetail_WHViewController.h"

#import "JXMapData.h"
#import "WH_JXSendRedPacket_WHViewController.h"

#import "WH_JXredPacketDetail_WHVC.h"
#import "WH_JXOpenRedPacket_WHVC.h"
//添加VC转场动画
#import "DMScaleTransition.h"
//各种Cell
#import "WH_JXBaseChat_WHCell.h"
#import "WH_JXMessage_WHCell.h"
#import "WH_JXImage_WHCell.h"
#import "WH_ReadDelTimeCell.h"
#import "WH_JXFile_WHCell.h"
#import "WH_JXVideo_WHCell.h"
#import "WH_JXAudio_WHCell.h"
#import "WH_JXLocation_WHCell.h"
#import "WH_JXCard_WHCell.h"
#import "WH_JXRedPacket_WHCell.h"
#import "WH_JXRemind_WHCell.h"
#import "WH_JXGif_WHCell.h"
#import "WH_JXSystemImage1_WHCell.h"
#import "WH_JXSystemImage2_WHCell.h"
#import "WH_JXAVCall_WHCell.h"
#import "WH_JXLink_WHCell.h"
#import "WH_JXShake_WHCell.h"
#import "WH_JXMergeRelay_WHCell.h"
#import "WH_JXShare_WHCell.h"
#import "WH_JXTransfer_WHCell.h"
#import "WH_JXReply_WHCell.h"

#import "WH_EmojiTextAttachment.h"
#import "NSAttributedString+WH_EmojiExtension.h"

#import "WH_ImageBrowser_WHViewController.h"
#import "WH_JXRelay_WHVC.h"
#import "WH_webpage_WHVC.h"
#import "WH_JX_DownListView.h"
#import "WH_JXReadList_WHVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageView+WebCache.h"
#import "WH_JXCamera_WHVC.h"
#import "WH_JXChatSetting_WHVC.h"
#import "WH_JXVerifyDetail_WHVC.h"
#import "JXDevice.h"
#import "WH_JXChatLog_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "WH_JXMsg_WHViewController.h"
#import "WH_WeiboViewControlle.h"
#import "ObjUrlData.h"
#import "JXSynTask.h"
#import "JXGoogleMapVC.h"
#import "RITLPhotosViewController.h"
#import "RITLPhotosDataManager.h"
#import "WH_JXActionSheet_WHVC.h"
#import "WH_JXInput_WHVC.h"
#import "WH_JXRoomPool.h"
#import "WH_KKImageEditor_WHViewController.h"
#import "WH_JXTransfer_WHViewController.h"
#import "WH_JXTransferDeatil_WHVC.h"
#import "WH_JXSelectAddressBook_WHVC.h"
#import "WH_JXInputMoney_WHVC.h"
#import "WH_Collect_WHViewController.h"
#import "WH_JXAnnounce_WHViewController.h"

#import "OBSHanderTool.h"
#import "UITextView+WZB.h"
#import "RedPacketView.h"
//自定义表情相关
#import "WWAddEmoticonViewController.h"
#import "WWEmoticonManagerViewController.h"
#import "WH_RegisterViewController.h"
#import "UIView+WH_CustomAlertView.h"
#import "WH_CustomActionSheetView.h"

#import "ChatMoreButton.h"
#include <sys/types.h>
#include <sys/stat.h>
#import "NSString+ContainStr.h"
#import "YJCircleView.h"
#import "WH_JXCommonService.h"

#define faceHeight (THE_DEVICE_HAVE_HEAD ? 253 : 218)
#define PAGECOUNT 100
#define NOTICE_WIDTH  120  // 调整两条公告间的距离

//@人功能
#define kATFormat  @"@%@ "
#define kATRegular @"@[\\u4e00-\\u9fa5\\w\\-\\_]+ "


@interface WH_JXChat_WHViewController()<emojiViewControllerDelegate,FavoritesVCDelegate,JXChatCellDelegate,WH_JXRoomMember_WHVCDelegate,SendRedPacketVCDelegate,UIAlertViewDelegate,WH_JXRelay_WHVCDelegate,WH_JXCamera_WHVCDelegate,ImageBrowserVCDelegate,weiboVCDelegate,RITLPhotosViewControllerDelegate,WH_JXVideo_WHCellDelegate,WH_JXActionSheet_WHVCDelegate,UINavigationControllerDelegate,KKImageEditorDelegate,transferVCDelegate,WH_JXSelectAddressBook_WHVCDelegate ,collectVCDelegate,emojiViewControllerDelegate>{

    CGRect _lastFrame;
    UIView *_shakeBgView;
    ChatMoreButton *rightNaviBtn;
    WH_JXCommonService *commonService;
}
@property (nonatomic, assign) CGFloat deltaY;
@property (nonatomic, assign) CGFloat deltaHeight;
//@property (nonatomic, strong) DMAlphaTransition *alphaTransition;
@property (nonatomic, strong) DMScaleTransition *scaleTransition;
//@property (nonatomic, strong) DMSlideTransition *slideTransition;
@property (nonatomic,strong) NSArray  *allChatImageArr;//消息记录里所有图片
//@property (nonatomic,assign) BOOL     isReadDelete;
@property (nonatomic,assign) NSInteger     myReadDel;//自己

@property (nonatomic, copy) NSMutableString *sendText;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL loginStatus;
@property (nonatomic, strong) NSTimer *enteringTimer;
@property (nonatomic, strong) NSTimer *noEnteringTimer;
@property (nonatomic, assign) BOOL isSendEntering;
@property (nonatomic, assign) BOOL isGetServerMsg;
@property (nonatomic, assign) int serverMsgPage;
@property (nonatomic, strong) NSMutableArray * atMemberArray;

@property (nonatomic, copy) NSString *userNickName;
@property (nonatomic, assign) BOOL firstGetUser;
@property (nonatomic, assign) BOOL onlinestate;

@property (nonatomic, strong) UIView *publicMenuBar;
@property (nonatomic, strong) NSArray *menuList;
@property (nonatomic, assign) NSInteger selMenuIndex;

@property (nonatomic, assign) NSInteger withdrawIndex;

@property (nonatomic, strong) NSMutableArray *recordArray;
@property (nonatomic, copy) NSString *recordName;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSInteger recordStarNum;

@property (nonatomic, strong) ATMHud *chatWait;
@property (nonatomic, assign) int sendIndex;

@property (nonatomic, strong) JXLocationVC *locVC;
@property (nonatomic, strong) JXGoogleMapVC *gooMap;

@property (nonatomic, assign) int isBeenBlack;
@property (nonatomic, assign) int friendStatus;

@property (nonatomic, copy) NSString *meetingNo;
@property (nonatomic, assign) BOOL isAudioMeeting;

@property (nonatomic, assign) int groupMessagesIndex;

@property (nonatomic, strong) WH_JXMessageObject *shakeMsg;

@property (nonatomic, strong) UIView *screenShotView;
@property (nonatomic, strong) UIImageView *screenShotImageView;

@property (nonatomic, strong) UIImageView *backGroundImageView;

@property (nonatomic, assign) BOOL isSelectMore;
@property (nonatomic, strong) NSMutableArray *selectMoreArr;
@property (nonatomic, strong) UIView *selectMoreView;

@property (nonatomic, assign) int readDelNum;

@property (nonatomic, assign) BOOL isAdmin;

@property (nonatomic, strong) UIButton *shareMore;
@property (nonatomic, strong) UILabel *talkTimeLabel;

@property (nonatomic, strong) UIButton *jumpNewMsgBtn;

@property (nonatomic, strong) WeiboData *collectionData;

@property (nonatomic, strong) NSMutableArray *taskList; // 任务列表

@property (nonatomic, strong) NSArray *imgDataArr;

@property (nonatomic, assign) int indexNum;   // 消息重发传来的cell.tag

@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, assign) BOOL isMapMsg; // 发送的是不是地图消息
@property (nonatomic, strong) JXMapData *mapData;

@property (nonatomic, strong) NSString *objToMsg;// 回复谁的消息，存json数据
@property (nonatomic, strong) NSString *hisReplyMsg; // 回复历史水印

@property (nonatomic, copy) NSString *meetUrl;

@property (nonatomic, strong) UIView *shareView;

@property (nonatomic, strong) UIView *noticeView;
@property (nonatomic, strong) UIImageView *noticeImgV;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) UIView *showNoticeView;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) NSTimer *noticeTimer;
@property (nonatomic, strong) NSString *noticeStr;
@property (nonatomic, assign) CGFloat leftW;
@property (nonatomic, assign) CGFloat rightW;
@property (nonatomic, assign) CGFloat noticeStrW;
@property (nonatomic, assign) int noticeHeight;
@property (nonatomic, strong) UIButton *textViewBtn;

@property (nonatomic, assign) BOOL scrollBottom;
@property (nonatomic, assign) BOOL isGotoLast;
@property (nonatomic, assign) BOOL isSyncMsg;

@property (nonatomic, assign) BOOL isFirst; // 第一次调用GetRoom
@property (nonatomic, assign) BOOL isDisable;   // 群组是否禁用
@property (nonatomic, strong) UIImage *screenImage; // 记录一下屏幕快照

@property (nonatomic, strong) NSDictionary *redPacketDict;
@property (nonatomic, assign) BOOL isDidRedPacketRemind;

//群成员进度展示控件
@property (nonatomic, strong) YJCircleView *circularView;
@property (nonatomic, strong) NSTimer *changeTimer;

//@property (nonatomic ,strong) UIView *bottomView;//阅后即焚使用
//@property (nonatomic ,strong) UIImageView *clockImageV;
//@property (nonatomic, strong) UILabel *bottomTitleLb;
//@property (nonatomic ,strong) UIButton *settingBtn;

@end

@implementation WH_JXChat_WHViewController
@synthesize chatPerson,roomId,chatRoom;

#pragma mark -- 懒加载
- (NSMutableArray *)noticesArry {
    if (!_noticesArry) {
        _noticesArry = [NSMutableArray arrayWithCapacity:1];
    }
    return _noticesArry;
}

- (id)init
{
    self = [super init];
    if (self) {
        if (!_room) {
            _room = [[WH_RoomData alloc] init];
        }
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 48;
        if (self.isHiddenFooter) {
            self.wh_heightFooter = 0;
        }
        self.wh_isGotoBack   = YES;
        self.isGotoLast = YES;
        _orderRedPacketArray = [[NSMutableArray alloc]init];
        _atMemberArray = [[NSMutableArray alloc] init];
        _selectMoreArr = [NSMutableArray array];
        if (self.roomJid.length > 0) {
            _taskList = [[JXSynTask sharedInstance] getTaskWithUserId:self.roomJid];
        }
        if (self.newMsgCount > 100) {
            self.newMsgCount = 100;
        }
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.groupMessagesIndex = 0;
        _disableSay = 0;
        _serverMsgPage = 0;
        _isRecording = NO;
        _recordStarNum = 0;
        
        _pool     = [[NSMutableArray alloc]init];
        _array = [[NSMutableArray alloc]init];
        
        //有时间限制
        _myReadDel = [self.chatPerson.isOpenReadDel integerValue];

        _recordArray = [NSMutableArray array];
        _chatWait = [[ATMHud alloc] init];
        commonService = [[WH_JXCommonService alloc] init];
        if (current_chat_userId)
            [g_xmpp.chatingUserIds addObject:current_chat_userId];
        
    }
    [g_notify addObserver:self selector:@selector(audioPlayEnd:) name:kCellVoiceStartNotifaction object:nil];//开始录音
    [g_notify addObserver:self selector:@selector(cardCellClick:) name:kCellShowCardNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(locationCellClick:) name:kCellLocationNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(WH_onDidImage:) name:kCellImageNotifaction object:nil];//照片
    [g_notify addObserver:self selector:@selector(WH_onDidRedPacket:) name:kcellRedPacketDidTouchNotifaction object:nil];//普通红包点击
    [g_notify addObserver:self selector:@selector(WH_onDidTransfer:) name:kcellTransferDidTouchNotifaction object:nil];//转账点击
    [g_notify addObserver:self selector:@selector(WH_onDidHeadImage:) name:kCellHeadImageNotification object:nil];//点击头像
    [g_notify addObserver:self selector:@selector(WH_longGesHeadImageNotification:) name:kCellLongGesHeadImageNotification object:nil];//长按头像
    
    [g_notify addObserver:self selector:@selector(resendMsgNotif:) name:kCellResendMsgNotifaction object:nil];//重发消息
    [g_notify addObserver:self selector:@selector(deleteMsgNotif:) name:kCellDeleteMsgNotifaction object:nil];//删除消息
    [g_notify addObserver:self selector:@selector(showReadPersons:) name:kCellShowReadPersonsNotifaction object:nil];   // 查看已读列表
    [g_notify addObserver:self selector:@selector(hideKeyboard:) name:kHiddenKeyboardNotification object:nil];
    [g_notify addObserver:self selector:@selector(WH_onDidSystemImage1:) name:kCellSystemImage1DidTouchNotifaction object:nil];  // 单条图文消息点击
    [g_notify addObserver:self selector:@selector(WH_onDidSystemImage2:) name:kCellSystemImage2DidTouchNotifaction object:nil];  // 多条图文消息点击
    [g_notify addObserver:self selector:@selector(WH_onDidAVCall:) name:kCellSystemAVCallNotifaction object:nil];  // 音视频通话
    [g_notify addObserver:self selector:@selector(WH_onDidFile:) name:kCellSystemFileNotifaction object:nil];  // 文件点击
    [g_notify addObserver:self selector:@selector(WH_onDidLink:) name:kCellSystemLinkNotifaction object:nil];  // 链接点击
    [g_notify addObserver:self selector:@selector(WH_onDidShake:) name:kCellSystemShakeNotifaction object:nil];  // 戳一戳点击
    [g_notify addObserver:self selector:@selector(WH_onDidMergeRelay:) name:kCellSystemMergeRelayNotifaction object:nil];  // 合并转发点击
    [g_notify addObserver:self selector:@selector(onDidShare:) name:kCellShareNotification object:nil]; // 分享cell点击
    
    [g_notify addObserver:self selector:@selector(onDidRemind:) name:kCellRemindNotifaction object:nil];  // 控制消息点击
    [g_notify addObserver:self selector:@selector(onDidReply:) name:kCellReplyNotifaction object:nil];  // 回复消息点击
    [g_notify addObserver:self selector:@selector(onDidMessageReadDel:) name:kCellMessageReadDelNotifaction object:nil];  // 文本消息阅后即焚点击
    [g_notify addObserver:self selector:@selector(openReadDelNotif:) name:kOpenReadDelNotif object:nil];    // 阅后即焚开关
    [g_notify addObserver:self selector:@selector(refreshChatLogNotif:) name:kRefreshChatLogNotif object:nil];
    
    [g_notify addObserver:self selector:@selector(onLoginChanged:) name:kXmppLogin_WHNotifaction object:nil];
    // 监听系统截屏
    [g_notify addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];

    [g_notify addObserver:self selector:@selector(refreshGroupSign) name:WHGroupSignInState_WHNotification object:nil]; //群签到变化时 更新界面
    
    //消息同步监听
    [g_notify addObserver:self selector:@selector(chatVCMessageSync:) name:kChatVCMessageSync object:nil];
    
    [g_notify addObserver:self selector:@selector(updateReceivedYourTransfer) name:WHUpdateReceivedYourTransfer_WHNotification object:nil];
    
    [g_notify addObserver:self selector:@selector(transferOwner) name:kTransferOwner_WHNotifaction object:nil];
    
    NSLog(@"timetime6 -- %f", [[NSDate date] timeIntervalSince1970]);
    
    return self;
}
#pragma mark 刷新群签到
- (void)refreshGroupSign
{
    [g_server getRoom:self.room.roomId toView:self];
}

#pragma mark 收取转账后更新界面
- (void)updateReceivedYourTransfer {
    [self.tableView reloadData];
}

#pragma mark 转让群主成功后刷新界面数据
- (void)transferOwner {
    [g_server getRoom:self.room.roomId toView:self];
    [self createFooterSubViews];
}

#pragma mark - 用户截屏通知事件
- (void)userDidTakeScreenshot:(NSNotification *)notification {
    //如果当前界面存在阅后即焚消息，进行截屏操作，便会通知对方
    NSArray *allDelMsg = [[WH_JXMessageObject sharedInstance] fetchDelMessageWithUserId:self.chatPerson.userId];
    if (allDelMsg.count > 0) {
        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
        msg.type = [NSNumber numberWithInt:kWCMessageTypeDelMsgScreenshots];
        msg.timeSend = [NSDate date];
        msg.toUserId = self.chatPerson.userId;
        msg.fromUserId = MY_USER_ID;
        msg.content = Localized(@"JX_TheOtherTookAScreenshotOfTheConversation");
        [msg insert:nil];
        [g_xmpp sendMessage:msg roomName:nil];
    }
}

-(void)onLoginChanged:(NSNotification *)notifacation{
    
    switch ([JXXMPP sharedInstance].isLogined){
        case login_status_ing:{
        }
            break;
        case login_status_no:{
        }
            break;
        case login_status_yes:{
            if (self.roomJid.length > 0 && [self.groupStatus integerValue] == 0) {
                [g_xmpp.roomPool.pool removeObjectForKey:chatPerson.userId];
                [g_xmpp.roomPool joinRoom:chatPerson.userId title:chatPerson.userNickname isNew:NO];
                chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:chatPerson.userId title:chatPerson.userNickname isNew:NO];
            }
        }
            
            break;
    }
}

- (void)actionTitle:(JXLabel *)sender {
    if (self.isRecording) {
        [self chatCell:nil stopRecordIndexNum:(int)_array.count - 1];
    }
}

// 阅后即焚通知
- (void)openReadDelNotif:(NSNotification *)notif {

//    BOOL isOpen = [notif.object boolValue];
//    _isReadDelete = isOpen;
}

#pragma mark----阅后即焚开关
//- (void)switchValueChange:(UIButton *)but{
//
//    if (but.tag == 2000) {
//        but.tag = 1000;
//        but.selected = !but.selected;
//        _isReadDelete = !_isReadDelete;
//        if (_isReadDelete) {
//            but.backgroundColor = [UIColor lightGrayColor];
//            [g_App showAlert:Localized(@"JX_ReadDeleteTip")];
//        }else{
//            but.backgroundColor = [UIColor clearColor];
//        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            but.tag = 2000;
//        });
//    }
//}

// 重新加载
- (void)refreshChatLogNotif:(NSNotification *)notif {
    self.isGetServerMsg = NO;
    [_array removeAllObjects];
    [self refresh:nil loadHistory:YES];
    [self.tableView reloadData];
}

-(void)cardCellClick:(NSNotification *) notification{
    if (recording) {
        return;
    }
    WH_JXMessageObject *msg = notification.object;
    NSString * objectId = msg.objectId;
    self.firstGetUser = YES;
//    [g_server getUser:objectId toView:self];
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = objectId;
    vc.wh_isJustShow = self.courseId.length > 0;
    vc.wh_fromAddType = 2;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)locationCellClick:(NSNotification *)notification{
    if (recording) {
        return;
    }
    WH_JXMessageObject *msg = notification.object;
    double location_x = [msg.location_x doubleValue];
    double location_y = [msg.location_y doubleValue];
    
    JXMapData * mapData = [[JXMapData alloc] init];
    mapData.latitude = [NSString stringWithFormat:@"%f",location_x];
    mapData.longitude = [NSString stringWithFormat:@"%f",location_y];
    NSArray * locations = @[mapData];
    mapData.title = msg.objectId;
    BOOL isShowGoo = [g_myself.isUseGoogleMap intValue] > 0 ? YES : NO;
    if (isShowGoo) {
        _gooMap = [JXGoogleMapVC alloc] ;
        _gooMap.locations = [NSMutableArray arrayWithArray:locations];
        _gooMap.locationType = JXGooLocationTypeShowStaticLocation;
        _gooMap.placeNames = msg.objectId;
        _gooMap = [_gooMap init];
        [g_navigation pushViewController:_gooMap animated:YES];
    }else {
        JXLocationVC * vc = [JXLocationVC alloc];
        vc.placeNames = msg.objectId;
        vc.locations = [NSMutableArray arrayWithArray:locations];
        vc.locationType = JXLocationTypeShowStaticLocation;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    for (UIGestureRecognizer *gesture in self.view.window.gestureRecognizers) {
        NSLog(@"gesture = %@",gesture);
        gesture.delaysTouchesBegan = NO;
        NSLog(@"delaysTouchesBegan = %@",gesture.delaysTouchesBegan?@"YES":@"NO");
        NSLog(@"delaysTouchesEnded = %@",gesture.delaysTouchesEnded?@"YES":@"NO");
    }
    
    
    //设置右上角图标
//#ifdef IS_SHOW_NEWReadDelete
    if ([g_config.isDelAfterReading isEqualToString:@"0"]) {
    if ([self.chatPerson.isOpenReadDel integerValue] != 0) {
        //重新设置
        [rightNaviBtn setClockTitleWithIndex:[self.chatPerson.isOpenReadDel integerValue]];
        if (_myReadDel != [self.chatPerson.isOpenReadDel integerValue]) {
            _myReadDel = [self.chatPerson.isOpenReadDel integerValue];
            [self sendReadDelMsg:self.chatPerson.isOpenReadDel];
        }
        
//        self.tableView.tableFooterView = self.bottomView;
//        if ([_lastMsg.fromUserId isEqualToString:MY_USER_ID]) {
//        self.bottomTitleLb.text = [NSString stringWithFormat:@"您设置了消息%@后消失", timeArr[[self.chatPerson.isOpenReadDel integerValue] - 1]];
        
//        }else {
//            if ([_lastMsg.isReadDel boolValue]) {
//
//                self.bottomTitleLb.text = [NSString stringWithFormat:@"对方设置了阅读消息%@后消失", timeArr[[_lastMsg.isReadDel integerValue] - 1]];
//            }
//        }
    }else{
        //self.tableView.tableFooterView = nil;
        [rightNaviBtn setMoreStyle];
    }
    }
//#else
//#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //进入界面刷新一下我的收藏表情
    [[NSNotificationCenter defaultCenter] postNotificationName:kFavoritesRefresh_WHNotification object:nil];
    
    self.view.backgroundColor = HEXCOLOR(0xD0D0D0);
    self.friendStatus = [self.chatPerson.status intValue];
    
    
    [self customView];
    if (self.chatRoom.roomJid.length > 0) {
        [self setupNotice];
    }
    if (self.courseId.length > 0) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 48)];
        btn.backgroundColor = THEMECOLOR;
        [btn setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = sysFontWithSize(15);
        [btn addTarget:self action:@selector(sendCourseAction) forControlEvents:UIControlEventTouchUpInside];
        [self.wh_tableFooter addSubview:btn];
        
    }else {

        [self createFooterSubViews];
    }
    
    self.screenShotView.frame = CGRectMake(self.screenShotView.frame.origin.x, self.wh_tableFooter.frame.origin.y - self.screenShotView.frame.size.height - 10, self.screenShotView.frame.size.width, self.screenShotView.frame.size.height);
    
    
    if (!self.roomJid) {
        // 如果是自己的其他端，不调用接口
        if (chatPerson && [chatPerson.userId rangeOfString:MY_USER_ID].location != NSNotFound) {
            self.friendStatus = 10;
            for (JXDevice *device in g_multipleLogin.deviceArr) {
                if ([device.userId isEqualToString:chatPerson.userId]) {
                    NSString *str = [device.isOnLine intValue] == 1 ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
                    self.onlinestate = [device.isOnLine boolValue];
                    self.title = [NSString stringWithFormat:@"%@",chatPerson.remarkName.length > 0 ? chatPerson.remarkName : chatPerson.userNickname];
                    break;
                }
            }
            
//            if ([chatPerson.userId rangeOfString:@"android"].location != NSNotFound) {
//
//                NSString *str = [g_multipleLogin.androidUser.isOnLine intValue] == 1 ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
//                self.title = [NSString stringWithFormat:@"%@(%@)",chatPerson.userNickname,str];
//            }
//            if ([chatPerson.userId rangeOfString:@"pc"].location != NSNotFound) {
//                NSString *str = [g_multipleLogin.pcUser.isOnLine intValue] == 1 ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
//                self.title = [NSString stringWithFormat:@"%@(%@)",chatPerson.userNickname,str];
//            }
//            if ([chatPerson.userId rangeOfString:@"mac"].location != NSNotFound) {
//                NSString *str = [g_multipleLogin.macUser.isOnLine intValue] == 1 ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
//                self.title = [NSString stringWithFormat:@"%@(%@)",chatPerson.userNickname,str];
//            }
            
        }else {
            if (self.isGroupMessages) {
                self.title = Localized(@"JX_GroupHair");
            }else {
                [g_server getUser:chatPerson.userId toView:self];
            }
        }
    } else {
        [g_server WH_roomGetRoom:self.roomId toView:self];
    }
    
   //同步消息
    [self messageSync];
    
    if (chatPerson.lastInput.length > 0) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            _messageText.inputView = nil;
            [_messageText reloadInputViews];
            [self doBeginEdit];
            [_messageText becomeFirstResponder];
            [_faceView removeFromSuperview];
        });
    }
}
- (void)chatVCMessageSync:(NSNotification *)noti {
    long long timeSend = [noti.object longLongValue];
    self.chatPerson.timeSend = [NSDate dateWithTimeIntervalSince1970:timeSend];
    [self messageSync];
}
- (void)messageSync
{
    // 同步消息
    if ([self.chatPerson.downloadTime timeIntervalSince1970] < [self.chatPerson.timeSend timeIntervalSince1970] && _taskList.count<=0) {
        double syncTimeLen = 0;
        NSString* s;
        if([self.roomJid length]>0){
            s = self.roomJid;
            //            syncTimeLen = [g_myself.groupChatSyncTimeLen doubleValue];
            syncTimeLen = 0;
        }
        else{
            s = chatPerson.userId;
            syncTimeLen = [g_myself.chatSyncTimeLen doubleValue];
        }
        if (syncTimeLen != -2) {
            
            long  starTime = [self.chatPerson.downloadTime timeIntervalSince1970] * 1000;
            double n = [self.chatPerson.timeSend timeIntervalSince1970] - [self.chatPerson.downloadTime timeIntervalSince1970];
            double m = syncTimeLen * 24 * 3600;
            if (n > m && syncTimeLen > 0) {
                starTime = ([self.chatPerson.timeSend timeIntervalSince1970] - m) * 1000;
            }
            
            //            if (self.roomJid.length > 0) {
            //                JXSynTask *task = _taskList.firstObject;
            //                if (task) {
            //                    starTime = [task.endTime timeIntervalSince1970] * 1000;
            //                }else {
            //                    starTime = 0;
            //                }
            //            }
            
            //            long endTime = [self.chatPerson.timeSend timeIntervalSince1970] * 1000 + 1;
            long endTime = [[NSDate date] timeIntervalSince1970] * 1000;
            
            self.isSyncMsg = YES;
            
            if([self.roomJid length]>0)
            {
                [g_server WH_tigaseMucMsgsWithRoomId:s StartTime:starTime EndTime:endTime PageIndex:0 PageSize:PAGECOUNT toView:self];
            }else{
                [g_server WH_tigaseMsgsWithReceiver:s StartTime:starTime EndTime:endTime  PageIndex:0 toView:self];
            }
            [self refresh:nil loadHistory:YES];
                
            self.chatPerson.downloadTime = self.chatPerson.timeSend;
            [self.chatPerson update];
            
        }
        
    }else {
         self.isSyncMsg = YES;
        [self refresh:nil loadHistory:YES];
        
    }
}

- (void) customView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self WH_createHeadAndFoot];
    self.wh_tableFooter.clipsToBounds = YES;
    // 设置聊天背景图片
    self.backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_BOTTOM)];
    [self.view insertSubview:self.backGroundImageView belowSubview:_table];

    NSData *imageData = [g_constant.userBackGroundImage objectForKey:[NSString stringWithFormat:@"%@_%@" ,MY_USER_ID ,self.chatPerson.userId]];
    
    NSData *imageData2 = [g_constant.chatBackgrounImage objectForKey:MY_USER_ID];
//    UIImage *backGroundImage = [UIImage imageWithContentsOfFile:kChatBackgroundImagePath];
    
    if (imageData) {
        _table.backgroundColor = [UIColor clearColor];
        self.backGroundImageView.image = [UIImage imageWithData:imageData];
    }else if (imageData2) {
        _table.backgroundColor = [UIColor clearColor];
//        self.backGroundImageView.image = backGroundImage;
        self.backGroundImageView.image = [UIImage imageWithData:imageData2];
    }else {
        _table.backgroundColor = g_factory.globalBgColor;
    }
//    _table.allowsSelection = NO;
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = YES;
//    self.wh_tableFooter.backgroundColor = HEXCOLOR(0xD0D0D0);
    
    CGFloat width = 120;
    if ([g_constant.sysLanguage isEqualToString:@"zh"]) {
        width = 80;
    }
    //        if (!self.ished) {
    
//    NSString *str = [NSString stringWithFormat:@"%@(%@)",chatPerson.userNickname,Localized(@"JX_OffLine")];
//    CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.headerTitle.font} context:nil].size;
//    CGFloat n = JX_SCREEN_WIDTH / 2 + size.width / 2;
//    CGFloat x = ((JX_SCREEN_WIDTH - n - (JX_SCREEN_WIDTH - btn.frame.origin.x)) / 2) - (width / 2) + n;
    
//    UIButton *readDelBut = [UIFactory WH_create_WHButtonWithImage:@"im_destroy"
//                           highlight:nil
//                              target:self
//                            selector:@selector(switchValueChange:)];
//    readDelBut.custom_acceptEventInterval = .25f;
//    readDelBut.tag = 2000;
//    readDelBut.frame = CGRectMake(JX_SCREEN_WIDTH - 42 - 32, JX_SCREEN_TOP - 33, 22, 22);
//    readDelBut.layer.cornerRadius = readDelBut.frame.size.width / 2;
//    readDelBut.layer.masksToBounds = YES;
//    readDelBut.layer.borderWidth = 1;
//    readDelBut.layer.borderColor = [UIColor whiteColor].CGColor;
//    [self.tableHeader addSubview:readDelBut];

    NSLog(@"timetime203 -- %f", [[NSDate date] timeIntervalSince1970]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _moreView =[WH_JXSelectImageView alloc];
        _moreView.wh_isDevice = [self.chatPerson.userId rangeOfString:MY_USER_ID].location != NSNotFound;
        _moreView.delegate = self;
        _moreView.wh_isGroupMessages = self.isGroupMessages;
        _moreView.wh_isGroup = _roomJid.length > 0;
        
        //        if([ [ UIDevice currentDevice ] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ){
        //            _moreView.onImage  = @selector(pickPhoto);
        //        }else{
        //            _moreView.onImage  = @selector( pickImage:);
        //        }
        _moreView.wh_onImage  = @selector(pickPhoto);
        
        if (self.roomJid) {//如果是群聊
            //        readDelBut.hidden = YES;
            _moreView.wh_onGift = @selector(sendGiftToRoom);
            _moreView.onTwoWayWithdrawal = @selector(twoWayWithdrawalMethod);
        }else{
            _moreView.wh_onGift = @selector(sendGift);
            _moreView.wh_onTransfer = @selector(onTransfer);
        }
        
        _moreView.wh_onAudioChat  = @selector(onChatSip);
        
        
        _moreView.wh_onVideo  = @selector(pickVideo);
        _moreView.onCard  = @selector(onCard);
        _moreView.onFile  = @selector(onFile);
        _moreView.onLocation  = @selector(onLocation);
        _moreView.onCamera = @selector(onCamera);
        _moreView.onShake = @selector(WH_onShake);
        _moreView.onCollection = @selector(onCollection);
        _moreView.onAddressBook = @selector(onAddressBook);
        _moreView = [_moreView initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, faceHeight)];
        
        _voice = [[WH_VolumeView alloc]initWithFrame:CGRectMake(0, 0, 160, 150)];
        _voice.center = self.view.center;
    });
    [self initAudio];
    
    UIButton* btn;
    if(self.roomJid){
        
        btn = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal" highlight:nil target:self selector:@selector(onMember)];
        btn.custom_acceptEventInterval = 1.0f;
        btn.frame = CGRectMake(JX_SCREEN_WIDTH - 28 - g_factory.globelEdgeInset, JX_SCREEN_TOP - 36, 28, 28);
        [self.wh_tableHeader addSubview:btn];
        
//        _circularView = [[YJCircleView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 28 - g_factory.globelEdgeInset, JX_SCREEN_TOP - 36, 28, 28)];
//        _circularView.backgroundColor = [UIColor clearColor];
//        _circularView.lineStyle       = LineStyleRound;
//        _circularView.degrees         = 1;
////        _changeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
////        _circularView.valueLabel.text            = @"15";
////        _circularView.descButton.titleLabel.text = @"今日里程(km)";
//        
//        
//        _circularView.circleStrokeColor          = [UIColor clearColor];
//        
//        _circularView.activeCircleStrokeColor    = HEXCOLOR(0x0093ff);
//        
//        [self.wh_tableHeader addSubview:_circularView];
        
        [g_server WH_getRoomMemberWithRoomId:roomId userId:[g_myself.userId intValue] toView:self];
        
        //第一次拉取服务器群成员存本地
        self.isFirst = YES;
        [g_server getRoom:self.room.roomId toView:self];
        //获取群成员：
        NSArray * memberArray = [memberData fetchAllMembers:_room.roomId];
        self.groupSize = memberArray.count;
        self.title = [NSString stringWithFormat:@"%@(%ld)", self.chatPerson.userNickname, memberArray.count];
        _room.roomId = roomId;
        _room.members = [memberArray mutableCopy];
        
        memberData *data = [self.room getMember:g_myself.userId];
        if ([data.role intValue] == 1 || [data.role intValue] == 2) {
            _isAdmin = YES;
        }else {
            _isAdmin = NO;
        }
        
    }else {
        rightNaviBtn = [ChatMoreButton buttonWithType:UIButtonTypeCustom];
        rightNaviBtn.backgroundColor = [UIColor clearColor];
        rightNaviBtn.custom_acceptEventInterval = 1.0f;
        rightNaviBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 28 - g_factory.globelEdgeInset, JX_SCREEN_TOP - 36, 36, 36);
        [rightNaviBtn addTarget:self action:@selector(createRoom) forControlEvents:UIControlEventTouchUpInside];
        [rightNaviBtn setMoreStyle];
        [self.wh_tableHeader addSubview:rightNaviBtn];
    }
    
    if (!self.isQRCodePush) {
        if (self.courseId.length > 0 || [chatPerson.userId rangeOfString:MY_USER_ID].location != NSNotFound || self.isGroupMessages || self.isHiddenFooter) {
            //        readDelBut.hidden = YES;
            btn.hidden = YES;
        }
    }else{
        btn.hidden = NO;
    }
    
    
    if (self.isGroupMessages) {
        self.wh_isShowHeaderPull = NO;
        UIView *friendNamesView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y, JX_SCREEN_WIDTH, 0)];
        friendNamesView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:friendNamesView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 300, 20)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor lightGrayColor];
        label.text = [NSString stringWithFormat:Localized(@"JX_YouWillSendMessagesToFriends"),_userIds.count];
        [friendNamesView addSubview:label];
        
        NSMutableString *names = [NSMutableString string];
        for (NSInteger i = 0; i < _userNames.count; i ++) {
            NSString *str = _userNames[i];
            if (i == 0) {
                [names appendString:[NSString stringWithFormat:@"[\"%@",str]];
            }
            else if (i == _userNames.count - 1) {
                [names appendString:[NSString stringWithFormat:@",%@\"]", str]];
            }
            else {
                [names appendString:[NSString stringWithFormat:@",%@", str]];
            }
            if (_userNames.count == 1) {
                [names appendString:@"\"]"];
            }
        }
        
        CGSize size = [names boundingRectWithSize:CGSizeMake(friendNamesView.frame.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil].size;
        
        CGFloat height = 0;
        if (size.height > 200) {
            height = 200;
        }else {
            height = size.height;
        }
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(15, CGRectGetMaxY(label.frame) + 10, friendNamesView.frame.size.width - 30, height)];
        [friendNamesView addSubview:scrollView];
        
        UILabel *namesLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, friendNamesView.frame.size.width - 30, size.height)];
        namesLabel.font = [UIFont systemFontOfSize:17.0];
        namesLabel.textColor = [UIColor blackColor];
        namesLabel.numberOfLines = 0;
        namesLabel.text = names;
        [scrollView addSubview:namesLabel];
        scrollView.contentSize = CGSizeMake(namesLabel.frame.size.width, size.height);
        
        friendNamesView.frame = CGRectMake(friendNamesView.frame.origin.x, friendNamesView.frame.origin.y, friendNamesView.frame.size.width, scrollView.frame.origin.y + scrollView.frame.size.height + 15);
        NSLog(@"%@", friendNamesView);
    }
    
    // 截屏
    self.screenShotView = [[UIView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 80 - 10, 100, 80, 130)];
    self.screenShotView.backgroundColor = [UIColor whiteColor];
    self.screenShotView.layer.cornerRadius = 5.0;
    self.screenShotView.layer.masksToBounds = YES;
    self.screenShotView.hidden = YES;
    [self.view addSubview:self.screenShotView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenShotViewAction:)];
    [self.screenShotView addGestureRecognizer:tap];
    
    UILabel *screenShotLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.screenShotView.frame.size.width - 10, 40)];
    screenShotLabel.font = [UIFont systemFontOfSize:11.0];
    screenShotLabel.numberOfLines = 0;
    screenShotLabel.text = Localized(@"JX_ThePhotosYouMightWantToSend");
    [self.screenShotView addSubview:screenShotLabel];
    
    self.screenShotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(screenShotLabel.frame), self.screenShotView.frame.size.width - 10, self.screenShotView.frame.size.height - screenShotLabel.frame.size.height - 5)];
    self.screenShotImageView.layer.cornerRadius = 5.0;
    self.screenShotImageView.layer.masksToBounds = YES;
//    self.screenShotImageView.image = [UIImage imageWithContentsOfFile:ScreenShotImage];
    [self.screenShotView addSubview:self.screenShotImageView];
    
    // 新消息跳转
    _jumpNewMsgBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 105, JX_SCREEN_TOP + 20, 120, 30)];
    _jumpNewMsgBtn.backgroundColor = [UIColor whiteColor];
    _jumpNewMsgBtn.layer.cornerRadius = _jumpNewMsgBtn.frame.size.height / 2;
    _jumpNewMsgBtn.layer.masksToBounds = YES;
    [_jumpNewMsgBtn addTarget:self action:@selector(jumpNewMsgBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_jumpNewMsgBtn];
    
    UILabel *newMsgLabel = [[UILabel alloc] initWithFrame:_jumpNewMsgBtn.bounds];
    newMsgLabel.text = [NSString stringWithFormat:@"%d%@", self.newMsgCount,Localized(@"JX_NewMessages")];
    newMsgLabel.font = [UIFont systemFontOfSize:13.0];
    newMsgLabel.textAlignment = NSTextAlignmentCenter;
    newMsgLabel.textColor = HEXCOLOR(0x4FC557);
    [_jumpNewMsgBtn addSubview:newMsgLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
    imageView.image = [UIImage imageNamed:@"doubleArrow_up"];
    [_jumpNewMsgBtn addSubview:imageView];
    
    if (self.newMsgCount > 20) {
        _jumpNewMsgBtn.hidden = NO;
    }else {
        _jumpNewMsgBtn.hidden = YES;
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //进入界面即开启定时器
    [self.noticeTimer setFireDate:[NSDate distantPast]];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //退出界面即关闭定时器
    [self.noticeTimer setFireDate:[NSDate distantFuture]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (_player) {
        [g_notify postNotificationName:@"CancleVideoPlay_Notification" object:nil];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

}

- (void)setupNotice {
    _noticeView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 36)];
    _noticeView.backgroundColor = [UIColor whiteColor];
    _noticeView.hidden = YES;
    [self.view addSubview:_noticeView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideNoticeView:)];
    [_noticeView addGestureRecognizer:tap];

    _noticeImgV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 16, 16)];
    _noticeImgV.image = [UIImage imageNamed:@"chat_notice"];
    [_noticeView addSubview:_noticeImgV];
    
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_noticeImgV.frame)+4, 0, 64, 36)];
    _noticeLabel.text = Localized(@"JX_LatestAnnouncement:");
    _noticeLabel.textColor = HEXCOLOR(0x323232);
    _noticeLabel.font = sysFontWithSize(13);
    [_noticeView addSubview:_noticeLabel];
    
    _showNoticeView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_noticeLabel.frame)+5, 0, JX_SCREEN_WIDTH-125, 36)];
    _showNoticeView.backgroundColor = [UIColor whiteColor];
    _showNoticeView.clipsToBounds = YES;
    [_noticeView addSubview:_showNoticeView];
    
    _leftLabel = [[UILabel alloc] initWithFrame:_showNoticeView.bounds];
    _leftLabel.textColor = HEXCOLOR(0x323232);
    _leftLabel.textAlignment = NSTextAlignmentLeft;
    _leftLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _leftLabel.font = sysFontWithSize(13);
    [_showNoticeView addSubview:_leftLabel];

    _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftLabel.frame), 0, JX_SCREEN_WIDTH-130, 36)];
    _rightLabel.textColor = HEXCOLOR(0x323232);
    _rightLabel.font = sysFontWithSize(13);
    _rightLabel.textAlignment = NSTextAlignmentLeft;
    _rightLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_showNoticeView addSubview:_rightLabel];
    
}

- (void)hideNoticeView:(UITapGestureRecognizer *)tap {
//    _noticeView.hidden = YES;
//    _noticeHeight = 0;
//    _table.frame = CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-JX_SCREEN_BOTTOM);
//    _jumpNewMsgBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 105, JX_SCREEN_TOP + 20+_noticeHeight, 120, 30);
    
    
    //跳转到公告列表
    memberData *data = [self.room getMember:g_myself.userId];
    WH_JXAnnounce_WHViewController* vc = [WH_JXAnnounce_WHViewController alloc];
    //    vc.dataArray = self.noticeArr;
    //    vc.delegate  = self;
    if (([data.role intValue] == 1 || [data.role intValue] == 2)) {
        vc.isAdmin = YES; // 是群主和管理
    }else {
        vc.isAdmin = NO;  // 不是群主和管理
    }
    vc.room = _room;
    vc.title = Localized(@"JXRoomMemberVC_UpdateAdv");
    //    vc.didSelect = @selector(onSaveNote:);
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
}

- (void)startNoticeTimer {
    _leftW = 0;
    _rightW = _noticeStrW+NOTICE_WIDTH;
    _noticeTimer = [NSTimer scheduledTimerWithTimeInterval:0.04f target:self selector:@selector(updateNoticeTimer:) userInfo:nil repeats:YES];

    [self.noticeTimer setFireDate:[NSDate distantPast]];
}

- (void)stopNoticeTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)updateNoticeTimer:(NSTimer *)timer {
    self.leftW --;
    self.rightW --;
    self.leftLabel.frame = CGRectMake(self.leftW, 0, _noticeStrW+NOTICE_WIDTH, 36);
    self.rightLabel.frame = CGRectMake(self.rightW, 0, _noticeStrW+NOTICE_WIDTH, 36);
    if (self.leftW <= -_noticeStrW-NOTICE_WIDTH) {
        self.leftW = _noticeStrW+NOTICE_WIDTH;
    }
    if (self.rightW <= -_noticeStrW-NOTICE_WIDTH) {
        self.rightW = _noticeStrW+NOTICE_WIDTH;
    }
}

- (void)setupNoticeWithContent:(NSString *)noticeStr time:(NSString *)noticeTime {
    
    NSString * newNoticeStr = [self getContentMsg:noticeStr];
    
    CGSize size = [newNoticeStr sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(13)}];
    _leftLabel.frame = CGRectMake(0, 0, size.width, 36);
    _leftLabel.text = newNoticeStr;
    _rightLabel.frame = CGRectMake(CGRectGetMaxX(_leftLabel.frame), 0, size.width, 36);
    _rightLabel.text = newNoticeStr;
    _noticeStrW = size.width;
    if (_noticeStrW > _showNoticeView.frame.size.width) {
        _rightLabel.hidden = NO;
        [self startNoticeTimer];
    }else {
        _rightLabel.hidden = YES;
        [self stopNoticeTimer];
        [self.noticeTimer invalidate];
        self.noticeTimer = nil;
    }
    if (newNoticeStr.length > 0) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        // 公告时间超过一周即不再显示
        if (time >= 60*60*24*7+[noticeTime intValue]) {
            _noticeView.hidden = YES;
            _noticeHeight = 0;
        }else {
            _noticeView.hidden = NO;
            _noticeHeight = 36;
            _table.frame = CGRectMake(0, JX_SCREEN_TOP+_noticeHeight, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-JX_SCREEN_BOTTOM - _noticeHeight);
            [_table WH_gotoLastRow:NO];
        }
    }else {
        _noticeView.hidden = YES;
        _noticeHeight = 0;
    }
    _jumpNewMsgBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 105, JX_SCREEN_TOP + 20+_noticeHeight, 120, 30);
}



// 跳转到新消息
- (void)jumpNewMsgBtnAction {
//    NSIndexPath* indexPat = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView scrollToRowAtIndexPath:indexPat atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    _jumpNewMsgBtn.hidden = YES;
    
     NSInteger index = _array.count - self.newMsgCount;
     if (index >= 0) {
         NSIndexPath* indexPat = [NSIndexPath indexPathForRow:index inSection:0];
         [self.tableView scrollToRowAtIndexPath:indexPat atScrollPosition:UITableViewScrollPositionBottom animated:YES];
     } else {
         NSIndexPath* indexPat = [NSIndexPath indexPathForRow:0 inSection:0];
         [self.tableView scrollToRowAtIndexPath:indexPat atScrollPosition:UITableViewScrollPositionBottom animated:YES];
     }
    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + self.tableView.height/2);
     _jumpNewMsgBtn.hidden = YES;
}

- (void)screenShotViewAction:(UITapGestureRecognizer *)tap {
    
    if([self showDisableSay])
        return;
    
    if([self sendMsgCheck]){
        return;
    }
    WH_KKImageEditor_WHViewController *editor = [[WH_KKImageEditor_WHViewController alloc] initWithImage:self.screenImage delegate:self];
    
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:vc animated:YES completion:nil];

}

#pragma mark- 照片编辑后的回调
- (void)imageDidFinishEdittingWithImage:(UIImage *)image
{
    self.screenShotImageView.image = image;
    UIImage *chosedImage = self.screenShotImageView.image;
    //获取image的长宽
    int imageWidth = chosedImage.size.width;
    int imageHeight = chosedImage.size.height;
    
    self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self hideKeyboard:YES];
    
    
    NSString *name = @"jpg";
    if (self.isGroupMessages) {
        for (NSInteger i = 0; i < self.userIds.count; i ++) {
            NSString *userId = self.userIds[i];
            
            NSString *file = [FileInfo getUUIDFileName:name];
            [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:NO];
            [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:userId];
//            [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        }
    }else {
        NSString *file = [FileInfo getUUIDFileName:name];
        [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:NO];
        [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:nil];
//        [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
    }
    //    NSString* file = [FileInfo getUUIDFileName:name];
    //
    //    file = [FileInfo getUUIDFileName:name];
    //    [g_server saveImageToFile:chosedImage file:file isOriginal:NO];
    ////    [self sendImage:file withWidth:imageWidth andHeight:imageHeight];
    //    [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut toView:self];
    
    self.screenShotView.hidden = YES;
    //    NSFileManager* fileManager=[NSFileManager defaultManager];
    //    BOOL blDele= [fileManager removeItemAtPath:ScreenShotImage error:nil];
    //    if (blDele) {
    //        NSLog(@"dele success");
    //    }else {
    //        NSLog(@"dele fail");
    //    }
}


- (void) createFooterSubViews{
    
    [inputBar removeFromSuperview];
    [_publicMenuBar removeFromSuperview];
    [_selectMoreView removeFromSuperview];
    
    if(self.wh_tableFooter){
        //戳一戳背景
        _shakeBgView = [UIView new];
        _shakeBgView.hidden = YES;
        _shakeBgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_shakeBgView];
        [self.view sendSubviewToBack:_shakeBgView];
        UIView* shakeLine = [UIView new];
        shakeLine.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [_shakeBgView addSubview:shakeLine];
        [shakeLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.offset(0);
            make.height.offset(.5f);
        }];
    }
    
    //输入条
    inputBar = [[UIImageView alloc] initWithImage:nil];
    inputBar.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 48+10);
    inputBar.backgroundColor = [UIColor whiteColor];
    inputBar.userInteractionEnabled = YES;
    inputBar.clipsToBounds = YES;
    [self.wh_tableFooter addSubview:inputBar];
    //        [inputBar release];
    
    if(self.wh_tableFooter){
        [_shakeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(inputBar).offset(-50);
            make.right.equalTo(inputBar).offset(50);
            make.top.bottom.equalTo(inputBar);
        }];
    }
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [inputBar addSubview:line];
    //        [line release];
    
    //＋
    self.shareMore = [UIFactory WH_create_WHButtonWithImage:@"WH_input_more_normal" highlight:@"WH_input_more_normal" target:self selector:@selector(shareMore:)];
    self.shareMore.frame = CGRectMake(JX_SCREEN_WIDTH - 42, 8+2, 32, 32);
    [inputBar addSubview:self.shareMore];
    CGFloat firstX;
    if (_menuList.count > 0) {
        UIButton *btn = [UIFactory WH_create_WHButtonWithImage:@"lashang" selected:@"lashang" target:self selector:@selector(inputBarSwitch:)];
        btn.frame = CGRectMake(10, 8+2, 32, 32);
        btn.selected = NO;
        [inputBar addSubview:btn];
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(47, 0, 0.5, self.wh_heightFooter)];
        v.backgroundColor = HEXCOLOR(0xdcdcdc);
        [inputBar addSubview:v];
        
        firstX = 52;
        
        inputBar.frame = CGRectMake(inputBar.frame.origin.x, inputBar.frame.size.height, inputBar.frame.size.width, inputBar.frame.size.height);
        
    }else {
        firstX = 10;
        inputBar.frame = CGRectMake(inputBar.frame.origin.x, 0, inputBar.frame.size.width, inputBar.frame.size.height);
    }
    
    UIButton *btn = [UIFactory WH_create_WHButtonWithImage:@"WH_input_ptt_normal" selected:@"WH_new_keyboard" target:self selector:@selector(recordSwitch:)];
    btn.frame = CGRectMake(firstX, 8+2, 32, 32);
    btn.selected = NO;
    [inputBar addSubview:btn];
    _recordBtnLeft = btn;
    
    //eomoj
    btn = [UIFactory WH_create_WHButtonWithImage:@"im_input_expression_normal" selected:@"im_input_keyboard_normal" target:self selector:@selector(actionFace:)];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH -82, 8+2, 32, 32);
    btn.selected = NO;
    [inputBar addSubview:btn];
    _btnFace = btn;
    
    CGFloat msgTextX = CGRectGetMaxX(_recordBtnLeft.frame) + INSETS;
    
    _messageText = [[UITextView alloc] initWithFrame:CGRectMake(msgTextX, 8, JX_SCREEN_WIDTH - msgTextX - 89, 32)];
    _messageText.wzb_placeholder = Localized(@"WaHu_input_chat_content");
    _messageText.wzb_placeholderColor = HEXCOLOR(0xBAC3D5);
    //内容缩进为零（去除左右边距）
    _messageText.textContainer.lineFragmentPadding = INSETS;
    _messageText.font = sysFontWithSize(16);
    _messageText.delegate = self;
    _messageText.layer.borderWidth = 1.f;
    _messageText.layer.borderColor = HEXCOLOR(0xE3E5E6).CGColor;
    _messageText.layer.cornerRadius = CGRectGetHeight(_messageText.frame) / 2.f;
    _messageText.layer.masksToBounds = YES;
    _messageText.enablesReturnKeyAutomatically = YES;
    _messageText.returnKeyType = UIReturnKeySend;
    if (![self changeEmjoyText:chatPerson.lastInput textColor:HEXCOLOR(0x3A404C)]) {
        _messageText.text = chatPerson.lastInput;
    }
    [inputBar addSubview:_messageText];
    [self setTableFooterFrame:_messageText];
    
    //设置菜单
    UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:Localized(@"JX_Newline") action:@selector(selfMenu:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:[NSArray arrayWithObject:menuItem]];
    
    _textViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, _messageText.frame.size.width, 12)];
    _textViewBtn.backgroundColor = [UIColor clearColor];
    [_textViewBtn addTarget:self action:@selector(textViewBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _textViewBtn.hidden = YES;
    [_messageText addSubview:_textViewBtn];
    
    _talkTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _messageText.frame.size.width, _messageText.frame.size.height)];
    _talkTimeLabel.font = [UIFont systemFontOfSize:15.0];
    _talkTimeLabel.text = Localized(@"JX_TotalSilence");
    _talkTimeLabel.textColor = [UIColor lightGrayColor];
    _talkTimeLabel.textAlignment = NSTextAlignmentCenter;
    _talkTimeLabel.backgroundColor = [UIColor whiteColor];
    [_messageText addSubview:_talkTimeLabel];
    _talkTimeLabel.hidden = YES;
    
    memberData *roomD = [[memberData alloc] init];
    roomD.roomId = self.room.roomId;
    memberData *roomData = [roomD getCardNameById:MY_USER_ID];
    
    if (([self.chatPerson.talkTime longLongValue] > 0 && !_isAdmin) || [roomData.role intValue] == 4) {
        if ([roomData.role intValue] == 4) {
            _talkTimeLabel.text = Localized(@"JX_ProhibitToSpeak");
        }
        _messageText.userInteractionEnabled = NO;
        _shareMore.enabled = NO;
        _recordBtnLeft.enabled = NO;
        _btnFace.enabled = NO;
        _messageText.text = nil;
    }else {
        _talkTimeLabel.hidden = YES;
        _shareMore.enabled = YES;
        _recordBtnLeft.enabled = YES;
        _btnFace.enabled = YES;
        _messageText.userInteractionEnabled = YES;
    }
    
    //点击语音图片后出现的录制语音按钮
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.frame = CGRectMake(_messageText.frame.origin.x, 8, _messageText.frame.size.width, 32+5.5);
    btn.frame = CGRectMake(_messageText.frame.origin.x, 8, _messageText.frame.size.width, 35.5f);
    btn.backgroundColor = HEXCOLOR(0xFEFEFE);
    btn.layer.borderWidth = 1.f;
    btn.layer.borderColor = HEXCOLOR(0xE3E5E6).CGColor;
    [btn setTitle:Localized(@"JXChatVC_TouchTalk") forState:UIControlStateNormal];
    [btn setTitle:Localized(@"JXChatVC_ReleaseEnd") forState:UIControlEventTouchDown];
    //    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:HEXCOLOR(0xBAC3D5) forState:UIControlStateNormal];
    btn.titleLabel.font = sysFontWithSize(16);
    //        [btn setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    //        [btn setTitleShadowOffset:CGSizeMake(1, 1)];
    btn.layer.cornerRadius = CGRectGetHeight(btn.frame) / 2.f;
    btn.layer.masksToBounds = YES;
    [inputBar addSubview:btn];
    [btn addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(recordStop:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(recordCancel:) forControlEvents:UIControlEventTouchUpOutside];
    btn.selected = NO;
    _recordBtn = btn;
    _recordBtn.hidden = YES;
    
    if (_menuList.count > 0) {
        // 公众号菜单
        _publicMenuBar = [[UIView alloc] init];
        _publicMenuBar.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 48);
        _publicMenuBar.backgroundColor = [UIColor whiteColor];
        _publicMenuBar.layer.borderWidth = .5;
        _publicMenuBar.layer.borderColor = [HEXCOLOR(0xdcdcdc) CGColor];
        [self.wh_tableFooter addSubview:_publicMenuBar];
        [self createPublicMenu:_menuList];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createSelectMoreView];
    });
    
}

//隐藏系统菜单的方法
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //允许显示
    if (action == @selector(selfMenu:)) {
        return YES;
    }
    //其他不允许显示
    return NO;
}

- (void)selfMenu:(id)sender {
    _messageText.text = [NSString stringWithFormat:@"%@\r",_messageText.text];
    [self textViewDidChange:_messageText];
    
}

- (void)textViewBtnAction:(UIButton *)btn {
    
    _messageText.inputView = nil;
    [_messageText reloadInputViews];
}

- (void) createPublicMenu:(NSArray *) array {
    
    UIButton *btn = [UIFactory WH_create_WHButtonWithImage:@"jiangp" selected:@"jiangp" target:self selector:@selector(publicMenuSwitch:)];
    btn.frame = CGRectMake(10, 8, 32, 32);
    btn.selected = NO;
    [_publicMenuBar addSubview:btn];
    
    
    CGFloat btnWidth = (JX_SCREEN_WIDTH - 52) / array.count;
    for (NSInteger i = 0; i < array.count; i ++) {
        NSDictionary *dict = array[i];
        NSString *name = dict[@"name"];
        btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), 0, btnWidth, _publicMenuBar.frame.size.height)];
        btn.tag = i;
        [btn addTarget:self action:@selector(publicMenuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            CGRect frame = btn.frame;
            frame.origin.x = 52;
            btn.frame = frame;
        }
        btn.titleLabel.font = sysFontWithSize(15.0);
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitle:name forState:UIControlStateNormal];
        [_publicMenuBar addSubview:btn];
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(btn.frame.origin.x, 0, 0.5, _publicMenuBar.frame.size.height)];
        v.backgroundColor = HEXCOLOR(0xdcdcdc);
        [_publicMenuBar addSubview:v];
        
        CGSize size = [name boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(15.0)} context:nil].size;
        CGFloat imageX = (btnWidth - size.width) / 2 - 20;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, (btn.frame.size.height - 16) / 2, 15, 15)];
        imageView.image = [UIImage imageNamed:@"public_menu"];
        [btn addSubview:imageView];
    }
}

- (void)createSelectMoreView {
    
    _selectMoreView = [[UIView alloc] initWithFrame:self.wh_tableFooter.bounds];
    _selectMoreView.hidden = YES;
    _selectMoreView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableFooter addSubview:_selectMoreView];
    
    NSArray *imageNames = @[@"msf", @"msc", @"msd", @"mse"];
    CGFloat w = 40;
    CGFloat margin = (JX_SCREEN_WIDTH - imageNames.count * w) / (imageNames.count + 1);
    CGFloat x = margin;
    for (NSInteger i = 0; i < imageNames.count; i ++) {
        NSString *imageName = imageNames[i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 5, w, w)];
        [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(selectMoreViewBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_selectMoreView addSubview:btn];
        
        x = CGRectGetMaxX(btn.frame) + margin;
    }
}

- (void)selectMoreViewBtnAction:(UIButton *)btn {
    
    for (NSInteger i = 0; i < self.selectMoreArr.count; i ++) {
        WH_JXMessageObject *msg1 = self.selectMoreArr[i];
        for (NSInteger j = i + 1; j < self.selectMoreArr.count; j ++) {
            WH_JXMessageObject *msg2 = self.selectMoreArr[j];
            if ([msg1.timeSend timeIntervalSince1970] > [msg2.timeSend timeIntervalSince1970]) {
                WH_JXMessageObject *msg = msg1;
                msg1 = msg2;
                self.selectMoreArr[i] = msg2;
                msg2 = msg;
                self.selectMoreArr[j] = msg;
            }
        }
    }
    
    if (self.selectMoreArr.count <= 0) {
        [g_App showAlert:Localized(@"JX_PleaseSelectTheMessageRecord")];
        return;
    }
    
    switch (btn.tag) {
        case 0:{    // 批量转发
            WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_OneByOneForward"),Localized(@"JX_MergeAndForward")]];
            actionVC.wh_tag = 2457;
            actionVC.delegate = self;
            [self presentViewController:actionVC animated:NO completion:nil];
        }
            
            break;
        case 1:{    // 批量收藏
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:Localized(@"JX_CollectedType") delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Collection"), nil];
            alert.tag = 2457;
            [alert show];
        }
            break;
        case 2:{    // 批量删除
            
            NSMutableString *msgIds = [NSMutableString string];
            for (NSInteger i = 0; i < self.selectMoreArr.count; i ++) {
                WH_JXMessageObject *msg = self.selectMoreArr[i];
                NSInteger indexNum = -1;
                for (NSInteger j = 0; j < _array.count; j ++) {
                    WH_JXMessageObject *msg1 = _array[j];
                    if ([msg1.messageId isEqualToString:msg.messageId]) {
                        if (msgIds.length <= 0) {
                            [msgIds appendString:msg1.messageId];
                        }else {
                            [msgIds appendFormat:@",%@",msg1.messageId];
                        }
                        indexNum = j;
                        break;
                    }
                }
                
                NSString* s;
                if([self.roomJid length]>0)
                    s = self.roomJid;
                else
                    s = chatPerson.userId;
                
                
                if (indexNum == _array.count - 1) {
                    if (indexNum <= 0) {
                        WH_JXMessageObject *lastMsg = [_array firstObject];
                        self.lastMsg.content = nil;
                        [lastMsg updateLastSend:UpdateLastSendType_None];
                    }else {
                        WH_JXMessageObject *newLastMsg = _array[indexNum - 1];
                        self.lastMsg.content = newLastMsg.content;
                        [newLastMsg updateLastSend:UpdateLastSendType_None];
                    }
                }
                
                //删除本地聊天记录
                [_array removeObjectAtIndex:indexNum];
                [msg delete];
                
                [_table WH_deleteRow:(int)indexNum section:0];
            }
            
            if (msgIds.length > 0) {
                int type = 1;
                if (self.roomJid) {
                    type = 2;
                }
                self.withdrawIndex = -1;
                [g_server WH_tigaseDeleteMsgWithMsgId:msgIds type:type deleteType:1 roomJid:self.roomJid toView:self];
            }
            
            if (self.isSelectMore) {
                [self actionQuit];
            }
            
        }
            
            break;
        case 3:{
            WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_SaveToTheAlbum")]];
            actionVC.wh_tag = 2458;
            actionVC.delegate = self;
            [self presentViewController:actionVC animated:NO completion:nil];
        }
            
            break;
            
        default:
            break;
    }
}

- (void)inputBarSwitch:(UIButton *)btn {
    self.wh_heightFooter = 49;
    [self hideKeyboard:YES];
    _publicMenuBar.hidden = NO;
    inputBar.hidden = YES;
    [UIView animateWithDuration:.3 animations:^{
        _publicMenuBar.frame = CGRectMake(_publicMenuBar.frame.origin.x, 0, _publicMenuBar.frame.size.width, _publicMenuBar.frame.size.height);
        inputBar.frame = CGRectMake(inputBar.frame.origin.x, self.wh_tableFooter.frame.size.height, inputBar.frame.size.width, inputBar.frame.size.height);
    }];
}

- (void)publicMenuSwitch:(UIButton *)btn {
    [self setTableFooterFrame:_messageText];
    _publicMenuBar.hidden = YES;
    inputBar.hidden = NO;
    [UIView animateWithDuration:.3 animations:^{
        _publicMenuBar.frame = CGRectMake(_publicMenuBar.frame.origin.x, self.wh_tableFooter.frame.size.height, _publicMenuBar.frame.size.width, _publicMenuBar.frame.size.height);
        inputBar.frame = CGRectMake(inputBar.frame.origin.x, 0, inputBar.frame.size.width, inputBar.frame.size.height);
    }];
}

- (void)publicMenuBtnAction:(UIButton *)btn {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGRect moreFrame = [self.wh_tableFooter convertRect:btn.frame toView:window];
    
    self.selMenuIndex = btn.tag;
    NSDictionary *dict = _menuList[btn.tag];
    NSArray *arr = dict[@"menuList"];
    
    if (!arr || arr.count <= 0) {
        WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
        webVC.isGoBack= YES;
        webVC.isSend = YES;
        webVC.title = [dict objectForKey:@"name"];
        NSString * url = [NSString stringWithFormat:@"%@",[dict objectForKey:@"url"]];
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        webVC.url = url;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
//        [g_navigation pushViewController:webVC animated:YES];
        return;
    }
    
    CGFloat maxWidth = 0;
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger i = 0; i < arr.count; i ++) {
        NSDictionary *dict2 = arr[i];
        [arrM addObject:dict2[@"name"]];
        NSString *str = dict2[@"name"];
        CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(15.0)} context:nil].size;
        if (size.width > maxWidth) {
            maxWidth = size.width;
        }
    }
    WH_JX_DownListView * downListView = [[WH_JX_DownListView alloc] initWithFrame:self.view.bounds];
    downListView.wh_listContents = arrM;
    downListView.wh_color = HEXCOLOR(0xf3f3f3);
    downListView.textColor = [UIColor darkGrayColor];
    downListView.maxWidth = maxWidth;
    downListView.showType = DownListView_ShowUp;
    __weak typeof(self) weakSelf = self;
    [downListView WH_downlistPopOption:^(NSInteger index, NSString *content) {
        [weakSelf showPublicMenuContent:index];
        
    } whichFrame:moreFrame animate:YES];
    [downListView show];
}

- (void)showPublicMenuContent:(NSInteger)index {
    
    NSDictionary *dict = _menuList[self.selMenuIndex];
    NSArray *arr = dict[@"menuList"];
    NSDictionary *dict2 = arr[index];
    
    NSString *menuId = dict2[@"menuId"];
    if (menuId.length > 0) {
        NSString * url = [NSString stringWithFormat:@"%@?access_token=%@",menuId,g_server.access_token];
        [g_server requestWithUrl:url toView:self];
    }else {
        WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
        webVC.isGoBack= YES;
        webVC.isSend = YES;
        webVC.title = [dict2 objectForKey:@"name"];
        NSString * url = [NSString stringWithFormat:@"%@",[dict2 objectForKey:@"url"]];
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        webVC.url = url;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
//        [g_navigation pushViewController:webVC animated:YES];
    }
}

-(void)initAudio{
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    //添加监听
    [g_notify addObserver:self selector:@selector(readTypeMsgCome:) name:kXMPPMessageReadType_WHNotification object:nil];
    [g_notify addObserver:self selector:@selector(readTypeMsgReceipt:) name:kXMPPMessageReadTypeReceipt_WHNotification object:nil];
    [g_notify addObserver:self selector:@selector(sendText:) name:kSendInput_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsg_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(showMsg:) name:kXMPPShowMsg_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(WH_onReceiveFile:) name:kXMPPReceiveFile_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(WH_onSendTimeout:) name:kXMPPSendTimeOut_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(onQuitRoom:) name:kQuitRoom_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [g_notify addObserver:self selector:@selector(onReceiveRoomRemind:) name:kXMPPRoom_WHNotifaction object:nil];
//    [g_notify addObserver:self selector:@selector(onLoginChanged:) name:kXmppLoginNotifaction object:nil];//登录状态改变
    // 正在输入
    [g_notify addObserver:self selector:@selector(enteringNotifi:) name:kXMPPMessageEntering_WHNotification object:nil];
    // 撤回消息
    [g_notify addObserver:self selector:@selector(withdrawNotifi:) name:kXMPPMessageWithdraw_WHNotification object:nil];
    [g_notify addObserver:self selector:@selector(actionQuitChatVC:) name:kActionRelayQuitVC_WHNotification object:nil];
    // 删除好友
    [g_notify addObserver:self selector:@selector(delFriend:) name:kDeleteUser_WHNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(delRoom:) name:kDeleteRoom_WHNotifaction object:nil]; //解散群组
    // 課程消息
    [g_notify addObserver:self selector:@selector(sendCourseMsg:) name:kSendCourseMsg_WHNotification object:nil];
    // 修改备注
    [g_notify addObserver:self selector:@selector(friendRemarkNotifi:) name:kFriendRemark object:nil];
    // 群成员更新
    [g_notify addObserver:self selector:@selector(roomMembersRefreshNotifi:) name:kRoomMembersRefresh_WHNotification object:nil];
    // 设置聊天背景
    [g_notify addObserver:self selector:@selector(setBackGroundImageViewNotifi:) name:kSetBackGroundImageView_WHNotification object:nil];
    [self.wh_tableFooter addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)unInitAudio{
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    //移除监听
    [g_notify removeObserver:self];
    [g_notify  removeObserver:self name:kXMPPNewMsg_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPSendTimeOut_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPReceipt_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kSendInput_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPReceiveFile_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [g_notify  removeObserver:self name:kQuitRoom_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPRoom_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXmppLogin_WHNotifaction object:nil];
    [g_notify removeObserver:self name:kXMPPMessageEntering_WHNotification object:nil];
    [g_notify removeObserver:self name:kXMPPMessageWithdraw_WHNotification object:nil];
    [g_notify removeObserver:self name:kSendCourseMsg_WHNotification object:nil];
    [g_notify removeObserver:self name:kFriendRemark object:nil];
    [self.wh_tableFooter removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (THE_DEVICE_HAVE_HEAD) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        CGRect newFrame = [newValue CGRectValue];
        int n = (int)newFrame.origin.y;
        int m = (int)(self.view.frame.size.height - self.wh_heightFooter);
        
        if (fabs(n - m) < 2) {
            
            self.wh_tableFooter.frame = CGRectMake(0, JX_SCREEN_HEIGHT-self.wh_heightFooter - 35, JX_SCREEN_WIDTH, self.wh_heightFooter);
            _table.frame =CGRectMake(0,self.wh_heightHeader+_noticeHeight,self_width,JX_SCREEN_HEIGHT-self.wh_heightHeader-self.wh_heightFooter - 35-_noticeHeight);
        }
    }
}

- (void)setBackGroundImageViewNotifi:(NSNotification *)notif {
    UIImage *image = notif.object;
    if (image) {
        _table.backgroundColor = [UIColor clearColor];
        self.backGroundImageView.image = image;
    }else {
        self.backGroundImageView.image = nil;
        _table.backgroundColor = HEXCOLOR(0xD0D0D0);
    }
}

-(void)friendRemarkNotifi:(NSNotification *)notif {
    
    if (self.courseId.length > 0) {
        return;
    }
    WH_JXUserObject *user = notif.object;
    if ([user.userId isEqualToString:chatPerson.userId]) {
        NSString *str = self.onlinestate ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
        self.title = [NSString stringWithFormat:@"%@",user.remarkName.length > 0 ? user.remarkName : user.userNickname];
    }
}

- (void)roomMembersRefreshNotifi:(NSNotification *)notif {
    
//    NSArray * memberArray = [memberData fetchAllMembers:_room.roomId];
    int userSize = [notif.object intValue];
    self.title = [NSString stringWithFormat:@"%@(%d)", self.chatPerson.userNickname, userSize];
}

- (void)actionQuitChatVC:(NSNotification *)notif {
    self.isSelectMore = NO;
    [self actionQuit];
}

- (void)delFriend:(NSNotification *)notif {
    WH_JXUserObject* user = (WH_JXUserObject *)notif.object;

    if ([chatPerson.userId isEqualToString:user.userId]) {
        [self actionQuit];
    }
}

- (void)delRoom:(NSNotification *)notif {
    WH_JXUserObject* user = (WH_JXUserObject *)notif.object;

    if ([chatPerson.userId isEqualToString:user.userId]) {
        [self actionQuit];
    }
}

- (void)sendCourseMsg:(NSNotification *)notif {
    WH_JXMessageObject *msg = (WH_JXMessageObject *)notif.object;
    if ([msg.toUserId isEqualToString:chatPerson.userId]) {
        [self WH_show_WHOneMsg:msg];
    }
}

/**
 刷新列表
 之前业务逻辑没有改动,添加 loadHistory 这个阈值为了解决群聊天提醒类型消息tableview白屏问题
 19.09.25 hanf

 @param msg <#msg description#>
 @param loadHistory yes:加载历史数据 no:不加载历史数据
 */
-(void)refresh:(WH_JXMessageObject*)msg loadHistory:(BOOL)loadHistory
{
    
    if (self.courseId.length > 0) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dict in self.courseArray) {
            [arr addObject:dict[@"message"]];
        }
        _array = arr;
        [_table WH_gotoLastRow:NO];
        self.wh_isShowHeaderPull = NO;
        return;
    }
    
    if (self.chatLogArray.count > 0) {
        _array = self.chatLogArray;
        [self.tableView reloadData];
        self.wh_isShowFooterPull = NO;
        return;
    }
    
    [_messageText setInputView:nil];
    [_messageText resignFirstResponder];
    BOOL b=YES;
    BOOL bPull=NO;
    NSInteger firstNum = 1;
    if([_array count]>0)
        firstNum = _array.count;
    
    
    CGFloat allHeight = 0;
    if(msg == nil){
        NSString* s;
        if([self.roomJid length]>0)
            s = self.roomJid;
        else
            s = chatPerson.userId;
        NSMutableArray* p;
        if (self.isGetServerMsg) {
            // 获取漫游聊天记录
            
            [_wait start];
            
            long starTime;
            long endTime;
            JXSynTask *task = _taskList.firstObject;
            if (task && self.roomJid.length > 0) {
                 starTime = [task.startTime timeIntervalSince1970] * 1000;
                 endTime = [task.endTime timeIntervalSince1970] * 1000;
            }else {
                WH_JXMessageObject *msg = _array.firstObject;
                // 7天前的时间戳
                endTime = [msg.timeSend timeIntervalSince1970] * 1000;
                if (endTime == 0) {
                    endTime = [[NSDate date] timeIntervalSince1970] * 1000;
                }
                starTime = 1262275200000;
            }
            if([self.roomJid length]>0)
               [g_server WH_tigaseMucMsgsWithRoomId:s StartTime:starTime EndTime:endTime PageIndex:0 PageSize:PAGECOUNT toView:self];
            else
                [g_server WH_tigaseMsgsWithReceiver:s StartTime:starTime EndTime:endTime  PageIndex:0 toView:self];
        }else {
            //获取本地聊天记录
            if (self.scrollLine == 0) {
                int pageCount = 20;
                if (self.newMsgCount > 20) {
                    pageCount = self.newMsgCount;
                }
                if (loadHistory) {
                    if (self.roomJid.length > 0 && _taskList.count > 0) {
                        
                        JXSynTask *task = _taskList.firstObject;
                        p = [[WH_JXMessageObject sharedInstance] fetchMessageListWithUser:s byAllNum:_array.count pageCount:pageCount startTime:task.endTime];
                        
                    }else {
                        p = [[WH_JXMessageObject sharedInstance] fetchMessageListWithUser:s byAllNum:_array.count pageCount:pageCount startTime:[NSDate dateWithTimeIntervalSince1970:0]];
                    }
                    //修复历史消息最多加载一页问题
                    bPull = p.count>0;
                }
            }else {
                p = [[WH_JXMessageObject sharedInstance] fetchAllMessageListWithUser:s];
                [_array removeAllObjects];
                bPull = NO;
            }
            
        }
        
        for (WH_JXMessageObject *msg in p) {
            allHeight += [msg.chatMsgHeight floatValue];
        }
        
        self.isGetServerMsg = !bPull;
        
        //获取口令红包记录
        [_orderRedPacketArray addObjectsFromArray:[self fetchRedPacketListWithType:3]];
        
        b = p.count>0;
        bPull = p.count>=PAGE_SHOW_COUNT;
//        if(_page == 0 || self.scrollLine>0)//如果
//            [_array removeAllObjects];
        if(b){
            NSMutableArray* temp = [[NSMutableArray alloc]init];
            [temp addObjectsFromArray:p];
            [temp addObjectsFromArray:_array];
            [_array removeAllObjects];
            [_array addObjectsFromArray:temp];
            [temp removeAllObjects];

        }
        [p removeAllObjects];

    }else
        [_array addObject:msg];
    
    
    WH_JXMessageObject *lastMsg = _array.lastObject;
    if (lastMsg) {
        if (self.roomJid.length > 0) {
            lastMsg.isGroup = YES;
        }
        if (lastMsg.isMySend) {
            if ([lastMsg.isSend boolValue]) {
                [lastMsg updateLastSend:UpdateLastSendType_None];
            }
        }else {
            [lastMsg updateLastSend:UpdateLastSendType_None];
        }
        
        self.lastMsg.content = [lastMsg getLastContent];
    }
    
    
    [self setIsShowTime];
    
    if (b) {
        [_pool removeAllObjects];
        _refreshCount++;
//        [_table reloadData];
//        [_table layoutIfNeeded];
       
//        self.isShowHeaderPull = bPull;
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新完成
            if (self.scrollLine > 0) {
                if (_array.count > 50) {
                    self.isGetServerMsg = NO;
                    self.scrollLine = 0;
                    [_array removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _array.count-15)]];
                    [_table reloadData];
                    [_table WH_gotoLastRow:NO];

                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        
                        [_table reloadData];
    //                    [self scrollToCurrentLine];
                        [_table WH_gotoLastRow:NO];
                    });
                }
                
            }else {
                if(msg || _page == 0){
                    
                    [_table reloadData];
                    if (self.isSyncMsg || self.isGotoLast) {
                        [_table WH_gotoLastRow:NO];
                    }
                }
                else{
                    if([_array count]>0){
                        
                        [_table reloadData];
//                        [_table gotoRow: (int)(_array.count - firstNum + 2)];
//                        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(int)(_array.count - firstNum) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        
                        [_table WH_gotoLastRow:NO];
                        _table.contentOffset = CGPointMake(0, allHeight);
                        
                    }
                }
            }
        });
        
    }
    
}

- (void) scrollToCurrentLine {
    [_table WH_gotoRow:self.scrollLine];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.scrollLine - 1 inSection:0];
//    [_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [g_notify removeObserver:self];
    [g_notify removeObserver:self name:kCellShowCardNotifaction object:nil];
    [g_notify removeObserver:self name:kCellLocationNotifaction object:nil];
    [g_notify removeObserver:self name:kCellImageNotifaction object:nil];
    [g_notify removeObserver:self name:kcellRedPacketDidTouchNotifaction object:nil];
    
    [g_notify removeObserver:self name:kCellHeadImageNotification object:nil];
    [g_notify removeObserver:self name:kHiddenKeyboardNotification object:nil];
    
    NSLog(@"WH_JXChat_WHViewController.dealloc");
    [g_xmpp.chatingUserIds removeObject:current_chat_userId];
    current_chat_userId = nil;

    [self hideKeyboard:NO];
    [self unInitAudio];

    [self free:_pool];
    [_pool removeAllObjects];
//    [_pool release];
    _pool = nil;

    [_array removeAllObjects];
//    [_array release];
    
    
//    [_messageConent release];
    _faceView.delegate = nil;
//    [_table release];
//    [_moreView release];
    _moreView=nil;
    
//    [_voice release];
//    _poolSend = nil;

    _locationVC = nil;
    self.chatPerson = nil;
//    [super dealloc];
    
    [self.enteringTimer invalidate];
    self.enteringTimer = nil;
    [self.noEnteringTimer invalidate];
    self.noEnteringTimer = nil;
    
}

-(void)free:(NSMutableArray*)array{
    for(int i=(int)[array count]-1;i>=0;i--){
        id p = [array objectAtIndex:i];
        [array removeObjectAtIndex:i];
        p = nil;
    }
}

// 正在输入
- (void)enteringNotifi:(NSNotification *) notif {
    WH_JXMessageObject *msg = notif.object;
    if ([chatPerson.userId isEqualToString:msg.fromUserId]) {
        if(msg==nil)
            return;
        if (self.roomJid || msg.isGroup) {
            return;
        }
        self.title = Localized(@"JX_Entering");
        self.noEnteringTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(noEnteringTimerAction:) userInfo:nil repeats:NO];
    }
}

- (void) noEnteringTimerAction:(NSNotification *)notif {
    [self.noEnteringTimer invalidate];
    self.noEnteringTimer = nil;
    if (self.courseId.length > 0) {
        return;
    }
    if([chatPerson.userId intValue]<10100 && [chatPerson.userId intValue]>=10000) {
        self.title = chatPerson.userNickname;
    }else {
        NSString *str = self.onlinestate ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
        self.title = [NSString stringWithFormat:@"%@",chatPerson.remarkName.length > 0 ? chatPerson.remarkName : chatPerson.userNickname];
    }
}

#pragma mark ---触摸关闭键盘----
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


#pragma mark ----键盘高度变化------
-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    
    id view = g_navigation.subViews.lastObject;
    if (![view isEqual:self]) {
        return;
    }
    
    if (!_messageText.isFirstResponder) {
        return;
    }
    
//    return;
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    self.deltaY = deltaY;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    deltaY=-endRect.size.height;
    self.deltaHeight = deltaY;
//    NSLog(@"deltaY:%f",deltaY);
    [CATransaction begin];
    [UIView animateWithDuration:0.4f animations:^{
//        [_table setFrame:CGRectMake(0, 0, _table.frame.size.width, self.view.frame.size.height+deltaY-self.wh_heightFooter)];
//        [_table WH_gotoLastRow:NO];
        self.wh_tableFooter.frame = CGRectMake(0, self.view.frame.size.height+deltaY-self.wh_heightFooter, JX_SCREEN_WIDTH, self.wh_heightFooter);
        
        self.screenShotView.frame = CGRectMake(self.screenShotView.frame.origin.x, self.wh_tableFooter.frame.origin.y - self.screenShotView.frame.size.height - 10, self.screenShotView.frame.size.width, self.screenShotView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    [CATransaction commit];
    
    if ((_table.contentSize.height > (self.view.frame.size.height + deltaY - self.wh_heightFooter - 64 - 40)) || self.deltaY > 0) {
        
        [CATransaction begin];//创建显式事务
        [UIView animateWithDuration:0.1f animations:^{
            //            self.wh_tableFooter.frame = CGRectMake(0, self.view.frame.size.height+deltaY-self.wh_heightFooter, JX_SCREEN_WIDTH, self.wh_heightFooter);
            [_table setFrame:CGRectMake(0, 0+_noticeHeight, _table.frame.size.width, self.view.frame.size.height+deltaY-self.wh_heightFooter-_noticeHeight)];
            [_table WH_gotoLastRow:NO];
        } completion:^(BOOL finished) {
        }];
        [CATransaction commit];
    }
}

- (BOOL)theTextAllSpace:(NSString *)text {
    NSString *string = [text copy];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (string.length <= 0) {
        return YES;
    }
    return NO;
}

- (void)sendIt:(id)sender {
    if([self showDisableSay])
        return;

    if([self sendMsgCheck]){
        return;
    }
    
    NSString *userId = self.userIds[self.groupMessagesIndex];
    //NSString *userName = self.userNames[self.groupMessagesIndex];
    
    NSMutableArray * tempArray = [[NSMutableArray alloc] init];
    for (memberData * member in _atMemberArray) {
        if (member.idStr){
            [tempArray addObject:[NSString stringWithFormat:@"%@",member.idStr]];
        }else{
            [tempArray addObject:[NSString stringWithFormat:@"%ld",member.userId]];
        }
    }
    NSString * ObjectIdStr = [tempArray componentsJoinedByString:@" "];

    if (self.objToMsg.length > 0) {
        ObjectIdStr = self.objToMsg;
    }
    
    
    NSString *message = [_messageText.textStorage getPlainString];
    if ([self theTextAllSpace:message]) {
        // txt全是空格
        _messageText.text = @"";
        [self doEndEdit];
        //不能发送空白消息
        [g_App showAlert:Localized(@"JX_CannotSendBlankMessage")];
        return;
    }
    if (message.length > 0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.content      = message;
        if (self.objToMsg.length > 0) {
            msg.type         = [NSNumber numberWithInt:kWCMessageTypeReply];
        }else {
            msg.type         = [NSNumber numberWithInt:kWCMessageTypeText];
        }
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];

        msg.isReadDel = self.chatPerson.isOpenReadDel;
        if (ObjectIdStr.length > 0){
            msg.objectId = ObjectIdStr;
        }
        //发往哪里
        [msg insert:self.roomJid];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        
        if (self.isGroupMessages) {//群发消息
            self.groupMessagesIndex ++;
            if (self.groupMessagesIndex < self.userIds.count) {
                [self sendIt:nil];
            }else if (self.userIds){
                self.groupMessagesIndex = 0;
                _messageText.text = nil;
                [self hideKeyboard:YES];
                [g_App showAlert:Localized(@"JX_SendComplete")];
                //返回到消息界面
                [self actionQuit];
                return;
            }
            return;
        }
        
        [self WH_show_WHOneMsg:msg];
        
        if (_table.contentSize.height > (JX_SCREEN_HEIGHT + self.deltaHeight - self.wh_heightFooter - 64 - 40 - 20)) {
            if (self.deltaY >= 0) {
                
            }else {
                
                if (self.wh_tableFooter.frame.origin.y != JX_SCREEN_HEIGHT-self.wh_heightFooter) {
                    [CATransaction begin];
                    [UIView animateWithDuration:0.1f animations:^{
                        //            self.wh_tableFooter.frame = CGRectMake(0, self.view.frame.size.height+deltaY-self.wh_heightFooter, JX_SCREEN_WIDTH, self.wh_heightFooter);
                        [_table setFrame:CGRectMake(0, 0+_noticeHeight, _table.frame.size.width, self.view.frame.size.height+self.deltaHeight-self.wh_heightFooter-_noticeHeight)];
                        //                [_table WH_gotoLastRow:NO];
                    } completion:^(BOOL finished) {
                    }];
                    [CATransaction commit];
                }
            }
        }
    }
         
    //检查是否有口令红包
    WH_JXMessageObject * msg = nil;
    for (NSInteger i = _orderRedPacketArray.count-1; i >= 0; i--) {
        msg = _orderRedPacketArray[i];
        if ([msg.content caseInsensitiveCompare:_messageText.text] == NSOrderedSame &&[msg.fileSize intValue] != 2) {
            if (self.roomJid.length > 0 || ![msg.fromUserId isEqualToString:MY_USER_ID]) {
                //关闭键盘
                [self.view endEditing:YES];
                //获取红包请求
                [g_server WH_getRedPacketWithMsg:msg.objectId toView:self];
                break; //找到一个口令红包请求直接break循环,防止多个相同口令红包弹出
            }
        }
    }
    [_atMemberArray removeAllObjects];
    [_messageText.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0,_messageText.text.length)];
    //[_messageText.textStorage removeAttribute:NSFontAttributeName range:NSMakeRange(0,_messageText.text.length)];
    [_messageText setText:nil];
    [_messageText setAttributedText:nil];

    chatPerson.lastInput = _messageText.text;
    [chatPerson updateLastInput];
    
    //发送消息后重置底部控件
    [self onBackForRecordBtnLeft];
}

//本地插入自己阅后即焚时间提醒,刷新显示,不发送xmpp
-(void)sendReadDelMsg:(NSNumber *)readDel {
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = _userNickName;
    msg.toUserId     = self.chatPerson.userId;
    msg.isGroup = NO;
    
    msg.content      = @"";
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeWithReadDele];
    
    msg.isSend       = [NSNumber numberWithInt:1];
    msg.isRead       = [NSNumber numberWithBool:1];
//    NSArray *secondArr = @[@(5), @(10), @(30), @(60),@(300) , @(30 * 60), @(60 * 60), @(6 * 60 * 60), @(12 * 60 * 60), @(24 * 60 * 60), @(7 * 24 * 60 * 60)];
//    msg.timeLen = readDel.integerValue<secondArr.count?secondArr[readDel.integerValue]:@5;
    
    msg.isReadDel = readDel;
    
    //发往哪里
    [msg insert:self.roomJid];
    [self WH_show_WHOneMsg:msg];
}

//本地插入对方阅后即焚时间提醒,刷新显示,不发送xmpp
-(void)readReadDelMsg:(WH_JXMessageObject *)p {
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.readTime     = [NSDate date];
    msg.fromUserId   = p.fromUserId;
    
    msg.fromUserName = p.fromUserName;
    msg.toUserId     = p.toUserId;
    msg.isGroup = NO;
    
    msg.content      = @"";
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeWithReadDele];
    
    msg.isSend       = [NSNumber numberWithInt:1];
    msg.isRead       = [NSNumber numberWithBool:1];
//    NSArray *secondArr = @[@(5), @(10), @(30), @(60),@(300) , @(30 * 60), @(60 * 60), @(6 * 60 * 60), @(12 * 60 * 60), @(24 * 60 * 60), @(7 * 24 * 60 * 60)];
//    NSNumber *readDel = p.isReadDel;
//    msg.timeLen = readDel.integerValue<secondArr.count?secondArr[readDel.integerValue]:@5;
    msg.isReadDel = p.isReadDel;
    //发往哪里
    [msg insert:self.roomJid];
    [self WH_show_WHOneMsg:msg];
}

//图片piker选择完成后调用
-(void)sendImage:(NSString *)file withWidth:(int) width andHeight:(int) height userId:(NSString *)userId
{
    
//    NSString *userId = self.userIds[self.groupMessagesIndex];
//    NSString *userName = self.userNames[self.groupMessagesIndex];
    
    if ([file length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.fileName     = file;
        msg.content      = [[file lastPathComponent] stringByDeletingPathExtension];
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeImage];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isUpload     = [NSNumber numberWithBool:NO];
        //新添加的图片宽高
        msg.location_x = [NSNumber numberWithInt:width];
        msg.location_y = [NSNumber numberWithInt:height];
        
        msg.isReadDel    = self.chatPerson.isOpenReadDel;
        
        [msg insert:self.roomJid];
        
        [self WH_show_WHOneMsg:msg];
//        if (self.isGroupMessages) {
//            self.groupMessagesIndex ++;
//            if (self.groupMessagesIndex < self.userIds.count) {
//                [self sendImage:file withWidth:width andHeight:height];
//            }else if (self.userIds){
//                self.groupMessagesIndex = 0;
//
//                return;
//            }
//            return;
//        }
//        [msg release];
        
/*直接上传服务器,改为上传obs*/
//        [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:msg.messageId toView:self];
        
        [OBSHanderTool handleUploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:msg.messageId toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                //请求
                NSMutableDictionary* p = [NSMutableDictionary dictionary];
                
                [p setValue:fileUrl forKey:@"oUrl"];
                [p setValue:fileName forKey:@"oFileName"];
                [p setValue:@"1" forKey:@"status"];
                if (self.isMapMsg) {
                    [self sendMapMsgWithDict:p];
                }else {
                    [self WH_doSendAfterUpload:p];
                }
                p = nil;
            }
        } failed:^(NSError * _Nonnull error) {

        }];
    }
}

//返回文件大小(单位M)
- (double)fileSizeAtPath:(NSString*)filePath
{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:filePath]){
//        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize] / (1024.0*1024.0);
//    }
//    return 0;
    struct stat statbuf;
    const char *cpath = [filePath fileSystemRepresentation];
    if (cpath && stat(cpath, &statbuf) == 0) {
        NSNumber *fileSize = [NSNumber numberWithUnsignedLongLong:statbuf.st_size];
        return [fileSize doubleValue] / (1024.0*1024.0);
    }
    return 0;
}

//发送视频，以后要改视频长宽
-(void)sendMedia:(WH_JXMediaObject*)p userId:(NSString *)userId
{
    double fileSize = [self fileSizeAtPath:p.fileName];
    if (fileSize > g_config.uploadMaxSize) {
        [g_App showAlert:[NSString stringWithFormat:@"文件超出%dM限制!",g_config.uploadMaxSize]];
        return;
    }
    
    NSString* file = p.fileName;
    if ([file length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.fileName     = file;
        msg.content      = [[file lastPathComponent] stringByDeletingPathExtension];
        if(p.isVideo)
            msg.type         = [NSNumber numberWithInt:kWCMessageTypeVideo];
        else
            msg.type         = [NSNumber numberWithInt:kWCMessageTypeAudio];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isUpload     = [NSNumber numberWithBool:NO];
        msg.location_x = [NSNumber numberWithInt:100];
        msg.location_y = [NSNumber numberWithInt:100];
        msg.isReadDel    = self.chatPerson.isOpenReadDel;

            
        [msg insert:self.roomJid];
        [self WH_show_WHOneMsg:msg];

        /*直接上传服务器,改为上传obs*/
//        [g_server uploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:msg.messageId toView:self];

        [OBSHanderTool handleUploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:msg.messageId toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                //请求
                NSMutableDictionary* p = [NSMutableDictionary dictionary];
                [p setValue:fileUrl forKey:@"oUrl"];
                [p setValue:fileName forKey:@"oFileName"];
                [p setValue:@"1" forKey:@"status"];
                if (self.isMapMsg) {
                    [self sendMapMsgWithDict:p];
                }else {
                    [self WH_doSendAfterUpload:p];
                }
                p = nil;
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
}

- (void)shareMore:(UIButton*)sender {
//    [messageText setInputView:messageText.inputView?nil: _moreView];
    if([self showDisableSay])
        return;
    if (!_moreView) {
        return;
    }
    sender.selected = !sender.selected;
    if(_messageText.inputView != _moreView){
        _messageText.inputView = _moreView;
        [_messageText reloadInputViews];
        [_messageText becomeFirstResponder];
        _textViewBtn.hidden = NO;
        
        if (self.screenShotView.hidden) {
            ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
            
            [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    [group enumerateAssetsWithOptions:NSEnumerationReverse/*遍历方式*/ usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            int photoIndex = [[g_default objectForKey:LastPhotoIndex] intValue];
                            if (photoIndex == index) {
                                *stop = YES;
                                return;
                            }
                            [g_default setObject:[NSNumber numberWithInteger:index] forKey:LastPhotoIndex];
                            NSString *type = [result valueForProperty:ALAssetPropertyType];
                            if ([type isEqual:ALAssetTypePhoto]){
                                UIImage *needImage = [UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];
                                if (needImage) {
                                    self.screenImage = needImage;
                                    self.screenShotImageView.image = needImage;
                                    self.screenShotView.hidden = NO;
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        self.screenShotView.hidden = YES;
                                        
                                    });
                                }else {
                                    [self hideKeyboard:YES];
                                }
                            }
                            *stop = YES;
                        }
                    }];
                    *stop = YES;
                    
                }
            } failureBlock:^(NSError *error) {
                if (error) {
                    
                }
            }];
        }
        
        
        
        
//        if (self.screenShotView.hidden) {
//            UIImage *image = [UIImage imageWithContentsOfFile:ScreenShotImage];
//            if (image) {
//                self.screenShotImageView.image = image;
//                self.screenShotView.hidden = NO;
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    self.screenShotView.hidden = YES;
//                     NSFileManager* fileManager=[NSFileManager defaultManager];
//                    BOOL blDele= [fileManager removeItemAtPath:ScreenShotImage error:nil];
//                    if (blDele) {
//                        NSLog(@"dele success");
//                    }else {
//                        NSLog(@"dele fail");
//                    }
//                });
//            }
//        }
    }
    else{
        [self hideKeyboard:YES];
    }
}
//遍历消息，添加时间
- (void)setIsShowTime{
    if([_array count]<=0)
        return;
    WH_JXMessageObject *firstMsg=[_array objectAtIndex:0];
    if (!firstMsg.isShowTime) {
        
        firstMsg.isShowTime = YES;
        [firstMsg updateIsShowTime];
        firstMsg.chatMsgHeight = [NSString stringWithFormat:@"0"];
        [firstMsg updateChatMsgHeight];
    }
    
    
    for (int i = 0; i < [_array count] -1 ; i++) {
        WH_JXMessageObject *firstMsg=[_array objectAtIndex:i];
        WH_JXMessageObject *secondMsg=[_array objectAtIndex:(i+1)];

        if(([secondMsg.timeSend timeIntervalSince1970]-[firstMsg.timeSend timeIntervalSince1970]>15*60)){
            if (!secondMsg.isShowTime) {
                secondMsg.isShowTime = YES;
                [secondMsg updateIsShowTime];
                secondMsg.chatMsgHeight = [NSString stringWithFormat:@"0"];
                [secondMsg updateChatMsgHeight];
            }
        }else {
            if (secondMsg.isShowTime) {
                secondMsg.isShowTime = NO;
                [secondMsg updateIsShowTime];
                secondMsg.chatMsgHeight = [NSString stringWithFormat:@"0"];
                [secondMsg updateChatMsgHeight];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideKeyboard:NO];
}

//新来的消息是否需要展示时间
- (void)setNewShowTime:(WH_JXMessageObject *)msg{
    WH_JXMessageObject *lastMsg=[_array lastObject];
    NSLog(@"%f",[msg.timeSend timeIntervalSince1970]-[lastMsg.timeSend timeIntervalSince1970]);

    if(([msg.timeSend timeIntervalSince1970]-[lastMsg.timeSend timeIntervalSince1970]>15*60)){
        if (!msg.isShowTime) {
            msg.isShowTime = YES;
            [msg updateIsShowTime];
            msg.chatMsgHeight = [NSString stringWithFormat:@"0"];
            [msg updateChatMsgHeight];
        }
    }else {
        if (msg.isShowTime) {
            msg.isShowTime = NO;
            [msg updateIsShowTime];
            msg.chatMsgHeight = [NSString stringWithFormat:@"0"];
            [msg updateChatMsgHeight];
        }
    }
}

- (void)viewDidLayoutSubviews {
    
    if (!self.scrollBottom) {
        if (_table.contentSize.height > _table.bounds.size.height) {
            self.isGotoLast = NO;
            [_table setContentOffset:CGPointMake(0, _table.contentSize.height - _table.bounds.size.height) animated:NO];
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        self.scrollBottom = YES;
    });
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    WH_JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
//    
////    bool isContent = NO;
////    //判断消息池里面是否含有此消息
////    for (WH_JXMessageObject * obj in g_xmpp.poolSendRead) {
////        //含有，直接跳过
////        if ([obj.content isEqualToString:msg.messageId]) {
////            isContent = YES;
////            break;
////        }
////    }
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMessageObject *msg;
    if (indexPath.row<_array.count) {
        msg=[_array objectAtIndex:indexPath.row];
    }else{
        msg = [[WH_JXMessageObject alloc] init];
    }
    
    msg.showRead = [self.chatPerson.showRead boolValue];
    
//    NSLog(@"indexPath.row:%ld,%ld",indexPath.section,indexPath.row);
    
    if (msg.type.integerValue == kWCMessageTypeWithReadDele) {
        return [self WH_creat_WHReadDelCell:msg indexPath:indexPath];
    }
    
    if ([msg.isReadDel boolValue]) {
        g_myself.isOpenReadDel = msg.isReadDel;
        self.chatPerson.isOpenReadDel = msg.isReadDel;
    }
    if (self.roomJid){
        msg.isGroup = YES;
//        msg.roomJid = self.roomJid;
    }
    
    //如果是新来的未读消息，回执通知
    if ([msg.type intValue] != kWCMessageTypeVoice && [msg.type intValue] != kWCMessageTypeVideo && [msg.type intValue] != kWCMessageTypeFile && [msg.type intValue] != kWCMessageTypeLocation && [msg.type intValue] != kWCMessageTypeCard && [msg.type intValue] != kWCMessageTypeLink && [msg.type intValue] != kWCMessageTypeMergeRelay && [msg.type intValue] != kWCMessageTypeShare && [msg.type intValue] != kWCMessageTypeIsRead) {
        memberData *member = [[memberData alloc] init];
        member.roomId = roomId;
        memberData *roleM = [member getCardNameById:MY_USER_ID];
        // 隐身人不发回执（已读列表不显示）
        if (![msg.isReadDel boolValue] && [roleM.role intValue] !=4) {
            [msg WH_sendAlreadyRead_WHMsg];
        }
    }
    
    
    //返回对应的Cell
    WH_JXBaseChat_WHCell * cell = [self getCell:msg indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.isSelectMore = self.isSelectMore;
    cell.room = _room;

//    memberData *data = [self.room getMember:g_myself.userId];
//    BOOL flag = [data.role intValue] == 1 || [data.role intValue] == 2;
//    if (!flag && ![self.chatPerson.allowSpeakCourse boolValue]) {
//        cell.isShowRecordCourse = NO;
//    }else {
//        cell.isShowRecordCourse = YES;
//    }
    if ([chatPerson.userId rangeOfString:MY_USER_ID].location == NSNotFound) {
        cell.isShowRecordCourse = YES;
    }else {
        cell.isShowRecordCourse = NO;
    }
    cell.chatPerson = self.chatPerson;
    cell.isBanned = [self showDisableSay];
    cell.bannedRemind = self.bannedRemind;
    
    cell.msg = msg;
    cell.isCourse = self.courseId.length > 0;
    cell.indexNum = (int)indexPath.row;
    cell.delegate = self;
    cell.chatCellDelegate = self;
    cell.checkBox.selected = NO;
    for (WH_JXMessageObject *selMsg in self.selectMoreArr) {
        if ([selMsg.messageId isEqualToString:msg.messageId]) {
            cell.checkBox.selected = YES;
            break;
        }
    }
    cell.readDele = @selector(readDeleWithUser:);
    if ([msg.type intValue] == kWCMessageTypeShake) {
        if (![msg.fileName isEqualToString:@"1"]) {
            self.shakeMsg = msg;
        }
    }
    if (self.roomJid.length > 0) {
        cell.isShowHead = [self.chatPerson.allowSendCard boolValue] || _isAdmin;
        cell.isWithdraw = msg.isMySend || _isAdmin;
    }else {
        cell.isShowHead = YES;
        cell.isWithdraw = msg.isMySend;
    }
    [cell setHeaderImage];
    [cell setCellData];
    
//    if (msg.type.integerValue != kWCMessageTypeImage) {
//        //偏移气泡位置
//    if (!msg.isMySend) {
//        CGRect bubbleF = cell.bubbleBg.frame;
//        bubbleF.origin.x += 4.0f;
//        cell.bubbleBg.frame = bubbleF;
//    }
//    }
    
    //偏移未读小红点位置
//    CGPoint readCenter = cell.readImage.center;
//    readCenter.x += 4;
//    cell.readImage.center = readCenter;
    
    [cell setBackgroundImage];
    [cell isShowSendTime];
    
    //转圈等待
    if ([msg.isSend intValue] == transfer_status_ing) {
        
        BOOL flag = NO;
        for (NSInteger i = 0; i < g_xmpp.poolSend.allKeys.count; i ++) {
            NSString *msgId = g_xmpp.poolSend.allKeys[i];
            if ([msgId isEqualToString:msg.messageId]) {
                flag = YES;
                break;
            }
        }
        
        if (flag || msg.isShowWait) {
            if ([cell respondsToSelector:@selector(drawIsSend)]) {
                [cell drawIsSend];
            }
            
        }else {
            [msg updateIsSend:transfer_status_no];
            cell.sendFailed.hidden = NO;
        }
    }
    
    if (indexPath.row == _array.count - 1) {
        // 戳一戳
        if (self.shakeMsg) {
            int value = 0;
            if (self.shakeMsg.isMySend) {
                value = -50;
            }else {
                value = 50;
            }
            
            self.shakeMsg = nil;
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];///横向移动
            
            animation.toValue = [NSNumber numberWithInt:value];
            
            animation.duration = .5;
            
            animation.removedOnCompletion = YES;//yes的话，又返回原位置了。
            
            animation.repeatCount = 2;
            
            animation.fillMode = kCAFillModeForwards;
            
            _shakeBgView.hidden = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animation.duration * animation.repeatCount * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _shakeBgView.hidden = YES;
            });
            
            [_messageText.inputView.superview.layer addAnimation:animation forKey:nil];
            [self.view.layer removeAnimationForKey:@"transform.translation.x"];
            [self.view.layer addAnimation:animation forKey:nil];

        }
        
    }
    
    //阅后即焚按钮 存在阅后即焚
//    __weak typeof(self)weakSelf = self;
//    cell.clickSettingBtnClick = ^{
//        //去设置
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        [strongSelf createRoom];
//    };
    if ([msg.type integerValue] == kWCMessageTypeVideoChatAsk || [msg.type integerValue] == kWCMessageTypeAudioChatAsk) {
        [cell.contentView removeFromSuperview];
    }
    return cell;
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMessageObject *msg ;
    if (_array.count > indexPath.row) {
        msg=[_array objectAtIndex:indexPath.row];
    }
    
    if (self.roomJid)
        msg.isGroup = YES;
    
    if (msg) {
        switch ([msg.type intValue]) {
            case kWCMessageTypeText:
                return [WH_JXMessage_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeImage:
                return [WH_JXImage_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeWithReadDele:
                return 80;
                break;
            case kWCMessageTypeVoice:
                return [WH_JXAudio_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeLocation:
                return [WH_JXLocation_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeGif:
                return [WH_JXGif_WHCell getChatCellHeight:msg] + 10;
                break;
            case kWCMessageTypeVideo:
                return [WH_JXVideo_WHCell getChatCellHeight:msg] + 20;
                break;
            case kWCMessageTypeAudio:
                return [WH_JXVideo_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeCard:
                return [WH_JXCard_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeFile:
                return [WH_JXFile_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeRemind:
                return [WH_JXRemind_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeRedPacket:
                return [WH_JXRedPacket_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeRedPacketExclusive:
                return [WH_JXRedPacket_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeTransfer:
                return [WH_JXTransfer_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeSystemImage1:
                return [WH_JXSystemImage1_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeSystemImage2:
                return [WH_JXSystemImage2_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeAudioMeetingInvite:
            case kWCMessageTypeVideoMeetingInvite:
            case kWCMessageTypeAudioChatCancel:
            case kWCMessageTypeAudioChatEnd:
            case kWCMessageTypeVideoChatCancel:
            case kWCMessageTypeVideoChatEnd:
                return [WH_JXAVCall_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeLink:
                return [WH_JXLink_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeShake:
                return [WH_JXShake_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeMergeRelay:
                return [WH_JXMergeRelay_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeShare:
                return [WH_JXShare_WHCell getChatCellHeight:msg];
                break;
            case kWCMessageTypeReply:
                return [WH_JXReply_WHCell getChatCellHeight:msg];
                break;
            default:
                return [WH_JXBaseChat_WHCell getChatCellHeight:msg];
                break;
        }
    }else{
        return 0;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self hideKeyboard:NO];
    if (self.isSelectMore) {
        //获取第几个Cell被点击
        
        _selCell = (WH_JXBaseChat_WHCell*)[_table cellForRowAtIndexPath:indexPath];
        _selCell.checkBox.selected = !_selCell.checkBox.selected;
        NSLog(@"indexNum = %d, isSelect = %d",_selCell.indexNum, _selCell.checkBox.selected);
        [self chatCell:_selCell checkBoxSelectIndexNum:_selCell.indexNum isSelect:_selCell.checkBox.selected];
    }else {
        
//        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        
        self.jumpNewMsgBtn.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideKeyboard:NO];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _array.count) {
        
        WH_JXMessageObject *msg = _array[indexPath.row];
        if ([msg.type intValue] == kWCMessageTypeText) {
            
            WH_JXBaseChat_WHCell * basecell = (WH_JXBaseChat_WHCell *)cell;
            if ([basecell isKindOfClass:[WH_JXBaseChat_WHCell class]]) {
                
                [basecell.readDelTimer invalidate];
                basecell.readDelTimer = nil;
            }
        }
    }
}

#pragma mark -----------------获取对应的Cell-----------------
- (WH_JXBaseChat_WHCell *)getCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    WH_JXBaseChat_WHCell * cell = nil;
    switch ([msg.type intValue]) {
        case kWCMessageTypeText:
            cell = [self WH_creat_WHMessageCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeImage:
            cell = [self WH_creat_WHImageCell:msg indexPath:indexPath];
            break;
        
        case kWCMessageTypeVoice:
            cell = [self WH_creat_WHAudioCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeLocation:
            cell = [self WH_creat_WHLocationCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeGif:
            cell = [self WH_creat_WHGifCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeVideo:
            cell = [self WH_creat_WHVideoCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeAudio:
            cell = [self WH_creat_WHVideoCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeCard:
            cell = [self WH_creat_WHCardCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeFile:
            cell = [self WH_creat_WHFileCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeRemind:
            cell = [self WH_creat_WHRemindCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeRedPacket:
            cell = [self WH_creat_WHRedPacketCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeRedPacketExclusive:
            cell = [self WH_creat_WHRedPacketCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeTransfer:
            cell = [self WH_creat_WHTransferCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeSystemImage1:
            cell = [self WH_creat_SystemImage1Cell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeSystemImage2:
            cell = [self WH_creat_SystemImage2Cell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeAudioMeetingInvite:
        case kWCMessageTypeVideoMeetingInvite:
        case kWCMessageTypeAudioChatCancel:
        case kWCMessageTypeAudioChatEnd:
        case kWCMessageTypeVideoChatCancel:
        case kWCMessageTypeVideoChatEnd:
            cell = [self WH_creat_AVCallCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeLink:
            cell = [self WH_creat_LinkCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeShake:
            cell = [self WH_creat_ShakeCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeMergeRelay:
            cell = [self WH_creat_MergeRelayCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeShare:
            cell = [self WH_creat_WHShareCell:msg indexPath:indexPath];
            break;
        case kWCMessageTypeReply:
            cell = [self WH_creat_WHReplyCell:msg indexPath:indexPath];
            break;
        default:
            cell = [[WH_JXBaseChat_WHCell alloc] init];
            break;
    }
    return cell;
}

#pragma  mark -----------------------创建对应的Cell---------------------
//文本
- (WH_JXBaseChat_WHCell *)WH_creat_WHMessageCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXMessage_WHCell";
    if ([msg.isReadDel boolValue]) {
        identifier = [NSString stringWithFormat:@"WH_JXMessage_WHCell_%ld",indexPath.row];
    }
    WH_JXMessage_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXMessage_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

    }
    return cell;
}
//图片
- (WH_JXBaseChat_WHCell *)WH_creat_WHImageCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXImage_WHCell";
    WH_JXImage_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXImage_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.chatImage.delegate = self;
//        cell.chatImage.didTouch = @selector(onCellImage:);
    }
    return cell;
}


//阅后即焚提示消息
- (WH_ReadDelTimeCell *)WH_creat_WHReadDelCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_ReadDelTimeCell";
    WH_ReadDelTimeCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_ReadDelTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //阅后即焚按钮 存在阅后即焚
    __weak typeof(self)weakSelf = self;
    cell.clickSettingBtnClick = ^{
        //去设置
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf createRoom];
    };

    cell.msg = msg;
    return cell;
}

//视频
- (WH_JXBaseChat_WHCell *)WH_creat_WHVideoCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXVideo_WHCell";
    WH_JXVideo_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXVideo_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.videoDelegate = self;
    cell.indexTag = indexPath.row;

    return cell;
}
//音频
- (WH_JXBaseChat_WHCell *)WH_creat_WHAudioCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXAudio_WHCell";
    WH_JXAudio_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXAudio_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.indexNum = (int)indexPath.row;
    return cell;
}
//文件
- (WH_JXBaseChat_WHCell *)WH_creat_WHFileCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXFile_WHCell";
    WH_JXFile_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXFile_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//位置
- (WH_JXBaseChat_WHCell *)WH_creat_WHLocationCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXLocation_WHCell";
    WH_JXLocation_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXLocation_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//名片
- (WH_JXBaseChat_WHCell *)WH_creat_WHCardCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXCard_WHCell";
    WH_JXCard_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXCard_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//红包
- (WH_JXBaseChat_WHCell *)WH_creat_WHRedPacketCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXRedPacket_WHCell";
    WH_JXRedPacket_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXRedPacket_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//动画
- (WH_JXBaseChat_WHCell *)WH_creat_WHGifCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXGif_WHCell";
    WH_JXGif_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXGif_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//系统提醒
- (WH_JXBaseChat_WHCell *)WH_creat_WHRemindCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXRemind_WHCell";
    WH_JXRemind_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXRemind_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 单条图文
- (WH_JXBaseChat_WHCell *)WH_creat_SystemImage1Cell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXSystemImage1_WHCell";
    WH_JXSystemImage1_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXSystemImage1_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 多条图文
- (WH_JXBaseChat_WHCell *)WH_creat_SystemImage2Cell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXSystemImage2_WHCell";
    WH_JXSystemImage2_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXSystemImage2_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 音视频通话
- (WH_JXBaseChat_WHCell *)WH_creat_AVCallCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXAVCall_WHCell";
    WH_JXAVCall_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXAVCall_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 链接
- (WH_JXBaseChat_WHCell *)WH_creat_LinkCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXLink_WHCell";
    WH_JXLink_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXLink_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 戳一戳
- (WH_JXBaseChat_WHCell *)WH_creat_ShakeCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXShake_WHCell";
    WH_JXShake_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXShake_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 合并转发消息
- (WH_JXBaseChat_WHCell *)WH_creat_MergeRelayCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXMergeRelay_WHCell";
    WH_JXMergeRelay_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXMergeRelay_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//分享
- (WH_JXBaseChat_WHCell *)WH_creat_WHShareCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath {
    NSString * identifier = @"WH_JXShare_WHCell";
    WH_JXShare_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXShare_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
// 转账
- (WH_JXBaseChat_WHCell *)WH_creat_WHTransferCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath {
    NSString * identifier = @"WH_JXTransfer_WHCell";
    WH_JXTransfer_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXTransfer_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
// 回复
- (WH_JXBaseChat_WHCell *)WH_creat_WHReplyCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath {
    NSString * identifier = @"WH_JXReply_WHCell";
    WH_JXReply_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXReply_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 显示全屏视频播放
- (void)WH_showVideoPlayerWithTag:(NSInteger)tag {
    [self hideKeyboard:NO];
    self.indexNum = (int)tag;
    
    _player= [WH_JXVideoPlayer alloc];
    _player.type = JXVideoTypeChat;
    _player.isShowHide = YES; //播放中点击播放器便销毁播放器
    _player.isStartFullScreenPlay = YES; //全屏播放
    _player.WH_didVideoPlayEnd = @selector(WH_didVideoPlayEnd);
    _player.delegate = self;
    WH_JXMessageObject *msg ;
    if (_array.count > tag) {
        msg = [_array objectAtIndex:tag];
    }
    if ([msg.fileName isUrl] || self.isShare) {
        _player.videoFile = msg.fileName;
    }else  if(isFileExist(msg.fileName)) {
        _player.videoFile = msg.fileName;
    }else {
        _player.videoFile = msg.content;
    }
        
    _player = [_player initWithParent:self.view];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player wh_switch];
    });
}


//销毁播放器
- (void)WH_didVideoPlayEnd {
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    WH_JXVideo_WHCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexNum inSection:0]];
    if (!cell.msg.isMySend) {
        //WH_JXMessageObject *msg = _array[self.indexNum];
        //[cell drawIsRead];
    }
}


-(void)WH_show_WHOneMsg:(WH_JXMessageObject*)msg{
    for(int i=0;i<[_array count];i++){
        WH_JXMessageObject* p = (WH_JXMessageObject*)[_array objectAtIndex:i];
        if([p.messageId isEqualToString:msg.messageId])
            return;
        p = nil;
    }
    //判断是否展示时间
    [self setNewShowTime:msg];
    CGFloat height = 0;
    if (_array.count > 0) {
        height = [self tableView:_table heightForRowAtIndexPath:[NSIndexPath indexPathForRow:_array.count - 1 inSection:0]];
    }
    
    BOOL flag = NO;
    if (fabs(_table.contentOffset.y + _table.frame.size.height - _table.contentSize.height) < height) {
        flag = YES;
    }
    msg.isShowWait = YES;
//    if ([msg.type intValue] == kWCMessageTypeVideo||
//        [msg.type intValue] == kWCMessageTypeVoice||
//        [msg.type intValue] == kWCMessageTypeImage||
//        [msg.type intValue] == kWCMessageTypeReply||
//        [msg.type intValue] == kWCMessageTypeText) {
//#ifdef IS_SHOW_NEWReadDelete
//        if ([msg.isReadDel boolValue]) {
//            if (!msg.isMySend) {
//
//                if (_gfReadDel != msg.isReadDel.integerValue) {
//                    msg.isShowDel = @1;
//                    _gfReadDel = msg.isReadDel.integerValue;
//                }
//            }else {
//                if (_myReadDel != msg.isReadDel.integerValue) {
//                    msg.isShowDel = @1;
//                    _myReadDel = msg.isReadDel.integerValue;
//                }
//            }
//        }
//#else
//#endif
//    }
    [_array addObject:msg];

    if (self.isGroupMessages) {
        return;
    }
    if ([msg.type intValue] == kWCMessageTypeRedPacket || [msg.type intValue] == kWCMessageTypeRedPacketExclusive) {
        [_orderRedPacketArray addObject:msg];
    }
   

    [_table WH_insertRow:(int)[_array count]-1 section:0];
    if (flag || msg.isMySend) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_table WH_gotoLastRow:NO];
        });
    }

}

//上传完成后，发消息
-(void)WH_doSendAfterUpload:(NSDictionary*)dict{
    
    NSString* msgId = [dict objectForKey:@"oUrl"];
    msgId = [[msgId lastPathComponent] stringByDeletingPathExtension];
    NSString* oFileName = [dict objectForKey:@"oFileName"];

//    NSString *userId = self.userIds[self.groupMessagesIndex];
//    NSString *userName = self.userNames[self.groupMessagesIndex];
    
    WH_JXMessageObject* p=nil;
    int found=-1;
    for(int i=(int)[_array count]-1;i>=0;i--){
        p = [_array objectAtIndex:i];
        if([p.type intValue]==kWCMessageTypeLocation)
            if([[p.fileName lastPathComponent] isEqualToString:[oFileName lastPathComponent]]){
                found = i;
                break;
            }
        if([p.type intValue]==kWCMessageTypeFile && ![p.isUpload boolValue])
            if([[p.fileName lastPathComponent] isEqualToString:[oFileName lastPathComponent]]){
                found = i;
                break;
            }
        if (p.content.length > 0) {
            if ([oFileName rangeOfString:p.content].location != NSNotFound) {
                found = i;
                break;
            }
        }
//        if([p.content isEqualToString:msgId]){
//            found = i;
//            break;
//        }
        p = nil;
    }
    if(found>=0){//找到消息体
        if([[dict objectForKey:@"status"] intValue] != 1){
            NSLog(@"doUploadFaire");
            [p updateIsSend:transfer_status_no];
            WH_JXBaseChat_WHCell* cell = [self getCell:found];
            [cell drawIsSend];
            cell = nil;
            return;
        }
        NSLog(@"doSendAfterUpload");
        p.content  = [dict objectForKey:@"oUrl"];
//        if (self.isGroupMessages) {
//            p.toUserId = userId;
//        }
        [p updateIsUpload:YES];
        [g_xmpp sendMessage:p roomName:self.roomJid];//发送消息
//        [self.tableView reloadData];
    }
    
    p = nil;
    if (self.isGroupMessages) {

        self.groupMessagesIndex ++;
        if (self.userIds && self.groupMessagesIndex >= self.userIds.count) {
            
            self.groupMessagesIndex = 0;
            [JXMyTools showTipView:Localized(@"JX_SendComplete")];
//            [g_App showAlert:Localized(@"JX_SendComplete")];
        }
        
//        if (self.groupMessagesIndex < self.userIds.count) {
//            [self WH_doSendAfterUpload:dict];
//        }else if (self.userIds){
//            self.groupMessagesIndex = 0;
//            [g_App showAlert:Localized(@"JX_SendComplete")];
//            return;
//        }
    }
}

//上传完成后，发消息
-(void)WH_doUploadError:(WH_JXConnection*)downloader{
    NSString* msgId = downloader.userData;
    msgId = [[msgId lastPathComponent] stringByDeletingPathExtension];
    
    for(int i=(int)[_array count]-1;i>=0;i--){
        WH_JXMessageObject* p = [_array objectAtIndex:i];
        if([p.content isEqualToString:msgId]){
            [p updateIsSend:transfer_status_no];
            [[self getCell:i] drawIsSend];
            return;
        }
        p = nil;
    }
}

-(void)WH_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    WH_JXMessageObject *msg     = (WH_JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;

    if ([msg.type intValue] == kWCMessageTypeWithdraw) {
        [_wait stop];
        [g_App showAlert:Localized(@"JX_WithdrawFailed")];
        return;
    }
    
    for(int i=(int)[_array count]-1;i>=0;i--){
        WH_JXMessageObject* p = [_array objectAtIndex:i];
        if(p == msg){
//            NSLog(@"receive:onSendTimeout");
            [[self getCell:i] drawIsSend];
            break;
        }
        p = nil;
    }
}


-(void)WH_onReceiveFile:(NSNotification *)notifacation//收到下载状态
{
    WH_JXMessageObject *msg     = (WH_JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    
    for(int i=(int)[_array count]-1;i>=0;i--){
        WH_JXMessageObject* p = [_array objectAtIndex:i];
        if(p == msg){
//            NSLog(@"onReceiveFile");
            [[self getCell:i] drawIsReceive];
            break;
        }
        p = nil;
    }
}

-(void)showMsg:(NSNotification *)notifacation{
    WH_JXMessageObject *msg = (WH_JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    if ([[msg getTableName] isEqualToString:chatPerson.userId] && msg.isMySend)
            [self WH_show_WHOneMsg:msg];
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation{
    
    
    WH_JXMessageObject *msg = (WH_JXMessageObject *)notifacation.object;
    
    
    if(msg==nil)
        return;
    
    // 更新title 在线状态
    if (!self.roomJid && !self.onlinestate && ![msg.fromUserId isEqualToString:MY_USER_ID]) {
        self.onlinestate = YES;
        if (self.isGroupMessages) {
            self.title = Localized(@"JX_GroupHair");
        }else {
            if (self.courseId.length > 0) {
                
            }else {
                
                if([chatPerson.userId intValue]<10100 && [chatPerson.userId intValue]>=10000) {
                    self.title = chatPerson.userNickname;
                }else {
                    NSString *str = self.onlinestate ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
                    self.title = [NSString stringWithFormat:@"%@",chatPerson.remarkName.length > 0 ? chatPerson.remarkName : chatPerson.userNickname];
                }
            }
        }
    }
    
#ifdef Live_Version
    if([[WH_JXLiveJid_WHManager shareArray] contains:msg.toUserId] || [[WH_JXLiveJid_WHManager shareArray] contains:msg.fromUserId])
        return;
#endif
    
    if ([msg.type intValue] == XMPP_TYPE_NOBLACK) {
        if ([msg.fromUserId isEqualToString:self.chatPerson.userId]) {
            self.isBeenBlack = 0;
        }
    }
    
    if(!msg.isVisible)
        return;
    
    if (self.roomJid || msg.isGroup) {//是房间
        if (msg.isRepeat) {
            return;
        }
        if ([msg.toUserId isEqualToString:chatPerson.userId]||[msg.toUserId isEqualToString:self.roomJid]) {//第一个判断时从MsgView进入，第二个从GroupView进入
            [self WH_show_WHOneMsg:msg];
        }else{
            if ([msg.fromId isEqualToString:chatPerson.userId]||[msg.fromId isEqualToString:self.roomJid])//第一个判断时从MsgView进入，第二个从GroupView进入
                [self WH_show_WHOneMsg:msg];
        }
    }else{
        if ([msg.type integerValue] == kWCMessageTypeRemind && !msg.isShowRemind) {
            return;
        }
        if ([msg.fromUserId isEqualToString:MY_USER_ID] && [msg.type intValue] == kWCMessageTypeWithdraw) {
            
            WH_JXMessageObject *newMsg;
            NSInteger index = 0;
            for (NSInteger i = 0; i < _array.count; i ++) {
                WH_JXMessageObject *withDrawMsg = _array[i];
                if ([msg.content isEqualToString:withDrawMsg.messageId]) {
                    newMsg = withDrawMsg;
                    index = i;
                    break;
                }
            }
            if (!newMsg) {
                return;
            }
            newMsg.isShowTime = NO;
            newMsg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
            newMsg.content = Localized(@"JX_AlreadyWithdraw");
            NSString* s;
            if([self.roomJid length]>0)
                s = self.roomJid;
            else
                s = chatPerson.userId;
            newMsg.fromUserId = MY_USER_ID;
            newMsg.toUserId = s;
            if (self.withdrawIndex == _array.count - 1) {
                self.lastMsg.content = newMsg.content;
            }
            [newMsg updateLastSend:UpdateLastSendType_None];
            [newMsg update];
            [newMsg notifyNewMsg];
            [_wait stop];
            [_table WH_reloadRow:(int)index section:0];
            return;
        }
        
        if ([msg.fromUserId isEqualToString:chatPerson.userId] || ([msg.fromUserId isEqualToString:MY_USER_ID] && [msg.toUserId isEqualToString:chatPerson.userId]))
            [self WH_show_WHOneMsg:msg];
        if (!msg.isMySend && [msg.isReadDel boolValue]) {
            _myReadDel = msg.isReadDel.integerValue;
            g_myself.isOpenReadDel = msg.isReadDel;
            self.chatPerson.isOpenReadDel = msg.isReadDel;
            [rightNaviBtn setClockTitleWithIndex:_myReadDel];
            [self readReadDelMsg:msg];
            
            [self.chatPerson WH_updateIsOpenReadDel];
            
//            [g_notify postNotificationName:kReadDelRefreshNotif object:self
        }else {
            _myReadDel = msg.isReadDel.integerValue;
            g_myself.isOpenReadDel = msg.isReadDel;
            self.chatPerson.isOpenReadDel = msg.isReadDel;
            [rightNaviBtn setMoreStyle];
        }
    }
    msg = nil;
}
//是否触发积分机器人
- (void)roomSignInGroupWithMessage:(WH_JXMessageObject *)msg {
    //
    if ([msg.content isEqualToString:@"签到"] || [msg.content isEqualToString:@"积分"]) {
        NSString *type = [msg.content isEqualToString:@"签到"] ? @"1" : @"2";
        [g_server roomSignInGroupWithUserId:@"" fraction:@"" roomId:self.roomId type:type toView:self];
    }
    memberData *data = [self.room getMember:msg.fromUserId];
    if ([data.role intValue] > 2) {
        return;
    }
    if ([msg.content hasPrefix:@"@"] && [msg.content hasSuffix:@" 积分"]) {
        NSArray *array = [msg.content componentsSeparatedByString:@" "];
        NSMutableArray *tempArr = [NSMutableArray array];
            for (NSString *nickname in array) {
                if ([nickname containsString:@"@"]) {
                    NSString *currentNickName = [nickname substringFromIndex:1];
                    NSArray *array2 = [msg.objectId componentsSeparatedByString:@" "];
                    for (NSString *userId in array2) {
                        memberData *data = [self.room getMember:userId];
                        if ([data.userNickName isEqualToString:currentNickName]) {
                            [tempArr addObject:userId];
                        }
                    }
                }
            }
        if (tempArr.count > 0) {
            NSString *uIds = [tempArr componentsJoinedByString:@","];
            [g_server roomSignInGroupWithUserId:uIds fraction:@"" roomId:self.roomId type:@"3" toView:self];
        }
    }
    if ([msg.content hasPrefix:@"@"] && ([msg.content containsString:@"+"] || [msg.content containsString:@"-"])) {
        NSString *fractionStr = @"";
            NSArray *array3 = [msg.content componentsSeparatedByString:@" "];
            NSString *lastObject = [array3 lastObject];
            if ([lastObject containsString:@"+"] || [lastObject containsString:@"-"]) {
                NSString *fraction = [lastObject substringFromIndex:1];
                if ([self isNumber:fraction] && [fraction intValue] > 0) {
                    fractionStr = lastObject;
                }
        }
        if (fractionStr.length > 0) {
            NSMutableArray *tempArr = [NSMutableArray array];
                for (NSString *nickname in array3) {
                    if ([nickname containsString:@"@"]) {
                        NSString *currentNickName = [nickname substringFromIndex:1];
                        NSArray *array2 = [msg.objectId componentsSeparatedByString:@" "];
                        for (NSString *userId in array2) {
                            memberData *data = [self.room getMember:userId];
                            if ([data.userNickName isEqualToString:currentNickName]) {
                                [tempArr addObject:userId];
                            }
                        }
                    }
                }
            if (tempArr.count > 0) {
                NSString *uIds = [tempArr componentsJoinedByString:@","];
                [g_server roomSignInGroupWithUserId:uIds fraction:fractionStr roomId:self.roomId type:@"4" toView:self];
            }
        }
    }
}

-(void)newReceipt:(NSNotification *)notifacation{//新回执
    NSLog(@"%@", self.roomId);
    WH_JXMessageObject *msg     = (WH_JXMessageObject *)notifacation.object;
    if(msg == nil)
        return;
    if (IS_SHOW_IntegratingRobot) {
        [self roomSignInGroupWithMessage:msg];
    }
    if ([msg.type intValue] == kWCMessageTypeWithdraw) {
        WH_JXMessageObject *msg1 = _array[self.withdrawIndex];
        msg1.isShowTime = NO;
        msg1.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
        msg1.content = Localized(@"JX_AlreadyWithdraw");
        NSString* s;
        if([self.roomJid length]>0)
            s = self.roomJid;
        else
            s = chatPerson.userId;
        msg1.fromUserId = MY_USER_ID;
        msg1.toUserId = s;
        if (self.withdrawIndex == _array.count - 1) {
            self.lastMsg.content = msg1.content;
        }
        [msg1 updateLastSend:UpdateLastSendType_None];
        [msg1 update];
        [msg1 notifyNewMsg];
        [_wait stop];
        [_table WH_reloadRow:(int)self.withdrawIndex section:0];
        return;
    }

    if([chatPerson.userId rangeOfString: msg.fromUserId].location != NSNotFound || [chatPerson.userId rangeOfString: msg.toUserId].location != NSNotFound || [msg.toUserId isEqualToString:self.roomJid] ){
        for(int i=(int)[_array count]-1;i>=0;i--){
            WH_JXMessageObject* p = [_array objectAtIndex:i];
            if([p.messageId isEqualToString:msg.messageId]){
                
                WH_JXBaseChat_WHCell* cell = [self getCell:i];
                if (p != msg) {
                    cell.msg = msg;
                }
                if(cell)
                    [cell drawIsSend];
                break;
            }
            p = nil;
        }
    }
}

#pragma mark sharemore按钮组协议
#pragma mark 照片选择器
-(void)pickPhoto
{
    [self hideKeyboard:YES];
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 9;//最大的选择数目
    photoController.configuration.containVideo = YES;//选择类型，目前只选择图片不选择视频
    photoController.photo_delegate = self;
    photoController.thumbnailSize = CGSizeMake(320, 320);//缩略图的尺寸
//    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoController animated:true completion:^{}];

//    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
//    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    [imgPicker setDelegate:self];
//    [imgPicker setAllowsEditing:NO];
////    [g_App.window addSubview:imgPicker.view];
//
//    [self presentViewController:imgPicker animated:YES completion:^{}];
}


- (void)photosViewController:(UIViewController *)viewController assets:(NSArray <PHAsset *> *)assets {
    self.imgDataArr = assets;
    
}

#pragma mark - 发送图片
- (void)photosViewController:(UIViewController *)viewController datas:(NSArray <id> *)datas; {
    
    for (int i = 0; i < datas.count; i++) {
        BOOL isGif = [datas[i] isKindOfClass:[NSData class]];
        
        if (isGif) {
            // GIF
            NSString *file = [FileInfo getUUIDFileName:@"gif"];
            [g_server WH_saveDataToFileWithData:datas[i] file:file];
            [self sendImage:file withWidth:0 andHeight:0 userId:nil];

        }else {
            // 普通图片
            UIImage *chosedImage = datas[i];
            //获取image的长宽
            int imageWidth = chosedImage.size.width;
            int imageHeight = chosedImage.size.height;
            NSString *name = @"jpg";
            if (self.isGroupMessages) {
                for (NSInteger i = 0; i < self.userIds.count; i ++) {
                    NSString *userId = self.userIds[i];
                    
                    NSString *file = [FileInfo getUUIDFileName:name];
                    [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:YES];
                    [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:userId];
                }
            }else {
                NSString *file = [FileInfo getUUIDFileName:name];
                //图片存储到本地
                [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:YES];
                
                [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:nil];
                
            }
        }
    }
}

#pragma mark - 发送视频
- (void)photosViewController:(UIViewController *)viewController media:(WH_JXMediaObject *)media {
    if (self.isGroupMessages) {
        for (NSInteger i = 0; i < self.userIds.count; i ++) {
            NSString *userId = self.userIds[i];
            
            [self sendMedia:media userId:userId];
//            [g_server uploadFile:media.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:self.curMessageId toView:self];
        }
    }else {
        [self sendMedia:media userId:nil];
//        [g_server uploadFile:media.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:self.curMessageId toView:self];
    }
}

-(void)onCamera{
    [self hideKeyboard:YES];
    
    if (![self checkCameraLimits]) {
        return;
    }
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    
    WH_JXCamera_WHVC *vc = [[WH_JXCamera_WHVC alloc] init];
    vc.cameraDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
    
//    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
//    [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
//    [imgPicker setDelegate:self];
//    [imgPicker setAllowsEditing:NO];
//    //    [g_App.window addSubview:imgPicker.view];
//    
//    [self presentViewController:imgPicker animated:YES completion:^{}];
    
}

// 戳一戳动画
- (void)WH_onShake {
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    
    if (self.roomJid.length > 0) {
        [JXMyTools showTipView:@"群组暂不支持该功能！"];
        return;
        
    }
    
    NSString *userId = self.userIds[self.groupMessagesIndex];
    NSString *userName = self.userNames[self.groupMessagesIndex];
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    if([self.roomJid length]>0){
        msg.toUserId = self.roomJid;
        msg.isGroup = YES;
        msg.fromUserName = _userNickName;
    }
    else{
        if (self.isGroupMessages) {
            msg.toUserId = userId;
        }else {
            msg.toUserId     = chatPerson.userId;
        }
        msg.isGroup = NO;
    }
//    msg.content      = message;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeShake];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];

    //发往哪里
    [msg insert:self.roomJid];
    [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
    
    if (self.isGroupMessages) {
        self.groupMessagesIndex ++;
        if (self.groupMessagesIndex < self.userIds.count) {
            [self WH_onShake];
        }else if (self.userIds){
            self.groupMessagesIndex = 0;
            [g_App showAlert:Localized(@"JX_SendComplete")];
            return;
        }
        return;
    }
    
    [self WH_show_WHOneMsg:msg];
}

#pragma mark 发送收藏
// 发送收藏
- (void)onCollection {
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    
    WH_Collect_WHViewController *collectVC = [[WH_Collect_WHViewController alloc] init];
    collectVC.delegate = self;
    collectVC.isSend = YES;
    [g_navigation pushViewController:collectVC animated:YES];
//    WeiboViewControlle * collection = [[WeiboViewControlle alloc] initCollection];
//    collection.delegate = self;
//    collection.isSend = YES;
//    [g_navigation pushViewController:collection animated:YES];
}

#pragma mark 发送双向撤回
- (void)twoWayWithdrawalMethod {
    
    memberData *roleData = [_room getMember:g_myself.userId];
    if ([roleData.role intValue] == 1) {
        [self hideKeyboard:YES];
        //群主
        CGFloat viewH = 226;
        if (THE_DEVICE_HAVE_HEAD) {
            viewH = 226+24;
        }
        WH_CustomActionSheetView *share = [[WH_CustomActionSheetView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, viewH) WithTitle:@"撤回全部群聊天记录，执行后永久删除所有群成员设备上的聊天记录，并不可恢复。" sureBtnColor:HEXCOLOR(0x0093FF)];
        
        [share showInWindowWithMode:CustomAnimationModeShare inView:nil bgAlpha:0.5 needEffectView:NO];
        
        __weak typeof(share) weakShare = share;
        __weak typeof(self) weakSelf = self;
        share.wh_okActionBlock = ^{
            [weakShare hideView];
            
            [g_server wh_twoWayDelectRoomMsg:g_myself.userId?:@"" roomId:weakSelf.room.roomJid?:@"" toView:weakSelf];
            
        };
        share.wh_cancelActionBlock = ^{
            [weakShare hideView];
        };
        
    }else{
        [GKMessageTool showText:@"您不是该群群主，不能进行此操作！"];
        return;
    }
}

// 发送手机联系人
- (void)onAddressBook {
    WH_JXSelectAddressBook_WHVC *vc = [[WH_JXSelectAddressBook_WHVC alloc] init];
    vc.delegate = self;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectAddressBookVC:(WH_JXSelectAddressBook_WHVC *)selectVC doneAction:(NSArray *)array {
    
    NSString *userId = self.userIds[self.groupMessagesIndex];
    NSString *userName = self.userNames[self.groupMessagesIndex];
    
    for(JXAddressBook* address in array){

        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.content      = [NSString stringWithFormat:@"%@\n%@", address.addressBookName, address.toTelephone];
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeText];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:self.roomJid];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg];
    }
    
    if (self.isGroupMessages) {
        self.groupMessagesIndex ++;
        if (self.groupMessagesIndex < self.userIds.count) {
            [self selectAddressBookVC:selectVC doneAction:array];
        }else if (self.userIds){
            self.groupMessagesIndex = 0;
            [g_App showAlert:Localized(@"JX_SendComplete")];
            return;
        }
        return;
    }
}

- (void)collectVC:(WH_Collect_WHViewController *)weiboVC didSelectWithData:(WeiboData *)data {
    if (data.type == 1) {
        
        NSString *userId = self.userIds[self.groupMessagesIndex];
        NSString *userName = self.userNames[self.groupMessagesIndex];
        
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.content      = data.content;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeText];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isReadDel    = self.chatPerson.isOpenReadDel;

        //发往哪里
        [msg insert:self.roomJid];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        
        if (self.isGroupMessages) {
            self.groupMessagesIndex ++;
            if (self.groupMessagesIndex < self.userIds.count) {
                [self collectVC:weiboVC didSelectWithData:data];
            }else if (self.userIds){
                self.groupMessagesIndex = 0;
                [g_App showAlert:Localized(@"JX_SendComplete")];
                return;
            }
            return;
        }
        [self WH_show_WHOneMsg:msg];
    }else {
        NSString *url;
        NSMutableArray *imgArr = [NSMutableArray array];
        switch (data.type) {
            case 2:{
                for (ObjUrlData *dict in data.larges) {
                    NSString *imgUrl = dict.url;
                    [imgArr addObject:imgUrl];
                }
                //                url = ((ObjUrlData *)data.larges.firstObject).url;
            }
                break;
            case 3:
                url = ((ObjUrlData *)data.audios.firstObject).url;
                break;
            case 4:
                url = ((ObjUrlData *)data.videos.firstObject).url;
                break;
            case 5:
                url = ((ObjUrlData *)data.files.firstObject).url;
                break;
                
            default:
                break;
        }
        _collectionData = data;
        if (imgArr.count > 0) {
            for (int i = 0; i < imgArr.count; i++ ) {
                [self WH_collectionFileMsgSend:imgArr[i]];
            }
            
        }else {
            [g_server WH_uploadCopyFileServletWithPaths:url validTime:g_config.fileValidTime toView:self];
        }
    }
    
}

- (void) weiboVC:(WH_WeiboViewControlle *)weiboVC didSelectWithData:(WeiboData *)data {
    if (data.type == 1) {
        
        NSString *userId = self.userIds[self.groupMessagesIndex];
        NSString *userName = self.userNames[self.groupMessagesIndex];
        
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.content      = data.content;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeText];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isReadDel    = self.chatPerson.isOpenReadDel;

        //发往哪里
        [msg insert:self.roomJid];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        
        if (self.isGroupMessages) {
            self.groupMessagesIndex ++;
            if (self.groupMessagesIndex < self.userIds.count) {
                [self weiboVC:weiboVC didSelectWithData:data];
            }else if (self.userIds){
                self.groupMessagesIndex = 0;
                [g_App showAlert:Localized(@"JX_SendComplete")];
                return;
            }
            return;
        }
        [self WH_show_WHOneMsg:msg];
    }else {
        NSString *url;
        NSMutableArray *imgArr = [NSMutableArray array];
        switch (data.type) {
            case 2:{
                for (ObjUrlData *dict in data.larges) {
                    NSString *imgUrl = dict.url;
                    [imgArr addObject:imgUrl];
                }
//                url = ((ObjUrlData *)data.larges.firstObject).url;
            }
                break;
            case 3:
                url = ((ObjUrlData *)data.audios.firstObject).url;
                break;
            case 4:
                url = ((ObjUrlData *)data.videos.firstObject).url;
                break;
            case 5:
                url = ((ObjUrlData *)data.files.firstObject).url;
                break;
                
            default:
                break;
        }
        _collectionData = data;
        if (imgArr.count > 0) {
            for (int i = 0; i < imgArr.count; i++ ) {
                [self WH_collectionFileMsgSend:imgArr[i]];
            }
            
        }else {
        [g_server WH_uploadCopyFileServletWithPaths:url validTime:g_config.fileValidTime toView:self];
        }
    }
    
}

- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    [self hideKeyboard:YES];
    //获取image的长宽
    int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    
    self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    NSString *name = @"jpg";
    if (self.isGroupMessages) {
        for (NSInteger i = 0; i < self.userIds.count; i ++) {
            NSString *userId = self.userIds[i];
            
            NSString *file = [FileInfo getUUIDFileName:name];
            [g_server WH_saveImageToFileWithImage:image file:file isOriginal:NO];
            [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:userId];
//            [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        }
    }else {
        NSString *file = [FileInfo getUUIDFileName:name];
        [g_server WH_saveImageToFileWithImage:image file:file isOriginal:NO];
        [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:nil];
//        [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
    }
    
//    NSString* file = [FileInfo getUUIDFileName:name];
//
//    [g_server saveImageToFile:image file:file isOriginal:NO];
////    [self sendImage:file withWidth:imageWidth andHeight:imageHeight];
//    [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut toView:self];
}

#pragma mark ----------图片选择完成-------------
//UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  * chosedImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //获取image的长宽
    int imageWidth = chosedImage.size.width;
    int imageHeight = chosedImage.size.height;
    [self dismissViewControllerAnimated:NO completion:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self hideKeyboard:YES];
        
        
        NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        NSString *urlStr = [url absoluteString];
        NSString *name = [urlStr substringFromIndex:urlStr.length - 3];
        name = [name lowercaseString];
        
        NSString* file = [FileInfo getUUIDFileName:name];
        
        
        if ([name isEqualToString:@"gif"]) {    // gif不能按照image取data存储
            ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
            
            void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset) {
                
                if (asset != nil) {
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    Byte *imageBuffer = (Byte*)malloc(rep.size);
                    NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
                    NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
                    
                    if (self.isGroupMessages) {
                        for (NSInteger i = 0; i < self.userIds.count; i ++) {
                            NSString *userId = self.userIds[i];
                            
                            NSString *file = [FileInfo getUUIDFileName:name];
                            [g_server WH_saveDataToFileWithData:imageData file:file];
                            [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:userId];
//                            [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
                        }
                    }else {
                        NSString *file = [FileInfo getUUIDFileName:name];
                        [g_server WH_saveDataToFileWithData:imageData file:file];
                        [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:nil];
//                        [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
                    }
//                    [g_server saveDataToFile:imageData file:file];
////                    [self sendImage:file withWidth:imageWidth andHeight:imageHeight];
//                    [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut toView:self];
                    
                }
                else {
                }
            };
            
            [assetLibrary assetForURL:url
                          resultBlock:ALAssetsLibraryAssetForURLResultBlock
                         failureBlock:^(NSError *error) {
                             
                         }];
        }else {
            
            name = @"jpg";
            if (self.isGroupMessages) {
                for (NSInteger i = 0; i < self.userIds.count; i ++) {
                    NSString *userId = self.userIds[i];
                    
                    NSString *file = [FileInfo getUUIDFileName:name];
                    [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:NO];
                    [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:userId];
//                    [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
                }
            }else {
                NSString *file = [FileInfo getUUIDFileName:name];
                [g_server WH_saveImageToFileWithImage:chosedImage file:file isOriginal:NO];
                [self sendImage:file withWidth:imageWidth andHeight:imageHeight userId:nil];
//                [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
            }
//            file = [FileInfo getUUIDFileName:name];
//            [g_server saveImageToFile:chosedImage file:file isOriginal:NO];
////            [self sendImage:file withWidth:imageWidth andHeight:imageHeight];
//            [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut toView:self];
        }
        
        
//        [picker release];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self hideKeyboard:YES];
//        [picker release];
    }];
}

#pragma mark - 录制语音
- (void)recordStart:(UIButton *)sender {
    NSLog(@"recordStart-------");
    if([self showDisableSay])
        return;
    if(recording)
        return;
    if([self sendMsgCheck]){
        return;
    }
    if (![self canRecord]) {
        [g_App showAlert:Localized(@"JX_CanNotOpenMicr")];
        return;
    }
    
//    _recordBtn.layer.borderColor = [[UIColor blueColor] CGColor];
    _recordBtn.backgroundColor = HEXCOLOR(0xB8B9BD);

    [g_notify postNotificationName:kAllAudioPlayerPauseNotifaction object:self userInfo:nil];
    [g_notify postNotificationName:kAllVideoPlayerPauseNotifaction object:self userInfo:nil];

    [self hideKeyboard:YES];
    recording=YES;
    
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: &error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];

    NSURL *url = [NSURL fileURLWithPath:[FileInfo getUUIDFileName:@"wav"]];
    pathURL = url;
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:pathURL settings:settings error:&error];
    audioRecorder.delegate = self;
    
    peakTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updatePeak:) userInfo:nil repeats:YES];
    [peakTimer fire];
    BOOL flag = NO;
    flag = [audioRecorder prepareToRecord];
    [audioRecorder setMeteringEnabled:YES];
    flag = [audioRecorder peakPowerForChannel:1];
    flag = [audioRecorder record];
    
    _voice.center = self.view.center;
    [_voice wh_show];
}

- (void)updatePeak:(NSTimer*)timer
{
    _timeLen = audioRecorder.currentTime;
    if(_timeLen>=60)
        [self recordStop:nil];

    [audioRecorder updateMeters];
    const double alpha=0.5;
    NSLog(@"peakPowerForChannel = %f,%f", [audioRecorder peakPowerForChannel:0],[audioRecorder peakPowerForChannel:1]);
    double peakPowerForChannel=pow(10, (0.05)*[audioRecorder peakPowerForChannel:0]);
    lowPassResults=alpha*peakPowerForChannel+(1.0-alpha)*lowPassResults;
    _voice.wh_volume = lowPassResults;
    
/*    for (int i=1; i<8; i++) {
        if (lowPassResults>1.0/7.0*i){
            [[talkView viewWithTag:i] setHidden:NO];
        }else{
            [[talkView viewWithTag:i] setHidden:YES];
        }
    }*/
}

- (void)recordStop:(UIButton *)sender {
    
    [_voice wh_hide];
    [peakTimer invalidate];
    peakTimer = nil;
    recording = NO;
    
//    if(!recording)
//        return;
    
//    _recordBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    _recordBtn.backgroundColor = HEXCOLOR(0xFEFEFE);
    _timeLen = audioRecorder.currentTime;
    [audioRecorder pause];
    [audioRecorder stop];
//    [audioRecorder release];
//    if (_timeLen<1) {
//        [g_App showAlert:@"录的时间过短
//    "];
//        return;
//    }

    if (_timeLen<1)
        _timeLen = 1;
    NSString *amrPath = [VoiceConverter wavToAmr:pathURL.path];
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:pathURL.path];
    _lastRecordFile = [[amrPath lastPathComponent] copy];
    
//    NSLog(@"音频文件路径:%@\n%@",pathURL.path,amrPath);
    if(amrPath == nil){
//        [g_App showAlert:Localized(@"JXChatVC_TimeLess")];
        [g_server showMsg:Localized(@"JXChatVC_TimeLess") delay:1.0];
        return;
    }
    if (self.isGroupMessages) {
        for (NSInteger i = 0; i < self.userIds.count; i ++) {
            NSString *userId = self.userIds[i];
            
            [self sendVoice:amrPath userId:userId];
            /*直接上传服务器,改为上传obs*/
//            [g_server uploadFile:amrPath validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
            
            [OBSHanderTool handleUploadFile:amrPath validTime:self.chatPerson.chatRecordTimeOut messageId:@"" toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
                if (code == 1) {
                    //请求
                    NSMutableDictionary* p = [NSMutableDictionary dictionary];
                    [p setValue:fileUrl forKey:@"oUrl"];
                    [p setValue:fileName forKey:@"oFileName"];
                    [p setValue:@"1" forKey:@"status"];
                    if (self.isMapMsg) {
                        [self sendMapMsgWithDict:p];
                    }else {
                        [self WH_doSendAfterUpload:p];
                    }
                    p = nil;
                }
            } failed:^(NSError * _Nonnull error) {
                
            }];
        }
    }else {
        [self sendVoice:amrPath userId:nil];
        /*直接上传服务器,改为上传obs*/
        //            [g_server uploadFile:amrPath validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        
        [OBSHanderTool handleUploadFile:amrPath validTime:self.chatPerson.chatRecordTimeOut messageId:@"" toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                //请求
                NSMutableDictionary* p = [NSMutableDictionary dictionary];
                [p setValue:fileUrl forKey:@"oUrl"];
                [p setValue:fileName forKey:@"oFileName"];
                [p setValue:@"1" forKey:@"status"];
                if (self.isMapMsg) {
                    [self sendMapMsgWithDict:p];
                }else {
                    [self WH_doSendAfterUpload:p];
                }
                p = nil;
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [_voice wh_hide];
    [peakTimer invalidate];
    peakTimer = nil;
    recording = NO;
}

- (void)recordCancel:(UIButton *)sender
{
    if(!recording)
        return;
//    _recordBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    _recordBtn.backgroundColor = HEXCOLOR(0xFEFEFE);
    [audioRecorder stop];
    audioRecorder = nil;
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:pathURL.path];
}

-(void)sendVoice:(NSString*)file userId:(NSString *)userId{
    
    //生成消息对象
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    if([self.roomJid length]>0){
        msg.toUserId = self.roomJid;
        msg.isGroup = YES;
        msg.fromUserName = _userNickName;
    }
    else{
        if (self.isGroupMessages) {
            msg.toUserId = userId;
        }else {
            msg.toUserId     = chatPerson.userId;
        }
        msg.isGroup = NO;
    }

    msg.fileName     = file;
    msg.content      = [[file lastPathComponent] stringByDeletingPathExtension];
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeVoice];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isUpload     = [NSNumber numberWithBool:NO];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.timeLen      = [NSNumber numberWithInt:_timeLen];
    
    msg.isReadDel    = self.chatPerson.isOpenReadDel;
    

    [msg insert:self.roomJid];
    [self WH_show_WHOneMsg:msg];
//    [msg release];
}

- (void)sendGif:(NSString *)str {
    if([self sendMsgCheck]){
        return;
    }
    
    NSString *message = str;
    if (message.length > 0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            msg.toUserId     = chatPerson.userId;
            msg.isGroup = NO;
        }
        msg.fileData     = nil;
//        msg.fileName      = message;
        msg.content      = message;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeGif];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:self.roomJid];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg];
//        [msg release];
    }
//    [_messageText setText:nil];
}


#pragma mark - 输入TextField代理

-(void)doBeginEdit{
	_table.frame = CGRectMake(0, self.wh_heightHeader+_noticeHeight, JX_SCREEN_WIDTH, self.view.frame.size.height-faceHeight-self.wh_heightHeader-self.wh_heightFooter-_noticeHeight);
	self.wh_tableFooter.frame = CGRectMake(0, _table.frame.origin.y+_table.frame.size.height, JX_SCREEN_WIDTH, self.wh_heightFooter);
    [_table WH_gotoLastRow:NO];
}

-(void)doEndEdit{
    _textViewBtn.hidden = YES;
    
    if (_messageText.isFirstResponder) {
        
        _table.frame =CGRectMake(0,self.wh_heightHeader+_noticeHeight,self_width,JX_SCREEN_HEIGHT-self.wh_heightHeader-self.wh_heightFooter-_noticeHeight);
        self.wh_tableFooter.frame = CGRectMake(0, JX_SCREEN_HEIGHT-self.wh_heightFooter, JX_SCREEN_WIDTH, self.wh_heightFooter);
        _btnFace.selected = NO;
        [_messageText resignFirstResponder];
        _messageText.inputView = nil;
        self.deltaHeight = 0;
        self.screenShotView.frame = CGRectMake(self.screenShotView.frame.origin.x, self.wh_tableFooter.frame.origin.y - self.screenShotView.frame.size.height - 10, self.screenShotView.frame.size.width, self.screenShotView.frame.size.height);
        [_table WH_gotoLastRow:NO];
    }
    
    if (_faceView && !_faceView.hidden) {
        _table.frame =CGRectMake(0,self.wh_heightHeader+_noticeHeight,self_width,JX_SCREEN_HEIGHT-self.wh_heightHeader-self.wh_heightFooter-_noticeHeight);
        self.wh_tableFooter.frame = CGRectMake(0, JX_SCREEN_HEIGHT-self.wh_heightFooter, JX_SCREEN_WIDTH, self.wh_heightFooter);
        _faceView.hidden = YES;
        [_faceView removeFromSuperview];
        [_table WH_gotoLastRow:NO];
    }
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	[self doBeginEdit];
    _btnFace.selected = NO;
//    if([[NSDate date] timeIntervalSince1970] <= _disableSay)
//        return NO;
//    else
//        return YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[self doEndEdit];
	return YES;
}

- (BOOL) hideKeyboard:(BOOL)gotoLastRow{
    if(gotoLastRow)
        [_table WH_gotoLastRow:NO];
    _btnFace.selected = NO;
    [_messageText resignFirstResponder];
    _messageText.inputView = nil;
    self.deltaHeight = 0;
    [self doEndEdit];
    
    self.screenShotView.frame = CGRectMake(self.screenShotView.frame.origin.x, self.wh_tableFooter.frame.origin.y - self.screenShotView.frame.size.height - 10, self.screenShotView.frame.size.width, self.screenShotView.frame.size.height);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyboard:YES];
    if(textField.tag == kWCMessageTypeGif)
        [self sendGif:textField.text];
    else {
        [self sendIt:textField];
    }
	return YES;
}

#pragma mark - 自定义表情按钮点击事件
-(void)actionFace:(UIButton*)sender{
    if([self showDisableSay])
        return;
    _messageText.inputView = nil;
    [_messageText reloadInputViews];
    
    [self offRecordBtns];
    if(sender.selected){
        [self doBeginEdit];
        [_messageText becomeFirstResponder];
        [_faceView removeFromSuperview];
        _faceView.hidden = YES;
        sender.selected = NO;
    }else{
        if(_faceView==nil){
            _faceView = g_App.faceView;
            _faceView.delegate = self;
        }
        [_messageText resignFirstResponder];
        [self.view addSubview:_faceView];
        _faceView.hidden = NO;
        sender.selected = YES;
        [_faceView selectType:0];
        [self doBeginEdit];
        self.deltaHeight = -faceHeight;
        [self setTableFooterFrame:_messageText];
    }
//	[self doBeginEdit];
}

- (void) selectImageNameString:(NSString*)imageName ShortName:(NSString *)shortName isSelectImage:(BOOL)isSelectImage {
    //如果不是delete响应,当前是提示信息，修改其属性
    if (![shortName isEqualToString:@""] && _messageText.textColor == [UIColor lightGrayColor]) {
        _messageText.text = @"";//置空
        _messageText.textColor = [UIColor blackColor];
    }

    WH_EmojiTextAttachment *attachment = [[WH_EmojiTextAttachment alloc] init];
    attachment.emojiTag = shortName;
    attachment.image = [UIImage imageNamed:imageName];
    attachment.bounds = CGRectMake(0, -4, _messageText.font.lineHeight, _messageText.font.lineHeight);
    //    attachment.emojiSize = CGSizeMake(_messageText.font.lineHeight, _messageText.font.lineHeight);
    
    NSRange newRange = NSMakeRange(_messageText.selectedRange.location + 1, 0);
    
    if (_messageText.selectedRange.length > 0) {
        [_messageText.textStorage deleteCharactersInRange:_messageText.selectedRange];
    }
    [_messageText.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:_messageText.selectedRange.location];
    
    _messageText.selectedRange = newRange;
    _messageText.font = sysFontWithSize(18);
    
    [_messageText scrollRangeToVisible:NSMakeRange(_messageText.text.length, 1)];
    if (isSelectImage) {
        self.deltaHeight = -faceHeight;
    }
    [self setTableFooterFrame:_messageText];
}

- (void)faceViewDeleteAction {
    [_messageText deleteBackward];
}

//添加表情按钮 被点击
- (void)emojiFaceView:(emojiViewController *)emojiFaceView didClickAddEmoticonButton:(UIButton *)addEmoticonButton
{
    WWAddEmoticonViewController *addEmoticonVC = [[WWAddEmoticonViewController alloc] init];
    [g_navigation pushViewController:addEmoticonVC animated:YES];
}

//gif动态图按钮被点击
- (void)emojiFaceView:(emojiViewController *)emojiFaceView didClickOnGifViewWithZuIndex:(NSInteger)zuIndx index:(NSInteger)index dataDic:(NSDictionary *)dataDic
{
    if (zuIndx>=2) {
//        [self creatMessageFrameModelWithContent:[WWChatEmojiMessageModel stringCustomEmoji:dataDic] message:TOMessageFromMe messageType:TOMessageTypeEmoji];
        NSString* s = dataDic[@"fileUrl"];
        [self selectFavoritWithString:s];
        
    }else{
        if (index == 0) {
            //跳转我的表情管理控制器
            WWEmoticonManagerViewController *managerEmoticonVC = [[WWEmoticonManagerViewController alloc] init];
            managerEmoticonVC.dataArray = [NSMutableArray arrayWithArray:_faceView.MyEmotIconDataArray];
            [g_navigation pushViewController:managerEmoticonVC animated:YES];
            
        }else{
            
            
            NSString* s = dataDic[@"url"];
            [self selectFavoritWithString:s];
            
        }
    }
}


- (void)selectGifWithString:(NSString *)str {
//    _messageText.text = str;
    [self sendGif:str];
}

// 发送收藏表情
- (void)selectFavoritWithString:(NSString *)str {

    UIImage  * chosedImage=[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:str];
    //获取image的长宽
    int imageWidth = chosedImage.size.width;
    int imageHeight = chosedImage.size.height;
    NSString *s = [str pathExtension];
    NSString* file = [FileInfo getUUIDFileName:s];
    if ([file length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            msg.toUserId     = chatPerson.userId;
            msg.isGroup = NO;
        }
        msg.fileName     = file;
        msg.content      = str;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeImage];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
//        msg.isUpload     = [NSNumber numberWithBool:NO];
        //新添加的图片宽高
        msg.location_x = [NSNumber numberWithInt:imageWidth];
        msg.location_y = [NSNumber numberWithInt:imageHeight];
        
        msg.isReadDel    = self.chatPerson.isOpenReadDel;

        [msg insert:self.roomJid];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg];
        //        [msg release];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 只有水印时，不能send
    if ([text isEqualToString:@"\n"] && textView.textColor == [UIColor lightGrayColor]) {
        return NO;
    }
    //如果不是delete响应,当前是提示信息，修改其属性
    if (![text isEqualToString:@""] && textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";//置空
        textView.textColor = [UIColor blackColor];
    }
    
    if ([text isEqualToString:@""] && [_messageText.text rangeOfString:@"@"].location != NSNotFound) {
        
        NSRange selectRange = _messageText.selectedRange;
        if (selectRange.length > 0)
        {
            //用户长按选择文本时不处理
            return YES;
        }
        
        
        // 判断删除的是一个@中间的字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:textView.text];
        NSArray *matches = [self findAllAt];
        
        BOOL inAt = NO;
        NSInteger index = range.location;
        
        for (int i = 0; i < matches.count; i ++) {
            NSTextCheckingResult *match = matches[i];
            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
            if (NSLocationInRange(range.location, newRange))
            {
                inAt = YES;
                index = match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                //移除数组中数据(防止数组越界)
                if (i < _atMemberArray.count) {
                    [_atMemberArray removeObjectAtIndex:i];
                }
                
                break;
            }
        }
        
        if (inAt)
        {
            textView.text = string;
            textView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
        
        
    }
    

    NSMutableArray *arr = [NSMutableArray array];
    [self getImageRange:text array:arr];
    if (arr.count > 1) {
        for (NSInteger i = 0; i < arr.count; i ++) {
            NSString *str = arr[i];
            NSInteger n;

            _messageText.font = sysFontWithSize(18);
            if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"]) {
                n = [g_faceVC.shortNameArrayE indexOfObject:str];
                //底表超出限制则说明不符合表情规则
                if (n >= 1000000000) {
//                    continue;
                    NSMutableString *textViewStr = [_messageText.text mutableCopy];
                    [textViewStr insertString:str atIndex:_messageText.selectedRange.location];
                    _messageText.text = textViewStr;

                }else{
                    NSDictionary *dic ;
                    if (g_constant.emojiArray.count > n) {
                        dic = [g_constant.emojiArray objectAtIndex:n];
                    }
                    [self selectImageNameString:dic[@"filename"]?:@"" ShortName:str isSelectImage:NO];
                }
                
                NSLog(@"");
            }else {
//                NSMutableString *textViewStr = [_messageText.text mutableCopy];
//                [textViewStr insertString:str atIndex:_messageText.selectedRange.location];
//                _messageText.text = textViewStr;
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

                NSRange newRange = NSMakeRange(_messageText.selectedRange.location + str.length - 1, 0);
                [_messageText.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:str attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:sysFontWithSize(18)}] atIndex:_messageText.selectedRange.location];

                _messageText.selectedRange = newRange;

                [_messageText scrollRangeToVisible:NSMakeRange(_messageText.text.length, 1)];
            }
        }
        return NO;
    }
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        //        if(textView.tag == kWCMessageTypeGif)
        //            [self sendGif:textView];
        //        else
        [self sendIt:textView];
        [self setTableFooterFrame:textView];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }else if ([text isEqualToString:@"@"] && [self.roomJid length]>0){
        
        if ((_messageText.selectedRange.location + 1) >= _messageText.text.length) {
            /// 获取当前登录用户
            memberData *loginMember = [self getCurrentLoginMerber];
            /// 当前登录用户是不是管理者
            BOOL isManger = [self isManger:loginMember];
            /// 当前登录用户不是管理者 并且开启了不允许群成员私聊 进入判断
            if (!isManger && !self.room.allowSendCard) {
                if (!ChatViewControllCanAtGroupMember) {
                    return YES;//返回值后则不能@群成员
                }
            }
            
            //@群成员
            static BOOL isWaitingShowAtSelectMemberView = NO;
            if (!isWaitingShowAtSelectMemberView) {
                isWaitingShowAtSelectMemberView = YES;
                [self performSelector:@selector(WH_showAtSelectMemberView) withObject:nil afterDelay:0.35];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                isWaitingShowAtSelectMemberView = NO;
            });
        }
        
    }
    
    return YES;
}

- (NSArray<NSTextCheckingResult *> *)findAllAt
{
    // 找到文本中所有的@
    NSString *string = _messageText.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
}

/**
 获取当前登录用户
 
 @return <#return value description#>
 */
- (memberData *)getCurrentLoginMerber {
    memberData *currentMember = nil;
    WH_JXUserObject *currentUser = g_myself;
    for (memberData *member in self.room.members) {
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

#pragma mark - 有表情的txt 转换成 含图片的txt
- (BOOL)changeEmjoyText:(NSString *)text textColor:(UIColor *)textColor {
    NSMutableArray *arr = [NSMutableArray array];
    [self getImageRange:text array:arr];
    NSRange newRange = _messageText.selectedRange;
    if (arr.count > 1) {
        for (NSInteger i = 0; i < arr.count; i ++) {
            NSString *str = arr[i];
            NSInteger n;
            
            _messageText.font = sysFontWithSize(18);
            if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"] && [g_faceVC.shortNameArrayE containsObject:str]) {
                n = [g_faceVC.shortNameArrayE indexOfObject:str];
                NSDictionary *dic ;
                if (g_constant.emojiArray.count > n) {
                    dic = [g_constant.emojiArray objectAtIndex:n];
                }

                WH_EmojiTextAttachment *attachment = [[WH_EmojiTextAttachment alloc] init];
                attachment.emojiTag = str;
                attachment.image = [UIImage imageNamed:dic[@"filename"]?:@""];
                attachment.bounds = CGRectMake(0, -4, _messageText.font.lineHeight, _messageText.font.lineHeight);
                
                newRange = NSMakeRange(newRange.location + 1, 0);
                [_messageText.textStorage appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                _messageText.font = sysFontWithSize(18);
                
                [_messageText scrollRangeToVisible:NSMakeRange(_messageText.text.length, 1)];
            }else {
                newRange = NSMakeRange(newRange.location + str.length, 0);

                [_messageText.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:str         attributes:@{NSFontAttributeName:sysFontWithSize(18),NSForegroundColorAttributeName:textColor}]];
                [_messageText scrollRangeToVisible:NSMakeRange(_messageText.text.length, 1)];
            }
            
        }
        _messageText.selectedRange = newRange;
    }
    return arr.count > 1;
}

//将表情和文字分开，装进array
-(void)getImageRange:(NSString*)message  array: (NSMutableArray*)array {
    NSRange range=[message rangeOfString: @"["];
    NSRange range1=[message rangeOfString: @"]"];
    NSRange atRange = [message rangeOfString:@"@"];
    //判断当前字符串是否还有表情的标志。
    
//    self.contentEmoji = [self isContainsEmoji:message];
    
    if (((range.length>0 && range1.length>0) || atRange.length>0) && range1.location > range.location) {
        if (range.length>0 && range1.length>0) {
//            self.contentEmoji = YES;
            if (range.location > 0) {
                [array addObject:[message substringToIndex:range.location]];
                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str array:array];
            }else {
                NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
                //排除文字是“”的
                if (![nextstr isEqualToString:@""]) {
                    [array addObject:nextstr];
                    NSString *str=[message substringFromIndex:range1.location+1];
                    [self getImageRange:str array:array];
                }else {
                    return;
                }
            }
            
        } else if (atRange.length>0) {
            if (atRange.location > 0) {
                [array addObject:[message substringToIndex:atRange.location]];
                [array addObject:[message substringWithRange:NSMakeRange(atRange.location, 1)]];
                NSString *str=[message substringFromIndex:atRange.location+1];
                [self getImageRange:str array:array];
            }else{
                [array addObject:[message substringWithRange:NSMakeRange(atRange.location, 1)]];
                NSString *str=[message substringFromIndex:atRange.location+1];
                [self getImageRange:str array:array];
            }
            
        }else if (message != nil) {
            [array addObject:message];
        }
    }else if (message != nil) {
        [array addObject:message];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    //如果是提示内容，光标放置开始位置
    if (textView.textColor==[UIColor lightGrayColor]) {
        NSRange range;
        range.location = 0;
        range.length = 0;
        textView.selectedRange = range;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.text.length <= 0) {
        [self removeAllAt];
        // 显示水印
        [self getTextViewWatermark];
    }
    
    [self setTableFooterFrame:textView];
    
    // 发送正在输入过滤条件
//    BOOL enteringStatus = [g_default boolForKey:kStartEnteringStatus];
    BOOL enteringStatus = [g_myself.isTyping intValue] > 0 ? YES : NO;
    if (!enteringStatus || self.roomJid || self.isSendEntering) {
        return;
    }
    
    {// 发送正在输入
        self.isSendEntering = YES;
        [self sendEntering];
        [self.enteringTimer invalidate];
        self.enteringTimer = nil;
        self.enteringTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(enteringTimerAction:) userInfo:nil repeats:NO];
    }

}

- (void) enteringTimerAction:(NSTimer *)timer {
    self.isSendEntering = NO;
    [self.enteringTimer invalidate];
    self.enteringTimer = nil;
}

- (void) setTableFooterFrame:(UITextView *) textView {
    
    static CGFloat maxHeight =66.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
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
//    if (textView.hidden) {
//        size.height = 32 + 5.5;
//    }
    self.wh_heightFooter = size.height + 16;
    if (self.isHiddenFooter) {
        self.wh_heightFooter =0;
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    //改变textView的倒角
    textView.layer.cornerRadius = size.height > 36.f ? g_factory.cardCornerRadius : (CGRectGetHeight(textView.frame) / 2.0f);
    inputBar.frame = CGRectMake(inputBar.frame.origin.x, inputBar.frame.origin.y, inputBar.frame.size.width, self.wh_heightFooter);
    self.wh_tableFooter.frame = CGRectMake(0, self.view.frame.size.height+self.deltaHeight-size.height-16, JX_SCREEN_WIDTH, self.wh_heightFooter);
    CGFloat height = 0;
    if (self.wh_heightFooter > 0) {
        height = self.wh_tableFooter.frame.origin.y;
    }else {
        height = JX_SCREEN_HEIGHT;
    }
    _table.frame =CGRectMake(_table.frame.origin.x,_table.frame.origin.y,self_width,JX_SCREEN_HEIGHT-_table.frame.origin.y-(JX_SCREEN_HEIGHT - height));
    [_table WH_gotoLastRow:NO];
    
    _publicMenuBar.frame = CGRectMake(_publicMenuBar.frame.origin.x, self.wh_tableFooter.frame.size.height, _publicMenuBar.frame.size.width, _publicMenuBar.frame.size.height);
    
    
    self.screenShotView.frame = CGRectMake(self.screenShotView.frame.origin.x, self.wh_tableFooter.frame.origin.y - self.screenShotView.frame.size.height - 10, self.screenShotView.frame.size.width, self.screenShotView.frame.size.height);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    _btnFace.selected = NO;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self doEndEdit];
    return YES;
}




-(void)recordSwitch:(UIButton*)sender{
    if([self showDisableSay])
        return;
    _messageText.inputView = nil;
    [_messageText reloadInputViews];

    sender.selected = !sender.selected;
    _recordBtn.hidden = !sender.selected;
    _messageText.hidden = !_recordBtn.hidden;
    if(!_recordBtn.hidden)
        [self hideKeyboard:YES];
    
    [self setTableFooterFrame:_messageText];
}

//聊天位置被点击
-(void)onDidLocation:(WH_JXMessageObject*)msg{
    JXLocationVC* vc = [JXLocationVC alloc];
    vc.longitude = [msg.location_y doubleValue];
    vc.latitude = [msg.location_x doubleValue];
    vc.locationType = JXLocationTypeShowStaticLocation;
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
//    [vc release];
}

//cell里的图片，被点击后的处理事件
-(void)onSelectImage:(WH_JXImageView*)sender{
//    [sender removeFromSuperview];
}

-(void)offRecordBtns{
    _recordBtnLeft.selected = NO;
    _recordBtn.hidden = YES;
    _messageText.hidden = NO;
}


-(void)WH_scrollToPageUp{
    if(_isLoading)
        return;
    NSLog(@"WH_scrollToPageUp");
    _page ++;
    [self WH_getServerData];
}

-(void)WH_scrollToPageDown{
    if(_isLoading)
        return;
    _page=0;
    [self WH_getServerData];
}
#pragma mark - ViewLoad获取数据
-(void)WH_getServerData{
    _isLoading = YES;
    [self refresh:nil loadHistory:YES];
    NSLog(@"_isLoading=no");
    [self WH_stopLoading];
}


//- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self hideKeyboard:NO];
//}

-(void)sendText:(UIView*)sender{
    if([_messageText.text length]<=0){
//        [g_App showAlert:Localized(@"JXAlert_MessageNotNil")];
        return;
    }
//    [self hideKeyboard:NO];
    [self sendIt:nil];
    [self setTableFooterFrame:_messageText];
}

-(void) setChatPerson:(WH_JXUserObject*)user{
    if(user == nil || user == chatPerson){
        current_chat_userId = nil;
        return;
    }
//    chatPerson = [user retain];
    chatPerson = user;
    current_chat_userId = user.userId;
}

#pragma mark----发送消息并显示
-(void)resendMsgNotif:(NSNotification*)notification{
    int indexNum = [notification.object intValue];
    WH_JXMessageObject *p =[_array objectAtIndex:indexNum];
    [p updateIsSend:transfer_status_ing];
    NSIndexPath* cellIndex = [NSIndexPath indexPathForRow:indexNum inSection:0];
    _selCell = [_table cellForRowAtIndexPath:cellIndex];
    [_selCell drawIsSend];
    if([p.isUpload boolValue]){
        [g_xmpp sendMessage:p roomName:nil];//发送消息
    }else{
        /*直接上传服务器,改为上传obs*/
//        [g_server uploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        [OBSHanderTool handleUploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:@"" toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                //请求
                NSMutableDictionary* p = [NSMutableDictionary dictionary];
                [p setValue:fileUrl forKey:@"oUrl"];
                [p setValue:fileName forKey:@"oFileName"];
                [p setValue:@"1" forKey:@"status"];
                if (self.isMapMsg) {
                    [self sendMapMsgWithDict:p];
                }else {
                    [self WH_doSendAfterUpload:p];
                }
                p = nil;
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
}

#pragma mark----删除消息并刷新
-(void)deleteMsgNotif:(NSNotification*)notification{
    int indexNum = [notification.object intValue];
    WH_JXMessageObject *p=[_array objectAtIndex:indexNum];
    [p delete];
    [_array removeObject:p];
    [self deleteMsg:p];
}

- (void)showReadPersons:(NSNotification *)notification{
    if (recording) {
        return;
    }
    int indexNum = [notification.object intValue];
    WH_JXMessageObject *msg = _array[indexNum];
    WH_JXReadList_WHVC *vc = [[WH_JXReadList_WHVC alloc] init];
    vc.msg = msg;
    vc.room = _room;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)resend:(WH_JXMessageObject*)p{
//    NSLog(@"resend");
    [p updateIsSend:transfer_status_ing];
    [_selCell drawIsSend];
    if([p.isUpload boolValue]){
        [g_xmpp sendMessage:p roomName:self.roomJid];//发送消息
    }else{
        /*直接上传服务器,改为上传obs*/
//        [g_server uploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        [OBSHanderTool handleUploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:@"" toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                //请求
                NSMutableDictionary* p = [NSMutableDictionary dictionary];
                [p setValue:fileUrl forKey:@"oUrl"];
                [p setValue:fileName forKey:@"oFileName"];
                [p setValue:@"1" forKey:@"status"];
                if (self.isMapMsg) {
                    [self sendMapMsgWithDict:p];
                }else {
                    [self WH_doSendAfterUpload:p];
                }
                p = nil;
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
}

-(void)deleteMsg:(WH_JXMessageObject*)p{
    for (NSInteger i = 0; i < _array.count; i ++) {
        WH_JXMessageObject *msg = _array[i];
        if ([msg.type intValue] == kWCMessageTypeText) {
            WH_JXMessage_WHCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (![cell isKindOfClass:[WH_ReadDelTimeCell class]]) {
                [cell.readDelTimer invalidate];
                cell.readDelTimer = nil;
            }
            
            if ([p.messageId isEqualToString:msg.messageId]) {
                if (i == _array.count - 1 && i > 0) {
                    WH_JXMessageObject *theLastMsg = _array[_array.count - 2];
                    self.lastMsg = theLastMsg;
                    [theLastMsg updateLastSend:UpdateLastSendType_None];
                }
            }
        }
    }
    
    [_array removeObject:p];
    _refreshCount++;
    [_table reloadData];
}

-(void)actionQuit{
    
    [_voice wh_hide];
    [peakTimer invalidate];
    peakTimer = nil;
    recording = NO;
    
    if (self.isSelectMore) {
        self.isSelectMore = NO;
        self.selectMoreView.hidden = YES;
//        [self.wh_gotoBackBtn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
        [self.wh_gotoBackBtn setImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
        [self.wh_gotoBackBtn setTitle:nil forState:UIControlStateNormal];
        [_selectMoreArr removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    [g_notify postNotificationName:kAllVideoPlayerStopNotifaction object:nil userInfo:nil];
    [g_notify postNotificationName:kAllAudioPlayerStopNotifaction object:nil userInfo:nil];

    for (NSInteger i = 0; i < _array.count; i ++) {
        WH_JXMessageObject *msg = _array[i];
        if ([msg.type intValue] == kWCMessageTypeText) {
            WH_JXMessage_WHCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (![cell isKindOfClass:[WH_ReadDelTimeCell class]]) {
                [cell.readDelTimer invalidate];
                cell.readDelTimer = nil;
            }
        }
    }
    // 保存更新输入框中如如的信息
    if (_messageText.textColor != [UIColor lightGrayColor]) {
        chatPerson.lastInput = [_messageText.textStorage getPlainString];
        [chatPerson updateLastInput];
    }
    if (g_mainVC.msgVc.wh_array.count > 0) {
        [g_mainVC.msgVc.tableView WH_reloadRow:(int)self.rowIndex section:0];
    }

//    [g_notify postNotificationName:kChatViewDisappear object:nil];
    [g_xmpp.chatingUserIds removeObject:current_chat_userId];
    current_chat_userId = nil;
    [g_notify removeObserver:self];
    [super actionQuit];
}
-(void)showChatView{
    [_wait stop];
    NSDictionary * dict = _dataDict;
    //老房间:
    WH_JXRoomObject *chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
    
    WH_RoomData * roomdata = [[WH_RoomData alloc] init];
    [roomdata WH_getDataFromDict:dict];
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    sendView.title = [dict objectForKey:@"name"];
    sendView.roomJid = [dict objectForKey:@"jid"];
    sendView.roomId = [dict objectForKey:@"id"];
    sendView.chatRoom = chatRoom;
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
-(void)onInputHello:(WH_JXInput_WHVC*)sender{
    
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.fromUserId = MY_USER_ID;
    msg.toUserId = [NSString stringWithFormat:@"%@", [_dataDict objectForKey:@"userId"]];
    msg.fromUserName = MY_USER_NAME;
    msg.toUserName = [_dataDict objectForKey:@"nickname"];
    msg.timeSend = [NSDate date];
    msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    NSString *userIds = g_myself.userId;
    NSString *userNames = g_myself.userNickname;
    NSDictionary *dict = @{
                           @"userIds" : userIds,
                           @"userNames" : userNames,
                           @"roomJid" : self.roomJid,
                           @"reason" : sender.inputText,
                           @"isInvite" : [NSNumber numberWithBool:YES]
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    msg.objectId = jsonStr;
    [g_xmpp sendMessage:msg roomName:nil];
    [self actionQuit];
    
    //    msg.fromUserId = self.roomJid;
    //    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
    //    msg.content = @"申请已发送给群主，请等待群主确认";
    //    [msg insert:self.roomJid];
    //    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
    //        [self.delegate needVerify:msg];
    //    }
}

-(void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
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
        
    [g_server WH_addRoomMemberWithRoomId:dict[@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
    
    user.groupStatus = [NSNumber numberWithInt:0];
    [user WH_updateGroupInvalid];
    
    dict = nil;
//    chatRoom.delegate = nil;
    
    [self showChatView];
    [self actionQuit];
}

#pragma mark  -------------------服务器返回数据--------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if (![aDownload.action isEqualToString:wh_act_getRedPacket]) {
        [_wait stop];
    }
    if ([aDownload.action isEqualToString:act_delectRoomMsg]) {
        
        //双向撤回
        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
        msg.isGroup = YES;
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:self.room.roomJid];
        msg.toUserId = user.userId;
        [msg deleteAll];
        msg.type = [NSNumber numberWithInt:1];
        msg.content = @"";
        [msg updateLastSend:UpdateLastSendType_None];
        [msg notifyMyLastSend];
        // 清除本群所有任务
        
        [_array removeAllObjects];
        [_table reloadData];
        
        [[JXSynTask sharedInstance] deleteTaskWithRoomId:self.room.roomId];
        
        [GKMessageTool showText:@"双向撤回消息成功!"];
//        [self actionQuit];
    }
    if([aDownload.action isEqualToString:wh_act_UploadFile]){
        NSDictionary* p = nil;
        if([[dict objectForKey:@"audios"] count]>0)
            p = [[dict objectForKey:@"audios"] objectAtIndex:0];
        if([[dict objectForKey:@"images"] count]>0)
            p = [[dict objectForKey:@"images"] objectAtIndex:0];
        if([[dict objectForKey:@"videos"] count]>0)
            p = [[dict objectForKey:@"videos"] objectAtIndex:0];
        if(p==nil)
            p = [[dict objectForKey:@"others"] objectAtIndex:0];

        if (self.isMapMsg) {
            [self sendMapMsgWithDict:p];
        }else {
            [self WH_doSendAfterUpload:p];
        }
        p = nil;
    }
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        
        if (self.firstGetUser || self.courseId.length > 0) {
            WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
            [user WH_getDataFromDict:dict];
            [_room setNickNameForUser:user];
            
            WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
            vc.wh_user       = user;
            vc.isAddFriend = user.isAddFirend;
            vc.wh_isJustShow = self.courseId.length > 0;
            vc.wh_fromAddType = 3;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
        }else {
            
            self.isBeenBlack = [[[dict objectForKey:@"friends"] objectForKey:@"isBeenBlack"] intValue];
            self.friendStatus = [[[dict objectForKey:@"friends"] objectForKey:@"status"] intValue];
            self.firstGetUser = YES;
            self.onlinestate = [dict[@"onlinestate"] boolValue];
            if([chatPerson.userId intValue]<10100 && [chatPerson.userId intValue]>=10000) {
                if (chatPerson.userNickname) {
                    self.title = chatPerson.userNickname;
                }else {
                    self.title = dict[@"nickname"];
                }
            }else {
                if (self.courseId.length > 0) {
                    
                }else {
                    NSString *str = self.onlinestate ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
                    if (chatPerson.userNickname) {
                        self.title = [NSString stringWithFormat:@"%@",chatPerson.remarkName.length > 0 ? chatPerson.remarkName : chatPerson.userNickname];
                    }else {
                        self.title = [NSString stringWithFormat:@"%@",dict[@"nickname"]];
                    }
                }
                
            }
            
            
            if ([dict[@"userType"] intValue] == 2) {    // 获取公众号菜单
                // 获取公众号菜单
                [g_server WH_getPublicMenuListWithUserId:chatPerson.userId toView:self];
            }
//            else {
//                // 获取公众号菜单
//                [g_server getPublicMenuListWithUserId:chatPerson.userId toView:self];
//            }
            
            
            
        }
        
        
    }
    if( [aDownload.action isEqualToString:wh_act_roomGet] ){
        
        
        self.noticesArry = [[dict objectForKey:@"notices"] mutableCopy];
        
        
        NSDictionary *member = dict[@"member"];
        if (member) {
            NSInteger role = [member[@"role"] integerValue];
            _isAdmin = role == 1 || role == 2;
        }
        
        WH_RoomData *room = [[WH_RoomData alloc] init];
        [room WH_getDataFromDict:dict];
        self.room = room;
        
        //        [_room WH_getDataFromDict:dict];
        //
        //        WH_JXRoomMember_WHVC* vc = [WH_JXRoomMember_WHVC alloc];
        //        vc.chatRoom   = chatRoom;
        //        vc.room       = _room;
        //        vc.delegate = self;
        //        vc = [vc init];
        ////        [g_window addSubview:vc.view];
        //        [g_navigation pushViewController:vc animated:YES];
        
        _dataDict = dict;
        
        if ([[dict objectForKey:@"s"] integerValue] == 1) {
            self.isDisable = NO;
        }else {
            self.isDisable = YES;
        }
        
        if(g_xmpp.isLogined == login_status_no){
            //        [self hideKeyboard:NO];
            //        [g_xmpp showXmppOfflineAlert];
            //        return YES;
            
            //        [g_xmpp logout];
            [g_xmpp login];
            
        }
        
        //        _chatRoom = [g_xmpp.roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
        
        //首次请求到群成员插入到本地
        if (self.isFirst) {
            self.isFirst = NO;
            
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:dict];
            
            NSMutableArray *memb = [NSMutableArray array];
            NSArray *members = [dict objectForKey:@"members"];
            for (NSDictionary *member in members) {
                memberData* option = [[memberData alloc] init];
                [option WH_getDataFromDict:member];
                option.roomId = self.roomId;
                //                [option insert];
                [memb addObject:option];
            }
            
            if (_room.members.count <= 0) {
                [_room.members addObjectsFromArray:memb];
            } else if (memb.count && _room.members.count != memb.count){
                [_room.members removeAllObjects];
                [_room.members addObjectsFromArray:memb];
            }
            
            return;
        }
        
        [self.tableView reloadData];
        //旧代码业务逻辑,暂时删除
        /*
        WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:[dict objectForKey:@"jid"]];
        if(user && [user.groupStatus intValue] == 0){
            
            //老房间:
            //            [self showChatView];
            //            [self actionQuit];
        }else if ([user.groupStatus intValue] == 1) {
            return;
        }else{
            WH_JXRoomObject *chatRoomObj = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
            BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
            long userId = [dict[@"userId"] longLongValue];
            if (isNeedVerify && userId != [g_myself.userId longLongValue]) {
                
                self.roomJid = [dict objectForKey:@"jid"];
                //                self.roomUserName = [dict objectForKey:@"nickname"];
                //                self.roomUserId = [dict objectForKey:@"userId"];
                
                WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
                vc.delegate = self;
                vc.didTouch = @selector(onInputHello:);
                vc.inputTitle = Localized(@"JX_GroupOwnersHaveEnabled");
                vc.titleColor = [UIColor lightGrayColor];
                vc.titleFont = [UIFont systemFontOfSize:13.0];
                vc.inputHint = Localized(@"JX_PleaseEnterTheReason");
                vc = [vc init];
                [g_window addSubview:vc.view];
            }else {
                
                [_wait start:Localized(@"JXAlert_AddRoomIng") delay:30];
                //新房间:
                chatRoomObj.delegate = self;
                [chatRoomObj joinRoom:YES];
            }
        }
         */
    }
    if( [aDownload.action isEqualToString:wh_act_roomMemberGet] ){
        _personalBannedTime = [[dict objectForKey:@"talkTime"] longLongValue]; //个人禁言时间
        _disableSay = [[dict objectForKey:@"talkTime"] longLongValue];
        _audioMeetingNo = [NSString stringWithFormat:@"%@",dict[@"call"]];
        _videoMeetingNo = [NSString stringWithFormat:@"%@",dict[@"videoMeetingNo"]];
        _userNickName = dict[@"nickname"];
        [_table reloadData];
        
        if (self.relayMsgArray.count > 0) {
            for (WH_JXMessageObject *msg in self.relayMsgArray) {
                if ([msg.type intValue] == kWCMessageTypeRedPacket) {
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                    msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JXredPacket")];
                }
                if ([msg.type intValue] == kWCMessageTypeRedPacketExclusive ) {
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                    msg.content = [NSString stringWithFormat:@"[%@]", @"专属红包"];
                }
                if ([msg.type intValue] == kWCMessageTypeTransfer) {
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                    msg.content = [NSString stringWithFormat:@"[%@%@]", Localized(@"JX_Transfer") ,Localized(@"WaHu_JXMain_WaHuViewController_Message")];
                }
                if ([msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [msg.type intValue] == kWCMessageTypeVideoMeetingInvite || [msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeAudioChatEnd || [msg.type intValue] == kWCMessageTypeVideoChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatEnd) {
                    
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                    msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JX_AudioAndVideoCalls")];
                }
                [self relay:msg];
            }
//            [self relay];
        }
    }
    if ([aDownload.action isEqualToString:wh_act_roomMemberList]) {
        _room.roomId = roomId;
        _room.members = [array1 mutableCopy];
        
        memberData *data = [self.room getMember:g_myself.userId];
        if ([data.role intValue] == 1 || [data.role intValue] == 2) {
            _isAdmin = YES;
        }else {
            _isAdmin = NO;
        }
        self.groupSize = array1.count;
        
        self.title = [NSString stringWithFormat:@"%@(%ld)", self.chatPerson.userNickname, array1.count];
    }
    //获取红包信息
    if ([aDownload.action isEqualToString:wh_act_getRedPacket]) {
//        if ([dict[@"packet"][@"type"] intValue] != 3) {
        NSString *userId = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"packet"] objectForKey:@"userId"]];
        if (self.roomJid.length > 0) {
            if (self.isDidRedPacketRemind) {
                self.isDidRedPacketRemind = NO;
                WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
                redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:dict];
                redPacketDetailVC.isGroup = self.room.roomId.length > 0;
                [g_navigation pushViewController:redPacketDetailVC animated:YES];
            }else {
                [self WH_showRedPacket:dict];
            }
            
//            [g_server openRedPacket:dict[@"packet"][@"id"] toView:self];
        }else {
            [_wait stop];
            if ([userId isEqualToString:MY_USER_ID]) {
//                [self changeMessageRedPacketStatus:dict[@"packet"][@"id"]];
//                [self changeMessageArrFileSize:dict[@"packet"][@"id"]];
                
                WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
                redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:dict];
                redPacketDetailVC.isGroup = self.room.roomId.length > 0;
                [g_navigation pushViewController:redPacketDetailVC animated:YES];
            }else {
//                [g_server openRedPacket:dict[@"packet"][@"id"] toView:self];
                [self WH_showRedPacket:dict];
            }
        }
//        }
        
    }
    
    if ([aDownload.action isEqualToString:wh_act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
    }else if ([aDownload.action isEqualToString:wh_act_tigaseMsgs] || [aDownload.action isEqualToString:wh_act_tigaseMucMsgs]) {// 漫游聊天记录
        if (array1.count > 0) {
            NSString* s;
            if([self.roomJid length]>0)
                s = self.roomJid;
            else
                s = chatPerson.userId;
            [[WH_JXMessageObject sharedInstance] getHistory:array1 userId:s];
            
            if (self.roomJid && _taskList.count > 0) {
                JXSynTask *task = _taskList.firstObject;
                if (array1.count < PAGECOUNT) {
                    [task delete];
                    [_taskList removeObjectAtIndex: 0];
                }else {
                    NSDictionary *dict = array1.lastObject;
                    task.endTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:kMESSAGE_TIMESEND] doubleValue]];
                }
                
                self.isGetServerMsg = NO;
                self.scrollLine = 1;
                [self refresh:nil loadHistory:YES];

                
            }else {
                
                self.wh_isShowHeaderPull = array1.count >= 20;
                [_array removeAllObjects];
                _page = 0;
                
                self.isGetServerMsg = NO;
                self.scrollLine = 1;
                [self refresh:nil loadHistory:YES];
            }
        }
        else{
            
            if (self.roomJid && _taskList.count > 0) {
                JXSynTask *task = _taskList.firstObject;
                [task delete];
                [_taskList removeObjectAtIndex: 0];
                
                self.isGetServerMsg = NO;
                self.scrollLine = 0;
                [self refresh:nil loadHistory:YES];
            }else {
                self.wh_isShowHeaderPull = NO;
            }
        }
    }else if ([aDownload.action isEqualToString:wh_act_publicMenuList]) {
        
        _menuList = [NSArray arrayWithArray:array1];
        if (_menuList.count > 0) {
            [self createFooterSubViews];
        }
        
    }else if ([aDownload.action isEqualToString:wh_act_tigaseDeleteMsg]) {
    
    if (self.withdrawIndex >= 0) {
        [_wait start];
        WH_JXMessageObject *msg = _array[self.withdrawIndex];
        
        // 发送撤回消息的XMPP
        WH_JXMessageObject *newMsg=[[WH_JXMessageObject alloc]init];
        newMsg.timeSend     = [NSDate date];
        newMsg.fromUserId   = MY_USER_ID;
        
        if([self.roomJid length]>0){
            newMsg.isGroup = YES;
            newMsg.fromUserName = _userNickName;
            newMsg.toUserId = self.roomJid;
        }
        else{
            newMsg.fromUserName = MY_USER_NAME;
            newMsg.toUserId     = chatPerson.userId;
        }
        newMsg.content      = msg.messageId;
        newMsg.type         = [NSNumber numberWithInt:kWCMessageTypeWithdraw];
        newMsg.isSend = [NSNumber numberWithInt:transfer_status_ing];
        
        [g_xmpp sendMessage:newMsg roomName:self.roomJid];//发送消息
    }
    
}else if ([aDownload.action isEqualToString:wh_act_userEmojiAdd]) {// 收藏表情
        if ([dict[@"type"] intValue] == CollectTypeEmoji) {
            [g_myself.favorites addObject:dict];
            [g_notify postNotificationName:kFavoritesRefresh_WHNotification object:nil];
        }
        
        [JXMyTools showTipView:Localized(@"JX_CollectionSuccess")];
        
        
        if (self.isSelectMore) {
            [self actionQuit];
        }
    }else if ([aDownload.action isEqualToString:wh_act_userCourseAdd]) {// 添加课程
        [JXMyTools showTipView:Localized(@"JX_AddSuccess")];
    }else if ([aDownload.action isEqualToString:wh_act_userCourseUpdate]) {
        [JXMyTools showTipView:Localized(@"JXAlert_DeleteOK")];
        [g_notify postNotificationName:kUpdateCourseList_WHNotification object:nil];
    }else if ([aDownload.action isEqualToString:wh_act_UploadCopyFileServlet]) {// 发送收藏 拷贝文件
        [self WH_collectionFileMsgSend:dict[@"url"]];
    }else if ([aDownload.action isEqualToString:wh_act_UserOpenMeet]) {    //获取音视频服务器地址
        self.meetUrl = [dict objectForKey:@"meetUrl"];
        if (self.isAudioMeeting) {
            [self onChatAudio:nil];
        }else{
            [self onChatVideo:nil];
        }
    }else if ([aDownload.action isEqualToString:wh_act_roomGetRoom]) {
        self.groupNum = [NSString stringWithFormat:@"%@" ,dict[@"userSize"]];
        self.groupSize = [dict[@"userSize"] integerValue];
        self.title = [NSString stringWithFormat:@"%@(%ld)", self.chatPerson.userNickname, [dict[@"userSize"] integerValue]];
        if ([dict[@"userSize"] integerValue] != _room.members.count) {
            self.isFirst = YES;
            [g_server getRoom:self.room.roomId toView:self];
        }
        if ([dict objectForKey:@"jid"]) {
            
            if (![dict objectForKey:@"member"]) {
                [JXMyTools showTipView:@"你已被踢出群组"];
                chatPerson.groupStatus = [NSNumber numberWithInt:1];
                [chatPerson WH_updateGroupInvalid];
            }else {
                
                if ([[dict objectForKey:@"s"] integerValue] != 1) {
                    [JXMyTools showTipView:@"此群组已被禁用"];
                    self.isDisable = YES;
                    return;
                }
                
                _disableSay = [[[dict objectForKey:@"member"]objectForKey:@"talkTime"] longLongValue];
                self.chatPerson.talkTime = [NSNumber numberWithInt:[[dict objectForKey:@"talkTime"] intValue]];
                NSString *role = [[dict objectForKey:@"member"] objectForKey:@"role"];
                if (([self.chatPerson.talkTime longLongValue] > 0 && !_isAdmin) || [role intValue] == 4) {
                    _talkTimeLabel.hidden = NO;
                    _talkTimeLabel.text = @"全员禁言";
                    if ([role intValue] == 4) {
                        _talkTimeLabel.text = @"禁止发言";
                    }
                    _messageText.userInteractionEnabled = NO;
                    _shareMore.enabled = NO;
                    _recordBtnLeft.enabled = NO;
                    _btnFace.enabled = NO;
                    _messageText.text = nil;
                    _recordBtn.enabled = NO;
                }else {
                    _talkTimeLabel.hidden = YES;
                    _shareMore.enabled = YES;
                    _recordBtnLeft.enabled = YES;
                    _btnFace.enabled = YES;
                    _messageText.userInteractionEnabled = YES;
                    _recordBtn.enabled = YES;
                }
                
                self.chatPerson.showRead = [dict objectForKey:@"showRead"];
                self.chatPerson.allowSendCard = [dict objectForKey:@"allowSendCard"];
                self.chatPerson.allowConference = [dict objectForKey:@"allowConference"];
                self.chatPerson.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
                self.chatPerson.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
                [self.chatPerson WH_updateGroupSetting];
                self.chatPerson.chatRecordTimeOut = [dict objectForKey:@"chatRecordTimeOut"];
                [self.chatPerson WH_updateUserChatRecordTimeOut];
                if (self.chatRoom.roomJid.length > 0) {
                    NSString *noticeStr = [[dict objectForKey:@"notice"] objectForKey:@"text"];
                    NSString *noticeTime = [[dict objectForKey:@"notice"] objectForKey:@"time"];
                    [self setupNoticeWithContent:noticeStr time:noticeTime];
                }
                
                // 保存自己
                NSDictionary* p = [dict objectForKey:@"member"];
                memberData* option = [[memberData alloc] init];
                [option WH_getDataFromDict:p];
                option.roomId = self.roomId;
                [option insert];
                
                // 保存群主和管理员
                NSMutableArray *memb = [NSMutableArray array];
                NSArray *members = [dict objectForKey:@"members"];
                for (NSDictionary *member in members) {
                    memberData* option = [[memberData alloc] init];
                    [option WH_getDataFromDict:member];
                    option.roomId = self.roomId;
                    [option insert];
                    [memb addObject:option];
                }
                
            }
            
        }else {
            [JXMyTools showTipView:Localized(@"JX_GroupDissolved")];
            chatPerson.groupStatus = [NSNumber numberWithInt:2];
            [chatPerson WH_updateGroupInvalid];
        }
    }
//    [_table reloadData];
}


#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [self WH_doUploadError:aDownload];
    [_wait stop];
    
    //自己查看红包或者红包已领完，resultCode ＝0
    if ([aDownload.action isEqualToString:wh_act_getRedPacket]) {
        
//        [self changeMessageRedPacketStatus:dict[@"data"][@"packet"][@"id"]];
//        [self changeMessageArrFileSize:dict[@"data"][@"packet"][@"id"]];
        
        WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
        redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:dict];
        redPacketDetailVC.isGroup = self.room.roomId.length > 0;
//        [g_window addSubview:redPacketDetailVC.view];
        [g_navigation pushViewController:redPacketDetailVC animated:YES];
        
    }else if ([aDownload.action isEqualToString:wh_act_roomGetRoom]) {
        if ([dict[@"resultCode"] intValue] == 0) {
            if (dict[@"resultMsg"]) {
                //群组已解散
                [JXMyTools showTipView:dict[@"resultMsg"]];
                chatPerson.groupStatus = [NSNumber numberWithInt:2];
                [chatPerson WH_updateGroupInvalid];
            }
        }
    }else if ([aDownload.action isEqualToString:wh_act_userEmojiAdd]) {
        return WH_show_error;
    }else if ([aDownload.action isEqualToString:act_delectRoomMsg]) {
        //双向撤回
        return WH_show_error;
    }
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [self WH_doUploadError:aDownload];
    [_wait stop];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    if([aDownload.action isEqualToString:wh_act_UploadFile] || [aDownload.action isEqualToString:wh_act_publicMenuList])
        return;
    if ([aDownload.action isEqualToString:wh_act_tigaseDeleteMsg]) {
        // 撤回加等待符（撤回接口调用很慢）
        [_wait start];
    }
}

- (void)WH_collectionFileMsgSend:(NSString *)url {
    
    NSString *userId = self.userIds[self.groupMessagesIndex];
    NSString *userName = self.userNames[self.groupMessagesIndex];
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    if([self.roomJid length]>0){
        msg.toUserId = self.roomJid;
        msg.isGroup = YES;
        msg.fromUserName = _userNickName;
    }
    else{
        if (self.isGroupMessages) {
            msg.toUserId = userId;
        }else {
            msg.toUserId     = chatPerson.userId;
        }
        msg.isGroup = NO;
    }
    msg.content      = url;
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = self.chatPerson.isOpenReadDel;

    switch (_collectionData.type) {
        case 2:
            msg.type = [NSNumber numberWithInt:kWCMessageTypeImage];
            break;
        case 3:{
            msg.type = [NSNumber numberWithInt:kWCMessageTypeVoice];
            ObjUrlData *obj = _collectionData.audios.firstObject;
            msg.timeLen = obj.timeLen;
        }
            break;
        case 4:
            msg.fileName = ((ObjUrlData *)_collectionData.videos.firstObject).url;
            msg.type = [NSNumber numberWithInt:kWCMessageTypeVideo];
            break;
        case 5:{
            msg.fileName = ((ObjUrlData *)_collectionData.files.firstObject).name;
            msg.type = [NSNumber numberWithInt:kWCMessageTypeFile];
        }
            break;
            
        default:
            break;
    }
    
    //发往哪里
    [msg insert:self.roomJid];
    
    [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
    
    if (self.isGroupMessages) {
        self.groupMessagesIndex ++;
        if (self.groupMessagesIndex < self.userIds.count) {
            [self WH_collectionFileMsgSend:url];
        }else if (self.userIds){
            self.groupMessagesIndex = 0;
            [g_App showAlert:Localized(@"JX_SendComplete")];
            return;
        }
        return;
    }
    [self WH_show_WHOneMsg:msg];
}

-(void)WH_showAtSelectMemberView{
    [self hideKeyboard:NO];
    if (_room.members.count >0) {
        WH_JXSelFriend_WHVC * selVC = [[WH_JXSelFriend_WHVC alloc] init];
//        selVC.chatRoom = chatRoom;
        _room.roomJid = _roomJid;
        selVC.room = _room;
        selVC.type = JXSelUserTypeGroupAT;
        selVC.delegate = self;
        selVC.didSelect = @selector(atSelectMemberDelegate:);
        
//        [g_window addSubview:selVC.view];
        [g_navigation pushViewController:selVC animated:YES];
    }else{
        //调接口
        [g_App showAlert:Localized(@"JX_NoGetMemberList")];
    }
}

-(void)removeAllAt{
    for (int i = 0; i<_atMemberArray.count; i++) {
        [self removeAtTextString:_atMemberArray[i]];
    }
    [_atMemberArray removeAllObjects];
}

-(void)removeAtTextString:(memberData *)member{
    NSString * atStr = [NSString stringWithFormat:@"@%@",member.userNickName];
    NSRange atRange = [[_messageText.textStorage string] rangeOfString:atStr];
    if (atRange.location != NSNotFound) {
        [_messageText.textStorage deleteCharactersInRange:atRange];
    }
    
}

-(BOOL)hasMember:(NSString*)theUserId{
    for(int i=0;i<[_atMemberArray count];i++){
        memberData* p = [_atMemberArray objectAtIndex:i];
        if([theUserId intValue] == p.userId)
            return YES;
    }
    return NO;
}

-(void)atSelectMemberDelegate:(memberData *)member{
    
    if (member.idStr) {
        [self removeAllAt];
        [_atMemberArray addObject:member];
    }else if([self hasMember:[NSString stringWithFormat:@"%ld",member.userId]]){
        if (_messageText.selectedRange.location >=1 && [[[_messageText.textStorage string] substringWithRange:NSMakeRange(_messageText.selectedRange.location-1, 1)] isEqualToString:@"@"]) {
            [_messageText.textStorage deleteCharactersInRange:NSMakeRange(_messageText.selectedRange.location-1, 1)];
        }
        return;
    }else{
        for (int i=0; i<_atMemberArray.count; i++) {
            memberData * member = _atMemberArray[i];
            if (member.idStr){
                [self removeAllAt];
                break;
            }
        }
        [_atMemberArray addObject:member];
    }
    NSLog(@"_messageText.selectedRange.location:%lu" ,(unsigned long)_messageText.selectedRange.location);
    
    NSInteger index = 0;
    if (_messageText.selectedRange.location == 1) {
        index = 0;
    }else{
        index = _messageText.selectedRange.location - 1;
    }
    if (_messageText.selectedRange.location >=1 && [[[_messageText.textStorage string] substringWithRange:NSMakeRange(_messageText.selectedRange.location-1, 1)] isEqualToString:@"@"]) {
        [_messageText.textStorage deleteCharactersInRange:NSMakeRange(_messageText.selectedRange.location-1, 1)];
    }
    
    
    NSString * atStr = [NSString stringWithFormat:@"@%@",member.userNickName];
    
    
    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:atStr];
//    [tncString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(0,atStr.length)];
    [tncString addAttribute:NSFontAttributeName value:sysFontWithSize(18) range:NSMakeRange(0,atStr.length)];
    
//    if (_messageText.selectedRange.length > 0) {
//        [_messageText.textStorage deleteCharactersInRange:_messageText.selectedRange];
//    }
    [_messageText.textStorage insertAttributedString:tncString atIndex:_messageText.selectedRange.location];
    
    tncString = nil;
    NSRange newRange = NSMakeRange(_messageText.selectedRange.location + atStr.length, 0);
     _messageText.selectedRange = newRange;
    
    NSMutableAttributedString* spaceString = [[NSMutableAttributedString alloc] initWithString:@" "];
    [_messageText.textStorage insertAttributedString:spaceString atIndex:_messageText.selectedRange.location];
    newRange = NSMakeRange(_messageText.selectedRange.location + spaceString.length, 0);
    _messageText.selectedRange = newRange;

    //    attachment.emojiSize = CGSizeMake(_messageText.font.lineHeight, _messageText.font.lineHeight);
    [self setTableFooterFrame:_messageText];
    
//
//    
//    
//    [_messageText.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:_messageText.selectedRange.location];
    
//    _messageText.selectedRange = newRange;
    _messageText.font = sysFontWithSize(18);
    
//    [_messageText scrollRangeToVisible:NSMakeRange(_messageText.text.length, 1)];
    
//    [_messageText becomeFirstResponder];
    [_messageText performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.7];
}

-(void)onSelMedia:(WH_JXMediaObject*)p{
    if (self.isGroupMessages) {
        for (NSInteger i = 0; i < self.userIds.count; i ++) {
            NSString *userId = self.userIds[i];
            
            [self sendMedia:p userId:userId];
//            [g_server uploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        }
    }else {
        [self sendMedia:p userId:nil];
//        [g_server uploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
    }
}

-(void)pickVideo{
    

    [self hideKeyboard:YES];
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 9;//最大的选择数目
    photoController.configuration.containVideo = YES;//选择类型，目前只选择图片不选择视频
    photoController.title = @"视频";
    photoController.photo_delegate = self;
    photoController.thumbnailSize = CGSizeMake(320, 320);//缩略图的尺寸
//    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoController animated:true completion:^{}];
//    WH_JXCamera_WHVC *vc = [[WH_JXCamera_WHVC alloc] init];
//    vc.cameraDelegate = self;
////    vc.maxTime = 30;
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
    
//    if ([[WH_JXMediaObject sharedInstance] fetch].count <= 0) {
//
//        WH_myMedia_WHVC* vc = [[WH_myMedia_WHVC alloc]init];
//        vc.delegate = self;
//        vc.didSelect = @selector(onSelMedia:);
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//        [vc onAddVideo];
//    }else {
//        WH_myMedia_WHVC* vc = [[WH_myMedia_WHVC alloc]init];
//        vc.delegate = self;
//        vc.didSelect = @selector(onSelMedia:);
////        [g_window addSubview:vc.view];
//        [g_navigation pushViewController:vc animated:YES];
//    }
}

#pragma mark - 視屏錄製回調
- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithVideoPath:(NSString *)filePath timeLen:(NSInteger)timeLen {
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath] )
        return;
    NSString* file = filePath;
    
    WH_JXMediaObject* p = [[WH_JXMediaObject alloc]init];
    p.userId = g_myself.userId;
    p.fileName = file;
    p.isVideo = [NSNumber numberWithBool:YES];
    p.timeLen = [NSNumber numberWithInteger:timeLen];
    if (self.isGroupMessages) {
        for (NSInteger i = 0; i < self.userIds.count; i ++) {
            NSString *userId = self.userIds[i];
            
            [self sendMedia:p userId:userId];
//            [g_server uploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
            [self saveVideo:file];
        }
    }else {
        [self sendMedia:p userId:nil];
//        [g_server uploadFile:p.fileName validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        [self saveVideo:file];
    }
}
- (void)saveVideo:(NSString *)videoPath{
    
    if (videoPath) {
        NSURL *url = [NSURL URLWithString:videoPath];
        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
        if (compatible) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}


//保存视频完成之后的回调
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }
    else {
        NSLog(@"保存视频成功");
    }
}

// 视频通话
-(void)onChatSip{
    [self hideKeyboard:YES];
    if (![self checkCameraLimits]) {
        return;
    }
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    
    NSString *str1;
    NSString *str2;
    if (self.roomJid.length > 0) {
        memberData *data = [self.room getMember:g_myself.userId];
       
        if (!_isAdmin && ![self.chatPerson.allowConference boolValue]) {
            [g_App showAlert:Localized(@"JX_DisabledAudioAndVideo")];
            return;
        }
        str1 = Localized(@"WaHu_JXSetting_WaHuVC_VideoMeeting");
        str2 = Localized(@"JX_Meeting");
    }else {
        str1 = Localized(@"JX_VideoChat");
        str2 = Localized(@"JX_VoiceChat");
    }
    
    // 视频通话
    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[@"meeting_tel",@"meeting_video"] names:@[str2, str1]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (actionSheet.wh_tag == 2457) {
        if (index == 0) {
            WH_JXRelay_WHVC*vc = [[WH_JXRelay_WHVC alloc] init];
            vc.relayMsgArray = [NSMutableArray arrayWithArray:self.selectMoreArr];
            [g_navigation pushViewController:vc animated:YES];
        }else if(index == 1) {
            WH_JXRelay_WHVC *vc = [[WH_JXRelay_WHVC alloc] init];
            
            NSMutableArray *contentArr = [NSMutableArray array];
            for (NSInteger i = 0; i < self.selectMoreArr.count; i ++) {
                WH_JXMessageObject *msg = [self.selectMoreArr[i] copy];
                
                if ([msg.type intValue] != kWCMessageTypeText && [msg.type intValue] != kWCMessageTypeLocation && [msg.type intValue] != kWCMessageTypeGif && [msg.type intValue] != kWCMessageTypeVideo && [msg.type intValue] != kWCMessageTypeImage) {
                    msg.content = [msg getLastContent];
                    switch ([msg.type intValue]) {
                        case kWCMessageTypeRedPacket: {
                            msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JXredPacket")];;
                        }
                            break;
                        case kWCMessageTypeRedPacketExclusive:
                            msg.content = [NSString stringWithFormat:@"[%@]" ,@"专属红包"];
                            break;
                        case kWCMessageTypeTransfer:{
                            msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                            msg.content = [NSString stringWithFormat:@"[%@%@]", Localized(@"JX_Transfer") ,Localized(@"WaHu_JXMain_WaHuViewController_Message")];
                        }
                            break;
                        case kWCMessageTypeAudioMeetingInvite:
                        case kWCMessageTypeVideoMeetingInvite:
                        case kWCMessageTypeAudioChatCancel:
                        case kWCMessageTypeAudioChatEnd:
                        case kWCMessageTypeVideoChatCancel:
                        case kWCMessageTypeVideoChatEnd: {
                            msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JX_AudioAndVideoCalls")];;
                        }
                            break;
                        case kWCMessageTypeSystemImage1:
                        case kWCMessageTypeSystemImage2: {
                            msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JXGraphic")];
                        }
                            break;
                        case kWCMessageTypeMergeRelay:
                            msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JX_ChatRecord")];
                            break;
                        default:
                            break;
                    }
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                    msg.fileName = @"";
                }
                
                NSString *jsonString = [[msg toDictionary] mj_JSONString];
                [contentArr addObject:jsonString];
            }
            
            WH_JXMessageObject *relayMsg = [[WH_JXMessageObject alloc] init];
            relayMsg.type = [NSNumber numberWithInt:kWCMessageTypeMergeRelay];
            if (self.roomJid.length > 0) {
                relayMsg.objectId = Localized(@"JX_GroupChatLogs");
            }else {
                relayMsg.objectId = [NSString stringWithFormat:Localized(@"JX_GroupChat%@And%@"),self.chatPerson.userNickname, g_myself.userNickname];
            }
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contentArr options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            relayMsg.content = jsonStr;
            
            vc.relayMsgArray = [NSMutableArray arrayWithObject:relayMsg];
            [g_navigation pushViewController:vc animated:YES];
        }
    }else if(actionSheet.wh_tag == 2458) {
        if (index == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:Localized(@"JX_SaveOnlyPictureMessages") delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Save"), nil];
            alert.tag = 2458;
            [alert show];
        }
    }else if(actionSheet.wh_tag == 1111) {
        if(index == 0)
            [g_notify postNotificationName:kCellDeleteMsgNotifaction object:[NSNumber numberWithInt:self.indexNum]];
        if(index == 1)
            [g_notify postNotificationName:kCellResendMsgNotifaction object:[NSNumber numberWithInt:self.indexNum]];
    }else {
        
        if (self.roomJid || [g_config.isOpenCluster integerValue] != 1) {
            if (index == 0) {
                [self onChatAudio:nil];
            }else if(index == 1){
                [self onChatVideo:nil];
            }
        }else {
            if (index == 0) {
                self.isAudioMeeting = YES;
            }else if(index == 1){
                self.isAudioMeeting = NO;
            }
            [g_server WH_userOpenMeetWithToUserId:chatPerson.userId toView:self];
        }
        
    }
    
}


#if TAR_IM
#ifdef Meeting_Version
-(void)onGroupAudioMeeting:(WH_JXMessageObject*)msg{
    NSString* no;
    NSString* s;
    if(msg != nil){
        no = msg.fileName;
        s  = msg.objectId;
    }else{
        no = _audioMeetingNo;
        s  = self.roomJid;
    }
//    if(!no){
//        [g_App showAlert:Localized(@"JXMeeting_numberNULL")];
//        return;
//    }
    self.meetingNo = no;
    self.isAudioMeeting = YES;
    [self onInvite];
//    [g_meeting startAudioMeeting:no roomJid:s];
}

-(void)onGroupVideoMeeting:(WH_JXMessageObject*)msg{
    NSString* no;
    NSString* s;
    if(msg != nil){
        no = msg.fileName;
        s  = msg.objectId;
    }else{
        no = _videoMeetingNo;
        s  = self.roomJid;
    }
//    if(!no){
//        [g_App showAlert:Localized(@"JXMeeting_numberNULL")];
//        return;
//    }
    self.isAudioMeeting = NO;
    self.meetingNo = no;
    [self onInvite];
//    [g_meeting startVideoMeeting:no roomJid:s];
}

-(void)onInvite{

    if (!_room.roomId) {
        return;
    }
    
    NSMutableSet* p = [[NSMutableSet alloc]init];
    
    WH_JXSelectFriends_WHVC* vc = [WH_JXSelectFriends_WHVC alloc];
    vc.isNewRoom = NO;
    vc.isShowMySelf = NO;
    vc.type = JXSelectFriendTypeSelMembers;
    vc.room = _room;
    vc.existSet = p;
    vc.delegate = self;
    vc.didSelect = @selector(meetingAddMember:);
    vc = [vc init];
    //    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)meetingAddMember:(WH_JXSelectFriends_WHVC*)vc{
    int type;
    if (self.isAudioMeeting) {
        type = kWCMessageTypeAudioMeetingInvite;
    }else {
        type = kWCMessageTypeVideoMeetingInvite;
    }
    for(NSNumber* n in vc.set){
        memberData *user;
        if (vc.seekTextField.text.length > 0) {
            user = vc.searchArray[[n intValue] % 1000];
        }else{
            user = [[vc.letterResultArr objectAtIndex:[n intValue] / 1000] objectAtIndex:[n intValue] % 1000];
        }
        NSString* s = [NSString stringWithFormat:@"%ld",user.userId];
        [g_meeting sendMeetingInvite:s toUserName:user.userName roomJid:self.roomJid callId:self.meetingNo type:type];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (g_meeting.isMeeting) {
            return;
        }
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.roomNum = self.roomJid;
        avVC.isAudio = self.isAudioMeeting;
        avVC.isGroup = YES;
        avVC.toUserName = self.chatRoom.roomTitle;
        avVC.view.frame = [UIScreen mainScreen].bounds;
//        [self presentViewController:avVC animated:YES completion:nil];
        [g_window addSubview:avVC.view];

    });

}
#endif
#endif

-(void)onChatAudio:(WH_JXMessageObject*)msg{
#if TAR_IM
#ifdef Meeting_Version
    if([self sendMsgCheck]){
        return;
    }
    
    // 验证XMPP是否在线
    if(g_xmpp.isLogined != login_status_yes){
        [self hideKeyboard:NO];
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
//    if(!g_meeting.connected){
//        [g_meeting WH_showAutoConnect];
//        return;
//    }
    
    [self hideKeyboard:YES];
    if(self.roomJid || msg.objectId){
        [self onGroupAudioMeeting:msg];
    }else{
        AskCallViewController* vc = [AskCallViewController alloc];
        vc.toUserId = chatPerson.userId;
        vc.toUserName = chatPerson.userNickname;
        vc.type = kWCMessageTypeAudioChatAsk;
        vc.meetUrl = self.meetUrl;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:NO];
    }
    
#endif
#endif
}

-(void)onChatVideo:(WH_JXMessageObject*)msg{
#if TAR_IM
#ifdef Meeting_Version
    if([self sendMsgCheck]){
        return;
    }
    
    // 验证XMPP是否在线
    if(g_xmpp.isLogined != login_status_yes){
        [self hideKeyboard:NO];
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
//    if(!g_meeting.connected){
//        [g_meeting WH_showAutoConnect];
//        return;
//    }

    [self hideKeyboard:YES];
    if(self.roomJid || msg.objectId){
        [self onGroupVideoMeeting:msg];
    }else{
        AskCallViewController* vc = [AskCallViewController alloc];
        vc.toUserId = chatPerson.userId;
        vc.toUserName = chatPerson.userNickname;
        vc.type = kWCMessageTypeVideoChatAsk;
        vc.meetUrl = self.meetUrl;
        vc = [vc init];
        //        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:NO];
    }
#endif
#endif
}


-(void)WH_on_WHHeadImage:(UIView*)sender{
    [self hideKeyboard:NO];

    WH_JXMessageObject *msg=[_array objectAtIndex:sender.tag];
    [g_server getUser:msg.fromUserId toView:self];
    msg = nil;
}

#pragma mark - 查看群组信息(入口)
-(void)onMember{
    if (recording) {
        return;
    }
    [self hideKeyboard:YES];
    NSString *s;
    switch ([self.groupStatus intValue]) {
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
        [self hideKeyboard:NO];
        [g_server showMsg:s];
    }else {
//        [_wait start];
        
        WH_JXRoomMember_WHVC* vc = [WH_JXRoomMember_WHVC alloc];
        //            vc.chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:roomdata.roomJid title:roomdata.name isNew:NO];
        //            vc.room       = roomdata;
        if (self.room.roomJid == nil ) {
            self.room.roomJid = self.roomJid;
        }
        vc.wh_roomId = roomId;
        vc.wh_room = self.room;
        vc.delegate = self;
        vc.membersNum = self.groupSize;
        vc.wh_groupNum = self.groupNum;
        vc.noticeArr = self.noticesArry;
        vc = [vc init];
        //        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
//        [g_server getRoom:roomId toView:self];
    }
}

-(void)onQuitRoom:(NSNotification *)notifacation//超时未收到回执
{
    WH_JXRoomObject* p     = (WH_JXRoomObject *)notifacation.object;
    if(p == chatRoom)
        [self actionQuit];
    p = nil;
}

#pragma mark - 控制消息处理
-(void)onReceiveRoomRemind:(NSNotification *)notifacation
{
    WH_JXRoomRemind* p     = (WH_JXRoomRemind *)notifacation.object;

    if([p.objectId isEqualToString:self.roomJid]){
        if([p.type intValue] == kRoomRemind_RoomName){
            self.groupSize = _room.members.count;
            self.title = [NSString stringWithFormat:@"%@(%lu)",p.content,(unsigned long)_room.members.count];
        }
        if([p.type intValue] == kRoomRemind_DisableSay){
            if([p.toUserId isEqualToString:MY_USER_ID])
                _personalBannedTime = [p.content longLongValue];
                _disableSay = [p.content longLongValue];
        }
        if([p.type intValue] == kRoomRemind_DelMember){
            if([p.toUserId isEqualToString:MY_USER_ID])
                self.groupStatus = [NSNumber numberWithInt:1];
//                [self actionQuit];
            
            NSArray * memberArray = [memberData fetchAllMembers:_room.roomId];
            self.groupSize = memberArray.count;
            self.title = [NSString stringWithFormat:@"%@(%lu)", self.chatPerson.userNickname, (unsigned long)memberArray.count];
            
            [g_server getRoom:self.room.roomId toView:self];
            
        }
        if([p.type intValue] == kRoomRemind_NewNotice){
            NSArray *noticeArr = [p.content componentsSeparatedByString:Localized(@"WH_JXMessageObject_AddNewAdv")];
            [self setupNoticeWithContent:[noticeArr lastObject] time:[NSString stringWithFormat:@"%lf",[[NSDate date] timeIntervalSince1970]]];
            //保存最新的群公告,给后一个界面传值会用到self.noticesArry
            NSString * newNoticeStr = [self getContentMsg:[noticeArr lastObject]];
            self.noticesArry = [NSMutableArray arrayWithArray:self.noticesArry];
            [self.noticesArry insertObject:@{@"text" : [NSString stringWithFormat:@"%@", newNoticeStr]} atIndex:0];
        }
        if([p.type intValue] == kRoomRemind_DelRoom){
            if([p.toUserId isEqualToString:MY_USER_ID])
                self.groupStatus = [NSNumber numberWithInt:2];
//                [self actionQuit];
        }
        if([p.type intValue] == kRoomRemind_AddMember){
            if([p.toUserId isEqualToString:MY_USER_ID]){
                self.groupStatus = [NSNumber numberWithInt:0];
                chatRoom.isConnected = YES;
            }
            NSArray * memberArray = [memberData fetchAllMembers:_room.roomId];
            self.groupSize = memberArray.count;
            self.title = [NSString stringWithFormat:@"%@(%ld)", self.chatPerson.userNickname, memberArray.count];
            //                [self actionQuit];
            
            [g_server getRoom:self.room.roomId toView:self];
        }
        if([p.type intValue] == kRoomRemind_NickName){
            
            memberData *data = [[memberData alloc] init];
            data.roomId = roomId;
            data.userNickName = p.content;
            data.userId = [p.toUserId longLongValue];
            [data WH_updateUserNickname];
            
//            for (int i = 0; i < [_array count] ; i++) {
//                WH_JXMessageObject *msg=[_array objectAtIndex:i];
//                if ([msg.fromUserId isEqualToString:p.userId]) {
//                    msg.fromUserName = p.content;
//                }
//            }
            
            [_table reloadData];
            
//            for(int i=0;i<[_room.members count];i++){
//                memberData* m = [_room.members objectAtIndex:i];
//                if(m.userId == [p.toUserId intValue]){
//                    m.userNickName = p.content;
//                    break;
//                }
//                m = nil;
//            }
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
                member.role = [NSNumber numberWithInt:2];
            }else {
                member.role = [NSNumber numberWithInt:3];
            }
            [member updateRole];
            _room = roomdata;
            
            if ([p.toUserId isEqualToString:g_myself.userId]) {
                if ([member.role intValue] == 2) {
                    _isAdmin = YES;
                    
                    _shareMore.enabled = YES;
                    _recordBtnLeft.enabled = YES;
                    _btnFace.enabled = YES;
                    _messageText.userInteractionEnabled = YES;
                    _talkTimeLabel.hidden = YES;
                }else {
                    _isAdmin = NO;
                    if ([self.chatPerson.talkTime longLongValue] > 0) {
                        _talkTimeLabel.hidden = NO;
                        _talkTimeLabel.text = Localized(@"JX_TotalSilence");
                        _shareMore.enabled = NO;
                        _recordBtnLeft.enabled = NO;
                        _btnFace.enabled = NO;
                        _messageText.userInteractionEnabled = NO;
                        _messageText.text = nil;
                        _recordBtn.enabled = NO;
                    }else {
                        
                        _shareMore.enabled = YES;
                        _recordBtnLeft.enabled = YES;
                        _btnFace.enabled = YES;
                        _messageText.userInteractionEnabled = YES;
                        _talkTimeLabel.hidden = YES;
                        _recordBtn.hidden = YES;
                    }
                }
            }
            
            [self refresh:nil loadHistory:NO];
            [_table reloadData];
        }
        
        if([p.type intValue] == kRoomRemind_ShowRead){
            //BOOL b = [self.chatPerson.showRead boolValue];
            self.chatPerson.showRead = [NSNumber numberWithInt:[p.content intValue]];
            //if(b != [self.chatPerson.showRead boolValue])
                [self refresh:nil loadHistory:NO];
        }
        
        if ([p.type integerValue] == kRoomRemind_GroupSignIn) {
            self.chatPerson.isGroupSignIn = [NSNumber numberWithInt:[p.content intValue]];
            
            [self refresh:nil loadHistory:NO];
        }
        
        if([p.type intValue] == kRoomRemind_ShowMember){
            
            self.chatPerson.showMember = [NSNumber numberWithInt:[p.content intValue]];
        
            [self refresh:nil loadHistory:NO];
        }
        if([p.type intValue] == kRoomRemind_allowSendCard){

            self.chatPerson.allowSendCard = [NSNumber numberWithInt:[p.content intValue]];
            self.room.allowSendCard = [p.content boolValue];
            
            [self refresh:nil loadHistory:NO];
            // 禁止私聊，所有名字最后一位改为*，需要刷新界面，保证整个列表即时更新
            [_table reloadData];
        }
        if([p.type intValue] == kRoomRemind_RoomAllowInviteFriend){
            
            self.chatPerson.allowInviteFriend = [NSNumber numberWithInt:[p.content intValue]];

        }
        if([p.type intValue] == kRoomRemind_RoomAllowUploadFile){
            
            self.chatPerson.allowUploadFile = [NSNumber numberWithInt:[p.content intValue]];
    
        }
        if([p.type intValue] == kRoomRemind_RoomAllowConference){
            
            self.chatPerson.allowConference = [NSNumber numberWithInt:[p.content intValue]];
    
        }
        if([p.type intValue] == kRoomRemind_RoomAllowSpeakCourse){
            
            self.chatPerson.allowSpeakCourse = [NSNumber numberWithInt:[p.content intValue]];
            [self refresh:nil loadHistory:NO];
        }
        if([p.type intValue] == kRoomRemind_RoomAllBanned){
            [self hideKeyboard:YES];

            self.chatPerson.talkTime = [NSNumber numberWithInt:[p.content intValue]];
            _disableSay = [self.chatPerson.talkTime longLongValue];
            
            if ([self.chatPerson.talkTime longLongValue] > 0 && !_isAdmin) {
                _talkTimeLabel.text = Localized(@"JX_TotalSilence");
                _shareMore.enabled = NO;
                _recordBtnLeft.enabled = NO;
                _btnFace.enabled = NO;
                _messageText.userInteractionEnabled = NO;
                _talkTimeLabel.hidden = NO;
                _messageText.text = nil;
                _recordBtn.enabled = NO;
            }else {
                _shareMore.enabled = YES;
                _recordBtnLeft.enabled = YES;
                _btnFace.enabled = YES;
                _messageText.userInteractionEnabled = YES;
                _talkTimeLabel.hidden = YES;
                _recordBtn.enabled = YES;
            }
//            [self refresh:nil];
        }
        if([p.type intValue] == kRoomRemind_SetInvisible){
            WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:p.objectId];
            
            NSDictionary * groupDict = [user toDictionary];
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:groupDict];
            NSArray * allMem = [memberData fetchAllMembers:user.roomId];
            roomdata.members = [allMem mutableCopy];
            
            memberData *member = [roomdata getMember:p.toUserId];

            if ([p.content intValue] == 1) {
                _talkTimeLabel.text = Localized(@"JX_ProhibitToSpeak");
                _messageText.userInteractionEnabled = NO;
                _shareMore.enabled = NO;
                _recordBtnLeft.enabled = NO;
                _btnFace.enabled = NO;
                _talkTimeLabel.hidden = NO;
                _messageText.text = nil;
                member.role = [NSNumber numberWithInt:4];
            }else {
                _talkTimeLabel.hidden = YES;
                _shareMore.enabled = YES;
                _recordBtnLeft.enabled = YES;
                _btnFace.enabled = YES;
                _messageText.userInteractionEnabled = YES;
                member.role = [NSNumber numberWithInt:3];
            }
            [member updateRole];
            _room = roomdata;
        }
        if([p.type intValue] == kRoomRemind_RoomTransfer){
            if ([p.fromUserId isEqualToString:MY_USER_ID] || [p.toUserId isEqualToString:MY_USER_ID]) {
                
                if ([p.fromUserId isEqualToString:MY_USER_ID]) {
                    _isAdmin = NO;
                }else {
                    _isAdmin = YES;
                }
                
                [self refresh:nil loadHistory:NO];
            }
        }
        
        if ([p.type intValue] == kRoomRemind_RoomDisable) {
            if ([p.content integerValue] != 1) {
                self.isDisable = YES;
            }else {
                self.isDisable = NO;
            }
        }
        
        if ([p.type intValue] == kRoomRemind_SetRecordTimeOut) {
            if ([p.objectId isEqualToString:self.roomJid]) {
                self.chatPerson.chatRecordTimeOut = p.content;
                [self.chatPerson WH_updateUserChatRecordTimeOut];
            }
        }
        
    }
}

-(BOOL)showDisableSay{
    NSLog(@"_personalBannedTime:%f _disableSay:%f" ,_personalBannedTime ,_disableSay);
//    memberData *data = [self.room getMember:g_myself.userId];
    if([[NSDate date] timeIntervalSince1970] <= _personalBannedTime && !_isAdmin){
        NSString* s = [TimeUtil formatDate:[NSDate dateWithTimeIntervalSince1970:_personalBannedTime] format:@"yyyy-MM-dd HH:mm"];
        
        [g_App showAlert:[NSString stringWithFormat:@"%@%@",s,Localized(@"JXChatVC_GagTime")]];
        
        self.bannedRemind = [NSString stringWithFormat:@"%@%@",s,Localized(@"JXChatVC_GagTime")];
        [self hideKeyboard:NO];
        return YES;
    }
    return NO;
}

-(void)onLocation{
    
    [self hideKeyboard:YES];
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }

    if (g_server.latitude <= 0 && g_server.longitude <= 0) {
        g_server.latitude  = 22.6;
        g_server.longitude = 114.04;
    }
    
    BOOL isShowGoo = [g_myself.isUseGoogleMap intValue] > 0 ? YES : NO;
    if (isShowGoo) {
        _gooMap = [JXGoogleMapVC alloc];
        _gooMap.isSend = YES;
        _gooMap.delegate  = self;
        _gooMap.locationType = JXGooLocationTypeCurrentLocation;
        _gooMap.didSelect = @selector(onSelLocation:);
        
        _gooMap = [_gooMap init];
        [g_navigation pushViewController:_gooMap animated:YES];
    } else {
        _locVC = [JXLocationVC alloc];
        _locVC.isSend = YES;
        _locVC.locationType = JXLocationTypeCurrentLocation;
        _locVC.delegate  = self;
        _locVC.didSelect = @selector(onSelLocation:);
        
        _locVC = [_locVC init];
        
        [g_navigation pushViewController:_locVC animated:YES];
    }

}


-(void)onSelLocation:(JXMapData*)location{
    //上传图片
    if (location.imageUrl) {
        self.isMapMsg = YES;
        self.mapData = location;
        /*直接上传服务器,改为上传obs*/
//        [g_server uploadFile:location.imageUrl validTime:self.chatPerson.chatRecordTimeOut messageId:nil toView:self];
        [OBSHanderTool handleUploadFile:location.imageUrl validTime:self.chatPerson.chatRecordTimeOut messageId:@"" toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                //请求
                NSMutableDictionary* p = [NSMutableDictionary dictionary];
                [p setValue:fileUrl forKey:@"oUrl"];
                [p setValue:fileName forKey:@"oFileName"];
                [p setValue:@"1" forKey:@"status"];
                if (self.isMapMsg) {
                    [self sendMapMsgWithDict:p];
                }else {
                    [self WH_doSendAfterUpload:p];
                }
                p = nil;
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
}


- (void)sendMapMsgWithDict:(NSDictionary *)dict {
    NSString *userId = self.userIds[self.groupMessagesIndex];
    NSString *userName = self.userNames[self.groupMessagesIndex];
    
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.fromUserName = MY_USER_NAME;
    if([self.roomJid length]>0){
        msg.toUserId = self.roomJid;
        msg.isGroup = YES;
        msg.fromUserName = _userNickName;
    }
    else{
        if (self.isGroupMessages) {
            msg.toUserId = userId;
        }else {
            msg.toUserId     = chatPerson.userId;
        }
        msg.isGroup = NO;
    }
    msg.location_x   = [NSNumber numberWithDouble:[self.mapData.latitude  doubleValue]];
    msg.location_y   = [NSNumber numberWithDouble:[self.mapData.longitude doubleValue]];
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeLocation];
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
//    msg.isUpload     = [NSNumber numberWithBool:NO];
    //    msg.content = [NSString stringWithFormat:@"%@",location.subtitle];
    msg.objectId     = [NSString stringWithFormat:@"%@",self.mapData.subtitle];

    msg.isReadDel    = [NSNumber numberWithInt:NO];
    
    //上传图片
    //    if (location.imageUrl) {
    //        [g_server uploadFile:location.imageUrl toView:self];
    //        msg.fileName = location.imageUrl;
    //    }else{
    msg.content = [dict objectForKey:@"oUrl"];
    //    BOOL isShowGoo = [g_myself.isUseGoogleMap intValue] > 0 ? YES : NO;
    //    if (isShowGoo) {
    //        msg.content = [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@,%@&size=640x480&markers=color:blue%7Clabel:S%7C62.107733,-145.541936&zoom=15",location.latitude, location.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    } else {
    //        msg.content = [NSString stringWithFormat:@"http://api.map.baidu.com/staticimage?width=640&height=480&center=%@,%@&zoom=15",location.longitude, location.latitude];
    //    }
    msg.fileName = msg.content;
    [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
//    }
    [msg insert:self.roomJid];
    [self WH_show_WHOneMsg:msg];
    
    if (self.isGroupMessages) {
        self.groupMessagesIndex ++;
        if (self.groupMessagesIndex < self.userIds.count) {
            [self onSelLocation:self.mapData];
        }else if (self.userIds){
            self.groupMessagesIndex = 0;
            [g_App showAlert:Localized(@"JX_SendComplete")];
            return;
        }
        return;
    }
    self.isMapMsg = NO;
}

-(void)onCard{
    
    [self hideKeyboard:YES];
    if (self.roomJid.length > 0 && ![self.chatPerson.allowSendCard boolValue] && !_isAdmin) {
        [g_App showAlert:Localized(@"JX_GroupDisableSendCard")];
        return;
    }
    
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    
    WH_JXSelectFriends_WHVC* vc = [WH_JXSelectFriends_WHVC alloc];
    vc.isNewRoom = NO;
    vc.chatRoom = nil;
    vc.room = nil;
    vc.isShowMySelf = YES;
    vc.delegate = self;
    vc.didSelect = @selector(onAfterAddMember:);
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];

}

-(void)onAfterAddMember:(WH_JXSelectFriends_WHVC*)vc{
    
    NSString *userId = self.userIds[self.groupMessagesIndex];
    NSString *userName = self.userNames[self.groupMessagesIndex];
    
    for(NSNumber* n in vc.set){
        WH_JXUserObject *user;
        if (vc.seekTextField.text.length > 0) {
            user = vc.searchArray[[n intValue] % 1000];
        }else{
            user = [[vc.letterResultArr objectAtIndex:[n intValue] / 1000] objectAtIndex:[n intValue] % 1000];
        }
        
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.content      = user.userNickname;
        msg.objectId     = user.userId;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeCard];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:self.roomJid];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg];
//        [msg release];
        user = nil;
    }
    
    if (self.isGroupMessages) {
        self.groupMessagesIndex ++;
        if (self.groupMessagesIndex < self.userIds.count) {
            [self onAfterAddMember:vc];
        }else if (self.userIds){
            self.groupMessagesIndex = 0;
            [g_App showAlert:Localized(@"JX_SendComplete")];
            return;
        }
        return;
    }
}

-(void)sendFile:(NSString*)file userId:(NSString *)userId
{
//    NSString *userId = self.userIds[self.groupMessagesIndex];
//    NSString *userName = self.userNames[self.groupMessagesIndex];
    
    double fileSize = [self fileSizeAtPath:file];
    if (fileSize > g_config.uploadMaxSize) {
        [g_App showAlert:[NSString stringWithFormat:@"文件超出%dM限制!",g_config.uploadMaxSize]];
        return;
    }
    
    if ([file length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            if (self.isGroupMessages) {
                msg.toUserId = userId;
            }else {
                msg.toUserId     = chatPerson.userId;
            }
            msg.isGroup = NO;
        }
        msg.fileName     = file;
        msg.content      = file;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeFile];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isUpload     = [NSNumber numberWithBool:NO];
        
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:self.roomJid];
        [self WH_show_WHOneMsg:msg];
        
//        if (self.isGroupMessages) {
//            self.groupMessagesIndex ++;
//            if (self.groupMessagesIndex < self.userIds.count) {
//                [self sendFile:file];
//            }else if (self.userIds){
//                self.groupMessagesIndex = 0;
//                return;
//            }
//            return;
//        }
//        [msg release];
        
        /*直接上传服务器,改为上传obs*/
//        [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:msg.messageId toView:self];
        [OBSHanderTool handleUploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:msg.messageId toView:self success:^(int code, NSString * _Nonnull fileUrl, NSString * _Nonnull fileName) {
            if (code == 1) {
                //请求
                NSMutableDictionary* p = [NSMutableDictionary dictionary];
                [p setValue:fileUrl forKey:@"oUrl"];
                [p setValue:fileName forKey:@"oFileName"];
                [p setValue:@"1" forKey:@"status"];
                if (self.isMapMsg) {
                    [self sendMapMsgWithDict:p];
                }else {
                    [self WH_doSendAfterUpload:p];
                }
                p = nil;
            }
        } failed:^(NSError * _Nonnull error) {
            
        }];
    }
}
//发红包
-(void)sendRedPacket:(NSDictionary*)redPacketDict withGreet:(NSString *)greet
{
    [self hideKeyboard:NO];
    if ([redPacketDict[@"id"] length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            msg.toUserId     = chatPerson.userId;
            msg.isGroup = NO;
        }

        msg.content      = greet;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeRedPacket];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
//        msg.isUpload     = [NSNumber numberWithBool:NO];
        msg.fileName = redPacketDict[@"type"];
        msg.objectId = redPacketDict[@"id"];
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:self.roomJid];
        [_orderRedPacketArray addObject:msg];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg];
//        [msg release];
    }
    //获取余额
    [g_server WH_getUserMoenyToView:self];
}

-(void)onSelFile:(NSString*)file{
    if (self.isGroupMessages) {
        for (NSInteger i = 0; i < self.userIds.count; i ++) {
            NSString *userId = self.userIds[i];
            
            //发送文件，file仅仅包含文件在本地的地址
            [self sendFile:file userId:userId];
            //上传文件到服务器
//            [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:self.curMessageId toView:self];
        }
    }else {
        //发送文件，file仅仅包含文件在本地的地址
        [self sendFile:file userId:nil];
        //上传文件到服务器
//        [g_server uploadFile:file validTime:self.chatPerson.chatRecordTimeOut messageId:self.curMessageId toView:self];
    }
}

-(void)sendGift{
    [self hideKeyboard:YES];
    if([self showDisableSay])
        return;
    
    if([self sendMsgCheck]){
        return;
    }
    WH_JXSendRedPacket_WHViewController * sendGiftVC = [[WH_JXSendRedPacket_WHViewController alloc] init];
    sendGiftVC.isRoom = NO;
    sendGiftVC.wh_toUserId = chatPerson.userId;
    sendGiftVC.delegate = self;
//    [g_window addSubview:sendGiftVC.view];
    [g_navigation pushViewController:sendGiftVC animated:YES];
}

- (void)onTransfer {
    
//    //先判断是否绑定了手机号
//    if (g_myself.phone == nil) {
//
//        WH_Register_WHViewController *vc = [[WH_Register_WHViewController alloc] init];
//        vc.isBindPhonePws = YES;
//        [g_navigation pushViewController:vc animated:YES];
//
//        return;
//    }
    
    WH_JXTransfer_WHViewController *transferVC = [WH_JXTransfer_WHViewController alloc];
    transferVC.wh_user = chatPerson;
    transferVC.delegate = self;
    transferVC = [transferVC init];
    [g_navigation pushViewController:transferVC animated:YES];
    
    
}

#pragma mark 群聊发红包
- (void)sendGiftToRoom{
    [self hideKeyboard:YES];
    if([self showDisableSay])
        return;
    
    if([self sendMsgCheck]){
        return;
    }
    WH_JXSendRedPacket_WHViewController * sendGiftVC = [[WH_JXSendRedPacket_WHViewController alloc] init];
    sendGiftVC.isRoom = YES;
    sendGiftVC.delegate = self;
    sendGiftVC.wh_roomJid = self.roomJid;
    sendGiftVC.wh_roomId = self.roomId;
    sendGiftVC.room = self.room;
    NSArray * memberArray = [memberData fetchAllMembers:_room.roomId];
    sendGiftVC.memberCount = [NSString stringWithFormat:@"%lu" ,(unsigned long)memberArray.count];
//    [g_window addSubview:sendGiftVC.view];
    [g_navigation pushViewController:sendGiftVC animated:YES];
}

#pragma mark - 转账delegate
- (void)transferToUser:(NSDictionary *)dict {
    [self hideKeyboard:NO];
    if ([dict[@"id"] length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        msg.toUserId     = chatPerson.userId;
        msg.isGroup = NO;
        
        msg.content      = [NSString stringWithFormat:@"%@",dict[@"money"]];
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeTransfer];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
//        msg.isUpload     = [NSNumber numberWithBool:NO];
        msg.fileName = dict[@"remark"];
        msg.objectId = dict[@"id"];
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:nil];
        
        [g_xmpp sendMessage:msg roomName:nil];//发送消息
        [self WH_show_WHOneMsg:msg];
    }
    //获取余额
    [g_server WH_getUserMoenyToView:self];

}

#pragma mark 发红包代理
-(void)sendRedPacketDelegate:(NSDictionary *)redpacketDict{
    [self hideKeyboard:NO];
    if ([redpacketDict[@"id"] length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            msg.toUserId     = chatPerson.userId;
            msg.isGroup = NO;
        }
        
        msg.content      = redpacketDict[@"greet"];
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeRedPacket];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
//        msg.isUpload     = [NSNumber numberWithBool:NO];
        msg.fileName = redpacketDict[@"type"];
        msg.objectId = redpacketDict[@"id"];
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:self.roomJid];
        [_orderRedPacketArray addObject:msg];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg];
        //        [msg release];
    }
    //获取余额
    [g_server WH_getUserMoenyToView:self];
}

#pragma mark 发指定红包代理
- (void)sendReceiveRedPacketDelegate:(NSDictionary *)redpacketDict {
    [self hideKeyboard:NO];
    if ([redpacketDict[@"id"] length]>0) {
        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg.toUserId = self.roomJid;
            msg.isGroup = YES;
            msg.fromUserName = _userNickName;
        }
        else{
            msg.toUserId     = chatPerson.userId;
            msg.isGroup = NO;
        }
        
        msg.content      = redpacketDict[@"greet"];
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeRedPacketExclusive];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        //        msg.isUpload     = [NSNumber numberWithBool:NO];
        msg.fileName = redpacketDict[@"type"];
        msg.objectId = redpacketDict[@"id"];
        msg.isReadDel    = [NSNumber numberWithInt:NO];
        
        [msg insert:self.roomJid];
        [_orderRedPacketArray addObject:msg];
        [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg];
    }
    //获取余额
    [g_server WH_getUserMoenyToView:self];
}

-(void)onFile{
    [self hideKeyboard:YES];
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    if (self.roomJid.length > 0) {
        
        if (!_isAdmin && ![self.chatPerson.allowUploadFile boolValue]) {
            [g_App showAlert:Localized(@"JX_NotUploadSharedFiles")];
            return;
        }
    }
    WH_JXMyFile* vc = [[WH_JXMyFile alloc]init];
    vc.delegate = self;
    vc.didSelect = @selector(onSelFile:);
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onDidCard:(WH_JXMessageObject*)msg{
//    [g_server getUser:msg.objectId toView:self];
    
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = msg.objectId;
    vc.wh_isJustShow = self.courseId.length > 0;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

#pragma mark------cell头像点击
-(void)WH_onDidHeadImage:(NSNotification*)notification{
    if (recording) {
        return;
    }
    if ([chatPerson.userId rangeOfString:MY_USER_ID].location != NSNotFound) {
        return;
    }
    WH_JXMessageObject *msg = notification.object;
    if ([msg.fromUserId intValue] == 10005) {
        return;
    }
    if([msg.fromUserId isEqualToString:CALL_CENTER_USERID])
        return;
    if (!self.roomJid) {
        //看详情
//        [g_server getUser:msg.fromUserId toView:self];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_userId       = msg.fromUserId;
        vc.wh_isJustShow = self.courseId.length > 0;
        vc.wh_fromAddType = 3;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }else {
        
        memberData *member = [self.room getMember:msg.fromUserId];
        if (_isAdmin || [self.chatPerson.allowSendCard boolValue] || [member.role integerValue] == 1 || [member.role integerValue] == 2) {
            
            NSString *s;
            switch ([self.groupStatus intValue]) {
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
                [self hideKeyboard:NO];
                [g_server showMsg:s];
                return;
            }
            
            WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
            vc.wh_userId       = msg.fromUserId;
            vc.wh_isJustShow = self.courseId.length > 0;
            vc.wh_fromAddType = 3;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
        }else {
            return;
//            [g_App showAlert:Localized(@"JX_GroupNotTalk")];
        }
    }

}

#pragma mark 长按头像事件
-(void)WH_longGesHeadImageNotification:(NSNotification *)notification{
    WH_JXMessageObject *msg = notification.object;
    if (self.roomJid) {
        
        /// 获取当前登录用户
        memberData *loginMember = [self getCurrentLoginMerber];
        /// 当前登录用户是不是管理者
        BOOL isManger = [self isManger:loginMember];
        /// 当前登录用户不是管理者 并且开启了不允许群成员私聊 进入判断
        if (!isManger && !self.room.allowSendCard) {
            if (!ChatViewControllCanAtGroupMember) {//如果不可以@群成员,就不响应长按群头像
                return;
            }
        }
        
        if ([self.chatPerson.talkTime longLongValue] > 0) {
            [GKMessageTool showText:@"禁言状态下不能@群成员！"];
            return;
        }else{
            /// @群成员
            memberData * mem = [self.room getMember:msg.fromUserId];
            if (mem) {
                [self atSelectMemberDelegate:mem];
            }
        }
    }
}

// 重新发送转账消息
- (void)WH_onResend:(WH_JXMessageObject *)msg {
    WH_JXMessageObject *msg1 = [[WH_JXMessageObject alloc]init];
    msg1 = [msg copy];
    msg1.messageId = nil;
    msg1.timeSend     = [NSDate date];
    msg1.fromId = nil;
    msg1.isGroup = NO;
    msg1.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg1.isRead       = [NSNumber numberWithBool:NO];
    msg1.isReadDel    = [NSNumber numberWithInt:NO];
    [msg1 insert:nil];
    [g_xmpp sendMessage:msg1 roomName:nil];//发送消息
    [self WH_show_WHOneMsg:msg1];
}

#pragma mark------转账点击
- (void)WH_onDidTransfer:(NSNotification*)notification {
    if (recording) {
        return;
    }
    [self hideKeyboard:NO];
    WH_JXMessageObject *msg = notification.object;
    WH_JXTransferDeatil_WHVC *detailVC = [WH_JXTransferDeatil_WHVC alloc];
    detailVC.wh_msg = msg;
    detailVC.onResend = @selector(WH_onResend:);
    detailVC.delegate = self;
    detailVC = [detailVC init];
    [g_navigation pushViewController:detailVC animated:YES];
}

#pragma mark------红包点击
-(void)WH_onDidRedPacket:(NSNotification*)notification{
    if (recording) {
        return;
    }
    [self hideKeyboard:NO];
    WH_JXMessageObject *msg = notification.object;
    if (([msg.fileName isEqualToString:@"3"] && [msg.fileSize intValue] != 2) && ![msg.fromUserId isEqualToString:MY_USER_ID]) {
        _messageText.text = msg.content;
        return;
    }
    [_wait start];
    [g_server WH_getRedPacketWithMsg:msg.objectId toView:self];

//    if (([msg.fileName isEqualToString:@"3"] && [msg.fileSize intValue] != 2) && ![msg.fromUserId isEqualToString:MY_USER_ID]) {
//        _messageText.text = msg.content;
//        return;
//    }
//    [_wait start];
//    [g_server getRedPacket:msg.objectId toView:self];
////    [g_server openRedPacket:msg.objectId toView:self];
    
}

- (void)WH_shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

#pragma mark 抢红包
- (void)WH_showRedPacket:(NSDictionary *)dict {
    [_wait stop];
    RedPacketView *redPacketView = [[RedPacketView alloc] initWithRedPacketInfo:dict];
    redPacketView.isGroup = self.room.roomId.length > 0;
    [redPacketView showRedPacket];
    redPacketView.redPocketBlock = ^(NSDictionary * _Nonnull dict, BOOL success) {
        self.redPacketDict = dict;
        if (success) {
            NSString *userId = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"packet"] objectForKey:@"userId"]];
            [self changeMessageRedPacketStatus:dict[@"packet"][@"id"]];
            [self changeMessageArrFileSize:dict[@"packet"][@"id"]];
            [self doEndEdit];
            if (self.roomJid.length > 0) {
                WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
                msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                msg.timeSend = [NSDate date];
                msg.toUserId = self.chatPerson.userId;
                msg.fromUserId = MY_USER_ID;
                msg.objectId = dict[@"packet"][@"id"];
                NSString *userName = [NSString string];
                NSString *overStr = [NSString string];
                if ([userId intValue] == [MY_USER_ID intValue]) {
                    userName = Localized(@"JX_RedPacketOneself");
                    double over = [[NSString stringWithFormat:@"%.2f",[dict[@"packet"][@"over"] floatValue]] doubleValue];
                    if (over < 0.01) {
                        overStr = Localized(@"JX_RedPacketOver");
                    }
                }else {
                    userName = dict[@"packet"][@"userName"];
                }
                NSString *getRedStr = [NSString stringWithFormat:Localized(@"JX_GetRedPacketFromFriend"),userName];
                msg.content = [NSString stringWithFormat:@"%@%@",getRedStr,overStr];
                [msg insert:self.roomJid];
                
                [self WH_show_WHOneMsg:msg];
            }
            [g_server WH_getUserMoenyToView:self];
        }else {//红包被抢完
            WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
            redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:dict];
            redPacketDetailVC.isGroup = self.room.roomId.length > 0;
            [g_navigation pushViewController:redPacketDetailVC animated:YES];
        }
    };
}
#pragma mark-------照片查看
- (void)WH_onDidImage:(NSNotification*)notification{
    if (recording) {
        return;
    }
    if (_array.count <= [notification.object intValue]) {
        //数组访问越界直接return,修复查看聊天记录时点击图片闪退问题
        return;
    }
    self.indexNum = [notification.object intValue];
    [self hideKeyboard:NO];
    WH_JXMessageObject *msg = [_array objectAtIndex:[notification.object intValue]];
    //图片路径数组
    NSMutableArray *imagePathArr = [[NSMutableArray alloc]init];
    NSMutableArray *msgArray = [NSMutableArray array];
    if ([msg.isReadDel boolValue] || [msg.content rangeOfString:@".gif"].location != NSNotFound) {//是阅后即焚 gif图片
        if (msg.content) {
            [msgArray addObject:msg];
            [imagePathArr addObject:msg.content];
        }
    }else{
        //获取所有聊天记录
        NSString* s;
        if([self.roomJid length]>0)
            s = self.roomJid;
        else
            s = chatPerson.userId;
        if (msg.isMySend) {
            _allChatImageArr = [msg fetchImageMessageListWithUser:s];
        }else{
            _allChatImageArr = [msg fetchImageMessageListWithUser:s];
        }
        
        for (int i = 0; i < [_allChatImageArr count]; i++) {
            WH_JXMessageObject * msgP = [_allChatImageArr objectAtIndex:i];
            if (![msgP.isReadDel boolValue] && [msgP.content rangeOfString:@".gif"].location == NSNotFound) {//得到的消息中含有阅后即焚 或 gif图片 的剔除掉
                if (msgP.content) {
                    [msgArray addObject:msgP];
                    NSString* url;
                    if(msgP.isMySend && isFileExist(msgP.fileName))
                        url = [msgP.fileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    else
                        url = [msgP.content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    [imagePathArr addObject:url];
                }
            }
        }
    }
    
    if (self.courseId.length > 0) {
        if (msg.content) {
            [msgArray addObject:msg];
            NSString* url;
            if(msg.isMySend && isFileExist(msg.fileName))
                url = [msg.fileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];//编码;
            else
                url = [msg.content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];//编码;;
            [imagePathArr addObject:url];
        }
    }
    
    //查到当前点击的图片的位置
    for (int i = 0; i < [msgArray count]; i++) {
        WH_JXMessageObject * msgObj = [msgArray objectAtIndex:i];
        if ([msg.messageId isEqualToString:msgObj.messageId]) {
            
            [WH_ImageBrowser_WHViewController show:self delegate:self type:PhotoBroswerVCTypeModal contentArray:msgArray index:i imagesBlock:^NSArray *{
                return imagePathArr;
            }];
            
        }
    }
    imagePathArr = nil;
}

- (void)WH_imageBrowserVCQRCodeAction:(NSString *)stringValue {
    
    NSRange range = [stringValue rangeOfString:@"tigId"];
    if (range.location != NSNotFound) {
        
        NSString * idStr = [stringValue substringFromIndex:range.location + range.length + 1];
        
        if ([stringValue rangeOfString:@"=user"].location != NSNotFound) {
            //                [g_server getUser:idStr toView:self];
            WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
            vc.wh_userId       = idStr;
            vc.wh_fromAddType = 1;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
            
        }else if ([stringValue rangeOfString:@"=group"].location != NSNotFound) {
            
            [g_server getRoom:idStr toView:self];
//            WH_JXRoomMember_WHVC* vc = [WH_JXRoomMember_WHVC alloc];
//            vc.roomId = idStr;
//            vc = [vc init];
//            [g_navigation pushViewController:vc animated:YES];
        }else if ([stringValue rangeOfString:@"=open"].location != NSNotFound) {
            if ([idStr rangeOfString:@"http://"].location != NSNotFound && [idStr rangeOfString:@"https://"].location != NSNotFound) {
                WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
                webVC.url= idStr;
                webVC.isSend = YES;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
            }else{
                [g_App showAlert:Localized(@"JX_TheUrlNotOpen")];
            }
        }
        
    }else {
        NSRange idRange = [stringValue rangeOfString:@"userId"];
        NSRange nameRange = [stringValue rangeOfString:@"userName"];
        
        if ([stringValue hasPrefix:@"http://"] || [stringValue hasPrefix:@"https://"]) {
            WH_webpage_WHVC * webVC = [WH_webpage_WHVC alloc];
            webVC.url= stringValue;
            webVC.isSend = YES;
            webVC = [webVC init];
            [g_navigation.navigationView addSubview:webVC.view];
//            [g_navigation pushViewController:webVC animated:YES];
            
        }else if (stringValue.length == 20 && [self isNumber:stringValue]){
            // 对面付款， 己方收款
            WH_JXInputMoney_WHVC *inputVC = [[WH_JXInputMoney_WHVC alloc] init];
            inputVC.type = JXInputMoneyTypeCollection;
            inputVC.wh_paymentCode = stringValue;
            [g_navigation pushViewController:inputVC animated:YES];
        }else if (idRange.location != NSNotFound && nameRange.location != NSNotFound) {
            // 己方付款， 对面收款
            NSDictionary *dict = [stringValue mj_JSONObject];
            WH_JXInputMoney_WHVC *inputVC = [[WH_JXInputMoney_WHVC alloc] init];
            inputVC.type = JXInputMoneyTypePayment;
            inputVC.wh_userId = [dict objectForKey:@"userId"];
            inputVC.wh_userName = [dict objectForKey:@"userName"];
            if ([dict objectForKey:@"money"]) {
                inputVC.wh_money = [dict objectForKey:@"money"];
            }
            if ([dict objectForKey:@"description"]) {
                inputVC.wh_desStr = [dict objectForKey:@"description"];
            }
            [g_navigation pushViewController:inputVC animated:YES];
        }
    }
}

- (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}


- (void)WH_dismissImageBrowserVC {
    WH_JXImage_WHCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexNum inSection:0]];
    if (!cell.msg.isMySend && cell.msg) {
        //[cell drawIsRead];
    }
}

-(void)readTypeMsgCome:(NSNotification*)notification{//发送方收到已读类型，改变消息图片为已读
    
    // 更新title 在线状态
    if (!self.roomJid && !self.onlinestate) {
        self.onlinestate = YES;
        if (self.isGroupMessages) {
            self.title = Localized(@"JX_GroupHair");
        }else {
            if (self.courseId.length > 0) {
                
            }else {
                if([chatPerson.userId intValue]<10100 && [chatPerson.userId intValue]>=10000) {
                    self.title = chatPerson.userNickname;
                    
                }else {
                    NSString *str = self.onlinestate ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
                    self.title = [NSString stringWithFormat:@"%@",chatPerson.remarkName.length > 0 ? chatPerson.remarkName : chatPerson.userNickname];

                }
            }
            
        }
    }
    
    WH_JXMessageObject * msg = (WH_JXMessageObject *)notification.object;
    if (msg == nil)
        return;
    
    NSString * msgId = msg.content;
    for (int i = 0; i < [_array count]; i ++) {
        WH_JXMessageObject * p = [_array objectAtIndex:i];
        if ([p.messageId isEqualToString:msgId]) {
            if(p.isMySend){
                p.isRead = [NSNumber numberWithInt:1];
                p.readTime = [NSDate date];
                p.isSend = [NSNumber numberWithInt:1];
            }
            p.readPersons = [NSNumber numberWithInt:[p.readPersons intValue] + 1];
            WH_JXBaseChat_WHCell* cell = [self getCell:i];
            if(cell){
                [cell drawIsRead];
                [cell drawIsSend];
            }
            
            
            if ([p.isReadDel boolValue]) {
                
                if (!cell) {
                    
                    [self readDeleWithUser:p];
                    break;
                }
                
//                switch ([p.type intValue]) {
//                    case kWCMessageTypeImage:{
//                        WH_JXImage_WHCell *imageCell = (WH_JXImage_WHCell *)cell;
//                        imageCell.isRemove = YES;
//
//                        [imageCell deleteReadMsg];
//                        //[g_notify postNotificationName:kImageDidTouchEndNotification object:p];
//                    }
//                        break;
//                    case kWCMessageTypeVoice:{
//                        WH_JXAudio_WHCell *audioCell = (WH_JXAudio_WHCell *)cell;
//
//                        [audioCell deleteMsg];
//                    }
//                        
//                        break;
//                    case kWCMessageTypeVideo:{
//                        WH_JXVideo_WHCell *videoCell = (WH_JXVideo_WHCell *)cell;
//                        [videoCell deleteMsg];
//                    }
//                        
//                        break;
//                    case kWCMessageTypeText:{
//                        WH_JXMessage_WHCell *messageCell = (WH_JXMessage_WHCell *)cell;
//                        [messageCell deleteMsg:messageCell.msg];
//                    }
//                        
//                        break;
//                        
//                    default:
//                        break;
//                }
            }
            
            break;
        }
    }
}

-(void)readTypeMsgReceipt:(NSNotification*)notification{//接收方收到已读消息的回执，改变标志避免重复发
    WH_JXMessageObject * msg = (WH_JXMessageObject *)notification.object;
    if (msg == nil)
        return;
    
    for (int i = 0; i < [_array count]; i ++) {
        WH_JXMessageObject * p = [_array objectAtIndex:i];
        if ([p.messageId isEqualToString:msg.content]){
            if(msg.isMySend){
                p.isRead = [NSNumber numberWithInt:1];
                p.isSend = [NSNumber numberWithInt:1];
            }
            p.readPersons = [NSNumber numberWithInt:[p.readPersons intValue] + 1];
            WH_JXBaseChat_WHCell* cell = [self getCell:i];
            if(cell){
                if ([cell respondsToSelector:@selector(drawIsSend)]) {
                    [cell drawIsSend];
                }
                if ([cell respondsToSelector:@selector(drawIsRead)]) {
                    [cell drawIsRead];
                }
            }
            break;
        }
    }
}

//获取口令红包聊天记录
-(NSMutableArray*)fetchRedPacketListWithType:(int)rpType
{
    NSString* myUserId = MY_USER_ID;
    if([myUserId length]<=0)
        return nil;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    NSString *s;
    if([self.roomJid length]>0)
        s = self.roomJid;
    else
        s = chatPerson.userId;
    
    NSString *queryString=[NSString stringWithFormat:@"select * from msg_%@ where type=28 and fileName=3",s];
    
    FMResultSet *rs=[db executeQuery:queryString];
    while ([rs next]) {
        WH_JXMessageObject *p=[[WH_JXMessageObject alloc]init];
        [p fromRs:rs];
        [messageList addObject:p];
//        [p release];
    }
    [rs close];
    db = nil;

    if([messageList count]==0){
//        [messageList release];
        messageList = nil;
    }
    return  messageList;
}

//改变红包对应消息的不可获取
-(void)changeMessageRedPacketStatus:(NSString*)redPacketId{
    NSString* myUserId = MY_USER_ID;
    if([myUserId length]<=0){
        return;
    }
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    NSString * sufStr = self.roomJid ? self.roomJid : self.chatPerson.userId;
    
    NSString * sql = [NSString stringWithFormat:@"update msg_%@ set fileSize=2 where objectId=?",sufStr];
    
    [db executeUpdate:sql,redPacketId];

    db = nil;
}
//改变红包消息不可获取
- (void)changeMessageArrFileSize:(NSString *)redPackerId{
    for (NSInteger i = _array.count - 1; i >= 0; i --) {
        WH_JXMessageObject *msg = _array[i];
        if ([msg.objectId isEqualToString:redPackerId]) {
            msg.fileSize = [NSNumber numberWithInt:2];
            [self.tableView WH_reloadRow:(int)i section:0];
        }
    }
    for (WH_JXMessageObject * msg in _orderRedPacketArray) {
        if ([msg.objectId isEqualToString:redPackerId]) {
            msg.fileSize = [NSNumber numberWithInt:2];
        }
    }
}

-(WH_JXBaseChat_WHCell*)getCell:(long)index{
    if(index<0 && index >= [_array count])
        return nil;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return (WH_JXBaseChat_WHCell*)[_table cellForRowAtIndexPath:indexPath];
}


#pragma mark------自动向下播放语音
-(void)audioPlayEnd:(NSNotification*)notification{
    WH_JXAudio_WHCell* cell = (WH_JXAudio_WHCell*)notification.object;
    WH_JXMessageObject *msg=cell.msg;
    _lastIndex = cell.indexNum;
    //msg.isReadDel = [NSNumber numberWithBool:YES];
    if ([msg.isReadDel boolValue]) {
        return;
    }
    if(_lastIndex >= _array.count)
        return;
    
    while (_lastIndex<_array.count) {
        _lastIndex++;
        if(_lastIndex>=_array.count)
            break;
        msg = [_array objectAtIndex:_lastIndex];
        if([msg.type intValue] == kWCMessageTypeVoice && ![msg.isRead boolValue] && !msg.isMySend){
            [cell.audioPlayer wh_stop];
            WH_JXAudio_WHCell* nextCell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastIndex inSection:0]];
            [nextCell.audioPlayer wh_switch];
            break;
        }
    }
    
    msg = nil;
    cell = nil;
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    return bCanRecord;
}

- (void)readDeleWithUser:(WH_JXMessageObject *)p{
    self.readDelNum ++;
    if ([p.fromUserId isEqualToString:MY_USER_ID]) {
        for (NSInteger i = 0; i < _array.count; i ++) {
            WH_JXMessageObject *msg = _array[i];
            if ([p.messageId isEqualToString:msg.messageId]) {
                if ([msg.isRead boolValue]) {
                    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
                    msg.content = Localized(@"JX_OtherLookedYourReadingMsg");
                    [_table reloadData];
                }else {
                    [self deleteMsg:p];
                }
                break;
            }
        }
    }else {
        [self deleteMsg:p];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.readDelNum > 5) {
            self.readDelNum = 0;
            [self.tableView reloadData];
            NSLog(@"readDelNum ----- %d", self.readDelNum);
        }
    });
}

//#pragma mark--------登录状态改变
//-(void)onLoginChanged:(NSNotification *)notifacation{
//    [_wait stop];
//    if (_isShowLoginChange) {
//        switch ([JXXMPP sharedInstance].isLogined){
//            case login_status_ing:
//                // 连接失败
//                [JXMyTools showTipView:Localized(@"JX_ConnectFailed")];
//                break;
//            case login_status_no:
//                // 连接失败
//                [JXMyTools showTipView:Localized(@"JX_ConnectFailed")];
//                break;
//            case login_status_yes:
//                // 连接成功
//                [JXMyTools showTipView:Localized(@"JX_ConnectSuccessfully")];
//                break;
//        }
//    }
//}

- (void)onBackForRecordBtnLeft {
    self.objToMsg = nil;
//    [_recordBtnLeft setBackgroundImage:[UIImage imageNamed:@"WH_input_ptt_normal"] forState:UIControlStateNormal];
//    [_recordBtnLeft setBackgroundImage:[UIImage imageNamed:@"WH_input_keyboard_normal"] forState:UIControlStateSelected];
    [_recordBtnLeft removeTarget:self action:@selector(onBackForRecordBtnLeft) forControlEvents:UIControlEventTouchUpInside];
    [_recordBtnLeft addTarget:self action:@selector(recordSwitch:) forControlEvents:UIControlEventTouchUpInside];
    _messageText.textColor = [UIColor blackColor];
    _messageText.text = nil;
    _hisReplyMsg = nil;
    [self textViewDidChange:_messageText];
    
}

- (void)getTextViewWatermark {
    if (_hisReplyMsg.length <= 0) {
        return;
    }
    [_messageText becomeFirstResponder];
    // 长按回复 显示水印
    if (![self changeEmjoyText:_hisReplyMsg textColor:[UIColor lightGrayColor]]) {
        [_messageText.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:_hisReplyMsg         attributes:@{NSFontAttributeName:sysFontWithSize(18),NSForegroundColorAttributeName:[UIColor lightGrayColor]}] atIndex:_messageText.selectedRange.location];
    }
    _messageText.textColor = [UIColor lightGrayColor];
    _messageText.selectedRange = NSMakeRange(0, 0);
    [self setTableFooterFrame:_messageText];
}

#pragma mark 长按回复
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell replyIndexNum:(int)indexNum {
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }else if([self showDisableSay]) {
        return;
    } else{
        WH_JXMessageObject *msg = _array[indexNum];
        if (_recordBtnLeft.selected) {
            [self recordSwitch:_recordBtnLeft];
        }
        [_messageText becomeFirstResponder];
        [_recordBtnLeft setBackgroundImage:[UIImage imageNamed:@"chat_back_reply"] forState:UIControlStateNormal];
        [_recordBtnLeft removeTarget:self action:@selector(recordSwitch:) forControlEvents:UIControlEventTouchUpInside];
        [_recordBtnLeft addTarget:self action:@selector(onBackForRecordBtnLeft) forControlEvents:UIControlEventTouchUpInside];
        _hisReplyMsg = [NSString stringWithFormat:@"%@%@:%@",Localized(@"JX_Reply"),msg.fromUserName,[msg getTypeName]];
        // 显示水印
        [self getTextViewWatermark];
        // 转成json数据
        NSString *jsonString = [[msg toDictionary] mj_JSONString];
        self.objToMsg = jsonString;
    }
    
}

#pragma mark 长按转发
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell RelayIndexNum:(int)indexNum {
    [self hideKeyboard:NO];
    
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言状态下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }else if ([self showDisableSay]) {
        return;
    } else{
        WH_JXMessageObject *msg = _array[indexNum];
        WH_JXRelay_WHVC *vc = [[WH_JXRelay_WHVC alloc] init];
        NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
        //    vc.msg = msg;
        vc.relayMsgArray = array;
        //    [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }
    
}

- (void)setRelayMsgArray:(NSMutableArray *)relayMsgArray {
    _relayMsgArray = relayMsgArray;
    self.friendStatus = friend_status_friend;
    if (!self.roomJid) {
        for (WH_JXMessageObject *msg in relayMsgArray) {
            if ([msg.type intValue] == kWCMessageTypeRedPacket) {
                msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JX_RED")];
            }
            if ([msg.type intValue] == kWCMessageTypeRedPacketExclusive) {
                msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                msg.content = [NSString stringWithFormat:@"[%@]", @"专属红包"];
            }
            if ([msg.type intValue] == kWCMessageTypeTransfer) {
                msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                msg.content = [NSString stringWithFormat:@"[%@%@]", Localized(@"JX_Transfer") ,Localized(@"WaHu_JXMain_WaHuViewController_Message")];
            }
            
            if ([msg.type intValue] == kWCMessageTypeAudioMeetingInvite || [msg.type intValue] == kWCMessageTypeVideoMeetingInvite || [msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeAudioChatEnd || [msg.type intValue] == kWCMessageTypeVideoChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatEnd) {
                
                msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
                msg.content = [NSString stringWithFormat:@"[%@]", Localized(@"JX_AudioAndVideoCalls")];
            }
            [self relay:msg];
        }
//        [self relay];
    }
}

//- (void)setRelayMsg:(WH_JXMessageObject *)relayMsg {
//    _relayMsg = relayMsg;
//    self.friendStatus = friend_status_friend;
//    if (!self.roomJid) {
//        [self relay];
//    }
//}

- (void) relay:(WH_JXMessageObject *)msg{
    if([self showDisableSay])
        return;
    if([self sendMsgCheck]){
        return;
    }
    
    if (msg.content.length > 0) {
        WH_JXMessageObject *msg1 = [[WH_JXMessageObject alloc]init];
        msg1 = [msg copy];
        msg1.messageId = nil;
        msg1.timeSend     = [NSDate date];
        msg1.fromId = nil;
        msg1.fromUserId   = MY_USER_ID;
        if([self.roomJid length]>0){
            msg1.toUserId = self.roomJid;
            msg1.isGroup = YES;
            msg1.fromUserName = _userNickName;
        }
        else{
            msg1.toUserId     = chatPerson.userId;
            msg1.isGroup = NO;
        }
        //        msg.content      = relayMsg.content;
        //        msg.type         = relayMsg.type;
        msg1.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg1.isRead       = [NSNumber numberWithBool:NO];
        msg1.isReadDel    = [NSNumber numberWithInt:NO];
        //发往哪里
        [msg1 insert:self.roomJid];
        [g_xmpp sendMessage:msg1 roomName:self.roomJid];//发送消息
        [self WH_show_WHOneMsg:msg1];
        if (_table.contentSize.height > (JX_SCREEN_HEIGHT + self.deltaHeight - self.wh_heightFooter - 64 - 40 - 20)) {
            if (self.deltaY >= 0) {
                
            }else {
                
                if (self.wh_tableFooter.frame.origin.y != JX_SCREEN_HEIGHT-self.wh_heightFooter) {
                    [CATransaction begin];
                    [UIView animateWithDuration:0.1f animations:^{
                        //            self.wh_tableFooter.frame = CGRectMake(0, self.view.frame.size.height+deltaY-self.wh_heightFooter, JX_SCREEN_WIDTH, self.wh_heightFooter);
                        [_table setFrame:CGRectMake(0, 0+_noticeHeight, _table.frame.size.width, self.view.frame.size.height+self.deltaHeight-self.wh_heightFooter-_noticeHeight)];
                        //                [_table WH_gotoLastRow:NO];
                    } completion:^(BOOL finished) {
                    }];
                    [CATransaction commit];
                }
                
            }
            
        }
    }
    
    [_messageText setText:nil];
    
    
    if (self.isShare && (self.shareSchemes || self.shareUrl)) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
            self.shareView.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
            [g_window addSubview:self.shareView];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH - 100, 220)];
            view.backgroundColor = [UIColor whiteColor];
            view.center = CGPointMake(self.shareView.frame.size.width / 2, self.shareView.frame.size.height / 2);
            view.layer.cornerRadius = 3.0;
            view.layer.masksToBounds = YES;
            [self.shareView addSubview:view];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 50, 50)];
            imageView.image = [UIImage imageNamed:@"appLogo"];
            imageView.center = CGPointMake(view.frame.size.width / 2, imageView.center.y);
            [view addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, view.frame.size.width, 30)];
            label.font = [UIFont systemFontOfSize:18];
            label.text = Localized(@"JX_Sended");
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 90, view.frame.size.width, .5)];
            line.backgroundColor = HEXCOLOR(0xdcdcdc);
            [view addSubview:line];
            
            UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, line.frame.origin.y, line.frame.size.width, 45)];
            [btn1 setTitle:Localized(@"JX_Return") forState:UIControlStateNormal];
            [btn1 setTitleColor:THEMECOLOR forState:UIControlStateNormal];
            [btn1 addTarget:self action:@selector(shareBackBtnAction) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn1];
            
            line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 45, view.frame.size.width, .5)];
            line.backgroundColor = HEXCOLOR(0xdcdcdc);
            [view addSubview:line];
            
            UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, line.frame.origin.y, line.frame.size.width, 45)];
            [btn2 setTitle:[NSString stringWithFormat:@"%@%@",Localized(@"JX_ToStayIn"),APP_NAME] forState:UIControlStateNormal];
            [btn2 setTitleColor:THEMECOLOR forState:UIControlStateNormal];
            [btn2 addTarget:self action:@selector(shareKeepBtnAction) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn2];
        });
    }
    
}

- (void)shareBackBtnAction {
    NSString *str = [NSString stringWithFormat:@"%@://type=%@",self.shareSchemes,@"Share"];
    NSString *urlString = self.shareUrl.absoluteString.stringByRemovingPercentEncoding;
    if ([urlString containsString:@"BLN"]) {
        NSString *identifer = [NSString stringWithFormat:@"%@/", SDKShareIdentifier];
        NSRange range = [self.shareUrl.absoluteString rangeOfString:identifer];
        if (range.location != NSNotFound) {
            NSString *contentString = [urlString substringFromIndex:(range.location + range.length)];
            NSDictionary *infoDic = [contentString.stringByRemovingPercentEncoding mj_JSONObject];
            NSDictionary *openDic = @{@"type":infoDic[@"type"], @"result":@(YES), @"info":@{@"resultMsg":@"分享成功"}};
            str = [NSString stringWithFormat:@"%@://%@/%@",self.shareUrl.host, BackToSDKIdentifier,[openDic mj_JSONString]];
        }
    }

    NSURL *backUrl = [NSURL URLWithString:[str  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    if ([[UIApplication sharedApplication] canOpenURL:backUrl]) {
        [[UIApplication sharedApplication] openURL:backUrl options:nil completionHandler:^(BOOL success) {
        
        }];
    }else {
        NSLog(@"无效的链接");
    }
    
    
    self.shareView.hidden = YES;
    [self.shareView removeFromSuperview];
}

- (void)shareKeepBtnAction {
    self.shareView.hidden = YES;
    [self.shareView removeFromSuperview];
}

- (BOOL)isNoAllowedOpearitionOnJinYanStatus
{
    if ([self.chatPerson.talkTime longLongValue] > 0) {
        if (self.roomJid) {
            WH_JXUserObject *roomObj = [[WH_JXUserObject sharedUserInstance] getUserById:self.roomJid];
            NSArray *members = [memberData fetchAllMembers:roomObj.roomId];
            
            /// 拿到当前用户 在群组里扮演的角色
            memberData *currentMember = nil;
            WH_JXUserObject *currentUser = g_myself;
            for (memberData *member in members) {
                if (member.userId == [currentUser.userId longLongValue]) {
                    currentMember = member;
                }
            }
            
            /// 是不是群主 或者 管理员 yes:是 no:不是
            BOOL isManger = [currentMember.role intValue] == 1 || [currentMember.role intValue] == 2;
            //禁言状态并且不是群主和管理员才不允许操作
            if (!isManger) {
                return YES;
            }
        }
    }
    
    
    return NO;
}

#pragma mark 长按删除
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell deleteIndexNum:(int)indexNum {
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }else if ([self showDisableSay]) {
        return;
    }else{
        WH_JXMessageObject *msg = _array[indexNum];
        NSString* s;
        if([self.roomJid length]>0)
            s = self.roomJid;
        else
            s = chatPerson.userId;
        
        
        if (indexNum == _array.count - 1) {
            WH_JXMessageObject *newLastMsg;
            if (indexNum == 0) {
                newLastMsg = [_array firstObject];
            }else {
                newLastMsg = _array[indexNum - 1];
            }
            self.lastMsg.content = newLastMsg.content;
            [newLastMsg updateLastSend:UpdateLastSendType_None];
        }
        
        //删除本地聊天记录
        [_array removeObjectAtIndex:indexNum];
        [msg delete];
        
        //    [_table deleteRow:indexNum section:0];
        [_table reloadData];
        if (self.courseId.length > 0) {
            //        NSDictionary *dict = self.courseArray[indexNum];
            [g_server WH_userCourseUpdateWithCourseId:self.courseId MessageIds:nil CourseName:nil CourseMessageId:msg.messageId toView:self];
        }else {
            int type = 1;
            if (self.roomJid) {
                type = 2;
            }
            self.withdrawIndex = -1;
            [g_server WH_tigaseDeleteMsgWithMsgId:msg.messageId type:type deleteType:1 roomJid:self.roomJid toView:self];
        }
    }
}

#pragma mark 长按撤回
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell withdrawIndexNum:(int)indexNum {
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }
    
    if ([self showDisableSay]) {
        return;
    }
    if ([self sendMsgCheck]) {
        return;
    }
    
    WH_JXMessageObject *msg = _array[indexNum];
    self.withdrawIndex = indexNum;
    int type = 1;
    if (self.roomJid) {
        type = 2;
    }
    [g_server WH_tigaseDeleteMsgWithMsgId:msg.messageId type:type deleteType:2 roomJid:self.roomJid toView:self];
}

#pragma mark 长按收藏
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell favoritIndexNum:(int)indexNum type:(CollectType)collectType{
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }
    if([self showDisableSay]){
        return;
    }
    
    WH_JXMessageObject *msg = _array[indexNum];
    NSMutableArray *emoji = [[NSMutableArray alloc] init];
    if (collectType == CollectTypeEmoji) {
        for (NSInteger i = 0; i < g_myself.favorites.count; i ++) {
            NSDictionary *dict = g_myself.favorites[i];
            NSString *url = dict[@"url"];
            
            if ([msg.content isEqualToString:url]) {
                
                [JXMyTools showTipView:Localized(@"JX_ExpressionAdded")];
                return;
            }
        }
    }
    NSString *type = [NSString stringWithFormat:@"%ld",collectType];
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    if (collectType != CollectTypeEmoji) {
        [dataDict setValue:msg.messageId forKey:@"msgId"];
    }
    [dataDict setValue:msg.content forKey:@"msg"];
    [dataDict setValue:type forKey:@"type"];
    [dataDict setValue:self.roomJid forKey:@"roomJid"];
    [dataDict setValue:@0 forKey:@"collectType"];
    [dataDict setValue:msg.content forKey:@"url"];

    [emoji addObject:dataDict];
//    NSString * jsonString = [[SBJsonWriter new] stringWithObject:[msg toDictionary]];
//    [g_server addFavoriteWithContent:jsonString type:collectType toView:self];
    [g_server WH_addFavoriteWithEmoji:emoji toView:self];
//    [g_server userEmojiAddWithUrl:msg.content toView:self];

}

#pragma mark 多选
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell selectMoreIndexNum:(int)indexNum {
    [self hideKeyboard:NO];
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }
    
    if ([self showDisableSay]) {
        return;
    }
    self.isSelectMore = YES;
    self.selectMoreView.hidden = NO;
    [self.wh_gotoBackBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.wh_gotoBackBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [self.tableView reloadData];
}

#pragma mark 多选选择
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell checkBoxSelectIndexNum:(int)indexNum isSelect:(BOOL)isSelect {
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }
    
    if ([self showDisableSay]) {
        return;
    }
    
    WH_JXMessageObject *msg = _array[indexNum];
    
    if ([msg.isReadDel boolValue]) {
        chatCell.checkBox.selected = NO;
        [g_App showAlert:Localized(@"JX_MessageBurningNo")];
        return;
    }
    
    if (isSelect) {
        [_selectMoreArr addObject:_array[indexNum]];
    }else {
        [_selectMoreArr removeObject:_array[indexNum]];
    }
}

#pragma mark 长按开始录制
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell startRecordIndexNum:(int)indexNum {
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }
    
    if ([self showDisableSay]) {
        return;
    }
    
    self.isRecording = YES;
    self.recordStarNum = indexNum;
    self.title = Localized(@"JX_StopRecording");
}

#pragma mark 长按结束录制
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell stopRecordIndexNum:(int)indexNum {
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }
    
    if ([self showDisableSay]) {
        return;
    }
    
    for (NSInteger i = self.recordStarNum; i<= indexNum; i ++) {
        if (i >= _array.count) {
            return;
        }
        WH_JXMessageObject *msg = _array[i];
        if([msg isVisible] && [msg.type intValue]!=kWCMessageTypeIsRead && [msg.fromUserId isEqualToString:MY_USER_ID] && [msg.isReadDel intValue] != 1)
            if (msg.messageId) {
                [_recordArray addObject:msg.messageId];
            }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localized(@"JX_InputCourseName") message:nil delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    
    NSString *str = self.onlinestate ? Localized(@"JX_OnLine") : Localized(@"JX_OffLine");
    if (self.roomJid || ([chatPerson.userId intValue]<10100 && [chatPerson.userId intValue]>=10000)) {
        self.title = chatPerson.userNickname;
    }else {
        
        self.title = [NSString stringWithFormat:@"%@",chatPerson.remarkName.length > 0 ? chatPerson.remarkName : chatPerson.userNickname];
    }
    self.isRecording = NO;
    self.recordStarNum = 0;
    
    [self hideKeyboard:NO];
}
#pragma mark 消息重发
- (void)chatCell:(WH_JXBaseChat_WHCell *)chatCell resendIndexNum:(int)indexNum {
    if ([self isNoAllowedOpearitionOnJinYanStatus]) {
        //禁言情况下
        [GKMessageTool showText:@"禁言状态下不能进行此操作！"];
        return;
    }
    
    if ([self showDisableSay]) {
        return;
    }
    
    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_Delete"),Localized(@"WH_JXBaseChat_WHCell_SendAngin")]];
    actionVC.wh_tag = 1111;
    actionVC.delegate = self;
    self.indexNum = indexNum;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (BOOL)getRecording {
    return self.isRecording;
}
- (NSInteger)getRecordStarNum {
    return self.recordStarNum;
}

// 发送课程
- (void)sendCourseAction {
    
    if (_array.count <= 0) {
        [JXMyTools showTipView:Localized(@"JX_ThisCourseEmpty")];
        return;
    }

    if (commonService.wh_courseTimer) {
        [JXMyTools showTipView:Localized(@"JX_SendingPleaseWait")];
        return;
    }
    WH_JXRelay_WHVC *vc = [[WH_JXRelay_WHVC alloc] init];
    vc.isCourse = YES;
    vc.relayDelegate = self;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)sendCourse:(NSTimer *) timer{
    
    WH_JXMsgAndUserObject *obj = timer.userInfo;
    BOOL isRoom;
    if ([obj.user.roomFlag intValue] > 0  || obj.user.roomId.length > 0) {
        isRoom = YES;
    }else {
        isRoom = NO;
    }
    
    self.sendIndex ++;
//    [_chatWait start:[NSString stringWithFormat:@"正在发送：%d/%ld",self.sendIndex,_array.count] inView:g_window];
    [_chatWait setCaption:[NSString stringWithFormat:@"%@：%d/%ld",Localized(@"JX_SendNow"),self.sendIndex,_array.count]];
    [_chatWait update];
    
    WH_JXMessageObject *msg= _array[self.sendIndex - 1];
    msg.messageId = nil;
    msg.timeSend     = [NSDate date];
    msg.fromId = nil;
    msg.fromUserId   = MY_USER_ID;
    if(isRoom){
        msg.toUserId = obj.user.userId;
        msg.isGroup = YES;
        msg.fromUserName = g_myself.userNickname;
    }
    else{
        msg.toUserId     = obj.user.userId;
        msg.isGroup = NO;
    }
    //        msg.content      = relayMsg.content;
    //        msg.type         = relayMsg.type;
    msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg.isRead       = [NSNumber numberWithBool:NO];
    msg.isReadDel    = [NSNumber numberWithInt:NO];
    //发往哪里
    if (isRoom) {
        [msg insert:obj.user.userId];
        [g_xmpp sendMessage:msg roomName:obj.user.userId];//发送消息
    }else {
        [msg insert:nil];
        [g_xmpp sendMessage:msg roomName:nil];//发送消息
    }
    
    if (_array.count == self.sendIndex) {
        [_chatWait stop];
        [_timer invalidate];
        _timer = nil;
        [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
    }
}

- (void)relay:(WH_JXRelay_WHVC *)relayVC MsgAndUserObject:(WH_JXMsgAndUserObject *)obj {
    
//    [g_subWindow addSubview:_suspensionBtn];
//    g_subWindow.hidden = YES;
//    _chatWait.view.frame = CGRectMake(0, 0, 50, 50);
//    [_chatWait start:[NSString stringWithFormat:@"%@：1/%ld",Localized(@"JX_SendNow"),_array.count] inView:g_subWindow];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [commonService WH_sendCourse:obj Array:_array];
    });
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendCourse:) userInfo:obj repeats:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2457) {
        
        if (buttonIndex == 1) {
            
//            NSMutableString *msgIds = [NSMutableString string];
//            NSMutableString *types = [NSMutableString string];
            NSMutableArray *emoji = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < self.selectMoreArr.count; i ++) {
                WH_JXMessageObject *msg = self.selectMoreArr[i];
                if ([msg.type intValue] == kWCMessageTypeText || [msg.type intValue] == kWCMessageTypeImage || [msg.type intValue] == kWCMessageTypeVoice || [msg.type intValue] == kWCMessageTypeVideo || [msg.type intValue] == kWCMessageTypeFile) {
                    
                    CollectType collectType = CollectTypeDefult;
                    if ([msg.type intValue] == kWCMessageTypeImage) {
                        collectType = CollectTypeImage;
                    }else if ([msg.type intValue] == kWCMessageTypeVideo) {
                        collectType = CollectTypeVideo;
                    }else if ([msg.type intValue] == kWCMessageTypeFile) {
                        collectType = CollectTypeFile;
                    }else if ([msg.type intValue] == kWCMessageTypeVoice) {
                        collectType = CollectTypeVoice;
                    }else if ([msg.type intValue] == kWCMessageTypeText) {
                        collectType = CollectTypeText;
                    }else {
                        
                    }
                    if (collectType == CollectTypeDefult) {
                        return;
                    }
//                    NSDictionary *dict = g_myself.favorites[i];
//                    NSString *url = dict[@"url"];
//                    if ([msg.content isEqualToString:url]) {
//                        continue;
//                    }

                    NSString *type = [NSString stringWithFormat:@"%ld",collectType];
                    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
                    [dataDict setValue:msg.messageId forKey:@"msgId"];
                    [dataDict setValue:msg.content forKey:@"msg"];
                    [dataDict setValue:type forKey:@"type"];
                    [dataDict setValue:self.roomJid forKey:@"roomJid"];
                    [dataDict setValue:@0 forKey:@"collectType"];

                    [emoji addObject:dataDict];
                    
//                    if (msgIds.length <= 0) {
//                        [msgIds appendString:msg.messageId];
//                        [types appendString:[NSString stringWithFormat:@"%ld",collectType]];
//                    }else {
//                        [msgIds appendFormat:@",%@", msg.messageId];
//                        [types appendFormat:@",%@", [NSString stringWithFormat:@"%ld",collectType]];
//                    }
                    
                }
            }
            
            [g_server WH_addFavoriteWithEmoji:emoji toView:self];
        }
        
    }else if (alertView.tag == 2458) {
        
        for (NSInteger i = 0; i < self.selectMoreArr.count; i ++) {
            WH_JXMessageObject *msg = self.selectMoreArr[i];
            if ([msg.type intValue] == kWCMessageTypeImage) {
                UIImageView *imageView = [[UIImageView alloc] init];
                NSURL* url;
                if(msg.isMySend && isFileExist(msg.fileName))
                    url = [NSURL fileURLWithPath:msg.fileName];
                else
                    url = [NSURL URLWithString:msg.content];
                [imageView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                    if (!error) {
                        [self saveImageToPhotos:imageView.image];
                    }
                }];
            }
            
            if ([msg.type integerValue] == kWCMessageTypeVideo) {
                
                if ([msg.content rangeOfString:@"http"].location != NSNotFound) {
                    [self playerDownload:msg.content];
                }else {
                    [self saveVideo:msg.content];
                }
                
            }
        }
        
        if (self.isSelectMore) {
            [self actionQuit];
        }
        
    }else {
        if (buttonIndex == 1) {
            UITextField *tf = [alertView textFieldAtIndex:0];
            if (tf.text.length <= 0) {
                [g_App showAlert:Localized(@"JX_InputCourseName")];
                return;
            }
            _recordName = tf.text;
            NSMutableString *recordStr = [NSMutableString string];
            for (NSInteger i = 0; i < _recordArray.count; i ++) {
                NSString *str = _recordArray[i];
                if (i == _recordArray.count - 1) {
                    [recordStr appendString:str];
                }else {
                    [recordStr appendFormat:@"%@,",str];
                }
            }
            
            [g_server WH_userCourseAddWithMessageIds:recordStr CourseName:_recordName RoomJid:self.roomJid toView:self];
        }
    }
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}


// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{

    if (!error) {
        
        [JXMyTools showTipView:Localized(@"JX_SaveSuessed")];
    }else {
        [JXMyTools showTipView:@"保存失败"];
    }
}

//-----下载视频--
- (void)playerDownload:(NSString *)url{
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString  *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"jaibaili.mp4"];
    NSURL *urlNew = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlNew];
    NSURLSessionDownloadTask *task =
    [manager downloadTaskWithRequest:request
                            progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                return [NSURL fileURLWithPath:fullPath];
                            }
                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                       [self saveVideo:fullPath];
                   }];
    [task resume];
    
}


// 发送正在输入
- (void) sendEntering {
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;

    msg.toUserId     = chatPerson.userId;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeRelay];
    [g_xmpp sendMessage:msg roomName:self.roomJid];//发送消息
}

// 群更改昵称
- (void)setNickName:(NSString *)nickName {
    _userNickName = nickName.length > 0 ? nickName : _userNickName;
    [_table reloadData];
}
// 发送邀请群成员验证
- (void)needVerify:(WH_JXMessageObject *)msg {
    [self WH_show_WHOneMsg:msg];
}

// 单条图文点击
- (void) WH_onDidSystemImage1:(NSNotification *)notif {
    if (recording) {
        return;
    }
    WH_JXMessageObject *msg = notif.object;
    id content = [msg.content mj_JSONObject];
    NSString *url = [content objectForKey:@"url"];
    
    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
    webVC.wh_isGotoBack= YES;
    webVC.isSend = YES;
    webVC.title = [content objectForKey:@"title"];
    webVC.url = url;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
    
}

// 多条图文点击
- (void) WH_onDidSystemImage2:(NSNotification *)notif {
    if (recording) {
        return;
    }
    NSDictionary *dic = notif.object;
    NSString *url = [dic objectForKey:@"url"];
    
    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
    webVC.wh_isGotoBack= YES;
    webVC.isSend = YES;
    webVC.title = [dic objectForKey:@"title"];
    webVC.url = url;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
    
}

// 音视频通话状态cell点击
- (void) WH_onDidAVCall:(NSNotification *)notif {
    if (recording) {
        return;
    }
    WH_JXMessageObject *msg = notif.object;
    
    BOOL isMeeting = NO;
    switch ([msg.type intValue]) {
        case kWCMessageTypeAudioMeetingInvite:
        case kWCMessageTypeAudioChatCancel:
        case kWCMessageTypeAudioChatEnd: {
            self.isAudioMeeting = YES;
            isMeeting = YES;
        }
//            [self onChatAudio:msg];
            break;
        case kWCMessageTypeVideoMeetingInvite:
        case kWCMessageTypeVideoChatCancel:
        case kWCMessageTypeVideoChatEnd: {
            self.isAudioMeeting = NO;
            isMeeting = YES;
        }
//            [self onChatVideo:msg];
            break;
            
        default:
            break;
    }
    
    if (isMeeting && [g_config.isOpenCluster integerValue] == 1) {
        
        [g_server WH_userOpenMeetWithToUserId:chatPerson.userId toView:self];
    }else {
        if (self.isAudioMeeting) {
            [self onChatAudio:msg];
        }else {
            [self onChatVideo:msg];
        }
    }
}

#pragma mark 文件cell点击
- (void) WH_onDidFile:(NSNotification *)notif {
    if (recording) {
        return;
    }
    WH_JXMessageObject *msg = notif.object;
    WH_JXShareFileObject *obj = [[WH_JXShareFileObject alloc] init];
    obj.fileName = [msg.fileName lastPathComponent];
    obj.url = msg.content;
    obj.size = [NSString stringWithFormat:@"%@" ,msg.fileSize];
    
    WH_JXFileDetail_WHViewController *vc = [[WH_JXFileDetail_WHViewController alloc] init];
    vc.shareFile = obj;
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];

}

// 链接cell点击
- (void) WH_onDidLink:(NSNotification *)notif {
    if (recording) {
        return;
    }
    [_messageText resignFirstResponder];
    
    WH_JXMessageObject *msg = notif.object;
    id content = [msg.content mj_JSONObject];
    NSString *url = [content objectForKey:@"url"];
    
    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
    webVC.isGoBack= YES;
    webVC.isSend = YES;
    webVC.title = [content objectForKey:@"title"];
    webVC.url = url;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
    
}

// 戳一戳点击
- (void)WH_onDidShake:(NSNotification *)notif {
    WH_JXMessageObject *msg = notif.object;
    
    int value = 0;
    if (msg.isMySend) {
        value = -50;
    }else {
        value = 50;
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];///横向移动
    
    animation.toValue = [NSNumber numberWithInt:value];
    
    animation.duration = .5;
    
    animation.removedOnCompletion = YES;//yes的话，又返回原位置了。
    
    animation.repeatCount = 2;
    
    animation.fillMode = kCAFillModeForwards;
    
    _shakeBgView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animation.duration * animation.repeatCount * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _shakeBgView.hidden = YES;
    });
    
    [_messageText.inputView.superview.layer addAnimation:animation forKey:nil];
    [self.view.layer removeAllAnimations];
    [self.view.layer addAnimation:animation forKey:nil];
}

// 合并转发点击
- (void)WH_onDidMergeRelay:(NSNotification *)notif {
    WH_JXMessageObject *msg = notif.object;
    NSArray *content = [msg.content mj_JSONObject];
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < content.count; i ++) {
        NSString *str = content[i];
        NSDictionary *dict = [str mj_JSONObject];
        WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
        [msg fromDictionary:dict];
        msg.isNotUpdateHeight = YES;
        [array addObject:msg];
    }
    
    WH_JXChatLog_WHVC *vc = [[WH_JXChatLog_WHVC alloc] init];
    
    vc.array = array;
    vc.title = msg.objectId;
    [g_navigation pushViewController:vc animated:YES];
    
}

// 分享cell点击
- (void)onDidShare:(NSNotification *)notif {
    if (recording) {
        return;
    }
    WH_JXMessageObject *msg = notif.object;
     NSDictionary * msgDict = [msg.objectId mj_JSONObject];
    
    NSString *url = [msgDict objectForKey:@"url"];
    NSString *downloadUrl = [msgDict objectForKey:@"downloadUrl"];
    
    if ([url rangeOfString:@"http"].location == NSNotFound) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:nil completionHandler:^(BOOL success) {
            
            if (!success) {
                
                WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
                webVC.isGoBack= YES;
                webVC.isSend = YES;
                webVC.titleString = [msgDict objectForKey:@"title"];
                webVC.url = downloadUrl;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
            }
            
        }];
        
    }else {
        WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
        webVC.isGoBack= YES;
        webVC.isSend = YES;
        webVC.titleString = [msgDict objectForKey:@"title"];
        webVC.url = url;
        webVC = [webVC init];
        [g_navigation.navigationView addSubview:webVC.view];
//        [g_navigation pushViewController:webVC animated:YES];
    }
    
}

// 控制消息点击
- (void)onDidRemind:(NSNotification *)notif {
    WH_JXMessageObject *msg = notif.object;
    
    if ([msg.remindType intValue] == kRoomRemind_NeedVerify) {
        WH_JXVerifyDetail_WHVC *vc = [[WH_JXVerifyDetail_WHVC alloc] init];
        vc.chatVC = self;
        vc.msg = msg;
        vc.room = self.room;
        [g_navigation pushViewController:vc animated:YES];
    }
    
    if ([msg.remindType intValue] == kWCMessageTypeRedPacketReceive) {
        self.isDidRedPacketRemind = YES;
        [g_server WH_getRedPacketWithMsg:msg.objectId toView:self];
    }
}

// 回复消息点击
- (void)onDidReply:(NSNotification *)notif {
    int indexNum = [notif.object intValue];
    WH_JXMessageObject *msg = _array[indexNum];
    
    WH_JXMessageObject *msgObj = [[WH_JXMessageObject alloc] init];
    NSDictionary *dict = [msg.objectId mj_JSONObject];
    [msgObj fromDictionary:dict];
    for (WH_JXMessageObject *msg1 in _array) {
        if ([msgObj.messageId isEqualToString:msg1.messageId]) {
            NSUInteger index = [_array indexOfObject:msg1];
            [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    
}

// 文本消息阅后即焚
- (void)onDidMessageReadDel:(NSNotification *)notif {
    int indexNum = [notif.object intValue];
    [_table WH_reloadRow:indexNum section:0];
    
}

// 消息撤回
- (void)withdrawNotifi:(NSNotification *) notif {
    WH_JXMessageObject *msg = notif.object;
    
    for(NSInteger i=[_array count]-1;i>=0;i--){
        WH_JXMessageObject *p=[_array objectAtIndex:i];
        if([p.messageId isEqualToString:msg.messageId]){//如果找到被撤回的那条消息
            p.content = msg.content;
            p.type = msg.type;
            [_table WH_reloadRow:(int)i section:0];
        }
        p =nil;
    }
}

- (void)createRoom{
    if (recording) {
        return;
    }
    WH_JXChatSetting_WHVC *vc = [[WH_JXChatSetting_WHVC alloc] init];
    vc.user = self.chatPerson;
    vc.room = self.room;
    vc.chatRoom = self.chatRoom;
    [g_navigation pushViewController:vc animated:YES];
    
//    WH_JXSelFriend_WHVC* vc = [WH_JXSelFriend_WHVC alloc];
////    vc.chatRoom = _chatRoom;
//    vc.room = _room;
//    vc.isNewRoom = YES;
//    vc.isForRoom = YES;
//    vc.forRoomUser = chatPerson;
//    vc = [vc init];
////    [g_window addSubview:vc.view];
//    [g_navigation pushViewController:vc animated:YES];
}

- (BOOL)sendMsgCheck {
    // 验证XMPP是否在线
    if(g_xmpp.isLogined == login_status_no){
        //        [self hideKeyboard:NO];
        //        [g_xmpp showXmppOfflineAlert];
        //        return YES;
        
        //        [g_xmpp logout];
        [g_xmpp login];
        
    }
    
    if (self.roomJid) {
        NSString *s;
        // 验证群组是否有效
        switch ([self.groupStatus intValue]) {
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
        
        if (!s || s.length <= 0) {
            if (!chatRoom.isConnected) {
                [g_xmpp.roomPool.pool removeObjectForKey:chatPerson.userId];
                [g_xmpp.roomPool joinRoom:chatPerson.userId title:chatPerson.userNickname isNew:NO];
                s = Localized(@"JX_GroupConnectionFailed");
                chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:chatPerson.userId title:chatPerson.userNickname isNew:NO];
            }
        }
        
        if (self.isDisable) {
            s = Localized(@"JX_GroupNotUse");
        }
        
        if (s.length > 0) {
            [self hideKeyboard:NO];
            [g_server showMsg:s];
            return YES;
        }
        
//        if (!chatRoom.isConnected) {
//            [_wait start];
//            chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:chatPerson.userId title:chatPerson.userNickname isNew:NO];
//            return YES;
//        }
        
    }else {
        if ([self.chatPerson.userId intValue] <=10100 && [self.chatPerson.userId intValue] >=10000) {
            return NO;
        }
        if (self.isGroupMessages) {
            return NO;
        }
        // 是否被拉入黑名单
        if (self.isBeenBlack > 0) {
            [g_App showAlert:Localized(@"TO_BLACKLIST")];
            return YES;
        }else
//            if (self.friendStatus != 2 && self.friendStatus != 10) {
//            [g_App showAlert:Localized(@"JX_NoFriendsWithMe")];
//            return YES;
//        }else
        {
            return NO;
        }
    }
    
    return NO;
}

- (BOOL)checkCameraLimits{
    /// 先判断摄像头硬件是否好用
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 用户是否允许摄像头使用
        NSString * mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        // 不允许弹出提示框
        if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
          
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:Localized(@"JX_CameraNotTake") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:Localized(@"WaHu_JXSetting_WaHuVC_Set") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // 无权限 引导去开启
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
            UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:Localized(@"JX_Cencal") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [alert addAction:actionCancel];
            
            [self presentViewController:alert animated:YES completion:nil];
            return NO;
        }else{
            // 这里是摄像头可以使用的处理逻辑
            return YES;
        }
    } else {
        // 硬件问题提示
        [g_App showAlert:Localized(@"JX_CameraBad")];
        return NO;
    }
}

/**
 跳转到聊天页面
 
 @param userId 用户id
 */
+ (void)gotoChatViewController:(NSString *)userId{
    WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:userId];
    WH_JXChat_WHViewController *chatVC = [WH_JXChat_WHViewController alloc];
    chatVC.title = user.userNickname;
    chatVC.roomJid = user.userId;
    chatVC.roomId = user.roomId;
    chatVC.chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname isNew:YES];
    chatVC.groupStatus = user.groupStatus;
    NSDictionary * groupDict = [user toDictionary];
    WH_RoomData * roomdata = [[WH_RoomData alloc] init];
    [roomdata WH_getDataFromDict:groupDict];
    chatVC.room = roomdata;
    chatVC.chatPerson = user;
    chatVC = [chatVC init];
    [g_navigation pushViewController:chatVC animated:YES];
}
//处理公告消息类型
- (NSString *)getContentMsg:(id)msg{
    NSString *newContent = @"";
    //添加开启公告强提醒后数据格式判断
    //是否可以解析到字典
    NSDictionary *contentDic = [NSDictionary dictionary];
    if ([msg isKindOfClass:[NSString class]]) {
        NSString *dataStr = (NSString *)msg;
        contentDic = [NSJSONSerialization JSONObjectWithData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
    if ([msg isKindOfClass:[NSDictionary class]] || [contentDic isKindOfClass:[NSDictionary class]]) {
        if ([contentDic valueForKey:@"text"] && contentDic[@"text"] != [NSNull class] && contentDic[@"text"] != nil) {
            newContent = contentDic[@"text"];
        }else{
        }
    }else if([msg isKindOfClass:[NSString class]]){
        newContent = msg;
    }else{
        //不处理 ""
    }
    return newContent;
}
@end
