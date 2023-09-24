//
//  NSString+StringNull.h
//  TesoText
//
//  Created by 锤子科技 on 16/4/9.
//  Copyright © 2016年 锤子科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (StringNull)
- (BOOL)isNull;
+ (BOOL)isBlankString:(NSString*)string;

+ (CGFloat)heightwoForWordContent:(NSString *)content withFontSize:(int)fontSize contentWidth:(CGFloat)width;
+ (CGFloat)widthwoForWordContent:(NSString *)content withFontSize:(int)fontSize;

//手机号校验
+(BOOL)validatePhone:(NSString *)phone;
//身份证校验
+ (BOOL)IsIdentityCard:(NSString *)IDNumber;
//检验银行卡
+ (BOOL) checkCardNo:(NSString*) cardNo;
//校验输入价格（大于0）
+(BOOL)validatePriceNum:(NSString *)price;
//判断是不是汉字
+ (BOOL)inputShouldChinese:(NSString *)inputString;
+ (BOOL)inputBase64Coding:(NSString *)inputString;
//判断是不是base64编码
- (CGSize)sizeOfTextWithMaxSize:(CGSize)maxSize font:(UIFont *)font;
+ (CGSize)sizeWithText:(NSString *)text maxSize:(CGSize)maxSize font:(UIFont *)font;

- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
+ (NSMutableAttributedString*)attrStrWith:(NSString*)str withFont:(CGFloat)strFont withFontRange:(NSRange)fontRange withColor:(UIColor*)strColor withColorRange:(NSRange)colorRange;

#pragma mark- 时间字符串转化
//把时间戳转化成时间字符串
- (NSString *)timeStampToStringWithFormaterStr:(NSString *)formaterStr;
//获取现在时间时间戳
+ (NSString *)getNowTimeTimestamp;
//时间字符串转化成时间戳
- (NSString *)formatTimeToTimestampWithFormaterStr:(NSString *)formaterStr;
//时间字符串转化
- (NSString *)timeStrToNewTimeStrWithOldFormaterStr:(NSString *)oldFormaterStr toNewFormaterStr:(NSString *)newFormaterStr;
//重写time的getter方法，获取时间
- (NSString *)toCustomTimeStrFormaterStr:(NSString *)formaterStr;

#pragma mark- 数字+字母组合验证
+ (BOOL)isPasswordStrNumberAndCharacter:(NSString *)userName;

- (CGFloat)getHeightOfStringWithspace:(float)lineSpace maxSize:(CGSize)size font:(CGFloat)font;

- (NSArray *)getLinesArrayOfStringWithMaxSize:(CGSize)size font:(UIFont *)font;

#pragma mark - MD5加密
- (NSString *)md5String;

+ (NSString *)getUUID;

@end

