//
//  WH_PublicNumberLogin_WHVC.m
//  Tigase
//
//  Created by 闫振奎 on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_PublicNumberLogin_WHVC.h"

@interface WH_PublicNumberLogin_WHVC ()

@end

@implementation WH_PublicNumberLogin_WHVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wh_heightHeader = 0;
    self.wh_heightFooter = 0;
    self.wh_isGotoBack = NO;
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    titleLabel.textColor = HEXCOLOR(0x333333);
    switch (_type) {
        case WH_PublicNumberLoginKaiFangPingTai:
        {
            titleLabel.text = @"开放平台登陆确认";
        }
            break;
        case WH_PublicNumberLoginGongZhongPingTai:
        {
            titleLabel.text = @"公众平台登陆确认";
        }
            break;
        case WH_PublicNumberLoginPC:
        {
            titleLabel.text = @"PC端登陆确认";
        }
            break;
            
        default:
            break;
    }

    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    UIImageView *logoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WH_PublicNumberPc_WHIcon"]];
    [self.view addSubview:logoImgView];
    [logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(titleLabel.mas_top).offset(-29);
        make.centerX.equalTo(titleLabel);
    }];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(125);
        make.centerX.equalTo(titleLabel);
        make.size.mas_equalTo(CGSizeMake(185, 40));
    }];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
    loginBtn.layer.cornerRadius = 5.f;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = HEXCOLOR(0x0093FF);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(clickLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cancelLoginBtn];
    [cancelLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(loginBtn);
        make.top.equalTo(loginBtn.mas_bottom).offset(10);
    }];
    [cancelLoginBtn setTitle:@"取消登录" forState:UIControlStateNormal];
    [cancelLoginBtn setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
    cancelLoginBtn.titleLabel.font = sysFontWithSize(16);
    [cancelLoginBtn addTarget:self action:@selector(clickCancelLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickLoginBtn:(UIButton *)loginBtn{
    switch (_type) {
        case WH_PublicNumberLoginKaiFangPingTai:
        {
            [g_server openLoginPublicOpenAccReqWithQrCodeToken:self.qrCodeStr toView:self];
        }
            break;
        case WH_PublicNumberLoginGongZhongPingTai:
        {
            [g_server loginPublicAccountReqWithQrCodeToken:self.qrCodeStr toView:self];
        }
            break;
        case WH_PublicNumberLoginPC:
        {
            [g_server requestScanLoginWithScanContent:self.qrCodeStr toView:self];
        }
            break;
            
        default:
            break;
    }
    if(_type == WH_PublicNumberLoginKaiFangPingTai){
        
    } else {
        
    }
}

- (void)clickCancelLoginBtn:(UIButton *)cancelLoginBtn{
    [self actionQuit];
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:wh_act_consoleLoginPublicAcc] || [aDownload.action isEqualToString:wh_act_openLoginPublicOpenAcc]) {
        [self actionQuit];
    }else if ([aDownload.action isEqualToString:act_ScanLogin]) {
        
        [self actionQuit];
    }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
    [_wait start];
}

@end
