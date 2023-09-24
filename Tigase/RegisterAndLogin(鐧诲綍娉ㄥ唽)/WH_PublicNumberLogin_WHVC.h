//
//  WH_PublicNumberLogin_WHVC.h
//  Tigase
//
//  Created by 闫振奎 on 2019/8/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WH_PublicNumberLoginType) {
    WH_PublicNumberLoginGongZhongPingTai, //公众平台登录
    WH_PublicNumberLoginKaiFangPingTai, //开放平台
    WH_PublicNumberLoginPC, //PC端
};

@interface WH_PublicNumberLogin_WHVC : WH_admob_WHViewController

@property (nonatomic, assign) WH_PublicNumberLoginType type;
    
@property (nonatomic, copy) NSString *qrCodeStr; //二维码扫码字符串

@end

NS_ASSUME_NONNULL_END
