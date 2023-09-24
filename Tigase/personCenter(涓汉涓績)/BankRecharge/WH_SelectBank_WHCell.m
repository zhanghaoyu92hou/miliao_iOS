//
//  WH_SelectBank_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SelectBank_WHCell.h"
#import "WH_BankList_WHModel.h"
#import "WH_HorizontalPageFlowlayout.h"

static const NSInteger kItemCountPerRow = 3; //每行显示5个
static const NSInteger kRowCount = 1; //每页显示行数

@implementation WH_SelectBank_WHItem

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_checkBtn];
        [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsZero);
        }];
        [_checkBtn setTitleColor:HEXCOLOR(0x0093FF) forState:UIControlStateSelected];
        [_checkBtn setTitleColor:HEXCOLOR(0x3A404C) forState:UIControlStateNormal];
        _checkBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        _checkBtn.userInteractionEnabled = NO;
    }
    return self;
}

@end

@interface WH_SelectBank_WHCell () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation WH_SelectBank_WHCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor clearColor];
    
    WH_HorizontalPageFlowlayout * layout = [[WH_HorizontalPageFlowlayout alloc] initWithRowCount:kRowCount itemCountPerRow:kItemCountPerRow];
    [layout setColumnSpacing:0 rowSpacing:0 edgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.bgView addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
    [self.bgView sendSubviewToBack:_collectionView];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[WH_SelectBank_WHItem class] forCellWithReuseIdentifier:@"WH_SelectBank_WHItem"];
    _collectionView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _items.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat bgViewW = JX_SCREEN_WIDTH - 10*2;
    CGFloat itemH = 55.f;
    if (_items.count >= 3) {
        return CGSizeMake(bgViewW / 3.f, itemH);
    } else {
        return CGSizeMake(bgViewW / _items.count, itemH);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WH_SelectBank_WHItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WH_SelectBank_WHItem" forIndexPath:indexPath];
    cell.checkBtn.selected  = _selectIndex == indexPath.row;
    if (cell.checkBtn.selected) {
        cell.checkBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    } else {
        cell.checkBtn.titleLabel.font = sysFontWithSize(15);
    }
    WH_BankList_WHModel *model = _items[indexPath.row];
    [cell.checkBtn setTitle:model.bankName forState:UIControlStateNormal];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _selectIndex = indexPath.row;
    [collectionView reloadData];
    if (_onClickItem) {
        _onClickItem(_selectIndex);
    }
}

- (void)setItems:(NSArray *)items{
    if (_items != items) {
        _items = items;
        [_collectionView reloadData];
    }
}

@end
