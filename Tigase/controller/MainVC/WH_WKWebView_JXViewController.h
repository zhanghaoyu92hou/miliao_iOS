//
//  WH_WKWebView_JXViewController.h
//  Tigase
//
//  Created by Apple on 2020/2/24.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

#import <WebKit/WebKit.h>

#import "WH_JXWebviewProgress.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_WKWebView_JXViewController : WH_admob_WHViewController<WKNavigationDelegate ,WKUIDelegate>

@property (nonatomic ,copy) NSString *url;

@property (nonatomic ,strong) WKWebView *wkWebView;

// 进度条
@property (nonatomic, strong) WH_JXWebviewProgress *progressLine;

@end

NS_ASSUME_NONNULL_END
