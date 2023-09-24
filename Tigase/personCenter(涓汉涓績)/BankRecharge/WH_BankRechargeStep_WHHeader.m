//
//  WH_BankRechargeStep_WHCell.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/22.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_BankRechargeStep_WHHeader.h"

@implementation WH_BankRechargeStep_WHHeader

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 10, 0, 10));
    }];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"  使用付款卡转帐到下面的银行(转账成功自动到账)\n"attributes: @{NSFontAttributeName: sysFontWithSize(14),NSForegroundColorAttributeName: [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0],NSParagraphStyleAttributeName:style}];
    [string appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"①打开网银APP "attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:0/255.0 green:147/255.0 blue:255/255.0 alpha:1.0]}]];
    
    NSTextAttachment *attchment = [[NSTextAttachment alloc]init];
    attchment.bounds = CGRectMake(0, 0, 12, 12);//设置frame
    attchment.image = [UIImage imageNamed:@"WH_BankRecharge_Arrow_WHIcon"];//设置图片
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)]];
    
    [string appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" ②转账到下面银行(使用已绑定的卡)"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:0/255.0 green:147/255.0 blue:255/255.0 alpha:1.0]}]];
    
    _titleLabel.attributedText = string;
}

@end
