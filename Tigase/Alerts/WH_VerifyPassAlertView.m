//
//  WH_VerifyPassView.m
//  Tigase
//
//  Created by 齐科 on 2019/9/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_VerifyPassAlertView.h"

@interface WH_VerifyPassAlertView() <UITextFieldDelegate>
{
    UILabel *titleLabel;
    UILabel *tipsLabel;
    NSString *password;
}
@end

@implementation WH_VerifyPassAlertView
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self loadSubViewsWithTitle:title];
    }
    return self;
}
- (void)loadSubViewsWithTitle:(NSString *)title {
    
    [g_App.window addSubview:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlert)];
    [self addGestureRecognizer:tap];
    
    UIView *whiteBackView = [[UIView alloc] initWithFrame:CGRectMake(20, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-40, 228)];
    whiteBackView.backgroundColor = [UIColor whiteColor];
    whiteBackView.layer.masksToBounds = YES;
    whiteBackView.layer.cornerRadius = 15.f;
    [self addSubview:whiteBackView];
    
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 14, 14, 14)];
    [closeButton setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissAlert) forControlEvents:UIControlEventTouchUpInside];
    [whiteBackView addSubview:closeButton];

    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, whiteBackView.frame.size.width - 12*2, 54)];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.textColor = HEXCOLOR(0x8C9AB8);
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    [whiteBackView addSubview:titleLabel];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 54, whiteBackView.width, g_factory.cardBorderWithd)];
    [topLine setBackgroundColor:g_factory.cardBorderColor];
    [whiteBackView addSubview:topLine];
    
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 75, whiteBackView.width-24, 60)];
    textField.delegate = self;
    textField.backgroundColor = HEXCOLOR(0xE8E8EA);
    textField.textColor = HEXCOLOR(0x3A404C);
    textField.secureTextEntry = YES;
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 10;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 60)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    [whiteBackView addSubview:textField];

    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, textField.bottom+2, whiteBackView.width-60, 15)];
    tipsLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    tipsLabel.textColor = HEXCOLOR(0xED6350);
    [whiteBackView addSubview:tipsLabel];

    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, tipsLabel.bottom+2, whiteBackView.width, 0.5)];
    bottomLine.backgroundColor = HEXCOLOR(0xD6D6D6);
    [whiteBackView addSubview:bottomLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(12 , bottomLine.bottom+14, whiteBackView.frame.size.width/2 - 12 - 15, 44)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [cancelBtn setBackgroundColor:HEXCOLOR(0xffffff)];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    cancelBtn.layer.borderWidth = g_factory.cardBorderWithd;
    cancelBtn.layer.borderColor = g_factory.cardBorderColor.CGColor;
    [whiteBackView addSubview:cancelBtn];
    
    // 发送
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(whiteBackView.frame.size.width/2 + 15, cancelBtn.frame.origin.y, whiteBackView.frame.size.width/2 - 12 - 15, 44)];
    [sureBtn setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
    [sureBtn setBackgroundColor:HEXCOLOR(0x0093FF)];
    sureBtn.layer.masksToBounds = YES;
    sureBtn.layer.cornerRadius = g_factory.cardCornerRadius;
    [sureBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [whiteBackView addSubview:sureBtn];
}

#pragma mark ---- Button Event
- (void)cancelAction {
    [self dismissAlert];
}
- (void)confirmAction {
    [self endEditing:YES];
    if (IsStringNull(password)) {
        [GKMessageTool showTips:@"请输入密码"];
        return;
    }
    if (self.confirmBlock) {
        self.confirmBlock(password, tipsLabel);
    }
}

#pragma mark ----- UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    password = textField.text;
}

- (void)showAlert {
    [g_window addSubview:self];
}
- (void)dismissAlert {
    [self removeFromSuperview];
}

@end
