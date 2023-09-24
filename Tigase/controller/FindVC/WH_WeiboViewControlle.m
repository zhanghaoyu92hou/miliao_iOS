//
//  WeiboViewControlle.m
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "WH_WeiboViewControlle.h"
#import "WH_WeiboCell.h"
#import "ObjUrlData.h"
#import "JSONKit.h"
#import "LXActionSheet.h"
#import "addMsgVC.h"
#import "JXTextView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "photosViewController.h"
//#import "mvViewController.h"
//#import "userInfoVC.h"
#import "WH_JXUserInfo_WHVC.h"
//#import "WH_JX_WHCell.h"
#import "WH_webpage_WHVC.h"
#import "JXBlogRemind.h"
#import "WH_JXTabMenuView.h"
#import "JXBlogRemindVC.h"
#import "WH_JX_DownListView.h"
#import "WH_JXReportUser_WHVC.h"
#import "WH_JXActionSheet_WHVC.h"
#import "WH_JXMenuView.h"
#import "ImageResize.h"
#import "WH_JXCamera_WHVC.h"
#import "WWPopupView.h"
#import "WH_WeiboSearchViewController.h"
#define TopHeight 7
#define CellHeight 45

@interface WH_WeiboViewControlle ()<UIAlertViewDelegate,WH_JXActionSheet_WHVCDelegate,JXSelectMenuViewDelegate,JXMenuViewDelegate,WH_WeiboCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WH_JXCamera_WHVCDelegate,WWPopupDelegate>
{
    BOOL _first;
    NSString * phoneNumber;
    WKWebView * webView;
    
    NSMutableArray * _images;  //测试用
    NSMutableArray * _contents;
    
    UIImageView *_topBackImageView;
}
@property (nonatomic,copy)NSString *urlStr;
@property (nonatomic, strong) WH_JXMessageObject *remindMsg;
@property (nonatomic, strong) NSMutableArray *remindArray;

@property (nonatomic, strong) WeiboData *currentData;
@property (nonatomic, strong) WH_JXActionSheet_WHVC *actionVC;

@property (nonatomic, strong) WH_WeiboCell *lastCell;   // 用于点赞、评论控件， 记录上个cell

//@property (nonatomic, strong) NSMutableArray *collectArray;

@property (nonatomic, assign) BOOL isFirstGoin;
@property (nonatomic, strong) NSString *topImageUrl;


/** 自定义导航 */
@property (nonatomic,weak) UIView *view_bar;
@property (nonatomic,weak) UIButton *bar_leftBtn;
@property (nonatomic,weak) UIButton *bar_rightBtn;
@property (nonatomic,weak) UIButton *bar_searchBtn;
@property (nonatomic,weak) UIImageView *bar_bgImageV;
@property (nonatomic,weak) UIView *separateLine;
@property (nonatomic,weak) UILabel *titleL;

@property (nonatomic, strong)WWPopupView *popupView;

@end

@implementation WH_WeiboViewControlle
@synthesize wh_replyDataTemp,wh_selectWeiboData,wh_deleteWeibo,refreshCount,wh_refreshCellIndex,wh_selectWH_WeiboCell,user;


- (id)init
{
    self = [super init];
    if (self) {
        _pool = [[NSMutableArray alloc]init];
        wh_refreshCellIndex = -1;
        //self.wh_isGotoBack   = NO;
//        self.title = Localized(@"WeiboViewControlle_MyFriend");
        self.title = Localized(@"JX_LifeCircle");
        
//        _input.delegate = self;
        self.wh_heightFooter = 0;
        self.wh_heightHeader = 0;
        
        if (self.isDetail) {
            self.wh_isGotoBack   = YES;
            self.title = Localized(@"JX_Detail");
            self.wh_heightFooter = 0;
            self.wh_heightHeader = JX_SCREEN_TOP;
        }
        
#ifdef IS_SHOW_MENU
        self.wh_isGotoBack = YES;
#endif
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self creatNavHeaderView];
        if (!self.isDetail && [self.user.userId isEqualToString:MY_USER_ID]) {
            [self buildAddMsg];
        }else {
            self.wh_isShowFooterPull = NO;
        }
        [self buildInput];
        _first = YES;
        wh_replyDataTemp = [[WeiboReplyData alloc]init];
        _datas=[[NSMutableArray alloc]init];
        
        [g_notify addObserver:self selector:@selector(WH_doRefresh:) name:kUpdateUser_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(urlTouch:) name:kCellTouchUrl_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(phoneTouch:) name:kCellTouchPhone_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(remindNotif:) name:kXMPPMessageWeiboRemind_WHNotification object:nil];
        [g_notify addObserver:self selector:@selector(didEnterBackground:) name:kApplicationDidEnterBackground object:nil];
        [g_notify addObserver:self selector:@selector(refreshCurrentView) name:kRefreshCurrentView object:nil];
        _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
        if (_remindArray.count > 0 && !self.isNotShowRemind) {
            [self createTableHeadShowRemind];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [g_mainVC.tb wh_setBadge:g_mainVC.tb.wh_items.count == 5 ? 3 : 2 title:[NSString stringWithFormat:@"%ld",_remindArray.count]];
            });
            
        }else {
            [self createTableHeadShowRemind];
        }
        [self getWeiboBackImage];
        //取消解压缩下载图片
        [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    }
    return self;
}

- (void)creatNavHeaderView
{
    
    
    //添加顶部自定义导航条
    UIView *customHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self_width, JX_SCREEN_TOP)];
    customHeadView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:customHeadView];
    self.view_bar = customHeadView;
    
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self_width, JX_SCREEN_TOP)];
    iv.image = [UIImage imageNamed:@"newicon_nav_shawder"];
    [customHeadView addSubview:iv];
    self.bar_bgImageV = iv;
    
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, self_width-40*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = g_factory.navigatorTitleColor;
    p.font = g_factory.navigatorTitleFont;
    p.text = self.title;
    
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(WH_actionTitle:);
    p.wh_delegate = self;
    p.wh_changeAlpha = NO;
    [customHeadView addSubview:p];
    self.titleL = p;
    
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(NAV_INSETS-6, JX_SCREEN_TOP - NAV_BTN_SIZE - 8 - 6, NAV_BTN_SIZE+12, NAV_BTN_SIZE+12)];
    [backBtn setImage:[UIImage imageNamed:@"newicon_nav_whiteback"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [customHeadView addSubview:backBtn];
    self.bar_leftBtn = backBtn;
    
    
    UIView *separateLine = [[UIView alloc] init];
    self.separateLine = separateLine;
    separateLine.backgroundColor = HEXCOLOR(0xdbe0e8);
    separateLine.frame = CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 0.5);
    [self.view_bar addSubview:separateLine];
    
    //初始化
    separateLine.hidden = YES;
    self.titleL.hidden = YES;
    
    if (self.isDetail) {
        separateLine.hidden = NO;
        self.titleL.hidden = NO;
        customHeadView.backgroundColor = [UIColor whiteColor];
        self.bar_bgImageV.hidden = YES;
        [backBtn setImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    }
    
}

-(instancetype)initCollection{
    if (self = [super init]) {
        self.isCollection = YES;
        self.title = Localized(@"JX_MyCollection");
        self.wh_isGotoBack = YES;
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        
        self.datas = [NSMutableArray array];
        self.user = g_myself;
        [self WH_createHeadAndFoot];
        [self createTableHeadShowRemind];
        self.footer.hidden = YES;
        [self getWeiboBackImage];
    }
    return self;
}

-(void)dealloc{
    [_pool removeAllObjects];
    [g_notify removeObserver:self name:kUpdateUser_WHNotifaction object:nil];
    [g_notify removeObserver:self name:kCellTouchUrl_WHNotifaction object:nil];
    [g_notify removeObserver:self name:kXMPPMessageWeiboRemind_WHNotification object:nil];
    [g_notify removeObserver:self name:kApplicationDidEnterBackground object:nil];
//    NSLog(@"WeiboViewControlle.dealloc");
    //    [super dealloc];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)getWeiboBackImage {
    [g_server getUser:user.userId toView:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [g_notify  addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillShowNotification object:nil];

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [g_notify  removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_wh_videoPlayer) {
        [g_notify postNotificationName:@"CancleVideoPlay_Notification" object:nil];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}

#pragma mark - 朋友圈新消息提醒
- (void) remindNotif:(NSNotification *)notif {
    WH_JXMessageObject *msg = notif.object;
    self.remindMsg = msg;
    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    if (_remindArray.count > 0 && !self.isNotShowRemind) {
        [self createTableHeadShowRemind];
    }else {
        [self showTopImage];
    }
    [self WH_scrollToPageUp];
}

// 进入后台
- (void)didEnterBackground:(NSNotification *)notif {
    // 暂停语音播放
    for (NSInteger i = 0; i < _datas.count; i ++) {
        WH_WeiboCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell) {
            if (cell.wh_audioPlayer != nil) {
                [cell.wh_audioPlayer wh_stop];
            }
        }
    }
}

-(void)WH_getServerData{
    [_wait start];
    if (self.isCollection) {
        [g_server WH_userCollectionListWithType:0 pageIndex:0 toView:self];
    }else if (self.isDetail) {
        [g_server WH_getMessageWithMsgId:self.wh_detailMsgId toView:self];
    }else{
        [[JXServer sharedServer] WH_getMessageWithMsgId:0 messageId:[self getLastMessageId:_datas] toView:self];
    }
    
}

-(void)WH_scrollToPageUp{
    [self doHideKeyboard];
    [super WH_scrollToPageUp];
}
#pragma mark ------------------数据成功返回----------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
//    [super stopLoading];
    
    if([aDownload.action isEqualToString:wh_act_UploadFile]){
        WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
        user.msgBackGroundUrl = [[dict[@"images"] firstObject] objectForKey:@"oUrl"];
        [g_server WH_updateUser:user toView:self];
    }
    if ([aDownload.action isEqualToString:wh_act_UserUpdate]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@",dict[@"msgBackGroundUrl"]];
        if (IsStringNull(urlStr)) {
            [g_server WH_getHeadImageLargeWithUserId:user.userId userName:user.userNickname imageView:_topBackImageView];
        }else {
            [g_server WH_getImageWithUrl:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] imageView:_topBackImageView];
        }
        
        _topImageUrl = urlStr;
        //缓存背景url到本地
        [[NSUserDefaults standardUserDefaults] setObject:_topImageUrl?:@"" forKey:@"user_info_headImageUrlString"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    //添加新回复
    if([aDownload.action isEqualToString:wh_act_CommentAdd]){
        [wh_replyDataTemp setMatch];
        if (wh_selectWeiboData.replys.count >= 20) {
            wh_selectWeiboData.replys = [NSMutableArray arrayWithArray:[wh_selectWeiboData.replys subarrayWithRange:NSMakeRange(0, 19)]];
        }
//        [wh_selectWeiboData.replys addObject:wh_replyDataTemp];
        [wh_selectWeiboData.replys insertObject:wh_replyDataTemp atIndex:0];
        wh_selectWeiboData.page = 0;
        wh_selectWeiboData.commentCount += 1;
        wh_selectWeiboData.replyHeight=[wh_selectWeiboData heightForReply];
        if ([wh_selectWeiboData.replys count] != 0) {
            [self.wh_selectWH_WeiboCell refresh];
        }
        
        wh_replyDataTemp = [[WeiboReplyData alloc]init];
    }else if ([aDownload.action isEqualToString:wh_act_CommentDel]){
        
        [wh_selectWeiboData.replys removeObjectAtIndex:self.deleteReply];

        [wh_replyDataTemp setMatch];
        wh_selectWeiboData.page = 0;
        wh_selectWeiboData.replyHeight=[wh_selectWeiboData heightForReply];
        if ([wh_selectWeiboData.replys count] != 0) {
            [self.wh_selectWH_WeiboCell refresh];
        }
    }
    if([aDownload.action isEqualToString:wh_act_PraiseAdd]){
        [self doAddPraiseOK];
    }
    if([aDownload.action isEqualToString:wh_act_PraiseDel]){
        [self doDelPraiseOK];
    }
    if([aDownload.action isEqualToString:wh_act_GiftAdd]){
        
    }
    if([aDownload.action isEqualToString:wh_act_userEmojiAdd]){
        WeiboData *data = _datas[self.lastCell.tag];
        data.isCollect = YES;
//        [_datas replaceObjectAtIndex:self.lastCell.tag withObject:data];
//        [_table WH_reloadRow:(int)self.lastCell.tag section:0];
        [g_server showMsg:Localized(@"JX_CollectionSuccess") delay:1.3f];
    }
    if([aDownload.action isEqualToString:wh_act_CommentList]){
        for(int i=0;i<[array1 count];i++){
            WeiboReplyData * reply=[[WeiboReplyData alloc]init];
            NSDictionary* dict = [array1 objectAtIndex:i];
            reply.type=1;
            reply.addHeight = 60;
            [reply WH_getDataFromDict:dict];
            [reply setMatch];
            [self.wh_selectWeiboData.replys addObject:reply];
        }
        [self.wh_selectWH_WeiboCell refresh];
    }
    if([aDownload.action isEqualToString:wh_act_MsgDel]){
        [_datas removeObject:wh_selectWeiboData];
        refreshCount++;
        [_table reloadData];
    }
    if([aDownload.action isEqualToString:wh_act_MsgList] || [aDownload.action isEqualToString:wh_act_MsgListUser] || [aDownload.action isEqualToString:wh_act_MsgGet]){

        self.wh_isShowFooterPull = [array1 count] >= WH_page_size;

        if(_page==0)
            [_datas removeAllObjects];
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //数据莫名为空
        if(_datas != nil){
            NSMutableArray * tempData = [[NSMutableArray alloc] init];
            for (int i=0; i<[array1 count]; i++) {
                NSDictionary* row = [array1 objectAtIndex:i];
                WeiboData * weibo=[[WeiboData alloc]init];
                [weibo WH_getDataFromDict:row];
                [tempData addObject:weibo];
            }
            if (tempData.count > 0){
                [_datas addObjectsFromArray:tempData];
                [self loadWeboData:_datas complete:nil formDb:NO];
            }else {
                if (dict) {
                    WeiboData *data = [[WeiboData alloc] init];
                    [data WH_getDataFromDict:dict];
                    [tempData addObject:data];
                    [_datas addObjectsFromArray:tempData];
                    [self loadWeboData:_datas complete:nil formDb:NO];
                }
            }
        }
        
        [_table reloadData];
    }
    if ([aDownload.action isEqualToString:wh_act_userCollectionList]) {
        if (_page ==0) {
            [_datas removeAllObjects];
        }
        NSMutableArray * tempData = [[NSMutableArray alloc] init];
        for (int i=0; i<[array1 count]; i++) {
            NSDictionary* row = [array1 objectAtIndex:i];
            NSString * msgStr = row[@"msg"];
//            NSDictionary * msgDict = [[[SBJsonParser alloc]init]objectWithString:msgStr];
//
//            WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
////            [msg fromDictionary:bodyDict];
//            [msg fromXmlDict:msgDict];
            
            int collectType = [row[@"type"] intValue];
            NSTimeInterval createTime = [row[@"createTime"] doubleValue];
            NSString * emojiId = row[@"emojiId"];
            
            NSString *url = row[@"url"];
            NSString *fileLength = row[@"fileLength"];
            NSString *fileName = row[@"fileName"];
            NSString *fileSize = row[@"fileSize"];
            NSString *collectContent = row[@"collectContent"];

            WeiboData * weibo=[[WeiboData alloc]init];
            weibo.createTime = createTime;
            weibo.objectId = emojiId;
            if (collectContent.length > 0) {
                weibo.content = collectContent;
            }
//            [weibo WH_getDataFromDict:row];
            [self weiboData:weibo WithUrl:url msg:msgStr collectType:collectType fileLength:fileLength fileName:fileName fileSize:fileSize];
            [tempData addObject:weibo];
        }
        if (tempData.count > 0){
            [_datas addObjectsFromArray:tempData];
            [self loadWeboData:_datas complete:nil formDb:NO];
        }
        [_table reloadData];
        
    }
    if ([aDownload.action isEqualToString:wh_act_ShengHuoQuanDeleteCollect]) {
        [g_server showMsg:Localized(@"JX_weiboCancelCollect") delay:1.3f];
        WeiboData *data = _datas[self.lastCell.tag];
        data.isCollect = NO;
//        [_datas replaceObjectAtIndex:self.lastCell.tag withObject:data];
//        [_table WH_reloadRow:(int)self.lastCell.tag section:0];
    }
    if ([aDownload.action isEqualToString:wh_act_userEmojiDelete]) {
        [g_server showMsg:Localized(@"JXAlert_DeleteOK") delay:1.3f];
        NSIndexPath * indexPath = [_table indexPathForCell:wh_selectWH_WeiboCell];
        [_datas removeObject:wh_selectWeiboData];
//        [_table deleteRow:(int)indexPath.row section:(int)indexPath.section];
        [_table reloadData];
    }

    if([aDownload.action isEqualToString:wh_act_PhotoList]){
        if([array1 count]>0){
            [photosViewController showPhotos:array1];
        }else{
            
        }
    }
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* p = [[WH_JXUserObject alloc]init];
        [p WH_getDataFromDict:dict];

        if (!self.isFirstGoin) {
            self.isFirstGoin = YES;
            _topImageUrl = p.msgBackGroundUrl;
            
            //缓存背景url到本地
            [[NSUserDefaults standardUserDefaults] setObject:_topImageUrl?:@"" forKey:@"user_info_headImageUrlString"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self showTopImage];

            return;
        }
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = p;
        vc.wh_fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [g_navigation pushViewController:vc animated:YES];
        [_pool addObject:vc];
//        [p release];
    }
    
    if([aDownload.action isEqualToString:wh_act_Report]){
        [_wait stop];
        [g_App showAlert:Localized(@"WaHu_JXUserInfo_WaHuVC_ReportSuccess")];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
//    [super stopLoading];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
//    [super stopLoading];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

-(void)weiboData:(WeiboData *)weiboData WithUrl:(NSString *)dataUrl msg:(NSString *)msg collectType:(int)collectType fileLength:(NSString *)fileLength fileName:(NSString *)fileName fileSize:(NSString *)fileSize{
//    weiboData.messageId = msg.messageId;
    weiboData.userId = MY_USER_ID;
    weiboData.userNickName = MY_USER_NAME;
    
//    weiboData.createTime = [[dict objectForKey:@"time"] longLongValue];
//    weiboData.deviceModel = [dict objectForKey:@"model"];
//    weiboData.location = [dict objectForKey:@"location"];
//    weiboData.flag = [[dict objectForKey:@"flag"] intValue];
//    weiboData.visible = [[dict objectForKey:@"visible"] intValue];
//    weiboData.isPraise = [[dict objectForKey:@"isPraise"] boolValue];
//    weiboData.isLoved = [[dict objectForKey:@"isLoved"] boolValue];
    
//    weiboData.loveCount = [[[dict objectForKey:@"count"] objectForKey:@"collect"] intValue];
//    weiboData.shareCount = [[[dict objectForKey:@"count"] objectForKey:@"share"] intValue];
//    weiboData.playCount = [[[dict objectForKey:@"count"] objectForKey:@"play"] intValue];
//    weiboData.forwardCount = [[[dict objectForKey:@"count"] objectForKey:@"forward"] intValue];
//    weiboData.praiseCount = [[[dict objectForKey:@"count"] objectForKey:@"praise"] intValue];
//    weiboData.commentCount = [[[dict objectForKey:@"count"] objectForKey:@"comment"] intValue];
//    weiboData.giftCount = [[[dict objectForKey:@"count"] objectForKey:@"money"] intValue];
//    weiboData.giftTotalPrice = [[[dict objectForKey:@"count"] objectForKey:@"total"] intValue];
    
//    weiboData.title = @"titletitle";
//    weiboData.type = [[[dict objectForKey:@"body"] objectForKey:@"type"] intValue];
    
    //    self.audios   = [[dict objectForKey:@"body"] objectForKey:@"audios"];
    //    self.videos   = [[dict objectForKey:@"body"] objectForKey:@"videos"];
//    weiboData.time = [[dict objectForKey:@"body"]  objectForKey:@"time"];
//    weiboData.address = [[dict objectForKey:@"body"]  objectForKey:@"address"];
//    weiboData.remark = [[dict objectForKey:@"body"]  objectForKey:@"remark"];
    
//    NSDictionary* row = nil;
    
    
//    CollectTypeEmoji    = 6,//表情
//    CollectTypeImage    = 1,//图片
//    CollectTypeVideo    = 2,//视频
//    CollectTypeFile     = 3,//文件
//    CollectTypeVoice    = 4,//语音
//    CollectTypeText     = 5,//文本
    
    
    if (collectType == 1) {//图片
        weiboData.type = weibo_dataType_image;
//        weiboData.images = [NSMutableArray arrayWithObject:msg.content];
        NSArray *urlArr = [dataUrl componentsSeparatedByString:@","];
        for (int i = 0; i < urlArr.count; i++) {
            ObjUrlData * url=[[ObjUrlData alloc] init];
            url.url= urlArr[i];
            url.mime=@"image/pic";
            [weiboData.smalls addObject:url];
            [weiboData.larges addObject:url];
            [weiboData.images addObject:url];
        }
        
    }else if (collectType == 2) {//视频
        weiboData.type = weibo_dataType_video;
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= dataUrl;
        url.fileSize = fileSize;
        url.timeLen = @([fileLength intValue]);
        [weiboData.videos addObject:url];
    }else if (collectType == 3) {//文件
        weiboData.type = weibo_dataType_file;
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= msg;
        url.fileSize = fileSize;
        url.type = @"4";
        if (fileName.length > 0) {
            url.name = [fileName lastPathComponent];
        }else {
            url.name = [msg lastPathComponent];
        }
        [weiboData.files addObject:url];
    }else if (collectType == 4) {//语音
        weiboData.type = weibo_dataType_audio;
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= dataUrl;
        url.fileSize =fileSize;
        url.timeLen = @([fileLength intValue]);
        [weiboData.audios addObject:url];
    }else if (collectType == 5) {//文本
        weiboData.type = weibo_dataType_text;
        weiboData.content= msg;
    }else if (collectType == 6) {//表情
        
    }
//    NSArray* p = nil;
//    weiboData.images = [[dict objectForKey:@"body"] objectForKey:@"images"];
//    
//    for(int i=0;i<[p count];i++){
//        row = [p objectAtIndex:i];
//        
//        ObjUrlData * url=[[ObjUrlData alloc] init];
//        url.url= [row objectForKey:@"tUrl"];
//        url.mime=@"image/pic";
//        [smalls addObject:url];
//        
//        url =[[ObjUrlData alloc]init];
//        url.url= [row objectForKey:@"oUrl"];
//        url.mime=@"image/pic";
//        [larges addObject:url];
//    }
    
//    p = [[dict objectForKey:@"body"] objectForKey:@"audios"];
//    for(int i=0;i<[p count];i++){
//        row = [p objectAtIndex:i];
//        
//        ObjUrlData * url=[[ObjUrlData alloc] init];
//        url.url= [row objectForKey:@"oUrl"];
//        url.fileSize = [row objectForKey:@"size"];
//        url.timeLen = [row objectForKey:@"length"];
//        [audios addObject:url];
//    }
    
//    p = [[dict objectForKey:@"body"] objectForKey:@"videos"];
//    for(int i=0;i<[p count];i++){
//        row = [p objectAtIndex:i];
//        
//        ObjUrlData * url=[[ObjUrlData alloc] init];
//        url.url= [row objectForKey:@"oUrl"];
//        url.fileSize = [row objectForKey:@"size"];
//        url.timeLen = [row objectForKey:@"length"];
//        [videos addObject:url];
//    }
    
    if( ([weiboData.audios count]>0 || [weiboData.videos count]>0) && [weiboData.images count]<=0){//假如没图，则用头像代替
        ObjUrlData * url=[[ObjUrlData alloc]init];
        //        url.url= @"http://www.feizl.com/upload2007/2013_02/130227014423722.jpg";
        url.url= [g_server WH_getHeadImageOUrlWithUserId:MY_USER_ID];
        url.mime=@"image/pic";
        [weiboData.smalls addObject:url];
    }
    
//    p = [dict objectForKey:@"praises"];
//    for(int i=0;i<[p count];i++){
//        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
//        reply.type=reply_data_praise;
//        //        reply.addHeight = self.minHeightForComment;
//        reply.messageId=self.messageId;
//        row = [p objectAtIndex:i];
//        [reply WH_getDataFromDict:row];
//        [praises addObject:reply];
//    }
    
    
//    p = [dict objectForKey:@"gifts"];
//    for(int i=0;i<[p count];i++){
//        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
//        reply.type=reply_data_gift;
//        //        reply.addHeight = self.minHeightForComment;
//        reply.messageId=self.messageId;
//        row = [p objectAtIndex:i];
//        [reply WH_getDataFromDict:row];
//        [gifts addObject:reply];
//    }
    
//    p = [dict objectForKey:@"comments"];
//    for(NSInteger i = p.count - 1; i >= 0; i--){
//        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
//        reply.type=reply_data_comment;
//        reply.addHeight = self.minHeightForComment;
//        reply.messageId=self.messageId;
//        row = [p objectAtIndex:i];
//        [reply WH_getDataFromDict:row];
//        [replys addObject:reply];
//    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isDetail) {
        //使大头像显示不全，让下方不被tabbar遮挡
        _table.contentInset = UIEdgeInsetsMake(-JX_SCREEN_WIDTH/5*1.8, 0, 49, 0);
    }
//    _table.contentOffset = CGPointMake(0,JX_SCREEN_WIDTH/16.0*8.0);
    [UIApplication sharedApplication].statusBarHidden = NO;

}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self WH_scrollToPageUp];
    //监听键盘状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self doHideKeyboard];
}

//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    [self doHideKeyboard];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [_datas count];
}
#pragma mark - Table view     --------代理--------     data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *CellIdentifier = [NSString stringWithFormat:@"WH_WeiboCell_%d_%ld",refreshCount,indexPath.row];
    NSString *CellIdentifier = nil;
    if (self.isCollection)
        CellIdentifier = [NSString stringWithFormat:@"collectionCell"];
    else
        CellIdentifier = [NSString stringWithFormat:@"WH_WeiboCell"];
    
    WH_WeiboCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [WH_WeiboCell alloc];
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } 
    if (self.isSend) {
        cell.contentView.userInteractionEnabled = NO;
    }else {
        cell.contentView.userInteractionEnabled = YES;
    }
    
    WeiboData * weibo;
    if ([_datas count] > indexPath.row) {
        weibo=[_datas objectAtIndex:indexPath.row];
    }
    cell.delegate = self;
    cell.controller=self;
    cell.wh_tableViewP = tableView;
    cell.tag   = indexPath.row;
    cell.isPraise = weibo.isPraise;
    cell.isCollect = weibo.isCollect;
    cell.weibo = weibo;
    [cell setupData];
    NSLog(@"=============%ld",indexPath.row);
    float height=[self tableView:tableView heightForRowAtIndexPath:indexPath];
    UIView * view=[cell.contentView viewWithTag:1200];
    if(view==nil){
        UIView* line = [[UIView alloc]init];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        line.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
        [cell.contentView  addSubview:line];
        line.tag=1200;
    }else{
        view.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
    }
    if (self.isCollection) {
        cell.wh_btnReply.hidden = YES;
        cell.wh_btnLike.hidden = YES;
        cell.wh_btnReport.hidden = YES;
        cell.wh_btnCollection.hidden = YES;
    }
    if (self.isCollection || [weibo.userId isEqualToString:MY_USER_ID]) {
        
        cell.delBtn.hidden = NO;
    }else {
        cell.delBtn.hidden = YES;
    }
    
    if (self.isSend) {
        cell.delBtn.hidden = YES;
    }
    
    [self WH_doAutoScroll:indexPath];
    return cell;
}

- (void)videoStartPlayer {
    [_wh_videoPlayer wh_switch];
}

- (void)WH_WeiboCell:(WH_WeiboCell *)WH_WeiboCell clickVideoWithIndex:(NSInteger)index {
    self.wh_videoIndex = index;
    _wh_videoPlayer = [WH_JXVideoPlayer alloc];
    _wh_videoPlayer.videoFile = [[_datas objectAtIndex:index] getMediaURL];
    _wh_videoPlayer.type = JXVideoTypeWeibo;
    _wh_videoPlayer.WH_didVideoPlayEnd = @selector(WH_didVideoPlayEnd);
    _wh_videoPlayer.isShowHide = YES;
    _wh_videoPlayer.delegate = self;
    _wh_videoPlayer = [_wh_videoPlayer initWithParent:self.view];
    [self performSelector:@selector(videoStartPlayer) withObject:self afterDelay:0.2];

}

- (void)WH_WeiboCell:(WH_WeiboCell *)WH_WeiboCell shareUrlActionWithUrl:(NSString *)url title:(NSString *)title {
    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
    webVC.wh_isGotoBack= YES;
    webVC.isSend = YES;
    webVC.title = title;
    webVC.url = url;
    webVC = [webVC init];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}

#pragma mark - Table view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isDetail) {
        return;
    }
    
    //newicon_nav_whiteback  title_back newicon_nav_whiteback newicon_nav_shawder
    if (self.tableView.contentOffset.y < self.view.height*0.3+20) {
        //        [self.view_bar setHidden:NO];
        [self.bar_bgImageV setHidden:NO];
        [self.separateLine setHidden:YES];
        self.view_bar.backgroundColor=[UIColor clearColor];
        [self.bar_leftBtn setImage:[UIImage imageNamed:@"newicon_nav_whiteback"] forState:UIControlStateNormal];
        [self.bar_rightBtn setImage:[UIImage imageNamed:@"newicon_nav_whiteCamera"] forState:UIControlStateNormal];
        [self.bar_searchBtn setImage:[UIImage imageNamed:@"白色放大镜"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [self.titleL setHidden:YES];
    }else{
        //        [self.view_bar setHidden:NO];
        [self.bar_bgImageV setHidden:YES];
        [self.separateLine setHidden:NO];
        
        self.view_bar.backgroundColor=[UIColor whiteColor];
        
        [self.bar_leftBtn setImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
        [self.bar_rightBtn setImage:[UIImage imageNamed:@"newicon_nav_blueCamera"]
                           forState:UIControlStateNormal];
        [self.bar_searchBtn setImage:[UIImage imageNamed:@"蓝色放大镜"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self.titleL setHidden:NO];
        
    }
}

-(void)doHideMenu{
    [self resignFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:NO];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.wh_menuView) {
        [self.wh_menuView dismissBaseView];
        self.lastCell = nil;
    }
    [self doHideMenu];
    [self doHideKeyboard];
    
    if (self.isCollection) {
        
        if ([self.delegate respondsToSelector:@selector(weiboVC:didSelectWithData:)]) {
            WeiboData *data = _datas[indexPath.row];
            _currentData = data;
            [g_App showAlert:Localized(@"JXWantSendCollectionMessage") delegate:self tag:2457 onlyConfirm:NO];
        }
    }
    
    return;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    //依据数据的多少修改cell的高度
    if ([_datas count] != 0 && [_datas count] > indexPath.row) {
        WeiboData * data=[_datas objectAtIndex:indexPath.row];
        float n = [WH_WeiboCell getHeightByContent:data];
        return n+20;
    }
    return 0;
}

#pragma -mark 回调方法
- (void)urlTouch:(NSNotification *)notification{
    self.actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_OpenUrl")]];
    self.actionVC.delegate = self;
    self.actionVC.wh_tag = 105;
    NSMutableString *str = notification.object;
    if ([str rangeOfString:@"http"].location == NSNotFound) {
        self.urlStr = [NSString stringWithFormat:@"http://%@",str];
    }else {
        self.urlStr = [str copy];
    }
    [g_App.window addSubview:self.actionVC.view];
}
- (void)phoneTouch:(NSNotification *)notification{
    
    self.actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_CallPhone")]];
    self.actionVC.delegate = self;
    self.actionVC.wh_tag = 102;
    phoneNumber=notification.object;
    [g_App.window addSubview:self.actionVC.view];
}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (actionSheet.wh_tag==105){
        if(0==index){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
                webVC.wh_isGotoBack= YES;
                webVC.isSend = YES;
                webVC.title = Localized(@"JXEmoji_OpenUrl");
                webVC.url = self.urlStr;
                webVC = [webVC init];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
            });
        }
    }else if (actionSheet.wh_tag==102){
        if(0==index){
            NSString * string=[NSString stringWithFormat:@"tel:%@",phoneNumber];
            if(webView==nil)
                webView=[[WKWebView alloc]initWithFrame:self.view.bounds];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
            webView.hidden=YES;
            [self.view addSubview:webView];
        }
    }else if (actionSheet.wh_tag == 111){
        if (index == 0) {
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            ipc.delegate = self;
            ipc.allowsEditing = YES;
            //选择图片模式
            ipc.modalPresentationStyle = UIModalPresentationCurrentContext;
            if (IS_PAD) {
                UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
                [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }else {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
                [self presentViewController:ipc animated:YES completion:nil];
            }
            
        }else {
            WH_JXCamera_WHVC *vc = [WH_JXCamera_WHVC alloc];
            vc.cameraDelegate = self;
            vc.isPhoto = YES;
            vc = [vc init];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }

    }

}
-(void)coreLabel:(WH_HBCoreLabel*)coreLabel linkClick:(NSString*)linkStr
{
    
}
-(void)coreLabel:(WH_HBCoreLabel *)coreLabel phoneClick:(NSString *)linkStr
{
    self.actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_CallPhone")]];
    self.actionVC.delegate = self;
    self.actionVC.wh_tag = 102;
    phoneNumber=linkStr;
    [g_App.window addSubview:self.actionVC.view];

}
-(void)coreLabel:(WH_HBCoreLabel *)coreLabel mobieClick:(NSString *)linkStr
{
    self.actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JXEmoji_CallPhone"),Localized(@"JX_SendMessage")]];
    self.actionVC.delegate = self;
    self.actionVC.wh_tag = 103;
    phoneNumber=linkStr;
    [g_App.window addSubview:self.actionVC.view];

}



//-(void)footViewBeginLoad:(PageLoadFootView*)footView
//{
//    //    [self loadFromDb:NO];
//}

-(void)loadWeboData:(NSArray*)webos complete:(void(^)())complete formDb:(BOOL)fromDb
{
    //用i循环遍历
    for(int i = 0 ; i < [webos count];i++){
        WeiboData * weibo = [webos objectAtIndex:i];
        weibo.match=nil;
        [weibo setMatch];
        weibo.uploadFailed=NO;
        weibo.linesLimit=YES;
        weibo.imageHeight=[WH_HBShowImageControl WH_heightForFileStr:weibo.smalls];
        weibo.replyHeight=[weibo heightForReply];
        if(weibo.type == weibo_dataType_file) weibo.fileHeight = 90;
        if (weibo.type == weibo_dataType_share) {
            weibo.shareHeight = 70;
        }
    }
    //需要在遍历时改变内容，所以弃用
//    for(WeiboData * weibo in webos){
//        weibo.match=nil;
//        [weibo setMatch];
//        weibo.uploadFailed=NO;
//        weibo.linesLimit=YES;
//        weibo.imageHeight=[WH_HBShowImageControl heightForFileStr:weibo.smalls];
//        weibo.replyHeight=[weibo heightForReply];
//    }
    dispatch_async(dispatch_get_main_queue(), ^{
        refreshCount++;
        [self.tableView reloadData];
        if(complete){
            complete();
        }
    });
}

- (void)loadWeboData:(NSArray *) webos {
    [self loadWeboData:webos complete:nil formDb:NO];
}


#pragma -mark 私有方法

#pragma -mark 事件响应方法

-(void)buildAddMsg{
//    UIButton* btn = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal"
//                                           highlight:nil
//                                              target:self
//                                            selector:@selector(onAddMsg:)];
//    btn.frame = CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 24, JX_SCREEN_TOP - 34, 24, 24);
//    [self.wh_tableHeader addSubview:btn];
    if(IS_SHOW_SEARCH) {
    UIButton *bar_searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-NAV_INSETS-NAV_BTN_SIZE - NAV_BTN_SIZE - 5, JX_SCREEN_TOP - NAV_BTN_SIZE - 8, NAV_BTN_SIZE, NAV_BTN_SIZE)];
    [bar_searchBtn setImage:[UIImage imageNamed:@"白色放大镜"] forState:UIControlStateNormal];
    [bar_searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view_bar addSubview:bar_searchBtn];
    self.bar_searchBtn = bar_searchBtn;
}
    UIButton *publishBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-NAV_INSETS-NAV_BTN_SIZE, JX_SCREEN_TOP - NAV_BTN_SIZE - 8, NAV_BTN_SIZE, NAV_BTN_SIZE)];
    [publishBtn setImage:[UIImage imageNamed:@"newicon_nav_whiteCamera"] forState:UIControlStateNormal];
    [publishBtn addTarget:self action:@selector(onAddMsg:) forControlEvents:UIControlEventTouchUpInside];
    [self.view_bar addSubview:publishBtn];
    self.bar_rightBtn = publishBtn;
    
}
#pragma mark   ---------------发说说------------
- (void)onAddMsg:(UIButton *)btn{
    if (self.wh_menuView) {
        [self.wh_menuView dismissBaseView];
        self.wh_menuView = nil;
    }

    WH_JX_SelectMenuView *menuView = [[WH_JX_SelectMenuView alloc] initWithTitle:@[
//                                                                             Localized(@"JX_SendWord"),
                                                                             Localized(@"JX_SendImage"),
                                                                             Localized(@"JX_SendVoice"),
                                                                             Localized(@"JX_SendVideo"),
                                                                             Localized(@"JX_SendFile"),
                                                                             Localized(@"JX_NewCommentAndPraise")]
                                                                     image:@[]
                                                                cellHeight:45];
    menuView.delegate = self;
    [g_App.window addSubview:menuView];
}
- (void)searchAction:(UIButton *)button {
    WH_WeiboSearchViewController *searchVC = [[WH_WeiboSearchViewController alloc] init];
    searchVC.isFrom = 1;
    [g_navigation pushViewController:searchVC animated:YES];
}
- (void)didMenuView:(WH_JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:{
            addMsgVC* vc = [[addMsgVC alloc] init];
            //在发布信息后调用，并使其刷新
            vc.block = ^{
                [self WH_scrollToPageUp];
            };
            vc.dataType = (int)index + 2;
            vc.delegate = self;
            vc.didSelect = @selector(hideKeyShowAlert);
            //        [g_window addSubview:vc.view];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            [g_navigation pushViewController:vc animated:YES];
            vc.view.hidden = NO;
        }
            break;
        case 4:{
            
            JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
            vc.wh_remindArray = self.remindArray;
            vc.wh_isShowAll = YES;
            //        [g_window addSubview:vc.view];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            [g_navigation pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void) moreListActionWithIndex:(NSInteger)index {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = touches.anyObject;
    if (_selectView == nil) {
        return;
    }
    CGPoint location = [touch locationInView:_selectView];
    //不在选择范围内
    if (location.x < 0 || location.x > JX_SCREEN_WIDTH/2 || location.y < 7) {
        [self viewDisMissAction];
        return;
    }
    int num = (location.y - TopHeight)/CellHeight;
    if (num >= 0 && num < 4) {
        addMsgVC* vc = [[addMsgVC alloc] init];
        //在发布信息后调用，并使其刷新
        vc.block = ^{
            [self WH_scrollToPageUp];
        };
        vc.dataType = num+1;
        vc.delegate = self;
        vc.didSelect = @selector(hideKeyShowAlert);
//        [g_window addSubview:vc.view];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [g_navigation pushViewController:vc animated:YES];
        vc.view.hidden = NO;
    }
    if (num == 4) {
        JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
        vc.wh_remindArray = self.remindArray;
        vc.wh_isShowAll = YES;
//        [g_window addSubview:vc.view];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [g_navigation pushViewController:vc animated:YES];
    }
    
    [self viewDisMissAction];

}

- (void)viewDisMissAction{
    [UIView animateWithDuration:0.4 animations:^{
        _bgBlackAlpha.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_selectView removeFromSuperview];
        _selectView = nil;
        [_bgBlackAlpha removeFromSuperview];
    }];
}

//单独加在weiboview上，弃用
- (void) hideKeyShowAlert
{
    [self doHideKeyboard];
    
    
}


- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self doHideMenu];
    [self doHideKeyboard];
}

- (void)tapHide:(UITapGestureRecognizer *)tap{
    [self doHideMenu];
    [self doHideKeyboard];
}

//创建回复keyBoard上的回复小黑条
-(void)buildInput{
    self.clearBackGround = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    
    UITapGestureRecognizer * tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHide:)];
    
    [self.clearBackGround addGestureRecognizer:tapG];
    
    _inputParent = [[UIView alloc]initWithFrame:CGRectMake(0, 200, JX_SCREEN_WIDTH, 30)];
    _inputParent.backgroundColor  = [UIColor whiteColor];
    [self.view addSubview:self.clearBackGround];
    [self.clearBackGround addSubview:_inputParent];
    // 配置自适应
    _inputParent.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.clearBackGround.hidden = YES;
    _inputParent.opaque = YES;
    _inputParent.hidden = YES;
    
    _input=[[JXTextView alloc]initWithFrame:CGRectMake(5, 0, JX_SCREEN_WIDTH -10 , 30)];
    _input.wh_target = self;
//    _input.delegate = self;
    _input.didTouch = @selector(onInputText:);
    _input.backgroundColor = [UIColor whiteColor];
    _input.layer.borderWidth = 0.5f;
    _input.layer.borderColor = HEXCOLOR(0xe6e6e7).CGColor;
    _input.wh_placeHolder = Localized(@"JXAlert_InputSomething");
    [_inputParent addSubview:_input];
}

-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    //    return;
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    deltaY=-endRect.size.height;
    
//    NSLog(@"deltaY:%f",deltaY);
    
//    [_table setFrame:CGRectMake(0, JX_SCREEN_HEIGHT+deltaY-_table.frame.size.height, _table.frame.size.width, _table.frame.size.height)];
    [_inputParent setFrame:CGRectMake(0, JX_SCREEN_HEIGHT+deltaY-_inputParent.frame.size.height, _inputParent.frame.size.width, _inputParent.frame.size.height)];
}

-(void)doHideKeyboard{
    [_input resignFirstResponder];
    _table.frame =CGRectMake(0,self.wh_heightHeader,self_width,JX_SCREEN_HEIGHT-self.wh_heightHeader-self.wh_heightFooter);
    _inputParent.frame = CGRectMake(0,JX_SCREEN_HEIGHT-30,self_width,30);
    _inputParent.hidden = YES;
    self.clearBackGround.hidden = YES;
}

-(void)setupTableViewHeight:(CGFloat)height tag:(NSInteger)tag{
    _table.contentSize = CGSizeMake(_table.contentSize.width, _table.contentSize.height+height);
    [_table WH_reloadRow:(int)tag section:0];
}


-(IBAction)deleteAction:(id)sender
{
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:Localized(@"JX_DeleteShare")
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:Localized(@"JX_Cencal")
                                        otherButtonTitles:Localized(@"JX_Confirm"), nil];
    alert.tag=222;
    [alert show];
}
//发送回复
-(void)onInputText:(NSString*)s{
    _input.text = nil;
    [self doHideKeyboard];
    
    wh_replyDataTemp.messageId = wh_selectWeiboData.messageId;
    wh_replyDataTemp.body      = s;
    wh_replyDataTemp.userId    = MY_USER_ID;
    wh_replyDataTemp.userNickName    = g_myself.userNickname;
    
    [[JXServer sharedServer] WH_addCommentWithData:wh_replyDataTemp toView:self];
}

-(void)delBtnAction:(WeiboData *)cellData{
    wh_selectWeiboData = cellData;
    NSUInteger index = [_datas indexOfObject:cellData];
    if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        wh_selectWH_WeiboCell = [_table cellForRowAtIndexPath:indexPath];
    }
    
    if (self.isCollection) {
        
        [g_server WH_userEmojiDeleteWithId:wh_selectWeiboData.objectId toView:self];
    }else {
        [self deleteAction];
    }
}

- (void)fileAction:(WeiboData *)cellData {
    ObjUrlData * obj= [cellData.files firstObject];
    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
    webVC.wh_isGotoBack= YES;
    webVC.isSend = YES;
    if (obj.name.length > 0) {
        webVC.titleString = obj.name;
    }else {
        webVC.titleString = [obj.url lastPathComponent];
    }
    webVC.url = obj.url;
    webVC = [webVC init];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [g_navigation.navigationView addSubview:webVC.view];
//    [g_navigation pushViewController:webVC animated:YES];
}

//#pragma mark - 点赞、评论控件 delegate
//- (void)didMenuView:(JXMenuView *)menuView WithButtonIndex:(NSInteger)index {
//    self.menuView = nil;
//    if (index == 0) {
//        if (!selectWeiboData.isPraise) {
//            [self praiseAddAction];
//        } else {
//            [self praiseDelAction];
//        }
//    }else if (index == 1) {
//        [self commentAction];
//    }else if (index == 2) {
//        if ([selectWeiboData.userId isEqualToString:MY_USER_ID]) {
//            [self deleteAction];
//        }else {
//            [self reportUserView];
//        }
//    }
//}

#pragma mark - 点赞、评论控件创建
-(void)btnReplyAction:(UIButton *)sender WithCell:(WH_WeiboCell *)cell {
//    if (self.menuView) {
//        [self.menuView dismissBaseView];
//        if (cell == _lastCell) {
//            self.lastCell = nil;
//            return;
//        }
//    }
    self.lastCell = cell;
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
    wh_selectWH_WeiboCell = [_table cellForRowAtIndexPath:indexPath];
    wh_selectWeiboData = [_datas objectAtIndex:cell.tag];
    
//    BOOL isDelete = [selectWeiboData.userId isEqualToString:MY_USER_ID];
//    NSArray *strArr = @[selectWeiboData.isPraise ? Localized(@"JX_Cencal") : Localized(@"JX_Good"),Localized(@"JX_Comment"),isDelete ? Localized(@"JX_Delete") : Localized(@"WaHu_JXUserInfo_WHVC_Report")];
//    NSArray *imgArr = @[@"blog_giveLike",@"blog_comments",isDelete ? @"blog_delete" : @"blog_report"];
//
//    CGPoint point = cell.replyContent.frame.origin;
//    CGFloat y = point.y-5;
//
//
//    self.menuView = [[JXMenuView alloc] initWithPoint:CGPointMake(0, y) Title:strArr Images:imgArr];
//    self.menuView.delegate = self;
//    [cell addSubview:self.menuView];
    NSInteger btnTag = sender.tag % 1000;
    if (btnTag == 1) {  // 点赞
        if (!wh_selectWeiboData.isPraise) {
            [self praiseAddAction];
        } else {
            [self praiseDelAction];
        }
    }else if(btnTag == 2) { // 评论
        if (cell.weibo.isAllowComment == 0) {
            [self commentAction];
        }else {
            [g_server showMsg:Localized(@"JX_NotComments") delay:.5];
        }
    }else if(btnTag == 3) { // 收藏
        [self collectionWeibo];
    }else if(btnTag == 4){  // 举报
        [self reportUserView];
    }else if(btnTag == 5){  // 显示更多
        CGRect rect = [sender convertRect:sender.bounds toView:[UIApplication sharedApplication].keyWindow];
        NSMutableArray *tempArr = [NSMutableArray array];
        if (!wh_selectWeiboData.isPraise) {//没赞过
            [tempArr addObject:@{
                                 @"icon":@"newicon_friendCircle_praise"
                                 }];
        }else{
            [tempArr addObject:@{
                                 @"icon":@"newicon_friendCircle_praise_sel"
                                 }];
        }
        
        
        
        if (cell.weibo.isAllowComment == 0) {
            [tempArr addObject:@{
                                 @"icon":@"newicon_friendCircle_comment"
                                 }];
        }else {
            [g_server showMsg:Localized(@"JX_NotComments") delay:.5];
        }
        
        if (wh_selectWeiboData.isCollect) {
            [tempArr addObject:@{
                                 @"icon":@"newicon_friendCircle_collection_sel"
                                 }];
        }else{
            [tempArr addObject:@{
                                 @"icon":@"newicon_friendCircle_collection_nor"//newicon_friendCircle_collection_sel
                                 }];
        }
        
        
        if ([wh_selectWeiboData.userId isEqualToString:MY_USER_ID]) {
            
        }else {
            [tempArr addObject:@{
                                 @"icon":@"newicon_friendCircle_jubao"
                                 }];
        }
        
        
        
        _popupView = [[WWPopupView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y-10, 160, 37) items:tempArr arrowDirection:WBArrowDirectionRight2];
        
        _popupView.tag = 91;
        _popupView.delegate = self;
        [_popupView popup];
    }
    
    
}

#pragma mark - 更多点击按钮事件
- (void)popupView:(WWPopupView *)popupView didSelectedItemAtIndex:(NSInteger)index userName:(NSString *)userName text:(NSString *)text feedId:(NSString *)feedId commentId:(NSString *)commentId btn:(UIButton *)btn cell:(WH_WeiboCell *)weiboCell
{
    [_popupView dismiss];
    if (popupView.tag == 91) {
        
        switch (index) {
            case 0:
            {
                if (!wh_selectWeiboData.isPraise) {
                    [self praiseAddAction];
                } else {
                    [self praiseDelAction];
                }
            }
                break;
            case 1:
            {
                if (weiboCell.weibo.isAllowComment == 0) {
                    [self commentAction];
                }else {
                    [g_server showMsg:Localized(@"JX_NotComments") delay:.5];
                }
            }
                break;
            case 2:
            {
                [self collectionWeibo];
            }
                break;
            case 3:
            {
                [self reportUserView];
            }
                break;
                
            default:
                break;
        }
        
    }
}

- (void)collectionWeibo {
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    WeiboData * weibo = [_datas objectAtIndex:self.lastCell.tag];
    
    if (weibo.isCollect) { // 如果已被收藏,则取消收藏
        [g_server WH_userPengYouQunEmojiDeleteWithId:weibo.messageId toView:self];
    }else {
        ObjUrlData *data;
        NSString *msg;
        if (weibo.images.count > 0 || weibo.videos.count > 0) { // 图片或者视频都会进
            if (weibo.videos.count > 0) { // 如果是视频
                data = [weibo.videos firstObject];
                msg = data.url;
                weibo.type = 2;
            }else {  // 只是图片
                NSMutableArray *imgArr = [NSMutableArray array];
                for (NSDictionary *dict in weibo.images) {
                    NSString *imgUrl = [dict objectForKey:@"oUrl"];
                    [imgArr addObject:imgUrl];
                }
                if (imgArr.count > 1) {
                    msg = [imgArr componentsJoinedByString:@","];
                }else {
                    msg = [imgArr firstObject];
                }
                weibo.type = 1;
            }
        }else if (weibo.audios.count > 0) {
            data = [weibo.audios firstObject];
            msg = data.url;
            weibo.type = 4;
        }else if (weibo.files.count > 0){
            data = [weibo.files firstObject];
            msg = data.url;
            weibo.type = 3;
        }else if (weibo.videos.count > 0){
            // 视频放在图片中做处理
        }else { // 纯文本
            weibo.type = 5;
            msg = weibo.content;
        }

        [dataDict setValue:msg forKey:@"msg"];
        [dataDict setValue:@(weibo.type) forKey:@"type"];
        [dataDict setValue:data.name forKey:@"fileName"];
        [dataDict setValue:data.fileSize forKey:@"fileSize"];
        [dataDict setValue:data.timeLen forKey:@"fileLength"];
        [dataDict setValue:weibo.content forKey:@"collectContent"];
        [dataDict setValue:weibo.messageId forKey:@"collectMsgId"];
        [dataDict setValue:@1 forKey:@"collectType"];
        
        NSMutableArray * emoji = [NSMutableArray array];
        [emoji addObject:dataDict];
        [g_server WH_addFavoriteWithEmoji:emoji toView:self];
    }
}

-(void)reportUserView{
    WH_JXReportUser_WHVC * reportVC = [[WH_JXReportUser_WHVC alloc] init];
    reportVC.user = self.user;
    reportVC.delegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [g_navigation pushViewController:reportVC animated:YES];
    
}

- (void)report:(WH_JXUserObject *)reportUser reasonId:(NSNumber *)reasonId {
    [g_server WH_reportUserWithToUserId:wh_selectWeiboData.userId roomId:nil webUrl:nil reasonId:reasonId toView:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
        if (action == @selector(allCommentAction) ||
            action == @selector(commentAction) ||
            action == @selector(giftAction) ||
            action == @selector(forwardAction) ||
            action == @selector(deleteAction) ||
            (action == @selector(praiseAddAction) && !wh_selectWeiboData.isPraise) ||
            (action == @selector(praiseDelAction) &&  wh_selectWeiboData.isPraise) || action == @selector(reportUserView))
            return YES;
        else
            return NO;
}

-(void)delAndReplyAction
{
    
}

-(void)allCommentAction{
    
}

-(void)WH_doShowAddMyCustomComment:(NSString*)s{
    _input.wh_placeHolder = s;
    self.clearBackGround.hidden = NO;
    _inputParent.hidden = NO;
    [_input becomeFirstResponder];
}

-(void)commentAction{
    wh_replyDataTemp.toUserId  = nil;
    wh_replyDataTemp.toNickName  = nil;
    [self WH_doShowAddMyCustomComment:nil];
}

-(void)praiseAddAction{
    if(!wh_selectWeiboData.isPraise)
        [[JXServer sharedServer] WH_addPraiseWithMsgId:wh_selectWeiboData.messageId toView:self];
}

-(void)praiseDelAction{
    if(wh_selectWeiboData.isPraise)
        [[JXServer sharedServer] WH_delPraiseWithMsgId:wh_selectWeiboData.messageId toView:self];
}

-(void)giftAction{
    return;

}

-(void)forwardAction{
    
}
//删除说说
-(void)deleteAction{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_IsDeletionConfirmed") message:nil delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        if (alertView.tag == 2457) {
            
            [self.delegate weiboVC:self didSelectWithData:_currentData];
            [self actionQuit];
        }else {
            
            NSInteger i = [_datas indexOfObject:wh_selectWeiboData];
            WH_WeiboCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.wh_audioPlayer != nil) {
                [cell.wh_audioPlayer wh_stop];
                cell.wh_audioPlayer = nil;
            }
            
            if (cell.wh_videoPlayer != nil) {
                [cell.wh_videoPlayer stop];
                cell.wh_videoPlayer = nil;
            }
            [g_server WH_deleteMessageWithMsgId:wh_selectWeiboData.messageId toView:self];
        }
        
    }
}

//顶部大头照
-(void)createTableHeadShowRemind{
 
    if (self.isDetail) {
        _table.tableHeaderView = nil;
        return;
    }

    [g_mainVC.tb wh_setBadge:g_mainVC.tb.wh_items.count == 5 ? 3 : 2 title:[NSString stringWithFormat:@"%ld",_remindArray.count]];
    
    UIView* head = [[UIView alloc]initWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH,JX_SCREEN_WIDTH+40)];
    head.backgroundColor = [UIColor whiteColor];
    
    //上方大头照
    WH_JXImageView* iv = [[WH_JXImageView alloc]initWithFrame:CGRectMake(0,0, JX_SCREEN_WIDTH,JX_SCREEN_WIDTH)];
    iv.wh_delegate = self;
    iv.didTouch = @selector(actionPhotos);
    iv.wh_changeAlpha = NO;
    iv.backgroundColor = [UIColor lightGrayColor];
    iv.clipsToBounds = YES;
    iv.contentMode = UIViewContentModeScaleAspectFill;
    _topBackImageView = iv;
    [self showTopImage];
//    [g_server WH_getHeadImageLargeWithUserId:user.userId imageView:iv];
    [head addSubview:iv];
    
    
//    if (!self.isDetail && [self.user.userId isEqualToString:MY_USER_ID] && !self.isCollection) {
//        UIButton *btn;
//        // 语音
//        CGFloat btnX = 20;
//        CGFloat btnY = head.frame.size.height-90;
//
//        CGFloat btnWH = ((JX_SCREEN_WIDTH - 86)-20*5)/5;
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(20, btnY, btnWH, btnWH)];
//        [btn setTag:1];
//        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_voice"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
//
//        // 图文
//        btnX += btn.frame.size.width+20;
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
//        [btn setTag:0];
//        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_image"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
//        // 视频
//        btnX += btn.frame.size.width+20;
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
//        [btn setTag:2];
//        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_video"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
//        // 文件
//        btnX += btn.frame.size.width+20;
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
//        [btn setTag:3];
//        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_file"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
//        // 点赞/回复
//        btnX += btn.frame.size.width+20;
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
//        [btn setTag:4];
//        [btn setImage:[UIImage imageNamed:@"weibo_menu_btn_like"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(didMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [head addSubview:btn];
//    }
    
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-80-6,CGRectGetMaxY(iv.frame)-40, 80,80)];
    v.backgroundColor = HEXCOLOR(0xfefefe);
    v.layer.masksToBounds = YES;
    v.layer.cornerRadius = (MainHeadType)?(40.f):(g_factory.headViewCornerRadius);
    v.layer.borderWidth = 4.f;
    v.layer.borderColor = [UIColor whiteColor].CGColor;
    [head addSubview:v];
    
    
    iv = [[WH_JXImageView alloc]initWithFrame:CGRectMake(2,2, 74,74)];
    iv.layer.masksToBounds = YES;
    iv.layer.cornerRadius = (MainHeadType)?(37.f):(g_factory.headViewCornerRadius);
    iv.wh_delegate = self;
    iv.didTouch = @selector(actionUser);
    [g_server WH_getHeadImageSmallWIthUserId:user.userId userName:nil imageView:iv];
    [v addSubview:iv];
    
    UILabel *namelabel = [[UILabel alloc] initWithFrame:CGRectMake(v.frame.origin.x-150-11, v.frame.origin.y, 150, 30)];
    namelabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 17];
    namelabel.textColor = [UIColor whiteColor];
    namelabel.textAlignment = NSTextAlignmentRight;
    [head addSubview:namelabel];
//    namelabel.text =g_myself.userNickname;
    namelabel.text = user.userNickname;
    
    if (self.remindArray.count) {
        head.frame = CGRectMake(head.frame.origin.x, head.frame.origin.y, head.frame.size.width, head.frame.size.height + 100);
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, head.frame.size.height - 50, 140, 38)];
        btn.backgroundColor = HEXCOLOR(0x333333);
        btn.center = CGPointMake(head.frame.size.width / 2, btn.center.y);
        [btn radiusWithAngle:btn.frame.size.height * 0.5];
        [btn addTarget:self action:@selector(remindBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [head addSubview:btn];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 4, 30, 30)];
        JXBlogRemind *br = _remindArray.firstObject;
        [g_server WH_getHeadImageLargeWithUserId:br.fromUserId userName:br.fromUserName imageView:imageView];
        [imageView radiusWithAngle:imageView.frame.size.width * 0.5];
        [btn addSubview:imageView];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10+CGRectGetMaxX(imageView.frame), 0, btn.frame.size.width - CGRectGetMaxX(imageView.frame) - 20, btn.frame.size.height)];
        label.font = sysFontWithSize(16.0);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%ld%@",self.remindArray.count, Localized(@"JX_PieceNewMessage")];
        [btn addSubview:label];
        
//        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.size.width - 20, 7, 15, 15)];
//        arrowImage.image = [UIImage imageNamed:@"arrow_black"];
//        [btn addSubview:arrowImage];
    }
    
    _table.tableHeaderView = head;
}

- (void)didMenuBtn:(UIButton *)button {
    NSInteger index = button.tag;
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:{
            addMsgVC* vc = [[addMsgVC alloc] init];
            //在发布信息后调用，并使其刷新
            vc.block = ^{
                [self WH_scrollToPageUp];
            };
            vc.dataType = (int)index + 2;
            vc.delegate = self;
            vc.didSelect = @selector(hideKeyShowAlert);
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            [g_navigation pushViewController:vc animated:YES];
            vc.view.hidden = NO;
        }
            break;
        case 4:{
            
            JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
            vc.wh_remindArray = self.remindArray;
            vc.wh_isShowAll = YES;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            [g_navigation pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 有新消息事件点击
- (void)remindBtnAction:(UIButton *)btn {
    JXBlogRemindVC *vc = [[JXBlogRemindVC alloc] init];
    vc.wh_remindArray = self.remindArray;
//    [g_window addSubview:vc.view];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [g_navigation pushViewController:vc animated:YES];
    
    [[JXBlogRemind sharedInstance] updateUnread];
    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    [self createTableHeadShowRemind];
//    [self showTopImage];
}

-(void)WH_doRefresh:(NSNotification *)notifacation{
    [self createTableHeadShowRemind];
    [self WH_getServerData];
}
- (void)refreshCurrentView {
   [self WH_getServerData];
}
-(void)actionUser{
//    _userVc = nil;
//    _userVc = [userInfoVC alloc];
//    _userVc.userId = self.user.userId;
//    [_userVc init];
//    [g_window addSubview:_userVc.view];
//    [g_server getUser:self.user.userId toView:self];
    
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = self.user.userId;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [_pool addObject:vc];
}


-(NSString*)getLastMessageId:(NSArray*)objects{
    NSString* lastId = @"";
    if(_page > 0){
        NSInteger n = [objects count]-1;
        if(n>=0){
            WeiboData* p = [objects objectAtIndex:n];
            lastId = p.messageId;
            p = nil;
        }
    }
    return lastId;
}

-(void)doAddPraiseOK{
    BOOL b=YES;
    for(int i=0;i<[wh_selectWeiboData.praises count];i++){
        WeiboReplyData* praise = [wh_selectWeiboData.praises objectAtIndex:i];
        if([praise.userId intValue] == [g_myself.userId intValue]){
            b = NO;
            break;
        }
    }
    
    if(b){
        WeiboReplyData* praise = [[WeiboReplyData alloc]init];
        praise.userId = g_myself.userId;
        praise.userNickName = g_myself.userNickname;
        praise.type = reply_data_praise;
        [self.wh_selectWeiboData.praises insertObject:praise atIndex:0];
        wh_selectWeiboData.replyHeight=[wh_selectWeiboData heightForReply];
    }
    
    wh_selectWeiboData.praiseCount++;
    wh_selectWeiboData.isPraise = YES;
    [self.wh_selectWH_WeiboCell refresh];
    
    
    
//    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
//    msg.timeSend     = [NSDate date];
//    msg.fromUserId   = MY_USER_ID;
//    msg.fromUserName = g_myself.userNickname;
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:selectWeiboData.messageId forKey:@"id"];
//    NSString *url;
//    int type;
//    if (selectWeiboData.images.count > 0) {
//        url = [selectWeiboData.images.firstObject objectForKey:@"oUrl"];
//        type = 1;
//    }
//    if (selectWeiboData.audios.count > 0) {
//        url = selectWeiboData.audios.firstObject;
//        type = 2;
//    }
//    if (selectWeiboData.videos.count > 0) {
//        url = selectWeiboData.videos.firstObject;
//        type = 3;
//    }
//    
//    [dict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
//    if (url.length > 0) {
//        
//        [dict setObject:url forKey:@"url"];
//    }
//    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:&error];
//    
//    NSString *jsonString;
//    if (! jsonData)
//    {
//        NSLog(@"Got an error: %@", error);
//    }else
//    {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//    
//    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
//    
//    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    
//    msg.objectId = jsonString;
//    [g_xmpp sendMessage:msg roomName:nil];
    
}

-(void)doDelPraiseOK{
    for(int i=0;i<[wh_selectWeiboData.praises count];i++){
        WeiboReplyData* praise = [wh_selectWeiboData.praises objectAtIndex:i];
        if([praise.userId intValue] == [g_myself.userId intValue]){
            [wh_selectWeiboData.praises removeObjectAtIndex:i];
            break;
        }
    }
    wh_selectWeiboData.praiseCount--;
    if(wh_selectWeiboData.praiseCount<0)
        wh_selectWeiboData.praiseCount=0;
    wh_selectWeiboData.isPraise = NO;
    wh_selectWeiboData.replyHeight=[wh_selectWeiboData heightForReply];
    [self.wh_selectWH_WeiboCell refresh];
}

-(void)actionPhotos{
    if (![user.userId isEqualToString:MY_USER_ID]) {
        return;
    }
    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JX_ChoosePhoto"),Localized(@"JX_TakePhoto")]];
    actionVC.delegate = self;
    actionVC.wh_tag = 111;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self presentViewController:actionVC animated:NO completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [ImageResize image:[info objectForKey:@"UIImagePickerControllerEditedImage"] fillSize:CGSizeMake(640, 640)];
    
    NSString* filePath = [FileInfo getUUIDFileName:@"jpg"];
    [g_server WH_saveImageToFileWithImage:image file:filePath isOriginal:NO];
    [g_server uploadFile:filePath validTime:@"-1" messageId:nil toView:self];

    _topBackImageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraVC:(WH_JXCamera_WHVC *)vc didFinishWithImage:(UIImage *)image {
    UIImage *camImage = [ImageResize image:image fillSize:CGSizeMake(640, 640)];
    
    NSString* filePath = [FileInfo getUUIDFileName:@"jpg"];
    [g_server WH_saveImageToFileWithImage:camImage file:filePath isOriginal:NO];
    [g_server uploadFile:filePath validTime:@"-1" messageId:nil toView:self];
    
    _topBackImageView.image = camImage;
}

// 滚动tableView  移除点赞、评论控件
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.wh_menuView dismissBaseView];
    self.lastCell = nil;
}
- (void)showTopImage {
    //先加载本地背景
    _topImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info_headImageUrlString"];
    
    if (IsStringNull(_topImageUrl) || _topImageUrl.length == 0) {
        [g_server WH_getHeadImageLargeWithUserId:user.userId userName:user.userNickname imageView:_topBackImageView];
    }else {
        [g_server WH_getImageWithUrl:_topImageUrl imageView:_topBackImageView];
    }
}


@end
