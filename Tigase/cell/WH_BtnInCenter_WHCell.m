//
//  WH_BtnInCenter_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_BtnInCenter_WHCell.h"

@implementation WH_BtnInCenter_WHCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor] ;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(g_factory.globelEdgeInset);
        make.right.offset(-g_factory.globelEdgeInset);
        make.centerY.offset(0);
        make.height.offset(44);
    }];
    _button.backgroundColor = HEXCOLOR(0x0093ff);
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _button.titleLabel.font = sysFontWithSize(16);
    [_button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    _button.layer.cornerRadius = g_factory.cardCornerRadius;
    _button.layer.masksToBounds = YES;
}


- (void)clickButton{
    if (_onClickButton) {
        _onClickButton(self,_button);
    }
}


- (void)sp_checkNetWorking:(NSString *)mediaCount {
    NSLog(@"Check your Network");
}
@end
