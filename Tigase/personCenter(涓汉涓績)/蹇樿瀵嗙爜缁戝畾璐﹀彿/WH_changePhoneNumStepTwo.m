
//
//  WH_changePhoneNumStepTwo.m
//  Tigase
//
//  Created by admin on 2019/8/5.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_changePhoneNumStepTwo.h"
#import "WH_CountryCodeViewController.h"
@interface WH_changePhoneNumStepTwo ()

@end

@implementation WH_changePhoneNumStepTwo
{
    UITextField *_phone;
    UITextField *_imgCode;
    UITextField *_CodeTf;
    UIButton *_areaBtn;
}
- (instancetype)init{
    if (self = [super init]) {
        self.wh_isGotoBack = YES;
        self.title = self.naviTitle;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    [self addSetUpViews];
}

#pragma mark - 下一步
- (void) nextBtnClick{
    NSLog(@"更换绑定");
    
}


//图片码
- (void) getImageCode:(UIButton *)sender{
    //    act_GetCode
    [g_server getImgCode:_phone.text areaCode:[WH_JXUserObject sharedUserInstance].areaCode];
}
//手机验证码
- (void) getPhoneCode:(UIButton *)sender{
    //    act_SendSMS
        NSString *areaCode = [_areaBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [g_server WH_sendSMSCodeWithTel:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
}



#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
}
#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}


//选择区域
#pragma mark 选择国家区域
- (void)areaCodeBtnClick:(UIButton *)but{
    [self.view endEditing:YES];
    WH_CountryCodeViewController *telAreaListVC = [[WH_CountryCodeViewController alloc] init];
    telAreaListVC.wh_telAreaDelegate = self;
    telAreaListVC.wh_didSelect = @selector(didSelectTelArea:);
    //    [g_window addSubview:telAreaListVC.view];
    [g_navigation pushViewController:telAreaListVC animated:YES];
}
- (void)didSelectTelArea:(NSString *)areaCode{
    [_areaBtn setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
}

- (void) addSetUpViews{
    UIView *bgView = [UIView new];
    UIButton *areaBtn = [UIButton new];
    UITextField *phoneNumTf = [UITextField new];
    UIView *lineView = [UIView new];
    UITextField *passTf = [UITextField new];
    UIButton *codeImgV = [UIButton new];
    UIView *codeTfBgView = [UIView new];
    UITextField *codeTf = [UITextField new];
    UIButton *getCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *nextSteepBtn = [UIButton new];
    
    [self.wh_tableBody addSubview:bgView];
    [bgView addSubview:areaBtn];
    [bgView addSubview:lineView];
    [bgView addSubview:phoneNumTf];
    [bgView addSubview:passTf];
    [bgView addSubview:codeImgV];
    [self.wh_tableBody addSubview:codeTfBgView];
    [codeTfBgView addSubview:codeTf];
    [self.wh_tableBody addSubview:getCodeBtn];
    [self.wh_tableBody addSubview:nextSteepBtn];
    
    
    _phone = phoneNumTf;
    _imgCode = passTf;
    _CodeTf = codeTf;
    _areaBtn = areaBtn;
    
    
    bgView.layer.cornerRadius = 10.0f;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.borderWidth = 1;
    bgView.layer.borderColor = RGB(245, 247, 250).CGColor;
    areaBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [areaBtn setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    [areaBtn setTitle:@"+86" forState:UIControlStateNormal];//根据地区匹配
    [areaBtn addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    phoneNumTf.placeholder = @"填写新的手机号";
    passTf.secureTextEntry = NO;
    passTf.placeholder = @"输入图形码";
    passTf.borderStyle = UITextBorderStyleNone;
    lineView.backgroundColor = RGB(245, 247, 250);
    [codeImgV setTitle:@"图片验证码" forState:UIControlStateNormal];
    [codeImgV addTarget:self action:@selector(getImageCode:) forControlEvents:UIControlEventTouchUpInside];
    codeImgV.titleLabel.font = [UIFont systemFontOfSize:15];
    [codeImgV setTitleColor:RGB(143, 156, 187) forState:UIControlStateNormal];
    
    
    codeTf.placeholder = @"输入验证码";
    codeTfBgView.backgroundColor = [UIColor whiteColor];
    codeTfBgView.layer.borderWidth = 1;
    codeTfBgView.layer.borderColor = RGB(245, 247, 250).CGColor;
    codeTfBgView.layer.cornerRadius = 10;
    phoneNumTf.font = passTf.font =  codeTf.font = [UIFont systemFontOfSize:15];
    getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [getCodeBtn setTitleColor:RGB(143, 156, 187) forState:UIControlStateNormal];
    [getCodeBtn setBackgroundColor:RGB(237, 239, 241)];
    getCodeBtn.layer.borderWidth = 0.5;
    getCodeBtn.layer.borderColor = [UIColor colorWithRed:219/255.0 green:224/255.0 blue:231/255.0 alpha:1.0].CGColor;
    getCodeBtn.layer.cornerRadius = 10;
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    
    
    [nextSteepBtn setTitle:@"更换绑定" forState:UIControlStateNormal];
    [nextSteepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextSteepBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    nextSteepBtn.layer.cornerRadius = 10;
    nextSteepBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    nextSteepBtn.backgroundColor = RGB(0, 147, 255);
    [nextSteepBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(11);
        make.right.mas_equalTo(self.view.mas_right).offset(-11);
        make.top.mas_equalTo(self.view.mas_top).offset(12 + JX_SCREEN_TOP);
        make.height.mas_equalTo(101);
    }];
    [areaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView);
        make.left.mas_equalTo(bgView.mas_left).offset(16);
        make.width.height.mas_equalTo(50);
    }];
    [phoneNumTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(areaBtn.mas_right).offset(10);
        make.right.mas_equalTo(bgView.mas_right).offset(-10);
        make.top.mas_equalTo(bgView);
        make.height.mas_equalTo(50);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(bgView);
        make.top.mas_equalTo(areaBtn.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    [passTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(bgView);
        make.left.mas_equalTo(bgView.mas_left).offset(16);
        make.top.mas_equalTo(lineView.mas_bottom);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(bgView.mas_bottom);
    }];
    [codeImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(bgView.mas_right).offset(-12);
        make.top.mas_equalTo(lineView.mas_bottom);
        make.bottom.mas_equalTo(bgView.mas_bottom);
        make.width.mas_equalTo(100);
    }];
    [codeTfBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(bgView.mas_leading);
        make.top.mas_equalTo(bgView.mas_bottom).offset(12);
        make.height.mas_equalTo(51);
        make.right.mas_equalTo(getCodeBtn.mas_left).offset(-10);
    }];
    [codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(0, 16, 0, 0));
    }];
    [getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.top.mas_equalTo(bgView.mas_bottom).offset(12);
        make.width.mas_equalTo(115);
        make.height.mas_equalTo(51);
    }];
    [nextSteepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(bgView);
        make.top.mas_equalTo(codeTf.mas_bottom).offset(20);
        make.height.mas_equalTo(44);
    }];
    
    [self.view layoutIfNeeded];
    getCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
