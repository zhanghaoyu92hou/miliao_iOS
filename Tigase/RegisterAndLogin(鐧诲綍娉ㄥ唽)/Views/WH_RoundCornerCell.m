//
//  WH_CommonCell.m
//  Tigase
//
//  Created by 齐科 on 2019/8/18.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_RoundCornerCell.h"
@interface WH_RoundCornerCell()
{
    UITableView *cellTable;
}
@property (nonatomic, strong) CAShapeLayer *strokeLayer;
@property (nonatomic, strong) UIColor *fillColor;
@end
@implementation WH_RoundCornerCell
+ (Class)layerClass {
    return [CAShapeLayer class];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        cellTable = tableView;
        self.cellIndexPath = indexPath;
        [self setUpCellProperties];
        [self autoSetCellType];
        self.fillColor = g_factory.globalBgColor;
    }
    return self;
}

- (void)setUpCellProperties {
//    self.backgroundColor = g_factory.globalBgColor;
//    self.contentView.backgroundColor = g_factory.globalBgColor;
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CAShapeLayer *shapeLayer = ((CAShapeLayer *)(self.layer));
    CGRect frame = CGRectInset(self.frame, 10, 0);
    shapeLayer.path = [self bezierPathWithCellType:[self cellType] width:frame.size.width height:frame.size.height].CGPath;
    shapeLayer.fillColor = self.fillColor ? self.fillColor.CGColor : UIColor.whiteColor.CGColor;
    self.strokeLayer.strokeColor =  g_factory.cardBorderColor.CGColor;
    self.strokeLayer.lineWidth = g_factory.cardBorderWithd;
    self.strokeLayer.path = [self strokePathWithCellType:[self cellType] width:self.frame.size.width height:self.frame.size.height].CGPath;
}


- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    if (_fillColor != backgroundColor) {
        _fillColor = backgroundColor;
        ((CAShapeLayer *)(self.layer)).fillColor = _fillColor.CGColor;
    }
}

- (UIColor *)backgroundColor {
    return _fillColor;
}

- (UIColor *)fillColor {
    if (!_fillColor) {
        // 默认cell背景色为白色
        _fillColor = [UIColor whiteColor];
    }
    return _fillColor;
}
- (void)setCellIndexPath:(NSIndexPath *)cellIndexPath {
    _cellIndexPath = cellIndexPath;
    [self autoSetCellType];
    [self setNeedsDisplay];
}

- (void)autoSetCellType {
    NSInteger number = [cellTable numberOfRowsInSection:_cellIndexPath.section];
    if (number == 1) {
        self.cellType = RoundCornerCellTypeAll;
    } else if (_cellIndexPath.row == 0) {
        self.cellType = RoundCornerCellTypeTop;
    } else if (_cellIndexPath.row == number - 1) {
        self.cellType = RoundCornerCellTypeBottom;
    } else {
        self.cellType = RoundCornerCellTypeNone;
    }
}

#pragma mark -----  BezierPath

- (UIBezierPath *)bezierPathWithCellType:(RoundCornerCellType)cellType width:(CGFloat)width height:(CGFloat)height {
    UIBezierPath *bezierPath;
    CGFloat radius = g_factory.cardCornerRadius;
    CGRect frame = CGRectMake(10, 0, self.frame.size.width-20, self.frame.size.height);// CGRectInset(self.frame, 10, 0);
    switch (self.cellType) {
        case RoundCornerCellTypeAll: {
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
            break;
        }
        case RoundCornerCellTypeTop: {
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(radius, radius)];
            break;
        }
        case RoundCornerCellTypeBottom: {
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(radius, radius)];
            break;
        }
        case RoundCornerCellTypeNone: {
            bezierPath = [UIBezierPath bezierPathWithRect:frame];
            break;
        }
        default:
            break;
    }
    return bezierPath;
}

- (UIBezierPath *)strokePathWithCellType:(RoundCornerCellType)cellType width:(CGFloat)width height:(CGFloat)height {
    UIBezierPath *bezierPath;
    CGFloat radius = g_factory.cardCornerRadius;
    CGFloat lineWidth = g_factory.cardBorderWithd;
    if (lineWidth <= 0) {
        return nil;
    }
    
    switch (self.cellType) {
        case RoundCornerCellTypeAll: {
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(lineWidth / 2.f + 10, lineWidth / 2.f, width - lineWidth - 20, height - lineWidth) cornerRadius:(radius - lineWidth / 2.f)];
            break;
        }
        case RoundCornerCellTypeTop: {
            bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint:CGPointMake(lineWidth / 2.f + 10, height)];
            [bezierPath addLineToPoint:CGPointMake(lineWidth / 2.f + 10, radius)];
            [bezierPath addArcWithCenter:CGPointMake(radius + 10, radius) radius:(radius - lineWidth / 2.f) startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(width - radius - 10, lineWidth / 2.f)];
            [bezierPath addArcWithCenter:CGPointMake(width - radius - 10, radius) radius:(radius - lineWidth / 2.f) startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [bezierPath addLineToPoint:CGPointMake(width - lineWidth / 2.f - 10, height)];
            
            break;
        }
        case RoundCornerCellTypeBottom: {
            bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint:CGPointMake(lineWidth / 2.f + 10, 0)];
            [bezierPath addLineToPoint:CGPointMake(lineWidth / 2.f + 10, height - radius)];
            [bezierPath addArcWithCenter:CGPointMake(radius + 10, height - radius) radius:(radius - lineWidth / 2.f) startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
            [bezierPath addLineToPoint:CGPointMake(width - radius - 10, height - lineWidth / 2.f)];
            [bezierPath addArcWithCenter:CGPointMake(width - radius - 10, height - radius) radius:(radius - lineWidth / 2.f) startAngle:M_PI_2 endAngle:0 clockwise:NO];
            [bezierPath addLineToPoint:CGPointMake(width - lineWidth / 2.f - 10, 0)];
            break;
        }
        case RoundCornerCellTypeNone: {
            bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint:CGPointMake(lineWidth / 2.f + 10, 0)];
            [bezierPath addLineToPoint:CGPointMake(lineWidth / 2.f + 10, height)];
            
            [bezierPath moveToPoint:CGPointMake(width - lineWidth / 2.f - 10, 0)];
            [bezierPath addLineToPoint:CGPointMake(width - lineWidth / 2.f - 10, height)];
            break;
        }
        default:
            break;
    }
    return bezierPath;
    
}


- (CAShapeLayer *)strokeLayer {
    if (!_strokeLayer) {
        _strokeLayer = [CAShapeLayer layer];
        _strokeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_strokeLayer];
    }
    return _strokeLayer;
}
@end
