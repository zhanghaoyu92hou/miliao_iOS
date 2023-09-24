//
//  WH_JXSearchFileLog_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXSearchFileLog_WHVC.h"
#import "WH_JXSearchFileLog_WHCell.h"
#import "WH_JXShareFileObject.h"
#import "WH_JXFileDetail_WHViewController.h"
#import "WH_webpage_WHVC.h"
#import "WH_JXTransferDeatil_WHVC.h"
#import "WH_JXredPacketDetail_WHVC.h"

@interface WH_JXSearchFileLog_WHVC ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation WH_JXSearchFileLog_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = NO;
    [self WH_createHeadAndFoot];
    
    _array = [NSMutableArray array];
    [self WH_getServerData];
}

- (void)WH_getServerData {
    
    switch (self.type) {
        case FileLogType_file:{
            
            _array = [[WH_JXMessageObject sharedInstance] fetchAllMessageListWithUser:self.user.userId withTypes:@[[NSNumber numberWithInt:kWCMessageTypeFile]]];
            self.title = Localized(@"JX_File");
        }
            break;
        case FileLogType_Link:{
            _array = [[WH_JXMessageObject sharedInstance] fetchAllMessageListWithUser:self.user.userId withTypes:@[[NSNumber numberWithInt:kWCMessageTypeLink],[NSNumber numberWithInt:kWCMessageTypeShare]]];
            self.title = Localized(@"JXLink");
        }
            
            break;
        case FileLogType_transact:{
            _array = [[WH_JXMessageObject sharedInstance] fetchAllMessageListWithUser:self.user.userId withTypes:@[[NSNumber numberWithInt:kWCMessageTypeRedPacket],[NSNumber numberWithInt:kWCMessageTypeRedPacketExclusive] ,[NSNumber numberWithInt:kWCMessageTypeTransfer]]];
            self.title = Localized(@"JX_Trading");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXSearchFileLog_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WH_JXSearchFileLog_WHCell"];
    if (!cell) {
        
        cell = [[WH_JXSearchFileLog_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WH_JXSearchFileLog_WHCell"];
    }
    cell.type = self.type;
    WH_JXMessageObject *msg = _array[indexPath.row];
    cell.msg = msg;
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WH_JXMessageObject *msg = _array[indexPath.row];
    
    switch (self.type) {
        case FileLogType_file:{
            WH_JXShareFileObject *obj = [[WH_JXShareFileObject alloc] init];
            obj.fileName = [msg.fileName lastPathComponent];
            obj.url = msg.content;
            obj.size = msg.fileSize;
            
            WH_JXFileDetail_WHViewController *vc = [[WH_JXFileDetail_WHViewController alloc] init];
            vc.shareFile = obj;
            //    [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
            
        }
            break;
        case FileLogType_Link:{
            
            if ([msg.type integerValue] == kWCMessageTypeShare) {
                NSDictionary * msgDict = [msg.objectId mj_JSONObject];
                
                NSString *url = [msgDict objectForKey:@"url"];
                NSString *downloadUrl = [msgDict objectForKey:@"downloadUrl"];
                
                if ([url rangeOfString:@"http"].location == NSNotFound) {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:nil completionHandler:^(BOOL success) {
                        
                        if (!success) {
                            
                            WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
                            webVC.wh_isGotoBack= YES;
                            webVC.isSend = YES;
                            webVC.titleString = [msgDict objectForKey:@"title"];
                            webVC.url = downloadUrl;
                            webVC = [webVC init];
                            [g_navigation.navigationView addSubview:webVC.view];
                            //                [g_navigation pushViewController:webVC animated:YES];
                        }
                        
                    }];
                    
                }else {
                    WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
                    webVC.wh_isGotoBack= YES;
                    webVC.isSend = YES;
                    webVC.titleString = [msgDict objectForKey:@"title"];
                    webVC.url = url;
                    webVC = [webVC init];
                    [g_navigation.navigationView addSubview:webVC.view];
                    //        [g_navigation pushViewController:webVC animated:YES];
                }
                
            }else {
    
                id content = [msg.content mj_JSONObject];
                NSString *url = [content objectForKey:@"url"];
                
                WH_webpage_WHVC *webVC = [WH_webpage_WHVC alloc];
                webVC.wh_isGotoBack= YES;
                webVC.isSend = YES;
                webVC.title = [content objectForKey:@"title"];
                webVC.url = url;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
            }
        }
            
            break;
        case FileLogType_transact:{
            if ([msg.type integerValue] == kWCMessageTypeRedPacket || [msg.type integerValue] == kWCMessageTypeRedPacketExclusive) {
                
                [g_server WH_getRedPacketWithMsg:msg.objectId toView:self];
            }else {
                
                WH_JXTransferDeatil_WHVC *detailVC = [WH_JXTransferDeatil_WHVC alloc];
                detailVC.wh_msg = msg;
                detailVC.onResend = @selector(WH_onResend:);
                detailVC.delegate = self;
                detailVC = [detailVC init];
                [g_navigation pushViewController:detailVC animated:YES];
            }
        }
            
            break;
            
        default:
            break;
    }
    
}

// 重新发送转账消息
- (void)WH_onResend:(WH_JXMessageObject *)msg {
    WH_JXMessageObject *msg1 = [[WH_JXMessageObject alloc]init];
    msg1 = [msg copy];
    msg1.messageId = nil;
    msg1.timeSend     = [NSDate date];
    msg1.fromId = nil;
    msg1.isGroup = NO;
    msg1.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    msg1.isRead       = [NSNumber numberWithBool:NO];
    msg1.isReadDel    = [NSNumber numberWithInt:NO];
    [msg1 insert:nil];
    [g_xmpp sendMessage:msg1 roomName:nil];//发送消息
}

#pragma mark  -------------------服务器返回数据--------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    //获取红包信息
    if ([aDownload.action isEqualToString:wh_act_getRedPacket]) {

        
    }

}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{

    [_wait stop];
    
    //自己查看红包或者红包已领完，resultCode ＝0
    if ([aDownload.action isEqualToString:wh_act_getRedPacket]) {
        
        //        [self changeMessageRedPacketStatus:dict[@"data"][@"packet"][@"id"]];
        //        [self changeMessageArrFileSize:dict[@"data"][@"packet"][@"id"]];
        
        WH_JXredPacketDetail_WHVC * redPacketDetailVC = [[WH_JXredPacketDetail_WHVC alloc]init];
        redPacketDetailVC.wh_dataDict = [[NSDictionary alloc]initWithDictionary:dict];
        //        [g_window addSubview:redPacketDetailVC.view];
        redPacketDetailVC.isGroup = self.isGroup;
        [g_navigation pushViewController:redPacketDetailVC animated:YES];
        
    }
    
    return WH_hide_error;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
