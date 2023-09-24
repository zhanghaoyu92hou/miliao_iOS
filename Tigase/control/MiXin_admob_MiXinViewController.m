//
//  MiXin_admob_MiXinViewController.m
//  sjvodios
//
//  Created by  on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MiXin_admob_MiXinViewController.h"
#import "AppDelegate.h"
#import "versionManage.h"
#import "MiXin_JXImageView.h"
#import "JXLabel.h"
#import "UIImage+Tint.h"


@implementation MiXin_admob_MiXinViewController
@synthesize heightFooter,heightHeader,leftBarButtonItem,rightBarButtonItem,tableHeader,tableFooter,isGotoBack,tableBody,footerBtnLeft,footerBtnMid,footerBtnRight,headerTitle,isFreeOnClose;

#define AdMob_REFRESH_PERIOD 60.0 // display fresh ads once per second

-(id)init{
    self = [super init];
    heightHeader=JX_SCREEN_TOP;
    heightFooter=JX_SCREEN_BOTTOM;
    isFreeOnClose = YES;
    [g_window endEditing:YES];
    //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        heightHeader=JX_SCREEN_TOP;
        heightFooter=49;
        isFreeOnClose = YES;

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isGotoBack) {
//        self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        
//        [self screenEdgePanGestureRecognizer];
    }
    _wait = [ATMHud sharedInstance];
//    _pSelf = self;
}


//创建边缘手势
-(void)screenEdgePanGestureRecognizer
{
    
    UIScreenEdgePanGestureRecognizer *screenPan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPanAction:)];
    screenPan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenPan];
    
    [self.tableBody.panGestureRecognizer requireGestureRecognizerToFail:screenPan];
    
}
//边缘手势事件
-(void)screenPanAction:(UIScreenEdgePanGestureRecognizer *)screenPan
{
    
    CGPoint p = [screenPan translationInView:self.view];
    NSLog(@"p = %@",NSStringFromCGPoint(p));
    self.view.frame = CGRectMake(p.x, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    if (screenPan.state == UIGestureRecognizerStateEnded) {
        if (p.x > JX_SCREEN_WIDTH/2) {
            [self actionQuit];
        }else {
            [self resetViewFrame];
        }
    }
    
}

- (void)dealloc {
    NSLog(@"dealloc - %@",[self class]);
    self.title = nil;
    self.headerTitle = nil;
//    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"CurrentController = %@",[self class]);
    //页面zuo移
//    if (self.isGotoBack) {
//        if (self.view.frame.origin.x != 0) {
////            UIView *view = g_window.subviews.lastObject;
//            [UIView animateWithDuration:0.3 animations:^{
////                view.frame = CGRectMake(-85, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
//                //自己归位
//                [self resetViewFrame];
//            }];
//        }
//    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
-(void)createHeaderViewWithColor:(UIColor *)color {
    tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    [tableHeader setBackgroundColor:color];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    
    iv.userInteractionEnabled = YES;
//    [tableHeader addSubview:iv];
    //    [iv release];
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-60*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = [UIColor blackColor];
    p.text = self.title;
    p.font = g_factory.font17m;
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(actionTitle:);
    p.delegate = self;
    p.changeAlpha = NO;
    [tableHeader addSubview:p];
    //    [p release];
    
    self.headerTitle = p;
    
    if(isGotoBack){
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, JX_SCREEN_TOP - 38, 31, 31)];
        [btn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        [self.tableHeader addSubview:btn];
        //        btn.showsTouchWhenHighlighted = YES;
    }
}

-(void)createHeaderView{
    tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightHeader)];
    
    iv.backgroundColor = g_factory.navigatorBgColor;
//    [g_theme setViewGradientWithView:iv gradientDirection:JXSkinGradientDirectionTopToBottom];
//    if (g_theme.themeIndex == 0) {
//        iv.image = [[UIImage imageNamed:@"navBarBackground"] imageWithTintColor:HEXCOLOR(0x00ceb3)];
//    }else {
//        iv.image = [g_theme themeTintImage:@"navBarBackground"];//[UIImage imageNamed:@"navBarBackground"];
//    }
    iv.userInteractionEnabled = YES;
    [tableHeader addSubview:iv];
//    [iv release];
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-60*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = g_factory.navigatorTitleColor;
    p.font = g_factory.navigatorTitleFont;
    p.text = self.title;
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(actionTitle:);
    p.delegate = self;
    p.changeAlpha = NO;
    [tableHeader addSubview:p];
//    [p release];

    self.headerTitle = p;
    
    if(isGotoBack){
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(NAV_INSETS, JX_SCREEN_TOP - 38, NAV_BTN_SIZE, NAV_BTN_SIZE)];
        [btn setBackgroundImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 2357;
        [self.tableHeader addSubview:btn];
//        btn.showsTouchWhenHighlighted = YES;
    }
}

-(void)createFooterView{
    tableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, heightFooter)];
//    tableFooter.backgroundColor = [UIColor whiteColor];

    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [tableFooter addSubview:line];
    UIButton* btn;
    
    if(isGotoBack)
        return;

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((JX_SCREEN_WIDTH-76)/2, (49-36)/2, 152/2, 72/2);
//    btn.showsTouchWhenHighlighted = YES;
    [btn setBackgroundImage:[UIImage imageNamed:@"singing_button_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"singing_button_press"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onSing) forControlEvents:UIControlEventTouchUpInside];
    [tableFooter addSubview:btn];
//    [btn release];
    self.footerBtnMid = btn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH-53-5, (49-33)/2, 53, 66/2);
//    btn.showsTouchWhenHighlighted = YES;
    [btn setBackgroundImage:[UIImage imageNamed:@"nearby_button_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"nearby_button_press"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onBtnRight) forControlEvents:UIControlEventTouchUpInside];
    [tableFooter addSubview:btn];
//    [btn release];
    self.footerBtnRight = btn;
}

-(void)createHeadAndFoot{
    int heightTotal = self.view.frame.size.height;

    if(heightHeader>0){
        [self createHeaderView];
        [self.view addSubview:tableHeader];
//        [tableHeader release];
    }
    
    if(heightFooter>0){
        [self createFooterView];
        [self.view addSubview:tableFooter];
//        [tableFooter release];
        tableFooter.frame = CGRectMake(0,heightTotal-heightFooter,self_width,heightFooter);
    }

    if (!_isNotCreateTableBody) {
        tableBody = [[UIScrollView alloc]init];
        tableBody.userInteractionEnabled = YES;
        tableBody.backgroundColor = g_factory.globalBgColor;
        tableBody.showsVerticalScrollIndicator = NO;
        tableBody.showsHorizontalScrollIndicator = NO;
        tableBody.frame =CGRectMake(0,heightHeader,self_width,heightTotal-heightHeader-heightFooter);
        tableBody.contentSize = CGSizeMake(self_width, tableBody.frame.size.height + 0.5);
        [self.view addSubview:tableBody];
    }
//    [tableBody release];
}

#pragma mark 导航更改颜色
- (void)createHeadAndFootWithColor:(UIColor *)color {
    int heightTotal = self.view.frame.size.height;
    
    if(heightHeader>0){
//        [self createHeaderView];
        [self createHeaderViewWithColor:color];
        [self.view addSubview:tableHeader];
        //        [tableHeader release];
    }
    
    if(heightFooter>0){
        [self createFooterView];
        [self.view addSubview:tableFooter];
        //        [tableFooter release];
        tableFooter.frame = CGRectMake(0,heightTotal-heightFooter,self_width,heightFooter);
    }
    
    tableBody = [[UIScrollView alloc]init];
    tableBody.userInteractionEnabled = YES;
    tableBody.backgroundColor = [UIColor whiteColor];
    tableBody.showsVerticalScrollIndicator = NO;
    tableBody.showsHorizontalScrollIndicator = NO;
    tableBody.frame =CGRectMake(0,heightHeader,self_width,heightTotal-heightHeader-heightFooter);
    tableBody.contentSize = CGSizeMake(self_width, tableBody.frame.size.height + 0.5);
    [self.view addSubview:tableBody];
}

-(void) onGotoHome{
    if(self.view.frame.origin.x == 260){
//        [g_App.leftView onClick];
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = CGRectMake (260, 0, self_width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

-(void)actionQuit{
    [_wait stop];
    [g_server stopConnection:self];
    [g_window endEditing:YES];
    [g_notify removeObserver:self];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:context];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(doQuit)];
    
    [g_navigation MiXin_dismiss_MiXinViewController:self animated:YES];
    
//    self.view.frame = CGRectMake (JX_SCREEN_WIDTH, 0, self_width, self.view.frame.size.height);
//    NSInteger index = g_window.subviews.count;
//    if (index - 2 >= 0) {
//        UIView *view = g_window.subviews[index - 2];
//        view.frame = CGRectMake (0, 0, self_width, self.view.frame.size.height);
//    }
//    [UIView commitAnimations];
}

-(void)doQuit{
    [self.view removeFromSuperview];
//    if(isFreeOnClose)
//        _pSelf = nil;
}

-(void) setLeftBarButtonItem:(UIBarButtonItem*)button{
    leftBarButtonItem = button;
    button.customView.frame = CGRectMake(7, 7, 65, 30);
    [tableHeader addSubview:button.customView];
//    [button release];
}

-(void) setRightBarButtonItem:(UIBarButtonItem*)button{
    rightBarButtonItem = button;
    button.customView.frame = CGRectMake(self_width-7-65, 7, 65, 30);
    [tableHeader addSubview:button.customView];
//    [button release];
}

-(void)onSing{
//    [g_App.leftView onSing];
}

-(void)onBtnRight{
//    [g_App.leftView onNear];
}

-(void)actionTitle:(JXLabel*)sender{
    
}

-(void)setTitle:(NSString *)value{
    self.headerTitle.text = value;
    [super setTitle:value];
}

//归位
- (void)resetViewFrame{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.view.frame.size.height);
    }];
}
@end
