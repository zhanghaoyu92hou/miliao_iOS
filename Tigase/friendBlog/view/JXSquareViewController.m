//
//  JXSquareViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/11/7.
//  Copyright © 2018年 YZK. All rights reserved.
//



#import "JXSquareViewController.h"
#import "WH_WeiboViewControlle.h"
#import "WH_JXActionSheet_WHVC.h"
#ifdef Meeting_Version
#import "WH_JXSelectFriends_WHVC.h"
#import "JXAVCallViewController.h"
#endif

#ifdef Live_Version
#import "WH_JXLive_WHViewController.h"
#endif

#import "WH_JXScanQR_WHViewController.h"
#import "WH_JXNear_WHVC.h"
#import "JXBlogRemind.h"
#import "WH_JXTabMenuView.h"
#ifdef Meeting_Version
#ifdef Live_Version
#import "WH_GKDYHome_WHViewController.h"
#import "JXSmallVideoViewController.h"
#endif
#endif
#import "ImageResize.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JX_WHCell.h"

/*
 *   如果要改变左右间隔
 *   减少间隔，则增加 SQUARE_HEIGHT
 *   增加间隔，则减少 SQUARE_HEIGHT
 */
#define SQUARE_HEIGHT      38      //图片宽高
#define INSET_IMAGE       15        // 字和图片的间距


typedef NS_ENUM(NSInteger, JXSquareType) {
    JXSquareTypeLife,           // 生活圈
    JXSquareTypeVideo,          // 视频会议
    JXSquareTypeVideoLive,      // 视频直播
    JXSquareTypeShortVideo,     // 短视频
    JXSquareTypeQrcode,         // 扫一扫
    JXSquareTypeNearby,         // 附近的人
};
@interface JXSquareViewController () <WH_JXActionSheet_WHVCDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *iconArr;
@property (nonatomic, assign) JXSquareType type;
@property (nonatomic, assign) BOOL isAudioMeeting;
@property (nonatomic, strong) UILabel *weiboNewMsgNum;
@property (nonatomic, strong) NSMutableArray *remindArray;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UIImageView *topImageView;

@property (nonatomic, strong) NSMutableArray *subviews;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger page;
@property(nonatomic,strong) MJRefreshFooterView *footer;
@property(nonatomic,strong) MJRefreshHeaderView *header;

@end

@implementation JXSquareViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = Localized(@"WaHu_JXMain_WaHuViewController_Find");
        _array = [NSMutableArray array];
        self.wh_heightFooter = 0;
        self.wh_heightHeader = JX_SCREEN_TOP;
        [self createHeadAndFoot];
//        self.wh_tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
        self.wh_tableBody.backgroundColor = HEXCOLOR(0xffffff);
        
        self.subviews = [[NSMutableArray alloc] init];
        
        [self WH_setupViews];
        [g_notify addObserver:self selector:@selector(remindNotif:) name:kXMPPMessageWeiboRemind_WHNotification object:nil];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self WH_getServerData];
}

- (void)WH_getServerData {
    [g_server WH_searchPublicWithKeyWorld:@"" limit:20 page:(int)_page toView:self];
}


-(void)dealloc{
    [g_notify removeObserver:self name:kXMPPMessageWeiboRemind_WHNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self WH_showNewMsgNoti];
}

- (void)WH_showNewMsgNoti {
    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
    
    NSString *newMsgNum = [NSString stringWithFormat:@"%ld",_remindArray.count];
    if (_remindArray.count >= 10 && _remindArray.count <= 99) {
        self.weiboNewMsgNum.font = sysFontWithSize(12);
    }else if (_remindArray.count > 0 && _remindArray.count < 10) {
        self.weiboNewMsgNum.font = sysFontWithSize(13);
    }else if(_remindArray.count > 99){
        self.weiboNewMsgNum.font = sysFontWithSize(9);
    }

    self.weiboNewMsgNum.text = newMsgNum;
    [g_mainVC.tb wh_setBadge:g_mainVC.tb.wh_items.count == 5 ? 3 : 2 title:newMsgNum];
    self.weiboNewMsgNum.hidden = _remindArray.count <= 0;
}


- (void)WH_setupViews {
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - JX_SCREEN_BOTTOM - JX_SCREEN_TOP)];
    baseView.backgroundColor = [UIColor whiteColor];
    [self.wh_tableBody addSubview:baseView];
    //顶部图片
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(baseView.frame), (220*CGRectGetWidth(baseView.frame))/375)];
    [baseView addSubview:_topImageView];
    CGFloat fl = (_topImageView.frame.size.width/_topImageView.frame.size.height);
    [_topImageView sd_setImageWithURL:[NSURL URLWithString:g_config.headBackgroundImg] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            image = [UIImage imageNamed:@"Default_Gray"];
        }
        _topImageView.image = [ImageResize image:image fillSize:CGSizeMake((_topImageView.frame.size.height+200)*fl, _topImageView.frame.size.height+200)];
    }];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(13, (CGRectGetHeight(_topImageView.frame) + _topImageView.frame.origin.y) - 30 , CGRectGetWidth(baseView.frame) - 26, 207)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [baseView addSubview:contentView];
    contentView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.14].CGColor;
    contentView.layer.shadowOffset = CGSizeMake(0,1);
    contentView.layer.shadowOpacity = 1;
    contentView.layer.shadowRadius = 6;
    contentView.layer.cornerRadius = 10;
    
    //发现内容
    [self createContentWithView:contentView];
    
    //底部提示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(baseView.frame) - 30, CGRectGetWidth(baseView.frame), 10)];
    [label setTextAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"更多功能应用敬请期待!" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang-SC-Regular" size: 9],NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];
    label.attributedText = string;
    [baseView addSubview:label];
}

- (void)createContentWithView:(UIView *)view {
    CGFloat pic_width = CGRectGetWidth(view.frame)/3;
    NSInteger pic_height = 65;
    
    
    NSArray *pictures = @[@[ThemeImage(@"pengyouquan") ,ThemeImage(@"shipinhuiyi") ,ThemeImage(@"shipinzhibo")] ,@[ThemeImage(@"duanshipin") ,ThemeImage(@"fujinderen") ,ThemeImage(@"gengduo")]];
    NSArray *titleArray = @[@[Localized(@"JX_LifeCircle") ,Localized(@"WaHu_JXSetting_WaHuVC_VideoMeeting") ,Localized(@"JX_LiveVideo")] ,@[Localized(@"JX_ShorVideo") ,Localized(@"WaHu_JXNear_WaHuVC_NearPer") ,@"更多"]];
    
    for (int i = 0; i < pictures.count; i++) {
        NSArray *imageArray = [pictures objectAtIndex:i];
        NSArray *tArray = [titleArray objectAtIndex:i];
        for (int j = 0; j < imageArray.count; j++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(j*(pic_width), ((CGRectGetHeight(view.frame) - (pic_height*2))/3) + ((CGRectGetHeight(view.frame) - (pic_height*2))/3)*i + i*65, pic_width, pic_height)];
//            btn setTag:()
            [view addSubview:btn];
            
            CGFloat imageWith = 0;
            CGFloat imageHieht = 40;
            NSInteger btnTag = 0;
            if (i == 0) {
                if (j == 0) {
                    imageWith = 40;
                    btnTag = 0;
                }else if (j == 1) {
                    imageWith = (83*40)/76 ;
                    btnTag = 1;
                }else if (j == 2) {
                    imageWith = (95*40)/74 ;
                    btnTag = 2;
                }
            }else{
                if (j == 0) {
                    imageWith = 50;
                    imageHieht = 50;
                    btnTag = 3;
                }else if (j == 1) {
                    imageWith = (62*40)/85 ;
                    btnTag = 4;
                }else if (j == 2) {
                    imageWith = (89*40)/87 ;
                    btnTag = 5;
                }
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((pic_width - imageWith)/2, 0, imageWith, imageHieht)];
            [imgView setImage:[imageArray objectAtIndex:j]];
            [btn addSubview:imgView];
            
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(btn.frame) - 15, CGRectGetWidth(btn.frame), 15)];
            [title setText:[tArray objectAtIndex:j]];
            [title setFont:[UIFont systemFontOfSize:12]];
            [title setTextColor:HEXCOLOR(0x666666)];
            [title setTextAlignment:NSTextAlignmentCenter];
            [btn addSubview:title];
            
            [btn setTag:btnTag];
            [btn addTarget:self action:@selector(clickButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
}

- (void)stopLoading {
    
    [_footer endRefreshing];
    [_header endRefreshing];
}
- (void)addFooter
{
    if(_footer){
        //        [_footer free];
        //        return;
    }
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = _tableView;
    __weak JXSquareViewController *weakSelf = self;
    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        [weakSelf WH_scrollToPageDown];
        //        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
        // 刷新完毕就会回调这个Block
        //        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    _footer.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
}

- (void)addHeader
{
    if(_header){
        //        [_header free];
        //        return;
    }
    _header = [MJRefreshHeaderView header];
    _header.scrollView = _tableView;
    __weak JXSquareViewController *weakSelf = self;
    _header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        [weakSelf WH_scrollToPageUp];
    };
    _header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    _header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
}

//顶部刷新获取数据
-(void)WH_scrollToPageUp{
    
    _page = 0;
    [self WH_getServerData];
}

-(void)WH_scrollToPageDown{
    
    [self WH_getServerData];
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_array.count == 1) {
        return 100;
    }
    return 54;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"WH_JX_WHCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    WH_JXUserObject *user = _array[indexPath.row];
    if (_array.count == 1) {
        if ([cell isKindOfClass:[WH_JX_WHCell class]]) {
            cell = nil;
        }
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.imageView.frame = CGRectMake(0.0, 0.0, SQUARE_HEIGHT, SQUARE_HEIGHT);
//        [cell.imageView setBackgroundColor:[UIColor brownColor]];
        [cell.imageView headRadiusWithAngle:SQUARE_HEIGHT/2];
        [g_server WH_getHeadImageSmallWIthUserId:user.userId userName:user.userNickname imageView:cell.imageView];
        cell.textLabel.text = user.userNickname;
    }else {
        WH_JX_WHCell *cell=nil;
        if(cell==nil){
            cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.title = user.userNickname;
        cell.index = (int)indexPath.row;
        cell.userId = user.userId;
        [cell.lbTitle setText:cell.title];
        cell.isSmall = YES;
        [cell WH_headImageViewImageWithUserId:nil roomId:nil];
        return cell;

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WH_JXUserObject *user = _array[indexPath.row];
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    
    sendView.scrollLine = 0;
    sendView.title = user.userNickname;
    sendView.chatPerson = user;
    sendView = [sendView init];
    [g_navigation pushViewController:sendView animated:YES];


}

//服务端返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    if( [aDownload.action isEqualToString:wh_act_PublicSearch] ){
        [self stopLoading];
        
        if (array1.count < 20) {
            _footer.hidden = YES;
        }
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        if(_page == 0){
            [_array removeAllObjects];
            for (int i = 0; i < array1.count; i++) {
                WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
                [user WH_getDataFromDict:array1[i]];
                [arr addObject:user];
            }
            [_array addObjectsFromArray:arr];
        }else{
            if([array1 count]>0){
                for (int i = 0; i < array1.count; i++) {
                    WH_JXUserObject *user = [[WH_JXUserObject alloc] init];
                    [user WH_getDataFromDict:array1[i]];
                    [arr addObject:user];
                }
                [_array addObjectsFromArray:arr];
            }
        }
        _page ++;
        [_tableView reloadData];
        [self setTableviewHeight];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    [self stopLoading];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [self stopLoading];
    return WH_hide_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

- (void)setTableviewHeight {
    int height = _array.count <= 1 ? 100 : 54;
    CGRect frame = _tableView.frame;
    frame.size.height = height*_array.count;
    _tableView.frame = frame;
    
    self.wh_tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(_tableView.frame) + JX_SCREEN_BOTTOM+15);
}

#pragma mark 点击事件
- (void)clickButtonMethod:(UIButton *)btn {
    if (btn.tag == 0) {
        //朋友圈
        NSLog(@"朋友圈");
        WH_WeiboViewControlle *weiboVC = [WH_WeiboViewControlle alloc];
        weiboVC.user = g_myself;
        weiboVC = [weiboVC init];
        [g_navigation pushViewController:weiboVC animated:YES];
    }else if (btn.tag == 1) {
        //视频会议
        NSLog(@"视频会议");
        [GKMessageTool showText:@"功能开发中"];
        return;
#ifdef Meeting_Version
        
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
#endif
    }else if (btn.tag == 2) {
        //视频直播
        NSLog(@"视频直播");
        [GKMessageTool showText:@"功能开发中"];
        return;
#ifdef Live_Version
        
        WH_JXLive_WHViewController *vc = [[WH_JXLive_WHViewController alloc] init];
        [g_navigation pushViewController:vc animated:YES];
#endif
        
    }else if (btn.tag == 3) {
        //短视频
        NSLog(@"短视频");
        
#ifdef Meeting_Version
#ifdef Live_Version
        JXSmallVideoViewController *vc = [[JXSmallVideoViewController alloc] init];
        [g_navigation pushViewController:vc animated:YES];
        return;
        //            GKDYHomeViewController *vc = [[GKDYHomeViewController alloc] init];
        //            [g_navigation pushViewController:vc animated:NO];
        //            return;
#endif
#endif
        
    }else if (btn.tag == 4) {
        //附近的人
        NSLog(@"附近的人");
        
//        [JXMyTools showTipView:@"暂未开通，敬请期待"];
        [GKMessageTool showText:@"暂未开通，敬请期待"];
        return;
        
        WH_JXNear_WHVC * nearVc = [[WH_JXNear_WHVC alloc] init];
        [g_navigation pushViewController:nearVc animated:YES];
        
    }else if (btn.tag == 5) {
        //更多
        [GKMessageTool showText:@"暂未开通，敬请期待"];
        return;
    }
}

//- (void)clickButtonWithTag:(NSInteger)btnTag {
//    switch (btnTag) {
//        case JXSquareTypeLife:{// 生活圈
//            WeiboViewControlle *weiboVC = [WeiboViewControlle alloc];
//            weiboVC.user = g_myself;
//            weiboVC = [weiboVC init];
//            [g_navigation pushViewController:weiboVC animated:YES];
//        }
//            break;
//        case JXSquareTypeVideo:{// 视频会议
//#ifdef Meeting_Version
//
//            if(g_xmpp.isLogined != 1){
//                [g_xmpp showXmppOfflineAlert];
//                return;
//            }
//
//            NSString *str1;
//            NSString *str2;
//            str1 = Localized(@"WaHu_JXSetting_WHVC_VideoMeeting");
//            str2 = Localized(@"JX_Meeting");
//
//            WH_JXActionSheet_WHVC *actionVC = [[WH_JXActionSheet_WHVC alloc] initWithImages:@[@"meeting_tel",@"meeting_video"] names:@[str2,str1]];
//            actionVC.delegate = self;
//            [self presentViewController:actionVC animated:NO completion:nil];
//#endif
//        }
//            break;
//        case JXSquareTypeVideoLive:{ // 视频直播
//            [GKMessageTool showText:@"功能开发中"];
//            return;
//#ifdef Live_Version
//
//            WH_JXLive_WHViewController *vc = [[WH_JXLive_WHViewController alloc] init];
//            [g_navigation pushViewController:vc animated:YES];
//#endif
//        }
//            break;
//        case JXSquareTypeShortVideo:{// 短视频
//            [GKMessageTool showText:@"功能开发中"];
//            return;
//#ifdef Meeting_Version
//#ifdef Live_Version
//            JXSmallVideoViewController *vc = [[JXSmallVideoViewController alloc] init];
//            [g_navigation pushViewController:vc animated:YES];
//            return;
////            GKDYHomeViewController *vc = [[GKDYHomeViewController alloc] init];
////            [g_navigation pushViewController:vc animated:NO];
////            return;
//#endif
//#endif
//
//        }
//            break;
//        case JXSquareTypeQrcode:{// 扫一扫
//            AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//            if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
//            {
//                [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
//                return;
//            }
//
//            WH_JXScanQR_WHViewController * scanVC = [[WH_JXScanQR_WHViewController alloc] init];
//            [g_navigation pushViewController:scanVC animated:YES];
//        }
//            break;
//        case JXSquareTypeNearby:{// 附近的人
//            [JXMyTools showTipView:@"暂未开通，敬请期待"];
//            return;
//            WH_JXNear_WHVC * nearVc = [[WH_JXNear_WHVC alloc] init];
//            [g_navigation pushViewController:nearVc animated:YES];
//        }
//            break;
//
//        default:
//            break;
//    }
//
//}



#ifdef Meeting_Version

- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        [self onGroupAudioMeeting:nil];
    }else if(index == 1){
        [self onGroupVideoMeeting:nil];
    }
}

-(void)onGroupAudioMeeting:(WH_JXMessageObject*)msg{
    self.isAudioMeeting = YES;
    [self onInvite];
}

-(void)onGroupVideoMeeting:(WH_JXMessageObject*)msg{
    self.isAudioMeeting = NO;
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
//    WH_JXMessageObject *msg = notif.object;
//    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];
//    if (_remindArray.count > 0) {
//        NSString *newMsgNum = [NSString stringWithFormat:@"%ld",_remindArray.count];
//        self.weiboNewMsgNum.hidden = NO;
//        self.weiboNewMsgNum.text = newMsgNum;
//        [g_mainVC.tb setBadge:2 title:newMsgNum];
//    }
    [self WH_showNewMsgNoti];
    
}


-(void)meetingAddMember:(WH_JXSelectFriends_WHVC*)vc{
    int type;
    if (self.isAudioMeeting) {
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
        avVC.isAudio = self.isAudioMeeting;
        avVC.isGroup = YES;
        avVC.toUserName = MY_USER_NAME;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        [g_window addSubview:avVC.view];
        
    });
}
#endif


- (UIButton *)WH_create_WHButtonWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)iconName index:(NSInteger)index {
    UIButton *button = [[UIButton alloc] init];
    button.frame = frame;
    button.tag = index;
    [button addTarget:self action:@selector(WH_didButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(didButtonDown:) forControlEvents:UIControlEventTouchDown];

    //长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didButtonLong:)];
    longPress.minimumPressDuration = 0.1; //定义按的时间
    [button addGestureRecognizer:longPress];
 
    [_scrollView addSubview:button];
    
//    CGFloat X = frame.origin.x;
//    CGFloat Y = frame.origin.y;
    CGFloat inset =(JX_SCREEN_WIDTH-SQUARE_HEIGHT*5)/10;   // 间隔
//    CGFloat originY = Y > 0 ? 20+51- INSET_IMAGE  : 20+51;
    CGFloat originY = 15;
    _imgV = [[UIImageView alloc] init];
    _imgV.frame = CGRectMake(inset, originY, SQUARE_HEIGHT, SQUARE_HEIGHT);
//    [_imgV headRadiusWithAngle:_imgV.frame.size.width *0.5];
    _imgV.layer.cornerRadius = SQUARE_HEIGHT * 40 / 240;
    _imgV.layer.masksToBounds = YES;
//    [_imgV setBackgroundColor:[UIColor brownColor]];
    _imgV.image = [UIImage imageNamed:iconName];
    _imgV.tag = index;
    [button addSubview:_imgV];
    [_subviews addObject:_imgV];
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(15)} context:nil].size;
    UILabel *lab = [[UILabel alloc] init];
    lab.text = title;
    lab.textColor = HEXCOLOR(0x323232);
    lab.font = sysFontWithSize(15);
    lab.frame = CGRectMake(0, CGRectGetMaxY(_imgV.frame)+INSET_IMAGE, size.width, size.height);
    CGPoint center = lab.center;
    center.x = _imgV.center.x;
    lab.center = center;
    
    CGRect btnFrame = button.frame;
    btnFrame.size.height = originY+SQUARE_HEIGHT+size.height+INSET_IMAGE;
    button.frame = btnFrame;
    
    [button addSubview:lab];
    
    return button;
}

// 点击事件
//- (void)WH_didButton:(UIButton *)button {
//    [self clickButtonWithTag:button.tag];
//}

// 按下事件
- (void)didButtonDown:(UIButton *)button {
    for (UIView *sub in button.subviews) {
        if ([sub isKindOfClass:[UIImageView class]]) {
            sub.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
            [UIView animateWithDuration:.3f animations:^{
                sub.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
            }];
        }
    }
}

// 长按事件
- (void)didButtonLong:(UILongPressGestureRecognizer *)tap {
    UIView *view= tap.view;
//    UIImageView * moveShipImageView = (UIImageView *)[self.view viewWithTag:view.tag];
    UIView *subview;
    for (UIView *sub in view.subviews) {
        if ([sub isKindOfClass:[UIImageView class]]) {
            sub.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
            subview = sub;
        }
    }
    //(手势完成时)手指离开时
    if (tap.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:.3f animations:^{
            subview.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.f];
        } completion:^(BOOL finished) {
//            CGPoint curPoint = [tap locationInView:self.view];
//            if ([moveShipImageView.layer.presentationLayer hitTest:curPoint]) {
//                [self clickButtonWithTag:view.tag];
//            }else {
//
//            }
        }];
    }
}



@end
