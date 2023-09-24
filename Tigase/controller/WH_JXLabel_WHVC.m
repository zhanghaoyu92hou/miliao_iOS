//
//  WH_JXLabel_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/6/21.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXLabel_WHVC.h"
#import "WH_JXLabelObject.h"
#import "WH_JXNewLabel_WHVC.h"
#import "UIButton+WH_Button.h"
#import "WH_AddFriend_WHCell.h"

#define HEIGHT (55+12*2)
@interface WH_JXLabel_WHVC ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) WH_JXLabelObject *currentLabelObj;
@end

@implementation WH_JXLabel_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = Localized(@"JX_Label");
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    self.wh_isShowFooterPull = NO;
    
    [self WH_createHeadAndFoot];
    
    _array = [NSMutableArray array];
    _array = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
    
    for (WH_JXLabelObject *labelObj in _array) {
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
    
    [self.tableView reloadData];
    
    if (!_array || _array.count <= 0) {
        [self.view insertSubview:self.emptyView aboveSubview:self.tableView];
        self.emptyView.hidden = NO;
    }else {
        self.emptyView.hidden = YES;
    }
    
    [self customView];
    
    [g_notify addObserver:self selector:@selector(refreshNotif:) name:kLabelVCRefreshNotif object:nil];
}

- (void)WH_scrollToPageUp {
    [self WH_stopLoading];
    [self refreshNotif:nil];
}

- (void)customView {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, CGRectGetWidth(self.view.frame), HEIGHT)];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(INSETS, 12, JX_SCREEN_WIDTH - INSETS*2, HEIGHT - 12*2)];
    [headerView addSubview:btn];
    btn.layer.cornerRadius = g_factory.cardCornerRadius;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = g_factory.cardBorderWithd;
    btn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    [btn setTitleColor:HEXCOLOR(0x8F9CBB) forState:UIControlStateNormal];
    [btn setTitle:Localized(@"JX_NewLabel") forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"WH_label_add"] forState:UIControlStateNormal];
    btn.titleLabel.font = sysFontWithSize(15);
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(createLabelAction) forControlEvents:UIControlEventTouchUpInside];
    
    [btn layoutButtonWithEdgeInsetsStyle:LLButtonStyleTextRight imageTitleSpace:12];
    
    self.tableView.tableHeaderView = headerView;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
//    imageView.center = CGPointMake(imageView.center.x, HEIGHT / 2);
//    imageView.image = [UIImage imageNamed:@"person_add_green"];
//    [btn addSubview:imageView];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 0, btn.frame.size.width, btn.frame.size.height)];
//    label.textColor = THEMECOLOR;
//    label.text = Localized(@"JX_NewLabel");
//    label.font = [UIFont systemFontOfSize:17.0];
//    [btn addSubview:label];
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - .5, JX_SCREEN_WIDTH, .5)];
//    line.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [btn addSubview:line];
    _table.backgroundColor = g_factory.globalBgColor;
    
    [_table registerClass:[WH_AddFriend_WHCell class] forCellReuseIdentifier:@"WH_AddFriend_WHCell"];
}

- (void)refreshNotif:(NSNotification *)notif {
    
    // 同步标签
    [g_server WH_friendGroupListToView:self];
    
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _emptyView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, JX_SCREEN_WIDTH, 20)];
        label.font = [UIFont systemFontOfSize:17.0];
        label.textColor = [UIColor grayColor];
        label.text = Localized(@"JX_NoLabel");
        label.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame) + 10, JX_SCREEN_WIDTH, 20)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.text = Localized(@"JX_LabelFindContacts");
        label.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:label];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label.frame) + 150, JX_SCREEN_WIDTH - 40, 50)];
        [btn setTitle:Localized(@"JX_NewLabel") forState:UIControlStateNormal];
        [btn setBackgroundColor:THEMECOLOR];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 3.0;
        btn.layer.masksToBounds = 0;
        [btn addTarget:self action:@selector(createLabelAction) forControlEvents:UIControlEventTouchUpInside];
        [_emptyView addSubview:btn];
        
    }
    
    return _emptyView;
}

- (void)createLabelAction {
    
    WH_JXNewLabel_WHVC *vc = [[WH_JXNewLabel_WHVC alloc] init];
    vc.title = Localized(@"JX_NewLabel");
    [g_navigation pushViewController:vc animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WH_JXLabelObject *label = _array[indexPath.row];
    NSString *userIdStr = label.userIdList;
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
    
//    WH_AddFriend_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_AddFriend_WHCell"];
    
//    if(cell==nil){
//
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
//        [_table addToPool:cell];
//
//    }
    
    
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",label.groupName, userIds.count];
//    cell.textLabel.textColor = HEXCOLOR(0x333333);
//    cell.textLabel.font = sysFontWithSize(15);
//
//    cell.detailTextLabel.text = userNameStr;
//    cell.detailTextLabel.textColor = HEXCOLOR(0x969696);
//    cell.detailTextLabel.font = sysFontWithSize(12);
//
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - .5, JX_SCREEN_WIDTH, .5)];
//    view.backgroundColor = HEXCOLOR(0xdcdcdc);
//    [cell addSubview:view];
//
//    return cell;
    
    WH_AddFriend_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_AddFriend_WHCell"];
    cell.type = WHSettingCellTypeTitleWithContent;
    NSInteger numOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (numOfRows == 1) {
        cell.bgRoundType = WHSettingCellBgRoundTypeAll;
    } else {
        cell.bgRoundType = indexPath.row == 0 ? WHSettingCellBgRoundTypeTop : (indexPath.row == numOfRows - 1) ? WHSettingCellBgRoundTypeBottom : WHSettingCellBgRoundTypeNone;
    }
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%lu)",label.groupName, (unsigned long)userIds.count];
    cell.contentLabel.text = userNameStr;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WH_JXLabelObject *label = _array[indexPath.row];
    WH_JXNewLabel_WHVC *vc = [[WH_JXNewLabel_WHVC alloc] init];
    vc.title = Localized(@"JX_SettingLabel");
    vc.labelObj = label;
    [g_navigation pushViewController:vc animated:YES];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        WH_JXLabelObject *labelObj = _array[indexPath.row];
        _currentLabelObj = labelObj;
        [g_server WH_friendGroupDeleteWithGroupId:labelObj.groupId toView:self];
    }];
    
    return @[deleteBtn];
    
}


//服务器返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:wh_act_FriendGroupDelete]) {
        
        [_currentLabelObj delete];
        [_array removeObject:_currentLabelObj];
        [self.tableView reloadData];
    }
    
    // 同步标签
    if ([aDownload.action isEqualToString:wh_act_FriendGroupList]) {
        
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            WH_JXLabelObject *labelObj = [[WH_JXLabelObject alloc] init];
            labelObj.groupId = dict[@"groupId"];
            labelObj.groupName = dict[@"groupName"];
            labelObj.userId = dict[@"userId"];
            
            NSArray *userIdList = dict[@"userIdList"];
            NSString *userIdListStr = [userIdList componentsJoinedByString:@","];
            if (userIdListStr.length > 0) {
                labelObj.userIdList = [NSString stringWithFormat:@"%@", userIdListStr];
            }
            [labelObj insert];
        }
        
        // 删除服务器上已经删除的
        NSArray *arr = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        for (NSInteger i = 0; i < arr.count; i ++) {
            WH_JXLabelObject *locLabel = arr[i];
            BOOL flag = NO;
            for (NSInteger j = 0; j < array1.count; j ++) {
                NSDictionary * dict = array1[j];
                
                if ([locLabel.groupId isEqualToString:dict[@"groupId"]]) {
                    flag = YES;
                    break;
                }
            }
            
            if (!flag) {
                [locLabel delete];
            }
        }
        
        
        _array = [[WH_JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
        for (WH_JXLabelObject *labelObj in _array) {
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
        if (!_array || _array.count <= 0) {
            self.emptyView.hidden = NO;
        }else {
            self.emptyView.hidden = YES;
        }
        [self.tableView reloadData];
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


- (void)sp_checkNetWorking:(NSString *)string {
    NSLog(@"Get Info Success");
}
@end
