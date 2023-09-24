//
//  WH_JXTransfer_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTransfer_WHViewController.h"
#import "UIImage+WH_Color.h"
#import "WH_JXVerifyPay_WHVC.h"
#import "BindTelephoneChecker.h"

#define drawMarginX 25
#define bgWidth JX_SCREEN_WIDTH-15*2
#define drawHei 60

@interface WH_JXTransfer_WHViewController () <UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UITextField * countTextField;
@property (nonatomic, strong) UIButton *transferBtn;
@property (nonatomic, strong) UILabel *addDscLab;
@property (nonatomic, strong) UILabel *dscLab;
@property (nonatomic, strong) NSString *desContent;
@property (nonatomic, strong) WH_JXVerifyPay_WHVC *verVC;


@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *replayTitle;
@property (nonatomic, strong) UITextField *replayTextField;

@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation WH_JXTransfer_WHViewController

- (instancetype)init {
    if (self = [super init]) {
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        [self createHeadAndFoot];
        [self WH_setupViews];
        
//        [self WH_setupReplayView];
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = Localized(@"JX_Transfer");
}

- (void)WH_setupViews {
    self.wh_tableBody.backgroundColor = g_factory.globalBgColor;

   UIView *headerBgV = [[UIView alloc] initWithFrame:CGRectMake(10, 13, JX_SCREEN_WIDTH - 10 * 2, 83)];
   [g_factory setViewCardStyle:headerBgV];
   [self.wh_tableBody addSubview:headerBgV];
   
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(headerBgV.frame) - 35)/2.f, 12, 35, 35)];
    icon.layer.masksToBounds = YES;
    icon.layer.cornerRadius = icon.frame.size.width/2;
    [headerBgV addSubview:icon];
   
    NSString *name = _wh_user.remarkName.length > 0 ? _wh_user.remarkName : _wh_user.userNickname;
    [g_server WH_getHeadImageLargeWithUserId:_wh_user.userId userName:name imageView:icon];
   
//    CGSize size = [name sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(14)}];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(icon.frame)+8, CGRectGetWidth(headerBgV.frame) - 10*2, 20)];
    nameLabel.font = sysFontWithSize(14);
    nameLabel.textColor = HEXCOLOR(0x3A404C);
    nameLabel.text = name;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [headerBgV addSubview:nameLabel];
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(INSETS, CGRectGetMaxY(headerBgV.frame)+12, JX_SCREEN_WIDTH - INSETS*2, 55)];
    [g_factory setViewCardStyle:baseView];
    [self.wh_tableBody addSubview:baseView];
    
//    UIBezierPath *cornerRadiusPath = [UIBezierPath bezierPathWithRoundedRect:baseView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(15, 15)];
//    CAShapeLayer *cornerRadiusLayer = [ [CAShapeLayer alloc ] init];
//    cornerRadiusLayer.frame = baseView.bounds;
//    cornerRadiusLayer.path = cornerRadiusPath.CGPath;
//    baseView.layer.mask = cornerRadiusLayer;

    
    UILabel * cashTitle = [UIFactory WH_create_WHLabelWith:CGRectMake(15, 0, 66, CGRectGetHeight(baseView.frame)) text:Localized(@"JX_TransferAmount")];
    cashTitle.textColor = HEXCOLOR(0x333333);
    cashTitle.font = sysFontWithSize(16);
    [baseView addSubview:cashTitle];
    
    UILabel * rmbLabel = [UIFactory WH_create_WHLabelWith:CGRectMake(CGRectGetWidth(baseView.frame) - 15 - 17, 0, 17, CGRectGetHeight(baseView.frame)) text:@"元"];
    rmbLabel.font = sysFontWithSize(16);
    rmbLabel.textColor = HEXCOLOR(0x3A404C);
    rmbLabel.textAlignment = NSTextAlignmentLeft;
   
    [baseView addSubview:rmbLabel];
    
    _countTextField = [UIFactory WH_create_WHTextFieldWithRect:CGRectMake(CGRectGetMaxX(cashTitle.frame), 0, CGRectGetMinX(rmbLabel.frame) - 8 - 15 - 66, CGRectGetHeight(baseView.frame)) keyboardType:UIKeyboardTypeDecimalPad secure:NO placeholder:@"0.00" font:sysFontWithSize(16) color:HEXCOLOR(0x969696) delegate:self];
    _countTextField.borderStyle = UITextBorderStyleNone;
   _countTextField.textAlignment = NSTextAlignmentRight;
    [baseView addSubview:_countTextField];
   [_countTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
//    UIView * line = [[UIView alloc] init];
//    line.frame = CGRectMake(drawMarginX, CGRectGetMaxY(_countTextField.frame)+5, bgWidth-drawMarginX*2, 0.8);
//    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
//    [baseView addSubview:line];
   
   UIView *transferBgV = [[UIView alloc] initWithFrame:CGRectMake(INSETS,CGRectGetMaxY(baseView.frame)+12,JX_SCREEN_WIDTH - INSETS * 2,55)];
   [g_factory setViewCardStyle:transferBgV];
   [self.wh_tableBody addSubview:transferBgV];
   
   //转账说明内容
   UILabel *transferDesTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 66, CGRectGetHeight(transferBgV.frame))];
   transferDesTitle.textColor = HEXCOLOR(0x333333);
   transferDesTitle.font = sysFontWithSize(16);
   transferDesTitle.text = Localized(@"JX_TransferInstructions");
   [transferBgV addSubview:transferDesTitle];
   
   self.replayTextField = [self WH_createMiXinTextField:self.baseView default:nil hint:nil];
   self.replayTextField.frame = CGRectMake(CGRectGetMaxX(transferDesTitle.frame) + 20, 0, CGRectGetWidth(transferBgV.frame) - (CGRectGetMaxX(transferDesTitle.frame) + 20), CGRectGetHeight(transferBgV.frame));
   self.replayTextField.delegate = self;
   self.replayTextField.textColor = HEXCOLOR(0x333333);
   if (@available(iOS 10, *)) {
       self.replayTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_Maximum10Words") attributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x969696)}];
   } else {
       [self.replayTextField setValue:HEXCOLOR(0x969696) forKeyPath:@"_placeholderLabel.textColor"];
   }
   self.replayTextField.placeholder = Localized(@"JX_Maximum10Words");
   [self.replayTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
   [transferBgV addSubview:self.replayTextField];
//    _dscLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 17, 66, 23)];
//    [baseView addSubview:_dscLab];
    // 添加转账说明
//    _addDscLab = [[UILabel alloc] initWithFrame:CGRectMake(drawMarginX, CGRectGetMaxY(line.frame)+15, 120, 18)];
//    _addDscLab.text = Localized(@"JX_AddTransferInstructions");
//    _addDscLab.textColor = HEXCOLOR(0x6E7B8F);
//    _addDscLab.userInteractionEnabled = YES;
//    [baseView addSubview:_addDscLab];
   
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSendTransferDsc)];
//    [_addDscLab addGestureRecognizer:tap];

   //金额
   _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, CGRectGetMaxY(transferBgV.frame) + 12, JX_SCREEN_WIDTH - INSETS*2, 56)];
   _moneyLabel.textColor = HEXCOLOR(0x3A404C);
   _moneyLabel.font = [UIFont systemFontOfSize:40];
   _moneyLabel.textAlignment = NSTextAlignmentCenter;
   _moneyLabel.text = @"¥0.00";
   [self.wh_tableBody addSubview:_moneyLabel];
   
    _transferBtn = [UIFactory WH_create_WHButtonWithRect:CGRectZero title:Localized(@"JX_Transfer") titleFont:sysFontWithSize(17) titleColor:[UIColor whiteColor] normal:nil selected:nil selector:@selector(transferBtnAction:) target:self];
    _transferBtn.tag = 1000;
    _transferBtn.frame = CGRectMake(INSETS, CGRectGetMaxY(_moneyLabel.frame)+16, JX_SCREEN_WIDTH-INSETS*2, 44);
   [_transferBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   _transferBtn.titleLabel.font = sysFontWithSize(16);
    [_transferBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x0093FF)] forState:UIControlStateNormal];
    [_transferBtn setBackgroundImage:[UIImage createImageWithColor:[HEXCOLOR(0x0093FF) colorWithAlphaComponent:0.8f]] forState:UIControlStateDisabled];
    _transferBtn.layer.cornerRadius = 10;
    _transferBtn.clipsToBounds = YES;
   _transferBtn.enabled = NO;
   
    [self.wh_tableBody addSubview:_transferBtn];
}


/*
- (void)WH_setupReplayView {
    int height = 44;
    self.bigView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.bigView.hidden = YES;
    [g_App.window addSubview:self.bigView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.bigView addGestureRecognizer:tap];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self. baseView.layer.cornerRadius = 4.0f;
    [self.bigView addSubview:self.baseView];
    int n = 20;
    _replayTitle = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, n, self.baseView.frame.size.width - INSETS*2, 20)];
    _replayTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _replayTitle.textAlignment = NSTextAlignmentCenter;
    _replayTitle.textColor = HEXCOLOR(0x595959);
    _replayTitle.font = [UIFont boldSystemFontOfSize:17];
    _replayTitle.text = Localized(@"JX_TransferInstructions");
    [self.baseView addSubview:_replayTitle];
    
    n = n + height;
    self.replayTextField = [self WH_createMiXinTextField:self.baseView default:nil hint:nil];
    self.replayTextField.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    self.replayTextField.frame = CGRectMake(10, n, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.replayTextField.delegate = self;
    self.replayTextField.textColor = HEXCOLOR(0x595959);
    self.replayTextField.placeholder = Localized(@"JX_Maximum10Words");
    [self.replayTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    n = n + INSETS + height;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, n, self.baseView.frame.size.width, 44)];
    [self.baseView addSubview:self.topView];
    
    // 两条线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, 0.5)];
    topLine.backgroundColor = HEXCOLOR(0xD6D6D6);
    [self.topView addSubview:topLine];
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, 0, 0.5, self.topView.frame.size.height)];
    botLine.backgroundColor = HEXCOLOR(0xD6D6D6);
    [self.topView addSubview:botLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:sysFontWithSize(15)];
    [cancelBtn addTarget:self action:@selector(hideBigView) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancelBtn];
    // 确定
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [sureBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0x383893) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:sysFontWithSize(15)];
    [sureBtn addTarget:self action:@selector(onRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:sureBtn];
    
}
 */
- (void)hideBigView {
    [self resignKeyBoard];
}

- (void)onRelease {
    [self resignKeyBoard];
    self.desContent = _replayTextField.text;
    
    _dscLab.text = self.desContent;
   _addDscLab.text = self.desContent.length > 0 ? Localized(@"JX_Modify") : Localized(@"JX_AddTransferInstructions");
    CGSize size = [self.desContent sizeWithAttributes:@{NSFontAttributeName:sysFontWithSize(17)}];
    _dscLab.frame = CGRectMake(drawMarginX, _dscLab.frame.origin.y, size.width, 18);
    _addDscLab.frame = CGRectMake(CGRectGetMaxX(_dscLab.frame)+5, _addDscLab.frame.origin.y, 120, 18);
}



#pragma mark - 转账
- (void)transferBtnAction:(UIButton *)button {
   if ([_countTextField.text doubleValue] > g_App.myMoney) {
      [g_App showAlert:Localized(@"CREDIT_LOW")];
      return;
   }
   g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
   if ([g_myself.isPayPassword boolValue]) {
      self.verVC = [WH_JXVerifyPay_WHVC alloc];
      self.verVC.type = JXVerifyTypeTransfer;
      self.verVC.wh_RMB = self.countTextField.text;
      self.verVC.delegate = self;
      self.verVC.didDismissVC = @selector(WH_dismiss_WHVerifyPayVC);
      self.verVC.didVerifyPay = @selector(WH_didVerifyPay:);
      self.verVC = [self.verVC init];

      [self.view addSubview:self.verVC.view];
   } else {
      [BindTelephoneChecker checkBindPhoneWithViewController:self entertype:JXEnterTypeTransfer];
   }
}

- (void)WH_didVerifyPay:(NSString *)sender {
   long time = (long)[[NSDate date] timeIntervalSince1970] + (g_server.timeDifference / 1000);
   NSString *secret = [self getSecretWithText:sender time:time];
   [g_server WH_transferToPeopleWithUserId:_wh_user.userId money:_countTextField.text remark:_replayTextField.text time:time secret:secret toView:self];
}


- (void)WH_dismiss_WHVerifyPayVC {
   [self.verVC.view removeFromSuperview];
}

- (void)showSendTransferDsc{
    self.bigView.hidden = NO;
    [self.replayTextField becomeFirstResponder];
}


- (void)textFieldDidChange:(UITextField *)textField {
   if (textField == _countTextField) {
      @try{
         _moneyLabel.text = [NSString stringWithFormat:@"¥%.2f",[textField.text doubleValue]];
      } @catch(NSException *e){}
      if ([textField.text doubleValue] > 0) {
         _transferBtn.enabled = YES;
      }else {
         _transferBtn.enabled = NO;
      }
   }
//   if (textField == _replayTextField) {
//      if (textField.text.length > 10) {
//         textField.text = [textField.text substringToIndex:10];
//      }
//   }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
   if (textField == _countTextField) {
      // 首位不能输入 .
      if (IsStringNull(textField.text) && [string isEqualToString:@"."]) {
         return NO;
      }
      //限制.后面最多有两位，且不能再输入.
      if ([textField.text rangeOfString:@"."].location != NSNotFound) {
         //有.了 且.后面输入了两位  停止输入
         if (toBeString.length > [toBeString rangeOfString:@"."].location+3) {
            return NO;
         }
         //有.了，不允许再输入.
         if ([string isEqualToString:@"."]) {
            return NO;
         }
      }
      //限制首位0，后面只能输入. 和 删除
      if ([textField.text isEqualToString:@"0"]) {
         if (![string isEqualToString:@"."] && ![string isEqualToString:@""]) {
            return NO;
         }
      }
      //限制只能输入：1234567890.
      NSCharacterSet * characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] invertedSet];
      NSString * filtered = [[string componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
      return [string isEqualToString:filtered];
   }
   if (textField == self.replayTextField) {
      if (toBeString.length > 10) {
         return NO;
      }
   }

   return YES;
}


#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
   if( [aDownload.action isEqualToString:wh_act_sendTransfer]){
      [self WH_dismiss_WHVerifyPayVC];  // 销毁支付密码界面
      
      if (self.delegate && [self.delegate respondsToSelector:@selector(transferToUser:)]) {
         [self.delegate performSelector:@selector(transferToUser:) withObject:dict];
      }
      [self actionQuit];

   }
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
   [_wait stop];
   if ([aDownload.action isEqualToString:wh_act_sendTransfer]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self.verVC WH_clearUpPassword];
      });
   }

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



- (void)resignKeyBoard {
    self.bigView.hidden = YES;
    [self hideKeyBoard];
    [self resetBigView];
}

- (void)resetBigView {
    self.replayTextField.frame = CGRectMake(10, 64, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5);
    self.topView.frame = CGRectMake(0, 118, self.baseView.frame.size.width, 40);
}

- (void)hideKeyBoard {
    if (self.replayTextField.isFirstResponder) {
        [self.replayTextField resignFirstResponder];
    }
}


-(UITextField*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,54)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = sysFontWithSize(16);
    [parent addSubview:p];
    return p;
}

- (NSString *)getSecretWithText:(NSString *)text time:(long)time {
   NSMutableString *str1 = [NSMutableString string];
   [str1 appendString:APIKEY];
   [str1 appendString:[NSString stringWithFormat:@"%ld",time]];
   [str1 appendString:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[_countTextField.text doubleValue]]]];
   str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
   
   [str1 appendString:g_myself.userId];
   [str1 appendString:g_server.access_token];
   NSMutableString *str2 = [NSMutableString string];
   str2 = [[g_server WH_getMD5StringWithStr:text] mutableCopy];
   [str1 appendString:str2];
   str1 = [[g_server WH_getMD5StringWithStr:str1] mutableCopy];
   
   return [str1 copy];
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   if (scrollView == self.wh_tableBody) {
      if ([self.countTextField isFirstResponder]) {
         [self.countTextField resignFirstResponder];
      }
   }
}

@end
