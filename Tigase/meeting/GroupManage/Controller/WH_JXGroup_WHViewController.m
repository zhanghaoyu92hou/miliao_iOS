//
//  WH_JXGroup_WHViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "WH_JXGroup_WHViewController.h"
//#import "Statics.h"
//#import "KKMessageCell.h"
//#import "XMPPStream.h"
#import "WH_JXMessageObject.h"
#import "JXXMPP.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "WH_JX_WHCell.h"
#import "WH_JXRoomPool.h"
#import "JXTableView.h"
#import "WH_JXRoomMember_WHVC.h"
#import "WH_JXRoomObject.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXNewRoom_WHVC.h"
#import "WH_menuImageView.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXRoomRemind.h"
#import "WH_JXInput_WHVC.h"
#import "WH_JXCommonInput_WHVC.h"
#import "WH_JXSearchGroup_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "BMChineseSort.h"
//#import "WH_JXTableViewController.h"


#define Scroll_Move 45

#define padding 20
@interface WH_JXGroup_WHViewController()<UITextFieldDelegate,WH_JXCommonInput_WHVCDelegate>{
    NSMutableArray * _myGroupArray;
    NSMutableArray * _allGroupArray;
    NSMutableArray * _originGroupArray;
}

//排序后的出现过的拼音首字母数组
@property(nonatomic,strong) NSMutableArray *indexArray;

@property (nonatomic, copy) NSString *roomJid;
@property (nonatomic, copy) NSString *roomUserId;
@property (nonatomic, copy) NSString *roomUserName;

@end
@implementation WH_JXGroup_WHViewController

#pragma mark - life circle

- (id)init
{
    self = [super init];
    if (self) {
//        self.title = @"";
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.myTableViewStyle = 1;
        self.title = Localized(@"JX_ManyPerChat");
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM);
        self.wh_isGotoBack = YES;
        [self WH_createHeadAndFoot];
        
//        CGRect frame = self.tableView.frame;
//        frame.origin.y += 40;
//        frame.size.height -= 40;
//        self.tableView.frame = frame;

        [self customView];
        UIButton* btn = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal"
                                               highlight:nil
                                                  target:self
                                                selector:@selector(onNewRoom)];
        
        btn.frame = CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 24, JX_SCREEN_TOP - 34, 24, 24);
        [self.wh_tableHeader addSubview:btn];
        
#pragma 隐藏群搜索功能
//        btn = [UIFactory WH_create_WHButtonWithImage:@"search_publicNumber"
//                               highlight:nil
//                                  target:self
//                                selector:@selector(onSearchRoom)];
//        btn.frame = CGRectMake(JX_SCREEN_WIDTH - 80, JX_SCREEN_TOP - 34, 24, 24);
//        [self.wh_tableHeader addSubview:btn];
        
        _myGroupArray = [[NSMutableArray alloc] init];
        _allGroupArray = [[NSMutableArray alloc] init];
        _originGroupArray = [[NSMutableArray alloc] init];
        _page=0;
        _isLoading=0;
        _selMenu = 0;
        [self WH_scrollToPageUp];

        [g_notify addObserver:self selector:@selector(onReceiveRoomRemind:) name:kXMPPRoom_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(onQuitRoom:) name:kQuitRoom_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(WH_doRefresh:) name:kUpdateUser_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(headImageNotification:) name:kGroupHeadImageModifyNotifaction object:nil];
    }
    return self;
}

-(void)headImageNotification:(NSNotification *)notification{
    [_table reloadData];
}

//-(void)onClick:(UIButton*)sender{
//}
- (void)WH_doRefresh:(NSNotification *)notif {
    [self.indexArray removeAllObjects];
    [_myGroupArray removeAllObjects];
    [self WH_getServerData];
}

- (void) customView {
    //顶部筛选控件
//    _topSiftView = [[WH_JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 40)];
//    _topSiftView.delegate = self;
//    _topSiftView.isShowMoreParaBtn = NO;
//    _topSiftView.dataArray = [[NSArray alloc] initWithObjects:Localized(@"JXGroupVC_MyRoom"),Localized(@"JXGroupVC_AllRoom"), nil];
//    //    _topSiftView.searchForType = SearchForPos;
//    [self.view addSubview:_topSiftView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 44.f)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //搜索条
    [self createSeekTextField:headerView isFriend:NO];
    
    [self.view addSubview:headerView];
    self.tableView.tableHeaderView = headerView;
    
    _table.backgroundColor = g_factory.globalBgColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc {
    [g_notify removeObserver:self];
    [g_notify  removeObserver:self name:kXMPPRoom_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kQuitRoom_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kUpdateUser_WHNotifaction object:nil];
    [g_notify  removeObserver:self name:kGroupHeadImageModifyNotifaction object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_selMenu == 1) {
        [_scrollView setContentOffset:CGPointMake(JX_SCREEN_WIDTH/2+Scroll_Move*0.5, 0) animated:NO];
    }else{
        [_scrollView setContentOffset:CGPointMake(JX_SCREEN_WIDTH, 0) animated:NO];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//-(void)onNewRoom{
//    if ([g_config.isCommonCreateGroup intValue] == 1) {
//        [g_App showAlert:Localized(@"JX_NotCreateNewRoom")];
//        return;
//    }
//    WH_JXNewRoom_WHVC* vc = [[WH_JXNewRoom_WHVC alloc]init];
//    [g_navigation pushViewController:vc animated:YES];
//}

-(void)onNewRoom{
    
    if ([g_config.isCommonCreateGroup intValue] == 1) {
        [g_App showAlert:Localized(@"JX_NotCreateNewRoom")];
        return;
    }
    
    WH_RoomData *roomData = [[WH_RoomData alloc] init];
    
    memberData *member = [[memberData alloc] init];
    member.userId = (long)[g_myself.userId longLongValue];
    member.userNickName = MY_USER_NAME;
    member.role = @1;
    [roomData.members addObject:member];
    
    WH_JXUserObject *userObj = [[WH_JXUserObject alloc] init];
    userObj.userId = g_myself.userId;
    userObj.userNickname = g_myself.userNickname;
    
    WH_JXSelectFriends_WHVC* vc = [WH_JXSelectFriends_WHVC alloc];
    vc.room = roomData;
    vc.isNewRoom = YES;
    //    vc.isForRoom = YES;
    vc.forRoomUser = userObj;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)onSearchRoom {
    
    WH_JXCommonInput_WHVC *vc = [[WH_JXCommonInput_WHVC alloc] init];
    vc.delegate = self;
    vc.titleStr = Localized(@"JX_CommonGroupSearch");
    vc.subTitle = Localized(@"JX_ManyPerChat");
    vc.tip = Localized(@"JX_InputRoomName");
    vc.btnTitle = Localized(@"JX_Seach");
    [g_navigation pushViewController:vc animated:YES];
    
}

- (void)commonInputVCBtnActionWithVC:(WH_JXCommonInput_WHVC *)commonInputVC {
    
    WH_JXSearchGroup_WHVC *vc = [[WH_JXSearchGroup_WHVC alloc] init];
    vc.searchName = commonInputVC.name.text;
    [g_navigation pushViewController:vc animated:YES];
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.seekTextField.text.length > 0) {
        return 1;
    }
    return [self.indexArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.seekTextField.text.length > 0) {
        return self.searchArray.count;
    }
    NSArray *tmpArr = nil;
    if (_selMenu == 0) {
        tmpArr = _myGroupArray;
    }else if (_selMenu == 1) {
        tmpArr = _allGroupArray;
    }
    return [[tmpArr objectAtIndex:section] count];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.seekTextField.text.length > 0) {
        return nil;
    }
    return self.indexArray;
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
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellName = [NSString stringWithFormat:@"groupWH_JX_WHCell"];
    WH_JX_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    NSDictionary *dataDict = [self rowItemsWithIndexPath:indexPath];
    
    //准备数据
    NSString * roomIdStr = dataDict[@"id"];
    NSString * title = [NSString stringWithFormat:@"%@ (%@%@)",dataDict[@"name"],dataDict[@"userSize"],Localized(@"JXLiveVC_countPeople")];
    NSString * userId = [dataDict objectForKey:@"userId"];
    NSString * jid = [dataDict objectForKey:@"jid"];
    
    if(cell==nil){
        cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
        [_table WH_addToPool:cell];
    }
    cell.delegate = self;
    cell.didTouch = @selector(WH_on_WHHeadImage:);
//    [cell groupCellDataSet:dict indexPath:indexPath];
    
//    NSTimeInterval t = [[dataDict objectForKey:@"createTime"] longLongValue];
//    NSDate* d = [NSDate dateWithTimeIntervalSince1970:t];
    
    cell.index = (int)indexPath.row;
//    if (_selMenu == 0) {
//        cell.title = dataDict[@"name"];
//    }else
        cell.title = title;
//    }
//    cell.subtitle = [dataDict objectForKey:@"desc"];
//    cell.bottomTitle = [TimeUtil formatDate:d format:@"MM-dd HH:mm"];
    cell.userId = userId;
    
    cell.headImageView.tag = (int)indexPath.row;
    cell.headImageView.idxPath = indexPath;
    cell.headImageView.wh_object = roomIdStr;
    cell.headImageView.wh_delegate = self;
    cell.headImageView.didTouch = @selector(WH_on_WHHeadImage:);
    
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
    cell.lbTitle.tag = cell.index;
    
    [cell.lbSubTitle setText:cell.subtitle];
    [cell.timeLabel setText:cell.bottomTitle];
    cell.bageNumber.wh_delegate = self;
//    bageNumber.didDragout = self.didDragout;
    cell.bage = cell.bage;
    
    cell.roomId = roomIdStr;
    [cell WH_headImageViewImageWithUserId:jid roomId:roomIdStr];
    cell.isSmall = YES ;
    
    [self WH_doAutoScroll:indexPath];
    [cell setLineDisplayOrHidden:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 31;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (NSDictionary *)rowItemsWithIndexPath:(NSIndexPath *)indexPath{
    if (self.seekTextField.text.length > 0) {
        return self.searchArray[indexPath.row];
    }else{
        NSArray *tmpArr = nil;
        if (_selMenu == 0) {
            tmpArr = _myGroupArray;
        }else if (_selMenu == 1) {
            tmpArr = _allGroupArray;
        }
        return [[tmpArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
}

#pragma mark - 头像按钮点击方法
-(void)WH_on_WHHeadImage:(WH_JXImageView*)sender{
//    if (_selMenu == 0) {
//        dict = _myGroupArray[sender.tag];
//    }else if (_selMenu == 1) {
//        dict = _allGroupArray[sender.tag];
//    }
    NSDictionary *groupDict = [self rowItemsWithIndexPath:sender.idxPath];
    
    WH_JXRoomMember_WHVC* vc = [WH_JXRoomMember_WHVC alloc];
    vc.wh_roomId = sender.wh_object;
    WH_RoomData *roomdata = [[WH_RoomData alloc] init];
    [roomdata WH_getDataFromDict:groupDict];
    vc.wh_room      = roomdata;

    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
//    [g_server getRoom:dict[@"id"] toView:self];

//    [g_server getUser:[[dict objectForKey:@"userId"] stringValue] toView:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(g_xmpp.isLogined != 1){
        // 掉线后点击title重连
        // 判断XMPP是否在线  不在线重连
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
    [_inputText resignFirstResponder];
    _selectIndexPath = indexPath;
    NSDictionary *dict = [self rowItemsWithIndexPath:indexPath];
//    if (_selMenu == 0) {
//        dict = _myGroupArray[_sel];
//    }else if (_selMenu == 1) {
//        dict = _allGroupArray[_sel];
//    }

    WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:[dict objectForKey:@"jid"]];
    
    if(user && [user.groupStatus intValue] == 0){
        
        _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
        //老房间:
        [self showChatView];
    }else{
        
        _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
        BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
        long userId = [dict[@"userId"] longLongValue];
        if (isNeedVerify && userId != [g_myself.userId longLongValue]) {

            self.roomJid = [dict objectForKey:@"jid"];
            self.roomUserName = [dict objectForKey:@"nickname"];
            self.roomUserId = [dict objectForKey:@"userId"];
            
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
            _chatRoom.delegate = self;
            [_chatRoom joinRoom:YES];
        }
    }
    dict = nil;
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
}


-(void)onInputHello:(WH_JXInput_WHVC*)sender{
    
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
                           @"roomJid" : self.roomJid,
                           @"reason" : sender.inputText,
                           @"isInvite" : [NSNumber numberWithBool:YES]
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    msg.objectId = jsonStr;
    [g_xmpp sendMessage:msg roomName:nil];
    
//    msg.fromUserId = self.roomJid;
//    msg.type = [NSNumber numberWithInt:kWCMessageTypeRemind];
//    msg.content = @"申请已发送给群主，请等待群主确认";
//    [msg insert:self.roomJid];
//    if ([self.delegate respondsToSelector:@selector(needVerify:)]) {
//        [self.delegate needVerify:msg];
//    }
}

-(void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    NSDictionary *dict = [self rowItemsWithIndexPath:_selectIndexPath];
//    if (_selMenu == 0) {
//        dict = _myGroupArray[_sel];
//    }else if (_selMenu == 1) {
//        dict = _allGroupArray[_sel];
//    }
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
    
    [self showChatView];
}

-(void)startReconnect{
    NSArray * tempArray = _originGroupArray;
//    if (_selMenu == 0) {
//        tempArray = _myGroupArray;
//    }else if (_selMenu == 1) {
//        tempArray = _allGroupArray;
//    }
    
    for (int i = 0; i < [tempArray count]; i++) {
        NSDictionary *dict=tempArray[i];
        
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
        else
            [user update];
//        [user release];
        
        [g_server WH_addRoomMemberWithRoomId:[dict objectForKey:@"id"] userId:g_myself.userId nickName:g_myself.userNickname toView:self];
        
        dict = nil;
        _chatRoom.delegate = nil;
    }
}

-(void)showChatView{
    [_wait stop];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self rowItemsWithIndexPath:_selectIndexPath]];
//    if (_selMenu == 0) {
//        dict = _myGroupArray[_sel];
//    }else if (_selMenu == 1) {
//        dict = _allGroupArray[_sel];
//    }
    //保证不再重新插入群成员数据
    [dict setValue:nil forKey:@"members"];
    
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
    userObj.showMember = [dict objectForKey:@"showMember"];
    userObj.allowSendCard = [dict objectForKey:@"allowSendCard"];
    userObj.userNickname = [dict objectForKey:@"name"];
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

-(void)buildButtons{
    //int height=60;
    int height1=26;
//    int height=0;
    
    _inputText  = [[UITextField alloc]initWithFrame:CGRectMake(5, JX_SCREEN_TOP+2, 310, height1)];
    _inputText.textColor = [UIColor blackColor];
    _inputText.userInteractionEnabled = YES;
    _inputText.delegate = self;
    _inputText.placeholder = Localized(@"JXGroupVC_InputRoomName");
	_inputText.borderStyle = UITextBorderStyleRoundedRect;
    _inputText.font = sysFontWithSize(15);
    _inputText.text = Localized(@"JXGroupVC_Sky");
	_inputText.autocorrectionType = UITextAutocorrectionTypeNo;
	_inputText.returnKeyType = UIReturnKeyDone;
	_inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
    _table.tableHeaderView = _inputText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];

    [self WH_stopLoading];
    if([aDownload.action isEqualToString:wh_act_roomList] || [aDownload.action isEqualToString:wh_act_roomListHis] ){

        self.wh_isShowFooterPull = [array1 count]>=WH_page_size;

        
        if(_page == 0){
            [_originGroupArray removeAllObjects];
            [_originGroupArray addObjectsFromArray:array1];
            //保存所有进入过的房间
            if ([aDownload.action isEqualToString:wh_act_roomListHis]) {
                for (int i = 0; i < [_originGroupArray count]; i++) {
                    NSDictionary *dict=_originGroupArray[i];
                    
                    WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
                    user.userNickname = [dict objectForKey:@"name"];
                    user.userId = [dict objectForKey:@"jid"];
                    user.userDescription = [dict objectForKey:@"desc"];
                    user.roomId = [dict objectForKey:@"id"];
                    user.showRead = [dict objectForKey:@"showRead"];
                    user.showMember = [dict objectForKey:@"showMember"];
                    user.allowSendCard = [dict objectForKey:@"allowSendCard"];
                    user.chatRecordTimeOut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"chatRecordTimeOut"]];
                    user.offlineNoPushMsg = [[dict objectForKey:@"member"] objectForKey:@"offlineNoPushMsg"];
                    user.talkTime = [dict objectForKey:@"talkTime"];
                    user.allowInviteFriend = [dict objectForKey:@"allowInviteFriend"];
                    user.allowUploadFile = [dict objectForKey:@"allowUploadFile"];
                    user.allowConference = [dict objectForKey:@"allowConference"];
                    user.allowSpeakCourse = [dict objectForKey:@"allowSpeakCourse"];
                    user.category = [dict objectForKey:@"category"];
                    user.createUserId = [dict objectForKey:@"userId"];
                    
                    if (![user haveTheUser]){
                        [user insertRoom];
                    }else {
                        [user WH_updateUserNickname];
                    }

                }
            }

        }else{
            if([array1 count]>0)
                [_originGroupArray addObjectsFromArray:array1];
        }

        _refreshCount++;
        
        [self handlerRoomListData:_originGroupArray];
        
//        [_table reloadData];
    }
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = user;
        vc.wh_fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
//        [user release];
    }
    
    if( [aDownload.action isEqualToString:wh_act_roomGet] ){
        
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        NSDictionary * groupDict = [user toDictionary];
        WH_RoomData * roomdata = [[WH_RoomData alloc] init];
        [roomdata WH_getDataFromDict:groupDict];
        
        [roomdata WH_getDataFromDict:dict];
        
        // 非本群成员，不能进入
        BOOL flag = NO;
        for (NSInteger i = 0; i < roomdata.members.count; i ++) {
            memberData *data = roomdata.members[i];
            if (data.userId == [g_myself.userId longLongValue]) {
                flag = YES;
                break;
            }
        }
        if (!flag) {
            [g_App showAlert:Localized(@"JX_NotEnterRoom")];
            return;
        }
        
        WH_JXRoomMember_WHVC* vc = [WH_JXRoomMember_WHVC alloc];
        vc.wh_chatRoom   = [[JXXMPP sharedInstance].roomPool joinRoom:roomdata.roomJid title:roomdata.name isNew:NO];
        vc.wh_room       = roomdata;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }
//    if( [aDownload.action isEqualToString:wh_act_roomMemberSet] ){
//    }
}

- (void)handlerRoomListData:(NSArray *)originArray{
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:originArray key:@"name" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            
            if (_selMenu == 0) {
                _myGroupArray =  sortedObjArr ;
            }else if (_selMenu == 1) {
                _allGroupArray = sortedObjArr;
            }
            
            [_table reloadData];
        }
    }];
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

//筛选点击
- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
    [_topSiftView WH_resetAllParaBtn];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    if (offsetX == 0) {
        _selMenu = 0;
        if (_myGroupArray.count <= 0) {
            [self WH_scrollToPageUp];
        }else {
            [self.tableView reloadData];
        }
    }else {
        _selMenu = 1;
        if (_allGroupArray.count <= 0) {
            [self WH_scrollToPageUp];
        }else {
            [self.tableView reloadData];
        }
    }
    
}
-(void)WH_scrollToPageUp{
    if(_isLoading)
        return;
    _page = 0;
    [self WH_getServerData];
    [self performSelector:@selector(WH_stopLoading) withObject:nil afterDelay:1.0];
}
-(void)WH_getServerData{
    self.wh_isShowFooterPull = _selMenu == 1;
    if(_selMenu==1){
        [g_server listRoom:_page roomName:nil toView:self];
        self.wh_isShowFooterPull = YES;
    }
    else{
        self.wh_isShowFooterPull = NO;
//        if (!(_myGroupArray.count >0)){
            [g_server WH_listHisRoomWithPage:_page pageSize:1000 toView:self];
//        }
        [self.tableView reloadData];
    }
}

- (void)onReceiveRoomRemind:(NSNotification *)notifacation
{

    NSMutableArray * tempArray = _originGroupArray;
//    if (_selMenu == 0) {
//        tempArray = _myGroupArray;
//    }else if (_selMenu == 1) {
//        tempArray = _allGroupArray;
//    }
    WH_JXRoomRemind* p     = (WH_JXRoomRemind *)notifacation.object;
    if([p.type intValue] == kRoomRemind_RoomName){
        for(int i=0;i<[tempArray count];i++){
            NSDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:tempArray[i]];
            if([p.objectId isEqualToString:[dict objectForKey:@"jid"]]){
                [dict setValue:p.content forKey:@"name"];
                NSIndexPath* row = [NSIndexPath indexPathForRow:i inSection:0];

                WH_JX_WHCell* cell = (WH_JX_WHCell*)[_table cellForRowAtIndexPath:row];
                cell.title = [dict objectForKey:@"name"];
                cell = nil;
                
                break;
            }
            dict = nil;
        }
    }
    
    if ([p.type intValue] == kRoomRemind_DelMember || [p.type intValue] == kRoomRemind_DelRoom) {
        for (int i = 0; i < [tempArray count]; i++) {
            NSDictionary *dict = tempArray[i];
            if ([p.objectId isEqualToString:[dict objectForKey:@"jid"]] && [p.toUserId isEqualToString:MY_USER_ID]) {
                [tempArray removeObjectAtIndex:i];
                _refreshCount++;
                [_table reloadData];
                break;
            }
            dict = nil;
        }
    }
}

-(void)onQuitRoom:(NSNotification *)notifacation//删除房间
{
    NSMutableArray * tempArray = _originGroupArray;
//    if (_selMenu == 0) {
//        tempArray = _myGroupArray;
//    }else if (_selMenu == 1) {
//        tempArray = _allGroupArray;
//    }
    WH_JXRoomObject* p     = (WH_JXRoomObject *)notifacation.object;
    for(int i=0;i<[tempArray count];i++){
        NSDictionary *dict=tempArray[i];
        if([p.roomJid isEqualToString:[dict objectForKey:@"jid"]]){
            [tempArray removeObjectAtIndex:i];
            _refreshCount++;
            [_table reloadData];
            break;
        }
        dict = nil;
    }
    p = nil;
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
    
    for (NSDictionary *dataDict in _originGroupArray) {
        if ([dataDict[@"name"] isKindOfClass:[NSString class]] && [dataDict[@"name"] containsString:textField.text]) {
            [self.searchArray addObject:dataDict];
        }
    }
    
    [self.tableView reloadData];
}

@end
