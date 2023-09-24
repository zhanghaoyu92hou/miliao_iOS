//
//  BindTelephoneHelper.m
//  Tigase
//
//  Created by 齐科 on 2019/9/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "BindTelephoneChecker.h"
#import "WH_ChangeTheBoundPhoneNumber_WHViewController.h"
#import "WH_JXUserObject.h"

@implementation BindTelephoneChecker
+ (void)checkBindPhoneWithViewController:(UIViewController *)viewController entertype:(JXEnterType)enterType {
    g_myself.isPayPassword = [g_default objectForKey:PayPasswordKey];//因为通过获取用户信息的接口,获取不到用户的支付密码是否已经设置信息,所以目前采用保存在g_default中,防止发生修改支付密码出现无法识别返回值问题
    if (![g_myself.isPayPassword boolValue]) {//不存在支付密码
        if ([g_default boolForKey:WH_ThirdPartyLogins] && IsStringNull(g_myself.phone)) {//第三方登录、未绑定手机号
            WH_ChangeTheBoundPhoneNumber_WHViewController *boundPhoneVC = [[WH_ChangeTheBoundPhoneNumber_WHViewController alloc] init];
            [boundPhoneVC setTopTitle:@"设置手机号"];
            [g_navigation pushViewController:boundPhoneVC animated:YES];
        }else {
            [BindTelephoneChecker setPaypassForFirstTimeWithViewController:viewController entertype:enterType];
        }
    }else {//修改支付密码
        WH_JXPayPassword_WHVC * PayVC = [[WH_JXPayPassword_WHVC alloc] init];
        PayVC.type = JXPayTypeInputPassword;
        PayVC.enterType = JXEnterTypeSecureSetting;
        [g_navigation pushViewController:PayVC animated:YES];
    }
}
//未设置支付密码，设置支付密码
+ (void)setPaypassForFirstTimeWithViewController:(UIViewController *)viewController entertype:(JXEnterType)enterType {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"您还未设置支付密码，请设置支付密码。" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WH_JXPayPassword_WHVC * PayVC = [WH_JXPayPassword_WHVC alloc];
        PayVC.type = JXPayTypeSetupPassword;
        PayVC.enterType = enterType;
        PayVC = [PayVC init];
        [g_navigation pushViewController:PayVC animated:YES];
//    }];
//    [alertController addAction:confirmAction];
//    [viewController presentViewController:alertController animated:YES completion:nil];
}
@end
