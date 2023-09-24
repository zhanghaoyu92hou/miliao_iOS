//
//  WH_FindViewController.m
//  Tigase
//
//  Created by Apple on 2019/6/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_FindViewController.h"

#import "JXBlogRemind.h"

#import "WH_JXTabMenuView.h"
#import "WH_FindTableViewCell.h"

#import "WH_WeiboViewControlle.h"
#import "WH_JXNear_WHVC.h"

#import "WH_webpage_WHVC.h"

#ifdef Meeting_Version
#import "WH_JXSelectFriends_WHVC.h"
#import "JXAVCallViewController.h"
#endif

#ifdef Live_Version
#import "WH_JXLive_WHViewController.h"
#endif

#ifdef Meeting_Version
#ifdef Live_Version
#import "WH_GKDYHome_WHViewController.h"
#import "JXSmallVideoViewController.h"
#endif
#endif

#import "WH_Signature_WHViewController.h"
#import "WH_JXPublicNumber_WHVC.h"
#import "WH_GKDYVideoModel.h"
#import "GKDYVideoView.h"
#import "WH_GKDYPlayer_WHViewController.h"

@interface WH_FindViewController ()

@property (nonatomic, strong) NSMutableArray *smallVideos;

@end

@implementation WH_FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"WaHu_JXMain_WaHuViewController_Find");
    
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = JX_SCREEN_BOTTOM;
    [self createHeadAndFoot];
    
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    self.wh_cMenuArray = [[NSMutableArray alloc] init];
    
    self.wh_dataArray = [[NSMutableArray alloc] init];
    
    //@[@[生活圈] ,@[短视频 ,视频会议 ,视频直播] ,@[附近的人] ,@[公众号]]
    if (g_config.isOpenPositionService) {
        //是否开启位置相关服务 0：开启 1：关闭
        self.wh_imagesArray = @[@[@"WH_ShengHuoQuan"] ,@[@"WH_DuanShiPin" ,@"WH_ShiPinHuiYi" ,@"WH_ShiPinZhiBo"] ,@[@"WH_GongZhongHao"] ,@[@"WH_QianDaoHongBao"]]; //注释签到红包


        self.wh_nameArray = @[@[Localized(@"WaHu_LifeCircle_WaHu")] ,@[Localized(@"JX_ShorVideo") ,Localized(@"WaHu_JXSetting_WaHuVC_VideoMeeting") ,Localized(@"JX_LiveVideo")] ,@[Localized(@"JX_PublicNumber")],@[Localized(@"WaHu_SignRedPacket_WaHu")]]; //注释签到红包
    }else{
        self.wh_imagesArray = @[@[@"WH_ShengHuoQuan"] ,@[@"WH_DuanShiPin" ,@"WH_ShiPinHuiYi" ,@"WH_ShiPinZhiBo"] ,@[@"WH_FuJinDeRen_FaXian"] ,@[@"WH_GongZhongHao"] ,@[@"WH_QianDaoHongBao"]]; //注释签到红包
        
        self.wh_nameArray = @[@[Localized(@"WaHu_LifeCircle_WaHu")] ,@[Localized(@"JX_ShorVideo") ,Localized(@"WaHu_JXSetting_WaHuVC_VideoMeeting") ,Localized(@"JX_LiveVideo")] ,@[Localized(@"WaHu_JXNear_WaHuVC_NearPer")] ,@[Localized(@"JX_PublicNumber")],@[Localized(@"WaHu_SignRedPacket_WaHu")]]; //注释签到红包

    }
    
    for (int i = 0; i < self.wh_nameArray.count; i++) {
        
        NSMutableArray *sArray = [[NSMutableArray alloc] init];
        NSArray *ary = [self.wh_nameArray objectAtIndex:i];
        NSArray *mAry = [self.wh_imagesArray objectAtIndex:i];
        
        if (g_config.isOpenPositionService) {
            for (int j = 0; j < ary.count; j++) {
                NSInteger index = 0;
                if (i == 0) {
                    index = 1;
                }else if (i == 2) {
                    index = 6;
                }else if (i == 3) {
                    index = 7;
                }//注释签到红包
                else{
                    index = i+j+1;
                }
                NSDictionary *dict = @{@"discoverNum":[NSNumber numberWithInteger:index] ,@"discoverImg":[mAry objectAtIndex:j] ,@"discoverName":[ary objectAtIndex:j]};
                [sArray addObject:dict];
            }
        }else{
            for (int j = 0; j < ary.count; j++) {
                NSInteger index = 0;
                if (i == 0) {
                    index = 1;
                }else if (i == 2) {
                    index = 5;
                }else if (i == 3) {
                    index = 6;
                }
                else if (i == 4){
                    index = 7;
                } //注释签到红包
                else{
                    index = i+j+1;
                }
                NSDictionary *dict = @{@"discoverNum":[NSNumber numberWithInteger:index] ,@"discoverImg":[mAry objectAtIndex:j] ,@"discoverName":[ary objectAtIndex:j]};
                [sArray addObject:dict];
            }
        }
        
        [self.wh_dataArray addObject:sArray];
        
    }
    
    [g_server requestCustomMenuWithToView:self];
    
//    [self WaHu_getServerData];
    
    [g_notify addObserver:self selector:@selector(remindNotif:) name:kXMPPMessageWeiboRemind_WHNotification object:nil];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showNewMsgNoti];
}

- (void)WaHu_getServerData {
//    _isLoading = YES;
//    NSString *lable = [NSString stringWithFormat:@"%ld",self.type];
//    if (self.type == JXSmallVideoTypeOther) {
//        lable = nil;
//    }
    _smallVideos = [NSMutableArray array];
    [g_server WH_circleMsgPureVideoPageIndex:0 lable:nil toView:self];
}

- (void)showNewMsgNoti {
    _wh_remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    
    NSString *newMsgNum = [NSString stringWithFormat:@"%lu",(unsigned long)_wh_remindArray.count];
    if (_wh_remindArray.count >= 10 && _wh_remindArray.count <= 99) {
        self.wh_weiboNewMsgNum.font = sysFontWithSize(12);
    }else if (_wh_remindArray.count > 0 && _wh_remindArray.count < 10) {
        self.wh_weiboNewMsgNum.font = sysFontWithSize(13);
    }else if(_wh_remindArray.count > 99){
        self.wh_weiboNewMsgNum.font = sysFontWithSize(9);
    }
    if (self.wh_tableView) {
        self.wh_numMarkLabel.hidden = _wh_remindArray.count <= 0;
        [self.wh_tableView reloadData];
    }else {
        [self createContentView];
    }
    
    self.wh_weiboNewMsgNum.text = newMsgNum;
    [g_mainVC.tb wh_setBadge:g_mainVC.tb.wh_items.count == 5 ? 3 : 2 title:newMsgNum];
    self.wh_weiboNewMsgNum.hidden = _wh_remindArray.count <= 0;
    
}

- (void)createContentView {
    //globelEdgeInset
    self.wh_tableView = [[UITableView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 0, JX_SCREEN_WIDTH - 2*(g_factory.globelEdgeInset),JX_SCREEN_HEIGHT - JX_SCREEN_TOP - JX_SCREEN_BOTTOM) style:UITableViewStylePlain];
    [self.wh_tableView setDelegate:self];
    [self.wh_tableView setDataSource:self];
    [self.wh_tableView setBackgroundColor:self.wh_tableBody.backgroundColor];
    [self.wh_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.wh_tableBody addSubview:self.wh_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.wh_cMenuArray.count > 0) {
//        return self.wh_dataArray.count + self.wh_cMenuArray.count;
        return self.wh_dataArray.count + 1;
    }else{
        return self.wh_dataArray.count;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *identifier = [NSString stringWithFormat:@"Cell_%li_%li" ,(long)indexPath.section ,(long)indexPath.row];
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        [cell setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
    cell.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cell.layer.borderWidth = g_factory.cardBorderWithd;
    
    if (indexPath.section < self.wh_dataArray.count) {
        NSArray *array = [self.wh_dataArray objectAtIndex:indexPath.section];
        
        for (int j = 0; j < array.count ; j++) {
            NSDictionary *dict = [array objectAtIndex:j];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0, j*55, CGRectGetWidth(self.wh_tableView.frame), 55)];
            [cell addSubview:btn];
            
            NSInteger discoverNum = [[dict objectForKey:@"discoverNum"] integerValue];
            btn.tag = discoverNum;
            
            NSString *imgUrl = [dict objectForKey:@"discoverImg"];
            NSLog(@"imgUrl:%@" ,imgUrl);
            Boolean isLink = ([[dict objectForKey:@"discoverImg"] hasPrefix:@"http://"] || [[dict objectForKey:@"discoverImg"] hasPrefix:@"https://"]);
            
            [self createCellContentWithSupView:btn imageName:[dict objectForKey:@"discoverImg"] labelText:[dict objectForKey:@"discoverName"] isLinkUrl:isLink buttonTag:discoverNum];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if (discoverNum == 1) {
                self.wh_numMarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, (55 - 16)/2, 16, 16)];
                [self.wh_numMarkLabel setBackgroundColor:HEXCOLOR(0xED6350)];
                [self.wh_numMarkLabel setTextColor:HEXCOLOR(0xffffff)];
                [self.wh_numMarkLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 12]];
                
                self.wh_numMarkLabel.layer.cornerRadius = 8;
                self.wh_numMarkLabel.layer.masksToBounds = YES;
                [self.wh_numMarkLabel setTextAlignment:NSTextAlignmentCenter];
                if (_wh_remindArray.count <= 0) {
                    [self.wh_numMarkLabel setHidden:YES];
                }else{
                    [self.wh_numMarkLabel setHidden:NO];
                    NSString *newMsgNum = [NSString stringWithFormat:@"%lu",(unsigned long)_wh_remindArray.count];
                    self.wh_numMarkLabel.text = newMsgNum;
                    [btn addSubview:self.wh_numMarkLabel];
                }
            }
            
        }
        if (array.count > 1) {
            for (int i = 0; i < array.count; i++) {
                UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, (i+1)*(55 - g_factory.cardBorderWithd), CGRectGetWidth(self.wh_tableView.frame), g_factory.cardBorderWithd)];
                [lView setBackgroundColor:g_factory.globalBgColor];
                [cell addSubview:lView];
            }
        }
    }else{
        //自定义菜单
        
//        NSDictionary *dict = [self.wh_cMenuArray objectAtIndex:indexPath.section - self.wh_dataArray.count];
//
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setFrame:CGRectMake(0, 0, CGRectGetWidth(self.wh_tableView.frame), 55)];
//        btn.tag = indexPath.section - self.wh_dataArray.count;
//        [cell addSubview:btn];
//        [btn addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
//
//        [self createCellContentWithSupView:btn imageName:[dict objectForKey:@"discoverImg"] labelText:[dict objectForKey:@"discoverName"] isLinkUrl:YES buttonTag:indexPath.section - self.wh_dataArray.count];
        
//        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, (i+1)*55, CGRectGetWidth(self.tableView.frame), g_factory.cardBorderWithd)];
//        [lView setBackgroundColor:g_factory.globalBgColor];
//        [cell addSubview:lView];
        
//        for (int i = 0; i < self.cMenuArray.count; i++) {
//            NSDictionary *dict = [self.cMenuArray objectAtIndex:i];
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [btn setFrame:CGRectMake(0, i*55, CGRectGetWidth(self.tableView.frame), 55)];
//            btn.tag = i;
//            [cell addSubview:btn];
//            [btn addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
//
//            [self createCellContentWithSupView:btn imageName:[dict objectForKey:@"discoverImg"] labelText:[dict objectForKey:@"discoverName"] isLinkUrl:YES buttonTag:i];
//
//            UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, (i+1)*55, CGRectGetWidth(self.tableView.frame), g_factory.cardBorderWithd)];
//            [lView setBackgroundColor:g_factory.globalBgColor];
//            [cell addSubview:lView];
        
        for (int i = 0; i < self.wh_cMenuArray.count; i++) {
            NSDictionary *dict = [self.wh_cMenuArray objectAtIndex:i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0, i*55, CGRectGetWidth(self.wh_tableView.frame), 55)];
            btn.tag = i;
            [cell addSubview:btn];
            [btn addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self createCellContentWithSupView:btn imageName:[dict objectForKey:@"discoverImg"] labelText:[dict objectForKey:@"discoverName"] isLinkUrl:YES buttonTag:i];
            
            UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, (i+1)*55, CGRectGetWidth(self.wh_tableView.frame), g_factory.cardBorderWithd)];
            [lView setBackgroundColor:g_factory.globalBgColor];
            [cell addSubview:lView];
        }
        
//        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.wh_cMenuArray.count > 0) {
        if (indexPath.section < self.wh_dataArray.count) {
            NSArray *array = [self.wh_dataArray objectAtIndex:indexPath.section];
            return array.count*55;
        }else{
            return self.wh_cMenuArray.count*55;
//            return 55;
        }
    }else{
//        NSArray *array = [self.wh_dataArray objectAtIndex:indexPath.section];
        NSArray *array = [self.wh_dataArray objectAtIndex:indexPath.section];
        return array.count*55;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark 自定义菜单点击
- (void)menuClick:(UIButton *)button {
    NSDictionary *dict = [self.wh_cMenuArray objectAtIndex:button.tag];
    WH_webpage_WHVC *webVC = [[WH_webpage_WHVC alloc] init];
    NSString *tabBarLinkUrl = [dict objectForKey:@"discoverLinkURL"]?:@"http://www.baidu.com";
    webVC.wh_isGotoBack= YES;
    webVC.isSend = YES;
    webVC.url = tabBarLinkUrl;
     //    [g_navigation.navigationView addSubview:webVC.view];
        [g_navigation pushViewController:webVC animated:YES];
}

- (void)buttonClick:(UIButton *)button {
    NSLog(@"=====button.tag:%li" ,(long)button.tag);
    //@[@[生活圈] ,@[短视频 ,视频会议 ,视频直播] ,@[附近的人] ,@[公众号]]
    if (button.tag == 1) {
        //生活圈
        WH_WeiboViewControlle *weiboVC = [WH_WeiboViewControlle alloc];
        weiboVC.user = g_myself;
        weiboVC = [weiboVC init];
        [g_navigation pushViewController:weiboVC animated:YES];
    }else if (button.tag == 2) {
        
        //短视频
        NSLog(@"短视频");
        //        [GKMessageTool showText:@"功能开发中"];
        //        return;
#ifdef Meeting_Version
#ifdef Live_Version
        //        JXSmallVideoViewController *vc = [[JXSmallVideoViewController alloc] init];
        //        [g_navigation pushViewController:vc animated:YES];
        
        //        if (!_smallVideos) {
        //            [self WaHu_getServerData];
        //            [JXMyTools showTipView:@"加载短视频中,请稍等"];
        //            return;
        //        }
        
        WH_GKDYHome_WHViewController *homeVC = [[WH_GKDYHome_WHViewController alloc] init];
        //        [homeVC.playerVC.videoView setModels:_smallVideos index:0];
        //            homeVC.playerVC.videoView.videos = arr;
        homeVC.wh_titleStr = @"推荐";
        //        homeVC.playerVC.videoView.index = indexPath.row;
        [g_navigation pushViewController:homeVC animated:YES];
        return;
#endif
#endif
        
    }else if (button.tag == 3) {
        //视频会议
        //        [GKMessageTool showText:@"暂未开通，敬请期待"];
        //        return;
        //#ifdef Meeting_Version
        
        if(g_xmpp.isLogined != 1){
            [g_xmpp showXmppOfflineAlert];
            return;
        }
        
        NSString *str1;
        NSString *str2;

        str1 = Localized(@"WaHu_JXSetting_WaHuVC_VideoMeeting");

        str2 = Localized(@"JX_Meeting");
        
        WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[@"meeting_tel",@"meeting_video"] names:@[str2,str1]];
        actionVC.delegate = self;
        [self presentViewController:actionVC animated:NO completion:nil];
        //#endif
    }else if (button.tag == 4) {
        //视频直播
        //        NSLog(@"视频直播");
        //        [GKMessageTool showText:@"暂未开通，敬请期待"];
        //        return;
        //#ifdef Live_Version
        
        WH_JXLive_WHViewController *vc = [[WH_JXLive_WHViewController alloc] init];
        [g_navigation pushViewController:vc animated:YES];
        //#endif
    }
    
    if (g_config.isOpenPositionService) {
        if (button.tag == 5) {
            //附近的人
            NSLog(@"附近的人");
            
            //        [JXMyTools showTipView:@"暂未开通，敬请期待"];
            //        [GKMessageTool showText:@"暂未开通，敬请期待"];
            //        return;
            
            WH_JXNear_WHVC * nearVc = [[WH_JXNear_WHVC alloc] init];
            [g_navigation pushViewController:nearVc animated:YES];
            
        }if (button.tag == 6) {
            //公众号
//            [GKMessageTool showText:@"暂未开通，敬请期待"];
            WH_JXPublicNumber_WHVC *publicVC = [WH_JXPublicNumber_WHVC new];
            [g_navigation pushViewController:publicVC animated:YES];
            return;
        }else if (button.tag == 7) {
            //签到红包
            WH_Signature_WHViewController *signatureVC = [[WH_Signature_WHViewController alloc] initWithNibName:@"WH_Signature_WHViewController" bundle:nil];
            [g_navigation pushViewController:signatureVC animated:YES];
        }
    }else{
        if (button.tag == 5) {
            //附近的人
            NSLog(@"附近的人");
            
            //        [JXMyTools showTipView:@"暂未开通，敬请期待"];
            //        [GKMessageTool showText:@"暂未开通，敬请期待"];
            //        return;
            
            WH_JXNear_WHVC * nearVc = [[WH_JXNear_WHVC alloc] init];
            [g_navigation pushViewController:nearVc animated:YES];
            
        }else if (button.tag == 6) {
            //公众号
//            [GKMessageTool showText:@"暂未开通，敬请期待"];
            WH_JXPublicNumber_WHVC *publicVC = [WH_JXPublicNumber_WHVC new];
            [g_navigation pushViewController:publicVC animated:YES];
            return;
        }else if (button.tag == 7) {
            //签到红包
            WH_Signature_WHViewController *signatureVC = [[WH_Signature_WHViewController alloc] initWithNibName:@"WH_Signature_WHViewController" bundle:nil];
            [g_navigation pushViewController:signatureVC animated:YES];
        }
    }
    

}

#ifdef Meeting_Version
- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        [self onGroupAudioMeeting:nil];
    }else if(index == 1){
        [self onGroupVideoMeeting:nil];
    }
}

-(void)onGroupAudioMeeting:(WH_JXMessageObject*)msg{
    self.wh_isAudioMeeting = YES;
    [self onInvite];
}

-(void)onGroupVideoMeeting:(WH_JXMessageObject*)msg{
    self.wh_isAudioMeeting = NO;
    [self onInvite];
}

-(void)onInvite{
    NSMutableSet* p = [[NSMutableSet alloc]init];
    
    WH_JXSelectFriends_WHVC* vc = [WH_JXSelectFriends_WHVC alloc];
    vc.isNewRoom = NO;
    vc.isShowMySelf = NO;
    vc.type = JXSelectFriendTypeSelFriends;
    vc.existSet = p;
    vc.delegate = self;
    vc.didSelect = @selector(meetingAddMember:);
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void) remindNotif:(NSNotification *)notif {
    [self showNewMsgNoti];
    
}

-(void)meetingAddMember:(WH_JXSelectFriends_WHVC*)vc{
    int type;
    if (self.wh_isAudioMeeting) {
        type = kWCMessageTypeAudioMeetingInvite;
    }else {
        type = kWCMessageTypeVideoMeetingInvite;
    }
    for(NSNumber* n in vc.set){
        WH_JXUserObject *user;
        if (vc.seekTextField.text.length > 0) {
            user = vc.searchArray[[n intValue] % 1000];
        }else{
            user = [[vc.letterResultArr objectAtIndex:[n intValue] / 1000] objectAtIndex:[n intValue] % 1000];
        }
        NSString* s = [NSString stringWithFormat:@"%@",user.userId];
        [g_meeting sendMeetingInvite:s toUserName:user.userNickname roomJid:MY_USER_ID callId:nil type:type];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (g_meeting.isMeeting) {
            return;
        }
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        avVC.roomNum = MY_USER_ID;
        avVC.isAudio = self.wh_isAudioMeeting;
        avVC.isGroup = YES;
        avVC.toUserName = MY_USER_NAME;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        
    });
}
#endif

- (void)createCellContentWithSupView:(id)supView imageName:(NSString *)imgName labelText:(NSString *)lText isLinkUrl:(Boolean)linkUrl buttonTag:(NSInteger)tag{
    //图标
    UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, (55 - 20)/2, 20, 20)];
    if (linkUrl) {
        NSString *placeholderImgName = @"";
        if (tag == 1) {
            placeholderImgName = @"WH_ShengHuoQuan";
        }else if (tag == 2) {
            placeholderImgName = @"WH_DuanShiPin";
        }else if (tag == 3) {
            placeholderImgName = @"WH_ShiPinHuiYi";
        }else if (tag == 4) {
            placeholderImgName = @"WH_ShiPinZhiBo";
        }else if (tag == 5) {
            placeholderImgName = @"WH_FuJinDeRen_FaXian";
        }else if (tag == 6) {
            placeholderImgName = @"WH_GongZhongHao";
        }else if (tag == 7) {
            placeholderImgName = @"WH_QianDaoHongBao";
        }
        [iconImg sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:placeholderImgName]];
    }else{
        NSString *placeholderImgName = imgName;
        if (tag == 1) {
            placeholderImgName = @"WH_ShengHuoQuan";
        }else if (tag == 2) {
            placeholderImgName = @"WH_DuanShiPin";
        }else if (tag == 3) {
            placeholderImgName = @"WH_ShiPinHuiYi";
        }else if (tag == 4) {
            placeholderImgName = @"WH_ShiPinZhiBo";
        }else if (tag == 5) {
            placeholderImgName = @"WH_FuJinDeRen_FaXian";
        }else if (tag == 6) {
            placeholderImgName = @"WH_GongZhongHao";
        }else if (tag == 7) {
            placeholderImgName = @"WH_QianDaoHongBao";
        }
        
        [iconImg setImage:[UIImage imageNamed:placeholderImgName]];
    }
    
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

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if([aDownload.action isEqualToString:wh_act_CustomMenu] ){

        [self.wh_cMenuArray removeAllObjects];
        [self.wh_dataArray removeAllObjects];
        
        if (array1.count > 0) {
            
            NSArray *pArray ;
            NSMutableArray *videoArray = [[NSMutableArray alloc] init];
            NSArray *nearArray ;
            NSArray *gArray ;
            NSArray *readArray;
            
            for (int i = 0; i < array1.count; i++) {
                
                
                NSDictionary *data = [array1 objectAtIndex:i];
                NSInteger type = [[data objectForKey:@"discoverNum"] integerValue];
                if (type == 1) {
                    //朋友圈
                    pArray = @[data];
                }else if (type == 2) {
                    //短视频
                    [videoArray addObject:data];
                }else if (type == 3) {
                    //视频会议
                    [videoArray addObject:data];
                }else if (type == 4) {
                    //视频直播
                    [videoArray addObject:data];
                }else if (type == 5) {
                    //附近的人
                    nearArray = @[data];
                }else if (type == 6) {
                    //公众号
                    gArray = @[data];
                }else if (type == 7){
                    //签到红包
                    readArray = @[data];
                } else{
                    //自定义列表
                    [self.wh_cMenuArray addObject:data];
                }
            }
            
            if (pArray.count > 0) {
                [self.wh_dataArray addObject:pArray];
            }
            if (videoArray.count > 0) {
                [self.wh_dataArray addObject:videoArray];
            }
            if (nearArray.count > 0) {
                [self.wh_dataArray addObject:nearArray];
            }
            if (gArray.count > 0) {
                [self.wh_dataArray addObject:gArray];
            }
            if (readArray.count > 0) {
                [self.wh_dataArray addObject:readArray];
            }
        }
        
        [self.wh_tableView reloadData];
    }
    if( [aDownload.action isEqualToString:wh_act_CircleMsgPureVideo] ){
//        [self stopLoading];
        
//        if (_page == 0) {
//            [_smallVideos removeAllObjects];
//        }
        
//        _isLoading = NO;
//        NSMutableArray *arr = [[NSMutableArray alloc] init];
        _smallVideos = [NSMutableArray array];
        for (int i = 0; i < array1.count; i++) {
            WH_GKDYVideoModel *model = [[WH_GKDYVideoModel alloc] init];
            [model WH_getDataFromDict:array1[i]];
            [_smallVideos addObject:model];
        }
//        [_array addObjectsFromArray:arr];
//        [self.collectionView reloadData];
        
//        _page++;
    }
}

#pragma mark - 请求失败回调
- (int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    
    return WH_hide_error;
}


- (void)sp_getUsersMostLikedSuccess {
    NSLog(@"Get Info Success");
}
@end
