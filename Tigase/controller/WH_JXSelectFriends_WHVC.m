//
//  WH_JXSelectFriends_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/7/2.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXSelectFriends_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "WH_JXImageView.h"
#import "WH_JX_WHCell.h"
#import "WH_JXRoomPool.h"
#import "JXTableView.h"
#import "WH_JXNewFriend_WHViewController.h"
#import "WH_menuImageView.h"
#import "QCheckBox.h"
#import "XMPPRoom.h"
#import "WH_JXRoomObject.h"
#import "NSString+ContainStr.h"
#import "WH_JXMessageObject.h"
#import "BMChineseSort.h"

@interface WH_JXSelectFriends_WHVC ()<UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIButton* finishBtn;

@property (nonatomic, strong) NSMutableArray *checkBoxArr;

@end

@implementation WH_JXSelectFriends_WHVC
@synthesize chatRoom,room,isNewRoom,set,array=_array;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack   = YES;
        //self.view.frame = g_window.bounds;
        self.wh_isShowFooterPull = NO;
        self.searchArray = [NSMutableArray array];
        _userIds = [NSMutableArray array];
        _userNames = [NSMutableArray array];
        set   = [[NSMutableSet alloc] init];
        _indexArray = [NSMutableArray array];
        _letterResultArr = [NSMutableArray array];
        _checkBoxArr = [NSMutableArray array];
        _selMenu = 0;
        
        
        [g_notify addObserver:self selector:@selector(newReceipt:) name:kXMPPReceipt_WHNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(WH_onSendTimeout:) name:kXMPPSendTimeOut_WHNotifaction object:nil];
        
        [g_notify addObserver:self selector:@selector(refreshNotif:) name:kLabelVCRefreshNotif object:nil];
    }
    return self;
}

- (void)refreshNotif:(NSNotification *)notif {
    [self actionQuit];
}

-(void)dealloc{
    //移除监听
    [g_notify removeObserver:self];
    [set removeAllObjects];
    [_array removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self WH_createHeadAndFoot];
    if (_type == JXSelectFriendTypeGroupAT ||_type == JXSelectFriendTypeSpecifyAdmin) {
        
    }else{
        
        _finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_finishBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
        [_finishBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateHighlighted];
        [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _finishBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 43 - 10, JX_SCREEN_TOP - 8 - 28, 43, 28);
        [_finishBtn addTarget:self action:@selector(onAdd:) forControlEvents:UIControlEventTouchUpInside];
        _finishBtn.layer.cornerRadius = CGRectGetHeight(_finishBtn.frame) / 2.f;
        _finishBtn.layer.masksToBounds = YES;
        _finishBtn.backgroundColor = HEXCOLOR(0x0093FF);
        _finishBtn.titleLabel.font = sysFontWithSize(14);
        [self.wh_tableHeader addSubview:_finishBtn];
    }
//    [self customSearchTextField];
    [self customView];
    
    [self getDataArrayByType];
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

-(void)getDataArrayByType{
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = NO;
    
    if (_type == JXSelectFriendTypeGroupAT || _type == JXSelectFriendTypeSelMembers) {
        if(_type == JXSelectFriendTypeSelMembers){
            self.title = Localized(@"JXSip_invite");
            [self getSelUserTypeSelMembersArray];
        }else{
            self.title = Localized(@"JX_GroupAtMember");
            [self getGroupATRoomMembersArray];
        }
        [_table reloadData];
    }else if(_type == JXSelectFriendTypeSpecifyAdmin){
        self.title = Localized(@"WaHu_JXRoomMember_WaHuVC_SetAdministrator");
        [self getRoomMembersArray];
        [_table reloadData];
    }else if (_type == JXSelectFriendTypeCustomArray) {
        //        self.title
        [_table reloadData];
    }
    else{
        self.title = Localized(@"WaHu_JXSelFriend_WaHuVC_SelFriend");
        _array=[[NSMutableArray alloc] init];
        [self refresh];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


/*
- (void)customSearchTextField{
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 50)];
//    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:backView];
    
//    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(backView.frame.size.width-5-45, 5, 45, 30)];
//    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
//    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    [cancelBtn addTarget:self action:@selector(WH_cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.titleLabel.font = sysFontWithSize(14);
//    [backView addSubview:cancelBtn];
    
    
    self.seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 30)];
    self.seekTextField.placeholder = Localized(@"JX_EnterKeyword");
    self.seekTextField.textColor = [UIColor blackColor];
    [self.seekTextField setFont:sysFontWithSize(14)];
    self.seekTextField.backgroundColor = HEXCOLOR(0xf0f0f0);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    self.seekTextField.leftView = leftView;
    self.seekTextField.leftViewMode = UITextFieldViewModeAlways;
    self.seekTextField.borderStyle = UITextBorderStyleNone;
    self.seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.seekTextField.delegate = self;
    self.seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:self.seekTextField];
    [self.seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, JX_SCREEN_WIDTH, .5)];
    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
    [backView addSubview:lineView];
    
    self.tableView.tableHeaderView = backView;
    
}
 */

- (void) textFieldDidChange:(UITextField *)textField {
    [super textFieldDidChange:textField];
    if (textField.text.length <= 0) {
        [self getDataArrayByType];
        return;
    }
    
    [self.searchArray removeAllObjects];
    //    NSMutableArray *arr = [_array mutableCopy];
    //    for (NSInteger i = 0; i < arr.count; i ++) {
    //
    //        NSString * nameStr = nil;
    //        NSString * cardNameStr = nil;
    //        NSString * nickNameStr = nil;
    //        if ([arr[i] isMemberOfClass:[memberData class]]) {
    //            memberData *obj = arr[i];
    //            nameStr = obj.userName;
    //            cardNameStr = obj.cardName;
    //            nickNameStr = obj.userNickName;
    //        }else if ([arr[i] isMemberOfClass:[WH_JXUserObject class]]) {
    //            WH_JXUserObject * obj = arr[i];
    //            nameStr = obj.userNickname;
    //        }
    //        nameStr = !nameStr ? @"" : nameStr;
    //        cardNameStr = !cardNameStr ? @"" : cardNameStr;
    //        nickNameStr = !nickNameStr ? @"" : nickNameStr;
    //        NSString * allStr = [NSString stringWithFormat:@"%@%@%@",nameStr,cardNameStr,nickNameStr];
    //        if ([[allStr lowercaseString] containsMyString:[textField.text lowercaseString]]) {
    //            [self.searchArray addObject:arr[i]];
    //        }
    //
    //    }
    
    if (_type == JXSelectFriendTypeGroupAT || _type == JXSelectFriendTypeSelMembers || _type == JXSelectFriendTypeSpecifyAdmin) {
        
//        self.searchArray = [memberData searchMemberByFilter:textField.text room:room.roomId];
        for (NSInteger i = 0; i < _array.count; i ++) {
            memberData *data = _array[i];
            memberData *data1 = [self.room getMember:g_myself.userId];
            WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
            allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
            NSString *name = [NSString string];
            if ([data1.role intValue] == 1) {
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

    }else{
        for (NSInteger i = 0; i < _array.count; i ++) {
            WH_JXUserObject * user = _array[i];
            NSString *userStr = [user.userNickname lowercaseString];
            NSString *textStr = [textField.text lowercaseString];
            NSString *userRemarkStr = [user.remarkName lowercaseString];
//            if (([userStr rangeOfString:textStr].location != NSNotFound) || ([userRemarkStr rangeOfString:textStr].location != NSNotFound)) {
//                [self.searchArray addObject:user];
//            }
            
            if (([userStr containsString:textStr]) || ([userRemarkStr containsString:textStr])) {
                [self.searchArray addObject:user];
            }
            
        }
    }
    
    //    self.searchArray = [memberData searchMemberByFilter:textField.text room:room.roomId];
    
    [self.tableView reloadData];
}


- (void) WH_cancelBtnAction {
    self.seekTextField.text = nil;
    [self.seekTextField resignFirstResponder];
    [self getDataArrayByType];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.seekTextField.text.length > 0) {
        return 1;
    }
    return [self.indexArray count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (self.seekTextField.text.length > 0) {
//        return Localized(@"JXFriend_searchTitle");
//    }
//    return [self.indexArray objectAtIndex:section];
//}

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
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    //    if(cell==nil){
    memberData *data = [self.room getMember:g_myself.userId];
    
    if (_type == JXSelectFriendTypeGroupAT || _type == JXSelectFriendTypeSpecifyAdmin ||  _type == JXSelectFriendTypeSelMembers) {
        
        if (!cell) {
            cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        memberData * member;
        if (self.seekTextField.text.length > 0) {
            member = self.searchArray[indexPath.row];
        }else{
            member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        //            cell = [[WH_JX_WHCell alloc] init];
        [_table WH_addToPool:cell];
        NSString *name = [NSString string];
        WH_JXUserObject *allUser = [[WH_JXUserObject alloc] init];
        allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",member.userId]];
        if (_type == JXSelectFriendTypeSelMembers) {
            if ([data.role intValue] == 1) {
                name = member.lordRemarkName ? member.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }else {
                name = allUser.remarkName.length > 0  ? allUser.remarkName : member.userNickName;
            }
        }else {
            name = member.userNickName;
        }
        if (!self.room.allowSendCard && [data.role intValue] != 1 && [data.role intValue] != 2 && member.userId > 0) {
            if (GroupMemberShowPlaceholderString) {
                name = [name substringToIndex:[name length]-1];
                name = [name stringByAppendingString:@"*"];
            }
            
        }

        cell.title = name;
        cell.positionTitle = [self positionStrRole:[member.role integerValue]];
        if(!member.idStr){//所有人不显示
            //                cell.subtitle = [NSString stringWithFormat:@"%ld",member.userId];
        }else{
            if (MainHeadType) {//圆形
                cell.headImage = @"groupImage";
            }else{
                cell.headImage = @"fangxinggroupImagePlaceholder";
            }
        }
        //            cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
        cell.userId = [NSString stringWithFormat:@"%ld",member.userId];
        //            [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.isSmall = YES;
        [cell WH_headImageViewImageWithUserId:nil roomId:nil];
        
        if (_type == JXSelectFriendTypeGroupAT) {
            if(member.idStr){
                if (room.roomId != nil) {
//                    NSString *groupImagePath = [NSString stringWithFormat:@"%@%@/%@.%@",NSTemporaryDirectory(),g_myself.userId,room.roomId,@"jpg"];
//                    if (groupImagePath && [[NSFileManager defaultManager] fileExistsAtPath:groupImagePath]) {
//                        cell.headImageView.image = [UIImage imageWithContentsOfFile:groupImagePath];
//                    }else{
//                        [roomData roomHeadImageRoomId:room.roomId toView:cell.headImageView];
//                    }
                    [g_server WH_getRoomHeadImageSmallWithUserId:room.roomJid roomId:room.roomId imageView:cell.headImageView];
                }
            }
        }
        
        if(_type == JXSelectFriendTypeSelMembers){
            QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
//            btn.frame = CGRectMake(20, 15, 25, 25);
            btn.frame = btnF;
            btn.tag = indexPath.section * 1000 + indexPath.row;
            BOOL b = NO;
            NSString* s = [NSString stringWithFormat:@"%ld",member.userId];
            b = [_existSet containsObject:s];
            btn.selected = b;
            btn.userInteractionEnabled = !b;
            [cell addSubview:btn];
            
            [_checkBoxArr addObject:btn];
        }
        
    }else if (_type == JXSelectFriendTypeCustomArray || _type == JXSelectFriendTypeDisAble) {
        
        if (!cell) {
            cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        WH_JXUserObject *user;
        if (self.seekTextField.text.length > 0) {
            user = self.searchArray[indexPath.row];
        }else{
            user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        [_table WH_addToPool:cell];
        cell.title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;
        //            cell.subtitle = user.userId;
        //            cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
        cell.userId = user.userId;
        cell.isSmall = YES;
        [cell WH_headImageViewImageWithUserId:nil roomId:nil];
        //        cell.headImage   = user.userHead;
        //            [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
        btn.frame = btnF;
        btn.tag = indexPath.section * 1000 + indexPath.row;
        
        if (self.disableSet) {
            btn.enabled = ![_disableSet containsObject:user.userId];
        }else{
            btn.enabled = YES;
        }
        
        [_checkBoxArr addObject:btn];
        
        [cell addSubview:btn];
    }else{
        WH_JXUserObject *user;
        if (self.seekTextField.text.length > 0) {
            user = self.searchArray[indexPath.row];
        }else{
            user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        //            cell = [[WH_JX_WHCell alloc] init];
        
//        if (!cell) {
            cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            
            QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
//            btn.frame = CGRectMake(20, 15, 25, 25);
            btn.frame = btnF;
            btn.tag = indexPath.section * 1000 + indexPath.row;
            BOOL b = NO;
            if (self.addressBookArr.count > 0) {
                if ([_existSet containsObject:user.userId]) {
                    btn.selected = [_existSet containsObject:user.userId];
                    [self didSelectedCheckBox:btn checked:btn.selected];
                }
            }else {
                if (room){
                    b = [room isMember:user.userId];
                    BOOL flag = NO;
                    for (NSInteger i = 0; i < _userIds.count; i ++) {
                        NSString *selUserId = _userIds [i];
                        if ([user.userId isEqualToString:selUserId]) {
                            flag = YES;
                            break;
                        }
                    }
                    btn.selected = flag;
                    btn.userInteractionEnabled = !flag;
//                    btn.selected = b;
//                    btn.userInteractionEnabled = !b;
                }else{
                    
                    b = [_existSet containsObject:user.userId];
                    BOOL flag = NO;
                    for (NSInteger i = 0; i < _userIds.count; i ++) {
                        NSString *selUserId = _userIds [i];
                        if ([user.userId isEqualToString:selUserId]) {
                            flag = YES;
                            break;
                        }
                    }

                    if (b) {
                        if (_type == JXSelectFriendTypeSelFriends) {
                            btn.selected = b;
                        }else {
                            btn.enabled = !b;
                        }
                    }else {
                        if (_type == JXSelectFriendTypeSelFriends) {
                            btn.selected = flag;
                        }else {
                            btn.enabled = !flag;
                        }
                    }
                    [self didSelectedCheckBox:btn checked:btn.selected];
                }
            }
            
            [_checkBoxArr addObject:btn];
            [cell addSubview:btn];
//        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [_table WH_addToPool:cell];
        
        cell.title = user.remarkName.length > 0 ? user.remarkName : user.userNickname;

        //            cell.subtitle = user.userId;
        cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
        cell.userId = user.userId;
        cell.isSmall = YES;
        [cell WH_headImageViewImageWithUserId:nil roomId:nil];

        
    }
    
//    cell.headImageView.frame = CGRectMake(cell.headImageView.frame.origin.x + 50, cell.headImageView.frame.origin.y, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height);
//    cell.lbTitle.frame = CGRectMake(cell.lbTitle.frame.origin.x + 50, cell.lbTitle.frame.origin.y, cell.lbTitle.frame.size.width, cell.lbTitle.frame.size.height);
    
    //    }
    //    else{
    //
    //        NSLog(cellName);
    //    }
    [cell setLineDisplayOrHidden:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_type == JXSelectFriendTypeGroupAT) {
        memberData * member;
        if (self.seekTextField.text.length > 0) {
            member = self.searchArray[indexPath.row];
        }else{
            member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:member waitUntilDone:YES];
        
        [self actionQuit];
        //        _pSelf = nil;
    }else if (_type == JXSelectFriendTypeSpecifyAdmin) {
        
        memberData * member;
        if (self.seekTextField.text.length > 0) {
            member = self.searchArray[indexPath.row];
        }else{
            member = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        if ([member.role intValue] == 1) {
            [g_App showAlert:Localized(@"JXGroup_CantSetSelf")];
            return;
        }
        if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:member waitUntilDone:YES];
        
        [self actionQuit];
        //        _pSelf = nil;
    }else {
        if (_type == JXSelectFriendTypeSelMembers) {
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
        }else {
            WH_JXUserObject *user;
            if (self.seekTextField.text.length > 0) {
                user = self.searchArray[indexPath.row];
            }else{
                user = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            }
            if (![_existSet containsObject:user.userId]) {
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
        
    }
}

-(void)getGroupATRoomMembersArray{
    _array = (NSMutableArray *)[memberData fetchAllMembers:room.roomId sortByName:YES];
    
    memberData * mem = [[memberData alloc] init];
    mem.userId = 0;
    mem.idStr = room.roomJid;
    mem.roomId = room.roomId;
    mem.userNickName = Localized(@"JX_AtALL");
    mem.cardName = Localized(@"JX_AtALL");
    mem.role = [NSNumber numberWithInt:10];
    //    mem.createTime = [[rs objectForColumnName:@"createTime"] longLongValue];
    
    [_array insertObject:mem atIndex:0];
    [self reomveExistsSet];
    
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
//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];
}

-(void)getSelUserTypeSelMembersArray{
    _array = (NSMutableArray *)[memberData fetchAllMembers:room.roomId sortByName:YES];
    [self reomveExistsSet];
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

//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];
}

-(void)getRoomMembersArray{
    _array = (NSMutableArray *)[memberData fetchAllMembers:room.roomId sortByName:NO];
    [self reomveExistsSet];
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
//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickName"];
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickName"];
}

-(void)reomveExistsSet{
    for(NSInteger i=[_array count]-1;i>=0;i--){
        memberData* p = [_array objectAtIndex:i];
        if([self.existSet containsObject:[NSString stringWithFormat:@"%ld",p.userId]]>0)
            [_array removeObjectAtIndex:i];
    }
}

-(void)getArrayData{
    if (self.addressBookArr.count > 0) {
        [_userIds removeAllObjects];
        _array = [NSMutableArray arrayWithArray:self.addressBookArr];
    }else {
        _array=[[WH_JXUserObject sharedUserInstance] WH_fetchAllUserFromLocal];
    }
    if (self.isShowMySelf) {
        WH_JXUserObject *mySelf = [[WH_JXUserObject alloc] init];
        mySelf.userId = g_myself.userId;
        mySelf.userNickname = g_myself.userNickname;
        [_array insertObject:mySelf atIndex:0];
    }
    
    for(NSInteger i=[_array count]-1;i>=0;i--){
        WH_JXUserObject* u = [_array objectAtIndex:i];
        for (int j=0; j<[room.members count]; j++) {
            memberData* p = [room.members objectAtIndex:j];
            if(p.userId == [u.userId intValue]){
                [_array removeObjectAtIndex:i];
                break;
            }
        }
        
        if (self.isForRoom) {
            if([self.forRoomUser.userId isEqualToString:u.userId]){
                [_array removeObjectAtIndex:i];
            }
        }
        
        if (self.addressBookArr.count > 0) {
            [_userIds addObject:u.userId];
            [_userNames addObject:u.userNickname];
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

//    NSLog(@"------- indexArray start");
//    //根据Person对象的 name 属性 按中文 对 Person数组 排序
//    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"userNickname"];
//    NSLog(@"------- letterResultArr start");
//
//    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"userNickname"];
//    NSLog(@"------- letterResultArr stop");
    if(isNewRoom && [_array count]<=0)//没有好友时
        [self performSelector:@selector(onAdd:) withObject:nil afterDelay:0.1];
}

-(void)refresh{
    [self WH_stopLoading];
    _refreshCount++;
    [_array removeAllObjects];
    
    [self getArrayData];
    for (NSString *userId in _existSet) {
        
        NSString *userName = [WH_JXUserObject WH_getUserNameWithUserId:userId];
        
        if (!userName) {
            userName = @"";
        }
        
        [_userIds addObject:userId];
        [_userNames addObject:userName];
    }
    [_table reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.seekTextField resignFirstResponder];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)WH_scrollToPageUp{
    [self refresh];
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
//    if (self.addressBookArr.count > 0) {
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
                [set addObject:[NSNumber numberWithInteger:checkbox.tag]];
            }
        }
        else{
            if ([_userIds containsObject:userId]) {
                [_userIds removeObject:userId];
                [_userNames removeObject:userNickname];
                [set removeObject:[NSNumber numberWithInteger:checkbox.tag]];
            }
        }
    
//    }else {
//        if(checked){
//            [set addObject:[NSNumber numberWithInteger:checkbox.tag]];
//        }
//        else{
//            [set removeObject:[NSNumber numberWithInteger:checkbox.tag]];
//        }
//    }
    
}

-(void)onAdd:(UIButton *)btn{
    btn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
    });
    
    _userIdsArray = [NSMutableArray array];
    _userNamesArray = [NSMutableArray array];
    for (int i = 0; i < _userIds.count; i++) {
        NSString *uId = [_userIds objectAtIndex:i];
        NSString *uName = [_userNames objectAtIndex:i];
        
        if (![_userIdsArray containsObject:uId]) {
            [_userIdsArray addObject:uId];
            [_userNamesArray addObject:uName];
        }
    }
    
    if (self.isNewRoom && self.isForRoom) {
        //通过单聊创建群组
        if (_userIdsArray.count < 1) {
//            [g_App showAlert:@"请选择至少一名好友！"];
            [GKMessageTool showText:@"请选择至少一名好友！"];
            return;
        }
    }
    
    if (self.isNewRoom && !self.isForRoom) {
        //创建群组
        if (_userIdsArray.count < 2) {
            [GKMessageTool showText:@"请选择至少两名好友！"];
            return;
        }
    }
    
    NSLog(@"g_myself.userId:%@------myuserId:%@" ,g_myself.userId ,MY_USER_ID);
    if(_type == JXSelectFriendTypeSelFriends || chatRoom || self.isForRoom || self.isNewRoom){
        
        if (!self.addressBookArr || self.addressBookArr.count <= 0) {
            if (self.isForRoom) {
                [_userIdsArray addObject:self.forRoomUser.userId];
                [_userNamesArray addObject:self.forRoomUser.userNickname];
            }
        }
        
        if(self.isNewRoom){
            
            NSString* s = [XMPPStream generateUUID];
            s = [[s stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
            
            NSString *roomName = [NSString stringWithFormat:@"%@、%@",MY_USER_NAME,[_userNames componentsJoinedByString:@"、"]];
            
            room.roomJid= s;
            room.name   = roomName;
            room.desc   = nil;
            room.userId = [g_myself.userId longLongValue];
            room.userNickName = MY_USER_NAME;
            room.showRead = NO;
            room.showMember = YES;
            room.allowSendCard = YES;
            room.isLook = YES;
            room.isNeedVerify = NO;
            room.allowInviteFriend = YES;
            room.allowUploadFile = YES;
            room.allowConference = YES;
            room.allowSpeakCourse = YES;
            
            chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:s title:roomName];
            chatRoom.delegate = self;
            
            [_wait start:Localized(@"JXAlert_CreatRoomIng") delay:30];
            return;
        }
        if ((self.room.isNeedVerify && self.room.userId != [g_myself.userId longLongValue]) || _type == JXSelectFriendTypeSelFriends) {
            
            if (self.isShowAlert) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_SaveLabelNextTime") message:nil delegate:self cancelButtonTitle:Localized(@"JX_DepositAsLabel") otherButtonTitles:Localized(@"JX_Ignore"), nil];
                alert.tag = 2457;
                [alert show];
                return;
            }
            
            
            if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
                [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
            [self actionQuit];
        }else {
            [g_server WH_addRoomMemberWithRoomId:room.roomId userArray:_userIdsArray toView:self];//用接口即可
        }
        if(isNewRoom){
            [self onNewRoom];
//            [self actionQuit];
        }
        return;
    }
    if (_type == JXSelectFriendTypeGroupAT)
        return;
    if (_type == JXSelectFriendTypeSpecifyAdmin)
        return;
    if (_type == JXSelectFriendTypeSelMembers){
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
    
    [self actionQuit];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2457) {
        if (buttonIndex == 0) {
            if ([self.delegate respondsToSelector:self.alertAction]) {
                [self.delegate performSelectorOnMainThread:self.alertAction withObject:self waitUntilDone:YES];
            }
        }else {
            if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
                [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
            [self actionQuit];
        }
    }
    
}

-(void)xmppRoomDidCreate:(XMPPRoom *)sender{
    [g_server addRoom:room userArray:_userIdsArray isPublic:YES isNeedVerify:NO category:0 toView:self];
    chatRoom.delegate = nil;
}

-(void)onNewRoom{
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    sendView.title = chatRoom.roomTitle;
    sendView.roomJid = chatRoom.roomJid;
    sendView.roomId = room.roomId;
    sendView.chatRoom = chatRoom;
    sendView.room = self.room;
    
    WH_JXUserObject * user = [[WH_JXUserObject alloc]init];
    user = [user getUserById:chatRoom.roomJid];
    sendView.chatPerson = user;
    
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
}

-(NSString *)positionStrRole:(NSInteger)role{
    if (_type == JXSelectFriendTypeSpecifyAdmin) {
        NSString * roleStr = nil;
        switch (role) {
            case 1://创建者
                roleStr = Localized(@"JXGroup_Owner");
                break;
            case 2://管理员
                roleStr = Localized(@"JXGroup_Admin");
                break;
            case 3://普通成员
                roleStr = Localized(@"JXGroup_RoleNormal");
                break;
            default:
                roleStr = Localized(@"JXGroup_RoleNormal");
                break;
        }
        return roleStr;
    }
    return nil;
}

-(void)WH_onSendTimeout:(NSNotification *)notifacation//超时未收到回执
{

}

-(void)newReceipt:(NSNotification *)notifacation{//新回执

}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_roomMemberSet] ){
        for (int i=0;i<[_userIds count];i++) {
            NSString *userId=[_userIds objectAtIndex:i];
            
            memberData* p = [[memberData alloc] init];
            p.userId = [userId intValue];
            p.userNickName = [_userNames objectAtIndex:i];
            p.role = [NSNumber numberWithInt:3];
            [room.members addObject:p];
        }
        if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:YES];
        
        [_userIds removeAllObjects];
        [_userNames removeAllObjects];
        [self actionQuit];
        //        _pSelf = nil;
    }
    
    if( [aDownload.action isEqualToString:wh_act_roomAdd] ){
        room.roomId = [dict objectForKey:@"id"];
        //        _room.call = [NSString stringWithFormat:@"%@",[dict objectForKey:@"call"]];
        [self insertRoom];
        [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
        [g_notify postNotificationName:kActionRelayQuitVC_WHNotification object:nil];
        [g_server WH_addRoomMemberWithRoomId:room.roomId userArray:_userIdsArray toView:self];//用接口即可
        if(isNewRoom){
            [self onNewRoom];
        }
    }
}
-(void)insertRoom{
    WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
    user.userNickname = room.name;
    user.userId = room.roomJid;
    user.userDescription = room.desc;
    user.roomId = room.roomId;
    user.content = Localized(@"JX_WelcomeGroupChat");
    user.showRead =  [NSNumber numberWithBool:room.showRead];
    user.showMember = [NSNumber numberWithBool:room.showMember];
    user.allowSendCard = [NSNumber numberWithBool:room.allowSendCard];
    user.chatRecordTimeOut = room.chatRecordTimeOut;
    user.talkTime = [NSNumber numberWithLong:room.talkTime];
    user.allowInviteFriend = [NSNumber numberWithBool:room.allowInviteFriend];
    user.allowUploadFile = [NSNumber numberWithBool:room.allowUploadFile];
    user.allowConference = [NSNumber numberWithBool:room.allowConference];
    user.allowSpeakCourse = [NSNumber numberWithBool:room.allowSpeakCourse];
    [user insertRoom];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
//    return WH_show_error;
    if ([aDownload.action isEqualToString:wh_act_roomMemberSet]) {
        return (isNewRoom)?WH_hide_error:WH_show_error;
    }else{
        return WH_show_error;
        
    }
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
//    return WH_show_error;
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

- (void)actionQuit {
    if (self.isAddWindow) {
        [self.view removeFromSuperview];
        self.view = nil;
    }else{
        [super actionQuit];
    }
}


@end
