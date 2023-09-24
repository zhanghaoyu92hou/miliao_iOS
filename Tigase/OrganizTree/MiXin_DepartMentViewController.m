//
//  MiXin_CompanyListController.m
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_DepartMentViewController.h"
#import "WH_JXAddDepart_WHViewController.h"
#import "UIAlertController+category.h"
#import "MiXin_CompanyModel.h"
#import "MiXin_MemberlistController.h"
#import "MiXin_CompanyListController.h"
#import "WH_JXRoomObject.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXRoomPool.h"
#import "WH_JXInput_WHVC.h"
#import "WH_JXRoomRemind.h"

@interface MiXin_DepartMentViewController ()<AddDepartDelegate> {
    UIView *_menuView;
    NSString *_depname;
    NSString *_roomUserId;
    NSString *_roomUserName;
    NSString *_roomJid;

    
    
}
@property (nonatomic, strong) NSMutableArray *models;
@end

@implementation MiXin_DepartMentViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        _models = [NSMutableArray array];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self customView];
    
    [_wait start];
    _models = [NSMutableArray array];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [g_server WH_getDepartmentListPageWithPageIndex:@0 companyId:_comId toView:self];
}


- (void)customView {
    
    self.title = _tname;
    [self WH_createHeadAndFoot];
    
    
    [_table setFrame:CGRectMake(10, JX_SCREEN_TOP,JX_SCREEN_WIDTH-20, JX_SCREEN_HEIGHT- JX_SCREEN_TOP)];
    [_table setBackgroundColor:g_factory.globalBgColor];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = 55;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (_ischoose) {
        self.wh_headerTitle.text = @"更换部门";
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 71)];
        UILabel *lab = [head createLab:CGRectMake(0, 20, _table.width, 30) font:[UIFont systemFontOfSize:22] color:HEXCOLOR(0x333333) text:@"请选择要更换的部门"];
        [head addSubview:lab];
        _table.tableHeaderView = head;
        
        UIView *foot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 71)];
        UIButton *_btn = [UIFactory WH_create_WHCommonButton:@"完成" target:self action:@selector(updateeDepartss)];
        _btn.custom_acceptEventInterval = .25f;
        _btn.layer.cornerRadius = 5;
        _btn.clipsToBounds = YES;
        _btn.frame = CGRectMake(10,13,CGRectGetWidth(_table.frame)-20,44);
        [foot addSubview:_btn];
        _table.tableFooterView = foot;
    }else {
        UIButton *moreBtn = [UIFactory WH_create_WHButtonWithImage:@"WH_addressbook_add" highlight:nil target:self selector:@selector(createMenu)];
        moreBtn.custom_acceptEventInterval = 1.0f;
        moreBtn.frame = CGRectMake(JX_SCREEN_WIDTH-38, JX_SCREEN_TOP-36, NAV_BTN_SIZE, NAV_BTN_SIZE);
        [self.wh_tableHeader addSubview:moreBtn];
    }
}


- (void)createMenu {
    if (!_menuView) {
        UIView *uView = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-155, JX_SCREEN_TOP, 145, 136)];
        uView.backgroundColor = [UIColor whiteColor];
        NSArray *arr = @[@"添加部门",@"修改团队名称",@"解散/退出公司"];
        for (int i = 0; i < arr.count; i++) {
            UIButton *btn = [uView createBtn:CGRectMake(0, 45*i, 145, 45) font:sysFontWithSize(16) color:HEXCOLOR(0x333333) text:arr[i] img:nil target:self sel:@selector(clickMenu:)];
            btn.tag = 2342+i;
            [uView addSubview:btn];
        }
        [uView setRadiu:12 color:nil];
        _menuView = [[UIView alloc]initWithFrame:self.view.bounds];
        _menuView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.3];
        [_menuView addSubview:uView];
    }
    
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickDismiss)];
    [_menuView addGestureRecognizer:tag];
    
    [self.view addSubview:_menuView];
}
- (void)clickDismiss {
    [_menuView removeFromSuperview];
}

- (void)clickMenu:(UIButton *)btn {
    [_menuView removeFromSuperview];
    
    if (btn.tag == 2342) {
        WH_JXAddDepart_WHViewController * addDepartVC = [[WH_JXAddDepart_WHViewController alloc] init];
        addDepartVC.delegate = self;
        addDepartVC.type = OrganizAddDepartment;
        addDepartVC.oldName = nil;
        [g_navigation pushViewController:addDepartVC animated:YES];
    }else if (btn.tag == 2343) {
        WH_JXAddDepart_WHViewController * addDepartVC = [[WH_JXAddDepart_WHViewController alloc] init];
        addDepartVC.delegate = self;
        addDepartVC.type = OrganizUpdateCompanyName;
        addDepartVC.oldName = @"修改团队名称"; //_tname;
        [g_navigation pushViewController:addDepartVC animated:YES];
    }else if (btn.tag == 2344) {
        [UIAlertController showAlertViewWithTitle:@"确定解散/退出企业吗" message:nil controller:self block:^(NSInteger buttonIndex) {
            if (buttonIndex==1) {
                [g_server WH_quitCompanyWithCompanyId:_comId toView:self];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
    }
}

- (void)inputDelegateType:(OrganizAddType)organizType text:(NSString *)updateStr {
    if (organizType == OrganizAddDepartment) {
        [g_server WH_createDepartmentWithCompanyId:_comId parentId:_parentId departName:updateStr createUserId:_userId toView:self];
    }else if (organizType == OrganizUpdateCompanyName) {
        [g_server WH_updataCompanyNameWithCompanyName:updateStr companyId:_comId toView:self];
        
    }
}



#pragma mark - 修改部门 -
- (void)updateeDepartss {
    NSString *departId;
    for (MiXin_DepartModel *mod in _models) {
        if (mod.isChoose) {
            _depname = mod.departName;
            departId = mod.ID;
            break;
        }
    }
    if (departId) {
        
        [g_server WH_modifyDpartWithUserId:_userId companyId:_comId newDepartmentId:departId toView:self];
    }else {
        [g_server showMsg:@"请选择要更改的部门"];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _models.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setRadiu:10 color:nil];
        if (_ischoose) {
            UIImageView *arro = [[UIImageView alloc]initWithFrame:CGRectMake(_table.width-30, 13, 20, 20)];
            arro.image = [UIImage imageNamed:@"emchoose-0"];
            [cell.contentView addSubview:arro];
            arro.tag = 3498;
        }else {
            UIButton *bbb = [cell createBtn:CGRectMake(_table.width-120, 0, 120, 55) font:sysFontWithSize(15) color:HEXCOLOR(0x8F9CBB) text:@"部门群" img:@"部门群" target:nil sel:nil];
            [bbb setTitleEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
            [cell.contentView addSubview:bbb];
            bbb.tag = 1823;
            [bbb addTarget:self action:@selector(clickChatGroup:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    MiXin_DepartModel *model = _models[indexPath.section];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%lu)",model.departName,(unsigned long)model.employees.count];
    if (_ischoose) {
        UIImageView *arro = [cell.contentView viewWithTag:3498];
        arro.image = [UIImage imageNamed:model.isChoose?@"emchoose-1":@"emchoose-0"];
    }
    return cell;
}


- (void)clickChatGroup:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [_table indexPathForCell:cell];
    MiXin_DepartModel *model = _models[path.section];
    if (model.empNum.integerValue == 0) {
        [g_server showMsg:@"该群组暂无成员"];
    }else {
        if (model.roomId == nil) {
            [g_server showMsg:@"不能进入该群组聊天"];
        }else {
            [g_server WH_roomGetRoom:model.roomId toView:self];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MiXin_DepartModel *model = _models[indexPath.section];
    if (_ischoose) {
        model.isChoose = !model.isChoose;
        for (MiXin_DepartModel *mm in _models) {
            if (mm != model) {
                mm.isChoose = NO;
            }
        }
        [_table reloadData];
    }else {
        MiXin_MemberlistController *vc = [MiXin_MemberlistController new];
        vc.comId = _comId;
        vc.comname = self.wh_headerTitle.text;
        vc.tname = model.departName;
        vc.departId = model.ID;
        vc.createUserId = model.createUserId;

        [g_navigation pushViewController:vc animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section==0?12:0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc]init];
}


- (void)goGroupRoom:(NSDictionary *)dict {
    if(g_xmpp.isLogined != 1){
        // 掉线后点击title重连
        // 判断XMPP是否在线  不在线重连
        [g_xmpp showXmppOfflineAlert];
        return;
    }
    
    WH_JXUserObject *user = [[WH_JXUserObject sharedUserInstance] getUserById:[dict objectForKey:@"jid"]];
    WH_JXRoomObject *_chatRoom;
    if(user && [user.groupStatus intValue] == 0){

        _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
        //老房间:
        [self showChatView:dict room:_chatRoom];
    }else{
        
        _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[dict objectForKey:@"jid"] title:[dict objectForKey:@"name"] isNew:YES];
        BOOL isNeedVerify = [dict[@"isNeedVerify"] boolValue];
        long userId = [dict[@"userId"] longLongValue];
        if (isNeedVerify && userId != [g_myself.userId longLongValue]) {
            
            _roomJid = [dict objectForKey:@"jid"];
            _roomUserName = [dict objectForKey:@"nickname"];
            _roomUserId = [dict objectForKey:@"userId"];
            
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
}

-(void)showChatView:(NSDictionary *)dict room:(WH_JXRoomObject *)chatRoom {
    [_wait stop];
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

    [g_navigation pushViewController:sendView animated:YES];
    
    dict = nil;
}

    
-(void)onInputHello:(WH_JXInput_WHVC*)sender{
    
    WH_JXMessageObject *msg = [[WH_JXMessageObject alloc] init];
    msg.fromUserId = MY_USER_ID;
    msg.toUserId = [NSString stringWithFormat:@"%@", _roomUserId];
    msg.fromUserName = MY_USER_NAME;
    msg.toUserName = _roomUserName;
    msg.timeSend = [NSDate date];
    msg.type = [NSNumber numberWithInt:kRoomRemind_NeedVerify];
    NSString *userIds = g_myself.userId;
    NSString *userNames = g_myself.userNickname;
    NSDictionary *dict = @{
                           @"userIds" : userIds,
                           @"userNames" : userNames,
                           @"roomJid" : _roomJid,
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
    

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    if ([aDownload.action isEqualToString:wh_act_departmentList]) {//部门列表
        [_models removeAllObjects];
        NSMutableArray *MArr = [NSMutableArray arrayWithArray:array1];
        if (MArr.count) {
            
            for (int i = 0; i < MArr.count; i ++) {
                NSDictionary *tempDic = MArr[i];
                NSString *parentId = tempDic[@"parentId"];
                NSString *departName = tempDic[@"departName"];
                if (parentId == nil && [departName isEqualToString:self.companyName]) {
                    [MArr removeObjectAtIndex:i];
                }
            }
            
        }
        
        [_models addObjectsFromArray:[MiXin_DepartModel mj_objectArrayWithKeyValuesArray:MArr]];
        
        if (_ischoose) {
            for (MiXin_DepartModel *mm in _models) {
                if ([mm.departName isEqualToString:_tname]) {
                    mm.isChoose = YES;
                }
            }
        }
        [_table reloadData];
        
    }else if ([aDownload.action isEqualToString:wh_act_addEmployee]) {//添加员工
        [g_server showMsg:Localized(@"OrgaVC_AddEmployeeSuccess") delay:1.0];

    }else if ([aDownload.action isEqualToString:wh_act_modifyDpart]) {
        [g_server showMsg:@"更改部门成功"];
        if (self.updateDepart&&_depname) {
            self.updateDepart(_depname);
        }
        [self actionQuit];
    }else if ([aDownload.action isEqualToString:wh_act_createDepartment]) {
        [g_server showMsg:@"添加部门成功"];
        [g_server WH_getDepartmentListPageWithPageIndex:@0 companyId:_comId toView:self];
    }else if ([aDownload.action isEqualToString:wh_act_updataCompanyName]) {
        [g_server showMsg:@"修改公司名成功"];
        _tname = dict[@"companyName"];
        self.wh_headerTitle.text = _tname;
    }else if ([aDownload.action isEqualToString:wh_act_companyQuit]) {
        [g_server showMsg:@"解散/退出企业成功"];
        if (self.deleteCom) {
            self.deleteCom();
        }
        [self actionQuit];
    }else if ([aDownload.action isEqualToString:wh_act_roomGetRoom]) {
        [self goGroupRoom:dict];
    }
    
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self WH_stopLoading];
    return WH_hide_error;
}
#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    
    return WH_show_error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

