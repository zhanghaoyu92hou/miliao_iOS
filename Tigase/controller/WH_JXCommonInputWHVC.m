//
//  WH_JXCommonInput_WHVC.m
//  Tigase_imChatT
//
//  Created by p on 2019/4/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXCommonInput_WHVC.h"
//#import "WH_LJ001_ViewController.h"
#define HEIGHT 44
#define STARTTIME_TAG 1
#define IMGSIZE 100

@interface WH_JXCommonInput_WHVC ()<UITextFieldDelegate>


@end

@implementation WH_JXCommonInput_WHVC

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.wh_isGotoBack   = YES;
    self.title = self.titleStr;
    self.wh_heightFooter = 0;
    self.wh_heightHeader = JX_SCREEN_TOP;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    
    int h = 0;
    WH_JXImageView *iv = [self WH_createMiXinButton:self.subTitle drawTop:NO drawBottom:YES must:NO click:nil];
    iv.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, HEIGHT);
    _name = [self WH_createMiXinTextField:iv default:nil hint:self.tip];
    [_name becomeFirstResponder];
    h+=iv.frame.size.height;

    h+=30;
    UIButton* _btn;
    _btn = [UIFactory WH_create_WHCommonButton:self.btnTitle target:self action:@selector(onSearch)];
    _btn.custom_acceptEventInterval = .25f;
    _btn.frame = CGRectMake(INSETS, h, WIDTH, HEIGHT);
    [self.wh_tableBody addSubview:_btn];
    
    //插入的代码 (YZK)
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH*2, JX_SCREEN_HEIGHT*2, 1, 1);
    
    [btn addTarget:self action:@selector(WH_testAction) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)WH_testAction
{
    
//    WH_LJ001_ViewController *vc = [[WH_LJ001_ViewController alloc] init];
//    [g_navigation pushViewController:vc animated:YES];
    
}



- (void)onSearch {
    
    [self actionQuit];
    
    if ([self.delegate respondsToSelector:@selector(commonInputVCBtnActionWithVC:)]) {
        [self.delegate commonInputVCBtnActionWithVC:self];
    }
    
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom must:(BOOL)must click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.wh_delegate = self;
    if(click)
        btn.didTouch = click;
    else
        btn.didTouch = @selector(hideKeyboard);
    [self.wh_tableBody addSubview:btn];
    //    [btn release];
    
    if(must){
        UILabel* p = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, 5, 20, HEIGHT-5)];
        p.text = @"*";
        p.font = sysFontWithSize(18);
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor redColor];
        p.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:p];
        //        [p release];
    }
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH/2-40, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(16);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = [UIColor blackColor];
    [btn addSubview:p];
    //    [p release];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-0.5,JX_SCREEN_WIDTH,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
        //        [line release];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 13, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        //        [iv release];
    }
    return btn;
}

-(UITextField*)WH_createMiXinTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextField* p = [[UITextField alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 + 10,HEIGHT-INSETS*2)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.borderStyle = UITextBorderStyleNone;
    p.returnKeyType = UIReturnKeyDone;
    p.clearButtonMode = UITextFieldViewModeAlways;
    p.textAlignment = NSTextAlignmentRight;
    p.userInteractionEnabled = YES;
    p.text = s;
    p.placeholder = hint;
    p.font = sysFontWithSize(16);
    [parent addSubview:p];
    //    [p release];
    return p;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
