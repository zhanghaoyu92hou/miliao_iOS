//
//  WH_JXBlackFriend_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/6/4.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXBlackFriend_WHVC.h"
#import "BMChineseSort.h"
#import "WH_AddFriend_WHCell.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXRoomPool.h"
#import "JXDevice.h"

@interface WH_JXBlackFriend_WHVC ()<UITextFieldDelegate>

//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) WH_JXUserObject * currentUser;

@end

@implementation WH_JXBlackFriend_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    _array = [NSMutableArray array];
    [self WH_createHeadAndFoot];
    [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
    if (self.isDevice) {
        [g_notify addObserver:self selector:@selector(updateIsOnLineMultipointLogin) name:kUpdateIsOnLineMultipointLogin_WHNotification object:nil];// 多点登录在线离线状态更新
    }
    _table.backgroundColor = g_factory.globalBgColor;
    [_table registerClass:[WH_AddFriend_WHCell class] forCellReuseIdentifier:@"WH_AddFriend_WHCell"];
    [self customView];
    [self getArrayData];
}

- (void)customView {
    //搜索输入框
    
//    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 50)];
////    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
//    [self.view addSubview:backView];
    
    //    [seekImgView release];
    
    //    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
    //    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    //    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    //    [cancelBtn addTarget:self action:@selector(WH_cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    //    cancelBtn.titleLabel.font = sysFontWithSize(14.0);
    //    [backView addSubview:cancelBtn];
    
    
//    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 30)];
//    _seekTextField.placeholder = [NSString stringWithFormat:@"%@",Localized(@"JX_EnterKeyword")];
//    _seekTextField.textColor = [UIColor blackColor];
//    [_seekTextField setFont:sysFontWithSize(14)];
//    _seekTextField.backgroundColor = HEXCOLOR(0xf0f0f0);
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
//    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    //    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
//    imageView.center = leftView.center;
//    [leftView addSubview:imageView];
//    _seekTextField.leftView = leftView;
//    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
//    _seekTextField.borderStyle = UITextBorderStyleNone;
//    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    _seekTextField.delegate = self;
//    _seekTextField.returnKeyType = UIReturnKeyGoogle;
//    [backView addSubview:_seekTextField];
//    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, JX_SCREEN_WIDTH, .5)];
//    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [backView addSubview:lineView];
    
    
//    self.tableView.tableHeaderView = backView;
}

- (void)getArrayData {
    [self.array removeAllObjects];
    //获取黑名單列表
    
    if (self.isDevice) {
        _array = [[JXDevice sharedInstance] fetchAllDeviceFromLocal];
    }else {
        //从数据库获取好友staus为-1的
        _array=[[WH_JXUserObject sharedUserInstance] WH_fetchAllBlackFromLocal];
    }
    //选择拼音 转换的 方法
//    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
//    [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
//        if (isSuccess) {
//            self.indexArray = sectionTitleArr;
//            self.letterResultArr = sortedObjArr;
//            [self.tableView reloadData];
//        }
//    }];

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//
//    [self.tableView reloadData];
}

- (void)updateIsOnLineMultipointLogin {
    [self getArrayData];

    [_table reloadData];
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        [self getArrayData];
        [self.tableView reloadData];
        return;
    }
    
    [_searchArray removeAllObjects];
    _searchArray = [[WH_JXUserObject sharedUserInstance] WH_fetchBlackFromLocalWhereLike:textField.text];
    
    [self.tableView reloadData];
}

- (void) WH_cancelBtnAction {
    if (_seekTextField.text.length > 0) {
        _seekTextField.text = nil;
        [self getArrayData];
    }
    [_seekTextField resignFirstResponder];
    [self.tableView reloadData];
}

#pragma mark   ---------tableView协议----------------

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (_seekTextField.text.length > 0) {
//        return 1;
//    }
    return _array.count;
//    return [self.indexArray count];
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (_seekTextField.text.length > 0) {
//        return Localized(@"JXFriend_searchTitle");
//    }
//    return [self.indexArray objectAtIndex:section];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
//    if (_seekTextField.text.length > 0) {
//        return _searchArray.count;
//    }
//    return [[self.letterResultArr objectAtIndex:section] count];
}
//-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    if (_seekTextField.text.length > 0) {
//        return nil;
//    }
//    return self.indexArray;
//}
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
//    return index;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXUserObject *user = _array[indexPath.section];;
//    if (_seekTextField.text.length > 0) {
//        user = _searchArray[indexPath.row];
//    }else{
//        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    }
    
    
    
    WH_AddFriend_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_AddFriend_WHCell"];
    
    if (self.isDevice) {
        cell.titleLabel.text = [self multipleLoginIsOnlineTitle:user];
    }else {
        cell.titleLabel.text = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
    }
//    [cell ]
    
//    cell.index = (int)indexPath.row;
//    cell.delegate = self;
//    if (!self.isDevice) {
//        cell.didTouch = @selector(WH_on_WHHeadImage:);
//    }
    
//    [cell setForTimeLabel:[TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"]];
//    cell.timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 120-20, 9, 115, 20);
//    cell.userId = user.userId;
//    [cell.lbTitle setText:cell.title];
    
//    cell.dataObj = user;

    
//    cell.isSmall = YES;
//    [cell WH_headImageViewImageWithUserId:nil roomId:nil];
    cell.type = WHSettingCellTypeIconWithTitle;
    cell.bgRoundType = WHSettingCellBgRoundTypeAll;
    [cell.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(21);
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    [g_server WH_getHeadImageSmallWIthUserId:user.userId userName:cell.titleLabel.text imageView:cell.iconImageView];
    return cell;
}

- (NSString *)multipleLoginIsOnlineTitle:(WH_JXUserObject *)user {
    NSString *isOnline;
    if ([user.isOnLine intValue] == 1) {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OnLine")];
    }else {
        isOnline = [NSString stringWithFormat:@"(%@)", Localized(@"JX_OffLine")];
    }
    NSString *title = user.userNickname;
//    title = [title stringByAppendingString:isOnline];
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WH_JXUserObject *user;
    if (_seekTextField.text.length > 0) {
        user = _searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }

    if (self.isDevice) {
//        WH_JX_WHCell * cell = [_table cellForRowAtIndexPath:indexPath];
//        cell.selected = NO;
        
        
        WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
        if([user.roomFlag intValue] > 0  || user.roomId.length > 0){
            sendView.roomJid = user.userId;
            sendView.roomId = user.roomId;
            [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname isNew:NO];
        }
        sendView.title = user.userNickname;
        sendView.chatPerson = user;
        sendView = [sendView init];
        //    [g_App.window addSubview:sendView.view];
        [g_navigation pushViewController:sendView animated:YES];
    }else {
        _currentUser = user;
        WH_JXUserInfo_WHVC *userVC = [WH_JXUserInfo_WHVC alloc];
        userVC.wh_userId = user.userId;
        userVC.wh_fromAddType = 6;
        userVC = [userVC init];
        [g_navigation pushViewController:userVC animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isDevice) {
        return NO;
    }

    if (_seekTextField.text.length <= 0){

        return YES;
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
    UITableViewRowAction *cancelBlackBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"REMOVE") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        WH_JXUserObject *user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        _currentUser = user;
        [g_server WH_delBlacklistWithToUserId:user.userId toView:self];
    }];
    
    return @[cancelBlackBtn];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

//服务器返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
//    //更新本地好友
//    if ([aDownload.action isEqualToString:wh_act_AttentionList]) {
//        [_wait stop];
//        WH_JXProgress_WHVC * pv = [WH_JXProgress_WHVC alloc];
//        // 服务端不会返回新朋友 ， 减去新朋友
//        pv.dbFriends = (long)[_array count] - 1;
//        pv.dataArray = array1;
//        pv = [pv init];
//        //        [g_window addSubview:pv.view];
//    }
    
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
        vc.wh_fromAddType = 6;
        vc = [vc init];
        //        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
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

-(void)newFriend:(NSObject*)sender{
    [self getArrayData];
}

-(void)WH_on_WHHeadImage:(id)dataObj{
    
    WH_JXUserObject *p = (WH_JXUserObject *)dataObj;
    if([p.userId isEqualToString:FRIEND_CENTER_USERID] || [p.userId isEqualToString:CALL_CENTER_USERID])
        return;
    
    _currentUser = p;
//    [g_server getUser:p.userId toView:self];
    
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = p.userId;
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
            [g_App showAlert:Localized(@"JXAlert_DeleteFirend")];
        }
    }
    
    if([msg.type intValue] == XMPP_TYPE_BLACK){//拉黑
        
        [_array removeObject:_currentUser];
        
        //选择拼音 转换的 方法
        BMChineseSortSetting.share.sortMode = 2; // 1或2
        //排序 Person对象
        [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
            if (isSuccess) {
                self.indexArray = sectionTitleArr;
                self.letterResultArr = sortedObjArr;
                [self.tableView reloadData];
            }
        }];

//        //根据Person对象的 name 属性 按中文 对 Person数组 排序
//        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//        [self.tableView reloadData];
    }
    
    if([msg.type intValue] == XMPP_TYPE_NOBLACK){
        //        _currentUser.status = [NSNumber numberWithInt:friend_status_friend];
        //        int status = [_currentUser.status intValue];
        //        [_currentUser update];
        
        if ([[JXXMPP sharedInstance].blackList containsObject:_currentUser.userId]) {
            [[JXXMPP sharedInstance].blackList removeObject:_currentUser.userId];
        }
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
}

- (void)friendRemarkNotif:(NSNotification *)notif {
    
    WH_JXUserObject *user = notif.object;
    for (int i = 0; i < _array.count; i ++) {
        WH_JXUserObject *user1 = _array[i];
        if ([user.userId isEqualToString:user1.userId]) {
            user1.userNickname = user.userNickname;
            [_table reloadData];
            break;
        }
    }
}
- (void)dealloc {
    [g_notify removeObserver:self];
    //    [_table release];
    [_array removeAllObjects];
    //    [_array release];
    //    [super dealloc];
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



@end
