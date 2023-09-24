//
//  WH_PhoneTextField.h
//  Tigase
//
//  Created by 齐科 on 2019/8/17.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, LoginFieldType) {
    LoginFieldPhoneNoType = 0,    //!< 手机号
    LoginFieldUserNameType, //!< 账号输入框
    LoginFieldPassWordType,   //!< 密码输入框
    LoginFieldSmsVerifyCodeType, //!< 短信验证码输入框
    LoginFieldImgVerifyCodeType, //!< 图片验证码输入框
    LoginFieldInviteCodeType    //!< 邀请码
};

@interface WH_LoginTextField : UITextField
@property (nonatomic, copy) void (^areaCodeBlock)(NSString *areaCode);
@property (nonatomic, assign) LoginFieldType fieldType; //!< YES 密码输入框， NO 用户名输入框

- (void)setCustomAttributePlaceHolder:(NSString *)placerHolder;
- (NSString *)getAreaString;
@end

NS_ASSUME_NONNULL_END
