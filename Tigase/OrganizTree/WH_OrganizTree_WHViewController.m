//
//  WH_OrganizTree_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/5/11.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_OrganizTree_WHViewController.h"
#import "WH_DepartObject.h"
#import "WH_EmployeObject.h"

#import "WH_RATreeView.h"
#import "WH_Organiz_WHTableViewCell.h"
#import "WH_Employee_WHTableViewCell.h"
#import "WH_JX_DownListView.h"

#import "WH_JXAddDepart_WHViewController.h"
#import "WH_JXSelFriend_WHVC.h"
#import "WH_JXSelectFriends_WHVC.h"
#import "WH_JXUserInfo_WHVC.h"
#import "WH_JXSelDepart_WHViewController.h"

@interface WH_OrganizTree_WHViewController ()<RATreeViewDelegate, RATreeViewDataSource,AddDepartDelegate,SelDepartDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray<WH_DepartObject *> * dataArray;
@property (nonatomic, weak) WH_RATreeView * treeView;
@property (nonatomic, strong) UIButton * moreButton;


@property (atomic, strong) id currentOrgObj;
@property (nonatomic, assign) BOOL afterDelCompany;
@property (nonatomic, strong) UIControl * control;

@property (nonatomic, strong) NSMutableDictionary * allDataDict;
@property (nonatomic, strong) NSMutableDictionary * employeesDict;
@property (nonatomic, strong) NSMutableDictionary * companyDict;

@property (nonatomic, copy) NSString * companyId;
@property (nonatomic, copy) NSString * companyName;


@property (nonatomic, copy) void (^rowActionAfterRequestBlock)(id sender);
@property (nonatomic, strong) UIView * noCompanyView;

@property (atomic, strong) id item;

@property (nonatomic, assign) BOOL isNotDele;


@end

@implementation WH_OrganizTree_WHViewController
- (id)init
{
    self = [super init];
    if (self) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        
        self.title = Localized(@"OrganizVC_Organiz");
        self.wh_tableBody.backgroundColor = THEMEBACKCOLOR;
        self.wh_isFreeOnClose = YES;
        self.wh_isGotoBack = YES;

#ifdef Live_Version
        self.wh_isGotoBack = YES;
        self.wh_heightFooter = 0;
#endif
        
        
        _dataArray = [NSMutableArray new];
        _allDataDict = [NSMutableDictionary new];
        _employeesDict = [NSMutableDictionary new];
        _companyDict = [NSMutableDictionary new];
        
        [self WH_create_WHTreeView];
        
        [g_server WH_getAutoSearchCompany:self];

    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self createHeadAndFoot];
    
    _moreButton = [UIFactory WH_create_WHButtonWithImage:@"im_003_more_button_normal" highlight:nil target:self selector:@selector(onMore:)];
    _moreButton.frame = CGRectMake(JX_SCREEN_WIDTH-NAV_INSETS-30, JX_SCREEN_TOP - 38, 30, 30);
    [self.wh_tableHeader addSubview:_moreButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_treeView reloadRows];
}

-(void)WH_create_WHTreeView{
    WH_RATreeView *treeView = [[WH_RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStylePlain];
    
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.treeFooterView = [UIView new];
    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    treeView.estimatedRowHeight = 0;
    treeView.estimatedSectionHeaderHeight = 0;
    treeView.estimatedSectionFooterHeight = 0;
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    [treeView.scrollView addSubview:refreshControl];
    
    [treeView reloadData];
    [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    
    
    self.treeView = treeView;
    treeView.frame = self.wh_tableBody.bounds;
    treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.wh_tableBody addSubview:treeView];
    
    [treeView registerClass:[WH_Organiz_WHTableViewCell class] forCellReuseIdentifier:NSStringFromClass([WH_Organiz_WHTableViewCell class])];
    [treeView registerClass:[WH_Employee_WHTableViewCell class] forCellReuseIdentifier:NSStringFromClass([WH_Employee_WHTableViewCell class])];
    
}


#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(WH_RATreeView *)treeView heightForRowForItem:(id)item
{
    return 44;
}

//-(BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item
//{
//    
//    return YES;
//}
- (void)treeView:(WH_RATreeView *)treeView willExpandRowForItem:(id)item
{
    if ([item isMemberOfClass:[WH_DepartObject class]]) {
        WH_Organiz_WHTableViewCell * cell = (WH_Organiz_WHTableViewCell *)[self.treeView cellForItem:item];
        cell.wh_arrowExpand = YES;
    }
}
//- (void)treeView:(RATreeView *)treeView didExpandRowForItem:(id)item{
//    
//}

- (void)treeView:(WH_RATreeView *)treeView willCollapseRowForItem:(id)item
{
    if ([item isMemberOfClass:[WH_DepartObject class]]) {
        WH_Organiz_WHTableViewCell * cell = (WH_Organiz_WHTableViewCell *)[self.treeView cellForItem:item];
        cell.wh_arrowExpand = NO;
    }
}

#pragma mark 左划手势 -删除
- (BOOL)treeView:(WH_RATreeView *)treeView canEditRowForItem:(id)item
{
    return NO;
//    NSInteger level = [self.treeView levelForCellForItem:item];
//    if (level == 0)
//        return NO;
//    else
//        return YES;
    
}

-(UITableViewCellEditingStyle)treeView:(WH_RATreeView *)treeView editingStyleForRowForItem:(id)item{
    if (treeView.editing)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

- (void)treeView:(WH_RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    [self deleteNodeWithItem:item];
}


//-(NSArray *)treeView:(RATreeView *)treeView editActionsForItem:(id)item{
//    DepartObject *parent = [self.treeView parentForItem:item];
//
//    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//
//        if ([item isMemberOfClass:[EmployeObject class]]) {
//            EmployeObject * employee = item;
//            [g_server deleteEmployee:employee.departmentId userId:employee.userId toView:self];
//        }else if ([item isMemberOfClass:[DepartObject class]]) {
//            DepartObject * depart = item;
//            [g_server deleteDepartment:depart.departId toView:self];
//        }
//
//        __weak typeof(self) weakSelf = self;
//        self.rowActionAfterRequestBlock = ^(id sender) {
//            NSInteger index = 0;
//            if (parent == nil) {
//                index = [self.dataArray indexOfObject:item];
//                NSMutableArray *children = [weakSelf.dataArray mutableCopy];
//                [children removeObject:item];
//                weakSelf.dataArray = [children copy];
//            } else {
//                index = [parent.children indexOfObject:item];
//                [parent MiXin_removeChild:item];
//            }
//
//            [weakSelf.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:RATreeViewRowAnimationRight];
//            if (parent) {
//                [weakSelf.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
//            }
//        };
//
//    }];//此处是iOS8.0以后苹果最新推出的api，
//    UITableViewRowAction *editRowAction;
//    if ([item isMemberOfClass:[DepartObject class]]) {
//        UITableViewRowAction *changeRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"改名" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//            //改名
//            _currentOrgObj = item;
//            [self inputViewController:OrganizUpdateDepartmentName];
//
//            __weak typeof(self) weakSelf = self;
//            self.rowActionAfterRequestBlock = ^(id sender) {
//                NSDictionary * dataDict = sender;
//                if (dataDict[@"departName"] != nil && [dataDict[@"departName"] length] >0) {
//                    DepartObject * depart = item;
//                    depart.departName = dataDict[@"departName"];
//                    [weakSelf.treeView reloadRowsForItems:@[depart] withRowAnimation:RATreeViewRowAnimationNone];
//                }
//            };
//        }];
//        changeRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];
//        editRowAction = changeRowAction;
//    }
//
//    if ([item isMemberOfClass:[EmployeObject class]]) {
//        UITableViewRowAction *modifyDpartRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"改部门" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//            //改部门
//            _currentOrgObj = item;
//            self.treeView.editing = YES;
//
////            [self inputViewController:OrganizUpdateDepartmentName];
////
////            __weak typeof(self) weakSelf = self;
////            self.rowActionAfterRequestBlock = ^(id sender) {
////                NSDictionary * dataDict = sender;
////                if (dataDict[@"departName"] != nil && [dataDict[@"departName"] length] >0) {
////                    DepartObject * depart = item;
////                    depart.departName = dataDict[@"departName"];
////                    [weakSelf.treeView reloadRowsForItems:@[depart] withRowAnimation:RATreeViewRowAnimationNone];
////                }
////            };
//
//        }];
//        modifyDpartRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];
//        editRowAction = modifyDpartRowAction;
//    }
//
//
//    UITableViewRowAction *moreRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"详情" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//        //详情
//        _currentOrgObj = item;
//
//    }];
//    moreRowAction.backgroundColor = [UIColor orangeColor];
//    return @[deleteRoWAction, editRowAction,moreRowAction];
//
//}


-(void)treeView:(WH_RATreeView *)treeView didSelectRowForItem:(id)item{
    if ([item isMemberOfClass:[WH_EmployeObject class]]){
        [self WH_showEmployeeDownListView:item];
    }else{
        WH_DepartObject * depart = item;
        if (depart.children.count == 0)
            [g_server showMsg:Localized(@"OrgaVC_DepartNoChild") delay:1.8];
    }
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(WH_RATreeView *)treeView cellForItem:(id)item
{
//    WH_Organiz_WHObject *dataObject = item;
    NSInteger level = [self.treeView levelForCellForItem:item];
//    NSInteger numberOfChildren = [dataObject.children count];
//    NSString *detailText = [NSString localizedStringWithFormat:@"Number of children %@", [@(numberOfChildren) stringValue]];
//    BOOL expanded = [self.treeView isCellForItemExpanded:item];

    if ([item isMemberOfClass:[WH_DepartObject class]]) {
        WH_DepartObject * dataObject = item;
        BOOL expanded = [self.treeView isCellForItemExpanded:item];
        WH_Organiz_WHTableViewCell * cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([WH_Organiz_WHTableViewCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setupWithData:dataObject level:level expand:expanded];
        
        __weak typeof(self) weakSelf = self;
        cell.additionButtonTapAction = ^(id sender){
            if (weakSelf.treeView.isEditing) {
                return;
            }
            [weakSelf showDepartDownListView:dataObject];
        };
        
        return cell;
    }else if ([item isMemberOfClass:[WH_EmployeObject class]]) {
        WH_EmployeObject * dataObject = item;
        WH_Employee_WHTableViewCell * cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([WH_Employee_WHTableViewCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setupWithData:dataObject level:level];
        
        return cell;
    }
    return nil;
}

- (NSInteger)treeView:(WH_RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.dataArray count];
    }
    
    if ([item isMemberOfClass:[WH_EmployeObject class]]) {
        return 0;
    }else{
        WH_DepartObject * dataObject = item;
        return [dataObject.children count];
    }
}

- (id)treeView:(WH_RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.dataArray objectAtIndex:index];
    }
    if ([item isMemberOfClass:[WH_EmployeObject class]]) {
        return nil;
    }else{
        WH_DepartObject * dataObject = item;
        return dataObject.children[index];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    self.rowActionAfterRequestBlock = nil;
}
#pragma mark - Actions

- (void)refreshControlChanged:(UIRefreshControl *)refreshControl
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}
#pragma mark 右上角更多
-(void)onMore:(UIButton *)sender{
//    _control.hidden = YES;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGRect moreFrame = [self.wh_tableHeader convertRect:_moreButton.frame toView:window];
    
    WH_JX_DownListView * downListView = [[WH_JX_DownListView alloc] initWithFrame:self.view.bounds];
    downListView.wh_listContents = @[Localized(@"OrgaVC_CreateNewCompany")];
    downListView.wh_listImages = @[@"me_press"];
    
    __weak typeof(self) weakSelf = self;
    [downListView WH_downlistPopOption:^(NSInteger index, NSString *content) {
        
        if (index == 0) {
            [weakSelf showAddCompanyView];
        }
        
    } whichFrame:moreFrame animate:YES];
    [downListView show];
    
//    self.treeView.editing = !self.treeView.editing;
}

-(void)showNoCompanyView{
    _noCompanyView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH-40, 200)];
    [self.wh_tableBody addSubview:_noCompanyView];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(_noCompanyView.width/2-128, 31, 256, 280)];
    img.image = [UIImage imageNamed:@"organztree"];
    [_noCompanyView addSubview:img];
    
    UILabel * noCompanyLabel = [[UILabel alloc] init];
    noCompanyLabel.frame = CGRectMake(0, 20+img.bottom, _noCompanyView.width, 20);
    noCompanyLabel.textAlignment = NSTextAlignmentCenter;
    noCompanyLabel.text = @"你还没有加入团队哦～";//Localized(@"OrgaVC_NoCompanyAlert");
    noCompanyLabel.textColor = HEXCOLOR(0x8F9CBB);
    [_noCompanyView addSubview:noCompanyLabel];
    
    UIButton * createButton = [UIButton buttonWithType:UIButtonTypeSystem];
    createButton.frame = CGRectMake(_noCompanyView.width/2-75, 20+noCompanyLabel.bottom, 150, 45);
    [createButton setTitle:@"创建团队" forState:UIControlStateNormal];
    //Localized(@"OrgaVC_GotoCreateCompany")
    [createButton setRadiu:10 color:nil];
    [createButton setBackgroundColor:THEMECOLOR];
    [createButton addTarget:self action:@selector(showAddCompanyView) forControlEvents:UIControlEventTouchUpInside];
    
    [_noCompanyView addSubview:createButton];
    _noCompanyView.height = createButton.bottom+20;
    
}
-(void)showAddCompanyView{
    [self inputViewController:OrganizAddCompany oldName:nil];
}
#pragma mark - 显示部门下拉列表
-(void)showDepartDownListView:(WH_DepartObject *)orgObject{
    _currentOrgObj = orgObject;
    NSInteger level = [self.treeView levelForCellForItem:orgObject];
    WH_Organiz_WHTableViewCell * cell = (WH_Organiz_WHTableViewCell *)[self.treeView cellForItem:orgObject];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
//    CGRect moreFrame = [self.treeView convertRect:cell.additionButton.frame toView:window];
    CGRect moreFrame = [window convertRect:cell.wh_additionButton.frame fromView:cell];
    
    NSDictionary * theCompany = _companyDict[orgObject.companyId];
    NSString * creatUserId = [NSString stringWithFormat:@"%@",theCompany[@"createUserId"]];
    BOOL permissions = [creatUserId isEqualToString:g_myself.userId] ? YES : NO;
    NSNumber * isCanOperate = [NSNumber numberWithBool:permissions];
    NSNumber * canOperate = [NSNumber numberWithBool:YES];
    
    WH_JX_DownListView * downListView = [[WH_JX_DownListView alloc] initWithFrame:self.view.bounds];
    if (level == 0) {
//        downListView.listContents = @[@"加部门",@"修改公司名",@"退出公司"];
        
        downListView.wh_listContents = @[Localized(@"OrgaVC_CreateDepart"),Localized(@"OrgaVC_UpdateCompany"),Localized(@"OrgaVC_QuitCompany")];
        downListView.wh_listEnables = @[isCanOperate,isCanOperate,canOperate];
        downListView.wh_listImages = @[@"me_press",@"me_press",@"me_press",@"me_press"];
    } else {
//        downListView.listContents = @[@"加部门",@"加员工",@"改部门名",@"删除"];
        downListView.wh_listContents = @[Localized(@"OrgaVC_CreateDepart"),Localized(@"OrgaVC_CreateEmployee"),Localized(@"OrgaVC_UpdaeDepart"),Localized(@"JX_Delete")];
        downListView.wh_listEnables = @[isCanOperate,canOperate,isCanOperate,isCanOperate];
        downListView.wh_listImages = @[@"me_press",@"me_press",@"me_press",@"me_press"];
    }
    
    __weak typeof(self) weakSelf = self;
    [downListView WH_downlistPopOption:^(NSInteger index, NSString *content) {
        
        if (level == 0) {
            if (index == 0) {
                [weakSelf WH_addDepartWithParent:orgObject];
            }else if (index == 1) {
                [weakSelf modifyCompanyNameWith:orgObject];
            }else if (index == 2 || index == 3) {
                [weakSelf quitCompanyWith:orgObject];
            }
        }else{
            switch (index) {
                case 0:{
                    [weakSelf WH_addDepartWithParent:orgObject];
                    break;
                }
                case 1:{
                    [weakSelf WH_chooseEmployeeWithParent:orgObject];
                    break;
                }
                case 2:{
                    [weakSelf WH_changeDepartNameWithParent:orgObject];
                    break;
                }
                case 3:{
                    [weakSelf deleteNodeWithItem:orgObject];
                    break;
                }
                default:
                    break;
            }
        }
    } whichFrame:moreFrame animate:YES];
    [downListView show];
}

#pragma mark - 显示员工下拉列表
-(void)WH_showEmployeeDownListView:(WH_EmployeObject *)empObject{
    _currentOrgObj = empObject;
//    NSInteger level = [self.treeView levelForCellForItem:empObject];
    WH_Employee_WHTableViewCell * cell = (WH_Employee_WHTableViewCell *)[self.treeView cellForItem:empObject];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    //    CGRect moreFrame = [self.treeView convertRect:cell.additionButton.frame toView:window];
    CGRect cellFrame = [window convertRect:cell.contentView.frame fromView:cell];
    CGRect listFrame = CGRectMake(cellFrame.size.width-20-22, cellFrame.origin.y +20, 22, 22);
    
    NSDictionary * theCompany = _companyDict[empObject.companyId];
    NSString * creatUserId = [NSString stringWithFormat:@"%@",theCompany[@"createUserId"]];
    BOOL permissions = [creatUserId isEqualToString:g_myself.userId] ? YES : NO;
    NSNumber * isCanOperate = [NSNumber numberWithBool:permissions];
    NSNumber * canOperate = [NSNumber numberWithBool:YES];
    BOOL employeeSelf = [empObject.userId isEqualToString:g_myself.userId] ? YES : NO;
    BOOL isCanModifyPosition = (permissions || employeeSelf);
    
    WH_JX_DownListView * downListView = [[WH_JX_DownListView alloc] initWithFrame:self.view.bounds];
    
    downListView.wh_listContents = @[Localized(@"OrgaVC_EmployeeDetail"),Localized(@"OrgaVC_EmployeeChangeDepart"),Localized(@"OrgaVC_ModifyEmployeePosition"),Localized(@"JX_Delete")];
    downListView.wh_listEnables = @[canOperate,isCanOperate,[NSNumber numberWithBool:isCanModifyPosition],isCanOperate];
    downListView.wh_listImages = @[@"me_press",@"me_press",@"me_press",@"me_press"];
    
    __weak typeof(self) weakSelf = self;
    [downListView WH_downlistPopOption:^(NSInteger index, NSString *content) {
        
            switch (index) {
                case 0:{
                    [weakSelf employeeDetailWith:empObject];
                    break;
                }
                case 1:{
                    [weakSelf employChangeDepartWith:empObject];
                    break;
                }
                case 2:{
                    [weakSelf modifyEmployeePositionWith:empObject];
                    break;
                }
                case 3:{
                    [weakSelf deleteNodeWithItem:empObject];
                    break;
                }
                default:
                    break;
            }
        
    } whichFrame:listFrame animate:YES];
    [downListView show];
}
//-(void)addChooseTypeView:(DepartObject *)orgObject
//{//原下拉
//    _currentOrgObj = orgObject;
//    NSInteger level = [self.treeView levelForCellForItem:orgObject];
//    
//    WH_Organiz_WHTableViewCell * cell = (WH_Organiz_WHTableViewCell *)[self.treeView cellForItem:orgObject];
//    CGRect frame = [self.treeView convertRect:cell.additionButton.frame fromView:cell];
//    
//    _control = [[UIControl alloc] initWithFrame:self.treeView.frame];
//    [_control addTarget:self action:@selector(hiddenAddView:) forControlEvents:UIControlEventAllEvents];
//    [self.treeView addSubview:_control];
//    
//    UIView * departView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x-60, CGRectGetMaxY(frame), 70, 35)];
//    departView.backgroundColor = [UIColor orangeColor];
//    departView.tag = 10;
//    [_control addSubview:departView];
//    if (level != 0) {
//        UIView * employeeView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x-60, CGRectGetMaxY(departView.frame), 70, 35)];
//        employeeView.backgroundColor = [UIColor redColor];
//        employeeView.tag = 11;
//        [_control addSubview:employeeView];
//        
//        UILabel * employeeLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, 0, CGRectGetWidth(employeeView.frame), CGRectGetHeight(employeeView.frame)) text:@"+员工" font:sysFontWithSize(17) textColor:[UIColor blackColor] backgroundColor:nil];
//        [employeeView addSubview:employeeLabel];
//        UITapGestureRecognizer * empGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseType:)];
//        [employeeView addGestureRecognizer:empGes];
//    }
//    
//    UILabel * departLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(0, 0, CGRectGetWidth(departView.frame), CGRectGetHeight(departView.frame)) text:@"+部门" font:sysFontWithSize(17) textColor:[UIColor blackColor] backgroundColor:nil];
//    [departView addSubview:departLabel];
//    
//    UITapGestureRecognizer * depGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseType:)];
//    
//    [departView addGestureRecognizer:depGes];
//    
//}
//
//-(void)hiddenAddView:(UIControl *) control{
//    if (control == _control) {
//        _control.hidden = YES;
//    }
//    
//}

//-(void)chooseType:(UIGestureRecognizer *)ges{
//    UIView * view = ges.view;
//    NSInteger i = view.tag;
//    _control.hidden = YES;
//    switch (i) {
//        case 10:{
//            //新部门
//            [self inputViewController:OrganizAddDepartment];
//            break;
//        }
//        case 11:{
//            //新员工
//            WH_JXSelFriend_WHVC * addEmployeeVC = [[WH_JXSelFriend_WHVC alloc] init];
//            addEmployeeVC.delegate = self;
//            addEmployeeVC.didSelect = @selector(WH_addEmployeeWithIdArr:);
//            [g_window addSubview:addEmployeeVC.view];
//            break;
//        }
//        default:
//            break;
//    }
//}
#pragma mark - Row下拉列表操作
/** 加部门 */
-(void)WH_addDepartWithParent:(WH_DepartObject *)orgObject{
    
    WH_Organiz_WHTableViewCell * cell = (WH_Organiz_WHTableViewCell *)[self.treeView cellForItem:orgObject];
    if (!cell.wh_arrowExpand) {
        cell.wh_arrowExpand = YES;
        [self.treeView expandRowForItem:orgObject expandChildren:NO withRowAnimation:RATreeViewRowAnimationNone];
    }
    
    [self inputViewController:OrganizAddDepartment oldName:nil];
    
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        NSDictionary * departData = sender;
        WH_DepartObject * childDepart = [WH_DepartObject WH_departmentObjectWith:departData allData:nil];
        
        [orgObject WH_addChild:childDepart];
        [weakSelf.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:orgObject withAnimation:RATreeViewRowAnimationLeft];
        [weakSelf.treeView reloadRowsForItems:@[orgObject] withRowAnimation:RATreeViewRowAnimationNone];
        
    };
}
/** 改部门名 */
-(void)WH_changeDepartNameWithParent:(WH_DepartObject *)orgObject{
    [self inputViewController:OrganizUpdateDepartmentName oldName:orgObject.departName];

    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        NSDictionary * dataDict = sender;
        if (dataDict[@"departName"] != nil && [dataDict[@"departName"] length] >0) {
            orgObject.departName = dataDict[@"departName"];
            [weakSelf.treeView reloadRowsForItems:@[orgObject] withRowAnimation:RATreeViewRowAnimationNone];
        }
    };
}
/** 加员工 */
-(void)WH_chooseEmployeeWithParent:(WH_DepartObject *)orgObject{
    
    WH_Organiz_WHTableViewCell * cell = (WH_Organiz_WHTableViewCell *)[self.treeView cellForItem:orgObject];
    if (!cell.wh_arrowExpand) {
        cell.wh_arrowExpand = YES;
        [self.treeView expandRowForItem:orgObject expandChildren:NO withRowAnimation:RATreeViewRowAnimationNone];
    }
    
    WH_JXSelectFriends_WHVC * addEmployeeVC = [[WH_JXSelectFriends_WHVC alloc] init];
    addEmployeeVC.delegate = self;
    addEmployeeVC.didSelect = @selector(addEmployeeDelegate:);
    NSMutableSet * existSet = _employeesDict[orgObject.companyId];
    addEmployeeVC.existSet = existSet;
    
//    [g_window addSubview:addEmployeeVC.view];
    [g_navigation pushViewController:addEmployeeVC animated:YES];
    
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray * dataArray = sender;
            NSMutableArray * employeeObjArr = [NSMutableArray array];
            for (NSDictionary * child in dataArray) {
                if (child[@"userId"] != nil) {
                    WH_EmployeObject * employ = [WH_EmployeObject employWithDict:child];
                    [employeeObjArr addObject:employ];
                }
            }
            
            NSMutableIndexSet * addRowIndex = [NSMutableIndexSet indexSet];
            for (int i = 0; i<employeeObjArr.count; i++) {
                WH_EmployeObject * allEmp = employeeObjArr[i];
                BOOL isAdd = NO;
                for (int j = 0; j<orgObject.employees.count; j++) {
                    WH_EmployeObject * oldEmp = orgObject.employees[j];
                    if ([oldEmp isKindOfClass:[WH_EmployeObject class]]) {
                        if ([oldEmp.userId intValue] == [allEmp.userId intValue]) {
                            isAdd = YES;
                        }
                    }
                }
                if (!isAdd){
                    [addRowIndex addIndex:i];
                    NSMutableSet * existSet = weakSelf.employeesDict[orgObject.companyId];
                    [existSet addObject:allEmp.userId];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //        NSInteger oldCount = orgObject.employees.count;
                orgObject.employees = employeeObjArr;
//                [weakSelf.treeView beginUpdates];
                
                [weakSelf.treeView insertItemsAtIndexes:addRowIndex inParent:orgObject withAnimation:RATreeViewRowAnimationRight];
                //        [weakSelf.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(orgObject.departes.count, employeeObjArr.count)] inParent:orgObject withAnimation:RATreeViewRowAnimationLeft];
                [weakSelf.treeView reloadRowsForItems:@[orgObject] withRowAnimation:RATreeViewRowAnimationRight];
//                [weakSelf.treeView endUpdates];
            });
            

        });

    };
}

/** 删除节点 */
-(void)deleteNodeWithItem:(id)item{
    self.item = item;
    WH_DepartObject *parent = [self.treeView parentForItem:item];
    NSUInteger index = 0;
    if ([item isKindOfClass:[WH_EmployeObject class]]) {
        for (id obj in parent.children) {
            WH_EmployeObject *employe = (WH_EmployeObject *)obj;
            WH_EmployeObject *employeItem = (WH_EmployeObject *)item;
            if ([employe isKindOfClass:[WH_EmployeObject class]]) {
                if ([employe.userId intValue] == [employeItem.userId intValue]) {
                    index = [parent.children indexOfObject:employe];
                }
            }
        }
    }else {
        index = [parent.children indexOfObject:item];
    }
    
//    if ([[[parent.children valueForKey:@"empNum"] objectAtIndex:index] intValue] > 0) {
    if (index < parent.children.count) {
        if ([[parent.children objectAtIndex:index] isKindOfClass:[WH_DepartObject class]]) {
            WH_DepartObject *dPar = (WH_DepartObject *)[parent.children objectAtIndex:index];
            if (dPar.children.count > 0) {
                [self deleteObject:dPar parent:parent];
                if (self.isNotDele) {
                    //不能删除公司创建人所在部门
                    [g_server showMsg:Localized(@"JX_YouCannotDelete")];
                    return;
                }
            }
            if (dPar.empNum > 0) {
                //该部门有成员,确认要删除
                [g_App showAlert:Localized(@"JX_ConfirmToBeDeleted") delegate:self tag:2001 onlyConfirm:NO];
            }else {
                [self deleNode];
            }
        }else {
            WH_EmployeObject *emObj = (WH_EmployeObject *)[parent.children objectAtIndex:index];
            if ([emObj.userId intValue] == [parent.createUserId intValue]) {
                //不能删除公司创建人
                [g_server showMsg:Localized(@"JX_Can'tDelete")];
                return;
            }
            [self deleNode];
        }
    }
}

- (void)deleteObject:(WH_DepartObject *)dPar parent:(WH_DepartObject *)parent {
    for (id obj in dPar.children) {
        if ([obj isKindOfClass:[WH_EmployeObject class]]) {
            WH_EmployeObject *employe = (WH_EmployeObject *)obj;
            if ([employe.userId intValue] == [parent.createUserId intValue]) {
                self.isNotDele = YES;
            }
        }else if ([obj isKindOfClass:[WH_DepartObject class]]){
            WH_DepartObject *depart = (WH_DepartObject *)obj;
            self.isNotDele = NO;
            [self deleteObject:depart parent:parent];
        }
    }
}

- (void)deleNode {
    WH_DepartObject *parent = [self.treeView parentForItem:self.item];
    
    if ([self.item isMemberOfClass:[WH_EmployeObject class]]) {
        WH_EmployeObject * employee = self.item;
        [g_server WH_deleteEmployeeWithDepartmentId:employee.departmentId userId:employee.userId toView:self];
    }else if ([self.item isMemberOfClass:[WH_DepartObject class]]) {
        WH_DepartObject * depart = self.item;
        [g_server WH_deleteDepartmentWithId:depart.departId toView:self];
    }
    
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        NSInteger index = 0;
        if (parent == nil) {
            index = [self.dataArray indexOfObject:self.item];
            NSMutableArray *children = [weakSelf.dataArray mutableCopy];
            [children removeObject:weakSelf.item];
            weakSelf.dataArray = [children copy];
        } else {
//            index = [parent.children indexOfObject:self.item];
            if ([weakSelf.item isKindOfClass:[WH_EmployeObject class]]) {
                for (id obj in parent.children) {
                    WH_EmployeObject *employe = (WH_EmployeObject *)obj;
                    WH_EmployeObject *employeItem = (WH_EmployeObject *)weakSelf.item;
                    if ([employe isKindOfClass:[WH_EmployeObject class]]) {
                        if ([employe.userId intValue] == [employeItem.userId intValue]) {
                            index = [parent.children indexOfObject:employe];
                        }
                    }
                }
            }else {
                index = [parent.children indexOfObject:weakSelf.item];
            }

            [parent WH_removeChild:weakSelf.item];
            if ([weakSelf.item isMemberOfClass:[WH_EmployeObject class]]) {
                WH_EmployeObject * employee = weakSelf.item;
                NSMutableSet * emplySet = [weakSelf.employeesDict objectForKey:employee.companyId];
                [emplySet removeObject:employee.userId];
            }
        }
        if (index < parent.children.count) {
            [weakSelf.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:RATreeViewRowAnimationRight];
            if (parent) {
                [weakSelf.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
            }
        }
    };
}

/** 员工详情 */
-(void)employeeDetailWith:(WH_EmployeObject *)employObj{
//    [g_server getUser:employObj.userId toView:self];
    WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
    vc.wh_userId       = employObj.userId;
    vc.wh_fromAddType = 6;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
}

/** 更改员工部门 */
-(void)employChangeDepartWith:(WH_EmployeObject *)employObj{
    
    [self showChooseDepartCurrent:employObj];
}

/** 修改员工职位 */
-(void)modifyEmployeePositionWith:(WH_EmployeObject *)employObj{
    [self inputViewController:OrganizModifyEmployeePosition oldName:employObj.position];
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        NSDictionary * dataDict = sender;
        if (dataDict[@"position"] != nil && [dataDict[@"position"] length] >0) {
            employObj.position = dataDict[@"position"];
            [weakSelf.treeView reloadRowsForItems:@[employObj] withRowAnimation:RATreeViewRowAnimationFade];
        }
    };
    
}

/** 修改公司名 */
-(void)modifyCompanyNameWith:(WH_DepartObject *)orgObject{
    [self inputViewController:OrganizUpdateCompanyName oldName:orgObject.departName];
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        NSDictionary * dataDict = sender;
        if (dataDict[@"companyName"] != nil && [dataDict[@"companyName"] length] >0) {
            orgObject.departName = dataDict[@"companyName"];
            [weakSelf.treeView reloadRowsForItems:@[orgObject] withRowAnimation:RATreeViewRowAnimationNone];
        }
    };
}
/** 解散公司/退出公司 */
-(void)quitCompanyWith:(WH_DepartObject *)orgObject{
    UIAlertView * alert = [g_App showAlert:Localized(@"OrgaVC_ConfirmQuit") delegate:self];
    alert.tag = 1001;
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        
//        if (weakSelf.afterDelCompany) {
            NSMutableArray * mutaArray = [weakSelf.dataArray mutableCopy];
        for (int i=0; i<mutaArray.count; i++) {
            WH_DepartObject * rootDep = mutaArray[i];
            if ([rootDep.companyId isEqualToString:orgObject.companyId])
                [mutaArray removeObject:rootDep];
        }
            weakSelf.dataArray = mutaArray;
//            weakSelf.afterDelCompany = NO;
            [weakSelf.treeView reloadData];
//        }else{
//            
//        }
    };
}



#pragma mark 跳输入VC
-(void)inputViewController:(OrganizAddType) type oldName:(NSString *)oldName{
    WH_JXAddDepart_WHViewController * addDepartVC = [[WH_JXAddDepart_WHViewController alloc] init];
    addDepartVC.delegate = self;
    addDepartVC.type = type;
    addDepartVC.oldName = oldName;
//    [g_window addSubview:addDepartVC.view];
    [g_navigation pushViewController:addDepartVC animated:YES];
}

#pragma mark 选择新部门
-(void)showChooseDepartCurrent:(WH_EmployeObject *)employeeObj{
    NSString * parentId = employeeObj.departmentId;
//    NSDictionary * empDepart = _allDataDict[parentId];
    NSDictionary * rootDict = nil;
    while (parentId.length > 0) {
        NSDictionary * parObj = _allDataDict[parentId];
        if (parObj[@"parentId"])
            parentId = parObj[@"parentId"];
        else{
            rootDict = parObj;
            break;
            parentId = nil;
        }
    }
    NSString * rootId = rootDict[@"id"];
    WH_DepartObject * rootDepart = nil;
    for (WH_DepartObject * root in _dataArray) {
        if ([root.departId isEqualToString:rootId]){
            rootDepart = root;
            break;
        }
    }
    
    WH_JXSelDepart_WHViewController * selDepartVC = [[WH_JXSelDepart_WHViewController alloc] init];
    selDepartVC.delegate = self;
    selDepartVC.wh_oldDepart = [self.treeView parentForItem:employeeObj];
    selDepartVC.wh_dataArray = @[rootDepart];
//    [g_window addSubview:selDepartVC.view];
    [g_navigation pushViewController:selDepartVC animated:YES];
    
}
#pragma mark alertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
//            [g_server WH_deleteCompanyWithCompanyId:_companyId userId:g_myself.userId toView:self];

            WH_DepartObject * orgObject = _currentOrgObj;
            [g_server WH_quitCompanyWithCompanyId:orgObject.companyId toView:self];
        }else{
            self.rowActionAfterRequestBlock = nil;
        }
    }else if (alertView.tag == 2001) {
        if (buttonIndex == 1) {
            [self deleNode];
        }else{

        }
    }
}

#pragma mark - input delegate

-(void)inputDelegateType:(OrganizAddType)organizType text:(NSString *)updateStr{
    
    switch (organizType) {
        case OrganizAddCompany:
        case OrganizSearchCompany:{
            [self addCompanyDelegate:updateStr];
            break;
        }
        case OrganizAddDepartment:{
            [self addDepartDelegate:updateStr];
            break;
        }
        case OrganizUpdateCompanyName:{
            [self updateCompanyNameDelegate:updateStr];
            break;
        }
        case OrganizUpdateDepartmentName:{
            [self updateDepartmentNameDelegate:updateStr];
            break;
        }
        case OrganizModifyEmployeePosition:{
            [self modifyEmployeePositionDelegate:updateStr];
        }
        default:
            break;
    }
}

#pragma mark 加部门
-(void)addDepartDelegate:(NSString *)departName{
    WH_DepartObject * dataObject = _currentOrgObj;
//    [_wait start:@"正在添加部门"];
    [g_server WH_createDepartmentWithCompanyId:dataObject.companyId parentId:dataObject.departId departName:departName createUserId:nil toView:self];
}
#pragma mark 加公司
-(void)addCompanyDelegate:(NSString *)companyName{
//    [_wait start:@"创建公司"];
    [g_server WH_createCompanyWithCompanyName:companyName toView:self];
    if (_noCompanyView)
        _noCompanyView.hidden = YES;
}
#pragma mark 部门改名
-(void)updateDepartmentNameDelegate:(NSString *)departNewName{
    WH_DepartObject * departObj = _currentOrgObj;
    [g_server WH_updataCompanyDepartmentNameWithName:departNewName departmentId:departObj.departId toView:self];
}

#pragma mark 员工改职位
-(void)modifyEmployeePositionDelegate:(NSString *)positionStr{
    WH_EmployeObject * employeeObj = _currentOrgObj;
    [g_server WH_modifyPosition:positionStr companyId:employeeObj.companyId userId:employeeObj.userId toView:self];
}
#pragma mark 公司改名
-(void)updateCompanyNameDelegate:(NSString *)companyName{
    WH_DepartObject * departObj = _currentOrgObj;
    [g_server WH_updataCompanyNameWithCompanyName:companyName companyId:departObj.companyId toView:self];
}

#pragma mark 加员工
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
        WH_DepartObject * dataObj = _currentOrgObj;
        [g_server WH_addEmployeeWithIdArr:adduserArr companyId:dataObj.companyId departmentId:dataObj.departId roleArray:nil toView:self];
    }
    
}

#pragma mark - selDepart Delegate
-(void)selNewDepartmentWith:(WH_DepartObject *)newDepart{
    WH_EmployeObject * employeeOBJ = _currentOrgObj;
    [g_server WH_modifyDpartWithUserId:employeeOBJ.userId companyId:employeeOBJ.companyId newDepartmentId:newDepart.departId toView:self];
    
    WH_Organiz_WHTableViewCell * cell = (WH_Organiz_WHTableViewCell *)[self.treeView cellForItem:newDepart];
    if (!cell.wh_arrowExpand) {
        cell.wh_arrowExpand = YES;
        [self.treeView expandRowForItem:newDepart expandChildren:NO withRowAnimation:RATreeViewRowAnimationNone];
    }
    
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
//        NSDictionary * dict = sender;
        WH_DepartObject * oldDepart = [weakSelf.treeView parentForItem:employeeOBJ];
//        NSString * newDepartId = dict[@"departmentId"];
//        NSInteger index = [weakSelf.treeView indexOfAccessibilityElement:employeeOBJ];
        NSInteger index = [oldDepart.children indexOfObject:employeeOBJ];
        
//        [weakSelf.treeView beginUpdates];
        [newDepart WH_addChild:employeeOBJ];
        [oldDepart WH_removeChild:employeeOBJ];
//        [weakSelf.treeView moveItemAtIndex:index inParent:oldDepart toIndex:0 inParent:newDepart];
        [weakSelf.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:newDepart withAnimation:RATreeViewRowAnimationNone];
        if (index < 0 || index > (oldDepart.children.count + 1)) {
            [weakSelf.treeView reloadData];
        }else {
            [weakSelf.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:oldDepart withAnimation:RATreeViewRowAnimationNone];
        }
        
        
//        [weakSelf.treeView reloadRowsForItems:@[newDepart,oldDepart] withRowAnimation:RATreeViewRowAnimationNone];
////        [weakSelf.treeView collapseRowForItem:newDepart collapseChildren:NO withRowAnimation:RATreeViewRowAnimationLeft];
////        [weakSelf.treeView expandRowForItem:newDepart expandChildren:YES withRowAnimation:RATreeViewRowAnimationLeft];
//        [weakSelf.treeView endUpdates];
        
        //        [weakSelf.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:<#(NSUInteger)#>] inParent:oldDepart withAnimation:RATreeViewRowAnimationAutomatic];
    };
}

-(void)expandAllRows{
    for (WH_DepartObject * depart in _dataArray) {
        if (!depart.parentId.length) {
            [_treeView expandRowForItem:depart expandChildren:NO withRowAnimation:RATreeViewRowAnimationAutomatic];
        }
    }
    [_treeView reloadRows];
}

#pragma mark 获取数据后处理及刷新
/** 自动获取公司成树后reload */
-(void)autoConstructTreeView:(NSArray *)originalArray{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray * array = [self getRootArray:originalArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            _dataArray = [NSMutableArray arrayWithArray:array];
            if (_dataArray.count > 0){
                [_treeView reloadData];
                [self performSelector:@selector(expandAllRows) withObject:nil afterDelay:0.1f];

//                for (DepartObject * depart in _dataArray) {
//                    [_treeView expandRowForItem:depart expandChildren:YES withRowAnimation:RATreeViewRowAnimationRight];
//                }
            }
        });
    });
}

/** 创建公司后拉取列表,将新数据加入dataArray,reload */
-(void)addCompanyTreeView:(NSArray *)originalArray{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray * array = [self constructDepartObject:originalArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (array.count > 0){
                [_dataArray addObjectsFromArray:array];
                [_treeView reloadData];
                for (WH_DepartObject * depart in array) {
                    [_treeView expandRowForItem:depart expandChildren:YES withRowAnimation:RATreeViewRowAnimationRight];
                }
            }
        });
    });
}


#pragma mark 数据成树
/** 所有公司数据 */
-(NSArray <WH_DepartObject *>*) getRootArray:(NSArray *)originalArray{
    NSMutableArray * rootArr = [[NSMutableArray alloc] init];
    for (NSDictionary * companyDict in originalArray) {
        [_companyDict setObject:companyDict forKey:companyDict[@"id"]];
        NSArray * compRootDepartArr = [self constructCompanyObject:companyDict];
        [rootArr addObjectsFromArray:compRootDepartArr];
    }
    return rootArr;
}

/** 公司实体数据 - 返回根部门数组 */
-(NSArray <WH_DepartObject *>*) constructCompanyObject:(NSDictionary *)companyDict{
    NSArray *departDictArr = companyDict[@"departments"];
//    NSArray * rootDpartArr = companyDict[@"rootDpartId"];
    return [self constructDepartObject:departDictArr];
}
/** 部门列表 */
-(NSArray <WH_DepartObject *>*) constructDepartObject:(NSArray *)departArray{
    NSMutableArray * rootArr = [[NSMutableArray alloc] init];
    NSMutableDictionary * allDataDict = [NSMutableDictionary new];
    NSMutableArray *allDataArr = [NSMutableArray array];
    for (NSDictionary * departData in departArray) {
        if (!departData[@"parentId"]) {
            [rootArr addObject:departData];
            if (![_employeesDict objectForKey:departData[@"companyId"]])
                [_employeesDict setObject:[NSMutableSet set] forKey:departData[@"companyId"]];
        }
        [allDataDict setObject:departData forKey:departData[@"id"]];
        [allDataArr addObject:departData];
    }
    
    //
    for (NSDictionary *departData in departArray) {
        if (departData[@"employees"]) {
            NSMutableSet * emplySet = [_employeesDict objectForKey:departData[@"companyId"]];
            NSArray * emplArr = departData[@"employees"];
            for (NSDictionary * emp in emplArr) {
                if (emp[@"departmentId"] != nil && emp[@"userId"] != nil)
                    [emplySet addObject:[NSString stringWithFormat:@"%@",emp[@"userId"]]];
            }
        }
    }
    
    NSMutableArray * departArr = [[NSMutableArray alloc] init];
    for (NSDictionary * rootData in rootArr) {
        WH_DepartObject * departObj  = [WH_DepartObject WH_departmentObjectWith:rootData allData:allDataArr];
        [departArr addObject:departObj];
    }
    [_allDataDict addEntriesFromDictionary:allDataDict];
    return departArr;
}


//-(void)constructDepartmentTreeObjectArray:(NSArray *) originalArray{
//    NSMutableArray * rootArr = [[NSMutableArray alloc] init];
//    for (NSDictionary * departData in originalArray) {
//        if (!departData[@"parentId"]) {
//            [rootArr addObject:departData];
//        }
//        [_allDataDict setObject:departData forKey:departData[@"id"]];
//        if (departData[@"employees"]) {
//            NSArray * emplArr = departData[@"employees"];
//            for (NSDictionary * emp in emplArr) {
//                if (emp[@"departmentId"] != nil && emp[@"userId"] != nil)
//                    [_employeesDict setObject:emp[@"departmentId"] forKey:emp[@"userId"]];
//            }
//        }
//    }
//    NSMutableArray * departArr = [[NSMutableArray alloc] init];
//    for (NSDictionary * rootData in rootArr) {
//        DepartObject * departObj  = [DepartObject WH_departmentObjectWith:rootData allData:_allDataDict];
//        [departArr addObject:departObj];
//    }
//    _dataArray = departArr;
//}

#pragma mark 选中公司,设置当前公司显示
//-(void)setUIDataWith:(NSDictionary *)companyDict{
//    _companyId = companyDict[@"id"];
//    _companyName = companyDict[@"companyName"];
//    self.title = _companyName;
//}
#pragma mark - **数据请求**
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
//    [self stopLoading];
    
    if([aDownload.action isEqualToString:wh_act_getCompany]){//自动查找公司
        if (!array1) {
            //没有公司
            [self showNoCompanyView];
//            if (!_afterDelCompany)
//                [self showAddCompanyView];
        }else{
            [self autoConstructTreeView:array1];
        }
        
    }else if ([aDownload.action isEqualToString:wh_act_creatCompany]) {//创建公司
        if (_noCompanyView)
            [_noCompanyView removeFromSuperview];
//        [self setUIDataWith:dict];
        
        [g_server showMsg:Localized(@"OrgaVC_CreateCompanySuccess") delay:1.0];
        if ([dict[@"id"] length] > 0) {
            [_companyDict setObject:dict forKey:dict[@"id"]];
            [g_server WH_getDepartmentListPageWithPageIndex:[NSNumber numberWithInt:0] companyId:dict[@"id"] toView:self];
        }
    }else if ([aDownload.action isEqualToString:wh_act_departmentList]) {//部门列表
        [self addCompanyTreeView:array1];

    }else if ([aDownload.action isEqualToString:wh_act_addEmployee]) {//添加员工
        [g_server showMsg:Localized(@"OrgaVC_AddEmployeeSuccess") delay:1.0];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(array1);
        }
        
    }else if([aDownload.action isEqualToString:wh_act_deleteEmployee]) {//删除员工
        [g_server showMsg:Localized(@"OrgaVC_DelEmployeeSuccess") delay:1.0];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(wh_act_deleteEmployee);
        }
        
    }else if ([aDownload.action isEqualToString:wh_act_modifyDpart]) {//更改员工部门
        @try {
            [g_server showMsg:Localized(@"OrgaVC_ModifyEmployeeSuccess") delay:1.0];
            if (self.rowActionAfterRequestBlock) {
                self.rowActionAfterRequestBlock(dict);
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    }else if([aDownload.action isEqualToString:wh_act_deleteDepartment]) {//删除部门
        [g_server showMsg:Localized(@"OrgaVC_DelDepartSuccess") delay:1.0];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(wh_act_deleteDepartment);
        }
    }else if([aDownload.action isEqualToString:wh_act_deleteCompany]) {//删除公司
//        [g_server showMsg:@"删除公司成功" delay:2.0];
//        _afterDelCompany = YES;
//        [self.dataArray removeAllObjects];
//        [self.treeView reloadData];
//        [g_server WH_getAutoSearchCompany:self];
    }else if([aDownload.action isEqualToString:wh_act_companyQuit]) {//退出公司/解散公司
        [g_server showMsg:Localized(@"OrgaVC_CompanyQuitSuccess") delay:1.0];
//        _afterDelCompany = YES;
//        [self.dataArray removeAllObjects];
//        [self.treeView reloadData];
//        [g_server WH_getAutoSearchCompany:self];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(nil);
        }
        
    }else if([aDownload.action isEqualToString:wh_act_createDepartment]) {//创建部门
        [g_server showMsg:Localized(@"OrgaVC_CreateDepartSuccess") delay:1.0];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(dict);
        }
        
    }else if([aDownload.action isEqualToString:wh_act_updataDepartmentName]) {//修改部门名称
        [g_server showMsg:Localized(@"OrgaVC_UpdateDepartNameSuccess") delay:1.0];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(dict);
        }
    }else if([aDownload.action isEqualToString:wh_act_updataCompanyName]) {//修改公司名
        [g_server showMsg:Localized(@"OrgaVC_UpdateCompanyNameSuccess") delay:1.0];
//        [self setUIDataWith:dict];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(dict);
        }
    }else if([aDownload.action isEqualToString:wh_act_dpartmentInfo]) {//部门详情
        
    }else if([aDownload.action isEqualToString:wh_act_UserGet]){//员工详情
        WH_JXUserObject* user = [[WH_JXUserObject alloc]init];
        [user WH_getDataFromDict:dict];
        
        WH_JXUserInfo_WHVC* vc = [WH_JXUserInfo_WHVC alloc];
        vc.wh_user       = user;
        vc.wh_fromAddType = 6;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }else if ([aDownload.action isEqualToString:wh_act_modifyPosition]){//修改员工职位
        [g_server showMsg:Localized(@"OrgaVC_ModifyEmployeePositionSuccess") delay:1.0];
        if (self.rowActionAfterRequestBlock) {
            self.rowActionAfterRequestBlock(dict);
        }
    }
    
    
//    else if ([aDownload.action isEqualToString:]) {
//        
//    }
}

#pragma mark -
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    self.rowActionAfterRequestBlock = nil;
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    self.rowActionAfterRequestBlock = nil;
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_wait start];
    });
}

@end
