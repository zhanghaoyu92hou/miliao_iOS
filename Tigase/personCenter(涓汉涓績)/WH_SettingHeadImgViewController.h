//
//  WH_SettingHeadImgViewController.h
//  Tigase
//
//  Created by 齐科 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_SettingHeadImgViewController : WH_admob_WHViewController
@property (nonatomic, strong) WH_JXUserObject* user;
@property (nonatomic, strong) UIImage *defaultImage; //!<默认的头像图片名称
/**
    修改头像成功回调
 */
@property (nonatomic, copy) void (^changeHeadImageBlock)(UIImage *headImage);
@property (nonatomic, assign) BOOL isNeedRegistFirst; //!< 是否需要注册

@end

NS_ASSUME_NONNULL_END
