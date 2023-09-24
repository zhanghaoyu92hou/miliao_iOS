//
//  WH_AddressbookSuper_WHController.m
//  Tigase
//
//  Created by Apple on 2019/7/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AddressbookSuper_WHController.h"

@interface WH_AddressbookSuper_WHController () <UITextFieldDelegate>

@end

@implementation WH_AddressbookSuper_WHController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view bringSubviewToFront:_coverView];
}

- (void)createSeekTextField:(UIView *)superView isFriend:(BOOL)isFriend {
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, JX_SCREEN_WIDTH - 10*2, 30.f)];
    _seekTextField.placeholder = [NSString stringWithFormat:@"%@", @"搜索联系人"];
    _seekTextField.backgroundColor = g_factory.inputBackgroundColor;
    if (@available(iOS 10, *)) {
        _seekTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", @"搜索联系人"] attributes:@{NSForegroundColorAttributeName:g_factory.inputDefaultTextColor}];
    } else {
        [_seekTextField setValue:g_factory.inputDefaultTextColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    [_seekTextField setFont:g_factory.inputDefaultTextFont];
    _seekTextField.textColor = HEXCOLOR(0x333333);
    _seekTextField.layer.borderWidth = 0.5;
    _seekTextField.layer.borderColor = g_factory.inputBorderColor.CGColor;
    _seekTextField.layer.cornerRadius = CGRectGetHeight(_seekTextField.frame) / 2.f;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [superView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [superView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_seekTextField.mas_right).offset(10);
        make.top.bottom.equalTo(_seekTextField);
        make.width.offset(52.f);
    }];
    cancelBtn.layer.borderColor = g_factory.cancelBtnBorderColor.CGColor;
    cancelBtn.layer.borderWidth = g_factory.cardBorderWithd;
    cancelBtn.titleLabel.font = g_factory.cancelBtnFont;
    [cancelBtn setTitleColor:g_factory.cancelBtnTextColor forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius = CGRectGetHeight(_seekTextField.frame) / 2.f;
    cancelBtn.layer.masksToBounds = YES;
    
    //上下分割线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(superView.frame), g_factory.cardBorderWithd)];
    topLine.backgroundColor = g_factory.inputBorderColor;
    [superView addSubview:topLine];
    UIView *btmLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_seekTextField.frame) + 7.f, CGRectGetWidth(superView.frame), g_factory.cardBorderWithd)];
    btmLine.backgroundColor = g_factory.inputBorderColor;
    [superView addSubview:btmLine];

    _coverView = [[UIView alloc] init];
    if (isFriend) {
        _coverView.frame = CGRectMake(0, CGRectGetMaxY(btmLine.frame), CGRectGetWidth(superView.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(btmLine.frame));
    }else{
        _coverView.frame = CGRectMake(0, CGRectGetMaxY(superView.frame), CGRectGetWidth(superView.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(superView.frame));
    }
    [self.view addSubview:_coverView];
    _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _coverView.alpha = 0;
    [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverView)]];
}

- (void)clickCancelBtn{
    [self dismissCoverWithIsResignKeyboard:YES];
}

- (void)tapCoverView{
    [self dismissCoverWithIsResignKeyboard:YES];
}

- (void)showCover{
    if (_coverView.alpha == 1) {
        return;
    }
//    CGRect frame = _coverView.frame;
//    frame.origin.y = CGRectGetMaxY(self.seekTextField.frame)+7.f;
//    _coverView.frame = frame;
    _coverView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        _coverView.alpha = 1;
        
        CGRect frame = _seekTextField.frame;
        frame.size.width = JX_SCREEN_WIDTH - 10 - 72;
        _seekTextField.frame = frame;
    }];
}

- (void)dismissCoverWithIsResignKeyboard:(BOOL)isResignKeyboard{
//    if (_coverView.alpha == 0) {
//        return;
//    }
//    _coverView.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        _coverView.alpha = 0;
        
        if (isResignKeyboard) {
            CGRect frame = _seekTextField.frame;
            frame.size.width = JX_SCREEN_WIDTH - 10*2;
            _seekTextField.frame = frame;
        }
    }];
    if (isResignKeyboard) {
        [_seekTextField resignFirstResponder];
    }
}

- (void)textFieldDidChange:(UITextField *)textField{
    if (_seekTextField.text.length > 0) {
        //隐藏蒙版
        [self dismissCoverWithIsResignKeyboard:NO];
    } else {
        //显示蒙版
        [self showCover];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //显示蒙版
    [self showCover];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //隐藏蒙版
    [self dismissCoverWithIsResignKeyboard:YES];
}

- (void)sp_checkUserInfo {
    NSLog(@"Check your Network");
}
@end
