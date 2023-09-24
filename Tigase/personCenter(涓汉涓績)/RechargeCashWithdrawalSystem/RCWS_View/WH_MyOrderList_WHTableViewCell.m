//
//  WH_MyOrderList_WHTableViewCell.m
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_MyOrderList_WHTableViewCell.h"

@interface WH_MyOrderList_WHTableViewCell ()

@property (nonatomic, strong) NSMutableArray *labels;

@end

@implementation WH_MyOrderList_WHTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self createContentView];
    }
    return self;
}

- (void)createContentView {
    self.cView = [[UIView alloc] initWithFrame:CGRectMake(12, 10, JX_SCREEN_WIDTH - 24, 228)];
    [self.cView setBackgroundColor:HEXCOLOR(0xffffff)];
    self.cView.layer.masksToBounds = YES;
    self.cView.layer.cornerRadius = 10;
    [self addSubview:self.cView];
    
    self.title = [UIFactory WH_create_WHLabelWith:CGRectMake(15, 15, CGRectGetWidth(self.cView.frame) - 30 - 120, 21) text:@"待付款" font:[UIFont fontWithName:@"PingFangSC-Semibold" size: 15] textColor:HEXCOLOR(0x333333) backgroundColor:self.viewForLastBaselineLayout.backgroundColor];
    [self.cView addSubview:self.title];
    
    self.dec = [UIFactory WH_create_WHLabelWith:CGRectMake(15, CGRectGetMaxY(self.title.frame) + 8, CGRectGetWidth(self.title.frame)+10, 18) text:@"请付款给承兑商，24小时后订单将取消" font:[UIFont fontWithName:@"PingFangSC-Regular" size: 12] textColor:HEXCOLOR(0x666666) backgroundColor:self.cView.backgroundColor];
    [self.cView addSubview:self.dec];
    
    self.paNun = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetWidth(self.cView.frame) - 110 - 15, 0, 110, 72) text:@"10000WA币" font:[UIFont fontWithName:@"PingFangSC-Semibold" size: 15] textColor:HEXCOLOR(0x333333) backgroundColor:self.cView.backgroundColor];
    [self.paNun setTextAlignment:NSTextAlignmentRight];
    [self.cView addSubview:self.paNun];
    
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(15, 72, CGRectGetWidth(self.cView.frame) - 30, 0.5)];
    [lView setBackgroundColor:HEXCOLOR(0xDBE0E7)];
    [self.cView addSubview:lView];
    
    _labels = [NSMutableArray array];
    NSArray *array = @[@"支付金额：" ,@"支付宝收款账号：" ,@"订单号："];
    for (int i = 0; i < array.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"%@ 10000" ,[array objectAtIndex:i]]];
        [label setTextColor:HEXCOLOR(0x8292B3)];
        [label setFont:[UIFont fontWithName:@"PingFangSC-Semibold" size: 14]];
        //WithFrame:CGRectMake(15, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), CGRectGetWidth(self.cView.frame) - 30, 20)
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        label.frame = CGRectMake(15, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), size.width, 20);
        [self.cView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.top.offset(CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15));
            make.height.offset(20);
        }];
        
        if (i > 0) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(CGRectGetMaxX(label.frame) + 20, CGRectGetMaxY(lView.frame) + 15 + i*(20 + 15), 20, 20)];
            [btn setImage:[UIImage imageNamed:@"MX_MyWallet_Copy"] forState:UIControlStateNormal];
            [self.cView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(label.mas_right).offset(20);
                make.centerY.equalTo(label);
            }];
            [btn setTag:i];
            [btn addTarget:self action:@selector(copMethod:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_labels addObject:label];
    }
}

- (void)copMethod:(UIButton *)button {
    [GKMessageTool showText:@"复制成功"];
    [UIPasteboard generalPasteboard].string = button.tag == 1 ? _model.skzh : _model.ordernum;
//    if (button.tag == 1) {
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        pasteboard.string = @"accountNumber";
//
//        if (self.delegate) {
//            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//            pasteboard.string = @"accountNumber";
//            [self.delegate copyAccountNumber:@"accountNumber"];
//        }
//    }else{
//        if (self.delegate) {
//            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//            pasteboard.string = @"orderNumber";
//            [self.delegate copyOrderNumber:@"orderNumber"];
//        }
//    }
}

- (void)setModel:(WH_OrderListModel *)model{
    if (_model != model) {
        _model = model;
        _paNun.text = [NSString stringWithFormat:@"%@WA币",_model.zfje];
        NSArray *titles = @[@"支付金额：" ,@"支付宝收款账号：" ,@"订单号："];
        NSArray *texts = @[[NSString stringWithFormat:@"%@元",_model.zfje?:@""],_model.skzh?:@"",_model.ordernum?:@""];
        int i = 0;
        for (UILabel *label in _labels) {
            label.text = [NSString stringWithFormat:@"%@%@",titles[i],texts[i++]];
        }
    }
}

@end
