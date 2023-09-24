//
//  WH_JXSelDepart_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 17/6/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXSelDepart_WHViewController.h"
#import "WH_DepartObject.h"
#import "WH_RATreeView.h"
#import "WH_Organiz_WHTableViewCell.h"

@interface WH_JXSelDepart_WHViewController ()<RATreeViewDelegate, RATreeViewDataSource>

@property (nonatomic, weak) WH_RATreeView * treeView;
@end

@implementation WH_JXSelDepart_WHViewController

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
    }
    return self;
}
//-(void)setDataArray:(NSArray *)dataArray{
//    for (int i = 0; i<dataArray.count; i++) {
//        DepartObject * depart = dataArray[i];
//        depart
//    }
//}
// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    [self createHeadAndFoot];
    
    [self WH_create_WHTreeView];
    
    if (_wh_dataArray.count > 0){
        [_treeView reloadData];
        for (WH_DepartObject * depart in _wh_dataArray) {
            [_treeView expandRowForItem:depart expandChildren:YES withRowAnimation:RATreeViewRowAnimationRight];
        }
    }
}

-(void)WH_create_WHTreeView{
    WH_RATreeView *treeView = [[WH_RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStylePlain];
    
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.treeFooterView = [UIView new];
    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    
    //    UIRefreshControl *refreshControl = [UIRefreshControl new];
    //    [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    //    [treeView.scrollView addSubview:refreshControl];
    
//    [treeView reloadData];
    [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    
    
    self.treeView = treeView;
    treeView.frame = self.wh_tableBody.bounds;
    treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.wh_tableBody addSubview:treeView];
    
    [treeView registerClass:[WH_Organiz_WHTableViewCell class] forCellReuseIdentifier:NSStringFromClass([WH_Organiz_WHTableViewCell class])];
    
}

#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(WH_RATreeView *)treeView heightForRowForItem:(id)item
{
    return 44;
}

- (BOOL)treeView:(WH_RATreeView *)treeView shouldExpandRowForItem:(id)item{
    return NO;
}
- (BOOL)treeView:(WH_RATreeView *)treeView shouldCollapaseRowForItem:(id)item{
    return NO;
}

-(void)treeView:(WH_RATreeView *)treeView didSelectRowForItem:(id)item{
    WH_DepartObject * depart = item;
    if (depart.parentId) {
        [self chooesDepartment:item];
    }
    
//    if (depart.children.count == 0)
//        [g_server showMsg:Localized(@"OrgaVC_DepartNoChild") delay:1.8];
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(WH_RATreeView *)treeView cellForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    //    NSInteger numberOfChildren = [dataObject.children count];

    WH_DepartObject * dataObject = item;
    BOOL expanded = [self.treeView isCellForItemExpanded:item];
    WH_Organiz_WHTableViewCell * cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([WH_Organiz_WHTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setupWithData:dataObject level:level expand:expanded];
    cell.wh_additionButton.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    cell.additionButtonTapAction = ^(id sender){
        if (weakSelf.treeView.isEditing) {
            return;
        }
        [weakSelf chooesDepartment:item];
        //            [weakSelf showDepartDownListView:dataObject];
    };
    
    return cell;
    
}

- (NSInteger)treeView:(WH_RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.wh_dataArray count];
    }
    
    if ([item isMemberOfClass:[WH_DepartObject class]]) {
        WH_DepartObject * dataObject = item;
        return [dataObject.departes count];
    }else{
        return 0;
    }
}
- (id)treeView:(WH_RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.wh_dataArray objectAtIndex:index];
    }
    if ([item isMemberOfClass:[WH_DepartObject class]]) {
        WH_DepartObject * dataObject = item;
        return dataObject.departes[index];
    }else{
        return nil;
    }
}

/**
 选择移动到的部门

 @param item 部门对象
 */
-(void)chooesDepartment:(id)item{
    WH_DepartObject * depart = item;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selNewDepartmentWith:)]) {
        [self actionQuit];
        [self.delegate selNewDepartmentWith:depart];
    }
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

@end
