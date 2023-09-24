//
//  WH_CardStyle_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_CardStyle_WHCell.h"


@interface WH_CardStyle_WHCell ()

@property (nonatomic, strong) UIView *lineBgView;

@end

@implementation WH_CardStyle_WHCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _bgView = [UIView new];
        [self.contentView addSubview:_bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(10);
            make.right.offset(-10);
            make.top.bottom.offset(0);
        }];
        _bgView.backgroundColor = [UIColor whiteColor];
        
        [self setupLineBgView];
    }
    return self;
}

- (void)setupLineBgView{
    _lineBgView = [UIView new];
    [_bgView addSubview:_lineBgView];
    [_lineBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
    _lineBgView.userInteractionEnabled = NO;
}

- (void)setBgRoundType:(WHSettingCellBgRoundType)bgRoundType{
    if (_bgRoundType != bgRoundType) {
        if (_bgRoundType != 0) {
            //移除mask
            _bgView.layer.mask = nil;
            
            //移除layer
            [_lineBgView removeFromSuperview] , _lineBgView = nil;
            //重新创建line背景
            [self setupLineBgView];
        }
        _bgRoundType = bgRoundType;
        
        CGRect frame = CGRectMake(0, 0, JX_SCREEN_WIDTH-INSETS*2, 56.f);
        UIRectCorner rectCorner = bgRoundType == WHSettingCellBgRoundTypeTop ? UIRectCornerTopLeft | UIRectCornerTopRight : bgRoundType == WHSettingCellBgRoundTypeBottom ? UIRectCornerBottomLeft | UIRectCornerBottomRight : UIRectCornerAllCorners;
        UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:rectCorner cornerRadii:CGSizeMake(10, 10)];
        CGSize cornerRadii = CGSizeZero;
        CGFloat lineWidth = .0f;
        if (bgRoundType == WHSettingCellBgRoundTypeNone) {
            cornerRadii = CGSizeZero;
            lineWidth = g_factory.cardBorderWithd;
        } else {
            CAShapeLayer *roundLayer = [[CAShapeLayer alloc] init];
            roundLayer.frame = frame;
            roundLayer.path = roundPath.CGPath;
            _bgView.layer.mask = roundLayer;
            
            cornerRadii = CGSizeMake(10, 10);
            lineWidth = g_factory.cardBorderWithd*2;
        }
        
        BOOL drawBorderAll = _bgRoundType == WHSettingCellBgRoundTypeTop || _bgRoundType == WHSettingCellBgRoundTypeAll;
        
        CAShapeLayer *roundLineLayer = [[CAShapeLayer alloc] init];
        roundLineLayer.frame = drawBorderAll ? frame : CGRectMake(0, -g_factory.cardBorderWithd, CGRectGetWidth(frame), CGRectGetHeight(frame)+g_factory.cardBorderWithd);
        UIBezierPath *roundLinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)+g_factory.cardBorderWithd) byRoundingCorners:rectCorner cornerRadii:cornerRadii];
        roundLineLayer.path = drawBorderAll ? roundPath.CGPath : roundLinePath.CGPath;
        roundLineLayer.lineWidth = lineWidth;
        roundLineLayer.strokeColor = g_factory.cardBorderColor.CGColor;
        roundLineLayer.fillColor = nil;
        [self.lineBgView.layer addSublayer:roundLineLayer];
    }
}

@end
