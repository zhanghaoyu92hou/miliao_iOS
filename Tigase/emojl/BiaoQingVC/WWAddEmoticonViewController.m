//
//  WWAddEmoticonViewController.m
//  WaHu
//
//  Created by Apple on 2019/2/28.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWAddEmoticonViewController.h"
#import "WWAddEmoticonCell.h"
//#import "WWBusinessManager.h"
#import "WWEmoticonDetailViewController.h"
#import "WWMyEmotViewController.h"


@interface WWAddEmoticonViewController ()<UITableViewDelegate,UITableViewDataSource,WWAddEmoticonDelegate>

@property (nonatomic, strong) NSMutableArray * allDataArr;

@end

@implementation WWAddEmoticonViewController

- (NSMutableArray *)allDataArr
{
    if (_allDataArr == nil) {
        _allDataArr = [NSMutableArray array];
    }
    
    return _allDataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self WH_createHeadAndFoot];
    self.tableView.backgroundColor = g_factory.globalBgColor;
    
    [self setUpNavigationBar];
    
    [self.view addSubview:self.tableView];
    
    [self WH_getServerData];
    
    [g_notify addObserver:self selector:@selector(WH_scrollToPageUp) name:kUpdateMyDownloadEmjioNotification object:nil];
    
    _page = 0;
}

- (void)setUpNavigationBar
{
    self.title = @"表情商店";
    
    // 自定制导航条 - 右侧按钮
    
    UIButton *btn;
    btn = [UIFactory WH_create_WHButtonWithImage:@"biaoqing_setting" highlight:nil target:self selector:@selector(settingButtonOnClick)];
    btn.custom_acceptEventInterval = 1.0f;
    btn.frame = CGRectMake(JX_SCREEN_WIDTH - 42 - g_factory.globelEdgeInset, JX_SCREEN_TOP - 43, 42, 42);
    //        [btn1 addSubview:btn];
    [self.wh_tableHeader addSubview:btn];
}


#pragma mark - navBar按钮点击事件
- (void)settingButtonOnClick
{
    WWMyEmotViewController *vc = [[WWMyEmotViewController alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}



#pragma mark - tableViewDeletage

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WWAddEmoticonCell *cell = [WWAddEmoticonCell cellWithTableView:tableView indexPath:indexPath];
    cell.dataDic = self.allDataArr[indexPath.row];
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WWEmoticonDetailViewController *detailVC = [[WWEmoticonDetailViewController alloc] init];
    NSDictionary *dic = self.allDataArr[indexPath.row];
    detailVC.dataArray = dic[@"imEmojiStoreListInfo"];
    detailVC.title = dic[@"emoPackName"];
    [g_navigation pushViewController:detailVC animated:YES];
}


#pragma mark - 数据请求

- (void)WH_scrollToPageUp {
    _page = 0;
    [self WH_getServerData];
}
- (void)WH_scrollToPageDown {
    _page ++;
    [self WH_getServerData];
}

- (void) WH_getServerData {
    
    
    [g_server getEmjioStoreListWithPageIndex:_page toView:self];
    
}

#pragma mark  -------------------服务器返回数据--------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    /// 表情商店
    if ([aDownload.action isEqualToString:wh_act_emojiStoreList]) {
        
        [_wait stop];
        [self WH_stopLoading];
        
        if (_page == 0) {
            [self.allDataArr removeAllObjects];
            [self.allDataArr addObjectsFromArray:array1];
        }else {
            [self.allDataArr addObjectsFromArray:array1];
        }
        
        [self.tableView reloadData];
    }else if ([aDownload.action isEqualToString:wh_act_emojiUserListAdd]) {
        
        [self.header beginRefreshing];
        
        [g_notify postNotificationName:kUpdateMyDownloadEmjioAddNotification object:nil userInfo:nil];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}


#pragma mark - WWAddEmoticonCell

- (void)addEmoticonDidClickWithAddBtn:(UIButton *)addBtn andAleadyBtn:(UIButton *)aleadyBtn dataDic:(nonnull NSDictionary *)dic
{
    //添加自定义表情组
    NSString *emoPackId = [NSString stringWithFormat:@"%@",dic[@"emoPackId"]];
    
    [g_server AddEmjioListToMineWithCustomEmoId:emoPackId toView:self];
    
    
    
}


@end
