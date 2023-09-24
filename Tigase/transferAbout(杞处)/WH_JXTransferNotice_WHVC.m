//
//  WH_JXTransferNotice_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTransferNotice_WHVC.h"
#import "WH_JXTransferNotice_WHCell.h"
#import "WH_JXTransferNoticeModel.h"
#import "WH_JXTransferModel.h"
#import "WH_BankCardTrans_WHModel.h"

@interface WH_JXTransferNotice_WHVC ()
@property (nonatomic, strong) NSArray *array;

@end

@implementation WH_JXTransferNotice_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = Localized(@"JX_PaymentNo.");
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self WH_createHeadAndFoot];
    self.wh_isShowFooterPull = NO;
    self.wh_isShowHeaderPull = NO;
    _table.backgroundColor = HEXCOLOR(0xefeff4);
    [self getData];
}

- (void)getData {
    // 获取所有聊天记录
    _array = [[WH_JXMessageObject sharedInstance] fetchAllMessageListWithUser:WAHU_TRANSFER];
    if (_array.count > 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_array.count-1 inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WH_JXMessageObject *msg=[_array objectAtIndex:indexPath.row];

    return [WH_JXTransferNotice_WHCell getChatCellHeight:msg];
//    return 215;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WH_JXTransferNotice_WHCell";
    WH_JXTransferNotice_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WH_JXTransferNotice_WHCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    WH_JXMessageObject *msg = _array[indexPath.row];

    NSDictionary *dict = [self dictionaryWithJsonString:msg.content];
    
    if ([msg.type intValue] == kWCMessageTypeBankCardTrans || [msg.type intValue] == kWCMessageTypeH5PaymentReturn) {
        WH_BankCardTrans_WHModel *model = [WH_BankCardTrans_WHModel mj_objectWithKeyValues:dict];
        [cell setDataWithMsg:msg model:model];
    } else if ([msg.type intValue] == kWCMessageTypeTransferBack) {

        WH_JXTransferModel *model = [[WH_JXTransferModel alloc] init];
        [model getTransferDataWithDict:dict];
        [cell setDataWithMsg:msg model:model];
    }else {
        WH_JXTransferNoticeModel *model = [[WH_JXTransferNoticeModel alloc]init];
        [model getTransferNoticeWithDict:dict];
        [cell setDataWithMsg:msg model:model];
    }
    
    return cell;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
