//
//  WH_JXCollectMoney_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/6.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXCollectMoney_WHVC.h"
#import "WH_QRImage.h"
#import "WH_JXInputMoney_WHVC.h"

#import "WH_JXScanQR_WHViewController.h"

@interface WH_JXCollectMoney_WHVC ()
@property (nonatomic, strong) NSString *money;
@property (nonatomic, strong) NSString *desStr;
@property (nonatomic, strong) UIImageView *qrCode;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rigLabel;
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UILabel *moneyLab;
@property (nonatomic, strong) UILabel *descLab;
@property (nonatomic, strong) UILabel *barCodeLab;
@property (nonatomic ,strong) UIView *yView;

@end

@implementation WH_JXCollectMoney_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_heightFooter = 0;
    self.title = @"收付款";
    self.wh_isGotoBack = YES;
    
    [self createHeadAndFoot];
    
    [self WH_setupViews];
    
//    [self setupNav];
    
    [g_notify addObserver:self selector:@selector(notifyPaymentGet:) name:kXMPPMessageQrPayment_WHNotification object:nil];
}

- (void)notifyPaymentGet:(NSNotification *)noti {
    WH_JXMessageObject *msg = noti.object;
    if ([msg.type intValue] == kWCMessageTypeReceiptGet) {
        [g_server showMsg:Localized(@"JX_PaymentReceived")];
        [self updateQr];
    }
}

- (void)setupNav {
    UIView *nav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
//    nav.backgroundColor = HEXCOLOR(0x449ad4);
    [self.view addSubview:nav];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(NAV_INSETS, JX_SCREEN_TOP - 38, NAV_BTN_SIZE, NAV_BTN_SIZE)];
    [btn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:btn];
    
    UILabel *p = [[UILabel alloc]initWithFrame:CGRectMake(40, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-40*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = [UIColor whiteColor];
    p.text = Localized(@"JX_QrCodeCollection");
    [nav addSubview:p];
}

- (void)WH_setupViews {
//    self.wh_tableBody.backgroundColor = HEXCOLOR(0x449ad4);
//    [self setupView:self.view colors:@[(__bridge id)HEXCOLOR(0x449ad4).CGColor,(__bridge id)HEXCOLOR(0x1953AF).CGColor]];

    [self.wh_tableBody setBackgroundColor:HEXCOLOR(0x0093FF)];
    
    _baseView = [[UIView alloc] initWithFrame:CGRectMake(12, JX_SCREEN_TOP+40, JX_SCREEN_WIDTH-24, 451)];
    _baseView.backgroundColor = [UIColor whiteColor];
    _baseView.layer.masksToBounds = YES;
    _baseView.layer.cornerRadius = 5.f;
    [self.view addSubview:_baseView];
    
//    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
//    img.image = [UIImage imageNamed:@"pay_wallet_blue"];
//    [_baseView addSubview:img];
//
//    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(img.frame)+10, 13, 100, 18)];
//    payLabel.text = Localized(@"JX_QrCodeCollection");
//    payLabel.textColor = HEXCOLOR(0x449ad4);
//    [_baseView addSubview:payLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(_baseView.frame), 30)];
    [label setText:@"扫一扫，向我付款"];
    [label setTextColor:HEXCOLOR(0x333333)];
    [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [_baseView addSubview:label];
    
    self.yView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), CGRectGetWidth(_baseView.frame), 36)];
    [self.yView setBackgroundColor:HEXCOLOR(0xFEFCEC)];
    [_baseView addSubview:self.yView];
    
    UILabel *yLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.yView.frame), CGRectGetHeight(self.yView.frame))];
    [yLabel setText:@"收款直接到账"];
    [yLabel setTextAlignment:NSTextAlignmentCenter];
    [yLabel setTextColor:HEXCOLOR(0xF76A24)];
    [yLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
    [self.yView addSubview:yLabel];
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(payLabel.frame)+13, _baseView.frame.size.width, .5)];
//    line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
//    [_baseView addSubview:line];
    
//    _barCodeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(yView.frame)+10, _baseView.frame.size.width, 15)];
//    _barCodeLab.text = Localized(@"JX_ScanQrCodeToPayMe");
//    _barCodeLab.textColor = [UIColor lightGrayColor];
//    _barCodeLab.font = sysFontWithSize(14);
//    _barCodeLab.textAlignment = NSTextAlignmentCenter;
//    [_baseView addSubview:_barCodeLab];
    
    UIView *lView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_baseView.frame) - 2)/2, CGRectGetHeight(_baseView.frame) - 43, 2, 20)];
    [lView setBackgroundColor:HEXCOLOR(0xE5E5E5)];
    [_baseView addSubview:lView];
    
    //金额
    _moneyLab = [[UILabel alloc] init];
    _moneyLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 40];
    _moneyLab.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_moneyLab];
    
    //说明
    _descLab = [[UILabel alloc] init];
    _descLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    _descLab.textColor = HEXCOLOR(0xBAC3D5);
    _descLab.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_descLab];

    // 二维码
    _qrCode = [[UIImageView alloc] init];
    [_baseView addSubview:_qrCode];
    
    // 设置金额
    _leftLabel = [[UILabel alloc] init];
    _leftLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    _leftLabel.textColor = HEXCOLOR(0x108EE9);
    _leftLabel.userInteractionEnabled = YES;
    _leftLabel.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_leftLabel];
    UITapGestureRecognizer *tapL = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setMoneyCount)];
    [_leftLabel addGestureRecognizer:tapL];

//    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(_leftLabel.frame.size.width-.5, -5, .5, 25)];
//    botLine.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
//    [_leftLabel addSubview:botLine];
    
    // 保存收款码
    _rigLabel = [[UILabel alloc] init];
    _rigLabel.text = Localized(@"JX_SaveCollectionCode");
    _rigLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    _rigLabel.textColor = HEXCOLOR(0x108EE9);
    _rigLabel.userInteractionEnabled = YES;
    _rigLabel.textAlignment = NSTextAlignmentCenter;
    [_baseView addSubview:_rigLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveQr)];
    [_rigLabel addGestureRecognizer:tap];

    [self updateViews];
    
    UIButton *scanView = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanView setFrame:CGRectMake(12,CGRectGetMaxY(_baseView.frame) + 12, JX_SCREEN_WIDTH - 24, 55)];
    [scanView setBackgroundColor:HEXCOLOR(0xffffff)];
    scanView.layer.cornerRadius = 5;
    scanView.layer.masksToBounds = YES;
    [self.view addSubview:scanView];
    
    UIImageView *sImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
    [sImgView setImage:[UIImage imageNamed:@"WH_Scan_Icon"]];
    [scanView addSubview:sImgView];
    
    UILabel *sLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sImgView.frame) + 12, 0, 60, CGRectGetHeight(scanView.frame))];
    [sLabel setText:@"去付钱"];
    [sLabel setTextColor:HEXCOLOR(0x0093FF)];
    [sLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]];
    [scanView addSubview:sLabel];
    
    UIImageView *mImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(scanView.frame) - 19, (CGRectGetHeight(scanView.frame) - 12)/2, 7, 12)];
    [mImgView setImage:[UIImage imageNamed:@"WH_Back"]];
    [scanView addSubview:mImgView];
    
    UILabel *mLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(scanView.frame) - 19 - 10 - 70, 0, 70, CGRectGetHeight(scanView.frame))];
    [mLabel setText:@"扫一扫付款"];
    [mLabel setTextColor:HEXCOLOR(0x333333)];
    [mLabel setTextAlignment:NSTextAlignmentRight];
    [mLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
    [scanView addSubview:mLabel];
    
    [scanView addTarget:self action:@selector(scanMethod) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 更新界面
- (void)updateViews {
    //金额
    CGSize mSize  = [self.money sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size: 40]}];
    _moneyLab.text = [NSString stringWithFormat:@"¥%.2f",[self.money doubleValue]];
    _moneyLab.frame = CGRectMake(0, CGRectGetMaxY(_qrCode.frame)+10, _baseView.frame.size.width, mSize.height);
    //说明
    CGSize dSize  = [self.desStr sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(14)}];
    _descLab.text = self.desStr;
    _descLab.frame = CGRectMake(0, CGRectGetMaxY(_moneyLab.frame)+5, _baseView.frame.size.width, dSize.height);
    //二维码
    _qrCode.frame = CGRectMake((_baseView.frame.size.width - 200)/2, CGRectGetMaxY(self.yView.frame) + 10, 200, 200);
    //设置金额
    _leftLabel.text = self.money.length > 0 ? Localized(@"JX_RemoveTheAmount") : Localized(@"JX_SetTheAmount");
    _leftLabel.frame = CGRectMake(0, CGRectGetHeight(_baseView.frame) - 45 , _baseView.frame.size.width*0.5 - 30, 20);
    
    // 保存收款码
    _rigLabel.frame = CGRectMake(_baseView.frame.size.width*0.5 + 30, _leftLabel.frame.origin.y, _baseView.frame.size.width*0.5 - 30, 20);
    
    _baseView.frame = CGRectMake(12, JX_SCREEN_TOP+40, JX_SCREEN_WIDTH-24, CGRectGetMaxY(_leftLabel.frame) + 30);
    
    [self updateQr];

}

- (void)setMoneyCount {
    if (self.money.length > 0) {
        self.money = nil;
        self.desStr = nil;
        [self updateViews];
        return;
    }
    WH_JXInputMoney_WHVC *inputVC = [[WH_JXInputMoney_WHVC alloc] init];
    inputVC.type = JXInputMoneyTypeSetMoney;
    inputVC.delegate = self;
    inputVC.onInputMoney = @selector(onInputMoney:);
    [g_navigation pushViewController:inputVC animated:YES];
}

- (void)onInputMoney:(NSDictionary *)dict {
    if ([dict objectForKey:@"money"]) {
        self.money = [dict objectForKey:@"money"];
    }
    if ([dict objectForKey:@"desc"]) {
        self.desStr = [dict objectForKey:@"desc"];
    }
    [self updateViews];
}

#pragma mark - 保存二维码到相册
- (void)saveQr {
    UIImageWriteToSavedPhotosAlbum(self.qrCode.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error){
        [g_server showMsg:Localized(@"ImageBrowser_saveFaild")];
    }else{
        [g_server showMsg:Localized(@"ImageBrowser_saveSuccess")];
    }
}


#pragma mark - 更新二维码
- (void)updateQr {
    UIImageView *imageView = [[UIImageView alloc] init];
    [g_server WH_getHeadImageLargeWithUserId:MY_USER_ID userName:MY_USER_NAME imageView:imageView];
    
    _qrCode.image = [WH_QRImage qrImageForString:[self getQrCode] imageSize:_qrCode.frame.size.width logoImage:imageView.image logoImageSize:30];
}

#pragma mark 扫码付款
- (void)scanMethod {
    WH_JXScanQR_WHViewController * scanVC = [[WH_JXScanQR_WHViewController alloc] init];
    [g_navigation pushViewController:scanVC animated:YES];
}

- (NSString *)getQrCode {
    NSMutableDictionary *dict = @{@"userId":MY_USER_ID,@"userName":MY_USER_NAME}.mutableCopy;
    if (self.money.length > 0) {
        [dict addEntriesFromDictionary:@{@"money":self.money}];
    }
    if (self.desStr.length > 0) {
        [dict addEntriesFromDictionary:@{@"description":self.desStr}];
    }
    

    
    return [dict mj_JSONString];
}


- (void)setupView:(UIView *)view colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, THE_DEVICE_HAVE_HEAD ? -44 : -20, JX_SCREEN_WIDTH, THE_DEVICE_HAVE_HEAD ? JX_SCREEN_HEIGHT+44 : JX_SCREEN_HEIGHT+20);  // 设置显示的frame
    gradientLayer.colors = colors;  // 设置渐变颜色
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [view.layer addSublayer:gradientLayer];
}


@end
