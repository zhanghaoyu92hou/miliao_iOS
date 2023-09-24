//
//  WH_JXRedPacketList_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2018/6/5.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXRedPacketList_WHVC.h"
#import "WH_JXRPacketList_WHCell.h"

@interface WH_JXRedPacketList_WHVC ()

@property (nonatomic, strong) UIButton *getBtn;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) int selIndex;

@end

@implementation WH_JXRedPacketList_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _array = [NSMutableArray array];
    self.wh_isShowFooterPull = YES;
    self.wh_isShowHeaderPull = YES;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 150)];
    headView.backgroundColor = HEXCOLOR(0xCD4331);
    [self.view addSubview:headView];
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(headView.frame), JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - CGRectGetMaxY(headView.frame));
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, JX_SCREEN_TOP - 32, 50, 20)];
    [closeBtn setTitle:Localized(@"JX_Close") forState:UIControlStateNormal];
    [closeBtn setTitleColor:HEXCOLOR(0xFBD49E) forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [closeBtn addTarget:self action:@selector(WH_closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:closeBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH, 20)];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = Localized(@"JX_RedPacketRecord");
    title.textColor = HEXCOLOR(0xFBD49E);
    title.font = [UIFont systemFontOfSize:17.0];
    [headView addSubview:title];
    
    _getBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, headView.frame.size.height - 30, headView.frame.size.width / 2, 30)];
    [_getBtn setTitle:Localized(@"PACKETS_RECEIVED") forState:UIControlStateNormal];
    [_getBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getBtn setTitleColor:HEXCOLOR(0xFBD49E) forState:UIControlStateSelected];
    _getBtn.selected = YES;
    _getBtn.tag = 1000;
    _getBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
    [_getBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_getBtn];
    
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(headView.frame.size.width / 2, headView.frame.size.height - 30, headView.frame.size.width / 2, 30)];
    [_sendBtn setTitle:Localized(@"ENVELOPES_ISSUED") forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:HEXCOLOR(0xFBD49E) forState:UIControlStateSelected];
    _sendBtn.selected = NO;
    _sendBtn.tag = 1001;
    _sendBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
    [_sendBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_sendBtn];
    
    _selIndex = 0;
    _page = 0;
    
    [self WH_getServerData];
}

- (void)WH_closeBtnAction:(UIButton *)btn {
    [self actionQuit];
}

- (void)btnAction:(UIButton *)btn {
    _getBtn.selected = !_getBtn.selected;
    _sendBtn.selected = !_sendBtn.selected;
    _page = 0;
    if (btn.tag == 1000) {
        _selIndex = 0;
    }else {
        _selIndex = 1;
    }
    [self WH_getServerData];
}

- (void)WH_scrollToPageUp {
    _page = 0;
    [self WH_getServerData];
}
- (void)WH_scrollToPageDown {
    _page ++;
    [self WH_getServerData];
}

- (void) WH_getServerData {
    
    if (_selIndex == 0) {
        [g_server WH_redPacketGetRedReceiveListIndex:_page toView:self];
    }else {
        [g_server WH_redPacketGetSendRedPacketListIndex:_page toView:self];
    }
}


#pragma mark  --------------------TableView-------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_array count];
}

-(WH_JXRPacketList_WHCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //领取过红包的用户，使用WH_JXRPacketList_WHCell展示
    NSString * cellName = @"RPacketListCell";
    WH_JXRPacketList_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"WH_JXRPacketList_WHCell" owner:self options:nil][0];
    }
    NSDictionary *dict = _array[indexPath.row];
    cell.headImageWidthCon.constant = 0;
    //用户名
    cell.nameLabel.text = dict[@"sendName"];
    if(_selIndex == 1) {
        NSString *str;
        int type = [dict[@"type"] intValue];
        if (type == 1) {
            str = Localized(@"JX_UsualGift");
        }
        if (type == 2) {
            str = Localized(@"JX_LuckGift");
        }
        if (type == 3) {
            str = Localized(@"JX_MesGift");
        }
        cell.nameLabel.text = str;
    }
    //日期
    NSTimeInterval  getTime = [dict[@"time"] longLongValue];
    if (_selIndex == 1) {
        getTime = [dict[@"sendTime"] longLongValue];
    }
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:getTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*60*60]];//中国专用
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    //金额
    cell.moneyLabel.text = [NSString stringWithFormat:@"%.2f %@",[dict[@"money"] doubleValue],Localized(@"JX_ChinaMoney")];
    //隐藏 hahaha
    cell.contentLab.hidden = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    
    if (_page == 0) {
        [_array removeAllObjects];
        [_array addObjectsFromArray:array1];
    }else {
        [_array addObjectsFromArray:array1];
    }
    
    [self.tableView reloadData];

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


- (void)sp_checkUserInfo:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
