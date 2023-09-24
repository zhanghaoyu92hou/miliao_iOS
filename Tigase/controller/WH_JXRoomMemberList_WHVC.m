//
//  WH_JXRoomMemberList_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/7/3.
//  Copyright © 2018年 YZK. All rights reserved.
//  查看全部群成员

#import "WH_JXRoomMemberList_WHVC.h"
#import "WH_RoomData.h"
#import "WH_JXRoomMemberList_WHCell.h"
#import "BMChineseSort.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXActionSheet_WHVC.h"
#import "WH_JXInputValue_WHVC.h"

#import "WH_ContentModification_WHView.h"
#import "UIView+WH_CustomAlertView.h"

#import "WH_JXRoomRemind.h"
#import "WH_RoomMemberListView.h"

#import "QCheckBox.h"

@interface WH_JXRoomMemberList_WHVC ()<UITextFieldDelegate,LXActionSheetDelegate, UIAlertViewDelegate,WH_JXActionSheet_WHVCDelegate ,JXSelectMenuViewDelegate ,QCheckBoxDelegate>

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) UITextField *seekTextField;


//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong) memberData *currentMember;

@property (nonatomic, strong) WH_JXUserObject *user;
@property (nonatomic ,strong) WH_RoomMemberListView *listView;
@property (nonatomic ,strong) NSMutableArray *managerMemberDataArr;//筛选出群管理
@end

@implementation WH_JXRoomMemberList_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
//    self.isShowFooterPull = NO;
    
    [self WH_createHeadAndFoot];
    
    if (self.type == Type_DelMember && IS_SHOW_BATCHDELETION_ROOMMEMBERS) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
        [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(JX_SCREEN_WIDTH - 43 - 10, JX_SCREEN_TOP - 8 - 28, 43, 28);
        [btn addTarget:self action:@selector(confirmMethod) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = CGRectGetHeight(btn.frame) / 2.f;
        btn.layer.masksToBounds = YES;
        btn.backgroundColor = HEXCOLOR(0x0093FF);
        btn.titleLabel.font = sysFontWithSize(14);
        [self.wh_tableHeader addSubview:btn];
    }
    
//    [self topMenuView];//右上角排序按钮
    
    _searchArray = [NSMutableArray array];
    self.timeArray = [[NSMutableArray alloc] init];
    self.checkBoxArr = [[NSMutableArray alloc] init];
    self.userIds = [[NSMutableArray alloc] init];
    self.userNames = [[NSMutableArray alloc] init];
    self.set = [[NSMutableSet alloc] init];
    
    [self.tableView setBackgroundColor:g_factory.globalBgColor];
    
    [self.tableView registerClass:[WH_JXRoomMemberList_WHCell class] forCellReuseIdentifier:@"WH_JXRoomMemberList_WHCell"];
    [self customSearchTextField];
    
    [self defaultSortMethod];
}

#pragma mark 确定事件
- (void)confirmMethod {
    NSLog(@"self.userids:%@ --- self.userNames:%@" ,self.userIds ,self.userNames);
    if (self.userIds.count == 0) {
        [GKMessageTool showText:@"请选择想要删除的成员！"];
        return;
    }else{
        NSString *userIdsStr = [self.userIds componentsJoinedByString:@","];
        [g_server wh_deleteMembersWithRoomId:self.room.roomId?:@"" userId:userIdsStr?:@"" toView:self];
    }
    
}

- (void)topMenuView {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 24-BTN_RANG_UP*2, JX_SCREEN_TOP - 34-BTN_RANG_UP, 24+BTN_RANG_UP*2, 24+BTN_RANG_UP*2)];
    [btn addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableHeader addSubview:btn];
    
    UIButton *moreBtn = [UIFactory WH_create_WHButtonWithImage:@"WH_WH_Edit"
                                                           highlight:nil
                                                              target:self
                                                            selector:@selector(onMore:)];
    moreBtn.custom_acceptEventInterval = 1.0f;
    moreBtn.frame = CGRectMake(BTN_RANG_UP * 2, BTN_RANG_UP, NAV_BTN_SIZE, NAV_BTN_SIZE);
    [btn addSubview:moreBtn];
}

- (void)onMore:(UIButton *)sender {
    NSArray *titles = @[@"默认排序" ,@"按活跃时间"];
    NSMutableArray *selMethod = [NSMutableArray arrayWithArray:@[@"defaultSortMethod" ,@"timeSortingMethod"]];
    WH_JX_SelectMenuView *menuView = [[WH_JX_SelectMenuView alloc] initWithTitle:titles image:nil cellHeight:45];
    menuView.sels = selMethod;
    menuView.delegate = self;
    [g_App.window addSubview:menuView];
}

- (void)didMenuView:(WH_JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index {
    NSString *method = MenuView.sels[index];
    SEL _selector = NSSelectorFromString(method);
    [self performSelectorOnMainThread:_selector withObject:nil waitUntilDone:YES];
}

#pragma mark 默认排序
- (void)defaultSortMethod {
    self.isTimeSorting = NO;
    
    self.user = [[WH_JXUserObject sharedUserInstance] getUserById:self.room.roomJid];
    
    _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
    [self filtrateMember];
    if (self.room.members.count != _array.count) {
        [self WH_getServerData];
    }else{
        if (_array.count > 0) {
            if ([self.user.joinTime timeIntervalSince1970] <= 0) {
                
                memberData *member = _array.lastObject;
                self.user.joinTime = [NSDate dateWithTimeIntervalSince1970:member.createTime];
            }
            
            [self refresh];
        }else {
            [self WH_getServerData];
        }
    }
    
}

#pragma mark 按照事件排序
- (void)timeSortingMethod {
    self.isTimeSorting = YES;
    
    [self WH_getServerData];
}

//新版群成员列表
- (void)addRoomMemberList{
    self.listView = [[WH_RoomMemberListView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH,JX_SCREEN_HEIGHT - JX_SCREEN_TOP)];
    self.listView.room = self.room;//????
    [self.view addSubview:self.listView];
    self.listView.dataSourceArr = _array;
    //点击回调
    self.listView.selectedIndex = ^(NSIndexPath * _Nonnull indexP, memberData * _Nonnull member) {
        //跳转到查看信息接口
        //        memberData *data = [self.room getMember:g_myself.userId];
        if (([member.role intValue] != 1 && [member.role intValue] != 2) && !self.room.allowSendCard) {
            [g_App showAlert:Localized(@"JX_NotAllowMembersSeeInfo")];
            return;
        }
        WH_JXUserInfo_WHVC* userVC = [WH_JXUserInfo_WHVC alloc];
        userVC.wh_userId = [NSString stringWithFormat:@"%ld",member.userId];
        userVC.wh_fromAddType = 3;
        userVC = [userVC init];
        [g_navigation pushViewController:userVC animated:YES];
    };
}



- (void)WH_scrollToPageUp {
    self.user.joinTime = [NSDate dateWithTimeIntervalSince1970:0];
    [self WH_getServerData];
}
- (void)WH_scrollToPageDown {
    [self WH_getServerData];
}

- (void)WH_getServerData {
    self.user.joinTime = 0;
    [g_server WH_roomMemberGetMemberListByPageWithRoomId:self.room.roomId joinTime:[self.user.joinTime timeIntervalSince1970] toView:self];
}

- (void)refresh {
 
    _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
    [self filtrateMember];
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    
    ////群主群管理 不参与排序
    NSMutableArray * allMemberDataArr = [[NSMutableArray alloc] init];
    
    if (self.type == Type_DelMember) {
        [_wait start];
//        for (memberData *data in _array) {
//            memberData *datas = [self.room getMember:[NSString stringWithFormat:@"%li" ,data.userId]];
//            if (self.room.showMember || [datas.role integerValue] == 1 || [datas.role integerValue] == 2) {
//                allMemberDataArr = [self checkQueueManager:_array];
//            }else{
//                allMemberDataArr = [self checkGroupManagement:_array];
//
//            }
//        }
        
        memberData *data = [self.room getMember:g_myself.userId];
        
        if (self.room.showMember || [data.role integerValue] == 1 || [data.role integerValue] == 2) {
            allMemberDataArr = [self checkQueueManager:_array];
        }else{
            allMemberDataArr = [self checkGroupManagement:_array];
            
        }
    }else{
        memberData *data = [self.room getMember:g_myself.userId];
        
        if (self.room.showMember || [data.role integerValue] == 1 || [data.role integerValue] == 2) {
            allMemberDataArr = [self checkQueueManager:_array];
        }else{
            allMemberDataArr = [self checkGroupManagement:_array];
            
        }
    }
    
    
    //对剩余的进行排序
    //排序 Person对象
    [BMChineseSort sortAndGroup:allMemberDataArr key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            [_wait stop];
            [self insertToTopWithTitleArr:sectionTitleArr sortedArr:sortedObjArr result:^(NSMutableArray *titleArr, NSMutableArray *sortedArr) {
                self.indexArray = titleArr;
                self.letterResultArr = sortedArr;
                [_table reloadData];
            }];
            //            self.indexArray = sectionTitleArr;
            //            self.letterResultArr = sortedObjArr;
            //            [_table reloadData];
          
        }
    }];
}

- (void)customSearchTextField{
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 50)];
    backView.backgroundColor = HEXCOLOR(0xffffff);
    [self.view addSubview:backView];
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 8, backView.frame.size.width - 20, 30)];
    _seekTextField.placeholder = [NSString stringWithFormat:@"%@", Localized(@"JX_EnterKeyword")];
    _seekTextField.backgroundColor = g_factory.inputBackgroundColor;
    if (@available(iOS 10, *)) {
        _seekTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", Localized(@"JX_EnterKeyword")] attributes:@{NSForegroundColorAttributeName:g_factory.inputDefaultTextColor}];
    } else {
        [_seekTextField setValue:g_factory.inputDefaultTextColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    [_seekTextField setFont:g_factory.inputDefaultTextFont];
    _seekTextField.textColor = HEXCOLOR(0x333333);
    _seekTextField.layer.borderWidth = 0.5;
    _seekTextField.layer.borderColor = g_factory.inputBorderColor.CGColor;
    _seekTextField.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:251/255.0 blue:252/255.0 alpha:1.0].CGColor;
    _seekTextField.layer.cornerRadius = 15;
    
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
    
    self.tableView.tableHeaderView = backView;
    
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length <= 0) {
        
        [self.tableView reloadData];
        return;
    }
    
    [_searchArray removeAllObjects];

    for (NSInteger i = 0; i < _array.count; i ++) {
        memberData *data = _array[i];
        WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
        allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
        NSString *name = [NSString string];
        if ([[NSString stringWithFormat:@"%ld",_room.userId] isEqualToString:MY_USER_ID]) {
            name = data.lordRemarkName ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
        }else {
            name = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
        }

        NSString *userStr = [name lowercaseString];
        NSString *textStr = [textField.text lowercaseString];
        if ([userStr rangeOfString:textStr].location != NSNotFound) {
            [_searchArray addObject:data];
        }
    }
    [self.tableView reloadData];
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_seekTextField.text.length > 0 || self.isTimeSorting) {
        return 1;
    }
    return [self.indexArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_seekTextField.text.length > 0) {
        return Localized(@"JXFriend_searchTitle");
    }else if (self.isTimeSorting) {
        return nil;
    }else {
        return [self.indexArray objectAtIndex:section];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_seekTextField.text.length > 0) {
        return _searchArray.count;
    }else if (self.isTimeSorting) {
        return self.timeArray.count;
    }else{
        return [[self.letterResultArr objectAtIndex:section] count];
    }
    
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (_seekTextField.text.length > 0 || self.isTimeSorting) {
        return nil;
    }
    if (self.indexArray.count>1) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.indexArray];
        [tempArr removeObjectAtIndex:0];
        return tempArr;
    }
    
    return self.indexArray;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if (self.indexArray.count>1) {
        return index+1;
    }
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.isTimeSorting) {
        return 0;
    }else{
        return 30;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [UIView new];
    UILabel *titleLbl = [UILabel new];
    [header addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(16);
        make.centerY.offset(0);
    }];
    titleLbl.textColor = HEXCOLOR(0x8C9AB8);
    titleLbl.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 16];
    
    NSString *title = nil;
    if (_seekTextField.text.length > 0) {
        title = Localized(@"JXFriend_searchTitle");
    } else {
        title = [self.indexArray objectAtIndex:section];
    }
    titleLbl.text = title;
    
    return header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    WH_JXRoomMemberList_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_JXRoomMemberList_WHCell" forIndexPath:indexPath];
    cell.curManager = [NSString stringWithFormat:@"%ld",_room.userId];
    memberData *data;
    if (_seekTextField.text.length > 0) {
        data = _searchArray[indexPath.row];
    }else if (self.isTimeSorting) {
        data = [self.timeArray objectAtIndex:indexPath.row];
    }else{
        data = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    memberData *d = [self.room getMember:[NSString stringWithFormat:@"%ld",data.userId]];
    cell.room = self.room;
    cell.role = [d.role intValue];
//    cell.type = self.type;
    cell.data = data;
    
//    if (IS_SHOW_BATCHDELETION_ROOMMEMBERS) {
//        //允许批量删除
//        if (self.type == Type_DelMember) {
//            if ([d.role intValue] == 1 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])) {
//                // && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])
//                //当前用户是群主
//                self.roleMark = 1;
//                [cell.checkBtn setHidden:YES];
//                
//            }else if ([d.role intValue] == 2 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])) {
//                //[d.role intValue] == 2 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])
//                //当前用户是管理员
//                self.roleMark = 2;
//                [cell.checkBtn setHidden:YES];
//                
//            }
//            if (((self.roleMark == 1) && [d.role intValue] != 1) || (self.roleMark == 2 && [d.role intValue] != 1 && [d.role intValue] != 2)) {
//                [cell.roleLabel setHidden:YES];
//                
//                /*//删除群成员
//                QCheckBox *btn = [[QCheckBox alloc] initWithDelegate:self];
//                btn.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - 20, 20, 20, 20);
//                btn.tag = indexPath.section * 1000 + indexPath.row;
//                BOOL b = NO;
//                NSString *s = [NSString stringWithFormat:@"%ld",data.userId];
//                b = [_existSet containsObject:s];
//                
//                BOOL flag = NO;
//                for (NSInteger i = 0; i < self.userIds.count; i++) {
//                    NSString *selUserId = [self.userIds objectAtIndex:i];
//                    if ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:selUserId]) {
//                        flag = YES;
//                        break;
//                    }
//                }
//                if (b) {
//                    btn.selected = b;
//                }else{
//                    btn.selected = flag;
//                }
//                
//                [self didSelectedCheckBox:btn checked:btn.selected];
//                
//                //        btn.selected = b;
//                btn.userInteractionEnabled = !b;
//                [cell addSubview:btn];
//                
//                [self.checkBoxArr addObject:btn];*/
//                
//                [cell.checkBtn setHidden:NO];
//                
//                [cell.checkBtn setFrame:CGRectMake(JX_SCREEN_WIDTH - 30 - 20, 20, 20, 20)];
////                [cell.checkBtn setDelegate:self];
//                [cell.checkBtn setTag:indexPath.section * 1000 + indexPath.row];
//                
////                BOOL b = NO;
////                NSString *s = [NSString stringWithFormat:@"%ld",data.userId];
////                b = [_existSet containsObject:s];
//                
//                BOOL flag = NO;
//                for (NSInteger i = 0; i < self.userIds.count; i++) {
//                    NSString *selUserId = [self.userIds objectAtIndex:i];
//                    if ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:selUserId]) {
//                        flag = YES;
//                        break;
//                    }
//                }
////                if (b) {
////                    cell.checkBtn.selected = b;
////                }else{
////                    cell.checkBtn.selected = flag;
////                }
//                
//                cell.checkBtn.selected = flag;
//                cell.checkBtn.userInteractionEnabled = !flag;
//                
////                [self didSelectedCheckBox:cell.checkBtn checked:cell.checkBtn.selected];
//                
//                //        btn.selected = b;
//                
////                [cell addSubview:btn];
//                
//                [self.checkBoxArr addObject:cell.checkBtn];
//            }
//            
//        }
//    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    memberData *data = [self.room getMember:g_myself.userId];
    
    memberData * member;
    if (_seekTextField.text.length > 0) {
        member = _searchArray[indexPath.row];
    }else if (self.isTimeSorting){
        member = [self.timeArray objectAtIndex:indexPath.row];
    }else{
        member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
//    if (([data.role intValue] != 1 && [data.role intValue] != 2) && !self.room.allowSendCard) {
//        [g_App showAlert:Localized(@"JX_NotAllowMembersSeeInfo")];
//        return;
//    }
    /// 获取当前登录用户
    memberData *loginMember = [self getCurrentLoginMerber];
    /// 当前登录用户是不是管理者
    BOOL isManger = [self isManger:loginMember];

    /// 当前登录用户不是管理者 并且开启了不允许群成员私聊 进入判断
    if (!isManger && !self.room.allowSendCard) {
        /// 被点击用户不是自己 进入判断
        if (member.userId != loginMember.userId && ![self isManger:member]) {
            return;
        }
    }

    switch (self.type) {
        case Type_Default:{
            WH_JXUserInfo_WHVC* userVC = [WH_JXUserInfo_WHVC alloc];
            userVC.wh_userId = [NSString stringWithFormat:@"%ld",member.userId];
            userVC.wh_fromAddType = 3;
            userVC.isAddFriend = data.isAddFirend;
            userVC = [userVC init];
            
            [g_navigation pushViewController:userVC animated:YES];
        }
            break;
        case Type_NotTalk:{
            //禁止某人聊天
//            memberData *d = [self.room getMember:[NSString stringWithFormat:@"%ld",member.userId]];
            if ([member.role intValue] == 1 || [member.role intValue] == 2) {
                [g_App showAlert:Localized(@"JX_Can'tBanManager")];
                return;
            }
            if ([member.role intValue] == 4) {
                [g_App showAlert:Localized(@"JX_YouCan'tKeepYourMouthShut")];
                return;
            }
            if ([member.role intValue] == 5) {
                [g_App showAlert:@"不能禁言监控人"];
                return;
            }
            _currentMember = member;
            [self onDisableSay:nil];
        }
            break;
        case Type_DelMember:{
            if (IS_SHOW_BATCHDELETION_ROOMMEMBERS) {
                //允许批量删除
//                memberData *mData = [self.room getMember:[NSString stringWithFormat:@"%li" ,member.userId]];
//                if ([mData.role intValue] == 1 || [mData.role intValue] == 2) {
//
//                    [g_App showAlert:Localized(@"JX_Can'tDeleteManager")];
//                    return;
//                }
                
                memberData *user;
                if (self.seekTextField.text.length > 0) {
                    user = self.searchArray[indexPath.row];
                }else{
                    user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                }
                if (![_existSet containsObject:[NSString stringWithFormat:@"%ld",user.userId]]) {
                    QCheckBox *checkBox = nil;
                    for (NSInteger i = 0; i < _checkBoxArr.count; i ++) {
                        QCheckBox *btn = _checkBoxArr[i];
                        if (btn.tag / 1000 == indexPath.section && btn.tag % 1000 == indexPath.row) {
                            checkBox = btn;
                            break;
                        }
                    }
                    checkBox.selected = !checkBox.selected;
                    [self didSelectedCheckBox:checkBox checked:checkBox.selected];
                }
            }else{
                
                memberData *mData = [self.room getMember:[NSString stringWithFormat:@"%li" ,member.userId]];
                if ([mData.role intValue] == 1 || [mData.role intValue] == 2) {
                    
                    [g_App showAlert:Localized(@"JX_Can'tDeleteManager")];
                    return;
                }
                _currentMember = member;
                
                WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
                allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",member.userId]];
                NSString *name;
                if ([[NSString stringWithFormat:@"%ld",_room.userId] isEqualToString:MY_USER_ID]) {
                    name = member.lordRemarkName.length > 0  ? member.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
                }else {
                    name = allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
                }
                
                
                [g_App showAlert:[NSString stringWithFormat:@"%@ %@",Localized(@"JX_DetermineToDelete"),name] delegate:self tag:2457 onlyConfirm:NO];
            }
        }
            break;
        case Type_AddNotes:{
            WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
            allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",member.userId]];
            NSString *name = [NSString string];
            if ([[NSString stringWithFormat:@"%ld",_room.userId] isEqualToString:MY_USER_ID]) {
                name = member.lordRemarkName ? member.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }else {
                name = allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }
            
            //修改名称
            WH_ContentModification_WHView *cmView = [[WH_ContentModification_WHView alloc] initWithFrame:CGRectMake(20, (JX_SCREEN_HEIGHT - 228)/2, JX_SCREEN_WIDTH - 40, 228) title:Localized(@"WaHu_JXRoomMember_WaHuVC_UpdateNickName") content:name isEdit:YES isLimit:YES];
            [cmView showInWindowWithMode:CustomAnimationModeDrop inView:nil bgAlpha:0.5 needEffectView:NO];
            
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
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(roomMemberList:addNotesVC:)]) {
                        memberData* p = [_room getMember:[NSString stringWithFormat:@"%ld",member.userId]];
                        if ([p.role intValue] == 1) {
                            p.userNickName = content;
                        }else {
                            p.lordRemarkName = content;
                        }
                        [p update];
                        
                        _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
                        [self filtrateMember];
                        //选择拼音 转换的 方法
                        BMChineseSortSetting.share.sortMode = 2; // 1或2
                        //排序 Person对象
                        [BMChineseSort sortAndGroup:_array key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                            if (isSuccess) {
                                self.indexArray = sectionTitleArr;
                                self.letterResultArr = sortedObjArr;
                                [_table reloadData];
                            }
                        }];
                        
                        //        //根据Person对象的 name 属性 按中文 对 Person数组 排序
                        //        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
                        //        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];
                        
                        [self.delegate roomMemberList:self addNotesVC:nil];
                    }
                }
            }];
        }
            break;
        default:
            break;
    }
}
- (void)filtrateMember {
    NSMutableArray *tempArr = [NSMutableArray array];
    if (!self.room.showMember) {
        for (memberData *member in _array) {
            if ([member.role intValue] <= 2 || [[NSString stringWithFormat:@"%ld", member.userId] isEqualToString:MY_USER_ID]) {
                [tempArr addObject:member];
            }
        }
        _array = [tempArr mutableCopy];
    }
}
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    id user;
    if (self.seekTextField.text.length > 0) {
        user = self.searchArray[checkbox.tag % 1000];
    }else{
        user = [[self.letterResultArr objectAtIndex:checkbox.tag / 1000] objectAtIndex:checkbox.tag % 1000];
    }
    NSString *userId;
    NSString *userNickname;
    if ([user isKindOfClass:[WH_JXUserObject class]]) {
        WH_JXUserObject *userO = (WH_JXUserObject *)user;
        userId = [NSString stringWithFormat:@"%@",userO.userId];
        userNickname = [NSString stringWithFormat:@"%@",userO.userNickname];
    }else if ([user isKindOfClass:[memberData class]]) {
        memberData *member = (memberData *)user;
        userId = [NSString stringWithFormat:@"%ld",member.userId];
        userNickname = [NSString stringWithFormat:@"%@",member.userNickName];
    }
    if(checked){
        if (![_userIds containsObject:userId]) {
            [_userIds addObject:userId];
            [_userNames addObject:userNickname];
            [self.set addObject:[NSNumber numberWithInteger:checkbox.tag]];
        }
    }
    else{
        if ([_userIds containsObject:userId]) {
            [_userIds removeObject:userId];
            [_userNames removeObject:userNickname];
            [self.set removeObject:[NSNumber numberWithInteger:checkbox.tag]];
        }
    }
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

-(void)onSaveNickName:(WH_JXInputValue_WHVC*)vc{
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomMemberList:addNotesVC:)]) {
        memberData* p = [_room getMember:vc.userId];
        if ([p.role intValue] == 1) {
            p.userNickName = vc.value;
        }else {
            p.lordRemarkName = vc.value;
        }
        [p update];
        
        _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
        [self filtrateMember];
        //选择拼音 转换的 方法
        BMChineseSortSetting.share.sortMode = 2; // 1或2
        //排序 Person对象
        [BMChineseSort sortAndGroup:_array key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
            if (isSuccess) {
                self.indexArray = sectionTitleArr;
                self.letterResultArr = sortedObjArr;
                [_table reloadData];
            }
        }];

//        //根据Person对象的 name 属性 按中文 对 Person数组 排序
//        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];

        [self.delegate roomMemberList:self addNotesVC:vc];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2457) {
        if (buttonIndex == 1) {
            
            [self onDelete:nil];
        }
    }
}

-(void)onDisableSay:(WH_JXImageView*)sender{

    WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[] names:@[Localized(@"JXAlert_NotGag"),Localized(@"JXAlert_GagTenMinute"),Localized(@"JXAlert_GagOneHour"),Localized(@"JXAlert_GagOne"),Localized(@"JXAlert_GagThere"),Localized(@"JXAlert_GagOneWeek"),Localized(@"JXAlert_GagFifteen")]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];

}

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    NSTimeInterval n = [[NSDate date] timeIntervalSince1970];
    memberData* member = _currentMember;
    switch (index) {
        case 0:
            member.talkTime = 0;
            break;
        case 1:
            member.talkTime = 10*60+n;
            break;
        case 2:
            member.talkTime = 1*3600+n;
            break;
        case 3:
            member.talkTime = 24*3600+n;
            break;
        case 4:
            member.talkTime = 3*24*3600+n;
            break;
        case 5:
            member.talkTime = 7*24*3600+n;
            break;
        case 6:
            member.talkTime = 15*24*3600+n;
            break;
        default:
            break;
    }
    
    [g_server WH_setDisableSayWithRoomId:self.room.roomId member:member toView:self];
    
    self.toUserId = [NSString stringWithFormat:@"%ld",member.userId];
    self.toUserName = member.userNickName;
    
//    [self sendSelfMsg:kRoomRemind_DisableSay content:[NSString stringWithFormat:@"%f",member.talkTime]];
    
    member = nil;
}

-(void)sendSelfMsg:(int)type content:(NSString*)content{
    WH_JXMessageObject* p = [[WH_JXMessageObject alloc]init];
    p.fromUserId = MY_USER_ID;
    p.fromUserName = MY_USER_NAME;
    p.objectId = self.room.roomJid;
    p.fromId = MY_USER_ID;
    p.type = [NSNumber numberWithInt:type];
    p.content = content;
    p.toUserId = _toUserId;
    p.toUserName = _toUserName;
    p.timeSend = [NSDate date];
    [p insert:p.fromId];
    [p notifyNewMsg];
    
}

-(void)onDelete:(WH_JXImageView*)sender{
    
    [g_server WH_delRoomMemberWithRoomId:self.room.roomId userId:_currentMember.userId toView:self];

}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:wh_act_deleteMemebers]) {
        
        NSLog(@"========dict:%@--array:%@" ,dict ,array1);
        [self.userIds removeAllObjects];
        [self.userNames removeAllObjects];
        
        NSString *resultMsg = [dict objectForKey:@"resultMsg"];
        NSDictionary *dictData = [dict objectForKey:@"data"];
//        NSString *filedUserIds = [dictData objectForKey:@"delFailedUserId"];
        
        [GKMessageTool showText:resultMsg];
        
        NSString *successedUserIds = [dictData objectForKey:@"delSucceedUserId"];
        NSArray *userIds = [successedUserIds componentsSeparatedByString:@","];
        NSArray *members = [NSArray arrayWithArray:self.room.members];
        for (int i = 0; i < members.count; i++) {
            memberData *data = [members objectAtIndex:i];
            
            for (int j = 0; j < userIds.count; j++) {
                NSString *userId = [userIds objectAtIndex:j];
                if ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:userId]) {
                    [self.chatRoom removeUser:data];
                    if ([self.room.members containsObject:data]) {
                        [self.room.members removeObject:data];
                    }
                    
                    [data remove];
                }
            }
        }
        
        if (_seekTextField.text.length > 0) {
            for (int j = 0; j < _searchArray.count; j++) {
                memberData *data = [_searchArray objectAtIndex:j];
                for (int m = 0; m < userIds.count; m++) {
                    NSString *uId = [userIds objectAtIndex:m];
                    if ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:uId]) {
                        [_searchArray removeObject:data];
                    }
                }
                
            }
            [_table reloadData];
        }
        
        if ([self.delegate respondsToSelector:@selector(roomMemberList:delMembers:)]) {
            [self.delegate roomMemberList:self delMembers:userIds];
        }
        
        if (self.isTimeSorting) {
            [self WH_getServerData];
        }else{
            //调用下刷新
            if (_seekTextField.text.length > 0) {
                [_table reloadData];
            }else{
               [self refresh];
            }
            
        }
    }
    if( [aDownload.action isEqualToString:wh_act_roomMemberSet] ){
        
        [g_App showAlert:Localized(@"JXAlert_SetOK")];
        for (memberData *m in self.room.members) {
            if (m.userId == _currentMember.userId) {
                m.talkTime = _currentMember.talkTime;
                [self.tableView reloadData];
                break;
            }
        }
    }
    
    if( [aDownload.action isEqualToString:wh_act_roomMemberDel] ){

        //在xmpp中删除成员
        [self.chatRoom removeUser:_currentMember];
        [self.room.members removeObject:_currentMember];
        [_currentMember remove];
        if ([self.delegate respondsToSelector:@selector(roomMemberList:delMember:)]) {
            [self.delegate roomMemberList:self delMember:_currentMember];
        }
        
        if (self.isTimeSorting) {
            [self WH_getServerData];
        }else{
            _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
            [self filtrateMember];
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_array key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];
            
            
            //调用下刷新
            [self refresh];
        }
//        //根据Person对象的 name 属性 按中文 对 Person数组 排序
//        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];

        [g_App showAlert:Localized(@"JXAlert_DeleteOK")];
        
    }

    if ([aDownload.action isEqualToString:wh_act_roomMemberGetMemberListByPage]) {
        
        [self WH_stopLoading];
        
        if (array1.count < kRoomMemberListNum) {
            self.wh_isShowFooterPull = NO;
        }
        
        NSDictionary *lastDict = array1.lastObject;
        self.user.joinTime = [NSDate dateWithTimeIntervalSince1970:[lastDict[@"createTime"] longValue]];
        [self.user updateJoinTime];
        
        for (NSDictionary *member in array1) {
            memberData* option = [[memberData alloc] init];
            [option WH_getDataFromDict:member];
            option.roomId = self.room.roomId;
            [option insert];
        }
        if (self.isTimeSorting) {
            [self.timeArray removeAllObjects];
            
            for (NSDictionary *member in array1) {
                memberData *option = [[memberData alloc] init];
                [option WH_getDataFromDict:member];
                option.roomId = self.room.roomId;
                
                if (self.room.showMember) {
                    [self.timeArray addObject:option];
                }else {
                    if ([option.role integerValue] == 1 || [option.role integerValue] == 2) {
                        [self.timeArray addObject:option];
                    }
                }
                
            }
            [_table reloadData];
        }else{
            [self refresh];
        }
        
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
    if (![aDownload.action isEqualToString:wh_act_roomMemberGetMemberListByPage]) {
//        [_wait start];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)managerMemberDataArr{
    if (!_managerMemberDataArr) {
        _managerMemberDataArr = [NSMutableArray array];
    }
    return _managerMemberDataArr;
}

#pragma mark - 筛选出群主以及群管理
- (NSMutableArray *) checkQueueManager:(NSArray *)membersArr{
    [self.managerMemberDataArr removeAllObjects];
    for (memberData *data in _array) {
        memberData *datas = [self.room getMember:[NSString stringWithFormat:@"%li" ,data.userId]];
        if ([datas.role integerValue] == 1 || [datas.role integerValue] == 2) {
            //查询出群主,管理员
            [self.managerMemberDataArr addObject:data];
        }
    }
    
    NSMutableArray *allMemberDataArr = [NSMutableArray arrayWithArray:_array];
    //移出群管理操作
    [allMemberDataArr removeObjectsInArray:self.managerMemberDataArr];
    return allMemberDataArr;
}

#pragma mark -群主或群管理员列表
- (NSMutableArray *)checkGroupManagement:(NSArray *)memberArray {
    [self.managerMemberDataArr removeAllObjects];
    NSMutableArray *myMemberDataArr = [NSMutableArray array];
    for (memberData *data in _array) {
        if ([data.role integerValue] == 1 || [data.role integerValue] == 2) {
            [self.managerMemberDataArr addObject:data];
        }
        
        if ([[NSString stringWithFormat:@"%ld",data.userId] isEqualToString:MY_USER_ID] && [data.role integerValue] != 1 && [data.role integerValue] != 2) {
            [myMemberDataArr addObject:data];
        }
    }
    
    return myMemberDataArr;
}

#pragma mark - 插入群主群管理到顶部
- (void) insertToTopWithTitleArr:(NSArray *)titleArr sortedArr:(NSArray *)sorted result : (void (^)(NSMutableArray *titleArr, NSMutableArray *sortedArr))resultBlock{
    //把群主群管理插入到 # 下面
    NSMutableArray *newSectionTitleArr = [NSMutableArray arrayWithArray:titleArr];
    NSMutableArray *newSortedObjArr = [NSMutableArray arrayWithArray:sorted];
    
    if (self.room.showMember) {
        //直接插入到第一个
        if (self.managerMemberDataArr.count > 0) {
            [newSectionTitleArr insertObject:@"群管理" atIndex:0];
            [newSortedObjArr insertObject:self.managerMemberDataArr atIndex:0];
        }
    }else{
        //直接插入到第一个
        if (self.managerMemberDataArr.count > 0) {
            [newSectionTitleArr insertObject:@"群管理" atIndex:0];
            [newSortedObjArr insertObject:self.managerMemberDataArr atIndex:0];
        }
        
    }
    
    
    
//    if (![newSectionTitleArr containsObject:@"#"]) {
//        //直接插入到第一个
//        if (newSectionTitleArr.count > 0) {
//            [newSectionTitleArr insertObject:@"#" atIndex:0];
//        }
//        if (newSortedObjArr.count > 0) {
//            [newSortedObjArr insertObject:self.managerMemberDataArr atIndex:0];
//        }
//    }else{
//        //插入到第一个
//        //获取排序好的第一个数组
//        NSMutableArray *firstOne = newSortedObjArr.firstObject;
//        //获取群管理数组
//        NSMutableArray *managerArr = [NSMutableArray arrayWithArray:self.managerMemberDataArr];
//        [managerArr addObjectsFromArray:firstOne];
//        //替换
//        [newSortedObjArr replaceObjectAtIndex:0 withObject:managerArr];
//    }
    
    
    
    resultBlock(newSectionTitleArr, newSortedObjArr);
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_getUserFollowSuccess {
    NSLog(@"Get User Succrss");
}
@end
