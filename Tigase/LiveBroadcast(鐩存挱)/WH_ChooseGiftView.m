//
//  WH_ChooseGiftView.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/28.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_ChooseGiftView.h"
#import "WH_JXLiveGift_WHCell.h"
#import "WH_JXLiveGift_WHObject.h"

@interface WH_ChooseGiftView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<WH_ChooseGiftViewDelegate> delegate;

@property (nonatomic, strong) UILabel * moneyLabel;
@property (nonatomic, strong) UICollectionView * giftCollectView;
@property (nonatomic, strong) UIPageControl * pageControl;
@property (nonatomic, strong) UIButton * rechargeButton;
//@property (nonatomic, strong) count

@property (nonatomic, strong) UIButton * sendButton;

@property (nonatomic, assign) BOOL isFlag;

@end

@implementation WH_ChooseGiftView

-(instancetype)initWithGiftData:(NSArray *)giftArray delegate:(id<WH_ChooseGiftViewDelegate>)delegate frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _wh_giftArray = giftArray;
        _delegate = delegate;
        self.isFlag = NO;
        
        [self customSubViews];
        [g_App addObserver:self forKeyPath:@"myMoney" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    double moneyNew = [change[NSKeyValueChangeNewKey] doubleValue];
//    [change[NSKeyValueChangeOldKey] doubleValue];
    [self setMoney:moneyNew];
}

-(void)dealloc{
    [g_App removeObserver:self forKeyPath:@"myMoney" context:nil];

}
-(void)setMoney:(double)money{
    NSString * moneyStr = [NSString stringWithFormat:@"%.0f",money];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:moneyStr];
    NSTextAttachment *attach=[[NSTextAttachment alloc]init];
    attach.image=[UIImage imageNamed:@"icon_dimen"];
    attach.bounds=CGRectMake(0, 0, 16, 16);
    NSAttributedString *attrStr=[NSAttributedString attributedStringWithAttachment:attach];
    [string appendAttributedString:attrStr];
    _moneyLabel.attributedText=string;
}
-(void)customSubViews{
    
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:effectView];
    
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 25)];
        _moneyLabel.font = sysFontWithSize(14);
        _moneyLabel.textColor = [UIColor orangeColor];
        [self addSubview:_moneyLabel];
    }
    [self setMoney:g_App.myMoney];
    
    if (!_rechargeButton) {
        _rechargeButton = [UIFactory WH_create_WHButtonWithRect:CGRectMake(CGRectGetWidth(self.frame)-100, 0, 100, 25) title:[NSString stringWithFormat:@"%@ >>",Localized(@"JXLiveVC_Recharge")] titleFont:sysFontWithSize(14) titleColor:[UIColor orangeColor] normal:nil highlight:nil selector:nil target:nil];
        [_rechargeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 18)];
        [_rechargeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        
        [self addSubview:_rechargeButton];
        
        if (_delegate && [_delegate respondsToSelector:@selector(rechargeButtonAction)]) {
            [_rechargeButton addTarget:_delegate action:@selector(rechargeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    
    if (!_giftCollectView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _giftCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_rechargeButton.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-50) collectionViewLayout:layout];
        _giftCollectView.backgroundColor = [UIColor clearColor];
        _giftCollectView.alwaysBounceHorizontal = YES;
        _giftCollectView.alwaysBounceVertical = NO;
        _giftCollectView.showsHorizontalScrollIndicator = NO;
        _giftCollectView.showsVerticalScrollIndicator = NO;
        _giftCollectView.pagingEnabled = YES;
        _giftCollectView.delegate = self;
        _giftCollectView.dataSource = self;
        [_giftCollectView registerClass:[WH_JXLiveGift_WHCell class] forCellWithReuseIdentifier:NSStringFromClass([WH_JXLiveGift_WHCell class])];
        [self addSubview:_giftCollectView];
    }
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.frame = CGRectMake(0, CGRectGetMaxY(_giftCollectView.frame), 100, 20);
        _pageControl.center = CGPointMake(_giftCollectView.center.x, _pageControl.center.y);
        NSUInteger pageCount = _wh_giftArray.count%8 ? _wh_giftArray.count/8+1 : _wh_giftArray.count/8;
        _pageControl.numberOfPages = pageCount;
        _pageControl.currentPage = 0;
        [self addSubview:_pageControl];
    }
    
    
    
//    if (!_sendButton) {
//        _sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        _sendButton.frame = CGRectMake(CGRectGetWidth(self.frame)-50-15, CGRectGetMaxY(_giftCollectView.frame) +10, 50, 40);
//        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
//        [_sendButton setTitle:@"发送" forState:UIControlStateHighlighted];
//        [_sendButton setBackgroundColor:[UIColor blueColor]];
//        [self addSubview:_sendButton];
//    }
    
}

-(void)setWh_giftArray:(NSArray *)giftArray{
    if (giftArray) {
        _wh_giftArray = giftArray;
        [_giftCollectView reloadData];
        NSUInteger pageCount = _wh_giftArray.count%8 ? _wh_giftArray.count/8+1 : _wh_giftArray.count/8;
        _pageControl.numberOfPages = pageCount;
    }
}


#pragma mark - UICollectionView delegate
#pragma 多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSUInteger pageCount = _wh_giftArray.count%8 ? _wh_giftArray.count/8+1 : _wh_giftArray.count/8;
    return pageCount;
}
#pragma 多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSUInteger countItem = (section+1)*8 > _wh_giftArray.count ? _wh_giftArray.count - (section -1)*8 : 8;
    return countItem;
}
#pragma 每一个的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = (self.frame.size.width - 10*5)/4;
    return CGSizeMake(itemWidth, 75);
}
#pragma 每一个边缘留白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
#pragma 最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma 最小竖间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma 返回每个单元格是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma 创建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    WH_JXLiveGift_WHCell *cell;
    
    if (collectionView == _giftCollectView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WH_JXLiveGift_WHCell class]) forIndexPath:indexPath];
        if ((indexPath.item + indexPath.section*8) < _wh_giftArray.count) {
            [self assignCell:cell data:_wh_giftArray[indexPath.item + indexPath.section*8]];
        }
        
        return cell;
    }
    return cell;
}
#pragma 点击单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isFlag) {
        self.isFlag = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isFlag = NO;
        });
        WH_JXLiveGift_WHObject * gift = _wh_giftArray[indexPath.item + indexPath.section*8];
        if (_delegate && [_delegate respondsToSelector:@selector(WH_ChooseGiftViewDelegateGift:count:)]) {
            [_delegate WH_ChooseGiftViewDelegateGift:gift count:1];
        }
    }
    
}

-(void)assignCell:(WH_JXLiveGift_WHCell *)cell data:(WH_JXLiveGift_WHObject *)giftObj{
    [cell.wh_giftImgView sd_setImageWithURL:[NSURL URLWithString:giftObj.wh_photo] placeholderImage:nil];
    NSString * priceStr = [NSString stringWithFormat:@"%@",giftObj.price];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:priceStr];
    NSTextAttachment *attach=[[NSTextAttachment alloc]init];
    attach.image=[UIImage imageNamed:@"icon_dimen"];
    attach.bounds=CGRectMake(0, 0, 16, 16);
    NSAttributedString *attrStr=[NSAttributedString attributedStringWithAttachment:attach];
    [string appendAttributedString:attrStr];
    cell.wh_priceLabel.attributedText=string;
    
//    cell.nameLabel.text = [NSString stringWithFormat:@"%@",dataDict[@"name"]];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    int pageIndex = offsetX/self.frame.size.width;
    _pageControl.currentPage = pageIndex;
}


@end
