//
//  WhoCanSeeViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/11/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WhoCanSeeViewController.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXLabelObject.h"
#import "WH_JXWhoCanSee_WHCell.h"
#import "WH_JXNewLabel_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "BMChineseSort.h"

@interface WhoCanSeeViewController ()<UITableViewDelegate,UITableViewDataSource, WH_JXWhoCanSee_WHCellDelegate>

@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) NSArray * subTitleArray;
@property (nonatomic, strong) UITableView * table;
@property (nonatomic, strong) UIButton * finishBtn;
@property (nonatomic, assign) int checkIndex;
@property (nonatomic, strong) NSMutableArray *labelsArray;

@property (nonatomic, strong) NSMutableArray * selArray;

@property (nonatomic, strong) WH_JXLabelObject *editLabel;


@end

@implementation WhoCanSeeViewController

-(void)setType:(int)type{
    _type = type;
    _checkIndex = type - 1;
}

-(instancetype)init{
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        _titleArray = [NSArray arrayWithObjects:Localized(@"JXBlogVisibel_public"), Localized(@"JXBlogVisibel_private"), Localized(@"JXBlogVisibel_see"), Localized(@"JXBlogVisibel_nonSee"), nil];
        _subTitleArray = [NSArray arrayWithObjects:Localized(@"JXBlogVisibelDes_public"), Localized(@"JXBlogVisibelDes_private"), Localized(@"JXBlogVisibelDes_see"), Localized(@"JXBlogVisibelDes_nonsee"), nil];
//        _labelsArray = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        _wh_selLabelsArray = [NSMutableArray array];
        _selArray = [NSMutableArray array];
        _wh_mailListUserArray = [NSMutableArray array];
        _checkIndex = 0;
        
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createHeadAndFoot];
    [self.wh_tableHeader addSubview:self.finishBtn];
    [self.view addSubview:self.table];
    
    [g_notify addObserver:self selector:@selector(refreshNotif:) name:kLabelVCRefreshNotif object:nil];
    
}

- (void)dealloc {
    [g_notify removeObserver:self];
    [g_notify removeObserver:self name:kLabelVCRefreshNotif object:nil];
}

- (void)refreshNotif:(NSNotification *)notif {
    _labelsArray = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
    for (WH_JXLabelObject *labelObj in _labelsArray) {
        NSString *userIdStr = labelObj.userIdList;
        NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
        if (userIdStr.length <= 0) {
            userIds = nil;
        }
        
        NSMutableArray *newUserIds = [userIds mutableCopy];
        for (NSInteger i = 0; i < userIds.count; i ++) {
            NSString *userId = userIds[i];
            NSString *userName = [WH_JXUserObject WH_getUserNameWithUserId:userId];
            
            if (!userName || userName.length <= 0) {
                [newUserIds removeObject:userId];
            }
            
        }
        
        NSString *string = [newUserIds componentsJoinedByString:@","];
        
        labelObj.userIdList = string;
        
        [labelObj update];
    }
    
    [_wh_selLabelsArray removeObject:self.editLabel];
    for (WH_JXLabelObject *label in _labelsArray) {
        if ([label.groupName isEqualToString:self.editLabel.groupName]) {
            [_wh_selLabelsArray addObject:label];
            break;
        }
    }
    [self.table reloadData];
}

-(UIButton *)finishBtn{
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.frame = CGRectMake(JX_SCREEN_WIDTH-50-8, JX_SCREEN_TOP - 38, 50, 31);
        [_finishBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
        [_finishBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateHighlighted];
        [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _finishBtn.layer.cornerRadius = CGRectGetHeight(_finishBtn.frame) / 2.f;
        _finishBtn.layer.masksToBounds = YES;
        _finishBtn.backgroundColor = HEXCOLOR(0x0093FF);
        _finishBtn.titleLabel.font = sysFontWithSize(14);
        
        [_finishBtn addTarget:self action:@selector(finishBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

-(UITableView *)table{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP) style:UITableViewStylePlain];
        _table.dataSource = self;
        _table.delegate = self;
        _table.tableFooterView = [[UIView alloc] init];
        [_table registerClass:[WH_JXWhoCanSee_WHCell class] forCellReuseIdentifier:@"WH_JXWhoCanSee_WHCell"];
    }
    return _table;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 60)];
    view.tag = section;
    [view addTarget:self action:@selector(headerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 15, 15)];
    imageView.image = [UIImage imageNamed:@"newicon_selected_done"];
    [view addSubview:imageView];
    imageView.hidden = YES;
    if (section == _checkIndex) {
        imageView.hidden = NO;
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(40, 6, self_width-40-10, 20)];
    p.text = _titleArray[section];
    p.font = sysFontWithSize(15);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x3A404C);
    [view addSubview:p];
    
    JXLabel* detail = [[JXLabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(p.frame)+6, self_width-40-10, 17)];
    detail.text = _subTitleArray[section];
    detail.font = sysFontWithSize(14);
    detail.backgroundColor = [UIColor clearColor];
    detail.textColor = HEXCOLOR(0x969696);
    [view addSubview:detail];
    
    UIImageView *showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 40, 19, 12, 12)];
    showImageView.image = [UIImage imageNamed:@"newicon_selected_done"];
    [view addSubview:showImageView];
    showImageView.hidden = YES;
    if (section == 2 || section == 3) {
        showImageView.hidden = NO;
    }
    if (_labelsArray.count > 0) {
        if (section == _checkIndex) {
            showImageView.image = [UIImage imageNamed:@"newicon_arrowdown"];
        }else {
            showImageView.image = [UIImage imageNamed:@"newicon_arrowup"];
        }
    }else {
        showImageView.image = [UIImage imageNamed:@"newicon_arrowup"];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - 0.5, JX_SCREEN_WIDTH, .5)];
    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
    [view addSubview:lineView];
    
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2 || section == 3) {
        if (_checkIndex == section) {
            if (_labelsArray.count > 0) {
                return _labelsArray.count + 1;
            }else {
                return 0;
            }
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == _labelsArray.count) {
        UITableViewCell *tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableViewCell"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, JX_SCREEN_WIDTH-60-30, 20)];
        label.text = Localized(@"JX_FromTheAddressBookSelection");
        label.font = sysBoldFontWithSize(15);
        label.textColor = HEXCOLOR(0x8F9CBB);
        [tableViewCell.contentView addSubview:label];
        
        NSMutableString *nameStr = [NSMutableString string];
        for (NSInteger i = 0; i < _wh_mailListUserArray.count; i ++) {
            WH_JXUserObject *user = _wh_mailListUserArray[i];
            if (i == 0) {
                [nameStr appendString:user.userNickname];
            }else {
                [nameStr appendFormat:@",%@", user.userNickname];
            }
        }
        label = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(label.frame)+6, JX_SCREEN_WIDTH-60-30, 17)];
        label.text = nameStr;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = HEXCOLOR(0x969696);
        
        [tableViewCell.contentView addSubview:label];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - .5, JX_SCREEN_WIDTH, .5)];
        lineView.backgroundColor = HEXCOLOR(0xEBECEF);
        [tableViewCell.contentView addSubview:lineView];
        
        return tableViewCell;
    }
    
    
    WH_JXWhoCanSee_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_JXWhoCanSee_WHCell" forIndexPath:indexPath];
    
    
    WH_JXLabelObject *labelObj = _labelsArray[indexPath.row];
    cell.title.text = labelObj.groupName;
    cell.index = indexPath.row;
    cell.delegate = self;
    
    BOOL flag = NO;
    for (NSInteger i = 0; i < _wh_selLabelsArray.count; i ++) {
        WH_JXLabelObject *label = _wh_selLabelsArray[i];
        if ([labelObj.groupName isEqualToString:label.groupName]) {
            flag = YES;
            break;
        }
    }
    
    if (flag) {
        cell.contentBtn.selected = YES;
        cell.selImageView.image = [UIImage imageNamed:@"WH_addressbook_selected"];
    }else {
        cell.contentBtn.selected = NO;
        cell.selImageView.image = [UIImage imageNamed:@"WH_addressbook_unselected"];
    }
    NSString *userIdStr = labelObj.userIdList;
    NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
    if (userIdStr.length <= 0) {
        userIds = nil;
    }
    NSMutableString *userNameStr = [NSMutableString string];
    for (NSInteger i = 0; i < userIds.count; i ++) {
        NSString *userId = userIds[i];
        NSString *userName = [WH_JXUserObject WH_getUserNameWithUserId:userId];
        if (i == 0) {
            [userNameStr appendFormat:@"%@", userName];
        }else {
            [userNameStr appendFormat:@", %@", userName];
        }
        
    }
    cell.userNames.text = userNameStr;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == _labelsArray.count) {
        WH_JXSelectFriends_WHVC *vc = [[WH_JXSelectFriends_WHVC alloc] init];
        vc.type = JXSelUserTypeSelFriends;
        vc.isShowAlert = YES;
        vc.alertAction = @selector(selectFriendsAlertAction:);
        vc.delegate = self;
        vc.didSelect = @selector(selectFriendsDelegate:);
        
        NSMutableSet *set = [NSMutableSet set];
        for (NSInteger i = 0; i < self.wh_mailListUserArray.count; i ++) {
            WH_JXUserObject *user = self.wh_mailListUserArray[i];
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
//        NSMutableArray *letterResultArr = [BMChineseSort sortObjectArray:friends Key:@"userNickname"];
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
    
//    NSArray * cellArray = [_table visibleCells];
//    for (UITableViewCell * cell in cellArray) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    _checkIndex = (int)indexPath.row;
//    UITableViewCell * cell = [_table cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    cell.selected = NO;
//
//    if (indexPath.row == 2 || indexPath.row == 3) {
//        WH_JXSelFriend_WHVC * selVC = [[WH_JXSelFriend_WHVC alloc] init];
//        selVC.delegate = self;
//        selVC.didSelect = @selector(selFriendsDelegate:);
//
//        if (indexPath.row == 2) {
//
//        }else if (indexPath.row == 3) {
//
//        }
////        [g_window addSubview:selVC.view];
//        [g_navigation pushViewController:selVC animated:YES];
//    }
}

- (void)selectFriendsDelegate:(WH_JXSelFriend_WHVC *)vc {
    
    [_wh_mailListUserArray removeAllObjects];
    
    for (NSInteger i = 0; i < vc.userIds.count; i ++) {
        WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
        user.userId = vc.userIds[i];
        user.userNickname = vc.userNames[i];
        
        [_wh_mailListUserArray addObject:user];
    }

    [self.table reloadData];
}

- (void)selectFriendsAlertAction:(WH_JXSelFriend_WHVC *)selFriendVC {
    WH_JXLabelObject *label = [[WH_JXLabelObject alloc] init];
    label.userIdList = [selFriendVC.userIds componentsJoinedByString:@","];
    WH_JXNewLabel_WHVC *vc = [[WH_JXNewLabel_WHVC alloc] init];
    vc.title = Localized(@"JX_SettingLabel");
    vc.labelObj = label;
    [g_navigation pushViewController:vc animated:YES];
}

- (void)whoCanSeeCell:(WH_JXWhoCanSee_WHCell *)whoCanSeeCell selectAction:(NSInteger)index {
    
    WH_JXLabelObject *labelObj = _labelsArray[index];
    WH_JXLabelObject *selObj;
    for (WH_JXLabelObject *obj in _wh_selLabelsArray) {
        if ([labelObj.groupName isEqualToString:obj.groupName]) {
            selObj = obj;
            break;
        }
    }
    
    if (whoCanSeeCell.contentBtn.selected) {
        [_wh_selLabelsArray addObject:labelObj];
    }else {
        [_wh_selLabelsArray removeObject:selObj];
    }
}

- (void)whoCanSeeCell:(WH_JXWhoCanSee_WHCell *)whoCanSeeCell editBtnAction:(NSInteger)index {
    WH_JXLabelObject *label = _labelsArray[index];
    self.editLabel = label;
    WH_JXNewLabel_WHVC *vc = [[WH_JXNewLabel_WHVC alloc] init];
    vc.title = Localized(@"JX_SettingLabel");
    vc.labelObj = label;
    [g_navigation pushViewController:vc animated:YES];
}


- (void) headerBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;

    if (_labelsArray.count > 0) {
        _labelsArray = nil;
    }else {
        _labelsArray = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
    }
    if (_checkIndex != btn.tag) {
        _checkIndex = (int)btn.tag;
        _labelsArray = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        [_wh_selLabelsArray removeAllObjects];
        [_wh_mailListUserArray removeAllObjects];
    }else {
        
    }
    for (WH_JXLabelObject *labelObj in _labelsArray) {
        NSString *userIdStr = labelObj.userIdList;
        NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
        if (userIdStr.length <= 0) {
            userIds = nil;
        }
        
        NSMutableArray *newUserIds = [userIds mutableCopy];
        for (NSInteger i = 0; i < userIds.count; i ++) {
            NSString *userId = userIds[i];
            NSString *userName = [WH_JXUserObject WH_getUserNameWithUserId:userId];
            
            if (!userName || userName.length <= 0) {
                [newUserIds removeObject:userId];
            }
            
        }
        
        NSString *string = [newUserIds componentsJoinedByString:@","];
        
        labelObj.userIdList = string;
        
        [labelObj update];
    }
    [_table reloadData];
}

-(void)finishBtnAction{
    
    [_selArray removeAllObjects];
    for (NSInteger i = 0; i < _wh_selLabelsArray.count; i ++) {
        WH_JXLabelObject *labelObj = _wh_selLabelsArray[i];
        NSArray *arr = [labelObj.userIdList componentsSeparatedByString:@","];
        for (NSInteger j = 0; j < arr.count; j ++) {
            NSString *userId = arr[j];
            WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
            user.userId = userId;
            
            BOOL flag = NO;
            for (NSInteger m = 0; m < _selArray.count; m ++) {
                WH_JXUserObject *selUser = _selArray[m];
                if ([userId isEqualToString:selUser.userId]) {
                    flag = YES;
                    break;
                }
            }
            
            if (!flag) {
                [_selArray addObject:user];
            }
        }
    }
    
    for (NSInteger i = 0; i < self.wh_mailListUserArray.count; i ++) {
        WH_JXUserObject *user = self.wh_mailListUserArray[i];
        BOOL flag = NO;
        for (NSInteger m = 0; m < _selArray.count; m ++) {
            WH_JXUserObject *selUser = _selArray[m];
            if ([user.userId isEqualToString:selUser.userId]) {
                flag = YES;
                break;
            }
        }
        
        if (!flag) {
            [_selArray addObject:user];
        }
        
    }
    
    if (self.wh_visibelDelegate && [self.wh_visibelDelegate respondsToSelector:@selector(seeVisibel:userArray:selLabelsArray:mailListArray:)]) {
        [self.wh_visibelDelegate seeVisibel:_checkIndex userArray:_selArray selLabelsArray:_wh_selLabelsArray mailListArray:_wh_mailListUserArray];
    }
    [self actionQuit];
}

-(void)selFriendsDelegate:(WH_JXSelFriend_WHVC*)vc{
    NSArray * allArr = vc.array;
    NSArray * indexArr = [vc.set allObjects];
    NSMutableArray * adduserArr = [NSMutableArray array];
    for (NSNumber * index in indexArr) {
        WH_JXUserObject * selUser = allArr[[index intValue]];
        [adduserArr addObject:selUser];
    }
    _selArray = [NSMutableArray arrayWithArray:adduserArr];
}


- (void)sp_getUsersMostLikedSuccess:(NSString *)mediaCount {
    NSLog(@"Check your Network");
}
@end
