//
//  JXLikeListViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/12/19.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "JXLikeListViewController.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JX_WHCell.h"

@interface JXLikeListViewController ()
@property (nonatomic, strong) NSArray *data;

@end

@implementation JXLikeListViewController

- (instancetype)init {
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        [self WH_createHeadAndFoot];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%d%@",self.wh_weibo.praiseCount,Localized(@"WeiboData_PerZan1")];
    if (self.wh_weibo.praises.count > 20) {
        self.wh_weibo.praises = [NSMutableArray arrayWithArray:[self.wh_weibo.praises subarrayWithRange:NSMakeRange(0, 20)]];
    }
}

- (void)WH_getServerData {
    [g_server WH_listPraiseWithMsgId:self.wh_weibo.messageId pageIndex:_page pageSize:20 praiseId:nil toView:self];
}

- (void)WH_scrollToPageDown {
    [super WH_scrollToPageDown];
}


#pragma mark - Table view     --------代理--------     data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wh_weibo.praises.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"JXLikeListCell";
    WH_JX_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[WH_JX_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    WeiboReplyData *data = self.wh_weibo.praises[indexPath.row];
    cell.title = data.userNickName;
    cell.index = (int)indexPath.row;
    cell.delegate = self;
//    cell.didTouch = @selector(WH_on_WHHeadImage:);
    cell.timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 120-20, 9, 115, 20);
    cell.userId = data.userId;
    [cell.lbTitle setText:cell.title];
    
    [cell WH_headImageViewImageWithUserId:nil roomId:nil];
    cell.isSmall = YES;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WeiboReplyData *data = self.wh_weibo.praises[indexPath.row];
    WH_JXUserInfo_WHVC *userVC = [WH_JXUserInfo_WHVC alloc];
    userVC.wh_userId = data.userId;
    userVC.wh_fromAddType = 6;
    userVC = [userVC init];
    [g_navigation pushViewController:userVC animated:YES];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [g_wait stop];
    if ([aDownload.action isEqualToString:wh_act_PraiseList]) {
        for (int i = 0; i < array1.count; i++) {
            WeiboReplyData * reply=[[WeiboReplyData alloc]init];
            reply.type=reply_data_praise;
            [reply WH_getDataFromDict:[array1 objectAtIndex:i]];
            [self.wh_weibo.praises addObject:reply];
        }
        [_table reloadData];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [g_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [g_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [g_wait start:nil];
}



- (void)sp_getUserName {
    NSLog(@"Get Info Failed");
}
@end
