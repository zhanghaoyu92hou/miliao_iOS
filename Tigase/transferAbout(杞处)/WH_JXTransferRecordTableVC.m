//
//  WH_JXTransferRecordTableVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/4/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTransferRecordTableVC.h"
#import "WH_JXRecordModel.h"
#import "WH_JXRecord_WHCell.h"

@interface WH_JXTransferRecordTableVC ()
//@property (nonatomic, strong) WH_JXRecordModel *model;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation WH_JXTransferRecordTableVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self WH_createHeadAndFoot];
    _array = [[NSMutableArray alloc] init];

    self.title = Localized(@"JX_TransferTheDetail");
    
    [self WH_getServerData];
}


- (void)WH_getServerData {
    [g_server WH_getConsumeRecordListInfoWithToUserId:self.wh_userId pageIndex:_page pageSize:20 toView:self];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"WH_JXRecord_WHCell";
    WH_JXRecord_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXRecord_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    WH_JXRecordModel *model = _array[indexPath.row];
    
    [cell setData:model];
    
    return cell;
}



#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:wh_act_getConsumeRecordList]){
        NSArray *arr = [dict objectForKey:@"pageData"];
        if (arr.count <= 0) {
        }
        NSMutableArray *mutArr = [[NSMutableArray alloc] init];
        if(_page == 0){
            [_array removeAllObjects];
            for (int i = 0; i < arr.count; i++) {
                WH_JXRecordModel *model = [[WH_JXRecordModel alloc] init];
                [model getDataWithDict:arr[i]];
                [mutArr addObject:model];
            }
            [_array addObjectsFromArray:mutArr];
        }else{
            if([arr count]>0){
                for (int i = 0; i < arr.count; i++) {
                    WH_JXRecordModel *model = [[WH_JXRecordModel alloc] init];
                    [model getDataWithDict:arr[i]];
                    [mutArr addObject:model];
                }
                [_array addObjectsFromArray:mutArr];
            }
        }
        _page ++;
        [_table reloadData];

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

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}



@end
