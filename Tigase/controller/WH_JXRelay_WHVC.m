//
//  WH_JXRelay_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2017/6/27.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXRelay_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXRoomPool.h"
#import "WH_JXRoomObject.h"
#import "WH_JX_WHCell.h"
#import "addMsgVC.h"

typedef enum : NSUInteger {
    RelayType_msg = 1,
    RelayType_myFriend,
    RelayType_myGroup,
} RelayType;

@interface WH_JXRelay_WHVC ()

@property (nonatomic, strong) NSMutableArray *msgArray;
@property (nonatomic, strong) NSMutableArray *myFriendArray;
@property (nonatomic, strong) NSMutableArray *myGroupArray;
@property (nonatomic, assign) RelayType type;
@property (nonatomic, strong) WH_JXRoomObject *chatRoom;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation WH_JXRelay_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM);
    [self WH_createHeadAndFoot];
    
    _msgArray = [NSMutableArray array];
    _myFriendArray = [NSMutableArray array];
    _myGroupArray = [NSMutableArray array];
    
    self.type = RelayType_msg;
    
    [self getLocData];
    
}

- (void) getLocData {
    NSMutableArray* p = [[WH_JXMessageObject sharedInstance] fetchRecentChat];
    //    if (p.count>0 || _page == 0) {
    if (p.count>0) {
        for(NSInteger i = 0; i < p.count; i ++) {
            WH_JXMsgAndUserObject *obj = p[i];
            if ([obj.user.userId isEqualToString:FRIEND_CENTER_USERID]) {
                continue;
            }
            
            [_msgArray addObject:obj];
        }
        //让数组按时间排序
        [self sortArrayWithTime];
        [_table reloadData];
        self.wh_isShowFooterPull = p.count>=PAGE_SHOW_COUNT;
    }
    [p removeAllObjects];
    
    NSMutableArray *array = [[WH_JXUserObject sharedUserInstance] WH_fetchAllFriendsFromLocal];
    for(NSInteger i = 0; i < array.count; i ++) {
        WH_JXUserObject *user = array[i];
        if ([user.userId isEqualToString:FRIEND_CENTER_USERID]) {
            continue;
        }
        WH_JXMsgAndUserObject *obj = [[WH_JXMsgAndUserObject alloc] init];
        obj.user = user;
        
        [_myFriendArray addObject:obj];
    }
    
    [g_server WH_listHisRoomWithPage:0 pageSize:1000 toView:self];
    
    [self.tableView reloadData];
}


//数据（CELL）按时间顺序重新排列
- (void)sortArrayWithTime{
    
    for (int i = 0; i<[_msgArray count]; i++)
    {
        
        for (int j=i+1; j<[_msgArray count]; j++)
        {
            WH_JXMsgAndUserObject * dicta = (WH_JXMsgAndUserObject*) [_msgArray objectAtIndex:i];
            NSDate * a = dicta.message.timeSend ;
            //            NSLog(@"a = %d",[dicta.user.msgsNew intValue]);
            WH_JXMsgAndUserObject * dictb = (WH_JXMsgAndUserObject*) [_msgArray objectAtIndex:j];
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
                
                [_msgArray replaceObjectAtIndex:i withObject:dictb];
                [_msgArray replaceObjectAtIndex:j withObject:dicta];
            }
            
        }
        
    }
    
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type != RelayType_myGroup) {
        if (indexPath.section == 0) {
            UITableViewCell *cell=nil;
            //    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,(long)indexPath.row];
            NSString* cellName = [NSString stringWithFormat:@"tableViewCell"];
            
            cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 53.5, JX_SCREEN_WIDTH, .5)];
            line.backgroundColor = HEXCOLOR(0xf0f0f0);
            [cell.contentView addSubview:line];
            
            cell.textLabel.font = sysFontWithSize(15.0);
            if (self.type == RelayType_msg) {
                cell.textLabel.text = Localized(@"JXRelay_CreateNewChat");
            }else if (self.type == RelayType_myFriend) {
                cell.textLabel.text = Localized(@"JXRelay_chooseGroup");
            }
            
            
            return cell;
        }
    }
    
    if (self.type == RelayType_msg && self.isShare && indexPath.row == 0 && [self shouldShareToLifeCircle]) {
        UITableViewCell *cell=nil;
        NSString* cellName = [NSString stringWithFormat:@"tableViewCell"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 53.5, JX_SCREEN_WIDTH, .5)];
        line.backgroundColor = HEXCOLOR(0xf0f0f0);
        [cell.contentView addSubview:line];
        
        cell.textLabel.font = sysFontWithSize(15.0);
        cell.textLabel.text = Localized(@"JX_ShareLifeCircle");

        return cell;
    }
    
    NSString* cellName = [NSString stringWithFormat:@"relayCell"];
    WH_JX_WHCell *relayCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!relayCell) {
        relayCell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    WH_JXMsgAndUserObject * obj = nil;
    switch (self.type) {
        case RelayType_msg:
            if (self.isShare && [self shouldShareToLifeCircle]) {
                obj = (WH_JXMsgAndUserObject*) [_msgArray objectAtIndex:indexPath.row - 1];
            }else {
                obj = (WH_JXMsgAndUserObject*) [_msgArray objectAtIndex:indexPath.row];
            }
            break;
        case RelayType_myFriend:
            obj = (WH_JXMsgAndUserObject*) [_myFriendArray objectAtIndex:indexPath.row];
            break;
        case RelayType_myGroup:
            obj = (WH_JXMsgAndUserObject*) [_myGroupArray objectAtIndex:indexPath.row];
            break;
            
        default:
            break;
    }
    
    relayCell.title = obj.user.userNickname;
//    relayCell.subtitle = [NSString stringWithFormat:@"%@",obj.user.userId];
    relayCell.userId = [NSString stringWithFormat:@"%@",obj.user.userId];
    NSString * roomIdStr = obj.user.roomId;
    relayCell.roomId = roomIdStr;
    [relayCell WH_headImageViewImageWithUserId:relayCell.userId roomId:roomIdStr];
    relayCell.isSmall = YES;

    return relayCell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.type == RelayType_myGroup) {
        
        return 1;
    }else {
        return 2;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.type == RelayType_myGroup) {
        return _myGroupArray.count;
    }
    
    if (section == 0) {
        
        return 1;
    }else {
        
        switch (self.type) {
            case RelayType_msg:
                if (self.isShare && [self shouldShareToLifeCircle]) {
                    return _msgArray.count + 1;
                }else {
                    return _msgArray.count;
                }
                break;
            case RelayType_myFriend:
                return _myFriendArray.count;
                break;
            case RelayType_myGroup:
                return _myGroupArray.count;
                break;
            default:
                return 0;
                break;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        switch (self.type) {
            case RelayType_msg:{
                    self.type = RelayType_myFriend;
                }
                break;
            case RelayType_myFriend:{
                    self.type = RelayType_myGroup;
                }
                break;
            case RelayType_myGroup:{
                WH_JXMsgAndUserObject *obj = _myGroupArray[indexPath.row];
                
                self.selectIndex = indexPath.row;
                [g_server getRoom:obj.user.roomId toView:self];
            }
                break;
            default:
                break;
        }
        [self.tableView reloadData];
    }else {
        
        if (self.type == RelayType_msg && self.isShare && indexPath.row == 0 &&  [self shouldShareToLifeCircle]) {//分享到朋友圈
            
            WH_JXMessageObject *msg = self.relayMsgArray.lastObject;
            NSDictionary * msgDict = [msg.objectId mj_JSONObject];
            
            addMsgVC* vc = [[addMsgVC alloc] init];
            //在发布信息后调用，并使其刷新
            vc.block = ^{
//                [self WH_scrollToPageUp];
            };
            if (self.isSDKShare) {
                [self handleBLNShareUrl:vc];
            }else {
                vc.wh_shareUr = [msgDict objectForKey:@"url"];
                vc.wh_shareTitle = [msgDict objectForKey:@"title"];
                vc.wh_shareIcon = [msgDict objectForKey:@"imageUrl"];
                vc.dataType = weibo_dataType_share;
                vc.delegate = self;
            }
            [g_navigation pushViewController:vc animated:YES];
            vc.view.hidden = NO;
            
            [self actionQuit];
            
            return;
        }
        
        
        NSMutableArray *array = [NSMutableArray array];
        switch (self.type) {
            case RelayType_msg:
                array = _msgArray;
                break;
            case RelayType_myFriend:
                array = _myFriendArray;
                break;
            case RelayType_myGroup:
                array = _myGroupArray;
                
                break;
            default:
                break;
        }
        WH_JXMsgAndUserObject *p;
        if (self.type == RelayType_msg && self.isShare && [self shouldShareToLifeCircle]) {
            p = [array objectAtIndex:indexPath.row - 1];
        }else {
            p =[array objectAtIndex:indexPath.row];
        }
        p.user.msgsNew = [NSNumber numberWithInt:0];
        [p.user update];
        [p.message WH_updateNewMsgsTo0];
        
        
        if ([p.user.roomFlag boolValue]) {
            
            self.selectIndex = indexPath.row;
            [g_server getRoom:p.user.roomId toView:self];
            return;
        }
        
        
        if (self.isCourse) {
            if([p.user.roomFlag boolValue]) {
                self.selectIndex = indexPath.row;
                [g_server getRoom:p.user.roomId toView:self];
            }else {
                if ([self.relayDelegate respondsToSelector:@selector(relay:MsgAndUserObject:)]) {
                    [self.relayDelegate relay:self MsgAndUserObject:p];
                    
                    [self actionQuit];
                }
            }
            
            return;
        }
        
        [self sendRelayMsg:p];
    }
    
}
#pragma mark ----- 数据处理
- (BOOL)shouldShareToLifeCircle {
    NSDictionary *infoDic = [self getBlnShareUrlDic];
    if (self.isSDKShare && [infoDic[@"type"] integerValue] == 7) {
        return NO;
    }
    return YES;
}
- (NSDictionary *)getBlnShareUrlDic {
    NSString *urlString = self.shareUrl.absoluteString.stringByRemovingPercentEncoding;
    NSRange range = [urlString rangeOfString:@"BLN/"];
    if (range.location != NSNotFound) {
        NSString *contentString = [urlString substringFromIndex:(range.location + range.length)];
        NSDictionary *infoDic = [contentString.stringByRemovingPercentEncoding mj_JSONObject];
        return infoDic;
    }
    return nil;
}

- (void)handleBLNShareUrl:(addMsgVC *)msgVC {
    NSDictionary *infoDic = [self getBlnShareUrlDic];
    if (infoDic == nil) {
        return;
    }
    NSInteger type = [infoDic[@"type"] integerValue];
    //        vc.shareTitle = [msgDict objectForKey:@"title"];
    //        vc.shareIcon = [msgDict objectForKey:@"imageUrl"];
    if (type == 2) {//分享文字时需要将类型设置为图文分享
        msgVC.wh_urlShare = infoDic[@"content"];
        msgVC.dataType = weibo_dataType_image;
    }else if (type == 3) {//image
        msgVC.wh_shareUr = infoDic[@"content"];
        msgVC.dataType = weibo_dataType_image;
    }else if (type == 4) {//Link
        NSDictionary *linkDic = [infoDic[@"content"] mj_JSONObject];
        msgVC.wh_urlShare = linkDic[@"url"];
        msgVC.wh_shareIcon = linkDic[@"img"];
        msgVC.wh_shareTitle = linkDic[@"title"];
        msgVC.dataType = weibo_dataType_share;
    }else  if (type == 5) {//audio
        msgVC.wh_audioFile = infoDic[@"content"];
        msgVC.dataType = weibo_dataType_audio;
    }else  if (type == 6) {//video
        msgVC.wh_shareUr = infoDic[@"content"];
        msgVC.dataType = weibo_dataType_video;
    }else  if (type == 7) {//file
        msgVC.wh_shareUr = infoDic[@"content"];
        msgVC.dataType = weibo_dataType_file;
    }
    msgVC.delegate = self;
}
- (void)sendRelayMsg:(WH_JXMsgAndUserObject *)p {
    
    [g_notify postNotificationName:kActionRelayQuitVC_WHNotification object:nil];
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    sendView.title = p.user.userNickname;
    if([p.user.roomFlag intValue] > 0  || p.user.roomId.length > 0){
        if(g_xmpp.isLogined != 1){
            // 掉线后点击title重连
            [g_xmpp showXmppOfflineAlert];
            return;
        }
        
        
        if ([p.user.groupStatus intValue] == 1) {
            [g_server showMsg:Localized(@"JX_OutOfTheGroup1")];
            return;
        }
        
        if ([p.user.groupStatus intValue] == 2) {
            [g_server showMsg:Localized(@"JX_DissolutionGroup1")];
            return;
        }
        sendView.roomJid = p.user.userId;
        sendView.roomId   = p.user.roomId;
        sendView.chatRoom  = [[JXXMPP sharedInstance].roomPool joinRoom:p.user.userId title:p.user.userNickname isNew:NO];
        
        if (p.user.roomFlag) {
            NSDictionary * groupDict = [p.user toDictionary];
            WH_RoomData * roomdata = [[WH_RoomData alloc] init];
            [roomdata WH_getDataFromDict:groupDict];
            sendView.room = roomdata;
        }
    }
    sendView.isShare = self.isShare;
    sendView.shareSchemes = self.shareSchemes;
    sendView.shareUrl = self.shareUrl;
    sendView.chatPerson = p.user;
    sendView = [sendView init];
    //        [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.relayMsgArray = self.relayMsgArray;
    sendView.view.hidden = NO;
    
    [self actionQuit];
}

-(void)showChatView:(NSInteger)index{
    [_wait stop];
    WH_JXMsgAndUserObject *obj = _myGroupArray[index];
    
    if (self.isCourse) {
        self.selectIndex = index;
        [g_server getRoom:obj.user.roomId toView:self];
        return;
    }
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    sendView.title = obj.user.userNickname;
    sendView.roomJid = obj.user.userId;
    sendView.roomId = obj.user.roomId;
    sendView.chatRoom = _chatRoom;
    sendView.chatPerson = obj.user;
    
    sendView = [sendView init];
//    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.relayMsgArray = self.relayMsgArray;
    
    [self actionQuit];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    [self WH_stopLoading];
    if([aDownload.action isEqualToString:wh_act_roomListHis] ){
        [_myGroupArray removeAllObjects];
        for (int i = 0; i < [array1 count]; i++) {
            NSDictionary *dict=array1[i];
            
            WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
            user.userNickname = [dict objectForKey:@"name"];
            user.userId = [dict objectForKey:@"jid"];
            user.userDescription = [dict objectForKey:@"desc"];
            user.roomId = [dict objectForKey:@"id"];
            
            WH_JXMsgAndUserObject *obj = [[WH_JXMsgAndUserObject alloc] init];
            obj.user = user;
            [_myGroupArray addObject:obj];
            
        }
        
    }
    if( [aDownload.action isEqualToString:wh_act_roomGet] ){
        
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        NSDictionary * groupDict = [user toDictionary];
        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
        [roomdata WH_getDataFromDict:groupDict];
        
        [roomdata WH_getDataFromDict:dict];
        
        memberData *data = [roomdata getMember:g_myself.userId];
        if ([user.talkTime longLongValue] > 0 && !([data.role integerValue] == 1 || [data.role integerValue] == 2)) {
            
            [g_App showAlert:Localized(@"HAS_BEEN_BANNED")];
            return;
        }
        
        if (!roomdata.allowSpeakCourse && !([data.role integerValue] == 1 || [data.role integerValue] == 2)) {
            
            [g_App showAlert:Localized(@"JX_SendLecture")];
            return;
        }
        
        if (!roomdata.allowSendCard && !([data.role integerValue] == 1 || [data.role integerValue] == 2)) {
            
            [g_App showAlert:Localized(@"JX_DisabledShowCard")];
            return;
        }
        NSMutableArray *array = [NSMutableArray array];
        switch (self.type) {
            case RelayType_msg:
                array = _msgArray;
                break;
            case RelayType_myFriend:
                array = _myFriendArray;
                break;
            case RelayType_myGroup:
                array = _myGroupArray;
                
                break;
            default:
                break;
        }
        WH_JXMsgAndUserObject *p=[array objectAtIndex:self.selectIndex];
        
        if (self.isCourse) {
            if ([data.role integerValue] == 1 || [data.role integerValue] == 2 || roomdata.allowSpeakCourse) {
                if ([user.talkTime longLongValue] > 0) {
                    
                    [g_App showAlert:Localized(@"HAS_BEEN_BANNED")];
                    return;
                }
                if ([self.relayDelegate respondsToSelector:@selector(relay:MsgAndUserObject:)]) {
                    
                    
                    
                    [self.relayDelegate relay:self MsgAndUserObject:p];
                    
                    [self actionQuit];
                }
                return;
            }
            [g_App showAlert:Localized(@"JX_SendLecture")];
        }else {
            [self sendRelayMsg:p];
        }
        
        
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

- (void)actionQuit {
    if (self.isShare) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.isUrl) {
        [self.view removeFromSuperview];
    }
    else {
        [super actionQuit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_getLoginState:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
