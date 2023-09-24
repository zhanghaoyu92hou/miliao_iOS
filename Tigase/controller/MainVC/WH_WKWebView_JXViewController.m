//
//  WH_WKWebView_JXViewController.m
//  Tigase
//
//  Created by Apple on 2020/2/24.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_WKWebView_JXViewController.h"

#import "NSString+RITLExtension.h"

@interface WH_WKWebView_JXViewController ()

@property (nonatomic, strong) UIButton *backBtn;


@end

@implementation WH_WKWebView_JXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    CGFloat topH = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [self createHeadView];
    
    self.progressLine = [[WH_JXWebviewProgress alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, 0, 3)];
    self.progressLine.lineColor = HEXCOLOR(0x18B710);
    [self.view addSubview:self.progressLine];
    
    NSString *encodeUrl = [self.url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [g_server WH_userCheckReportUrl:encodeUrl toView:self];
}

- (void)createHeadView {
    UIView *tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
    [tableHeader setBackgroundColor:g_factory.navigatorBgColor];
    [self.view addSubview:tableHeader];
    
    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH-60*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.textColor       = g_factory.navigatorTitleColor;
    p.font = g_factory.navigatorTitleFont;
    p.text = self.title;
    p.userInteractionEnabled = YES;
//    p.didTouch = @selector(WH_actionTitle:);
    p.wh_delegate = self;
    p.wh_changeAlpha = NO;
    [tableHeader addSubview:p];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(tableHeader.frame) - 0.5, CGRectGetWidth(tableHeader.frame), 0.5)];
    [lineView setBackgroundColor:g_factory.globalBgColor];
    [tableHeader addSubview:lineView];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(NAV_INSETS-6, JX_SCREEN_TOP - 38-6, NAV_BTN_SIZE+12, NAV_BTN_SIZE+12)];
    [btn setImage:[UIImage imageNamed:@"title_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(clickMethod:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 0;
    [tableHeader addSubview:btn];
    btn.hidden = YES;
    self.backBtn = btn;
    
    
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setFrame:CGRectMake(JX_SCREEN_WIDTH - NAV_INSETS - 6 - NAV_BTN_SIZE - 12, JX_SCREEN_TOP - 38-6, NAV_BTN_SIZE+12, NAV_BTN_SIZE+12)];
    [refreshBtn setImage:[UIImage imageNamed:@"tabBar_refresh"] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(clickMethod:) forControlEvents:UIControlEventTouchUpInside];
    refreshBtn.tag = 1;
    [tableHeader addSubview:refreshBtn];
}

- (void)clickMethod:(UIButton *)button {
    //0:返回 1：刷新
    if (button.tag == 0) {
        if (self.wkWebView.canGoBack == YES) {
            [self.wkWebView goBack];
        }
    }else{
        [self.wkWebView reload];
    }
}

#pragma mark - 请求成功回调
-(void) WH_didServerResult_WHSucces:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    
    if ([aDownload.action isEqualToString:wh_act_userCheckReportUrl]) {
        
        [self webViewLoad];
    }
}

- (void)webViewLoad {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 30.0;
    configuration.preferences = preferences;
    
    self.wkWebView = [[WKWebView  alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP + 3, JX_SCREEN_WIDTH, CGRectGetHeight(self.view.frame) - JX_SCREEN_TOP - JX_SCREEN_BOTTOM - 3)];
    [self.wkWebView setBackgroundColor:[UIColor whiteColor]];
    NSLog(@"self.url:%@" ,self.url);
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    if ([self.url ritl_containChinese]) {
        //含有中文
        self.url = [self.url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [self.view addSubview:self.wkWebView];
}

#pragma mark - 请求失败回调
-(int) WH_didServerResult_WHFailed:(WH_JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    if ([aDownload.action isEqualToString:wh_act_userCheckReportUrl]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"prohibit" ofType:@"html"];
        NSURL* url = [NSURL  fileURLWithPath:path];//创建URL
        NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
        //        [webView loadRequest:request];//加载
        
        self.title = Localized(@"JX_ShikuProtocolTitle");
        
        return WH_hide_error;
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
    NSLog(@"开始加载");
    // 开始走进度条
    [self.progressLine startLoadingAnimation];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    [self.progressLine endLoadingAnimation];
    
    self.backBtn.hidden = !webView.canGoBack;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
//    [GKMessageTool showText:@"加载失败！"];
    [self.progressLine endLoadingAnimation];
    self.backBtn.hidden = !webView.canGoBack;
}
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
//! WKWeView在每次加载请求前会调用此方法来确认是否进行请求跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString*urlString = navigationAction.request.URL.absoluteString;
    urlString = [urlString stringByRemovingPercentEncoding];
    NSLog(@"拦截到的Url%@",navigationAction.request.URL);
    NSLog(@"拦截到的方法%@",navigationAction.request.URL.scheme);
    if ([urlString containsString:@"alipay"]){//alipay://alipayclient/
        //拦截到之后不允许跳转
        decisionHandler(WKNavigationActionPolicyCancel);
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
        }];
    } else if ([urlString containsString:@"weixin://wap/pay?"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        //解决wkwebview weixin://无法打开微信客户端的处理
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
        }];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
@end
