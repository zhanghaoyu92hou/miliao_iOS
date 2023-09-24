//
//  MiXin_CompanyListController.m
//  Tigase
//
//  Created by Apple on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MiXin_DepartMentViewController.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "WH_DepartObject.h"
#import "MiXin_MemberlistController.h"
#import "MiXin_MemberInfoController.h"
#import "MiXin_CompanyListController.h"

@interface MiXin_MemberlistCell : UITableViewCell

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *job;
@property (nonatomic, strong) UILabel *vip;
@end

@implementation MiXin_MemberlistCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.icon = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 36, 36)];
        [self.contentView addSubview:self.icon];
        [self.icon setRadiu:18 color:nil];
        self.icon.image = [UIImage imageNamed:@"comlogo"];
        
        [self createLine:CGRectMake(60, 0, .5, 60) color:HEXCOLOR(0xF5F7FA) radio:0 border:nil sup:self.contentView];
        
        self.name = [self createLab:CGRectMake(70, 10, JX_SCREEN_WIDTH-150, 16) font:sysFontWithSize(16) color:HEXCOLOR(0x333333) text:@""];
        [self.contentView addSubview:self.name];
        
        self.job = [self createLab:CGRectMake(70, 30, JX_SCREEN_WIDTH-80, 16) font:sysFontWithSize(12) color:HEXCOLOR(0x969696) text:@""];
        [self.contentView addSubview:self.job];
        
        self.vip = [self createLab:CGRectMake(self.name.right+10, 10, 70, 20) font:sysFontWithSize(12) color:[UIColor whiteColor] text:@""];
        [self.vip setRadiu:10 color:nil];
        self.vip.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.vip];
        self.vip.backgroundColor = HEXCOLOR(0x0093FF);
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}
@end

@interface MiXin_MemberlistController ()<UIAlertViewDelegate, UITextFieldDelegate,UITextViewDelegate> {
    NSMutableArray *_searchs;
}
@property (nonatomic, strong) NSMutableArray *exits;
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) UITableView *searchList;
@end

@implementation MiXin_MemberlistController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    _exits = [NSMutableArray array];
    _models = [NSMutableArray array];
    _searchs = [NSMutableArray array];
    [self customView];
    
    //[_wait start];
    //请求该部门员工
    [g_server WH_getEmpListWithDepartmentId:_departId toView:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //请求所有部门所有员工
    [g_server WH_getDepartmentListPageWithPageIndex:@0 companyId:_comId toView:self];
}


- (void)customView {
    
    self.title = _tname;
    [self WH_createHeadAndFoot];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 160)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    _seekTextField = [bgView createTF:CGRectMake(10, 8, bgView.frame.size.width - 20, 30) font:g_factory.inputDefaultTextFont color:HEXCOLOR(0x333333) text:@"" place:[NSString stringWithFormat:@"%@", Localized(@"JX_SearchChatLog")]];
    _seekTextField.backgroundColor = g_factory.inputBackgroundColor;
    
    if (@available(iOS 10, *)) {
        _seekTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", Localized(@"JX_SearchChatLog")] attributes:@{NSForegroundColorAttributeName:g_factory.inputDefaultTextColor}];
    } else {
        [_seekTextField setValue:g_factory.inputDefaultTextColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    [_seekTextField setRadiu:15 color:g_factory.inputBorderColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [bgView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_seekTextField addTarget:self action:@selector(textFieldDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    NSArray *arrw = @[@"我的同事",_comname?:@"",_tname?:@""];
    for (int i = 0; i < arrw.count; i++) {
        UIButton *btn = [bgView createBtn:CGRectMake(i*103, 46, 80, 44) font:sysFontWithSize(15) color:HEXCOLOR(0x0093FF) text:arrw[i] img:nil target:self sel:@selector(clickGrade:)];
        btn.tag = 5203+i;
        [bgView addSubview:btn];
        if (i<2) {
            UIImageView *arow = [[UIImageView alloc]initWithFrame:CGRectMake(btn.right+8, 46+16, 7, 12)];
            arow.image = [UIImage imageNamed:@"emarrow"];
            [bgView addSubview:arow];
        }else {
            [btn setTitleColor:HEXCOLOR(0xBAC3D5) forState:UIControlStateNormal];
        }
    }
    
    [bgView createLine:CGRectMake(0, 46, JX_SCREEN_WIDTH, .5) color:HEXCOLOR(0xF5F7FA) radio:0 border:nil sup:bgView];
    [bgView createLine:CGRectMake(0, 90, JX_SCREEN_WIDTH, .5) color:HEXCOLOR(0xF5F7FA) radio:0 border:nil sup:bgView];
    
    
    UIButton *bbb = [bgView createBtn:CGRectMake(0, 90, JX_SCREEN_WIDTH, 60) font:nil color:nil text:nil img:nil target:self sel:@selector(clickInvite:)];
    UIImageView *sss = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 36, 36)];
    sss.image = [UIImage imageNamed:@"邀请"];
    [bbb addSubview:sss];
    UILabel *tip = [bgView createLab:CGRectMake(sss.right+24, sss.top, 200, 36) font:sysFontWithSize(16) color:HEXCOLOR(0x333333) text:@"邀请同事加入"];
    [bbb addSubview:tip];
    [bgView addSubview:bbb];
    
    [bgView createLine:CGRectMake(0, 150, JX_SCREEN_WIDTH, 10) color:HEXCOLOR(0xF5F7FA) radio:0 border:nil sup:bgView];
    [self.view addSubview:bgView];
    
    [_table setFrame:CGRectMake(0, bgView.bottom,JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT- bgView.bottom)];
    [_table setBackgroundColor:g_factory.globalBgColor];
    _table.delegate = self;
    _table.dataSource = self;
    _table.rowHeight = 55;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table registerClass:[MiXin_MemberlistCell class] forCellReuseIdentifier:@"cell"];
    
    _searchList = [[UITableView alloc]initWithFrame:CGRectMake(0, JX_SCREEN_TOP+46, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-46) style:UITableViewStylePlain];
    [_searchList setBackgroundColor:g_factory.globalBgColor];
    _searchList.delegate = self;
    _searchList.dataSource = self;
    _searchList.rowHeight = 55;
    _searchList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_searchList registerClass:[MiXin_MemberlistCell class] forCellReuseIdentifier:@"search"];
    [self.view addSubview:_searchList];
    _searchList.hidden = YES;
}

- (void)clickGrade:(UIButton *)sender {
    if (sender.tag == 5203) {
        [g_navigation popToViewController:[MiXin_CompanyListController class] animated:YES];
    }else if (sender.tag == 5204) {
        [g_navigation popToViewController:[MiXin_DepartMentViewController class] animated:YES];
    }
}


- (void)textFieldDidChange:(UITextField *)textField {
    NSString *ss = [textField.text lowercaseString];
    if (textField.text.length > 0) {
        [_searchs removeAllObjects];
        for (MiXin_EmployeeModel *mod in _models) {
            if ([[mod.nickname lowercaseString] containsString:ss]) {
                [_searchs addObject:mod];
            }
        }
        _searchList.hidden = NO;
        [_searchList reloadData];
    }else {
        _searchList.hidden = YES;
    }
}

- (void)textFieldDidEnd:(UITextField *)textField {
    _searchList.hidden = YES;
}


#pragma mark 加员工
- (void)clickInvite:(UIButton *)sender {
    WH_JXSelectFriends_WHVC * addEmployeeVC = [[WH_JXSelectFriends_WHVC alloc] init];
    addEmployeeVC.delegate = self;
    addEmployeeVC.didSelect = @selector(addEmployeeDelegate:);
    NSMutableSet * existSet = [NSMutableSet setWithArray:[_exits mutableArrayValueForKey:@"userId"]];
    addEmployeeVC.existSet = existSet;
    [g_navigation pushViewController:addEmployeeVC animated:YES];
}



-(void)addEmployeeDelegate:(WH_JXSelectFriends_WHVC*)vc{
    NSArray * allArr;
    if (vc.seekTextField.text.length > 0) {
        allArr = [vc.searchArray copy];
    }else{
        allArr = [vc.letterResultArr copy];
    }
    NSArray * indexArr = [vc.set allObjects];
    NSMutableArray * adduserArr = [NSMutableArray array];
    for (NSNumber * index in indexArr) {
        WH_JXUserObject *user;
        if (vc.seekTextField.text.length > 0) {
            user = allArr[[index intValue] % 1000];
        }else{
            user = [[allArr objectAtIndex:[index intValue] / 1000] objectAtIndex:[index intValue] % 1000];
        }
        [adduserArr addObject:user.userId];
    }
    if (adduserArr.count > 0) {

        [g_server WH_addEmployeeWithIdArr:adduserArr companyId:_comId departmentId:_departId roleArray:nil toView:self];
    }
}




#pragma mark - 列表 -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _searchList) {
        return _searchs.count;
    }
    return _models.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MiXin_MemberlistCell * cell;
    MiXin_EmployeeModel *model;
    if (tableView == _searchList) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"search"];
        model = _searchs[indexPath.row];
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        model = _models[indexPath.row];
    }
    cell.name.text = model.nickname;
    cell.job.text = model.position;
    [g_server WH_getHeadImageLargeWithUserId:model.userId userName:model.nickname imageView:cell.icon];
    
    [cell.name sizeToFit];
    cell.name.height = 20;
    if ([model.role isEqualToString:@"3"]) {
        cell.vip.hidden = NO;
        cell.vip.left = cell.name.right+10;
        cell.vip.text = @"管理";
        [cell.vip sizeToFit];
        cell.vip.width+=20;
        cell.vip.height = 20;
    }else {
        cell.vip.hidden = YES;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MiXin_EmployeeModel *model;
    if (tableView == _searchList) {
        model = _searchs[indexPath.row];
    }else {
        model = _models[indexPath.row];
    }
    MiXin_MemberInfoController *vc = [MiXin_MemberInfoController new];
    vc.employeeId = model.ID;
    vc.comname = _comname;
    vc.departname = self.wh_headerTitle.text;
    vc.createUserId = _createUserId;
    vc.deleteEmploy = ^{
        [g_server WH_getEmpListWithDepartmentId:_departId toView:self];
    };
    [g_navigation pushViewController:vc animated:YES];
}


- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_seekTextField resignFirstResponder];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self WH_stopLoading];
    if ([aDownload.action isEqualToString:wh_act_empList]) {//部门列表
        [_models removeAllObjects];
        [_models addObjectsFromArray: [MiXin_EmployeeModel mj_objectArrayWithKeyValuesArray:array1]];
        [_table reloadData];
        
    }else if ([aDownload.action isEqualToString:wh_act_addEmployee]) {//添加员工
        [g_server showMsg:Localized(@"OrgaVC_AddEmployeeSuccess") delay:1.0];
        [g_server WH_getEmpListWithDepartmentId:_departId toView:self];
    }else if ([aDownload.action isEqualToString:wh_act_departmentList]) {//部门列表
        [_exits removeAllObjects];
        NSArray *ttt = [MiXin_DepartModel mj_objectArrayWithKeyValuesArray:array1];
        for (MiXin_DepartModel *mod in ttt) {
            [_exits addObjectsFromArray:mod.employees];
        }
    }
    
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self WH_stopLoading];
    if ([aDownload.action isEqualToString:wh_act_addEmployee]) {//添加员工
        [g_server showMsg:Localized(@"OrgaVC_AddEmployeeSuccess") delay:1.0];
        [g_server WH_getEmpListWithDepartmentId:_departId toView:self];
    }
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

