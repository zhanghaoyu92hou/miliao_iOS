//
//  WWMyEmotSettingCell.h
//  WaHu
//
//  Created by Apple on 2019/3/2.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WWMyEmotSettingCellDelegate <NSObject>

- (void)MyEmotSettingCellDidClickRemoveBtn:(UIButton *)removeBtn dataDic:(NSDictionary *)dic;

@end

@interface WWMyEmotSettingCell : UITableViewCell
@property (nonatomic, strong) NSDictionary * dataDic;

@property (nonatomic, weak) id<WWMyEmotSettingCellDelegate> delegate;

+ (WWMyEmotSettingCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
