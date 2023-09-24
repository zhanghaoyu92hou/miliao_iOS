//
//  WH_SuccessfulWithdrawal_WHViewController.m
//  Tigase
//
//  Created by Apple on 2019/8/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SuccessfulWithdrawal_WHViewController.h"

@interface WH_SuccessfulWithdrawal_WHViewController ()

@end

@implementation WH_SuccessfulWithdrawal_WHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.title = Localized(@"JXMoney_withdrawals");
    self.wh_isGotoBack = YES;
    [self createHeadAndFoot];
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    
    [self createContentView];
}

- (void)createContentView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 12, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 208)];
    [view setBackgroundColor:HEXCOLOR(0xffffff)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = g_factory.cardCornerRadius;
    view.layer.borderColor = g_factory.cardBorderColor.CGColor;
    view.layer.borderWidth = g_factory.cardBorderWithd;
    [self.wh_tableBody addSubview:view];
    
    UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(view.frame) - 65)/2, 25, 65, 65)];
    [iconImg setImage:[UIImage imageNamed:@"SuccessfulWithdrawal"]];
    [view addSubview:iconImg];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iconImg.frame) + 16, CGRectGetWidth(view.frame), 28)];
    [label setText:@"提现成功"];
    [label setTextColor:HEXCOLOR(0x333333)];
    [label setFont:sysFontWithSize(20)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
    
    UILabel *mLabel = [[UILabel alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(label.frame) + 10, view.frame.size.width - 2*g_factory.globelEdgeInset, 40)];
    [mLabel setText:@"您的提现申请已经生成，请耐心等待审核！\n审核通过后，您将收到提示信息，注意查收！"];
    [mLabel setTextColor:HEXCOLOR(0x8F9CBB)];
    [mLabel setTextAlignment:NSTextAlignmentCenter];
    [mLabel setFont:sysFontWithSize(14)];
    [mLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [mLabel setNumberOfLines:0];
    [view addSubview:mLabel];
    
}

- (void)actionQuit {
    [super actionQuit];
    
    [g_notify postNotificationName:kUpdateUser_WHNotifaction object:nil];
}

@end
