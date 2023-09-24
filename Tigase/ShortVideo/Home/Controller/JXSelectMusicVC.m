//
//  JXSelectMusicVC.m
//  shiku_im
//
//  Created by p on 2018/12/4.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXSelectMusicVC.h"
#import "BMChineseSort.h"
#import "JXSelectMusicCell.h"

@interface JXSelectMusicVC ()<UITextFieldDelegate,JXSelectMusicCellDelegate>

@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *array;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic, strong) JXSelectMusicCell *selectCell;

@end

@implementation JXSelectMusicVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.title = Localized(@"JX_ChooseMusic");
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    _page = 0;
    
    _array = [NSMutableArray array];
    _searchArray = [NSMutableArray array];
    _indexArray = [NSMutableArray array];
    _letterResultArr = [NSMutableArray array];
    
    [self customSearchTextField];
    [self MiXin_getServerData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = YES; 
}

- (void)MiXin_getServerData {
    [g_server musicListPageIndex:_page keyword:nil toView:self];
}

- (void)customSearchTextField{
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 50)];
    //    backView.backgroundColor = HEXCOLOR(0xf0f0f0);
    [self.view addSubview:backView];
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 30)];
    _seekTextField.placeholder = Localized(@"JX_EnterKeyword");
    _seekTextField.textColor = [UIColor blackColor];
    [_seekTextField setFont:SYSFONT(14)];
    _seekTextField.backgroundColor = HEXCOLOR(0xf0f0f0);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    imageView.center = CGPointMake(leftView.frame.size.width/2, leftView.frame.size.height/2);
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, JX_SCREEN_WIDTH, .5)];
    lineView.backgroundColor = HEXCOLOR(0xdcdcdc);
    [backView addSubview:lineView];
    
    self.tableView.tableHeaderView = backView;
    
}

- (void) textFieldDidChange:(UITextField *)textField {
    
//    if (textField.text.length <= 0) {
//        [self.tableView reloadData];
//        return;
//    }
    
    [_searchArray removeAllObjects];
    
    if (textField.text.length > 0) {
        [g_server musicListPageIndex:0 keyword:textField.text toView:self];
    }else {
        _page = 0;
        [self MiXin_getServerData];
    }
    
    
//    for (NSInteger i = 0; i < _array.count; i ++) {
//        JXSelectMusicModel *model = _array[i];
//        NSString *userStr = [model.name lowercaseString];
//        NSString *textStr = [textField.text lowercaseString];
//        if ([userStr rangeOfString:textStr].location != NSNotFound) {
//            [_searchArray addObject:model];
//        }
//    }
    
//    [self.tableView reloadData];
}

- (void)selectMusicCell:(JXSelectMusicCell *)cell MiXin_select_MiXinBtnAction:(JXSelectMusicModel *)model {
    [cell.audioPlayer stop];
    
    if ([self.delegate respondsToSelector:@selector(selectMusicVC:selectMusic:)]) {
        [self.delegate selectMusicVC:self selectMusic:model];
        
        [self actionQuit];
    }
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_seekTextField.text.length > 0) {
        return 1;
    }
    return [self.indexArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_seekTextField.text.length > 0) {
        return Localized(@"JXFriend_searchTitle");
    }
    return [self.indexArray objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_seekTextField.text.length > 0) {
        return _searchArray.count;
    }
    return [[self.letterResultArr objectAtIndex:section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (_seekTextField.text.length > 0) {
        return nil;
    }
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JXSelectMusicCell *cell=[[JXSelectMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JXSelectMusicCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    JXSelectMusicModel *model;
    if (_seekTextField.text.length > 0) {
        model = _searchArray[indexPath.row];
    }else{
        model = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    cell.delegate = self;
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   JXSelectMusicCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.selectCell = cell;
    [cell playBtnAction:cell.playBtn];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)actionQuit {
    [super actionQuit];
    [self.selectCell.audioPlayer stop];
}

#pragma mark - 请求成功回调
-(void) MiXin_didServerResult_MiXinSucces:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_MusicList] ){
        [self stopLoading];
        if (array1.count <= 0) {
            self.isShowFooterPull = NO;
        }else {
            self.isShowFooterPull = YES;
        }
        
        if (_seekTextField.text.length > 0) {
            [_searchArray removeAllObjects];
            for (NSInteger i = 0; i < array1.count; i ++) {
                NSDictionary *dict = array1[i];
                JXSelectMusicModel *model = [JXSelectMusicModel setModelWithDict:dict];
                [_searchArray addObject:model];
            }
            
            //选择拼音 转换的 方法
            BMChineseSortSetting.share.sortMode = 2; // 1或2
            //排序 Person对象
            [BMChineseSort sortAndGroup:_searchArray key:@"nikeName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
                if (isSuccess) {
                    self.indexArray = sectionTitleArr;
                    self.letterResultArr = sortedObjArr;
                    [_table reloadData];
                }
            }];
            
            return;
        }
        
        
        if (_page == 0) {
            [_array removeAllObjects];
//            [_array addObjectsFromArray:array1];
        }else {
//            [_array addObjectsFromArray:array1];
        }
//        _page ++;
        
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            JXSelectMusicModel *model = [JXSelectMusicModel setModelWithDict:dict];
            [_array addObject:model];
        }
        
        //选择拼音 转换的 方法
        BMChineseSortSetting.share.sortMode = 2; // 1或2
        //排序 Person对象
        [BMChineseSort sortAndGroup:_array key:@"nikeName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
            if (isSuccess) {
                self.indexArray = sectionTitleArr;
                self.letterResultArr = sortedObjArr;
                [_table reloadData];
            }
        }];
        
//        //根据Person对象的 name 属性 按中文 对 Person数组 排序
//        self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"nikeName"];
//        self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"nikeName"];
//
//        [self.tableView reloadData];
    }

}

#pragma mark - 请求失败回调
-(int) MiXin_didServerResult_MinXinFailed:(MiXin_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return show_error;
}

#pragma mark - 请求出错回调
-(int) MiXin_didServerConnect_MiXinError:(MiXin_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return show_error;
}

#pragma mark - 开始请求服务器回调
-(void) MiXin_didServerConnect_MiXinStart:(MiXin_JXConnection*)aDownload{
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

@end
