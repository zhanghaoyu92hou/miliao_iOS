//
//  WH_forgetPwd_WHVC.m
//  Tigase_imChatT
//
//  Created by YZK on 19-6-7.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_forgetPwd_WHVC.h"
#import "WH_CountryCodeViewController.h"
#import "WH_JXUserObject.h"
#import "WH_LoginViewController.h"

#define HEIGHT 55


@interface WH_forgetPwd_WHVC () <UITextFieldDelegate>
{
   UIButton *_areaCodeBtn;
   NSTimer* timer;
   WH_JXUserObject *_user;
   UIImageView * _imgCodeImg;
   UITextField *_imgCode;   //图片验证码
   UIButton * _graphicButton;
}

@end

@implementation WH_forgetPwd_WHVC

- (id)init
{
   self = [super init];
   if (self) {
      
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   if (self.wh_isModify) {
      self.title = Localized(@"JX_UpdatePassWord");
   }else{
      self.title = Localized(@"JX_ForgetPassWord");
   }
   
   
   _user = [WH_JXUserObject sharedUserInstance];
   _seconds = 0;
   self.wh_isGotoBack   = YES;
   self.wh_heightFooter = 0;
   self.wh_heightHeader = JX_SCREEN_TOP;
   [self createHeadAndFoot];
   self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
//   int n = 12;
   
   UIView *tView = [self createViewWithOrginY:12 viewWidth:JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset viewHeight:(!self.wh_isModify)?HEIGHT*2:HEIGHT];
   //区号
   if (!_phone) {
      NSString *str = @"";
      if ([g_config.regeditPhoneOrName intValue] == 1) {
         str = Localized(@"JX_InputUserAccount");
      }else{
         str = Localized(@"JX_InputPhone");
      }
      _phone = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, 0, tView.frame.size.width - 28, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:str font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
      _phone.clearButtonMode = UITextFieldViewModeWhileEditing;
      [tView addSubview:_phone];
      
      if ([g_config.regeditPhoneOrName intValue] == 0) {
         ////使用手机号
         UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, HEIGHT)];
         _phone.leftView = leftView;
         _phone.leftViewMode = UITextFieldViewModeAlways;
         NSString *areaStr;
         NSString *codeStr = [g_default objectForKey:kMY_USER_AREACODE];
         if (IsStringNull(codeStr)) {
            areaStr = @"+86";
         } else {
            areaStr = [NSString stringWithFormat:@"+%@",[g_default objectForKey:kMY_USER_AREACODE]];
         }
         _areaCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, HEIGHT)];
         [_areaCodeBtn setTitle:areaStr forState:UIControlStateNormal];
         _areaCodeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
         [_areaCodeBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
         [_areaCodeBtn setImage:[UIImage imageNamed:@"down_arrow_black"] forState:UIControlStateNormal];
         _areaCodeBtn.custom_acceptEventInterval = 1.0f;
         [_areaCodeBtn addTarget:self action:@selector(areaCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
         [self resetBtnEdgeInsets:_areaCodeBtn];
         [leftView addSubview:_areaCodeBtn];
      }
   }
   
   
   CGFloat height = CGRectGetMaxY(tView.frame);
   
   if (!self.wh_isModify) {

      //图片验证码
      _imgCode = [UIFactory WH_create_WHTextFieldWith:CGRectMake(16, HEIGHT, CGRectGetWidth(tView.frame) -70-12-12 - 10, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];
      _imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
      [tView addSubview:_imgCode];

      _graphicButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _graphicButton.frame = CGRectMake(CGRectGetMaxX(_imgCode.frame) + 12, (HEIGHT - 35)/2, 70, 35);
      _graphicButton.center = CGPointMake(_graphicButton.center.x,_imgCode.center.y);
      [_graphicButton addTarget:self action:@selector(refreshGraphicAction:) forControlEvents:UIControlEventTouchUpInside];
      [tView addSubview:_graphicButton];
      
      UIView *cView = [self createViewWithOrginY:CGRectGetMaxY(tView.frame) + 12 viewWidth:JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset - 115 - 10 viewHeight:HEIGHT];
      
      _code = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, cView.frame.size.width, HEIGHT)];
      _code.delegate = self;
      _code.autocorrectionType = UITextAutocorrectionTypeNo;
      _code.autocapitalizationType = UITextAutocapitalizationTypeNone;
      _code.enablesReturnKeyAutomatically = YES;
      _code.font = sysFontWithSize(16);
//      _code.borderStyle = UITextBorderStyleRoundedRect;
      _code.returnKeyType = UIReturnKeyDone;
      _code.clearButtonMode = UITextFieldViewModeWhileEditing;
      _code.placeholder = Localized(@"JX_InputMessageCode");
      
      [cView addSubview:_code];
//      [self createLeftViewWithImage:[UIImage imageNamed:@"code"] superView:_code];

      _send = [UIFactory WH_create_WHButtonWithTitle:@"获取验证码"
                                     titleFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 15]
                                    titleColor:HEXCOLOR(0x8F9CBB)
                                        normal:nil
                                     highlight:nil ];
      [_send addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
      _send.backgroundColor = HEXCOLOR(0xffffff);
      _send.frame = CGRectMake(JX_SCREEN_WIDTH - g_factory.globelEdgeInset - 115, CGRectGetMaxY(tView.frame) + 12, 115, HEIGHT);
      [self.wh_tableBody addSubview:_send];
      _send.layer.borderColor = g_factory.cardBorderColor.CGColor;
      _send.layer.borderWidth = g_factory.cardBorderWithd;
      _send.layer.masksToBounds = YES;
      _send.layer.cornerRadius = g_factory.cardCornerRadius;
//      n = n+HEIGHT+INSETS;
      
      height = CGRectGetMaxY(cView.frame);
   }
   
   if (!self.wh_isModify) {
      [tView addSubview:[self createLineViewWithOrighY:HEIGHT lineWidth:CGRectGetWidth(tView.frame)]];
   }

   UIView *bView = [self createViewWithOrginY:height + 12 viewWidth:JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset viewHeight:(self.wh_isModify)?HEIGHT*3:HEIGHT*2];
   
   CGFloat pHight = 0;
   if (self.wh_isModify) {
      _oldPwd = [[UITextField alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset,0,CGRectGetWidth(bView.frame) - 2*g_factory.globelEdgeInset,HEIGHT)];
      _oldPwd.delegate = self;
      _oldPwd.autocorrectionType = UITextAutocorrectionTypeNo;
      _oldPwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
      _oldPwd.enablesReturnKeyAutomatically = YES;
//      _oldPwd.borderStyle = UITextBorderStyleRoundedRect;
      _oldPwd.returnKeyType = UIReturnKeyDone;
      _oldPwd.clearButtonMode = UITextFieldViewModeWhileEditing;
      _oldPwd.placeholder = Localized(@"JX_InputOldPassWord");
      _oldPwd.secureTextEntry = YES;
      _oldPwd.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
      [bView addSubview:_oldPwd];
      pHight = HEIGHT;
   }
   
   _pwd = [[UITextField alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset,pHight,CGRectGetWidth(bView.frame) - 2*g_factory.globelEdgeInset,HEIGHT)];
   _pwd.delegate = self;
   _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
   _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
   _pwd.enablesReturnKeyAutomatically = YES;
//   _pwd.borderStyle = UITextBorderStyleRoundedRect;
   _pwd.returnKeyType = UIReturnKeyDone;
   _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
   _pwd.placeholder = Localized(@"JX_InputNewPassWord");
   _pwd.secureTextEntry = YES;
   _pwd.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
   [bView addSubview:_pwd];

   _repeat = [[UITextField alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset,CGRectGetMaxY(_pwd.frame),CGRectGetWidth(bView.frame) - 2*g_factory.globelEdgeInset,HEIGHT)];
   _repeat.delegate = self;
   _repeat.autocorrectionType = UITextAutocorrectionTypeNo;
   _repeat.autocapitalizationType = UITextAutocapitalizationTypeNone;
   _repeat.enablesReturnKeyAutomatically = YES;
//   _repeat.borderStyle = UITextBorderStyleRoundedRect;
   _repeat.returnKeyType = UIReturnKeyDone;
   _repeat.clearButtonMode = UITextFieldViewModeWhileEditing;
   _repeat.placeholder = Localized(@"JX_ConfirmNewPassWord");
   _repeat.secureTextEntry = YES;
   _repeat.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
//   [self createLeftViewWithImage:[UIImage imageNamed:@"password"] superView:_repeat];
   [bView addSubview:_repeat];
   
   if (self.wh_isModify) {
      [bView addSubview:[self createLineViewWithOrighY:HEIGHT lineWidth:CGRectGetWidth(bView.frame)]];
      
      [bView addSubview:[self createLineViewWithOrighY:2*height lineWidth:CGRectGetWidth(bView.frame)]];
   }else{
      [bView addSubview:[self createLineViewWithOrighY:HEIGHT lineWidth:CGRectGetWidth(bView.frame)]];
   }
   
   UIButton* _btn = [UIFactory WH_create_WHCommonButton:Localized(@"JX_UpdatePassWord") target:self action:@selector(onClick:)];
   _btn.frame = CGRectMake(g_factory.globelEdgeInset, CGRectGetMaxY(bView.frame) + 20, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 44);
   [_btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 16]];
   [self.wh_tableBody addSubview:_btn];
   _btn.layer.masksToBounds = YES;
   _btn.layer.cornerRadius = g_factory.cardCornerRadius;
   
   //如果是用户名注册
   NSString *accountStr = @"";
   if ([g_config.regeditPhoneOrName intValue] == 1) {
      accountStr = [NSString stringWithFormat:@"%@",g_myself.account];
   }else if ([g_config.regeditPhoneOrName intValue] == 0) {
      accountStr = [NSString stringWithFormat:@"%@",g_myself.telephone];;
   }
   
   if (self.wh_isModify) {
      if (accountStr.length) {
         _phone.enabled = NO;
         _phone.text = accountStr;
      }
      

   }else{
      if (_phone.text.length > 0) {
         [self getImgCodeImg];
      }

   }
   
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

-(void)refreshGraphicAction:(UIButton *)button{
   [self getImgCodeImg];
}

-(void)getImgCodeImg{
   if(_phone.text.length > 0){
      //    if ([self checkPhoneNum]) {
      //请求图片验证码
      NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
      NSString * codeUrl = [g_server getImgCode:_phone.text areaCode:areaCode];
      NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
      
      [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         if (!connectionError) {
            UIImage * codeImage = [UIImage imageWithData:data];
            if (codeImage != nil) {
               [_graphicButton setImage:codeImage forState:UIControlStateNormal];
//               _imgCodeImg.image = codeImage;
            }else{
               [g_App showAlert:Localized(@"JX_ImageCodeFailed")];
            }
            
         }else{
            NSLog(@"%@",connectionError);
            [g_App showAlert:connectionError.localizedDescription];
         }
      }];
//      [_imgCodeImg sd_setImageWithURL:[NSURL URLWithString:codeUrl] placeholderImage:[UIImage imageNamed:@"refreshImgCode"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//         if (!error) {
//            _imgCodeImg.image = image;
//         }else{
//            NSLog(@"%@",error);
//         }
//      }];
   }else{
      
   }
   
}


#pragma mark------验证
-(void)onClick:(UIButton *)btn{
   btn.enabled = NO;
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      btn.enabled = YES;
   });
   if([_phone.text length]<= 0){
      if ([g_config.regeditPhoneOrName intValue] == 1) {
         [g_App showAlert:Localized(@"JX_InputUserAccount")];
      }else{
         [g_App showAlert:Localized(@"JX_InputPhone")];
      }
      
      return;
   }

   if (!self.wh_isModify) {

      if([_code.text length]<4){
         //_code.text = @"1315";
         [g_App showAlert:Localized(@"JX_InputMessageCode")];
         return;
      }

   }
   if (self.wh_isModify && [_oldPwd.text length] <= 0){
      [g_App showAlert:Localized(@"JX_InputPassWord")];
      return;
   }
   
   if([_pwd.text length]<=0){
      [g_App showAlert:Localized(@"JX_InputPassWord")];
      return;
   }
   if([_repeat.text length]<=0){
      [g_App showAlert:Localized(@"JX_ConfirmPassWord")];
      return;
   }
   if(![_pwd.text isEqualToString:_repeat.text]){
      [g_App showAlert:Localized(@"JX_PasswordFiled")];
      return;
   }
   
   if ([_pwd.text isEqualToString:_oldPwd.text]) {
      [g_App showAlert:Localized(@"JX_PasswordOriginal")];
      return;
   }
   
   //   if([_smsCode length]<=0){
   //      //忽略短信验证
   //      //_smsCode = _code.text;
   //      [g_App showAlert:@"请输入验证码"];
   //      return;
   //   }
   [self.view endEditing:YES];
   NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
   if (self.wh_isModify){
      [_wait start];
      [g_server WH_updatePwd:_phone.text areaCode:areaCode oldPwd:_oldPwd.text newPwd:_pwd.text toView:self];
   }else{
      BOOL b = YES;

      b = [_code.text isEqualToString:_smsCode];

      if(b){
         [_wait start];
         [g_server WH_resetPwd:_phone.text areaCode:areaCode randcode:_smsCode newPwd:_pwd.text toView:self];
         
      }
      else
         [g_App showAlert:Localized(@"WaHu_inputPhone_WaHuVC_MsgCodeNotOK")];
       //        [g_App showAlert:@"短信验证码不对"];
   }
  
}
//验证手机号格式
- (void)sendSMS{
   [_phone resignFirstResponder];
   [_imgCode resignFirstResponder];
   [_code resignFirstResponder];
   
   _send.enabled = NO;
   if (_imgCode.text.length < 3) {
      [g_App showAlert:Localized(@"JX_inputImgCode")];
      _send.enabled = YES;
      return;
   }
   
   [self onSend];
   
//   if([self isMobileNumber:_phone.text]){
//      //验证手机号码是否已注册
//      //        [g_server verifyPhone:[NSString stringWithFormat:@"%@%@",[_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""],_phoneNumTextField.text] toView:self];
//
//      //请求验证码
//
//
//   }else {
//      _send.enabled = YES;
//   }
}
//验证手机号码格式
- (BOOL)isMobileNumber:(NSString *)number{
   if ([_phone.text length] == 0) {
      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localized(@"JX_Tip") message:Localized(@"JX_InputPhone") delegate:nil cancelButtonTitle:Localized(@"JX_Confirm") otherButtonTitles:nil, nil];
      [alert show];
      //        [alert release];
      return NO;
   }
   
   if ([_areaCodeBtn.titleLabel.text isEqualToString:@"+86"]) {
      NSString *regex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
      NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
      BOOL isMatch = [pred evaluateWithObject:number];
      
      if (!isMatch) {
         [g_App showAlert:Localized(@"WaHu_inputPhone_WaHuVC_InputTurePhone")];
//         UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localized(@"JXVerifyAccountVC_Prompt") message:Localized(@"JXVerifyAccountVC_PhoneNumberError") delegate:nil cancelButtonTitle:Localized(@"JXVerifyAccountVC_OK") otherButtonTitles:nil, nil];
//         [alert show];
         //            [alert release];
         return NO;
      }
   }
   return YES;
}

-(void)onSend{
   
   if (!_send.selected) {
      [_wait start];
      NSString *areaCode = [_areaCodeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
      //      _user = [WH_JXUserObject sharedUserInstance];
      _user.areaCode = areaCode;
      [g_server WH_sendSMSCodeWithTel:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
   }
   
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
   [_wait stop];
   if([aDownload.action isEqualToString:wh_act_SendSMS]){
      _send.enabled = YES;
      _send.selected = YES;
      _send.userInteractionEnabled = NO;
      _send.backgroundColor = HEXCOLOR(0xffffff);
      _smsCode = [[dict objectForKey:@"code"] copy];
      [_send setTitle:@"60s" forState:UIControlStateSelected];
      _seconds = 60;
      timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_send repeats:YES];
   }
   if([aDownload.action isEqualToString:wh_act_PwdUpdate]){
      [g_App showAlert:Localized(@"JX_UpdatePassWordOK")];
      g_myself.password = [g_server WH_getMD5StringWithStr:_pwd.text];
      [g_default setObject:[g_server WH_getMD5StringWithStr:_pwd.text] forKey:kMY_USER_PASSWORD];
      [g_default synchronize];
      [self updateUserInfoSentToServer];
      [self actionQuit];
      [self relogin];
   }
   if([aDownload.action isEqualToString:wh_act_PwdReset]){
      [g_App showAlert:Localized(@"JX_UpdatePassWordOK")];
      g_myself.password = [g_server WH_getMD5StringWithStr:_pwd.text];
      [g_default setObject:[g_server WH_getMD5StringWithStr:_pwd.text] forKey:kMY_USER_PASSWORD];
      [g_default synchronize];
      [self updateUserInfoSentToServer];
      [self actionQuit];
   }
}
- (void)updateUserInfoSentToServer {
   WH_JXMessageObject * msg = [[WH_JXMessageObject alloc]init];
   msg.timeSend = [NSDate date];
   msg.fromUserId = MY_USER_ID;
   msg.fromUserName = g_myself.userNickname;
   msg.isGroup = NO;
   msg.type = [NSNumber numberWithInteger:kWCMessageTypeUpdateUserInfoSendToServer];
   [g_xmpp sendMessage:msg roomName:nil];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
   if([aDownload.action isEqualToString:wh_act_SendSMS]){
      [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
      _send.enabled = YES;
   }else if ([aDownload.action isEqualToString:wh_act_PwdUpdate]) {
      NSString *error = [[dict objectForKey:@"data"] objectForKey:@"resultMsg"];
      
      [g_App showAlert:[NSString stringWithFormat:@"%@",error]];
      
      return WH_hide_error;
   }
   
   [_wait stop];
   return WH_show_error;
}

#pragma mark - 请求出错回调
-(int) WH_didServerConnect_WHError:(WH_JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
   [_wait stop];
   _send.enabled = YES;
   return WH_show_error;
}

#pragma mark - 开始请求服务器回调
-(void) WH_didServerConnect_WHStart:(WH_JXConnection*)aDownload{
   [_wait stop];
}

-(void)showTime:(NSTimer*)sender{
   UIButton *but = (UIButton*)[timer userInfo];
   _seconds--;
   [but setTitle:[NSString stringWithFormat:@"%ds",_seconds] forState:UIControlStateSelected];
   if(_seconds<=0){
      but.selected = NO;
      but.userInteractionEnabled = YES;
      but.backgroundColor = HEXCOLOR(0xffffff);
      [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
      if (timer) {
         timer = nil;
         [sender invalidate];
      }
      _seconds = 60;
      
   }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

   if (textField == _phone) {
      [self getImgCodeImg];
   }


}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [self.view endEditing:YES];
   return YES;
}
- (void)areaCodeBtnClick:(UIButton *)but{
   [self.view endEditing:YES];
   WH_CountryCodeViewController *telAreaListVC = [[WH_CountryCodeViewController alloc] init];
   telAreaListVC.wh_telAreaDelegate = self;
   telAreaListVC.wh_didSelect = @selector(didSelectTelArea:);
//   [g_window addSubview:telAreaListVC.view];
   [g_navigation pushViewController:telAreaListVC animated:YES];
}

- (void)didSelectTelArea:(NSString *)areaCode{
   [_areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",areaCode] forState:UIControlStateNormal];
   [self resetBtnEdgeInsets:_areaCodeBtn];
}
- (void)resetBtnEdgeInsets:(UIButton *)btn{
   [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
   [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}


-(void)relogin{
   [g_default removeObjectForKey:kMY_USER_PASSWORD];
   [g_default removeObjectForKey:kMY_USER_TOKEN];
   [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
   //    [g_default setObject:nil forKey:kMY_USER_TOKEN];
   g_server.access_token = nil;
   
   [g_notify postNotificationName:kSystemLogout_WHNotifaction object:nil];
   [[JXXMPP sharedInstance] logout];
   NSLog(@"XMPP ---- WH_forgetPwd_WHVC relogin");
   
    WH_LoginViewController *loginVC = [[ WH_LoginViewController alloc] init];
   loginVC.isSwitchUser = NO;
   [g_mainVC.view removeFromSuperview];
   g_mainVC = nil;
   [self.view removeFromSuperview];
   self.view = nil;
   loginVC.isPushEntering = YES;
   g_navigation.rootViewController = loginVC;
   
//    WH_LoginViewController* vc = [ WH_LoginViewController alloc];
//   vc.isAutoLogin = NO;
//   vc.isSwitchUser= NO;
//   vc = [vc init];
//   [g_mainVC.view removeFromSuperview];
//   g_mainVC = nil;
//   [self.view removeFromSuperview];
//   self.view = nil;
//
//   g_navigation.rootViewController = vc;
   
   
   [_wait stop];
#if TAR_IM
#ifdef Meeting_Version
   [g_meeting WH_stopMeeting];
#endif
#endif
}


- (void)createLeftViewWithImage:(UIImage *)image superView:(UITextField *)textField {
   UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, HEIGHT)];
   textField.leftView = leftView;
   textField.leftViewMode = UITextFieldViewModeAlways;
   UIImageView *leIgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 22, 22)];
   leIgView.image = image;
   leIgView.contentMode = UIViewContentModeScaleAspectFit;
   [leftView addSubview:leIgView];
}

- (UIView *)createLineViewWithOrighY:(CGFloat)orginY lineWidth:(CGFloat)lWidth{
   UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, lWidth, g_factory.cardBorderWithd)];
   [view setBackgroundColor:g_factory.globalBgColor];
   return view;
}

- (UIView *)createViewWithOrginY:(CGFloat)orginY viewWidth:(CGFloat)width viewHeight:(CGFloat)height{
   UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, orginY, width, height)];
   [cView setBackgroundColor:HEXCOLOR(0xffffff)];
   [self.wh_tableBody addSubview:cView];
   cView.layer.masksToBounds = YES;
   cView.layer.cornerRadius = g_factory.cardCornerRadius;
   cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
   cView.layer.borderWidth = g_factory.cardBorderWithd;
   return cView;
}



- (void)sp_upload {
    NSLog(@"Get Info Failed");
}
@end
