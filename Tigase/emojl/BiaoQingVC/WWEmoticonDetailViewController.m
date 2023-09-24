//
//  WWEmoticonDetailViewController.m
//  WaHu
//
//  Created by Apple on 2019/3/1.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWEmoticonDetailViewController.h"
#import "WWShowEmotCollectionViewCell.h"

@interface WWEmoticonDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;
@end

@implementation WWEmoticonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (JX_SCREEN_WIDTH - 30) / 4;
    
    // 设置每个item的大小
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    // 设置列间距
    layout.minimumInteritemSpacing = 0;
    
    // 设置行间距
    layout.minimumLineSpacing = 0;
    
    //每个分区的四边间距UIEdgeInsetsMake
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置分区(组)的EdgeInset（四边距）
    layout.sectionInset = UIEdgeInsetsMake(15, 0, 0, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, JX_SCREEN_TOP, JX_SCREEN_WIDTH-30, JX_SCREEN_HEIGHT-JX_SCREEN_TOP) collectionViewLayout:layout];
    
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
    [self.collectionView registerNib:[UINib nibWithNibName:@"WWShowEmotCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WWShowEmotCollectionViewCell"];
    
    [self.view addSubview:self.collectionView];
    
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
    WWShowEmotCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WWShowEmotCollectionViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WWShowEmotCollectionViewCell" owner:nil options:nil] firstObject];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.dataDic = dic;
    return cell;
}


@end
