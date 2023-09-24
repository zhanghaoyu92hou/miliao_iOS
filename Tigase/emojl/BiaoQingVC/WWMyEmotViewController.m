//
//  WWMyEmotViewController.m
//  WaHu
//
//  Created by Apple on 2019/2/28.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWMyEmotViewController.h"
#import "WWMyEmotSettingCell.h"
#import "WWEmoticonDetailViewController.h"


@interface WWMyEmotViewController ()<UITableViewDelegate,UITableViewDataSource,WWMyEmotSettingCellDelegate>

@property (nonatomic, assign) int pageNo;

@property (nonatomic, strong) NSMutableArray * allDataArr;

@end

@implementation WWMyEmotViewController

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
}


- (void)setUpNavigationBar
{
    self.title = @"我的表情";
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
    
    
    [g_server getMyEmjioListWithPageIndex:_page toView:self];
    
}

#pragma mark  -------------------服务器返回数据--------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    /// 我的表情
    if ([aDownload.action isEqualToString:wh_act_emojiMyDownListPage]) {
        
        [_wait stop];
        [self WH_stopLoading];
        NSDictionary *tempDic = [array1 firstObject];
        NSArray *imEmojiStoreArr = tempDic[@"imEmojiStore"];
        if (_page == 0) {
            [self.allDataArr removeAllObjects];
            if ([imEmojiStoreArr isKindOfClass:[NSArray class]]) {
                [self.allDataArr addObjectsFromArray:imEmojiStoreArr];
            }
            
        }else {
            if ([imEmojiStoreArr isKindOfClass:[NSArray class]]) {
                [self.allDataArr addObjectsFromArray:imEmojiStoreArr];
            }
        }
        
        [self.tableView reloadData];
    }else if ([aDownload.action isEqualToString:wh_act_emojiUserListDelete]) {
        
        [self.header beginRefreshing];
        
        [g_notify postNotificationName:kUpdateMyDownloadEmjioNotification object:nil];
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




#pragma mark - tableViewDeletage

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WWMyEmotSettingCell *cell = [WWMyEmotSettingCell cellWithTableView:tableView indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataDic = self.allDataArr[indexPath.row];
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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



#pragma mark - WWMyEmotSettingCellDelegate

- (void)MyEmotSettingCellDidClickRemoveBtn:(UIButton *)removeBtn dataDic:(NSDictionary *)dic
{
    //调取移除表情请求
    NSString *emoPackId = [NSString stringWithFormat:@"%@",dic[@"emoPackId"]];
    [g_server deleteMyEmjioListWithCustomEmoId:emoPackId toView:self];
}

@end
