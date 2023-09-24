//
//  WH_Organiz_WHTableViewCell.h
//  Tigase_imChatT
//
//  Created by 1 on 17/5/12.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_DepartObject.h"

@interface WH_Organiz_WHTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView * wh_arrowView;
@property (nonatomic) BOOL wh_arrowExpand;
//@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *wh_nameLabel;
@property (strong, nonatomic) UIButton *wh_additionButton;

@property (strong, nonatomic) WH_DepartObject *wh_organizObject;

@property (nonatomic, copy) void (^additionButtonTapAction)(id sender);
//@property (nonatomic) BOOL additionButtonHidden;

- (void)setupWithData:(WH_DepartObject *)dataObj level:(NSInteger)level expand:(BOOL)expand;
//- (void)setArrowExpand:(BOOL)arrowExpand animated:(BOOL)animated;
//- (void)setAdditionButtonHidden:(BOOL)additionButtonHidden animated:(BOOL)animated;


@end
