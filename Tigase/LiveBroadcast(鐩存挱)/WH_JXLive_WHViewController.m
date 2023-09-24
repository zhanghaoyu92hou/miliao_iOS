#define SERVER_URL @"rtmp://live.hkstv.hk.lxdns.com:1935/live/100044761484736059"
//#define SERVER_URL @"rtmp://ams.studytv.cn/live/aaa"
//#define SERVER_URL @"http://pull99.a8.com/live/1484986711488827.flv?ikHost=ws&ikOp=1&CodecInfo=8192"

//
//  WH_JXLive_WHViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "WH_JXLive_WHViewController.h"
#import "WH_JXPlayer_WHViewController.h"
#import "WH_AnchorMXViewController.h"

#import "WH_JXRoomPool.h"
#import "WH_JXRoomMember_WHVC.h"
#import "WH_JXRoomObject.h"
#import "WH_RoomData.h"

#import "WH_JXNewRoom_WHVC.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXRoomRemind.h"
#import "WH_JXLive_WHCell.h"
#import "MJRefresh.h"
#import "WH_CreateLiveRoomMXVC.h"
#import "WH_JXTopSiftJobView.h"

@interface WH_JXLive_WHViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate,JXCreateLiveRoomDelegate>
{
    
    WH_JXCollectionView *_collectionView;
    MJRefreshHeaderView *_refreshHeader;
    MJRefreshFooterView *_refreshFooter;
    
    int _page;
    BOOL _isLoading;
    BOOL _selected; //cell点击延时,防止多次快速点击
    
    UILongPressGestureRecognizer * _longPress;
    NSIndexPath * _selectIndexPath;
    
    WH_RoomData* _room;
}
@property (nonatomic, strong) NSDictionary * myLiveDict;
@property (nonatomic, strong) WH_JXTopSiftJobView *topSiftView;

@end

@implementation WH_JXLive_WHViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = Localized(@"JXLiveVC_Live");
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        [self createHeadAndFoot];
//        CGRect frame = self.wh_tableBody.frame;
//        frame.origin.y += 40;
//        frame.size.height -= 40;
//        self.wh_tableBody.frame = frame;
        
        UIButton* btn = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal"
                                               highlight:nil
                                                  target:self
                                                selector:@selector(onNewRoom)];
        
        btn.frame = CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 24, JX_SCREEN_TOP - 34, 24, 24);
        [self.wh_tableHeader addSubview:btn];
        
//        [self.view addSubview:self.topSiftView];
        
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[WH_JXCollectionView alloc] initWithFrame:self.wh_tableBody.frame collectionViewLayout:layout];
        _collectionView.backgroundColor = THEMEBACKCOLOR;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[WH_JXLive_WHCell class] forCellWithReuseIdentifier:NSStringFromClass([WH_JXLive_WHCell class])];
        
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
        [_collectionView addGestureRecognizer:_longPress];
        
        [self.view addSubview:_collectionView];
        _refreshHeader = [MJRefreshHeaderView header];
        _refreshFooter = [MJRefreshFooterView footer];
        [self addRefreshViewWith:_collectionView header:_refreshHeader footer:_refreshFooter];
        
        
        _wh_allArray = [NSMutableArray array];
        _wh_livingArray = [NSMutableArray array];
        _page=0;
        _isLoading=0;
        _selMenu = 1;
        //        [self WH_scrollToPageUp];
        [self WH_getServerData];
        [g_notify addObserver:self selector:@selector(WH_getServerData) name:kLiveListRefresh_WHNotification object:nil];
    }
    return self;
}

-(WH_JXTopSiftJobView *)topSiftView{
    if (!_topSiftView) {
        _topSiftView = [[WH_JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 40)];
        _topSiftView.wh_delegate = self;
        _topSiftView.wh_isShowMoreParaBtn = NO;
        _topSiftView.wh_dataArray = [[NSArray alloc] initWithObjects:Localized(@"JXLive_allLive"),Localized(@"JXLive_living"), nil];
    }
    return _topSiftView;
}
- (void)lonePressMoving:    (UILongPressGestureRecognizer *)longPress
{
    switch (_longPress.state) {
        case UIGestureRecognizerStateBegan: {
            {
                _selectIndexPath = [_collectionView indexPathForItemAtPoint:[_longPress locationInView:_collectionView]];
                
                // 找到当前的cell
                WH_JXLive_WHCell *cell = (WH_JXLive_WHCell *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
                // 定义cell的时候btn是隐藏的, 在这里设置为NO
                [cell.wh_btnDelete setHidden:NO];
                
                cell.wh_btnDelete.tag = _selectIndexPath.item;
                
                //添加删除的点击事件
                [cell.wh_btnDelete addTarget:self action:@selector(wh_btnDelete:) forControlEvents:UIControlEventTouchUpInside];
                
                [_collectionView beginInteractiveMovementForItemAtIndexPath:_selectIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [_collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:_longPress.view]];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_collectionView endInteractiveMovement];
            break;
        }
        default: {
            [_collectionView cancelInteractiveMovement];
            break;
        }
    }
}

- (void)btnDelete:(UIButton *)btn{
    NSMutableArray * array;
    if (_selMenu == 0) {
        array = _wh_allArray;
    }else{
        array = _wh_livingArray;
    }
    
    NSDictionary *dict = array[_selectIndexPath.row];
    if (![[NSString stringWithFormat:@"%@",dict[@"userId"]] isEqualToString:g_myself.userId]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_Tip") message:Localized(@"JXLiveVC_NotRoomOwner") delegate:self cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JXLiveVC_StillDelete"), nil];
        [alert show];
    }else{
        NSString* roomId = [dict objectForKey:@"roomId"];
        [g_server deleteLiveRoom:roomId toView:self];
        WH_JXLive_WHCell *cell = (WH_JXLive_WHCell *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        cell.wh_btnDelete.hidden = NO;
        
        [array removeObjectAtIndex:_selectIndexPath.row];
        [_collectionView reloadData];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1221) {
        if (buttonIndex == 1) {
            
            [g_server liveRoomStatus:1 roomId:[_myLiveDict objectForKey:@"roomId"] toView:self];
            
        }
        
    }else{
        NSMutableArray * array;
        if (_selMenu == 0) {
            array = _wh_allArray;
        }else{
            array = _wh_livingArray;
        }
        NSDictionary *dict = array[_selectIndexPath.row];
        WH_JXLive_WHCell *cell = (WH_JXLive_WHCell *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        if (buttonIndex == 0) {
            cell.wh_btnDelete.hidden = YES;
        }else if (buttonIndex == 1){
            
            NSString* roomId = [dict objectForKey:@"roomId"];
            [g_server deleteLiveRoom:roomId toView:self];
            
            cell.wh_btnDelete.hidden = NO;
            
            [array removeObjectAtIndex:_selectIndexPath.row];
            [_collectionView reloadData];
        }
    }
}

//添加刷新控件
- (void)addRefreshViewWith:(UICollectionView *)collectionView header:(MJRefreshHeaderView *)header footer:(MJRefreshFooterView *)footer{
    header.scrollView = collectionView;
    footer.scrollView = collectionView;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [self WH_scrollToPageUp];
//        [self WH_getServerData];
    };
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        //        [self WH_scrollToPageDown];
        _page++;
        [self WH_getServerData];
    };
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc {
    //    [_array release];
    //    [super dealloc];
    [g_notify removeObserver:self];
    [g_notify removeObserver:self name:kLiveListRefresh_WHNotification object:nil];
}

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [_scrollView setContentOffset:CGPointMake(JX_SCREEN_WIDTH, 0) animated:NO];
//    
//}

#pragma mark UICollectionView delegate
#pragma mark-----多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma mark-----多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSMutableArray * array;
    if (_selMenu == 0) {
        array = _wh_allArray;
    }else{
        array = _wh_livingArray;
    }
    _recordCount = array.count;
    return array.count;
}
#pragma mark-----每一个的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    return CGSizeMake((JX_SCREEN_WIDTH - 30)/2, (JX_SCREEN_WIDTH - 30)/2 + 50);
    return CGSizeMake(JX_SCREEN_WIDTH, (JX_SCREEN_WIDTH)/2 + 60);
}
#pragma mark-----每一个边缘留白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
#pragma mark-----最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma mark-----最小竖间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma mark-----返回每个单元格是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didUnhighlightItemAtIndexPath");
    WH_JXLive_WHCell *cell = (WH_JXLive_WHCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    //    NSLog(@"didHighlightItemAtIndexPath");
    WH_JXLive_WHCell *cell = (WH_JXLive_WHCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


#pragma mark-----创建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray * array;
    if (_selMenu == 0) {
        array = _wh_allArray;
    }else{
        array = _wh_livingArray;
    }
    
    WH_JXLive_WHCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WH_JXLive_WHCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.delegate = self;
    cell.didTouch = @selector(WH_on_WHHeadImage:);
    if (array.count)
        [cell doRefreshNearExpert:[array objectAtIndex:indexPath.row]];
    
    
    return cell;
}
#pragma mark-----点击单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    [self stopAllPlayer];
    NSMutableArray * array;
    if (_selMenu == 0) {
        array = _wh_allArray;
    }else{
        array = _wh_livingArray;
    }
    
    if (_selected == false) {   //防多次快速点击cell
        _selected = true;
        //点击过一次之后。5秒再让cell点击可以响应
        [self performSelector:@selector(changeDidSelect) withObject:nil afterDelay:0.5];
        
        _sel = indexPath.row;
        _myLiveDict = array[indexPath.row];
        if ([[_myLiveDict objectForKey:@"currentState"] integerValue] == 1) {
            [g_App showAlert:Localized(@"JX_TheStudioHasBeenDisabled")];
            return;
        }
        [_wait start:Localized(@"JXAlert_AddLiveRoomIng") delay:30];
        NSDictionary *dict = array[indexPath.row];

        _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[_myLiveDict objectForKey:@"jid"] title:[_myLiveDict objectForKey:@"name"] isNew:YES];
        _chatRoom.delegate = self;
        [_chatRoom joinRoom:YES];
        
        [self performSelector:@selector(enterMyLiveRoom) withObject:nil afterDelay:0.6];
//        NSString* roomId = [dict objectForKey:@"roomId"];
//        [g_server enterLiveRoom:roomId toView:self];
        dict = nil;
    }
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    NSMutableArray * array;
    if (_selMenu == 0) {
        array = _wh_allArray;
    }else{
        array = _wh_livingArray;
    }
    
    //    [self stopLoading];
    [_refreshHeader endRefreshing];
    [_refreshFooter endRefreshing];
    
    if([aDownload.action isEqualToString:act_liveRoomList]){
        //        self.isShowFooterPull = [array1 count]>=WH_page_size;
        if(_page == 0){
            [array removeAllObjects];
            [array addObjectsFromArray:array1];
        }else{
            if([array1 count]>0)
                [array addObjectsFromArray:array1];
        }
        _refreshFooter.hidden = array1.count < 10;
        _refreshCount++;
        [_collectionView reloadData];
    }else if( [aDownload.action isEqualToString:wh_act_UserGet] ){
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_fromAddType = 6;
        vc.wh_user       = user;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }else if( [aDownload.action isEqualToString:act_liveRoomCreate]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enterLiveRoom:dict];
            NSLog(@"推流：%@",[dict objectForKey:@"url"]);
        });
    }else if( [aDownload.action isEqualToString:act_liveRoomEnter]){
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSDictionary* roomDict = [array objectAtIndex:_sel];
            NSDictionary* roomDict = _myLiveDict;
            [self enterLiveRoom:roomDict];
            NSLog(@"拉流：%@",[roomDict objectForKey:@"url"]);
        });
    }else if( [aDownload.action isEqualToString:act_liveRoomDelete]){
        [g_server showMsg:Localized(@"JXAlert_DeleteOK")];
    }else if( [aDownload.action isEqualToString:act_liveRoomQuit]){
        [g_server showMsg:Localized(@"JXAlert_OutOK")];
    }
    
    if ([aDownload.action isEqualToString:act_liveRoomGetLiveRoom]) {
        
        if ([dict objectForKey:@"roomId"]) {
            
            if ([[dict objectForKey:@"currentState"] integerValue] == 1) {
                [_wait hide];
                [g_App showAlert:@"直播间已被禁用"];
                return;
            }
            
            _myLiveDict = [dict mutableCopy];
            [g_App showAlert:Localized(@"JXLive_createexistRoom") delegate:self tag:1221 onlyConfirm:NO];
        }else {
            WH_CreateLiveRoomMXVC * createVC = [[WH_CreateLiveRoomMXVC alloc] init];
            createVC.wh_userId = g_myself.userId;
            createVC.delegate = self;
            //    [g_window addSubview:createVC.view];
            [g_navigation pushViewController:createVC animated:YES];
        }
    }
    
    if ([aDownload.action isEqualToString:act_liveRoomStart]) {
        _chatRoom = [[JXXMPP sharedInstance].roomPool joinRoom:[_myLiveDict objectForKey:@"jid"] title:[_myLiveDict objectForKey:@"name"] isNew:YES];
        _chatRoom.delegate = self;
        [_chatRoom joinRoom:YES];
        
        [self performSelector:@selector(enterMyLiveRoom) withObject:nil afterDelay:0.5];
    }
    [_wait hide];
}
-(void)enterLiveRoom:(NSDictionary *)dataDict{
    WH_JXLiveRoom_WHViewController * liveVC;
    if ([[dataDict objectForKey:@"userId"] integerValue] == [g_myself.userId integerValue]) {
        liveVC = [[WH_AnchorMXViewController alloc] init];
    }else{
        liveVC = [[WH_JXPlayer_WHViewController alloc] init];
    }
    liveVC.wh_liveUrl = [dataDict objectForKey:@"url"];//房间地址;
    liveVC.userId  = [dataDict objectForKey:@"userId"];
    liveVC.name = dataDict[@"name"];
    liveVC.nickName = dataDict[@"nickName"];
    liveVC.notice = dataDict[@"notice"];
    liveVC.wh_jid = dataDict[@"jid"];
    liveVC.wh_liveRoomId = dataDict[@"roomId"];
    liveVC.count = [dataDict[@"numbers"] longValue];
//    [g_App.window addSubview:liveVC.view];
    [g_navigation pushViewController:liveVC animated:YES];
    
}
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    [_refreshHeader endRefreshing];
    [_refreshFooter endRefreshing];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [_refreshHeader endRefreshing];
    [_refreshFooter endRefreshing];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

-(void)WH_getServerData{
    if (_selMenu == 0) {
        [g_server listLiveRoom:_page status:0 toView:self];
    }else{
        [g_server listLiveRoom:_page status:1 toView:self];
    }
}

-(void)changeDidSelect{
    _selected = false;
}

-(void)WH_on_WHHeadImage:(WH_JXImageView*)sender{
    NSMutableArray * array;
    if (_selMenu == 0) {
        array = _wh_allArray;
    }else{
        array = _wh_livingArray;
    }
    NSDictionary *dict = array[sender.tag];
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = [[dict objectForKey:@"userId"] stringValue];
    vc.wh_fromAddType = 6;
    vc = [vc init];
    //        [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
//    [g_server getUser:[[dict objectForKey:@"userId"] stringValue] toView:self];
    dict = nil;
}

-(BOOL)hasExistingLiveRoom:(NSDictionary **)myLiveDict{
    NSMutableArray * array;
    if (_selMenu == 0) {
        array = _wh_allArray;
    }else{
        array = _wh_livingArray;
    }
    
    for (NSDictionary * liveDict in array) {
        if ([liveDict[@"userId"] integerValue] == [g_myself.userId integerValue]) {
            *myLiveDict = liveDict;
            return YES;
        }
    }
    return NO;
}
-(void)enterMyLiveRoom{
    [_wait start:Localized(@"JXAlert_AddLiveRoomIng") delay:30];
    
    NSString* roomId = [_myLiveDict objectForKey:@"roomId"];
    [g_server enterLiveRoom:roomId toView:self];
}

-(void)onNewRoom{
    
    [g_server liveRoomGetLiveRoom:[g_myself.userId integerValue] toView:self];
//    return;
//
//    NSMutableArray * array;
//    if (_selMenu == 0) {
//        array = _allArray;
//    }else{
//        array = _livingArray;
//    }
//
//    NSDictionary * dict = nil;
//    if([self hasExistingLiveRoom:&dict]){
//        _sel = [array indexOfObject:dict];
//        _myLiveDict = [dict mutableCopy];
//        [g_App showAlert:Localized(@"JXLive_createexistRoom") delegate:self tag:1221 onlyConfirm:NO];
//        return;
//    }
//
//    _myLiveDict= nil;
//
//    WH_CreateLiveRoomMXVC * createVC = [[WH_CreateLiveRoomMXVC alloc] init];
//    createVC.userId = g_myself.userId;
//    createVC.delegate = self;
////    [g_window addSubview:createVC.view];
//    [g_navigation pushViewController:createVC animated:YES];
}

-(void)createLiveRoomDelegate:(NSString *)name notice:(NSString *)notice{
    [self createRoom:name desc:notice];
}

//-(void)onSaveRoomName:(WH_JXInputValue_WHVC*)vc{
//    [self createRoom:vc.value];
//   
//}

-(void)createRoom:(NSString *)roomName desc:(NSString *)desc{
    NSString* jidStr = [XMPPStream generateUUID];
    jidStr = [[jidStr stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    _room = [[WH_RoomData alloc] init];
    _room.roomJid= jidStr;
    _room.name   = roomName;
    _room.desc   = desc;
    _room.userId = [g_myself.userId longLongValue];
    _room.userNickName = g_myself.userNickname;
    
    _chatRoom = [[JXXMPP sharedInstance].roomPool createRoom:jidStr title:roomName];
    _chatRoom.delegate = self;
    
    [_wait start:Localized(@"JXAlert_CreatRoomIng") delay:30];
    
    [g_server createLiveRoom:MY_USER_ID nickName:g_myself.userNickname roomName:_room.name notice:_room.desc jid:_room.roomJid toView:self];
}

-(void)xmppRoomDidCreate:(XMPPRoom *)sender{
//    [g_server createLiveRoom:MY_USER_ID nickName:g_myself.userNickname roomName:_room.name notice:_room.desc jid:_room.roomJid toView:self];
//    _chatRoom.delegate = nil;
}

- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
    [_topSiftView WH_resetAllParaBtn];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    if (offsetX == 0) {
        _selMenu = 0;
        if (_wh_allArray.count <= 0) {
            [self WH_scrollToPageUp];
        }else {
            [_collectionView reloadData];
        }
    }else {
        _selMenu = 1;
        if (_wh_livingArray.count <= 0) {
            [self WH_scrollToPageUp];
        }else {
            [_collectionView reloadData];
        }
    }
    
}
-(void)WH_scrollToPageUp{
//    if(_isLoading)
//        return;
    _page = 0;
    [self WH_getServerData];
//    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.0];
}

@end
