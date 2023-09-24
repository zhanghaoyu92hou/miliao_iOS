//
//  WH_JXNewFriend_WHViewController.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXNewFriend_WHViewController.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "WH_JXFriend_WHCell.h"
#import "WH_JXRoomPool.h"
#import "WH_JXFriendObject.h"
#import "UIFactory.h"
#import "WH_JXInput_WHVC.h"
#import "WH_JXUserInfo_WHVC.h"

@interface WH_JXNewFriend_WHViewController ()<WH_JXFriend_WHCellDelegate>

@end

@implementation WH_JXNewFriend_WHViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack   = YES;
        self.title = Localized(@"JXNewFriendVC_NewFirend");
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self WH_createHeadAndFoot];
        [self customView];
        self.wh_isShowFooterPull = NO;

        [g_notify addObserver:self selector:@selector(newRequest:) name:kXMPPNewRequest_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(WH_onSendTimeout:) name:kXMPPSendTimeOut_WHNotifaction object:nil];

        poolCell = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)customView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 44.f)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //搜索条
    [self createSeekTextField:headerView isFriend:NO];
    
    [self.view addSubview:headerView];
    self.tableView.tableHeaderView = headerView;
    
    _table.backgroundColor = g_factory.globalBgColor;
}

- (void)dealloc {
//    NSLog(@"WH_JXNewFriend_WHViewController.dealloc");
//    [super dealloc];
}

-(void)free{
    current_chat_userId = nil;
    [_array removeAllObjects];
//    [_array release];
    [poolCell removeAllObjects];
//    [poolCell release];
    
    [g_notify  removeObserver:self name:kXMPPNewRequest_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPSendTimeOut_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kXMPPReceipt_WHNotifaction object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _array   = [[NSMutableArray alloc]init];
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.seekTextField.text.length > 0) {
        return self.searchArray.count;
    }
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WH_JXFriend_WHCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
        WH_JXFriendObject *user = self.seekTextField.text.length > 0 ? self.searchArray[indexPath.row] : _array[indexPath.row];
        cell = [WH_JXFriend_WHCell alloc];
        [_table WH_addToPool:cell];
        cell.tag   = indexPath.row;
        cell.delegate = self;
        cell.subtitle = user.userId;
        cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
        cell.user        = user;
        cell.target      = self;
        cell.status = @"已通过";
        cell.title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        user = nil;
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
    }
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.seekTextField.text.length <= 0){
//        if (_selMenu == 0) {
//            WH_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//            if (user.userId.length <= 5) {
//                return NO;
//            }else{
//                return YES;
//            }
//        }else{
            return YES;
//        }
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
    UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        WH_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//        _currentUser = user;
//        [g_server delFriend:user.userId toView:self];
        WH_JXFriendObject *friendObj = _array[indexPath.row];
        [friendObj delete];
        [_array removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }];
    return @[deleteBtn];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXFriendObject *friend = self.seekTextField.text.length > 0 ? self.searchArray[indexPath.row] : _array[indexPath.row];
    WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
    user.userNickname = friend.userNickname;
    user.userId = friend.userId;
    
    //新朋友的界面不让跳转会话列表
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    sendView.isHiddenFooter = YES;
    sendView.title = friend.userNickname;
    sendView.chatPerson = user;
    sendView = [sendView init];
    //[g_navigation pushViewController:sendView animated:YES];
}

- (void)friendCell:(WH_JXFriend_WHCell *)friendCell headImageAction:(NSString *)userId {
    
//    [g_server getUser:userId toView:self];
    
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = userId;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)refresh{
    [self WH_stopLoading];
    _refreshCount++;
//    [_array release];
    _array=[[WH_JXFriendObject sharedInstance] WH_fetchAllFriendsFromLocal];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld",indexPath.row);
    WH_JXFriendObject *user = _array[indexPath.row];
    [_array removeObjectAtIndex:indexPath.row];
    [user delete];
    [_table reloadData];
}

-(void)WH_scrollToPageUp{
    [self refresh];
}

-(void)WH_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{
    [_wait stop];
    WH_JXMessageObject *msg     = (WH_JXMessageObject *)notifacation.object;
    if(msg==nil)
        return;
    WH_JXFriend_WHCell* cell = [poolCell objectForKey:msg.messageId];
    if(cell){
//        [g_App showAlert:Localized(@"JXAlert_SendFilad")];
        [JXMyTools showTipView:Localized(@"JXAlert_SendFilad")];
        [poolCell removeObjectForKey:msg.messageId];
    }
}

-(void)newRequest:(NSNotification *)notifacation{//新推送
//    NSLog(@"newRequest");
    WH_JXFriendObject *user     = (WH_JXFriendObject *)notifacation.object;
    if(user == nil)
        return;
    if ([user.type intValue] == 516) {
        return;
    }
//    if(_wait.isShowing)//正在等待，就不刷新
//        return;
    for(int i=0;i<[_array count];i++){
        WH_JXFriendObject* friend = [_array objectAtIndex:i];
        if([friend.userId isEqualToString:user.userId]){
            [friend loadFromObject:user];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            WH_JXFriend_WHCell* cell = (WH_JXFriend_WHCell*)[_table cellForRowAtIndexPath:indexPath];
            [cell update];
            cell = nil;
            return;
        }
        friend = nil;
    }
    [self refresh];
}

-(void)onSayHello:(UIButton*)sender{//打招呼
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    _cell = (WH_JXFriend_WHCell*)[_table cellForRowAtIndexPath:indexPath];

    WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
    vc.delegate = self;
    vc.didTouch = @selector(onInputHello:);
    vc.inputText = Localized(@"JXNewFriendVC_Iam");
    vc = [vc init];
    [g_window addSubview:vc.view];
}

-(void)onInputHello:(WH_JXInput_WHVC*)sender{
    NSString* messageId = [_cell.user doSendMsg:XMPP_TYPE_SAYHELLO content:sender.inputText];
    [poolCell setObject:_cell forKey:messageId];
    [_wait start:nil];
}


-(void)onFeedback:(UIButton*)sender{//回话
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    _cell = (WH_JXFriend_WHCell*)[_table cellForRowAtIndexPath:indexPath];
    
    WH_JXInput_WHVC* vc = [WH_JXInput_WHVC alloc];
    vc.delegate = self;
    vc.didTouch = @selector(onInputReply:);
    vc.inputText = Localized(@"JXNewFriendVC_Who");
    vc = [vc init];
    [g_window addSubview:vc.view];
}

-(void)onInputReply:(WH_JXInput_WHVC*)sender{
    NSString* messageId = [_cell.user doSendMsg:XMPP_TYPE_FEEDBACK content:sender.inputText];
    [poolCell setObject:_cell forKey:messageId];
    [_wait start:nil];
}

-(void)onSeeHim:(UIButton*)sender{//关注他
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    WH_JXFriend_WHCell* cell = (WH_JXFriend_WHCell*)[_table cellForRowAtIndexPath:indexPath];
    NSString* messageId = [cell.user doSendMsg:XMPP_TYPE_NEWSEE content:nil];
    [poolCell setObject:cell forKey:messageId];
    [_wait start:nil];
}

-(void)WH_clickAddFriend:(UIButton*)sender{//加好友
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    _cell = (WH_JXFriend_WHCell*)[_table cellForRowAtIndexPath:indexPath];
    _user = _cell.user;
    [g_server WH_addAttentionWithUserId:_user.userId fromAddType:0 toView:self];
}

-(void)actionQuit{
    [self free];
    [super actionQuit];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:wh_act_AttentionAdd]){
        int n = [[dict objectForKey:@"type"] intValue];
        if( n==2 || n==4)
            _friendStatus = 2;
//        else
//            _friendStatus = 1;

        if(_friendStatus == 2){
            NSString* messageId = [_user doSendMsg:XMPP_TYPE_PASS content:nil];
            [poolCell setObject:_cell forKey:messageId];
            [_wait start:nil];
            messageId = nil;
        }
    }
    
    //点击好友头像响应
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = user;
        vc.wh_fromAddType = 6;
//        vc.isJustShow = YES;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
//        [self WH_cancelBtnAction];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

-(void)newReceipt:(NSNotification *)notifacation{//新回执
    //    NSLog(@"newReceipt");
    [_wait stop];
    WH_JXMessageObject *msg     = (WH_JXMessageObject *)notifacation.object;
    if(msg == nil)
        return;
    if(![msg isAddFriendMsg])
        return;
    if(![msg.toUserId isEqualToString:_cell.user.userId])
        return;
    if([msg.type intValue] == XMPP_TYPE_PASS){//通过
        _friendStatus = friend_status_friend;
        _user.status = [NSNumber numberWithInt:_friendStatus];
        [_user update];

        WH_JXMessageObject *msg=[[WH_JXMessageObject alloc] init];
        msg.type = [NSNumber numberWithInt:kWCMessageTypeText];
        msg.toUserId = _user.userId;
        msg.fromUserId = MY_USER_ID;
        msg.content = Localized(@"WaHu_JXFriendObject_StartChat");
        msg.timeSend = [NSDate date];
        [msg insert:nil];
        [msg updateLastSend:UpdateLastSendType_None];
        [msg notifyNewMsg];
    }
    
    WH_JXFriend_WHCell* cell = [poolCell objectForKey:msg.messageId];
    if(cell){
        [cell.user loadFromMessageObj:msg];
        [cell update];
        [g_App showAlert:Localized(@"JXAlert_SendOK")];
        [poolCell removeObjectForKey:msg.messageId];
    }
}


- (void) textFieldDidChange:(UITextField *)textField {
    [super textFieldDidChange:textField];
    //    if (textField.text.length <= 0) {
    //        if (!self.isMyGoIn) {
    //            [self showMenuView];
    //        }
    //        [self getArrayData];
    //        [self.tableView reloadData];
    //        return;
    //    }else {
    //        [self hideMenuView];
    //    }
    
    //    [self.searchArray removeAllObjects];
    //    if (_selMenu == 0) {
    //        self.searchArray = [[WH_JXUserObject sharedUserInstance] WH_fetchGroupsFromLocalWhereLike:textField.text];
    //    }else if (_selMenu == 1){
    //        self.searchArray = [[WH_JXUserObject sharedUserInstance] WH_fetchBlackFromLocalWhereLike:textField.text];
    //    }
    
    self.searchArray = [NSMutableArray array];
    
    NSString *title = nil;
    for (WH_JXFriendObject *user in _array) {
        title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
        if ([title isKindOfClass:[NSString class]] && [title containsString:textField.text]) {
            [self.searchArray addObject:user];
        }
    }
    
    _refreshCount++;
    
    [self.tableView reloadData];
}

- (void)sp_getUserFollowSuccess:(NSString *)mediaCount {
    NSLog(@"Check your Network");
}
@end
