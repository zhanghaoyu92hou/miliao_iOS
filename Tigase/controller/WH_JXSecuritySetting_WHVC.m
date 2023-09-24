//
//  WH_JXSecuritySetting_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2019/4/3.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXSecuritySetting_WHVC.h"
#import "WH_JXDeviceLock_WHVC.h"
#import "WH_JXAccountBinding_WHVC.h"
#import "WH_AddFriend_WHCell.h"
#import "WH_JXPayPassword_WHVC.h"
#import "WH_ForgetPayPsw_WHVC.h"
#import "WH_VerifyPassAlertView.h"
#import "WH_PwsSecSettingViewController.h"
#import "WH_JXVerifyPay_WHVC.h"
#import "BindTelephoneChecker.h"

#define HEIGHT 55

@interface WH_JXSecuritySetting_WHVC () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    
    NSArray <NSArray *>* _items;
}

@property (nonatomic,strong) WH_JXVerifyPay_WHVC *verVC;

@end


@implementation WH_JXSecuritySetting_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    
    [self createHeadAndFoot];
    
    
    self.title = Localized(@"JX_SecuritySettings");
    
    [self commonInit];
    [self setupUI];
    
    /*
    UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, ([g_config.isThirdPartyLogins boolValue])?111:55)];
    [cView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_tableBody addSubview:cView];
    cView.layer.masksToBounds = YES;
    cView.layer.cornerRadius = g_factory.cardCornerRadius;
    cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cView.layer.borderWidth = g_factory.cardBorderWithd;
    
    int y = 0;
    WH_JXImageView *iv = [self WH_createMiXinButton:Localized(@"JX_EquipmentLock") drawTop:NO drawBottom:YES must:NO click:@selector(deviceLock:) superView:cView];
    iv.frame = CGRectMake(0,y, JX_SCREEN_WIDTH, HEIGHT);
    
    if ([g_config.isThirdPartyLogins boolValue]) {
        WH_JXImageView *iv2 = [self WH_createMiXinButton:Localized(@"JX_AccountAndBindSettings") drawTop:NO drawBottom:NO must:NO click:@selector(bindSetting) superView:cView];
        iv2.frame = CGRectMake(0, HEIGHT, cView.frame.size.width, HEIGHT);
    }
     */
    
    [g_notify addObserver:self selector:@selector(refreshPwsSecureQues) name:kPwsSecuSettingSuccessNotifaction object:nil];
    
}

- (void)refreshPwsSecureQues
{
//    self.questions = @"安全密码有值";
    [_tableView reloadData];
}


- (void)commonInit{
    
    NSMutableArray *mainArr = [NSMutableArray array];
    if ([g_config.wechatLoginStatus integerValue]==1 || [g_config.qqLoginStatus integerValue]==1) {
        [mainArr addObject:@[@{
                                 @"title":@"设备锁",
                                 @"content":@"",
                                 @"type":@(WHSettingCellTypeTitleWithContent),
                                 },
                             @{
                                 @"title":@"账号和绑定设置",
                                 @"content":@"",
                                 @"type":@(WHSettingCellTypeTitleWithContent),
                                 }]];
    }else{
        [mainArr addObject:@[@{
                                 @"title":@"设备锁",
                                 @"content":@"",
                                 @"type":@(WHSettingCellTypeTitleWithContent),
                                 },
                             ]];
    }
    
//    [mainArr addObject:@[@{
//                             @"title":@"修改支付密码",
//                             @"content":@"",
//                             @"type":@(WHSettingCellTypeTitleWithContent),
//                             },
//                         @{
//                             @"title":@"忘记支付密码",
//                             @"content":@"",
//                             @"type":@(WHSettingCellTypeTitleWithContent),
//                             },
//                         ]];
    
    
    
    if ([g_config.isQestionOpen integerValue] == 1) {
        [mainArr addObject:@[@{
                                 @"title":@"密保问题",
                                 @"content":@"未设置",
                                 @"type":@(WHSettingCellTypeTitleWithRightContent),
                                 }]];
    }
    _items = mainArr;
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
    return 13;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
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
    NSInteger numOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (numOfRows == 1) {
        cell.bgRoundType = WHSettingCellBgRoundTypeAll;
    } else {
        cell.bgRoundType = indexPath.row == 0 ? WHSettingCellBgRoundTypeTop : indexPath.row == numOfRows - 1 ? WHSettingCellBgRoundTypeBottom : WHSettingCellBgRoundTypeNone;
    }
    cell.iconImageView.image = nil;
    cell.contentLabel.text = item[@"content"];
    cell.titleLabel.text = item[@"title"];
    cell.accessoryImageView.hidden = NO;
    if (indexPath.section == 2 && indexPath.row == 0) {//密保问题
        if (g_myself.questions.count > 0) {
            cell.contentLabel.text = Localized(@"PassHasSet");
        }else {
            cell.contentLabel.text = @"未设置";
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //设备锁
            WH_JXDeviceLock_WHVC *vc = [[WH_JXDeviceLock_WHVC alloc] init];
            [g_navigation pushViewController:vc animated:YES];
        } else {
            //账号和绑定设置
            WH_JXAccountBinding_WHVC *bindVC = [[WH_JXAccountBinding_WHVC alloc] init];
            bindVC.userObject = g_myself;
            [g_navigation pushViewController:bindVC animated:YES];
        }
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {//修改支付密码
            [BindTelephoneChecker checkBindPhoneWithViewController:self entertype:JXEnterTypeSecureSetting];
        } else {
            //忘记支付密码
            g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
            if ([g_myself.isPayPassword boolValue]) {
                WH_ForgetPayPsw_WHVC *forgetPayPsw = [[WH_ForgetPayPsw_WHVC alloc] init];
                [g_navigation pushViewController:forgetPayPsw animated:YES];
            }else if (![g_myself.isPayPassword boolValue]) {//不存在支付密码
                [BindTelephoneChecker checkBindPhoneWithViewController:self entertype:JXEnterTypeForgetPayPsw];
            }
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            //密保问题
            WH_PwsSecSettingViewController* vc = [[WH_PwsSecSettingViewController alloc] init];
            vc.questionBlock = ^(NSString * _Nonnull questions) {
                if (questions.length > 0) {
                     [_tableView reloadData];
                }
            };
            [g_navigation pushViewController:vc animated:YES];
        }
    }
}
//未设置支付密码，设置支付密码
- (void)setPaypassForFirstTime {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"您还未设置支付密码，请设置支付密码。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WH_JXPayPassword_WHVC * PayVC = [WH_JXPayPassword_WHVC alloc];
        PayVC.type = JXPayTypeSetupPassword;
        PayVC.enterType = JXEnterTypeSecureSetting;
        PayVC = [PayVC init];
        [g_navigation pushViewController:PayVC animated:YES];
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)WH_didVerifyPay:(NSString *)sender {
    WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
    user.payPassword = sender;
    [g_server WH_checkPayPasswordWithUser:user toView:self];
}


- (void)WH_dismiss_WHVerifyPayVC {
    [self.verVC.view removeFromSuperview];
}

//设备锁
- (void)deviceLock:(WH_JXImageView *)imageView {
    
    WH_JXDeviceLock_WHVC *vc = [[WH_JXDeviceLock_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}
//账号和绑定设置
- (void)bindSetting {
    WH_JXAccountBinding_WHVC *bindVC = [[WH_JXAccountBinding_WHVC alloc] init];
    [g_navigation pushViewController:bindVC animated:YES];
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click superView:(UIView *)superView{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    btn.wh_delegate = self;
    [superView addSubview:btn];
    //    [btn release];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = sysFontWithSize(18);
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
        //        [p release];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(28, 0, 200, HEIGHT)];
    p.text = title;
    p.font = [UIFont systemFontOfSize:16.2];
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    //    [p release];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 19, (55 - 12)/2, 7, 12)];
        iv.image = [UIImage imageNamed:@"WH_Back"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}




@end
