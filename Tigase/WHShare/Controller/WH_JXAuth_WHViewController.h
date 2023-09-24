//
//  WH_JXAuth_WHViewController.h
//  Tigase_imChatT
//
//  Created by p on 2018/11/2.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_JXAuth_WHViewController : WH_admob_WHViewController

@property (nonatomic, copy) NSString *urlSchemes;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, strong) UIImage *sdkImage;
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSString *fromSchema;

@property (nonatomic, assign) BOOL isWebAuth;
@property (nonatomic,copy) NSString *callbackUrl;

@end
