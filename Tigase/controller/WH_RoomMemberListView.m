

//
//  roomMemberListView.m
//  test_oC
//
//  Created by 史小峰 on 2019/7/23.
//  Copyright © 2019 SXF. All rights reserved.
//


#import <UIKit/UIKit.h>
@interface reusableHeaderV : UICollectionReusableView

@end


@implementation reusableHeaderV
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

@end



@interface roomMemberListViewCell : UICollectionViewCell
@property (nonatomic ,strong) UIImageView *headerImgV;
@property (nonatomic ,strong) UILabel *nameLb;
@property (nonatomic ,strong) UIImageView *userLeveImgV;//用户等级
@property (nonatomic ,strong) UIImageView *queueManagerImageV;//群管理头像（群管理需要置顶）
@property (nonatomic ,strong) memberData *data;
@end
@implementation roomMemberListViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addChildrenViews];
    }
    return self;
}
- (void) addChildrenViews{
    [self.contentView addSubview:self.headerImgV];
    [self.contentView addSubview:self.nameLb];
    [self.contentView addSubview:self.queueManagerImageV];
    [self.contentView addSubview:self.userLeveImgV];

    self.headerImgV.backgroundColor = [UIColor greenColor];
    self.nameLb.font = [UIFont systemFontOfSize:15];
    self.nameLb.textColor = HEXCOLOR(0x969696);
    self.nameLb.text = @"namenamenamnana";
    self.nameLb.textAlignment = NSTextAlignmentCenter;
}
- (void)setData:(memberData *)data{
    self.nameLb.text = data.userNickName;
    [g_server WH_getHeadImageSmallWIthUserId:[NSString stringWithFormat:@"%ld", data.userId] userName:data.userNickName imageView:self.headerImgV];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.headerImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_width);
    }];
    [self.queueManagerImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.headerImgV);
    }];
    [self.userLeveImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.headerImgV);
        make.width.height.mas_equalTo(16);
    }];
    
    
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self);
    }];
    [self layoutIfNeeded];
    self.headerImgV.layer.cornerRadius = self.headerImgV.bounds.size.width * 0.5;
    self.headerImgV.layer.masksToBounds = YES;
    self.headerImgV.clipsToBounds = YES;
}
- (UIImageView *)headerImgV{
    if (!_headerImgV) {
        _headerImgV = [[UIImageView alloc] init];
    }
    return _headerImgV;
}

- (UILabel *)nameLb{
    if (!_nameLb) {
        _nameLb = [UILabel new];
    }
    return _nameLb;
}
- (UIImageView *)userLeveImgV{
    if (!_userLeveImgV) {
        _userLeveImgV = [UIImageView new];
    }
    return _userLeveImgV;
}
@end







#import "WH_RoomMemberListView.h"
@interface WH_RoomMemberListView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic ,strong) UICollectionView *collectionView;
@property (nonatomic ,strong) UILabel *titleLb;
@end

@implementation WH_RoomMemberListView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addChildrenViews];
    }
    return self;
}

- (void) addChildrenViews{
    [self addSubview:self.collectionView];
}

- (void)setSearchView:(UIView *)searchView{
    _searchView = searchView;
    [self.collectionView addSubview:searchView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.collectionView.bounds];
    self.collectionView.backgroundView = bgView;
//    searchView.frame = CGRectMake(0,0,searchView.bounds.size.width, searchView.bounds.size.height);
    [bgView addSubview:searchView];
    
    
    UIView *topLineView = [UIView new];
    UIView *bottomLineView = [UIView new];
    [searchView addSubview:topLineView];
    [searchView addSubview:bottomLineView];
    topLineView.backgroundColor = bottomLineView.backgroundColor = HEXCOLOR(0xEBECEF);
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(searchView);
        make.height.mas_equalTo(1);
    }];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(searchView);
        make.bottom.mas_equalTo(searchView.mas_bottom).offset(-3);
        make.height.mas_equalTo(1);
    }];
    
    
}
- (void)setDataSourceArr:(NSArray<memberData *> *)dataSourceArr{
    _dataSourceArr = dataSourceArr;
    //    [self.collectionView reloadData];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    roomMemberListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([roomMemberListViewCell class]) forIndexPath:indexPath];
    memberData *data = self.dataSourceArr[indexPath.row];
    cell.data = data;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    !self.selectedIndex ? : self.selectedIndex(indexPath, self.dataSourceArr[indexPath.row]);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableHeaderV *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
//        if (!self.titleLb) {
//            UILabel *titleLb = [UILabel new];
//            self.titleLb = titleLb;
//            [header addSubview:self.titleLb];
//            [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(header.mas_left).offset(10);
//                make.top.bottom.mas_equalTo(header);
//            }];
//            titleLb.text = @"最佳搜索";
//        }
        
        return header;
    }
    
    return nil;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 35, 15, 35);
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeMake(_collectionView.frame.size.width, 0.01);
//}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        CGFloat margin = 35.0;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGFloat itemW = ([UIScreen mainScreen].bounds.size.width - 4 * 30.0 - margin * 2) / 5.0;
        layout.itemSize = CGSizeMake(itemW, itemW + 20);
        layout.minimumLineSpacing = 15.0;
        layout.minimumInteritemSpacing = 30.0;
//        layout.headerReferenceSize = CGSizeMake(_collectionView.frame.size.width, 50);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[roomMemberListViewCell class] forCellWithReuseIdentifier:NSStringFromClass([roomMemberListViewCell class])];
        
        [_collectionView registerClass:[reusableHeaderV class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}






- (void)sp_getUserFollowSuccess:(NSString *)isLogin {
    NSLog(@"Get User Succrss");
}
@end
