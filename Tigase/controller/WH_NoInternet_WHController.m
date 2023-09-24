//
//  WH_NoInternet_WHController.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_NoInternet_WHController.h"

@interface WH_NoInternet_WHController ()

@end

@implementation WH_NoInternet_WHController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    
    self.title = @"网络链接不可用";
    [self createHeadAndFoot];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_TOP - 36, 28, 28)];
    [btn setImage:[UIImage imageNamed:@"WH_Close_Blue"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didDissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self setupUI];
}

- (void)didDissVC{
    [g_navigation WH_dismiss_WHViewController:self animated:YES];
}

- (void)setupUI{
    UIView *bgView = [UIView new];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(self.wh_heightHeader+12, 10 , 12, 10));
    }];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 10;
    bgView.layer.masksToBounds = YES;
    bgView.layer.borderWidth = 1;
    bgView.layer.borderColor = HEXCOLOR(0xDBE0E7).CGColor;
    
    UILabel *titleLabel = [UILabel new];
    [bgView addSubview:titleLabel];
    [titleLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(16);
        make.top.offset(20);
        make.right.offset(-16);
    }];
    titleLabel.textColor = HEXCOLOR(0x333333);
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 23];
    titleLabel.text = @"未能链接到互联网";
    
    UILabel *subTitle = [UILabel new];
    [bgView addSubview:subTitle];
    [subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
    }];
    subTitle.textColor = HEXCOLOR(0x999999);
    subTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    subTitle.text = @"您的设备未启用移动网络或无线局域网";
    
    UIView *lineView = [UIView new];
    [bgView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLabel);
        make.top.equalTo(subTitle.mas_bottom).offset(15);
        make.height.offset(1);
    }];
    lineView.backgroundColor = HEXCOLOR(0xD8D8D8);
    
    UILabel *contentLabel = [UILabel new];
    [bgView addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLabel);
        make.top.equalTo(lineView.mas_bottom).offset(15);
    }];
    contentLabel.numberOfLines = 0;
    
    NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc] init];
    [self appendAttributedString:contentAtt string:@"如需要连接到互联网，请参考以下几点：\n\t\t\t\t\t\t" color:HEXCOLOR(0x464646) font:sysFontWithSize(13)];
    [self appendAttributedString:contentAtt string:@"•" color:HEXCOLOR(0x464646) font:sysFontWithSize(15)];
    [self appendAttributedString:contentAtt string:@" 检查手机中的无线局域网设置，查看是否有可接入的无线局域网信号。\n\t\t\t\t\t\t" color:HEXCOLOR(0x464646) font:sysFontWithSize(13)];
    [self appendAttributedString:contentAtt string:@"•" color:HEXCOLOR(0x464646) font:sysFontWithSize(15)];
    [self appendAttributedString:contentAtt string:@" 检查手机是否已接入移动网络，并且手机没有被停机。\n" color:HEXCOLOR(0x464646) font:sysFontWithSize(13)];
    [self appendAttributedString:contentAtt string:@"如果您已接入无线局域网：\n\t\t\t\t\t\t" color:HEXCOLOR(0x464646) font:sysFontWithSize(13)];
    [self appendAttributedString:contentAtt string:@"•" color:HEXCOLOR(0x464646) font:sysFontWithSize(15)];
    [self appendAttributedString:contentAtt string:@" 请检查您所连接的无线局域网热点是否已接入互联网，或该热点是否已允许您的设备访问互联网。\n" color:HEXCOLOR(0x464646) font:sysFontWithSize(13)];
    contentLabel.attributedText = contentAtt;
}

- (void)appendAttributedString:(NSMutableAttributedString *)mutAtt string:(NSString *)string color:(UIColor *)textColor font:(UIFont *)font{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    [mutAtt appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName:textColor,NSFontAttributeName:font,NSParagraphStyleAttributeName:style}]];
}



@end
