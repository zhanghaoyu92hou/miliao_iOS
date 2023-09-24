//
//  WH_JXChatLog_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/7/5.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXChatLog_WHVC.h"
#import "WH_JXBaseChat_WHCell.h"
#import "WH_JXMessage_WHCell.h"
#import "WH_JXImage_WHCell.h"
#import "WH_JXLocation_WHCell.h"
#import "WH_JXGif_WHCell.h"
#import "WH_JXVideo_WHCell.h"

@interface WH_JXChatLog_WHVC ()

@end

@implementation WH_JXChatLog_WHVC


// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEXCOLOR(0xD0D0D0);
    self.tableView.backgroundColor = HEXCOLOR(0xD0D0D0);
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = NO;
    self.wh_isGotoBack = YES;

    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self WH_createHeadAndFoot];
    
    
    [self.tableView reloadData];
    
}


- (void)actionQuit {
    [super actionQuit];
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
    
    NSLog(@"indexPath.row:%ld,%ld",indexPath.section,indexPath.row);
    
    //返回对应的Cell
    WH_JXBaseChat_WHCell * cell = [self getCell:msg indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    msg.changeMySend = 1;
    cell.msg = msg;
    cell.indexNum = (int)indexPath.row;
    cell.delegate = self;
    //    cell.chatCellDelegate = self;
    //    cell.readDele = @selector(readDeleWithUser:);
    cell.isShowHead = YES;
    [cell setCellData];
    [cell setHeaderImage];
    [cell setBackgroundImage];
    [cell isShowSendTime];
    //转圈等待
    if ([msg.isSend intValue] == transfer_status_ing) {
        [cell drawIsSend];
    }
    msg = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WH_JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
    
    switch ([msg.type intValue]) {
        case kWCMessageTypeText:
            return [WH_JXMessage_WHCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeImage:
            return [WH_JXImage_WHCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeLocation:
            return [WH_JXLocation_WHCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeGif:
            return [WH_JXGif_WHCell getChatCellHeight:msg];
            break;
        case kWCMessageTypeVideo:
            return [WH_JXVideo_WHCell getChatCellHeight:msg];
            break;
        default:
            return [WH_JXBaseChat_WHCell getChatCellHeight:msg];
            break;
    }
}


#pragma mark -----------------获取对应的Cell-----------------
- (WH_JXBaseChat_WHCell *)getCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    WH_JXBaseChat_WHCell * cell = nil;
    switch ([msg.type intValue]) {
        case kWCMessageTypeText:
            cell = [self WH_creat_WHMessageCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeImage:
            cell = [self WH_creat_WHImageCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeLocation:
            cell = [self WH_creat_WHLocationCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeGif:
            cell = [self WH_creat_WHGifCell:msg indexPath:indexPath];
            break;
            
        case kWCMessageTypeVideo:
            cell = [self WH_creat_WHVideoCell:msg indexPath:indexPath];
            break;
        default:
            cell = [[WH_JXBaseChat_WHCell alloc] init];
            break;
    }
    return cell;
}
#pragma  mark -----------------------创建对应的Cell---------------------
//文本
- (WH_JXBaseChat_WHCell *)WH_creat_WHMessageCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXMessage_WHCell";
    WH_JXMessage_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXMessage_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    return cell;
}
//图片
- (WH_JXBaseChat_WHCell *)WH_creat_WHImageCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXImage_WHCell";
    WH_JXImage_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXImage_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //        cell.chatImage.delegate = self;
        //        cell.chatImage.didTouch = @selector(onCellImage:);
    }
    return cell;
}
//视频
- (WH_JXBaseChat_WHCell *)WH_creat_WHVideoCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXVideo_WHCell";
    WH_JXVideo_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXVideo_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//位置
- (WH_JXBaseChat_WHCell *)WH_creat_WHLocationCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXLocation_WHCell";
    WH_JXLocation_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXLocation_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}
//动画
- (WH_JXBaseChat_WHCell *)WH_creat_WHGifCell:(WH_JXMessageObject *)msg indexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"WH_JXGif_WHCell";
    WH_JXGif_WHCell *cell=[_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WH_JXGif_WHCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
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


- (void)sp_upload:(NSString *)isLogin {
    NSLog(@"Get User Succrss");
}
@end
