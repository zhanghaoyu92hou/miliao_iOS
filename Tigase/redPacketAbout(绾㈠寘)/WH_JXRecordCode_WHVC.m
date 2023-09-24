//
//  WH_JXRecordCode_WHVC.m
//  Tigase_imChatT
//
//  Created by Apple on 16/9/18.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXRecordCode_WHVC.h"
#import "WH_JXRecordTB_WHCell.h"
@interface WH_JXRecordCode_WHVC ()

@end

@implementation WH_JXRecordCode_WHVC
- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customView];
    [self WH_getServerData];
}
-(void)WH_getServerData{
    [_wait start];
    [g_server WH_getConsumeRecordWithIndex:_page toView:self];
}
- (void)customView{
    
//    self.title = Localized(@"WaHu_JXRecordCode_WHVC_Title");
    self.title = @"账单";
    [self WH_createHeadAndFoot];
    
    [_table setFrame:CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_TOP, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, JX_SCREEN_HEIGHT - JX_SCREEN_TOP)];
    [_table setBackgroundColor:g_factory.globalBgColor];
    _table.delegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.allowsSelection = NO;
    
}

- (void)createEmptyView {
    if (self.wh_eView) {
        [self.self.wh_eView removeFromSuperview];
    }
    self.wh_eView = [[UIView alloc] init];
    [self.view addSubview:self.self.wh_eView];
    [self.wh_eView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(JX_SCREEN_TOP, 0, 0, 0));
    }];
    
    UIImageView *emptyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_Empty"]];
    [self.wh_eView addSubview:emptyImg];
    [emptyImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.wh_eView);
    }];
    
    //icon_not_found
//    if (self.eView) {
//        [self.eView removeFromSuperview];
//    }
//    self.eView = [[UIView alloc] initWithFrame:CGRectMake(0, (JX_SCREEN_HEIGHT - JX_SCREEN_TOP - 200)/2 - 80, self.tableView.frame.size.width, 200)];
//    [self.eView setBackgroundColor:g_factory.globalBgColor];
//    [self.tableView addSubview:self.eView];
    
//    UIImageView *eImg = [[UIImageView alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width - 170)/2, 30, 170, 170)];
//    [eImg setImage:[UIImage imageNamed:@"icon_not_found"]];
//    [self.eView addSubview:eImg];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
//    [label setText:@"暂无数据"];
//    [label setTextColor:HEXCOLOR(0x8F9CBB)];
//    [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
//    [label setTextAlignment:NSTextAlignmentCenter];
//    [self.eView addSubview:label];
}

-(void)WH_getDataObjFromArr:(NSMutableArray*)arr{
    [_table reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
     return [_wh_dataArr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [_dataArr count];
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WH_JXRecordTB_WHCell * cell = [tableView dequeueReusableCellWithIdentifier:@"WH_JXRecordTB_WHCell"];
    
    if (cell == nil) {
        if ([g_config.isWithdrawToAdmin intValue] == 1){//提现到后台
            cell = [[NSBundle mainBundle] loadNibNamed:@"WH_JXRecordTB_WHCell" owner:self options:nil][0];
        }else{
            cell = [[NSBundle mainBundle] loadNibNamed:@"WH_JXRecordTB_WHCell" owner:self options:nil][1];
        }
        
    }
    [cell.contentView setBackgroundColor:HEXCOLOR(0xffffff)];
    [cell setBackgroundColor:HEXCOLOR(0xffffff)];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = g_factory.cardCornerRadius;
    cell.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cell.layer.borderWidth = g_factory.cardBorderWithd;
    
    NSDictionary * cellModel = _wh_dataArr[indexPath.section];
    
    //描述
    cell.titleLabel.text = cellModel[@"desc"];
    [cell.titleLabel setTextColor:HEXCOLOR(0x3A404C)];
    [cell.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]];
    
    //转换为日期
    NSTimeInterval  creatTime = [cellModel[@"time"]  doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:creatTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*60*60]];//中国专用
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
//    cell.timeLabel.text = @"12月24日 20:52";
    [cell.timeLabel setTextColor:HEXCOLOR(0x969696)];
    [cell.timeLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 13]];
    
    //交易金额
    cell.moneyLabel.text = [NSString stringWithFormat:@"%@ %@",cellModel[@"money"],Localized(@"JX_ChinaMoney")];
    //是否退款
    cell.refundLabel.text = @"";
    
    if ([g_config.isWithdrawToAdmin intValue] == 1){//提现到后台
        NSDictionary * cellModel = _wh_dataArr[indexPath.section];
        
        if ([[cellModel objectForKey:@"type"] integerValue] == 15) {
            //后台审核
            //1：审核通过 2：待审核 3：审核拒绝
            NSString *state = [cellModel objectForKey:@"status"];
            if ([state integerValue] == 1) {
                [cell.statusImgView setImage:[UIImage imageNamed:@"auditState_tongguo"]];
            }else if ([state integerValue] == 2) {
                [cell.statusImgView setImage:[UIImage imageNamed:@"auditState_daishenhe"]];
            }else if ([state integerValue]  == 3) {
                [cell.statusImgView setImage:[UIImage imageNamed:@"auditState_jujue"]];
            }
        }
    }
    NSInteger type = [cellModel[@"type"] integerValue];
    NSInteger payType = [cellModel[@"payType"] integerValue];
    NSInteger status = [cellModel[@"status"] integerValue];
    if(type == 1 && payType == 6){ //payType == 6是云支付
        NSString *des = @"";
        if (status == 1) {
            //成功
            des = @"成功";
        } else if (status == 6){
            //失败
            des = @"失败";
        }
        cell.titleLabel.text = [NSString stringWithFormat:@"%@%@",cell.titleLabel.text,des];
    }
    
    switch (status) {
        case 0: //订单创建
            cell.titleLabel.textColor = HEXCOLOR(0x23B525);
            cell.moneyLabel.textColor = HEXCOLOR(0x23B525);
            break;
        case 1: //支付  充值 成功
            cell.titleLabel.textColor = [UIColor blackColor];
            if (type == 1 || type == 3 || type == 5
                || type == 6 || type == 8 || type == 9 || type == 11
                || type == 13 || type == 14) {
                cell.moneyLabel.textColor = HEXCOLOR(0xEEB026);
            } else if (type == 2 || type == 4 || type == 7
                       || type == 10 || type == 12 || type == 16) {
                cell.moneyLabel.textColor = [UIColor blackColor];
            }
            break;
        case -1: //交易关闭:
            cell.titleLabel.textColor = HEXCOLOR(0xED6350);
            cell.moneyLabel.textColor = HEXCOLOR(0xED6350);
            break;
        case 2:  //审核初始化
            cell.titleLabel.textColor = HEXCOLOR(0x23B525);
            cell.moneyLabel.textColor = HEXCOLOR(0x23B525);
            break;
        case 3:  //审核驳回
            cell.titleLabel.textColor = HEXCOLOR(0xED6350);
            cell.moneyLabel.textColor = HEXCOLOR(0xED6350);
            break;
        case 4:   //交易完成
            cell.titleLabel.textColor = [UIColor blackColor];
            cell.moneyLabel.textColor = HEXCOLOR(0xEEB026);
            break;
        case 5:   //支付失败
            cell.titleLabel.textColor = HEXCOLOR(0xED6350);
            cell.moneyLabel.textColor = HEXCOLOR(0xED6350);
            break;
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _table.frame.size.width, 12)];
    [view setBackgroundColor:_table.backgroundColor];
    return view;
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    //消费记录
    if ([aDownload.action isEqualToString:wh_act_consumeRecord]) {
        //添加到数据源
        if (dict == nil) {
            [self createEmptyView];
            [_table setHidden:YES];
            
            return;
        }
        
        [_table setHidden:NO];
        if (self.wh_eView) {
            [self.wh_eView setHidden:YES];
        }
        if ([dict[@"pageIndex"] intValue] == 0) {
            _wh_dataArr = [[NSMutableArray alloc]initWithArray:dict[@"pageData"]];
            //            self.dataDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
        }else if([dict[@"pageIndex"] intValue] <= [dict[@"pageCount"] intValue]){
            [_wh_dataArr addObjectsFromArray:dict[@"pageData"]];
        }else{
            //没有更多数据
        }
        
        if (_wh_dataArr.count > 0) {
            [self WH_getDataObjFromArr:_wh_dataArr];
        }else{
            [self createEmptyView];
        }  
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self WH_stopLoading];
    return WH_hide_error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)sp_getMediaFailed {
    NSLog(@"Continue");
}
@end
