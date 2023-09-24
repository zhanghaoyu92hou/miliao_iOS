//
//  WH_JXPublicNumber_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/6/4.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXPublicNumber_WHVC.h"
#import "WH_JX_WHCell.h"
#import "WH_JXChat_WHViewController.h"
#import "WH_JXSearchUser_WHVC.h"
#import "WH_JXTransferNotice_WHVC.h"

@interface WH_JXPublicNumber_WHVC ()
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation WH_JXPublicNumber_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack   = YES;
    self.wh_isShowHeaderPull = NO;
    self.wh_isShowFooterPull = NO;
    _array = [NSMutableArray array];
    self.title = Localized(@"JX_PublicNumber");
    [self WH_createHeadAndFoot];
    [self setupSearchPublicNumber];

    [self WH_getServerData];
}

- (void)setupSearchPublicNumber {
//    UIButton *moreBtn = [UIFactory WH_create_WHButtonWithImage:@"search_publicNumber"
//                                          highlight:nil
//                                             target:self
//                                           selector:@selector(searchPublicNumber)];
//    moreBtn.custom_acceptEventInterval = 1.0f;
//    moreBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 40, JX_SCREEN_TOP - 34, 24, 24);
//    [self.wh_tableHeader addSubview:moreBtn];
}


//- (void)searchPublicNumber {
//    WH_JXSearchUser_WHVC *searchUserVC = [WH_JXSearchUser_WHVC alloc];
//    searchUserVC.type = JXSearchTypePublicNumber;
//    searchUserVC = [searchUserVC init];
//    [g_navigation pushViewController:searchUserVC animated:YES];
//}

- (void)WH_getServerData {
    
    self.array = [[WH_JXUserObject sharedUserInstance] WH_fetchSystemUser];

    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXUserObject *user = _array[indexPath.row];
    
    
    
    WH_JX_WHCell *cell=nil;
    NSString* cellName = @"WH_JX_WHCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        
        cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        [_table WH_addToPool:cell];
        
    }
    
    cell.title = user.userNickname;
    
    cell.index = (int)indexPath.row;
    cell.delegate = self;
//    cell.didTouch = @selector(WH_on_WHHeadImage:);
    [cell setForTimeLabel:[TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"]];
    cell.timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 120-20, 9, 115, 20);
    cell.userId = user.userId;
    [cell.lbTitle setText:cell.title];
    
    cell.dataObj = user;
    //    cell.headImageView.tag = (int)indexPath.row;
    //    cell.headImageView.delegate = cell.delegate;
    //    cell.headImageView.didTouch = cell.didTouch;
    
    cell.isSmall = YES;
    [cell WH_headImageViewImageWithUserId:nil roomId:nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JX_WHCell* cell = (WH_JX_WHCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;
    WH_JXUserObject *user = _array[indexPath.row];
    
    if ([user.userId intValue] == [WAHU_TRANSFER intValue]) {
        WH_JXTransferNotice_WHVC *noticeVC = [[WH_JXTransferNotice_WHVC alloc] init];
        [g_navigation pushViewController:noticeVC animated:YES];
        return;
    }
    
    WH_JXChat_WHViewController *sendView=[WH_JXChat_WHViewController alloc];
    
    sendView.scrollLine = 0;
    sendView.title = user.userNickname;
    sendView.chatPerson = user;
    sendView = [sendView init];
    [g_navigation pushViewController:sendView animated:YES];
    sendView.view.hidden = NO;
}



// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WH_JXUserObject *user = _array[indexPath.row];
        [_array removeObject:user];
        [_table WH_deleteRow:(int)indexPath.row section:(int)indexPath.section];
        [g_server WH_delAttentionWithToUserId:user.userId toView:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JXUserObject *user = _array[indexPath.row];

    if ([user.userId intValue] == 10000) {
        return NO;
    }
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Localized(@"JX_Delete");
}

//服务器返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if ([aDownload.action isEqualToString:wh_act_AttentionDel]) {
        [_wait stop];
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



- (void)sp_upload {
    NSLog(@"Get Info Success");
}
@end
