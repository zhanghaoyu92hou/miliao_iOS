//
//  WH_DeleteRoomMembers_ViewController.m
//  Tigase
//
//  Created by Apple on 2020/4/17.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_DeleteRoomMembers_ViewController.h"

#import "BMChineseSort.h"
#import "QCheckBox.h"

#import "WH_JXRoomMemberList_WHCell.h"

@interface WH_DeleteRoomMembers_ViewController ()<QCheckBoxDelegate>

@property (nonatomic, strong) memberData *currentMember;

@end

@implementation WH_DeleteRoomMembers_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Localized(@"JX_DeleteGroupMemebers")
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.wh_isShowFooterPull = NO;
    self.title = Localized(@"JX_DeleteGroupMemebers");
    [self WH_createHeadAndFoot];
    
    self.searchArray = [[NSMutableArray alloc] init];
    self.userIds = [[NSMutableArray alloc] init];
    self.userNames = [[NSMutableArray alloc] init];
    self.set = [[NSMutableSet alloc] init];
    self.indexArray = [[NSMutableArray alloc] init];
    self.letterResultArr = [[NSMutableArray alloc] init];
    self.checkBoxArr = [[NSMutableArray alloc] init];
    self.array = [[NSMutableArray alloc] init];
    
    if (IS_SHOW_BATCHDELETION_ROOMMEMBERS) {
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
    
    [self customView];
    
}

- (void)customView{
    CGFloat headerViewH = 44.f;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, headerViewH)];
    header.backgroundColor = [UIColor whiteColor];
    [self createSeekTextField:header isFriend:NO];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.offset(JX_SCREEN_TOP+headerViewH);
    }];
    self.seekTextField.placeholder = [NSString stringWithFormat:@"%@",Localized(@"JX_EnterKeyword")];
    self.tableView.tableHeaderView = header;
    
    _table.backgroundColor = g_factory.globalBgColor;
    
    [self requestData];
}

- (void)requestData {
    self.user = [[WH_JXUserObject sharedUserInstance] getUserById:self.room.roomJid];
    self.array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
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

- (void)WH_getServerData {
    self.user.joinTime = 0;
    [g_server WH_roomMemberGetMemberListByPageWithRoomId:self.room.roomId joinTime:[self.user.joinTime timeIntervalSince1970] toView:self];
}

- (void)refresh {
 
    _array = (NSMutableArray *)[memberData fetchAllMembers:self.room.roomId sortByName:NO];
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    
    ////群主群管理 不参与排序
    NSMutableArray * allMemberDataArr = [[NSMutableArray alloc] init];
    
    allMemberDataArr = [self checkQueueManager:_array];
    
//    for (memberData *data in _array) {
//        memberData *datas = [self.room getMember:[NSString stringWithFormat:@"%li" ,data.userId]];
//        if (self.room.showMember || [datas.role integerValue] == 1 || [datas.role integerValue] == 2) {
//            allMemberDataArr = [self checkQueueManager:_array];
//        }else{
//            allMemberDataArr = [self checkGroupManagement:_array];
//
//        }
//    }
    
    
    //对剩余的进行排序
    //排序 Person对象
    [BMChineseSort sortAndGroup:allMemberDataArr key:@"userNickName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            
            [self insertToTopWithTitleArr:sectionTitleArr sortedArr:sortedObjArr result:^(NSMutableArray *titleArr, NSMutableArray *sortedArr) {
                self.indexArray = titleArr;
                self.letterResultArr = sortedArr;
                [_table reloadData];
            }];
          
        }
    }];
}

#pragma mark 确定删除事件
- (void) confirmMethod {
    NSLog(@"self.userids:%@ --- self.userNames:%@" ,self.userIds ,self.userNames);
    if (self.userIds.count == 0) {
        [GKMessageTool showText:@"请选择想要删除的成员！"];
        return;
    }else{
        NSString *userIdsStr = [self.userIds componentsJoinedByString:@","];
        [g_server wh_deleteMembersWithRoomId:self.room.roomId?:@"" userId:userIdsStr?:@"" toView:self];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    [super textFieldDidChange:textField];
    
    if (textField.text.length <= 0) {
        [self refresh];
        return;
    }
    
    [self.searchArray removeAllObjects];
    
    for (NSInteger i = 0; i < self.array.count; i ++) {
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
            [self.searchArray addObject:data];
        }
    }
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.seekTextField resignFirstResponder];
}

- (void)WH_scrollToPageUp {
    [self refresh];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.seekTextField.text.length > 0) {
        return 1;
    }else {
        return self.indexArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.seekTextField.text.length > 0) {
        return self.searchArray.count;
    }else{
        return [[self.letterResultArr objectAtIndex:section] count];
    }
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.seekTextField.text.length > 0) {
        return nil;
    }
    
    if (self.indexArray.count > 1) {
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
    return 30;
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
    if (self.seekTextField.text.length > 0) {
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellName = [NSString stringWithFormat:@"cell_%ld_%ld" ,(long)indexPath.section ,(long)indexPath.row];
    WH_JXRoomMemberList_WHCell *cell = nil;
    
//    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    cell = [[WH_JXRoomMemberList_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    
    cell.curManager = [NSString stringWithFormat:@"%ld",_room.userId];
    memberData *data;
    if (self.seekTextField.text.length > 0) {
        data = self.searchArray[indexPath.row];
    }else {
        data = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    memberData *d = [self.room getMember:[NSString stringWithFormat:@"%ld",data.userId]];
    cell.room = self.room;
    cell.role = [d.role intValue];
    cell.data = data;
    
    if (IS_SHOW_BATCHDELETION_ROOMMEMBERS) {
        //允许批量删除
        if ([d.role intValue] == 1 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])) {
            //当前用户是群主
            self.roleMark = 1;
            
        }else if ([d.role intValue] == 2 && ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:g_myself.userId])) {
            //当前用户是管理员
            self.roleMark = 2;
        }
        if (((self.roleMark == 1) && [d.role intValue] != 1) || (self.roleMark == 2 && [d.role intValue] != 1 && [d.role intValue] != 2) ) {
            [cell.roleLabel setHidden:YES];
            
            //删除群成员
            QCheckBox *btn = [[QCheckBox alloc] initWithDelegate:self];
            btn.frame = CGRectMake(JX_SCREEN_WIDTH - 10 - 20, 20, 20, 20);
            btn.tag = indexPath.section * 1000 + indexPath.row;
            BOOL b = NO;
            NSString *s = [NSString stringWithFormat:@"%ld",data.userId];
            b = [self.existSet containsObject:s];
            
            BOOL flag = NO;
            for (NSInteger i = 0; i < self.userIds.count; i++) {
                NSString *selUserId = [self.userIds objectAtIndex:i];
                if ([[NSString stringWithFormat:@"%li" ,data.userId] isEqualToString:selUserId]) {
                    flag = YES;
                    break;
                }
            }
            if (b) {
                btn.selected = b;
            }else{
                btn.selected = flag;
            }
            
            [self didSelectedCheckBox:btn checked:btn.selected];
            
            //        btn.selected = b;
            btn.userInteractionEnabled = !b;
            [cell addSubview:btn];
            
            [self.checkBoxArr addObject:btn];
        }

    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    memberData *data = [self.room getMember:g_myself.userId];
    memberData * member;
    if (self.seekTextField.text.length > 0) {
        member = self.searchArray[indexPath.row];
    }else{
        member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    if (IS_SHOW_BATCHDELETION_ROOMMEMBERS) {
        
        memberData *mData = [self.room getMember:[NSString stringWithFormat:@"%li" ,member.userId]];
        if ([mData.role intValue] == 1 || [mData.role intValue] == 2) {
            
            [g_App showAlert:Localized(@"JX_Can'tDeleteManager")];
            return;
        }
        
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
        //允许批量删除
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
            
            if ([self.delegate respondsToSelector:@selector(deleteRoomMembers:members:)]) {
                [self.delegate deleteRoomMembers:self members:self.userIds];
            }
            
            //调用下刷新
        if (self.seekTextField.text.length > 0) {
            [_table reloadData];
        }else{
            [self refresh];
        }
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
        
        [self refresh];
        
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
    
    resultBlock(newSectionTitleArr, newSortedObjArr);
}


@end
