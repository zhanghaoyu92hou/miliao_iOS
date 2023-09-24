//
//  WH_MyOrderList_WHTableViewCell.h
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_OrderListModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MiXin_MyOrderList_TabelViewCellDelegate <NSObject>

- (void)copyAccountNumber:(NSString *)accountNumber;

- (void)copyOrderNumber:(NSString *)orderNumber;

@end

@interface WH_MyOrderList_WHTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIView *cView;

@property (nonatomic ,strong) UILabel *title; //订单类型
@property (nonatomic ,strong) UILabel *dec; //订单描述
@property (nonatomic ,strong) UILabel *paNun; //WA币

@property (nonatomic ,strong) UILabel *payMoney; //支付金额
@property (nonatomic ,strong) UILabel *obtainPA; //获得奖励的WA币
@property (nonatomic ,strong) UILabel *accountNumber; //支付的账号
@property (nonatomic ,strong) UILabel *orderNumber; //订单号

@property (nonatomic ,weak) id<MiXin_MyOrderList_TabelViewCellDelegate> delegate;

@property (nonatomic, strong) WH_OrderListModel *model;

@end

NS_ASSUME_NONNULL_END
