//
//  WWEmoticonManagerViewController.m
//  WaHu
//
//  Created by Apple on 2019/3/1.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWEmoticonManagerViewController.h"
#import "WWEmotManagerCell.h"//

@interface WWEmoticonManagerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray *selDataArray;
@end

@implementation WWEmoticonManagerViewController

- (NSMutableArray *)selDataArray
{
    if (_selDataArray == nil) {
        _selDataArray = [NSMutableArray array];
    }
    
    return _selDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    [self setUpNavigationBar];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (JX_SCREEN_WIDTH - 4) / 5;
    
    // 设置每个item的大小
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    // 设置列间距
    layout.minimumInteritemSpacing = 1;
    
    // 设置行间距
    layout.minimumLineSpacing = 1;
    
    //每个分区的四边间距UIEdgeInsetsMake
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置分区(组)的EdgeInset（四边距）
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, self.view.frame.size.height-JX_SCREEN_TOP) collectionViewLayout:layout];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    //禁止滚动
    _collectionView.scrollEnabled = YES;
    
    //设置代理协议
    _collectionView.delegate = self;
    
    //设置数据源协议
    _collectionView.dataSource = self;
    
    /**
     四./注册cell
     在重用池中没有新的cell就注册一个新的cell
     相当于懒加载新的cell
     定义重用标识符(在页面最上定义全局)
     用自定义的cell类,防止内容重叠
     注册时填写的重用标识符 是给整个类添加的 所以类里有的所有属性都有重用标识符
     */
    [self.collectionView registerNib:[UINib nibWithNibName:@"WWEmotManagerCell" bundle:nil] forCellWithReuseIdentifier:@"WWEmotManagerCell"];
    
    [self.view addSubview:self.collectionView];
    
}

- (void)setUpNavigationBar
{
    self.title = [NSString stringWithFormat:@"%@(%ld)",@"添加的单个表情",(long)self.dataArray.count-1];
    
    // 自定制导航条 - 右侧按钮
    
    UIButton *btn;
    btn = [UIFactory WH_create_WHButtonWithRect:CGRectMake(JX_SCREEN_WIDTH - 42 - g_factory.globelEdgeInset, JX_SCREEN_TOP - 43, 42, 42) title:@"删除" titleFont:sysFontWithSize(15) titleColor:RGB(24, 24, 24) normal:nil highlight:nil selector:@selector(delButtonOnClick) target:self];
    btn.custom_acceptEventInterval = 1.0f;
    //        [btn1 addSubview:btn];
    [self.wh_tableHeader addSubview:btn];
    
    
}

#pragma mark - navbar按钮点击
- (void)closeButtonOnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)delButtonOnClick
{
    
    if (self.selDataArray.count>100) {
        
        [GKMessageTool showText:@"不能超过100个"];
        return;
    }
    NSString *emoIdStr = @"";
    
    for (int i = 0; i < self.selDataArray.count; i ++) {
        NSDictionary *dic = self.selDataArray[i];
        NSString *tempStr = checkNull(dic[@"emojiId"]);
        emoIdStr = [emoIdStr stringByAppendingString:tempStr];
        if (i != self.selDataArray.count-1) {
            emoIdStr = [emoIdStr stringByAppendingString:@","];
        }
    }
    
    [self deleteFavoritWithString:emoIdStr];
    
    //    [MBProgressHUD showProgressToView:self.view Text:@"删除中..."];
    //
    //    NSString *token = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
    //    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    //    [params setObject:@"2" forKey:@"type"];
    //    [params setObject:token forKey:@"token"];
    //    [params setObject:emoIdStr forKey:@"emoId"];
    //    WEAKSELF
    //    [WWBusinessManager POST:kApi_biaoqing_delUserEMOData_Path parameters:params mediaDatas:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //
    //
    //
    //        if ([responseObject[@"code"] integerValue] == 1) {
    //            [MBProgressHUD hideHUDForView:weakSelf.view];
    //            [MBProgressHUD showSuccess:@"删除成功" ToView:self.view];
    
    //
    //
    //
    //
    //
    //        }else{
    //            [MBProgressHUD hideHUDForView:weakSelf.view];
    //        }
    //
    //
    //
    //    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //
    //    }];
    
}

// 取消收藏
- (void)deleteFavoritWithString:(NSString *)str {
    [g_server WH_userEmojiDeleteWithId:str toView:self];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WWEmotManagerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WWEmotManagerCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WWEmotManagerCell" owner:nil options:nil] firstObject];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.dataDic = dic;
    cell.choseBtn.selected = NO;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
    }else{
        NSDictionary *dic = self.dataArray[indexPath.row];
        WWEmotManagerCell *cell = (WWEmotManagerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        if (cell.choseBtn.selected) {
            cell.choseBtn.selected = NO;
            [self.selDataArray removeObject:dic];
        }else{
            cell.choseBtn.selected = YES;
            [self.selDataArray addObject:dic];
        }
        
    }
    
    
}


#pragma mark  -------------------服务器返回数据--------------------
#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    /// 取消收藏
    if ([aDownload.action isEqualToString:wh_act_userEmojiDelete]) {
        
        [GKMessageTool showText:Localized(@"JXAlert_DeleteOK")];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFavoritesRefresh_WHNotification object:nil];
        [self.dataArray removeObjectsInArray:self.selDataArray];
        [self.selDataArray removeAllObjects];
        [self.collectionView reloadData];
        
        //刷新标题
        self.title = [NSString stringWithFormat:@"%@(%ld)",@"添加的单个表情",(long)self.dataArray.count-1];
    }
}


@end
