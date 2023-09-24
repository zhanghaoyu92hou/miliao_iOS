//
//  WH_LoginViewController.h
//  Tigase
//
//  Created by 齐科 on 2019/8/18.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_LoginViewController : WH_admob_WHViewController
@property (assign) BOOL isSwitchUser;   //!< 是否切换账号
@property (assign) BOOL isFromAuth;

@property (nonatomic ,strong) UIButton *pointBtn;
@property (nonatomic ,strong) UILabel *pointLabel; //节点

@property (nonatomic ,assign) Boolean isInitialization; //是否为初始化

@property (nonatomic ,assign) Boolean isPushEntering ;//是否是push进入的

//授权登录页面需要传的值
@property (nonatomic, strong) UIImage *sdkImage;
@property (nonatomic, strong) NSDictionary *shareInfoDic;
@property (nonatomic, strong) NSString *fromSchema;

@end

NS_ASSUME_NONNULL_END
