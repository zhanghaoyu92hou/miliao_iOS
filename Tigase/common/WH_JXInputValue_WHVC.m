//
//  WH_JXInputValue_WHVC.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXInputValue_WHVC.h"
//#import "WH_selectTreeVC_WHVC.h"
#import "WH_selectProvince_WHVC.h"
#import "WH_selectValue_WHVC.h"
#import "ImageResize.h"
#import "WH_SearchData.h"

#define HEIGHT 54
#define STARTTIME_TAG 1
#define IMGSIZE 100

@interface WH_JXInputValue_WHVC ()<UITextViewDelegate>
@property(nonatomic, assign) BOOL isShow;
@end

@implementation WH_JXInputValue_WHVC
@synthesize delegate,didSelect,value;

- (id)init
{
    self = [super init];
    if (self) {
        self.wh_isGotoBack   = YES;
        self.title = @"群公告";
        self.wh_heightFooter = 0;
        self.wh_heightHeader = JX_SCREEN_TOP;
        [self createHeadAndFoot];
        self.wh_tableBody.backgroundColor = g_factory.globalBgColor;
        
        [self.wh_tableBody setScrollEnabled:NO];
        
        JXLabel* p;
        p = [self WH_createLabel:self.wh_tableHeader default:Localized(@"JX_Confirm") selector:@selector(onSave)];
        p.textColor = [UIColor whiteColor];
        p.textAlignment = NSTextAlignmentCenter;
        p.backgroundColor = HEXCOLOR(0x0093FF);
        p.frame = CGRectMake(JX_SCREEN_WIDTH -53, JX_SCREEN_TOP - 28 - 8, 43, 28);
        p.layer.masksToBounds = YES;
        p.layer.cornerRadius = 14;
        
        [self createContentView];
    }
    return self;
}

- (void)createContentView {
    UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 16, JX_SCREEN_WIDTH - 2*g_factory.globelEdgeInset, 230)];
    [cView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.wh_tableBody addSubview:cView];
    cView.layer.masksToBounds = YES;
    cView.layer.cornerRadius = g_factory.cardCornerRadius;
    cView.layer.borderColor = g_factory.cardBorderColor.CGColor;
    cView.layer.borderWidth = g_factory.cardBorderWithd;
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 14, CGRectGetWidth(cView.frame) - 2*g_factory.globelEdgeInset, CGRectGetHeight(cView.frame) - 28)];
    [self.textView setBackgroundColor:HEXCOLOR(0xffffff)];
    [self.textView setText:self.value?:@""];
    [self.textView setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]];
    [self.textView setTextColor:HEXCOLOR(0x3A404C)];
    [self.textView setEditable:YES];
    [self.textView setUserInteractionEnabled:YES];
    [self.textView setDelegate:self];
    [self.textView setScrollEnabled:YES];
    [self.textView setReturnKeyType:UIReturnKeyDone];
    [self.textView setKeyboardType:UIKeyboardTypeDefault];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;//数据类型连接模式
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;//自动纠错方式
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [cView addSubview:self.textView];
    
    self.textDefaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(g_factory.globelEdgeInset, 16, CGRectGetWidth(cView.frame) - 2*g_factory.globelEdgeInset, 20)];
    [self.textDefaultLabel setTextColor:HEXCOLOR(0x969696)];
    [self.textDefaultLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 16]];
    [self.textDefaultLabel setText:@"请输入群公告"];
    [cView addSubview:self.textDefaultLabel];
    if (self.value.length > 0) {
        [self.textDefaultLabel setHidden:YES];
    }
    
    
    //强提醒 按钮
    UIButton *strongNoticeBtn = [UIButton new];
    [self.wh_tableBody addSubview:strongNoticeBtn];
//    [strongNoticeBtn setTitle:@"使用强提醒发布本次公告" forState:UIControlStateNormal];
    [strongNoticeBtn setTitle:[NSString stringWithFormat:@"  %@",Localized(@"JX_StrongReminderPrompt") ? Localized(@"JX_StrongReminderPrompt") : @"  使用强提醒发布本次公告"] forState:UIControlStateNormal];
    [strongNoticeBtn setTitleColor:HEXCOLOR(0x595959) forState:UIControlStateNormal];
    [strongNoticeBtn.titleLabel setFont:sysFontWithSize(15)];
    [strongNoticeBtn setImage:[UIImage imageNamed:@"selected_fause"] forState:UIControlStateNormal];
    [strongNoticeBtn setImage:[UIImage imageNamed:@"selected_true"] forState:UIControlStateSelected];
    [strongNoticeBtn addTarget:self action:@selector(strongNoticeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [strongNoticeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cView.mas_left);
        make.top.mas_equalTo(cView.mas_bottom).offset(20);
    }];
    
}
#pragma mark - 强提醒按钮点击
- (void) strongNoticeBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.allowForceNotice = sender.selected;
    NSLog(@"%@", sender.selected ? @"强提醒打开" : @"强提醒关闭");
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //判断类型，如果不是UITextView类型，收起键盘
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextView class]]) {
            UITextView* tv = (UITextView*)view;
            [tv resignFirstResponder];
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self.textDefaultLabel setHidden:YES];
    NSLog(@"开始编辑");
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"结束编辑");
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        [self onSave];
        return NO;
    }
    
    if (self.isLimit) {
        if (self.limitLen <= 0) {
            self.limitLen = NAME_INPUT_MAX_LENGTH;
        }
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length > self.limitLen && ![text isEqualToString:@""]){
            if (!self.isShow) {
                self.isShow = YES;
                [g_App showAlert:Localized(@"JX_InputLimit")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isShow = NO;
                });
            }
            return NO;
        }
    }
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isRoomNum) {
        self.textView.keyboardType = UIKeyboardTypeNumberPad;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITextView*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextView* p = [[UITextView alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,HEIGHT)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
//    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
//    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
//    p.placeholder = hint;
//    p.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, HEIGHT-INSETS*2)];
//    p.leftViewMode = UITextFieldViewModeAlways;
    p.font = sysFontWithSize(16);
    [parent addSubview:p];
//    [p release];
    return p;
}

-(JXLabel*)WH_createLabel:(UIView*)parent default:(NSString*)s selector:(SEL)selector{
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 -20,HEIGHT-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = sysFontWithSize(14);
    p.textAlignment = NSTextAlignmentLeft;
    p.didTouch = selector;
    p.wh_delegate = self;
    [parent addSubview:p];
//    [p release];
    return p;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)onSave{
    if([self.textView.text isEqualToString:@""]){
        if (self.isRoomNum) {
            [g_App showAlert:Localized(@"JX_MaximumPeopleNotNull")];
        }else {
//            [g_App showAlert:Localized(@"JX_NameCanNot")];
            [g_App showAlert:@"群公告/群说明不能为空!"];
            
            if (self.textDefaultLabel.hidden) {
                [self.textDefaultLabel setHidden:NO];
            }
        }
        return;
    }
    self.value = self.textView.text;
    if (delegate && [delegate respondsToSelector:didSelect]) {
//        [delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
    }
    [self actionQuit];
}

@end
