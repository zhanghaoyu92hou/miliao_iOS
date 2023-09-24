//
//  WH_RechargeSelectAccount_WHCell.m
//  Tigase
//
//  Created by lyj on 2019/11/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_RechargeSelectAccount_WHCell.h"

@implementation WH_RechargeSelectAccount_WHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self customSubviews];
    }
    return self;
}

- (void)customSubviews {
    //提现到标题
    UILabel *wh_withdrawalToTitleLabel = [[UILabel alloc] init];
    wh_withdrawalToTitleLabel.textColor = HEXCOLOR(0x3A404C);
    wh_withdrawalToTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    wh_withdrawalToTitleLabel.text = Localized(@"JX_WithdrawalToWhere");
    [self.contentView addSubview:wh_withdrawalToTitleLabel];
    [wh_withdrawalToTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(20);
        make.top.right.equalTo(self.contentView);
        make.height.mas_equalTo(54);
    }];
    
    //分割线
    UIView *wh_lineView = [[UIView alloc] init];
    wh_lineView.backgroundColor = HEXCOLOR(0xF8F8F7);
    [self.contentView addSubview:wh_lineView];
    [wh_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(wh_withdrawalToTitleLabel.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    //图标
    UIImageView *wh_iconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:wh_iconImageView];
    wh_iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.wh_iconImageView = wh_iconImageView;
    [wh_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wh_withdrawalToTitleLabel);
        make.top.equalTo(wh_lineView.mas_bottom).mas_offset(15);
        make.width.height.mas_equalTo(25);
        make.bottom.equalTo(self.contentView).mas_offset(-15);
    }];
    
    //提现到的账号
    UILabel *wh_withdrawalToAccountLabel = [[UILabel alloc] init];
    wh_withdrawalToAccountLabel.textColor = HEXCOLOR(0x3A404C);
    wh_withdrawalToAccountLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    [self.contentView addSubview:wh_withdrawalToAccountLabel];
    self.wh_withdrawalToAccountLabel = wh_withdrawalToAccountLabel;
    [wh_withdrawalToAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wh_iconImageView.mas_right).mas_offset(10);
        make.top.bottom.equalTo(wh_iconImageView);
        make.right.equalTo(self.contentView).mas_offset(-50);
    }];
    
    //右箭头
    UIImageView *wh_rightArrowImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:wh_rightArrowImageView];
    wh_rightArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *rightArrowImage = [UIImage imageNamed:@"icon_right_arrow"];
    wh_rightArrowImageView.image = rightArrowImage;
    [wh_rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).mas_offset(-20);
        make.centerY.mas_equalTo(wh_iconImageView);
        make.width.mas_equalTo(rightArrowImage.size.width);
        make.height.mas_equalTo(rightArrowImage.size.height);
    }];
    
    //点击按钮
    UIButton *wh_tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    wh_tapButton.backgroundColor = [UIColor clearColor];
    wh_tapButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    wh_tapButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [wh_tapButton setTitleColor:HEXCOLOR(0xBAC3D5) forState:UIControlStateNormal];
    [wh_tapButton setTitle:Localized(@"JX_SelectWithdrawalAccount") forState:UIControlStateNormal];
    [wh_tapButton addTarget:self action:@selector(selectWithdrawalAccountAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:wh_tapButton];
    self.wh_tapButton = wh_tapButton;
    [wh_tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wh_lineView.mas_bottom);
        make.bottom.right.equalTo(self.contentView);
        make.left.equalTo(wh_withdrawalToTitleLabel);
    }];
}

//点击事件
- (void)selectWithdrawalAccountAction {
    if (self.selectAccountBlock) {
        self.selectAccountBlock();
    }
}

- (void)loadContent {
    NSDictionary *accountDic = self.data;
    if (accountDic == nil || accountDic.count == 0) {
        [self.wh_tapButton setTitle:Localized(@"JX_SelectWithdrawalAccount") forState:UIControlStateNormal];
        self.wh_iconImageView.image = [UIImage imageNamed:@""];
        self.wh_withdrawalToAccountLabel.text = @"";
    } else {
        NSString *type = accountDic[@"type"];
        NSString *account = @"";
        if (type.integerValue == 1) {//支付宝账号
            account = accountDic[@"alipayNumber"];
            self.wh_iconImageView.image = [UIImage imageNamed:@"WH_ALiPay"];
        } else if(type.integerValue == 5){//银行卡账号
            account = [NSString stringWithFormat:@"%@（%@）", accountDic[@"bankName"], accountDic[@"bankCardNo"]];
            self.wh_iconImageView.image = [UIImage imageNamed:@"MX_MyWallet_UnionPayPayment"];
        }else {
            account = [NSString stringWithFormat:@"%@ %@" ,[accountDic objectForKey:@"otherNode1"]?:@"" ,[accountDic objectForKey:@"otherNode2"]?:@""];
            self.wh_iconImageView.image = [UIImage imageNamed:@"threeWithdraw_icon"];
        }
        self.wh_withdrawalToAccountLabel.text = account;
        [self.wh_tapButton setTitle:@"" forState:UIControlStateNormal];
    }
}
@end
