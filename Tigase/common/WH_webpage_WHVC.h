//
//  WH_webpage_WHVC.h
//  sjvodios
//
//  Created by  on 19-5-3-8.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@class AppDelegate;
//@class WH_admob_WHViewController;
@protocol JXServerResult;
#import "WH_admob_WHViewController.h"

@interface WH_webpage_WHVC : WH_admob_WHViewController<UIScrollViewDelegate>{
    WKWebView*  webView;
    UIActivityIndicatorView *aiv;
    
    int   _type;
    float _num;
    float _price;
    NSString* _product;
}

@property(nonatomic,strong) WKWebView* webView;
@property(nonatomic,strong) NSString* url;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) BOOL isGoBack;
@property (nonatomic, assign) BOOL isOnMainVC;//是否是在带tabbar的主界面上的web
@property (nonatomic, assign) BOOL isFormSuspension;//是否是悬浮窗点进来的
@property (nonatomic ,assign) BOOL isPostRequest; //是否为post请求

@property (nonatomic ,assign) BOOL isOpenFile; //是否是打开本地文件

-(float)getMoney:(char*)s;

@end
