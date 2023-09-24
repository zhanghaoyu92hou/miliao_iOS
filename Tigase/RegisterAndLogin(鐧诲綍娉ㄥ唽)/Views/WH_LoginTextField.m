//
//  WH_PhoneTextField.m
//  Tigase
//
//  Created by 齐科 on 2019/8/17.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_LoginTextField.h"
#import "WH_CountryCodeViewController.h"

@interface WH_LoginTextField() <UITextFieldDelegate>
@property (nonatomic, strong) UIButton *areaCodeButton;
@property (nonatomic, strong) UIButton *openSecureButton; //!< 密码开关
@end

@implementation WH_LoginTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customProperties];
    }
    return self;
}

- (void)customProperties {
    NSString *userNamePlaceHolderStr = [self getAccountNameStr];//!< 用户名
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:userNamePlaceHolderStr attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.keyboardType = ([g_config.regeditPhoneOrName intValue] == 1) ? UIKeyboardTypeDefault : UIKeyboardTypeNumberPad;
    self.borderStyle = UITextBorderStyleNone;
    self.textColor = HEXCOLOR(0x333333);
    self.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.backgroundColor = [UIColor whiteColor];
    self.enablesReturnKeyAutomatically = YES;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    //        textField.borderStyle = UITextBorderStyleRoundedRect;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.clipsToBounds = YES;
}
- (NSString *)getAccountNameStr {
    NSString *userNameStr = ([g_config.regeditPhoneOrName intValue] == 1) ? Localized(@"JX_InputUserAccount") : Localized(@"JX_InputPhone");
    return userNameStr;
}

#pragma mark ---- ReWrite Setter
- (void)setCustomAttributePlaceHolder:(NSString *)placerHolder {
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placerHolder attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:15], NSForegroundColorAttributeName:HEXCOLOR(0xcccccc)}];
}
- (void)setFieldType:(LoginFieldType)fieldType {
    _fieldType = fieldType;
    switch (fieldType) {
        case LoginFieldPhoneNoType:
            {
                self.leftView = self.areaCodeButton;
                self.secureTextEntry = NO;
                self.returnKeyType = UIReturnKeyNext;
                self.keyboardType = UIKeyboardTypeNumberPad;
                [self setCustomAttributePlaceHolder:Localized(@"JX_InputPhone")];
            }
            break;
        case LoginFieldUserNameType:
        {
            self.leftView = [self leftBlankView];
            [self setCustomAttributePlaceHolder:Localized(@"JX_InputUserAccount")];
            self.keyboardType = UIKeyboardTypeDefault;  // 仅支持大小写字母数字
            self.secureTextEntry = NO;
            self.returnKeyType = UIReturnKeyNext;
        }
            break;
        case LoginFieldPassWordType:
        {
            self.leftView = [self leftBlankView];
            self.rightView = self.openSecureButton;
            self.returnKeyType = UIReturnKeyDone;
            [self setCustomAttributePlaceHolder:Localized(@"JX_InputPassWord")];
            self.secureTextEntry = YES;
            self.keyboardType = UIKeyboardTypeNamePhonePad;
            self.rightViewMode = UITextFieldViewModeAlways;
        }
            break;
        case LoginFieldSmsVerifyCodeType:
        {
            self.leftView = [self leftBlankView];;
            self.returnKeyType = UIReturnKeyDone;
            self.secureTextEntry = NO;
            self.keyboardType = UIKeyboardTypeNumberPad;
            [self setCustomAttributePlaceHolder:Localized(@"JX_InputMessageCode")];
        }
            break;
        case LoginFieldImgVerifyCodeType:
        {
            self.leftView = [self leftBlankView];;
            self.returnKeyType = UIReturnKeyDone;
            self.secureTextEntry = NO;
            self.keyboardType = UIKeyboardTypeDefault;
             [self setCustomAttributePlaceHolder:Localized(@"JX_inputImgCode")];
        }
            break;
        case LoginFieldInviteCodeType:
        {
            self.leftView = [self leftBlankView];;
            self.returnKeyType = UIReturnKeyDone;
            self.secureTextEntry = NO;
            self.keyboardType = UIKeyboardTypeDefault;
//            [self setCustomAttributePlaceHolder:Localized(@"JX_EnterInvitationCode")];
            
            NSString *len = [JXMyTools getCurrentSysLanguage];
            NSString *code;
            if ([len isEqualToString:@"zh"]) {
                code = @"请输入军属邀请码";
            } else if ([len isEqualToString:@"en"]) {
                code = @"Invite code please";
            } else {
                code = @"請輸入軍屬邀請碼";
            }
            [self setCustomAttributePlaceHolder:code];
            
            self.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
            break;
            
        default:
            break;
    }
}
- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    
}
- (UIView *)leftBlankView {
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.height)];
    blankView.backgroundColor = [UIColor clearColor];
    return blankView;
}
- (UIButton *)openSecureButton {
    if (!_openSecureButton) {
        _openSecureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.width-40, 40, self.height)];
        [_openSecureButton setImage:[UIImage imageNamed:@"hide_pass"] forState:UIControlStateNormal];
        [_openSecureButton setImage:[UIImage imageNamed:@"show_pass"] forState:UIControlStateSelected];
        [_openSecureButton addTarget:self action:@selector(openSecure:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openSecureButton;
}
- (void)openSecure:(UIButton *)button {
    button.selected = !button.selected;
    self.secureTextEntry = !button.selected;
}
#pragma mark ----- Lazy Load
- (UIButton *)areaCodeButton {
    if (!_areaCodeButton) {
        NSString *areaStr = [self getAreaCodeStr];
        _areaCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_areaCodeButton setFrame:CGRectMake(0, 0, 60, self.height)];
        [_areaCodeButton setTitle:areaStr forState:UIControlStateNormal];
        _areaCodeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        [_areaCodeButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _areaCodeButton.custom_acceptEventInterval = 1.0f;
        [_areaCodeButton addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self resetBtnEdgeInsets:_areaCodeButton];
    }
    return _areaCodeButton;
}

- (NSString *)getAreaString {
    NSString *areaString = @"";
    if (self.areaCodeButton.titleLabel.text.length > 0) {
        areaString = [self.areaCodeButton.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    return areaString;
}

- (NSString *)getAreaCodeStr {
    NSString *areaStr = @"+86";
    NSString *codeStr = [g_default objectForKey:kMY_USER_AREACODE];
    if (!IsStringNull(codeStr)) {
        areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
    }
    return areaStr;
}
- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}

#pragma mark 选择国家区域
- (void)areaCodeBtnClick:(UIButton *)but{
    [self endEditing:YES];
    WH_CountryCodeViewController *telAreaListVC = [[WH_CountryCodeViewController alloc] init];
    telAreaListVC.wh_telAreaDelegate = self;
    telAreaListVC.wh_didSelect = @selector(didSelectTelArea:);
    //    [g_window addSubview:telAreaListVC.view];
    [g_navigation pushViewController:telAreaListVC animated:YES];
}

- (void)didSelectTelArea:(NSString *)areaCode{
    [self.areaCodeButton setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
    [self resetBtnEdgeInsets:self.areaCodeButton];
    if (self.areaCodeBlock) {
        self.areaCodeBlock(areaCode);
    }
}

@end
