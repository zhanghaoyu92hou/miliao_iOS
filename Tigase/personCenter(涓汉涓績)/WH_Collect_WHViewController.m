//
//  WH_Collect_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/7/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_Collect_WHViewController.h"

#import "WH_HBShowImageControl.h"

#import "WH_Collect_WHTableViewCell.h"
#import "WH_webpage_WHVC.h"

@interface WH_Collect_WHViewController ()<WH_Collect_WHTableViewCellDelegate>

@end

@implementation WH_Collect_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localized(@"JX_Collection");
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
//    [self.wh_tableHeader addSubview:[self createHeadButton]];
    
    self.wh_listArray = [[NSMutableArray alloc] init];
    
    [self createContentView];
//    [self requestCollectData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self createContentView];
//    [self requestCollectData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_wh_videoPlayer) {
        [g_notify postNotificationName:@"CancleVideoPlay_Notification" object:nil];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (UIButton *)createHeadButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(JX_SCREEN_WIDTH - 38, JX_SCREEN_TOP - 36, 28, 28)];
    [btn setImage:[UIImage imageNamed:@"im_003_more_button_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"im_003_more_button_normal"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(headButtonClick) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)requestCollectData {
    [_wait start];
    [g_server WH_userCollectionListWithType:0 pageIndex:0 toView:self];
}

- (void)createContentView {
    self.wh_listTable = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, JX_SCREEN_HEIGHT - JX_SCREEN_TOP) style:UITableViewStylePlain];
    [self.wh_listTable setDelegate:self];
    [self.wh_listTable setDataSource:self];
    [self.wh_listTable setBackgroundColor:g_factory.globalBgColor];
    [self.wh_listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_tableBody addSubview:self.wh_listTable];
    
    [self requestCollectData];
}

#pragma mark ------------------数据成功返回----------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_userEmojiDelete]) {
        [g_server showMsg:Localized(@"JXAlert_DeleteOK") delay:1.3f];
        NSIndexPath * indexPath = [self.wh_listTable indexPathForCell:self.wh_selectWH_CollectCell];
        [self.wh_listArray removeObject:self.wh_selectWeiboData];
        //        [_table deleteRow:(int)indexPath.row section:(int)indexPath.section];
        [self.wh_listTable reloadData];
    }else{
        if (self.page ==0) {
            [self.wh_listArray removeAllObjects];
        }
        NSMutableArray * tempData = [[NSMutableArray alloc] init];
        for (int i=0; i<[array1 count]; i++) {
            NSDictionary* row = [array1 objectAtIndex:i];
            NSString * msgStr = row[@"msg"];
            
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
            [self collectData:weibo WithUrl:url msg:msgStr collectType:collectType fileLength:fileLength fileName:fileName fileSize:fileSize];
            [tempData addObject:weibo];
        }
        if (tempData.count > 0){
            [self.wh_listArray addObjectsFromArray:tempData];
            [self loadCollectData:self.wh_listArray complete:nil formDb:NO];
        }
        [self.wh_listTable reloadData];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.wh_listArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"collectionCell";
    WH_Collect_WHTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[WH_Collect_WHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    cell.contentView.backgroundColor = HEXCOLOR(0xffffff);
    cell.backgroundColor = HEXCOLOR(0xffffff);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = g_factory.cardCornerRadius;
    cell.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cell.layer.borderWidth = g_factory.cardBorderWithd;
    
    if (self.isSend) {
        [cell.wh_delBtn setHidden:YES];
//        cell.contentView.userInteractionEnabled = NO;
    }else {
        [cell.wh_delBtn setHidden:NO];
//        cell.contentView.userInteractionEnabled = YES;
    }
    cell.contentView.userInteractionEnabled = YES;
    
//    if ([self.listArray count] > indexPath.section) {
//            }
    
    WeiboData *data = [self.wh_listArray objectAtIndex:indexPath.section];
    
    cell.wh_weibo = data;

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //依据数据的多少修改cell的高度
    if ([self.wh_listArray count] != 0 && [self.wh_listArray count] > indexPath.section) {
        WeiboData * data=[self.wh_listArray objectAtIndex:indexPath.section];
         if (data.type == weibo_dataType_image) {
             if (data.larges.count > 1) {
                 float n = [self getHeightByContent:data];
                 return n - 40;
             }else{
                  return 135;
             }
         } else if (data.type == weibo_dataType_video) {
             return 135;
         } else {
            float n = [self getHeightByContent:data];
            return (n+20) - 40;
        }
        
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.wh_listTable.frame), 12)];
    [view setBackgroundColor:self.wh_tableBody.backgroundColor];
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectVC:didSelectWithData:)]) {
        WeiboData *data = self.wh_listArray[indexPath.section];
        _wh_currentData = data;
        [g_App showAlert:Localized(@"JXWantSendCollectionMessage") delegate:self tag:2457 onlyConfirm:NO];
    }
}

- (void)WH_WeiboCell:(WH_Collect_WHTableViewCell *)WH_WeiboCell clickVideoWithIndex:(NSInteger)index {
    self.wh_videoIndex = index;
    _wh_videoPlayer = [WH_JXVideoPlayer alloc];
    _wh_videoPlayer.videoFile = [[self.wh_listArray objectAtIndex:index] getMediaURL];
    _wh_videoPlayer.type = JXVideoTypeWeibo;
    _wh_videoPlayer.WH_didVideoPlayEnd = @selector(WH_didVideoPlayEnd);
    _wh_videoPlayer.isShowHide = YES;
    _wh_videoPlayer.delegate = self;
    _wh_videoPlayer = [_wh_videoPlayer initWithParent:self.view];
    [self performSelector:@selector(videoStartPlayer) withObject:self afterDelay:0.2];
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
    [g_navigation.navigationView addSubview:webVC.view];
}

- (void)videoStartPlayer {
    [_wh_videoPlayer wh_switch];
}

-(void)loadCollectData:(NSArray*)webos complete:(void(^)())complete formDb:(BOOL)fromDb
{
    //用i循环遍历
    for(int i = 0 ; i < [webos count];i++){
        WeiboData * weibo = [webos objectAtIndex:i];
        weibo.match=nil;
        [weibo setMatch];
        weibo.uploadFailed=NO;
        weibo.linesLimit=NO;//展示全部内容
        weibo.imageHeight=[WH_HBShowImageControl WH_heightForFileStr:weibo.smalls];
        weibo.replyHeight=[weibo heightForReply];
        if(weibo.type == weibo_dataType_file) weibo.fileHeight = 90;
        if (weibo.type == weibo_dataType_share) {
            weibo.shareHeight = 70;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        refreshCount++;
        [self.wh_listTable reloadData];
        if(complete){
            complete();
        }
    });
}

-(void)collectData:(WeiboData *)weiboData WithUrl:(NSString *)dataUrl msg:(NSString *)msg collectType:(int)collectType fileLength:(NSString *)fileLength fileName:(NSString *)fileName fileSize:(NSString *)fileSize{
    //    weiboData.messageId = msg.messageId;
    weiboData.userId = MY_USER_ID;
    weiboData.userNickName = MY_USER_NAME;
    
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
        url.url= msg;
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
    
    if( ([weiboData.audios count]>0 || [weiboData.videos count]>0) && [weiboData.images count]<=0){//假如没图，则用头像代替
        ObjUrlData * url=[[ObjUrlData alloc]init];
        //        url.url= @"http://www.feizl.com/upload2007/2013_02/130227014423722.jpg";
        url.url= [g_server WH_getHeadImageOUrlWithUserId:MY_USER_ID];
        url.mime=@"image/pic";
        [weiboData.smalls addObject:url];
    }
    
}

#pragma -mark 委托方法
-(void)WH_showImageControlFinishLoad:(WH_HBShowImageControl*)control
{
    CGRect frame=self.wh_imageContent.frame;
    frame.size.height=control.frame.size.height;
    self.wh_imageContent.frame=frame;
}

- (void)collectDelect:(WeiboData *)data {
    self.wh_selectWeiboData = data;
    NSUInteger index = [self.wh_listArray indexOfObject:data];
    if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        _wh_selectWH_CollectCell = [self.wh_listTable cellForRowAtIndexPath:indexPath];
    }
    [g_server WH_userEmojiDeleteWithId:data.objectId toView:self];
}
-(void)delBtnAction:(WeiboData*)cellData {
    NSUInteger index = [self.wh_listArray indexOfObject:cellData];
    if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        _wh_selectWH_CollectCell = [self.wh_listTable cellForRowAtIndexPath:indexPath];
    }
    [g_server WH_userEmojiDeleteWithId:cellData.objectId toView:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == 2457) {
            
            [self.delegate collectVC:self didSelectWithData:_wh_currentData];
            [self actionQuit];
        }
    }
}

- (float)getHeightByContent:(WeiboData*)data
{
    float height;
    if(data.shouldExtend){
        if(data.linesLimit){
            height=data.heightOflimit;
        }else{
            height=data.height;
        }
    }else{
        height=data.height;
    }
    if (data.location.length > 0) {
        height += 15;
    }
    if ([data.replys isKindOfClass:[NSArray class]]&&([data.replys count]>0 || [data.praises count]>0)&&!data.local) {
        
        if (data.audios.count > 0) {
            return data.imageHeight+height+6+data.replyHeight +data.fileHeight + data.shareHeight;
        }
        return 80.0+data.imageHeight+height+6+data.replyHeight +data.fileHeight + data.shareHeight;
    } else  {
        if (data.audios.count > 0) {
            return data.imageHeight+height +data.fileHeight + data.shareHeight;
        }
        return 80.0+data.imageHeight+height +data.fileHeight + data.shareHeight;
    }
}

- (void)headButtonClick {
    
}


- (void)sp_checkNetWorking {
    NSLog(@"Get User Succrss");
}


@end
