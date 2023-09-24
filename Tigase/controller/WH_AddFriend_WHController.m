//
//  WH_AddFriend_WHController.m
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AddFriend_WHController.h"
#import "WH_AddFriend_WHCell.h"
#import "WH_SearchData.h"
#import "WH_SearchFriendResult_WHController.h"
#import "WH_JXAddressBook_WHVC.h"
#import "WH_JXInviteAddressBook_WHVC.h"
#import "WH_JXUserObject+GetCurrentUser.h"
#import "WH_QRCode_WHViewController.h"

@interface WH_AddFriend_WHController () <UITableViewDelegate,UITableViewDataSource>
{
    NSArray <NSArray *> *_items;
    UITableView *_tableView ;
}

@end

@implementation WH_AddFriend_WHController

- (id)init{
    if (self = [super init]) {
        [self commonInit];
        [self setupNavigation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [g_server getUser:MY_USER_ID toView:self];
    [self getCurrentUserInfo];
    [self setupUI];
}
- (void)getCurrentUserInfo {
    [[WH_JXUserObject sharedUserInstance] getCurrentUser];
    [WH_JXUserObject sharedUserInstance].complete = ^(HttpRequestStatus status, NSDictionary * _Nullable userInfo, NSError * _Nullable error) {
        switch (status) {
            case HttpRequestSuccess:
            {
                self.user = [WH_JXUserObject sharedUserInstance];
                [_tableView reloadData];
            }
                break;
            case HttpRequestFailed:
            {
                
            }
                break;
            case HttpRequestError:
            {
                
            }
                break;
                
            default:
                break;
        }
    };
}
- (void)commonInit{
    NSString *str = @"";
    if ([g_config.regeditPhoneOrName intValue] == 1) {
        //用户名登录
        str = Localized(@"WaHu_UserName_WaHu");
    }else{
        str = @"手机号";
    }
    _items = @[
               @[@{@"icon":@"icon_search",
                 @"title":str,
                 @"content":@"",
                 @"type":@(WHSettingCellTypeIconWithTextField),
                 @"bgRoundType":@(WHSettingCellBgRoundTypeAll),
                 }],
               @[@{@"icon":@"WH_addressbook_phone_contact",
                   @"title":@"手机联系人",
                   @"content":@"查看已注册的手机联系人",
                   @"type":@(WHSettingCellTypeCommon),
                   @"bgRoundType":@(WHSettingCellBgRoundTypeTop),
                   },
                 @{@"icon":@"WH_addressbook_invitefriend",
                   @"title":@"邀请好友",
                   @"content":@"短信邀请手机通讯录好友",
                   @"type":@(WHSettingCellTypeCommon),
                   @"bgRoundType":@(WHSettingCellBgRoundTypeBottom),
                   },
                 ],
               ];
}

- (void)setupNavigation{
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0.f;
    self.title = Localized(@"WaHu_JXNear_WaHuVC_AddFriends");
    self.wh_isGotoBack   = YES;
    self.wh_isNotCreatewh_tableBody = YES;
    [self createHeadAndFoot];
}

- (void)setupUI{
    [self setupTable];
}

- (void)setupTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(JX_SCREEN_TOP, 0, 0, 0));
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = g_factory.globalBgColor;
    [_tableView registerClass:[WH_AddFriend_WHCell class] forCellReuseIdentifier:@"WH_AddFriend_WHCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _items.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 13 : 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [UIView new];
    }
    UIView *header = [UIView new];
    
    UILabel *titleLabel = [UILabel new];
    [header addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(-(8+20));
        make.centerY.offset(0);
    }];
//    titleLabel.text = [NSString stringWithFormat:@"我的通讯号：%@",@"17348888"];
    titleLabel.text = [NSString stringWithFormat:@"我的账号：%@",self.user.account?:@""];
    titleLabel.textColor = HEXCOLOR(0x8C9AB8);
    titleLabel.font = sysFontWithSize(12);
    
    UIImageView *qr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_addressbook_qrcode"]];
    [header addSubview:qr];
    [qr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(8);
        make.centerY.equalTo(titleLabel);
    }];
    [qr addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickQrImage)]];
    qr.userInteractionEnabled = YES;
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

//弹出二维码
- (void)clickQrImage{
    WH_QRCode_WHViewController *qrVC = [[WH_QRCode_WHViewController alloc] init];
    qrVC.type = QR_UserType;
    qrVC.wh_userId = self.user.userId;
    qrVC.wh_nickName = self.user.userNickname;
    //        qrVC.roomJId = room.roomJid;
    //        qrVC.groupNum = self.groupNum;
    [self presentViewController:qrVC animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WH_AddFriend_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_AddFriend_WHCell"];
    
    NSDictionary *item = _items[indexPath.section][indexPath.row];
    cell.type = [item[@"type"] intValue];
    cell.bgRoundType = [item[@"bgRoundType"] intValue];
    cell.iconImageView.image = [UIImage imageNamed:item[@"icon"]];
    cell.contentLabel.text = item[@"content"];
    if (cell.type == WHSettingCellTypeIconWithTextField) {
        cell.titleLabel.text = nil;
        cell.textField.placeholder = item[@"title"];
        cell.textField.returnKeyType = UIReturnKeySearch;
        __weak typeof(self) weakSelf = self;
        cell.onTextFieldReturnKeyPress = ^(WH_AddFriend_WHCell * _Nonnull cell, UITextField * _Nonnull textField) {
            //按下搜索按钮
            [weakSelf searchFriend:textField.text];
        };
    } else {
        cell.titleLabel.text = item[@"title"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1){
        if(indexPath.row == 0){
            //手机联系人
//            WH_PhoneContact_WHController *vc = [[WH_PhoneContact_WHController alloc] init];
//            [g_navigation pushViewController:vc animated:YES];
            [self addressBookAction:nil];
        } else {
            //邀请好友
            [self inviteFriend];
        }
    }
}
- (void)addressBookAction:(WH_JXImageView *)imageView {
    
    WH_JXAddressBook_WHVC *vc = [[WH_JXAddressBook_WHVC alloc] init];
    NSMutableArray *arr = [[JXAddressBook sharedInstance] doFetchUnread];
    vc.abUreadArr = arr;
    [g_navigation pushViewController:vc animated:YES];
    [[JXAddressBook sharedInstance] updateUnread];
    
    WH_JXMsgAndUserObject* newobj = [[WH_JXMsgAndUserObject alloc]init];
    newobj.user = [[WH_JXUserObject sharedUserInstance] getUserById:FRIEND_CENTER_USERID];
//    [self showNewMsgCount:[newobj.user.msgsNew integerValue]];
}
- (void)inviteFriend {
    
    WH_JXInviteAddressBook_WHVC *vc = [[WH_JXInviteAddressBook_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}
//搜索好友
- (void)searchFriend:(NSString *)searchText{
    WH_SearchData *job = [[WH_SearchData alloc] init];
    job.sex    = -1;
    job.name = searchText;
    job.minAge = 0;
    job.maxAge = 0;
    
    NSLog(@"self.user:%@  self.user.isAddFriend:%@" ,self.user ,self.user.isAddFirend);
    
    WH_SearchFriendResult_WHController *vc = [WH_SearchFriendResult_WHController alloc];
    vc.isAddFriend = self.user.isAddFirend;
    vc.search = job;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

#pragma 服务端返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    [_wait hide];
    
    if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        self.user = user;
        
        [_tableView reloadData];
    }
}
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_hide_error;
}



@end
