//
//  WH_MyOrderList_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_MyOrderList_WHViewController.h"

#import "WH_MyOrderTop_NavigationVew.h"

#import "WH_MyOrderList_WHTableViewCell.h"

#import "WH_OrderListModel.h"

#import "MiXin_OrderInfo_MXViewController.h"

@interface WH_MyOrderList_WHViewController ()
{
    NSInteger _page;
}
@property (nonatomic, assign) NSInteger typeIndex;
@property (nonatomic, strong) NSMutableArray <WH_OrderListModel *> *items;
@end

@implementation WH_MyOrderList_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.wh_isShowHeaderPull = YES;
    self.wh_isShowFooterPull = YES;
    self.title = @"我的订单";
    [self WH_createHeadAndFoot];
    
    [self.view setBackgroundColor:HEXCOLOR(0xF5F6FA)];
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    self.topNavView = [[WH_MyOrderTop_NavigationVew alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 44.5)];
    [self.view addSubview:self.topNavView];
    __weak typeof(self) weakSelf = self;
    [self.topNavView setSelectedOrderTypeBlock:^(NSInteger orderType) {
        NSLog(@"orderType:%li" ,(long)orderType);
        //@[@"全部" ,@"待付款" ,@"待放行" ,@"已完成" ,@"已取消"]
        weakSelf.typeIndex = orderType;
        [weakSelf MiXin_scrollToPageUp];
    }];
    
    [self creatContentView];
    [self MiXin_scrollToPageUp];
}

- (void)creatContentView {
//    self.tableView = [[JXTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topNavView.frame), JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - CGRectGetMaxY(self.topNavView.frame)) style:UITableViewStylePlain];
//    [self.tableView setDelegate:self];
//    [self.tableView setDataSource:self];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.topNavView.frame), JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - CGRectGetMaxY(self.topNavView.frame));
    [self.tableView setBackgroundColor:self.view.backgroundColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.view addSubview:self.tableView];
}

- (void)MiXin_scrollToPageUp {
    _page = 1;
    [self myOrderListReq];
}
- (void)MiXin_scrollToPageDown {
    _page ++;
    [self myOrderListReq];
}

/**
 我的订单列表

 @param types
 0:全部
 1：待放行
 2：已完成
 3：已取消
 5：待付款
 */
- (void)myOrderListReq{
    NSString *reqTypes = @"0";
    switch (_typeIndex) {
        case 0:
            reqTypes = @"0";
            break;
        case 1:
            reqTypes = @"5";
            break;
        case 2:
            reqTypes = @"1";
            break;
        case 3:
            reqTypes = @"2";
            break;
        case 4:
            reqTypes = @"3";
            break;
        default:
            break;
    }
    [g_server paySystem_getOrderListWithTypes:reqTypes pagenum:[NSString stringWithFormat:@"%ld",(long)_page] toView:self];
}

#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"cell";
    WH_MyOrderList_WHTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[WH_MyOrderList_WHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
    }
    [cell.contentView setBackgroundColor:self.listTable.backgroundColor];
    [cell setBackgroundColor:self.listTable.backgroundColor];
    
    cell.model = _items[indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 238;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MiXin_OrderInfo_MXViewController *oInfoVC = [[MiXin_OrderInfo_MXViewController alloc] init];
    oInfoVC.model = _items[indexPath.row];
    __weak typeof(self) weakSelf = self;
    oInfoVC.needRefreshOrderList = ^{
        [weakSelf MiXin_scrollToPageUp];
    };
    [g_navigation pushViewController:oInfoVC animated:YES];
}

#pragma mark ------------------数据成功返回----------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    
    if([aDownload.action isEqualToString:act_portalIndexGetOrderList]){
        if (_page == 1) {
            _items = [NSMutableArray array];
        }
        NSArray *items = [WH_OrderListModel mj_objectArrayWithKeyValuesArray:array1];
        if (items.count) {
            [_items addObjectsFromArray:items];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    [self WH_stopLoading];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    [self WH_stopLoading];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

@end
