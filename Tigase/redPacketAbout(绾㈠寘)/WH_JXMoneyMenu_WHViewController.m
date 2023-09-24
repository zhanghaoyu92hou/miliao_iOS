//
//  WH_JXMoneyMenu_WHViewController.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/18.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXMoneyMenu_WHViewController.h"
#import "WH_JXRecordCode_WHVC.h"
#import "WH_JXPayPassword_WHVC.h"


#define HEIGHT 50

@interface WH_JXMoneyMenu_WHViewController ()

@end

@implementation WH_JXMoneyMenu_WHViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = Localized(@"JX_PayCenter");
        self.wh_heightHeader = JX_SCREEN_TOP;
        self.wh_heightFooter = 0;
        self.wh_isGotoBack = YES;
        [self createHeadAndFoot];
        self.wh_tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
        
        int h=9;
        int w=JX_SCREEN_WIDTH;

        WH_JXImageView* iv;
        iv = [self WH_createMiXinButton:Localized(@"JX_Bill") drawTop:NO drawBottom:YES click:@selector(onBill)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;
        
        iv = [self WH_createMiXinButton:Localized(@"JX_SetPayPsw") drawTop:NO drawBottom:YES click:@selector(WH_onPayThePassword)];
        iv.frame = CGRectMake(0,h, w, HEIGHT);
        h+=iv.frame.size.height;

        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


- (void)onBill {
    WH_JXRecordCode_WHVC * recordVC = [[WH_JXRecordCode_WHVC alloc]init];
    [g_navigation pushViewController:recordVC animated:YES];
}


- (void)WH_onPayThePassword {
    WH_JXPayPassword_WHVC * PayVC = [WH_JXPayPassword_WHVC alloc];
    g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];
    if ([g_myself.isPayPassword boolValue]) {
        PayVC.type = JXPayTypeInputPassword;
    }else {
        PayVC.type = JXPayTypeSetupPassword;
    }
    PayVC.enterType = JXEnterTypeDefault;
    PayVC = [PayVC init];
    [g_navigation pushViewController:PayVC animated:YES];
}


// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(WH_JXImageView*)WH_createMiXinButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom click:(SEL)click{
    WH_JXImageView* btn = [[WH_JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.wh_delegate = self;
    [self.wh_tableBody addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = sysFontWithSize(17);
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
    [btn addSubview:p];
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(20,0,JX_SCREEN_WIDTH-20,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(20,HEIGHT-0.5,JX_SCREEN_WIDTH-20,0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3, 16, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        
    }
    return btn;
}



- (void)sp_upload {
    NSLog(@"Check your Network");
}
@end
