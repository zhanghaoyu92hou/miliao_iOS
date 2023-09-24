//
//  WH_SelectReceiveRedPacket_ViewController.m
//  Tigase
//
//  Created by Apple on 2020/2/27.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_SelectReceiveRedPacket_ViewController.h"

#import "BMChineseSort.h"
#import "WH_JX_WHCell.h"

#import "QCheckBox.h"

@interface WH_SelectReceiveRedPacket_ViewController ()

@end

@implementation WH_SelectReceiveRedPacket_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.isClose = YES;
    self.wh_isGotoBack   = YES;
    self.wh_isShowFooterPull = NO;
    self.title = @"指定可领";
    [self WH_createHeadAndFoot];
    
    _userIds = [NSMutableArray array];
    _userNames = [NSMutableArray array];
    _set = [[NSMutableSet alloc] init];
    _checkBoxArr = [[NSMutableArray alloc] init];
    _array = [[NSMutableArray alloc] init];
    self.searchArray = [[NSMutableArray alloc] init];
    
    UIButton *confirm = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirm setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [confirm setTitle:Localized(@"JX_Confirm") forState:UIControlStateHighlighted];
    [confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirm.frame = CGRectMake(JX_SCREEN_WIDTH - 70, JX_SCREEN_TOP - 34, 60, 24);
    [confirm addTarget:self action:@selector(confirmMethod) forControlEvents:UIControlEventTouchUpInside];
    confirm.layer.cornerRadius = CGRectGetHeight(confirm.frame) / 2.f;
    confirm.layer.masksToBounds = YES;
    confirm.backgroundColor = HEXCOLOR(0x0093FF);
    confirm.titleLabel.font = sysFontWithSize(14);
    [self.wh_tableHeader addSubview:confirm];
    
    self.membersArray = [[NSMutableArray alloc] init];
    
    [self requestData];
    
    [self customView];
}

- (void)requestData {
    NSMutableArray *data = (NSMutableArray *)[memberData fetchAllMembers:self.roomId sortByName:NO];
    for (int i = 0; i < data.count; i++) {
        memberData *mData = [data objectAtIndex:i];
        if ([[NSString stringWithFormat:@"%ld" ,mData.userId] isEqualToString:g_myself.userId]) {
            WH_JXUserObject *myObject = [[WH_JXUserObject alloc] init];
            myObject.userId = g_myself.userId;
            myObject.userNickname = g_myself.userNickname;
            myObject.remarkName = g_myself.remarkName;
            [_array addObject:myObject];
        }else{
//            WH_JXUserObject *userObject = [[WH_JXUserObject sharedUserInstance] getUserById:[NSString stringWithFormat:@"%ld" ,mData.userId]];
//            [_array addObject:userObject];
            WH_JXUserObject *myObject = [[WH_JXUserObject alloc] init];
            myObject.userId = [NSString stringWithFormat:@"%ld" ,mData.userId];
            myObject.userNickname = mData.userNickName;
            [_array addObject:myObject];
        }
    }
    
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [_table reloadData];
        }
    }];
    
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
}

- (void) textFieldDidChange:(UITextField *)textField {
    [super textFieldDidChange:textField];
    if (textField.text.length <= 0) {
//        [self getDataArrayByType];
        [_array removeAllObjects];
        [self requestData];
        return;
    }
    
    [self.searchArray removeAllObjects];
    
    for (NSInteger i = 0; i < _array.count; i ++) {
        WH_JXUserObject *data = _array[i];
//        memberData *data1 = [self.roomData getMember:g_myself.userId];
//        WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
//        allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
//        NSString *name = [NSString string];
        
//        name = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
        NSString *remarkStr = data.remarkName?:@"";
        NSString *nickNameStr = data.userNickname?:@"";
        
        NSString *reStr = [remarkStr lowercaseString];
        NSString *nickStr = [nickNameStr lowercaseString];
        
//        NSString *userStr = [name lowercaseString];
        NSString *textStr = [textField.text lowercaseString];
        if ([reStr rangeOfString:textStr].location != NSNotFound || [nickStr rangeOfString:textStr].location != NSNotFound) {
            [self.searchArray addObject:data];
        }
    }
    
    [self.tableView reloadData];
}

- (void) WH_cancelBtnAction {
    self.seekTextField.text = nil;
    [self.seekTextField resignFirstResponder];
    [_array removeAllObjects];
    [self requestData];
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.seekTextField.text.length > 0) {
        return 1;
    }
    return [self.indexArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 31;
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.seekTextField.text.length > 0) {
        return self.searchArray.count;
    }
    return [[self.letterResultArr objectAtIndex:section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.seekTextField.text.length > 0) {
        return nil;
    }
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat btnW = 20.0f;
    CGRect btnF = CGRectMake(JX_SCREEN_WIDTH - 10 - btnW, 20, btnW, btnW);
    
    WH_JX_WHCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"selVC_%ld_%ld",indexPath.section,indexPath.row];
//    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
        cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    memberData *data;
    WH_JXUserObject *data;
    if (self.seekTextField.text.length > 0) {
        data = self.searchArray[indexPath.row];
    }else{
        data = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    [_table WH_addToPool:cell];
    
    cell.isSmall = YES;
    
//    WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
//    allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
    
//    NSString *remarkStr = @"";
//    if ([data.userId isEqualToString:g_myself.userId]) {
//        remarkStr = data.lordRemarkName.length > 0 ? data.lordRemarkName :allUser.remarkName.length > 0 ? allUser.remarkName :@"";
//    }else{
//        remarkStr = allUser.remarkName.length > 0 ? allUser.remarkName :@"";
//    }
    
    NSString *remarkStr = data.remarkName?:@"";
    if (remarkStr.length > 0) {
        _tLabel = [[UILabel alloc] init];
        [_tLabel setFrame:CGRectMake(CGRectGetMaxX(cell.headImageView.frame) + 23, 8, JX_SCREEN_WIDTH - 100 -CGRectGetMaxX(cell.headImageView.frame)-14, 22)];
        [_tLabel setText:data.userNickname?:@""];
        [_tLabel setTextColor:HEXCOLOR(0x2C2F36)];
        _tLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:_tLabel];
        
        _remarkLabl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cell.headImageView.frame) +23, 30,JX_SCREEN_WIDTH - 100 -CGRectGetMaxX(cell.headImageView.frame)-14, 24 )];
        [_remarkLabl setText:[NSString stringWithFormat:@"备注:%@" ,remarkStr]];
        [_remarkLabl setTextColor:HEXCOLOR(0x969696)];
        [_remarkLabl setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:_remarkLabl];
    }else{
        cell.title = data.userNickname?:@"";
    }
    
    cell.userId = [NSString stringWithFormat:@"%@" ,data.userId];
    
    [cell WH_headImageViewImageWithUserId:nil roomId:nil];

    QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
    btn.frame = btnF;
    btn.tag = indexPath.section * 1000 + indexPath.row;
    
    if (self.disableSet) {
        btn.enabled = ![_disableSet containsObject:[NSString stringWithFormat:@"%@" ,data.userId]];
    }else{
        btn.enabled = YES;
    }
    
    [_checkBoxArr addObject:btn];
    
    [cell addSubview:btn];

    [cell setLineDisplayOrHidden:indexPath];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    memberData *user;
    WH_JXUserObject *user;
    if (self.seekTextField.text.length > 0) {
        user = self.searchArray[indexPath.row];
    }else{
        user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    if (![_existSet containsObject:[NSString stringWithFormat:@"%@",user.userId]]) {
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
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
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
            [_set addObject:[NSNumber numberWithInteger:checkbox.tag]];
        }
    } else{
        if ([_userIds containsObject:userId]) {
            [_userIds removeObject:userId];
            [_userNames removeObject:userNickname];
            [_set removeObject:[NSNumber numberWithInteger:checkbox.tag]];
        }
    }
    
}

- (void)confirmMethod {
    NSLog(@"_userId:%@ userNames:%@" ,_userIds ,_userNames);
    if (_userIds.count == 0) {
        [GKMessageTool showText:@"请指定领取红包的人！"];
        return;
    }
    
    if (self.selectcClaimBlock) {
        self.selectcClaimBlock(self.userIds, self.userNames);
        [self actionQuit];
    }
}

#pragma mark  -------------------服务器返回数据--------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if ([aDownload.action isEqualToString:wh_act_roomMemberList]) {
//        _room.roomId = roomId;
//        _room.members = [array1 mutableCopy];
//
//        memberData *data = [self.room getMember:g_myself.userId];
//        if ([data.role intValue] == 1 || [data.role intValue] == 2) {
//            _isAdmin = YES;
//        }else {
//            _isAdmin = NO;
//        }
//        self.groupSize = array1.count;
//
//        self.title = [NSString stringWithFormat:@"%@(%ld)", self.chatPerson.userNickname, array1.count];
    }
}


#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    
    [_wait stop];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

@end
