//
//  WH_JXVerifyPay_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXVerifyPay_WHVC.h"
#import "WH_JXTextField.h"


#define kDotSize CGSizeMake (10, 10) //密码点的大小
#define kDotCount 6  //密码个数
#define K_Field_Height 45  //每一个输入框的高度

@interface WH_JXVerifyPay_WHVC () <UITextFieldDelegate>
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UILabel *typeLab;

@property (nonatomic, strong) WH_JXTextField *textField;
@property (nonatomic, strong) NSMutableArray *dotArray; //用于存放黑色的点点
@property (nonatomic, strong) UIButton *disBtn;
@property (nonatomic, strong) UILabel *serviceChargeTitleLabel;     //手续费标题
@property (nonatomic, strong) UILabel *serviceChargeContentLabel;   //手续费值
@property (nonatomic, strong) UILabel *serviceChargeRateTitleLabel; //费率标题
@property (nonatomic, strong) UILabel *serviceChargeRateContentLabel;//费率值

@end

@implementation WH_JXVerifyPay_WHVC


- (instancetype)init {
    self = [super init];
    if (self) {
        [self WH_setupViews];
        [self initPwdTextField];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.modalPresentationStyle = UIModalPresentationCustom;
    [self.textField becomeFirstResponder];
}

- (void)WH_setupViews {
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(20, 160, JX_SCREEN_WIDTH-20*2, 232)];
    if (self.type == JXVerifyTypeWithdrawal) {//提现
        self.baseView.height = self.baseView.height + 70;
    }
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self.baseView.layer.cornerRadius = 15.f;
    //    _baseView.center = CGPointMake(_baseView.center.x, self.view.center.y);
    [self.view addSubview:self.baseView];
    
    self.disBtn = [[UIButton alloc] initWithFrame:CGRectMake(12, 13, 28, 28)];
    [_disBtn setImage:[UIImage imageNamed:@"WH_CloseBtn"] forState:UIControlStateNormal];
    [self.disBtn addTarget:self action:@selector(didWH_dismiss_WHVerifyPayVC) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:self.disBtn];
    //    UIImageView *dis = [[UIImageView alloc] initWithFrame:CGRectMake(15, 35/2, 18, 18)];
    //    dis.image = [UIImage imageNamed:@"WH_CloseBtn"];
    //    [self.disBtn addSubview:dis];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.baseView.frame.size.width, 22)];
    titleLab.text = Localized(@"JX_EnterPayPsw");
    titleLab.font = pingFangMediumFontWithSize(18);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = HEXCOLOR(0x8C9AB8);
    [self.baseView addSubview:titleLab];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLab.frame)+15, self.baseView.frame.size.width, 0.5)];
    line.backgroundColor = HEXCOLOR(0xe8e8e8);
    [self.baseView addSubview:line];
    
    self.typeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame)+15, self.baseView.frame.size.width, 20)];
    self.typeLab.textAlignment = NSTextAlignmentCenter;
    self.typeLab.font = sysFontWithSize(14);
    self.typeLab.textColor = HEXCOLOR(0x3A404C);
    self.typeLab.text = [self WH_getTypeTitle];
    
    [self.baseView addSubview:self.typeLab];
    
    self.RMBLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.typeLab.frame)+11, self.baseView.frame.size.width, 50)];
    self.RMBLab.textAlignment = NSTextAlignmentCenter;
    self.RMBLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 30];
    self.RMBLab.textColor = HEXCOLOR(0x3A404C);
    self.RMBLab.text = [NSString stringWithFormat:@"¥%.2f",[self.wh_RMB doubleValue]];
    [self.baseView addSubview:self.RMBLab];
    
    if (self.type == JXVerifyTypeWithdrawal) {//提现
        self.serviceChargeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.RMBLab.frame)+15, 80, 20)];
        self.serviceChargeTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.serviceChargeTitleLabel.font = sysFontWithSize(14);
        self.serviceChargeTitleLabel.textColor = HEXCOLOR(0x8C9AB8);
        self.serviceChargeTitleLabel.text = @"手续费";
        [self.baseView addSubview:self.serviceChargeTitleLabel];
        
        self.serviceChargeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width - 80 - 10, self.serviceChargeTitleLabel.top, 80, 20)];
        self.serviceChargeContentLabel.textAlignment = NSTextAlignmentRight;
        self.serviceChargeContentLabel.font = sysFontWithSize(14);
        self.serviceChargeContentLabel.textColor = HEXCOLOR(0x8C9AB8);
        double rmb = [self.wh_RMB doubleValue];
        CGFloat transferRate = g_config.transferRate.floatValue;
        CGFloat serviceCharge = ceilf(rmb * transferRate) / 100;
        self.serviceChargeContentLabel.text = [NSString stringWithFormat:@"%.2f", serviceCharge];
        [self.baseView addSubview:self.serviceChargeContentLabel];
        
        self.serviceChargeRateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.serviceChargeContentLabel.frame)+15, 80, 20)];
        self.serviceChargeRateTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.serviceChargeRateTitleLabel.font = sysFontWithSize(14);
        self.serviceChargeRateTitleLabel.textColor = HEXCOLOR(0x8C9AB8);
        self.serviceChargeRateTitleLabel.text = @"费率";
        [self.baseView addSubview:self.serviceChargeRateTitleLabel];
        
        self.serviceChargeRateContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width - 80 - 10, self.serviceChargeRateTitleLabel.top, 80, 20)];
        self.serviceChargeRateContentLabel.textAlignment = NSTextAlignmentRight;
        self.serviceChargeRateContentLabel.font = sysFontWithSize(14);
        self.serviceChargeRateContentLabel.textColor = HEXCOLOR(0x8C9AB8);
        self.serviceChargeRateContentLabel.text = [NSString stringWithFormat:@"%.f%%", ceilf(transferRate)];
        [self.baseView addSubview:self.serviceChargeRateContentLabel];
    }
    
    UIView *btmLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.RMBLab.frame)+8, self.baseView.frame.size.width, 0.5)];
    if (self.type == JXVerifyTypeWithdrawal) {
        btmLine.frame = CGRectMake(0, CGRectGetMaxY(self.serviceChargeRateTitleLabel.frame)+8, self.baseView.frame.size.width, 0.5);
    }
    btmLine.backgroundColor = HEXCOLOR(0xe8e8e8);
    [self.baseView addSubview:btmLine];
    
    self.textField.frame = CGRectMake(16, CGRectGetMaxY(btmLine.frame)+12, self.baseView.frame.size.width - 32, K_Field_Height);
    
    [self.baseView addSubview:self.textField];
}


- (NSString *)WH_getTypeTitle {
    NSString *string;
    if (self.type == JXVerifyTypeWithdrawal) {
        string = Localized(@"JXMoney_withdrawals");
    }
    else if (self.type == JXVerifyTypeTransfer) {
        string = @"转账";
    }
    else if (self.type == JXVerifyTypeQr) {
        string = @"付款";
    }
    else if (self.type == JXVerifyTypeSkPay) {
        string = self.wh_titleStr;
    }
    else {
        string = Localized(@"JX_ShikuRedPacket");
    }
    return string;
}


- (void)didWH_dismiss_WHVerifyPayVC {
    if (self.delegate && [self.delegate respondsToSelector:self.didDismissVC]) {
        [self.delegate performSelectorOnMainThread:self.didDismissVC withObject:self waitUntilDone:NO];
    }
}

- (void)initPwdTextField
{
    //每个密码输入框的宽度
    CGFloat width = (self.baseView.frame.size.width - 32) / kDotCount;
    
    //生成分割线
    for (int i = 0; i < kDotCount - 1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (i + 1) * width, CGRectGetMinY(self.textField.frame), 0.5, K_Field_Height)];
        lineView.backgroundColor = HEXCOLOR(0xDBE0E7);
        [self.baseView addSubview:lineView];
    }
    
    self.dotArray = [[NSMutableArray alloc] init];
    //生成中间的点
    for (int i = 0; i < kDotCount; i++) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (width - kDotCount) / 2 + i * width, CGRectGetMinY(self.textField.frame) + (K_Field_Height - kDotSize.height) / 2, kDotSize.width, kDotSize.height)];
        dotView.backgroundColor = [UIColor blackColor];
        dotView.layer.cornerRadius = kDotSize.width / 2.0f;
        dotView.clipsToBounds = YES;
        dotView.hidden = YES; //先隐藏
        [self.baseView addSubview:dotView];
        //把创建的黑色点加入到数组中
        [self.dotArray addObject:dotView];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"]) {
        //按回车关闭键盘
        [textField resignFirstResponder];
        return NO;
    } else if(string.length == 0) {
        //判断是不是删除键
        return YES;
    }
    else if(textField.text.length >= kDotCount) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        return NO;
    } else {
        return YES;
    }
}

/**
 *  清除密码
 */
- (void)WH_clearUpPassword
{
    self.textField.text = @"";
    [self textFieldDidChange:self.textField];
}

/**
 *  获取密码(MD5加密)
 */
- (NSString *)WH_getMD5Password {
    return [g_server WH_getMD5StringWithStr:self.textField.text];
}

/**
 *  重置显示的点
 */
- (void)textFieldDidChange:(UITextField *)textField
{
    for (UIView *dotView in self.dotArray) {
        dotView.hidden = YES;
    }
    for (int i = 0; i < textField.text.length; i++) {
        ((UIView *)[self.dotArray objectAtIndex:i]).hidden = NO;
    }
    if (textField.text.length == kDotCount) {
        if (self.delegate && [self.delegate respondsToSelector:self.didDismissVC]) {
            [self.delegate performSelectorOnMainThread:self.didVerifyPay withObject:self.textField.text waitUntilDone:NO];
        }
    }
}

#pragma mark - init

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[WH_JXTextField alloc] init];
        _textField.backgroundColor = [UIColor whiteColor];
        //输入的文字颜色为白色
        _textField.textColor = [UIColor whiteColor];
        //输入框光标的颜色为白色
        _textField.tintColor = [UIColor whiteColor];
        _textField.delegate = self;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.layer.borderColor = [HEXCOLOR(0xDBE0E7) CGColor];
        _textField.layer.borderWidth = 0.5;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}



- (void)sp_didUserInfoFailed {
    NSLog(@"Check your Network");
}
@end
