//
//  WH_ForgetPwdForUserViewController.m
//  Tigase
//
//  Created by 齐科 on 2019/8/19.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_ForgetPwdForUserViewController.h"
#import "WH_LoginTextField.h"
#import "DMDropDownMenu.h"
#import "WH_InputPwdViewController.h"

@interface WH_ForgetPwdForUserViewController () <UITextFieldDelegate, DMDropDownMenuDelegate, JXServerResult>
{
    WH_LoginTextField *userField;
    UITextField *answerField;
    UILabel *passSecLabel;
    BOOL showQuestion;
    NSString *answer;
    NSArray *questionList;
    DMDropDownMenu *questionMenu;
}
@end

@implementation WH_ForgetPwdForUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"忘记密码";
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    self.wh_isGotoBack = YES;
    self.wh_isNotCreatewh_tableBody = YES;
    [self.wh_tableBody setBackgroundColor:g_factory.globalBgColor];
    [self.view setBackgroundColor:g_factory.globalBgColor];
    [self createHeadAndFoot];
    [self loadSubViews];
    if (self.forgetStep == 2) {
        [self initQuestionData];
    }
}
- (void)initQuestionData {
    NSMutableArray *mutAnswer = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in self.questions) {
        [mutAnswer addObject:dic[@"question"]];
    }
    self.questionDic = self.questions[0];
    questionMenu.listArr = self.questions;
}
- (void)loadSubViews {
    CGFloat buttonOriginY = JX_SCREEN_TOP+13;
    if (self.forgetStep == 1) {
        userField = [[WH_LoginTextField alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, JX_SCREEN_TOP+13, JX_SCREEN_WIDTH-2*g_factory.globelEdgeInset, 50)];
        userField.fieldType = LoginFieldUserNameType;
        userField.delegate = self;
        userField.tag = 1;
        [self customLayerCornerStyleWithGlobalParams:userField.layer];
        [self.view addSubview:userField];
        buttonOriginY = userField.bottom + 20;
    }else {
        
        UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, buttonOriginY+12, JX_SCREEN_WIDTH-2*g_factory.globelEdgeInset, 20)];
        desLabel.backgroundColor = g_factory.globalBgColor;
        desLabel.text = @"请选择密保问题进行验证:";
        desLabel.textColor = HEXCOLOR(0x8F9CBB);
        desLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:desLabel];
        
        UIView *passSecBackView = [[UIView alloc] initWithFrame:CGRectMake(desLabel.left, desLabel.bottom+12, desLabel.width, 56)];
        passSecBackView.backgroundColor = UIColor.whiteColor;
        passSecBackView.layer.borderColor = g_factory.cardBorderColor.CGColor;
        passSecBackView.layer.borderWidth = g_factory.cardBorderWithd;
        passSecBackView.layer.cornerRadius = g_factory.cardCornerRadius;
        //    [self.view addSubview:passSecBackView];
        
        passSecLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 17, passSecBackView.width-20*2-24-12, 56-17*2)];
        passSecLabel.text = @"";
        passSecLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        passSecLabel.textColor = HEXCOLOR(0x3A404C);
        //    [passSecBackView addSubview:passSecLabel];
        
        questionMenu = [[DMDropDownMenu alloc] initWithFrame:CGRectMake(desLabel.left, desLabel.bottom+12, desLabel.width, 56)];
        questionMenu.delegate = self;
        questionMenu.backgroundColor = UIColor.whiteColor;
        questionMenu.clipsToBounds = YES;
        [self customLayerCornerStyleWithGlobalParams:questionMenu.layer];
        //    questionMenu.curText.text = @"您父亲的名字是？";
        questionMenu.curText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        questionMenu.curText.textColor = HEXCOLOR(0x3A404C);
        questionMenu.arrowImg.image = [UIImage imageNamed:@"newicon_arrowup"];
        
        [self.view addSubview:questionMenu];
        
        UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(passSecBackView.width-27*2, 0, 27*2, passSecBackView.height)];
        [arrowButton setImage:[UIImage imageNamed:@"newicon_arrowup"] forState:UIControlStateNormal];
        [arrowButton addTarget:self action:@selector(showPwdQuestions:) forControlEvents:UIControlEventTouchUpInside];
        [passSecBackView addSubview:arrowButton];
        
        answerField = [[UITextField alloc] initWithFrame:CGRectMake(passSecBackView.left, passSecBackView.bottom+12, passSecBackView.width, 56)];
        answerField.delegate = self;
        answerField.tag = 2;
        answerField.autocorrectionType = UITextAutocorrectionTypeNo;
        answerField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerField.enablesReturnKeyAutomatically = YES;
        //    anserField.borderStyle = UITextBorderStyleRoundedRect;
        answerField.backgroundColor = UIColor.whiteColor;
        answerField.returnKeyType = UIReturnKeyDone;
        answerField.clearButtonMode = UITextFieldViewModeAlways;
        answerField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入答案" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Regular" size:15], NSForegroundColorAttributeName:HEXCOLOR(0xBAC3D5)}];
        answerField.font = sysFontWithSize(16);
        [self customLayerCornerStyleWithGlobalParams:answerField.layer];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, answerField.height)];
        leftView.backgroundColor = UIColor.whiteColor;
        answerField.leftViewMode = UITextFieldViewModeAlways;
        answerField.leftView = leftView;
        [self.view addSubview:answerField];
        
        buttonOriginY = answerField.bottom + 20;
    }
    
  
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, buttonOriginY, JX_SCREEN_WIDTH-2*g_factory.globelEdgeInset, 44)];
    [confirmButton setTitle:self.forgetStep == 1 ? Localized(@"JX_NextStep") : Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [confirmButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    confirmButton.backgroundColor = HEXCOLOR(0x0093FF);
    confirmButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    confirmButton.layer.cornerRadius = g_factory.cardCornerRadius;
    confirmButton.layer.borderWidth = g_factory.cardBorderWithd;
    confirmButton.layer.borderColor = g_factory.cardBorderColor.CGColor;
    confirmButton.layer.masksToBounds = YES;
    [confirmButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
}

- (void)customLayerCornerStyleWithGlobalParams:(CALayer *)layer {
    layer.cornerRadius = g_factory.cardCornerRadius;
    layer.borderColor = g_factory.cardBorderColor.CGColor;
    layer.borderWidth = g_factory.cardBorderWithd;
    layer.masksToBounds = YES;
}




#pragma mark --- UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        self.userName = textField.text;
    }else {
        answer = answerField.text;
    }
}

#pragma mark ---- DMDropMenuDelegate
- (void)selectIndex:(NSInteger)index AtDMDropDownMenu:(DMDropDownMenu *)dmDropDownMenu {
    id obj = dmDropDownMenu.listArr[index];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.questionDic = obj;
    }
}

#pragma mark --- Button Action
- (void)nextStep {
    [self.view endEditing:YES];
    if (self.forgetStep == 1) {
        if (IsStringNull(self.userName)) {
            [GKMessageTool showText:@"请输入用户名"];
            return;
        }
        [_wait start];
        [g_server getPasswordSecListWithUserName:self.userName toDelegate:self];
    }else {
        if (IsStringNull(answer)) {
            [GKMessageTool showText: @"请输入答案"];
            return;
        }
        if (!self.questionDic[@"id"]) {
            [GKMessageTool showText:@"未设置密保问题"];
            return;
        }
        NSDictionary *params = @{@"userName":self.userName, @"qid":self.questionDic[@"id"], @"answer":answer};
        [g_server checkPwdSecAnswer:params toDelegate:self];
    }
}

- (void)showPwdQuestions:(UIButton *)button {
    showQuestion = !showQuestion;
    [UIView animateWithDuration:0.3 animations:^{
        button.imageView.transform = showQuestion ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
    }];
}

#pragma mark -- JXResult Delegate
-(void)WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1 {
    [_wait stop];
    if([aDownload.action isEqualToString:act_pwsSecList]) {
        if (array1.count > 0) {
            WH_ForgetPwdForUserViewController *nextStep = [[WH_ForgetPwdForUserViewController alloc] init];
            nextStep.questions = array1;
            nextStep.forgetStep = 2;
            nextStep.userName = self.userName;
            [g_navigation pushViewController:nextStep animated:YES];
        }else {
            [GKMessageTool showText:@"未设置密保"];
        }
    }else if ([aDownload.action isEqualToString:act_pwdSecCheck]) {
        
        if ([dict[@"resultCode"] integerValue] == 1 && [dict[@"data"] boolValue] == YES) {
            WH_InputPwdViewController  *pwdVC = [[WH_InputPwdViewController alloc] init];
            pwdVC.resetPass = YES;
            pwdVC.registTYpe = 1;
            pwdVC.telephone = self.userName;
            [g_navigation pushViewController:pwdVC animated:YES];
        }else{
            [GKMessageTool showText:@"校验失败"];
            return;
        }
        
    }
}
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict {
    [_wait stop];
    [GKMessageTool showText:dict[@"resultMsg"]];
    return WH_hide_error;
}
#pragma mark ---- 请求出错回调
-(int) WH_didServerConnect_MiXinError:(WH_JXConnection*)aDownload error:(NSError *)error {//error为空时，代表超时
    [_wait stop];
    return WH_hide_error;
}
#pragma mark ----- 开始请求服务器回调
-(void) WH_didServerConnect_MiXinStart:(WH_JXConnection*)aDownload {
    
}
@end
