//
//  WH_PwsSecSettingViewController.h
//  Tigase
//
//  Created by Apple on 2019/8/12.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class DMDropDownMenu;

NS_ASSUME_NONNULL_BEGIN

@interface WH_PwsSecSettingViewController : WH_admob_WHViewController
@property (nonatomic,strong) UITextField *question1TF;
@property (nonatomic,strong) UITextField *question2TF;
@property (nonatomic,strong) UITextField *question3TF;
@property (nonatomic,strong) DMDropDownMenu *dm1;
@property (nonatomic,strong) DMDropDownMenu *dm2;
@property (nonatomic,strong) DMDropDownMenu *dm3;
@property (nonatomic, assign) BOOL isRegist; //!< 是否是注册用户
@property (nonatomic, copy) void (^questionBlock)(NSString *questions);
@end

NS_ASSUME_NONNULL_END
