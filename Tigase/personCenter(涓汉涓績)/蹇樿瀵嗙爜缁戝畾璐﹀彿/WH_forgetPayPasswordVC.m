//
//  WH_forgetPayPasswordVC.m
//  Tigase
//
//  Created by admin on 2019/8/5.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_forgetPayPasswordVC.h"

@interface WH_forgetPayPasswordVC ()

@end

@implementation WH_forgetPayPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"忘记支付密码";
    
    
    
    UIView *bgView = [UIView new];
    UILabel *titleLb = [UILabel new];
    UIView *lineView = [UIView new];
    UITextField *passTf = [UITextField new];
    UIButton *nextSteepBtn = [UIButton new];
    
    [self.view addSubview:bgView];
    [bgView addSubview:titleLb];
    [bgView addSubview:lineView];
    [bgView addSubview:passTf];
    [bgView addSubview:nextSteepBtn];
    
    
    bgView.layer.cornerRadius = 10.0f;
    bgView.backgroundColor = RGB(219, 224, 231);
    bgView.layer.borderWidth = 1;
    bgView.layer.borderColor = RGB(245, 247, 250).CGColor;
    titleLb.text = @"输入登陆密码，完成身份验证";
    titleLb.font = [UIFont systemFontOfSize:16];
    titleLb.textColor = RGB(51, 51, 51);
    titleLb.textAlignment = NSTextAlignmentCenter;
    passTf.secureTextEntry = YES;
    passTf.placeholder = @"输入登陆密码";
    passTf.borderStyle = UITextBorderStyleNone;
    lineView.backgroundColor = RGB(245, 247, 250);
    
    [nextSteepBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextSteepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextSteepBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    nextSteepBtn.layer.cornerRadius = 10;
    nextSteepBtn.backgroundColor = RGB(0, 147, 255);
    [nextSteepBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(11);
        make.right.mas_equalTo(self.view.mas_right).offset(-11);
        make.top.mas_equalTo(self.view.mas_top).offset(12);
    }];
    
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(bgView.mas_top);
        make.height.mas_equalTo(50);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(bgView);
        make.top.mas_equalTo(titleLb.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    [passTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(bgView);
        make.top.mas_equalTo(lineView.mas_bottom);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(bgView.mas_bottom);
    }];
    
    [nextSteepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(bgView);
        make.top.mas_equalTo(bgView.mas_bottom).offset(20);
        make.height.mas_equalTo(44);
    }];
    
    
}

#pragma mark - 下一步
- (void) nextBtnClick{
    NSLog(@"下一步");
}



@end
