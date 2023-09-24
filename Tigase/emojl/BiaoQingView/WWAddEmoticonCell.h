//
//  WWAddEmoticonCell.h
//  WaHu
//
//  Created by Apple on 2019/3/1.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WWAddEmoticonDelegate <NSObject>

- (void)addEmoticonDidClickWithAddBtn:(UIButton *)addBtn andAleadyBtn:(UIButton *)aleadyBtn dataDic:(NSDictionary *)dic;

@end

@interface WWAddEmoticonCell : UITableViewCell

@property (nonatomic, strong) NSDictionary * dataDic;

@property (nonatomic, weak) id<WWAddEmoticonDelegate> delegate;

+ (WWAddEmoticonCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
