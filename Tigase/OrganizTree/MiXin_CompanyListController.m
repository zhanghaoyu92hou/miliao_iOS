//
//  MiXin_CompanyListController.m
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXAddDepart_WHViewController.h"
#import "MiXin_CompanyListController.h"

#import "MiXin_CompanyCell.h"
#import "MiXin_DepartMentViewController.h"

@interface MiXin_CompanyListController ()<AddDepartDelegate> {
    UIView *_noCompanyView;
    UIView *_head;
}
@property (nonatomic, strong) NSMutableArray *models;
@end

@implementation MiXin_CompanyListController
- (instancetype)init
{
    self = [super init];
    if (self) {

        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        _models = [NSMutableArray array];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];

    [self customView];

    [_wait start];
    _models = [NSMutableArray array];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [g_server WH_getAutoSearchCompany:self];
    
}


- (void)customView{
    
    self.title = @"我的同事";
    [self WH_createHeadAndFoot];

    [_table setFrame:CGRectMake(10, JX_SCREEN_TOP,JX_SCREEN_WIDTH-20, JX_SCREEN_HEIGHT- JX_SCREEN_TOP)];
    [_table setBackgroundColor:g_factory.globalBgColor];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = 90;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 106)];
    for (int i = 0; i < 2; i++) {
        UILabel *lab = [head createLab:CGRectMake(10, 25, _table.width, 30) font:[UIFont systemFontOfSize:22] color:HEXCOLOR(0x333333) text:@"你已加入的团队/企业/组织"];
        if (i==1) {
            lab.frame = CGRectMake(10, 65, _table.width, 20);
            lab.font = sysFontWithSize(13);
            lab.text = @"和团队成员在一起，沟通协同更高效";
        }
        [head addSubview:lab];
    }
    _head = head;
    _table.tableHeaderView = _head;
    
}


-(void)showNoCompanyView {
    if (!_noCompanyView) {
        _noCompanyView = [[UIView alloc] initWithFrame:CGRectMake(20, JX_SCREEN_TOP+100, JX_SCREEN_WIDTH-40, 200)];
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(_noCompanyView.width/2-128, 31, 256, 280)];
        img.image = [UIImage imageNamed:@"organztree"];
        [_noCompanyView addSubview:img];
        
        UILabel * noCompanyLabel = [[UILabel alloc] init];
        noCompanyLabel.frame = CGRectMake(0, 20+img.bottom, _noCompanyView.width, 20);
        noCompanyLabel.textAlignment = NSTextAlignmentCenter;
        noCompanyLabel.text = @"你还没有加入团队哦～";//Localized(@"OrgaVC_NoCompanyAlert");
        noCompanyLabel.textColor = HEXCOLOR(0x8F9CBB);
        [_noCompanyView addSubview:noCompanyLabel];
        
        UIButton * createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        createButton.frame = CGRectMake(_noCompanyView.width/2-75, 20+noCompanyLabel.bottom, 150, 45);
        [createButton setTitle:@"创建团队" forState:UIControlStateNormal];
        //Localized(@"OrgaVC_GotoCreateCompany")
        [createButton setRadiu:10 color:nil];
        [createButton setBackgroundColor:THEMECOLOR];
        [createButton addTarget:self action:@selector(showAddCompanyView) forControlEvents:UIControlEventTouchUpInside];
        
        [_noCompanyView addSubview:createButton];
        _noCompanyView.height = createButton.bottom+20;
    }
    [self.view addSubview:_noCompanyView];
}

- (void)showAddCompanyView {
    WH_JXAddDepart_WHViewController * addDepartVC = [[WH_JXAddDepart_WHViewController alloc] init];
    addDepartVC.delegate = self;
    addDepartVC.type = OrganizAddCompany;
    addDepartVC.oldName = nil;
    [g_navigation pushViewController:addDepartVC animated:YES];
}

- (void)inputDelegateType:(OrganizAddType)organizType text:(NSString *)updateStr {
    if (organizType == OrganizAddCompany) {
        [g_server WH_createCompanyWithCompanyName:updateStr toView:self];
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _models.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MiXin_CompanyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MiXin_CompanyCell"];
    
    if (cell == nil) {
        cell = [[MiXin_CompanyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MiXin_CompanyCell"];
        
    }
    MiXin_CompanyModel *model = _models[indexPath.section];
    [cell refresh:model];
    [cell setRadiu:10 color:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MiXin_CompanyModel *model = _models[indexPath.section];
    MiXin_DepartMentViewController *vc = [MiXin_DepartMentViewController new];
    vc.comId = model.ID;
    vc.tname = model.companyName;
    vc.companyName = model.companyName?:@"";
    if (model.rootDpartId.count>0) vc.parentId = model.rootDpartId[0];
    
    __weak typeof(self) weakSelf = self;
    vc.deleteCom = ^{
        [g_server WH_getAutoSearchCompany:weakSelf];
    };
    [g_navigation pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    //自动查找公司
    if([aDownload.action isEqualToString:wh_act_getCompany]){
        if (!array1) {
            //没有公司
            _table.tableHeaderView = nil;
            [self showNoCompanyView];
            [_models removeAllObjects];
            [_table reloadData];
        }else{
            if (_noCompanyView) [_noCompanyView removeFromSuperview];
            if (!_table.tableHeaderView) _table.tableHeaderView = _head;
            
            if (![self.wh_tableHeader viewWithTag:5223]) {
                UIButton *moreBtn = [UIFactory WH_create_WHButtonWithImage:@"WH_addressbook_add" highlight:nil target:self selector:@selector(showAddCompanyView)];
                moreBtn.custom_acceptEventInterval = 1.0f;
                moreBtn.frame = CGRectMake(JX_SCREEN_WIDTH-38, JX_SCREEN_TOP-36, NAV_BTN_SIZE, NAV_BTN_SIZE);
                moreBtn.tag = 5223;
                [self.wh_tableHeader addSubview:moreBtn];
            }
            [_models removeAllObjects];
            [_models addObjectsFromArray: [MiXin_CompanyModel mj_objectArrayWithKeyValuesArray:array1]];
            [_table reloadData];
        }
        
    }else if ([aDownload.action isEqualToString:wh_act_creatCompany]) {//创建公司
        if (_noCompanyView) [_noCompanyView removeFromSuperview];
        //[self setUIDataWith:dict];
        
        [g_server showMsg:Localized(@"OrgaVC_CreateCompanySuccess") delay:1.0];
        if ([dict[@"id"] length] > 0) {
            [g_server WH_getAutoSearchCompany:self];
        }
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
    [_wait stop];

    return WH_show_error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

