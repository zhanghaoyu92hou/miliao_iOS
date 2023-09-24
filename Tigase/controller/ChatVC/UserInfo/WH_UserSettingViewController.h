//
//  WH_UserSettingViewController.h
//  Tigase
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_UserSettingViewController : WH_admob_WHViewController<UIAlertViewDelegate>

@property (nonatomic ,assign) NSInteger wh_friendStatus; //好友状态
@property (nonatomic,strong) WH_JXUserObject* wh_user;

@property (nonatomic ,strong) NSString *wh_fStatus;

@property (nonatomic ,strong) NSString *wh_xmppMsgId;
@property (nonatomic, assign) int wh_fromAddType;



NS_ASSUME_NONNULL_END
- (void)sp_getUserName;
@end
