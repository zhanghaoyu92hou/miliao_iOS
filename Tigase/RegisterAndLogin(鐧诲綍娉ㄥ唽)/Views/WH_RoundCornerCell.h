//
//  WH_CommonCell.h
//  Tigase
//
//  Created by 齐科 on 2019/8/18.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, RoundCornerCellType) {
    RoundCornerCellTypeAll = 0, //!< 单独一个cell
    RoundCornerCellTypeTop,    //!< 多个cell时，最上面的一个
    RoundCornerCellTypeBottom, //!< 多个cell时，最下面的一个
    RoundCornerCellTypeNone //!< 中间的cell
};

@interface WH_RoundCornerCell : UITableViewCell

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, assign) RoundCornerCellType cellType;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
