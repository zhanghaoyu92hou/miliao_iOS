//
//  JXBlogRemindVC.m
//  Tigase_imChatT
//
//  Created by p on 2017/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "JXBlogRemindVC.h"
#import "JXBlogRemind.h"
#import "JXBlogRemindCell.h"
#import "WH_WeiboViewControlle.h"

@interface JXBlogRemindVC ()

@property (nonatomic, assign) BOOL isHaveMore;

@end

@implementation JXBlogRemindVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = Localized(@"JX_NewMessage");
    self.isHaveMore = YES;
    self.wh_isGotoBack = YES;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    [self WH_createHeadAndFoot];
    self.wh_isShowFooterPull = NO;
    
    UIButton* btn = [UIFactory WH_create_WHButtonWithTitle:Localized(@"JX_Clear") titleFont:[UIFont systemFontOfSize:15] titleColor:[UIColor whiteColor] normal:nil highlight:nil];
    [btn addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH-55, JX_SCREEN_TOP - 38, 50, 30);
    [self.wh_tableHeader addSubview:btn];
    
    if (self.wh_isShowAll) {
        self.wh_remindArray = [[JXBlogRemind sharedInstance] doFetch];
        self.isHaveMore = NO;
        [_table reloadData];
    }
}

- (void) onClear {
    [[JXBlogRemind sharedInstance] deleteAllMsg];
    [self.wh_remindArray removeAllObjects];
    self.isHaveMore = NO;
    [_table reloadData];
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == self.wh_remindArray.count) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellName"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 30)];
        label.textColor = [UIColor grayColor];
        label.font = sysFontWithSize(14);
        label.text = Localized(@"JX_GetPreviousMessage");
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        
        return cell;
    }
    
    NSString* cellName = [NSString stringWithFormat:@"JXBlogRemindCell"];
    
    JXBlogRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        cell = [[JXBlogRemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
    }
    if (indexPath.row == 0) {
        cell.wh_toplineView.hidden = NO;
    }else{
        cell.wh_toplineView.hidden = YES;
    }
    JXBlogRemind *br = self.wh_remindArray[indexPath.row];
    [cell WH_doRefresh:br];
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isHaveMore) {
        return self.wh_remindArray.count + 1;
    }else {
        return self.wh_remindArray.count;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.wh_remindArray.count) {
        return 85;
    }
    
    JXBlogRemind *br = self.wh_remindArray[indexPath.row];
    NSString *content = br.content;
    if (br.toUserName.length > 0)
        content = [NSString stringWithFormat:@"%@%@: %@", Localized(@"JX_Reply"),br.toUserName, br.content];
    CGSize size = [content boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 60 - 10 - 80, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sysFontWithSize(13)} context:nil].size;
    if (size.height > 20) {
        return 85 - 20 + size.height;
    }
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == self.wh_remindArray.count) {
        self.wh_remindArray = [[JXBlogRemind sharedInstance] doFetch];
        self.isHaveMore = NO;
        [_table reloadData];
        
        return;
    }
    
    JXBlogRemind *br = self.wh_remindArray[indexPath.row];
    
    self.detailMsgId = br.objectId;
    [g_server WH_getMessageWithMsgId:br.objectId toView:self];
    
//    WH_WeiboViewControlle *weibo = [WH_WeiboViewControlle alloc];
//    weibo.wh_detailMsgId = br.objectId;
//    weibo.isDetail = YES;
//    weibo = [weibo init];
////    [g_window addSubview:weibo.view];
//    [g_navigation pushViewController:weibo animated:YES];
}

#pragma mark  -------------------服务器返回数据--------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    if ([aDownload.action isEqualToString:wh_act_MsgGet]) {
        if (!IsArrayNull(array1) || !IsDictionaryNull(dict)) {
            WH_WeiboViewControlle *weibo = [WH_WeiboViewControlle alloc];
            weibo.wh_detailMsgId = self.detailMsgId;
            weibo.isDetail = YES;
            weibo = [weibo init];
            //    [g_window addSubview:weibo.view];
            [g_navigation pushViewController:weibo animated:YES];

        }else{
            [GKMessageTool showText:@"该朋友圈已被删除！"];
            return;
        }
    }
}

-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    [_wait stop];
    return WH_hide_error;
}

-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_hide_error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)sp_getUserFollowSuccess {
    NSLog(@"Get Info Success");
}
@end
