//
//  WH_JXMyPromotion_WHVC.m
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXMyPromotion_WHVC.h"
#import "JXPromotionView.h"
#import "WH_JXPromotion_WHCell.h"
#import "WH_JXMyInvitationList_WHVC.h"

@interface WH_JXMyPromotion_WHVC ()<JXPromotionViewDelegate,WH_JXPromotion_WHCellDelegate>
@property (nonatomic, strong) UIView *myTabHeaderView;
@end

@implementation WH_JXMyPromotion_WHVC
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        //    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.wh_isGotoBack = YES;
        _table.backgroundColor = THEMEBACKCOLOR;
        self.myTableViewStyle = 1;
        
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self WH_createHeadAndFoot];
    
    //是否显示刷新控件
    self.wh_isShowFooterPull = YES;
    self.wh_isShowHeaderPull = YES;
    
    self.title = Localized(@"My_MyPromotion");
    
    [self addCustomView];
    
    //获取数据
    [self WH_getServerData];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WH_JXPromotion_WHCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WH_JXPromotion_WHCell class])];
    
}

- (void)addCustomView
{
    UIButton *clearAlearyUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:clearAlearyUserBtn];
    [clearAlearyUserBtn addTarget:self action:@selector(clearAlearyUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [clearAlearyUserBtn setBackgroundColor:HEXCOLOR(0xF03636)];
    [clearAlearyUserBtn setTitle:@"清空已使用推广通证" forState:UIControlStateNormal];
    [clearAlearyUserBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearAlearyUserBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    [clearAlearyUserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        if (THE_DEVICE_HAVE_HEAD) {
            make.bottom.offset(-35);
        }else{
            make.bottom.offset(-15);
        }
        
        make.width.offset(250);
        make.height.offset(44);
    }];
    
    clearAlearyUserBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.14].CGColor;
    clearAlearyUserBtn.layer.shadowOffset = CGSizeMake(0,1);
    clearAlearyUserBtn.layer.shadowOpacity = 1;
    clearAlearyUserBtn.layer.shadowRadius = 6;
    clearAlearyUserBtn.layer.cornerRadius = 22;
    
}

#pragma mark - 清空已使用通证
- (void)clearAlearyUserAction:(UIButton *)btn
{
    [_wait start];
    [g_server ClearHaveUsedPassCardWithUserId:g_myself.userId toView:self];
}

#pragma mark - 数据请求
-(void)WH_getServerData{
    [_wait start];
    if (_page == 0) {
        [g_server QueryUserInvitationCodeInformationWithUserId:g_myself.userId toView:self];
    }else{
        [g_server QueryUserInvitePassCardWithUserId:g_myself.userId PageIndex:_page toView:self];
    }
    
}

#pragma mark - tableViewDelegateAndDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    WH_JXPromotion_WHCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WH_JXPromotion_WHCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataDic = _dataArr[indexPath.row];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JXPromotionView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JXPromotionView class]) owner:nil options:nil] firstObject];
    if (self.dataDic) {
        view.dataDic = self.dataDic;
    }
    
    view.delegate = self;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 408;
}

-(void)WH_getDataObjFromArr:(NSMutableArray*)arr{
    [_table reloadData];
}

#pragma mark - JXPromotionDelegate
- (void)JXPromotionView:(JXPromotionView *)promotionView didClickMyInvertNumBtn:(UIButton *)btn
{
    WH_JXMyInvitationList_WHVC *vc = [[WH_JXMyInvitationList_WHVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

#pragma mark - WH_JXPromotion_WHCellDelegate
- (void)WH_JXPromotion_WHCell:(WH_JXPromotion_WHCell *)cell didSelCopyBtnActionWithCopyBtn:(UIButton *)copyBtn AndIndexPath:(NSIndexPath *)indexPath
{
    [GKMessageTool showText:@"复制成功"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSDictionary *dic = _dataArr[indexPath.row];
    pasteboard.string = [NSString stringWithFormat:@"%@",dic[@"code"]];
}

//服务端返回数据
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    //消费记录
    if ([aDownload.action isEqualToString:wh_act_InviteGetUserInviteInfo]) {
        //添加到数据源
        if (dict == nil) {
            return;
        }
        
        if ([dict[@"userInvitePassCardList"] isKindOfClass:[NSDictionary class]]) {
            
            if ([dict[@"userInvitePassCardList"][@"pageIndex"] intValue] == 0) {
                _dataArr = [[NSMutableArray alloc]initWithArray:dict[@"userInvitePassCardList"][@"pageData"]];
                //            self.dataDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
            }else if([dict[@"userInvitePassCardList"][@"pageIndex"] intValue] <= [dict[@"userInvitePassCardList"][@"pageCount"] intValue]){
                [_dataArr addObjectsFromArray:dict[@"userInvitePassCardList"][@"pageData"]];
            }else{
                //没有更多数据
            }
            
        }
        
        
        

        
        if ([dict[@"inviteCode"] isKindOfClass:[NSDictionary class]]) {
            
            self.dataDic = dict[@"inviteCode"];
            
        }
        
        [self WH_getDataObjFromArr:_dataArr];
        
    }else if ([aDownload.action isEqualToString:wh_act_InviteFindUserPassCard]){
        if (dict == nil) {
            return;
        }
        if ([dict[@"pageIndex"] intValue] == 0) {
            _dataArr = [[NSMutableArray alloc]initWithArray:dict[@"pageData"]];
            //            self.dataDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
        }else if([dict[@"pageIndex"] intValue] <= [dict[@"pageCount"] intValue]){
            [_dataArr addObjectsFromArray:dict[@"pageData"]];
        }else{
            //没有更多数据
        }
        
        [self WH_getDataObjFromArr:_dataArr];
    }else if ([aDownload.action isEqualToString:wh_act_InviteDelUserPassCard]){ //清空已使用通证
        [g_server QueryUserInvitationCodeInformationWithUserId:g_myself.userId toView:self];
    }
    
    
}



#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self WH_stopLoading];
    return WH_hide_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


- (void)sp_checkNetWorking:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
