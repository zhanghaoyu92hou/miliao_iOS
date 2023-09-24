//
//  WH_JXWeiboDetailViewController.m
//  Tigase
//
//  Created by 政委 on 2020/6/6.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_JXWeiboDetailViewController.h"
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

@interface WH_JXWeiboDetailViewController ()<UIAlertViewDelegate,WH_JXActionSheet_WHVCDelegate,JXSelectMenuViewDelegate,JXMenuViewDelegate,WH_WeiboCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WH_JXCamera_WHVCDelegate,WWPopupDelegate>
{
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

@property (nonatomic, strong)WWPopupView *popupView;


@end

@implementation WH_JXWeiboDetailViewController
@synthesize wh_replyDataTemp,wh_selectWeiboData,wh_deleteWeibo,refreshCount,wh_selectWH_WeiboCell,user;


- (id)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = 0;
        
//        if (self.isDetail) {
//            self.wh_isGotoBack   = YES;
//            self.title = Localized(@"JX_Detail");
//            self.wh_heightHeader = JX_SCREEN_TOP;
//        }
        
//#ifdef IS_SHOW_MENU
//        self.wh_isGotoBack = YES;
//#endif
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self creatNavHeaderView];
        _table.frame =CGRectMake(0, JX_SCREEN_TOP, self_width, JX_SCREEN_HEIGHT- JX_SCREEN_TOP);
        _table.delegate = self;
        _table.dataSource = self;
        [self buildInput];
        //删除评论弹窗
        UIView *delete = [[UIView alloc] initWithFrame:CGRectMake(0, 2 * JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
        delete.backgroundColor = RGBA(0, 0, 0, 0.5);
        UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 250, JX_SCREEN_WIDTH, 260)];
        content.backgroundColor = [UIColor whiteColor];
        content.layer.cornerRadius = 10;
        content.layer.masksToBounds = YES;
        [delete addSubview:content];
        
        UILabel *title = [JXXMPP createLabelWith:@"删除我的评论" frame:CGRectMake(0, 16, delete.width, 30) color:HEXCOLOR(0x8C9AB8) font:18];
        title.textAlignment = NSTextAlignmentCenter;
        [content addSubview:title];
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 62, JX_SCREEN_WIDTH, 1)];
        line1.backgroundColor = HEXCOLOR(0xE8E8E8);
        [content addSubview:line1];
        UIButton *deleteBtn = [JXXMPP createButtonWith:@"删除" frame:CGRectMake(0, 63, JX_SCREEN_WIDTH, 54) color:HEXCOLOR(0xED6350) font:16];
        [deleteBtn addTarget:self action:@selector(deleteCommentAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:deleteBtn];
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, deleteBtn.bottom, JX_SCREEN_WIDTH, 1)];
        line2.backgroundColor = HEXCOLOR(0xE8E8E8);
        [content addSubview:line2];
        UIButton *copyBtn = [JXXMPP createButtonWith:@"复制" frame:CGRectMake(0, deleteBtn.bottom + 1, JX_SCREEN_WIDTH, 54) color:HEXCOLOR(0x8C9AB8) font:16];
        [copyBtn addTarget:self action:@selector(copyAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:copyBtn];
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, copyBtn.bottom, JX_SCREEN_WIDTH, 1)];
        line3.backgroundColor = HEXCOLOR(0xE8E8E8);
        [content addSubview:line3];
        UIButton *cancelBtn = [JXXMPP createButtonWith:@"取消" frame:CGRectMake(0, copyBtn.bottom +1, JX_SCREEN_WIDTH, 54) color:HEXCOLOR(0x8C9AB8) font:16];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:cancelBtn];
        
        [self.view addSubview:delete];
        self.deleteView = delete;
        wh_replyDataTemp = [[WeiboReplyData alloc]init];
        [g_notify addObserver:self selector:@selector(urlTouch:) name:kCellTouchUrl_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(phoneTouch:) name:kCellTouchPhone_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(didEnterBackground:) name:kApplicationDidEnterBackground object:nil];
        //取消解压缩下载图片
        [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    }
    return self;
}

- (void)creatNavHeaderView
{
    //添加顶部自定义导航条
    UIView *customHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self_width, JX_SCREEN_TOP)];
    customHeadView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:customHeadView];
//    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self_width, JX_SCREEN_TOP)];
//    iv.image = [UIImage imageNamed:@"newicon_nav_shawder"];
//    [customHeadView addSubview:iv];
//    self.bar_bgImageV = iv;
    
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, self_width-40*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = g_factory.navigatorTitleColor;
    p.font = g_factory.navigatorTitleFont;
    p.text = @"动态详情";
    [customHeadView addSubview:p];
    
    
    UIButton *back = [JXXMPP createButtonWithFrame:CGRectMake(10, JX_SCREEN_TOP - 38, 28, 28) image:[UIImage imageNamed:@"title_back"]];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [customHeadView addSubview:back];    
}
- (void)backAction {
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
}
-(void)dealloc{
    [g_notify removeObserver:self name:kUpdateUser_WHNotifaction object:nil];
    [g_notify removeObserver:self name:kCellTouchUrl_WHNotifaction object:nil];
    [g_notify removeObserver:self name:kXMPPMessageWeiboRemind_WHNotification object:nil];
    [g_notify removeObserver:self name:kApplicationDidEnterBackground object:nil];
//    NSLog(@"WeiboViewControlle.dealloc");
    //    [super dealloc];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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

// 进入后台
- (void)didEnterBackground:(NSNotification *)notif {
        WH_WeiboCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell) {
            if (cell.wh_audioPlayer != nil) {
                [cell.wh_audioPlayer wh_stop];
            }
    }
}

-(void)WH_scrollToPageUp{

    [super WH_scrollToPageUp];
}
-(void)WH_scrollToPageDown {
    
}
#pragma mark ------------------数据成功返回----------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
//    [super stopLoading];
    if ([aDownload.action isEqualToString:wh_act_MsgGet]) {
        WeiboData * weibo=[[WeiboData alloc]init];
        [weibo WH_getDataFromDict:dict];
        self.wh_selectWeiboData = weibo;
        [self loadWeboData:@[weibo] complete:nil formDb:NO];
    }
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
        [wh_selectWeiboData.replys insertObject:wh_replyDataTemp atIndex:0];
        wh_selectWeiboData.page = 0;
        wh_selectWeiboData.commentCount += 1;
        wh_selectWeiboData.replyHeight=[wh_selectWeiboData heightForReply];
        if ([wh_selectWeiboData.replys count] != 0) {
            [self.wh_selectWH_WeiboCell refresh];
        }
        [_table reloadData];
        wh_replyDataTemp = [[WeiboReplyData alloc]init];
    }else if ([aDownload.action isEqualToString:wh_act_CommentDel]){
        
        [self.wh_selectWeiboData.replys removeObjectAtIndex:self.replyIndex];

        [self.wh_replyDataTemp setMatch];
        self.wh_selectWeiboData.page = 0;
        self.wh_selectWeiboData.replyHeight=[wh_selectWeiboData heightForReply];
        if ([self.wh_selectWeiboData.replys count] != 0) {
            [self.wh_selectWH_WeiboCell refresh];
        }
        [_table reloadData];
        [self deleteViewHiden];
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
        WeiboData *data = self.wh_selectWeiboData;
        data.isCollect = YES;
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
        [self backAction];
        [g_notify postNotificationName:kWeiboSearchViewRefresh object:nil];
        [g_notify postNotificationName:kRefreshCurrentView object:nil];
    }

    if ([aDownload.action isEqualToString:wh_act_ShengHuoQuanDeleteCollect]) {
        [g_server showMsg:Localized(@"JX_weiboCancelCollect") delay:1.3f];
        self.wh_selectWeiboData.isCollect = NO;
//        [_datas replaceObjectAtIndex:self.lastCell.tag withObject:data];
//        [_table WH_reloadRow:(int)self.lastCell.tag section:0];
    }
    if ([aDownload.action isEqualToString:wh_act_userEmojiDelete]) {
        [g_server showMsg:Localized(@"JXAlert_DeleteOK") delay:1.3f];;
//        [_table deleteRow:(int)indexPath.row section:(int)indexPath.section];
//        [_table reloadData];
    }

    if([aDownload.action isEqualToString:wh_act_PhotoList]){
        if([array1 count]>0){
            [photosViewController showPhotos:array1];
        }else{
            
        }
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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self WH_getServerData];
}
- (void)WH_getServerData {
    [g_server WH_getMessageWithMsgId:self.messageId toView:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
#pragma mark - Table view     --------代理--------     data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *CellIdentifier = [NSString stringWithFormat:@"WH_WeiboCell_%d_%ld",refreshCount,indexPath.row];
    NSString *CellIdentifier = [NSString stringWithFormat:@"WH_WeiboCell"];
    
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
    
    WeiboData * weibo = self.wh_selectWeiboData;
    cell.delegate = self;
    cell.detailController = self;
    cell.wh_tableViewP = tableView;
    cell.tag   = indexPath.row;
    cell.isPraise = weibo.isPraise;
    cell.isCollect = weibo.isCollect;
    cell.weibo = weibo;
    [cell setupData];
    NSLog(@"=============%ld",indexPath.row);
//    float height=[self tableView:tableView heightForRowAtIndexPath:indexPath];
//    UIView * view=[cell.contentView viewWithTag:1200];
//    if(view==nil){
//        UIView* line = [[UIView alloc]init];
//        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
//        line.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
//        [cell.contentView  addSubview:line];
//        line.tag=1200;
//    }else{
//        view.frame=CGRectMake(0, height-1, JX_SCREEN_WIDTH, 0.5);
//    }
    if ([weibo.userId isEqualToString:MY_USER_ID]) {
        
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
    _wh_videoPlayer.videoFile = [self.wh_selectWeiboData getMediaURL];
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
    
    return;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    //依据数据的多少修改cell的高度
    WeiboData * data= self.wh_selectWeiboData;
        float n = [WH_WeiboCell getHeightByContent:data];
        return n+20;
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
    if (webos.count == 0) {
        return;
    }
        WeiboData * weibo = [webos firstObject];
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
        [_table reloadData];
        if(complete){
            complete();
        }
    });
}

- (void)loadWeboData:(NSArray *) webos {
    [self loadWeboData:webos complete:nil formDb:NO];
}
//删除评论
- (void)deleteCommentAction {
    [g_server WH_delCommentWithMsgId:self.wh_selectWeiboData.messageId commentId:self.replyId toView:self];
//    [self deleteViewHiden];
}
//复制
- (void)copyAction {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    for (WeiboReplyData *replyData in self.wh_selectWeiboData.replys) {
        if ([replyData.replyId isEqualToString:self.replyId]) {
            NSLog(@"%@", replyData.match.source);
            NSString *aString = [[replyData.match.source substringToIndex:1] isEqualToString:@":"] ? [replyData.match.source substringFromIndex:1] : replyData.match.source;
            [pasteboard setString:aString];
             [self deleteViewHiden];
            [GKMessageTool showText:@"复制成功"];
        }
    }
    
   
}
//取消
- (void)cancelBtnAction {
    [self deleteViewHiden];
}
//删除评论弹出/收回
- (void)deleteViewShow {
    [UIView animateWithDuration:.2 animations:^{
        self.deleteView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}
- (void)deleteViewHiden{
    [UIView animateWithDuration:.2 animations:^{
        self.deleteView.frame = CGRectMake(0, 2 * JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}
#pragma mark   ---------------发说说------------

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


- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self doHideMenu];
}

- (void)tapHide:(UITapGestureRecognizer *)tap{
    [self doHideMenu];
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
    
    [_inputParent setFrame:CGRectMake(0, JX_SCREEN_HEIGHT+deltaY-_inputParent.frame.size.height, _inputParent.frame.size.width, _inputParent.frame.size.height)];
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
    [_input resignFirstResponder];
    _inputParent.frame = CGRectMake(0,JX_SCREEN_HEIGHT-30,self_width,30);
    _inputParent.hidden = YES;
    self.clearBackGround.hidden = YES;
    wh_replyDataTemp.messageId = wh_selectWeiboData.messageId;
    wh_replyDataTemp.body      = s;
    wh_replyDataTemp.userId    = MY_USER_ID;
    wh_replyDataTemp.userNickName    = g_myself.userNickname;
    
    [[JXServer sharedServer] WH_addCommentWithData:wh_replyDataTemp toView:self];
}

-(void)delBtnAction:(WeiboData *)cellData{
    wh_selectWeiboData = cellData;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        wh_selectWH_WeiboCell = [_table cellForRowAtIndexPath:indexPath];
        [self deleteAction];
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
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    wh_selectWH_WeiboCell = [_table cellForRowAtIndexPath:indexPath];
    wh_selectWeiboData = self.wh_selectWeiboData;
    
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
    WeiboData * weibo = self.wh_selectWeiboData;
    
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
            WH_WeiboCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_input resignFirstResponder];
    _inputParent.frame = CGRectMake(0,JX_SCREEN_HEIGHT-30,self_width,30);
    _inputParent.hidden = YES;
    self.clearBackGround.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
