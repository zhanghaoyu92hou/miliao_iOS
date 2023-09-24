//
//  WH_JXNewLabel_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/6/21.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXNewLabel_WHVC.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "WH_JX_WHCell.h"
#import "BMChineseSort.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXChat_WHViewController.h"
#import "UIButton+WH_Button.h"

#define HEIGHT 60

@interface WH_JXNewLabel_WHVC ()

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) UITextField *labelName;
@property (nonatomic, strong) UILabel *labelUserNum;
@end

@implementation WH_JXNewLabel_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    [self WH_createHeadAndFoot];
    
    self.tableView.backgroundColor = g_factory.globalBgColor;
    
    _array = [NSMutableArray array];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    doneBtn.backgroundColor = HEXCOLOR(0x0093FF);
    [doneBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 43 - 10, JX_SCREEN_TOP - 8 - 28, 43, 28);
    doneBtn.titleLabel.font = sysFontWithSize(14);
    [doneBtn addTarget:self action:@selector(WH_doneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.wh_tableHeader addSubview:doneBtn];
    doneBtn.layer.cornerRadius = CGRectGetHeight(doneBtn.frame) / 2.f;
    doneBtn.layer.masksToBounds = YES;
    
    [self createwh_tableHeaderView];
}

- (void)createwh_tableHeaderView {
    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = HEXCOLOR(0xf0eff4);
    
    UIView *labelNameBgView = [[UIView alloc] initWithFrame:CGRectMake(INSETS, 13, CGRectGetWidth(self.view.frame) - INSETS*2, 56)];
    [view addSubview:labelNameBgView];
    labelNameBgView.backgroundColor = [UIColor whiteColor];
    labelNameBgView.layer.cornerRadius = g_factory.cardCornerRadius;
    labelNameBgView.layer.masksToBounds = YES;
    labelNameBgView.layer.borderWidth = g_factory.cardBorderWithd;
    labelNameBgView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    
    CGFloat labelNameW = 65;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 17, labelNameW, 21)];
    label.text = Localized(@"JX_LabelName");
    label.textColor = HEXCOLOR(0x3A404C);
    label.font = sysFontWithSize(15);
    [labelNameBgView addSubview:label];
    
//    UIView *fieldView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), JX_SCREEN_WIDTH, 50)];
//    fieldView.backgroundColor = [UIColor whiteColor];
//    [view addSubview:fieldView];
    self.labelName = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame)+12, 0, CGRectGetWidth(labelNameBgView.frame) - CGRectGetMaxX(label.frame) - 12*2, CGRectGetHeight(labelNameBgView.frame))];
    if (@available(iOS 10, *)) {
        self.labelName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_LabelForExample") attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0xBAC3D5)}];
    } else {
        [self.labelName setValue:HEXCOLOR(0xBAC3D5) forKeyPath:@"_placeholderLabel.textColor"];
    }
    self.labelName.textAlignment = NSTextAlignmentRight;
    self.labelName.font = sysFontWithSize(15);
    self.labelName.placeholder = Localized(@"JX_LabelForExample");
    if (self.labelObj.groupName.length > 0) {
        self.labelName.text = self.labelObj.groupName;
    }
    [labelNameBgView addSubview:self.labelName];
    
//    self.labelUserNum = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(labelNameBgView.frame) + 10, JX_SCREEN_WIDTH, 30)];
//    self.labelUserNum.text = [NSString stringWithFormat:@"%@(0)",Localized(@"JX_LabelMembers")];
//    self.labelUserNum.textColor = [UIColor grayColor];
//    self.labelUserNum.font = [UIFont systemFontOfSize:16.0];
//
//    [view addSubview:self.labelUserNum];
    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.labelUserNum.frame), JX_SCREEN_WIDTH, 50)];
//    [btn setBackgroundColor:[UIColor whiteColor]];
//    [btn addTarget:self action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
//    imageView.center = CGPointMake(imageView.center.x, btn.frame.size.height / 2);
//    imageView.image = [UIImage imageNamed:@"person_add_green"];
//    [btn addSubview:imageView];
//    label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 0, btn.frame.size.width, btn.frame.size.height)];
//    label.textColor = THEMECOLOR;
//    label.text = Localized(@"JX_AddMembers");
//    label.font = [UIFont systemFontOfSize:17.0];
//    [btn addSubview:label];
//    [view addSubview:btn];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(INSETS, CGRectGetMaxY(labelNameBgView.frame)+12, JX_SCREEN_WIDTH - INSETS*2, 55)];
    [view addSubview:btn];
    btn.layer.cornerRadius = g_factory.cardCornerRadius;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = g_factory.cardBorderWithd;
    btn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    [btn setTitleColor:HEXCOLOR(0x8F9CBB) forState:UIControlStateNormal];
    [btn setTitle:Localized(@"JX_AddMembers") forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"WH_label_add"] forState:UIControlStateNormal];
    btn.titleLabel.font = sysFontWithSize(15);
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
    
    [btn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextRight imageTitleSpace:12];
    
    view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, CGRectGetMaxY(btn.frame) + 13);
    
    self.tableView.tableHeaderView = view;
    
    NSString *userIdStr = self.labelObj.userIdList;
    NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
    if (userIdStr.length <= 0) {
        userIds = nil;
    }
    [_array removeAllObjects];
    
    for (NSInteger i = 0; i < userIds.count; i ++) {
        WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
        user.userId = userIds[i];
        NSString *userName = [WH_JXUserObject WH_getUserNameWithUserId:userIds[i]];
        user.userNickname = userName;
        
        [_array addObject:user];
    }
    self.labelUserNum.text = [NSString stringWithFormat:@"%@(%ld)",Localized(@"JX_LabelMembers"),_array.count];
    [self.tableView reloadData];
}

- (void)addFriendAction {
    
    WH_JXSelectFriends_WHVC *vc = [[WH_JXSelectFriends_WHVC alloc] init];
    vc.type = JXSelectFriendTypeSelFriends;
    vc.delegate = self;
    vc.didSelect = @selector(selectFriendsDelegate:);
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSInteger i = 0; i < self.array.count; i ++) {
        WH_JXUserObject *user = self.array[i];
        [set addObject:user.userId];
    }
    
    NSMutableArray *friends = [[WH_JXUserObject sharedUserInstance] WH_fetchAllUserFromLocal];
    __block NSMutableArray *letterResultArr = [NSMutableArray array];
    //排序 Person对象
    [BMChineseSort sortAndGroup:friends key:@"userNickname" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            letterResultArr = unGroupArr;
        }
    }];
//    NSMutableArray *letterResultArr = [BMChineseSort sortObjectArray:friends Key:@"userNickname"];
    NSMutableSet *numSet = [NSMutableSet set];
    for (NSInteger i = 0; i < letterResultArr.count; i ++) {
        NSMutableArray *arr = letterResultArr[i];
        for (NSInteger j = 0; j < arr.count; j ++) {
            WH_JXUserObject *user = arr[j];
            if ([set containsObject:user.userId]) {
                [numSet addObject:[NSNumber numberWithInteger:i * 1000 + j]];
            }
        }
        
    }
    if (numSet.count > 0) {
        vc.set = numSet;
    }
    vc.existSet = set;
    
    [g_navigation pushViewController:vc animated:YES];
}

- (void)selectFriendsDelegate:(WH_JXSelectFriends_WHVC *)vc {
    
    [_array removeAllObjects];
    
    for (NSInteger i = 0; i < vc.userIds.count; i ++) {
        WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
        user.userId = vc.userIds[i];
        user.userNickname = vc.userNames[i];
        
        [_array addObject:user];
    }
    self.labelUserNum.text = [NSString stringWithFormat:@"%@(%ld)",Localized(@"JX_LabelMembers"),_array.count];
    [self.tableView reloadData];
}

- (void)WH_doneBtnAction:(UIButton *)btn {
    if (self.labelName.text.length <= 0) {
        [g_App showAlert:Localized(@"JX_EnterLabelName")];
        return;
    }
    if (self.array.count <= 0) {
        [g_App showAlert:Localized(@"JX_AddMember")];
        return;
    }
    
    if (self.labelObj.groupId.length > 0) {
        [g_server WH_friendGroupUpdateWithGroupId:self.labelObj.groupId groupName:self.labelName.text toView:self];
    }else {
        [g_server WH_friendGroupAdd:self.labelName.text toView:self];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WH_JXUserObject *user = _array[indexPath.row];
    
    WH_JX_WHCell *cell=nil;
    NSString* cellName = @"WH_JX_WHCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        
        cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [_table WH_addToPool:cell];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.title = user.userNickname;
    cell.index = (int)indexPath.row;
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.didTouch = @selector(WH_on_WHHeadImage:);
    cell.timeLabel.hidden = YES;
    cell.userId = user.userId;
    [cell.lbTitle setText:cell.title];
    
    cell.headImageView.tag = indexPath.row;
    cell.headImageView.wh_delegate = cell.delegate;
    cell.headImageView.didTouch = cell.didTouch;
    
    cell.dataObj = user;
    cell.isSmall = YES;
    [cell WH_headImageViewImageWithUserId:nil roomId:nil];
    return cell;
}

-(void)WH_on_WHHeadImage:(UIView*)sender{
    NSMutableArray *array;

    array = _array;
    WH_JXUserObject *user = [array objectAtIndex:sender.tag];
    if([user.userId isEqualToString:FRIEND_CENTER_USERID] || [user.userId isEqualToString:CALL_CENTER_USERID])
        return;
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = user.userId;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JXUserObject *userObj = [_array objectAtIndex:indexPath.row];
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    
    sendView.scrollLine = 0;
    sendView.title = userObj.userNickname;

    sendView.chatPerson = userObj;
    sendView = [sendView init];
    //    [g_App.window addSubview:sendView.view];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.view.hidden = NO;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        WH_JXUserObject *user = _array[indexPath.row];
        [_array removeObject:user];
        
        [_table reloadData];
        
    }];

    
    return @[deleteBtn];
    
}


//服务器返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_FriendGroupAdd] || [aDownload.action isEqualToString:wh_act_FriendGroupUpdate]) {
        
        NSMutableString *userIdListStr = [NSMutableString string];
        for (NSInteger i = 0; i < self.array.count; i ++) {
            WH_JXUserObject *user = self.array[i];
            if (i == 0) {
                [userIdListStr appendFormat:@"%@", user.userId];
            }else {
                [userIdListStr appendFormat:@",%@", user.userId];
            }
        }
        
        
        WH_JXLabelObject *label = [[WH_JXLabelObject alloc] init];
        if (dict) {
            label.userId = dict[@"userId"];
            label.groupId = dict[@"groupId"];
            label.groupName = dict[@"groupName"];
        }else {
            label.userId = self.labelObj.userId;
            label.groupId = self.labelObj.groupId;
            label.groupName = self.labelName.text;
        }
        label.userIdList = userIdListStr;
        [label insert];
        
        [g_server WH_friendGroupUpdateGroupUserListWithGroupId:label.groupId userIdListStr:userIdListStr toView:self];
        
        [g_notify postNotificationName:kLabelVCRefreshNotif object:nil];
        
        [self actionQuit];
    }
    
    if ([aDownload.action isEqualToString:wh_act_FriendGroupUpdateGroupUserList]) {
    
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


- (void)sp_getUsersMostLikedSuccess {
    NSLog(@"Get Info Failed");
}
@end
