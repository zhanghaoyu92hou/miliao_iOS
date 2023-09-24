//
//  WH_MineViewController.m
//  Tigase
//
//  Created by Apple on 2019/6/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_MineViewController.h"

#import "WH_JXMyMoney_WHViewController.h"
#import "WH_JXCourseList_WHVC.h"
#import "WH_WeiboViewControlle.h"
#import "userWeiboVC.h"
#import "WH_JXSecuritySetting_WHVC.h"
#import "WH_JXSettings_WHViewController.h"
#import "WH_JXSetting_WHVC.h"

#import "WH_PersonalData_WHViewController.h"
#import "WH_MyWallet_WHViewController.h"
#import "WH_Collect_WHViewController.h"
#import "WH_JXUserObject+GetCurrentUser.h"
#import "WH_JXImageScroll_WHVC.h"
#import "DMScaleTransition.h"
@interface WH_MineViewController ()
{
    DMScaleTransition *_scaleTransition;
}

@end

@implementation WH_MineViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //获取余额
        [g_server WH_getUserMoenyToView:self];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isRefresh) {
        self.isRefresh = NO;
    }else{
        [super viewDidAppear:animated];
        [self WH_doRefresh:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localized(@"JX_My");
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = JX_SCREEN_BOTTOM;
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    //@[@[@""] ,@[@"我的钱包" ,@"我的收藏" ,@"生活动态" ,@"我的讲课"] ,@[@"安全设置" ,@"隐私设置" ,@"其他设置"]];
    
    //我的讲课,2019年11月1日后干掉
//    if ([g_App.isShowRedPacket integerValue] == 1) {
//        self.wh_dataArray = @[@[@""] ,@[Localized(@"JX_MyBalance") ,Localized(@"JX_MyCollection") , Localized(@"WaHu_LifeStatus_WaHu"),Localized(@"JX_MyLecture")] ,@[Localized(@"JX_SecuritySettings") ,Localized(@"JX_PrivacySettings") ,Localized(@"WaHu_OtherSetting_WaHu")]];
//        self.wh_imgsArray = @[@[@""] ,@[@"MyWallet" ,@"MyCollection" ,@"My_DongTai" ,@"My_JiangKe"] ,@[@"My_AnQuanSheZhi" ,@"My_YinSiSheZhi" ,@"My_QiTaSheZhi"]];
//    }else {
//        //隐藏钱包
//        self.wh_dataArray = @[@[@""] ,@[Localized(@"JX_MyCollection") ,Localized(@"WaHu_LifeStatus_WaHu") ,Localized(@"JX_MyLecture")] ,@[Localized(@"JX_SecuritySettings") ,Localized(@"JX_PrivacySettings") ,@"其他设置"]];
//        self.wh_imgsArray = @[@[@""] ,@[@"MyCollection" ,@"My_DongTai" ,@"My_JiangKe"] ,@[@"My_AnQuanSheZhi" ,@"My_YinSiSheZhi" ,@"My_QiTaSheZhi"]];
//    }
    if ([g_App.isShowRedPacket integerValue] == 1) {
        self.wh_dataArray = @[@[@""] ,@[Localized(@"JX_MyBalance") ,Localized(@"JX_MyCollection") , Localized(@"WaHu_LifeStatus_WaHu")] ,@[Localized(@"JX_SecuritySettings") ,Localized(@"JX_PrivacySettings") ,Localized(@"WaHu_OtherSetting_WaHu")]];
        self.wh_imgsArray = @[@[@""] ,@[@"MyWallet" ,@"MyCollection" ,@"My_DongTai"] ,@[@"My_AnQuanSheZhi" ,@"My_YinSiSheZhi" ,@"My_QiTaSheZhi"]];
    }else {
        //隐藏钱包
//        self.wh_dataArray = @[@[@""] ,@[Localized(@"JX_MyCollection") ,Localized(@"WaHu_LifeStatus_WaHu")] ,@[Localized(@"JX_SecuritySettings") ,Localized(@"JX_PrivacySettings") ,@"其他设置"]];
//        self.wh_imgsArray = @[@[@""] ,@[@"MyCollection" ,@"My_DongTai"] ,@[@"My_AnQuanSheZhi" ,@"My_YinSiSheZhi" ,@"My_QiTaSheZhi"]];
        
        self.wh_dataArray = @[@[@""] ,@[Localized(@"JX_MyCollection")] ,@[Localized(@"JX_SecuritySettings") ,Localized(@"JX_PrivacySettings") ,@"其他设置"]];
        self.wh_imgsArray = @[@[@""] ,@[@"MyCollection"] ,@[@"My_AnQuanSheZhi" ,@"My_YinSiSheZhi" ,@"My_QiTaSheZhi"]];
    }
    
    
//    [g_server getUser:MY_USER_ID toView:self];
    [self getCurrentUserInfo];
    [self createContentView];
    
    
    
    [g_notify addObserver:self selector:@selector(WH_doRefresh:) name:kUpdateUser_WHNotifaction object:nil];
    
    [g_notify addObserver:self selector:@selector(wh_updateUserInfo:) name:kXMPPMessageUpdateUserInfo_WHNotification object:nil];
}
- (void)getCurrentUserInfo {
    [[WH_JXUserObject sharedUserInstance] getCurrentUser];
    [WH_JXUserObject sharedUserInstance].complete = ^(HttpRequestStatus status, NSDictionary * _Nullable userInfo, NSError * _Nullable error) {
        switch (status) {
            case HttpRequestSuccess:
            {
                //id号 即为通讯号
                self.wh_nameLabel.text = g_myself.userNickname;
                NSLog(@"g_myself:%@" ,g_myself);
                self.userId.text = [NSString stringWithFormat:@"账号:%@",g_myself.account?:@""];
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
- (void)createContentView {
    self.wh_tableView = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset),JX_SCREEN_HEIGHT - JX_SCREEN_TOP - JX_SCREEN_BOTTOM) style:UITableViewStylePlain];
    [self.wh_tableView setDelegate:self];
    [self.wh_tableView setDataSource:self];
    [self.wh_tableView setBackgroundColor:self.wh_tableBody.backgroundColor];
    [self.wh_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_tableBody addSubview:self.wh_tableView];
}

-(void)WH_doRefresh:(NSNotification *)notifacation{
    
    WH_JXMessageObject *msg=[[WH_JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = MY_USER_ID;
    msg.content = @"1";
    msg.toUserId     = MY_USER_ID;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeMultipleGetUserInfo];
    [g_xmpp sendMessage:msg roomName:nil];
    
    self.wh_headImgView.image = nil;
    [g_server WH_getHeadImageSmallWIthUserId:g_myself.userId userName:g_myself.userNickname imageView:self.wh_headImgView];
    
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //[infoDictionary objectForKey:@"CFBundleDisplayName"] ,
//    //id号 即为通讯号
    self.wh_nameLabel.text = g_myself.userNickname;
//    NSLog(@"g_myself:%@" ,g_myself);
    self.userId.text = [NSString stringWithFormat:@"账号:%@",g_myself.account?:@""];
}

#pragma mark 用户信息更改消息
- (void)wh_updateUserInfo:(NSNotification *)notification {
    [g_server getUser:MY_USER_ID toView:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.wh_dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        [cell setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if (indexPath.section == 0) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, CGRectGetWidth(self.wh_tableView.frame), 80)];
        [btn setTag:indexPath.section];
        [cell addSubview:btn];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.wh_headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
        [btn addSubview:self.wh_headImgView];
        self.wh_headImgView.layer.cornerRadius = (MainHeadType)?(20):(g_factory.headViewCornerRadius);
        self.wh_headImgView.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap:)];
        [self.wh_headImgView addGestureRecognizer:tap];
        [self.wh_headImgView setUserInteractionEnabled:YES];
        
        //用户名称
        self.wh_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.wh_headImgView.frame.origin.x + 12 + CGRectGetWidth(self.wh_headImgView.frame), 16, CGRectGetWidth(self.wh_tableView.frame) - self.wh_headImgView.frame.origin.x - CGRectGetWidth(self.wh_headImgView.frame) - 12 - 50, 20)];
        [self.wh_nameLabel setTextColor:HEXCOLOR(0x3A404C)];
        [self.wh_nameLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15]];
        [btn addSubview:self.wh_nameLabel];
        
        //用户ID
        self.userId = [[UILabel alloc] initWithFrame:CGRectMake(self.wh_headImgView.frame.origin.x + 12 + CGRectGetWidth(self.wh_headImgView.frame), 44, CGRectGetWidth(self.wh_tableView.frame) - self.wh_headImgView.frame.origin.x - CGRectGetWidth(self.wh_headImgView.frame) - 12 - 50, 20)];
        [self.userId setTextColor:HEXCOLOR(0x969696)];
        [self.userId setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
        [btn addSubview:self.userId];
        
        UIImageView *cardImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.wh_tableView.frame) - 47, 30, 20, 20)];
        [cardImg setImage:[UIImage imageNamed:@"My_ErWeiMa"]];
        [btn addSubview:cardImg];
        
        UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.wh_tableView.frame) - 19, (80 - 12)/2, 7, 12)];
        [markImg setImage:[UIImage imageNamed:@"WH_Back"]];
        [btn addSubview:markImg];
    }else{
        NSArray *imgsArray = [self.wh_imgsArray objectAtIndex:indexPath.section];
        NSArray *nameArray = [self.wh_dataArray objectAtIndex:indexPath.section];
        
        for (int i = 0; i < nameArray.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0, i*55, CGRectGetWidth(self.wh_tableView.frame), 55)];
            [cell addSubview:btn];
            [self createCellContentWithSupView:btn imageName:[imgsArray objectAtIndex:i] labelText:[nameArray objectAtIndex:i]];
            
            if (indexPath.section == 1) {
                btn.tag = indexPath.section + i;
            }else{
                btn.tag = indexPath.section + i + (([g_App.isShowRedPacket integerValue] == 1)?3:2);
            }
            
            if (i < nameArray.count - 1) {
                UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, (i+1)*55, CGRectGetWidth(self.wh_tableView.frame), 1)];
                [lView setBackgroundColor:HEXCOLOR(0xF8F8F7)];
                [cell addSubview:lView];
            }
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
    cell.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cell.layer.borderWidth = g_factory.cardBorderWithd;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 80;
    } else {
        return [[self.wh_dataArray objectAtIndex:indexPath.section] count]*55;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.wh_tableView.frame), 12)];
    [view setBackgroundColor:self.wh_tableBody.backgroundColor];
    return view;
}
- (void)createCellContentWithSupView:(id)supView imageName:(NSString *)imgName labelText:(NSString *)lText {
    //图标
    UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, (55 - 20)/2, 20, 20)];
    [iconImg setImage:[UIImage imageNamed:imgName]];
    [supView addSubview:iconImg];
    
    //名称
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconImg.frame.origin.x + CGRectGetWidth(iconImg.frame) + 20, 0, CGRectGetWidth(self.wh_tableView.frame) - iconImg.frame.origin.x - CGRectGetWidth(iconImg.frame) - 20 - 29, 55)];
    [label setText:lText];
    [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    [label setTextColor:HEXCOLOR(0x3A404C)];
    [supView addSubview:label];
    
    //图标
    UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.wh_tableView.frame) - 19, (55 - 12)/2, 7, 12)];
    [markImg setImage:[UIImage imageNamed:@"WH_Back"]];
    [supView addSubview:markImg];
}

#pragma mark - 头像点击方法
-(void)imageTap:(UIGestureRecognizer *)tap{
    
    WH_JXImageScroll_WHVC * imageVC = [[WH_JXImageScroll_WHVC alloc]init];
    
    imageVC.imageSize = CGSizeMake(JX_SCREEN_WIDTH, JX_SCREEN_WIDTH);
    
    imageVC.iv = [[WH_JXImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_WIDTH)];
    
    imageVC.iv.center = imageVC.view.center;
    
    [g_server WH_getHeadImageLargeWithUserId:MY_USER_ID userName:kMY_USER_NICKNAME imageView:imageVC.iv];
    if (@available(iOS 13.0, *)) {
        imageVC.modalPresentationStyle = UIModalPresentationFullScreen;
    }else{
        [self WH_addTransition:imageVC];
    }
    
    
    [self presentViewController:imageVC animated:YES completion:^{
        
    }];
}
//添加VC转场动画
- (void) WH_addTransition:(WH_JXImageScroll_WHVC *) siv
{
    _scaleTransition = [[DMScaleTransition alloc]init];
    [siv setTransitioningDelegate:_scaleTransition];
    
}

- (void)buttonClick:(UIButton *)button {
    NSLog(@"我的 click button tag:%ld" ,(long)button.tag);
    if (button.tag == 0) {
        //个人信息
//        [g_server getUser:MY_USER_ID toView:self];
        
        WH_PersonalData_WHViewController *pdVC = [[WH_PersonalData_WHViewController alloc] init];
        pdVC.wh_headImage = [self.wh_headImgView.image copy];
        pdVC.user = g_myself;
        g_myself.userNickname = g_myself.userNickname;
        NSRange range = [g_myself.telephone rangeOfString:@"86"];
        if (range.location != NSNotFound) {
            g_myself.telephone = [g_myself.telephone substringFromIndex:range.location + range.length];
        }
        [g_navigation pushViewController:pdVC animated:YES];
        
    }else{
        if ([g_App.isShowRedPacket integerValue] == 1) {
            if (button.tag == 1) {
                //我的钱包
                
                WH_MyWallet_WHViewController *moneyVC = [[WH_MyWallet_WHViewController alloc] init];
                [g_navigation pushViewController:moneyVC animated:YES];
                
                //        WH_JXMyMoney_WHViewController * moneyVC = [[WH_JXMyMoney_WHViewController alloc] init];
                //        [g_navigation pushViewController:moneyVC animated:YES];
                
            }else if (button.tag == 2) {
                //我的收藏
                WH_Collect_WHViewController *collectVC = [[WH_Collect_WHViewController alloc] init];
                [g_navigation pushViewController:collectVC animated:YES];
                
                //        WeiboViewControlle * collection = [[WeiboViewControlle alloc] initCollection];
                //        [g_navigation pushViewController:collection animated:YES];
                
            }else if (button.tag == 3) {
                //生活状态
                userWeiboVC* vc = [userWeiboVC alloc];
                vc.user = g_myself;
                vc.wh_isGotoBack = YES;
                vc = [vc init];
                //    [g_window addSubview:vc.view];
                [g_navigation pushViewController:vc animated:YES];
                
            }else if (button.tag == 4) {
                //我的讲课,11月1日后干掉
//                WH_JXCourseList_WHVC *vc = [[WH_JXCourseList_WHVC alloc] init];
//                [g_navigation pushViewController:vc animated:YES];
                
            }else if (button.tag == 5) {
                //安全设置
                WH_JXSecuritySetting_WHVC *vc = [[WH_JXSecuritySetting_WHVC alloc] init];
                [g_navigation pushViewController:vc animated:YES];
                
            }else if (button.tag == 6) {
                //隐私设置
                [g_server WH_getFriendSettingsWithUserId:[NSString stringWithFormat:@"%ld",g_server.user_id] toView:self];
                
            }else if (button.tag == 7) {
                //其他设置
                WH_JXSetting_WHVC* vc = [[WH_JXSetting_WHVC alloc]init];
                [g_navigation pushViewController:vc animated:YES];
            }
        }else{
            if (button.tag == 1) {
                //我的收藏
                WH_Collect_WHViewController *collectVC = [[WH_Collect_WHViewController alloc] init];
                [g_navigation pushViewController:collectVC animated:YES];
                
                //        WeiboViewControlle * collection = [[WeiboViewControlle alloc] initCollection];
                //        [g_navigation pushViewController:collection animated:YES];
                
            }else if (button.tag == 2) {
                //生活状态
                userWeiboVC* vc = [userWeiboVC alloc];
                vc.user = g_myself;
                vc.wh_isGotoBack = YES;
                vc = [vc init];
                //    [g_window addSubview:vc.view];
                [g_navigation pushViewController:vc animated:YES];
                
            }else if (button.tag == 3) {
                //我的讲课
//                WH_JXCourseList_WHVC *vc = [[WH_JXCourseList_WHVC alloc] init];
//                [g_navigation pushViewController:vc animated:YES];
                
            }else if (button.tag == 4) {
                //安全设置
                WH_JXSecuritySetting_WHVC *vc = [[WH_JXSecuritySetting_WHVC alloc] init];
                [g_navigation pushViewController:vc animated:YES];
                
            }else if (button.tag == 5) {
                //隐私设置
                [g_server WH_getFriendSettingsWithUserId:[NSString stringWithFormat:@"%ld",g_server.user_id] toView:self];
                
            }else if (button.tag == 6) {
                //其他设置
                WH_JXSetting_WHVC* vc = [[WH_JXSetting_WHVC alloc]init];
                [g_navigation pushViewController:vc animated:YES];
            }
        }
    }
}

#pragma 服务端返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    [_wait hide];
    
    if( [aDownload.action isEqualToString:wh_act_resumeList] ){
    }else if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        [g_myself WH_getDataFromDict:dict];
        
        //id号 即为通讯号
        self.wh_nameLabel.text = @"";
        self.wh_nameLabel.text = g_myself.userNickname;
        NSLog(@"g_myself:%@" ,g_myself);
        self.userId.text = @"";
        self.userId.text = [NSString stringWithFormat:@"账号:%@",g_myself.account?:@""];
    }else if ([aDownload.action isEqualToString:wh_act_getUserMoeny]) {
        g_App.myMoney = [dict[@"balance"] doubleValue];
    }else if ([aDownload.action isEqualToString:wh_act_Settings]){
        //跳转新的页面
        WH_JXSettings_WHViewController* vc = [[WH_JXSettings_WHViewController alloc]init];
        vc.dataSorce = dict;
        [g_navigation pushViewController:vc animated:YES];
        [_wait stop];
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


- (void)sp_didUserInfoFailed {
    NSLog(@"Continue");
}

- (void)sp_getUsersMostLiked:(NSString *)string {
    NSLog(@"Get Info Success");
}
@end
