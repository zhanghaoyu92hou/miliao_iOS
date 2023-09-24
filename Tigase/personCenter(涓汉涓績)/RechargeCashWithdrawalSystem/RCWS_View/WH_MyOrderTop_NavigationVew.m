//
//  WH_MyOrderTop_NavigationVew.m
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_MyOrderTop_NavigationVew.h"

@implementation WH_MyOrderTop_NavigationVew

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEXCOLOR(0xffffff);
        
        self.listArray = @[@"全部" ,@"待付款" ,@"待放行" ,@"已完成" ,@"已取消"];
        
        self.btnArray = [[NSMutableArray alloc] init];
        
        UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, CGRectGetWidth(self.frame), 0.5)];
        [lView setBackgroundColor:HEXCOLOR(0xF0F0F0)];
        [self addSubview:lView];
        
        CGFloat btnWidth = JX_SCREEN_WIDTH/self.listArray.count;
        for (int i = 0; i < self.listArray.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(i*btnWidth, 0, btnWidth, 44)];
            [btn setTag:i];
            [btn setTitle:[self.listArray objectAtIndex:i] forState:UIControlStateNormal];
            if (i == self.currentIndex) {
                [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15]];
                [btn setTitleColor:HEXCOLOR(0x2C2F36) forState:UIControlStateNormal];
            }else{
                [btn setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateNormal];
                [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
            }
            [self addSubview:btn];
            [btn addTarget:self action:@selector(buttonClickMethod:) forControlEvents:UIControlEventTouchUpInside];
            [self.btnArray addObject:btn];
        }
        
    }
    return self;
}

- (void)buttonClickMethod:(UIButton *)button {
    self.currentIndex = button.tag;
    for (int i = 0; i < self.btnArray.count; i++) {
        UIButton *button = [self.btnArray objectAtIndex:i];
        if (self.currentIndex == i) {
            [button.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15]];
            [button setTitleColor:HEXCOLOR(0x2C2F36) forState:UIControlStateNormal];
        }else{
            [button setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
        }
    }
    
    if (self.SelectedOrderTypeBlock) {
        self.SelectedOrderTypeBlock(button.tag);
    }
}

@end
