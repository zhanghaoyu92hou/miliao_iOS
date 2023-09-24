//
//  NSString+StringNull.m
//  TesoText
//
//  Created by 锤子科技 on 16/4/9.
//  Copyright © 2016年 锤子科技. All rights reserved.
//

#import "NSString+StringNull.h"
#import <CoreText/CoreText.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (StringNull)

- (BOOL)isNull {
    
    if (!self) {
        return YES;
    } else if ([self isEqualToString:@""]) {
        return YES;
    } else if ([self isEqualToString:@"(null)"]) {
        return YES;
    } else if ([self isEqualToString:@"null"]) {
        return YES;
    } else if ([self isEqualToString:@"<null>"]) {
        return YES;
    } else if ([self isEqual:[NSNull null]]) {
        return YES;
    } else if (self.length == 0) {
        return YES;
    } else if (self == nil) {
        return YES;
    } else if (self == NULL) {
        return YES;
    }
    
    return  NO;
}

+ (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    } else if (string == NULL) {
        return YES;
    } else if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    } else if (string.length == 0) {
        return YES;
    } else if ([string isEqualToString:@"(null)"]) {
        return YES;
    } else if ([string isEqualToString:@"null"]) {
        return YES;
    } else if ([string isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}
#pragma mark ------返回字体的高度
+ (CGFloat)heightwoForWordContent:(NSString *)content withFontSize:(int)fontSize contentWidth:(CGFloat)width
{
    NSDictionary *arrtribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]};
    CGSize size = [content boundingRectWithSize:CGSizeMake(width, 50000000) options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:arrtribute context:nil].size;
    return size.height;
}
#pragma mark ------返回字体的宽度
+ (CGFloat)widthwoForWordContent:(NSString *)content withFontSize:(int)fontSize
{
    NSDictionary *arrtribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]};
    CGSize size = [content boundingRectWithSize:CGSizeMake(100000, 15) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:arrtribute context:nil].size;
    return size.width;
}

#pragma mark --
#pragma mark -- 检验是否是手机号 --

+ (BOOL)validatePhone:(NSString *)phone {
    NSString *phoneRegex1 = @"1[3456789]([0-9]){9}";
    NSPredicate *phoneTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex1];
    return  [phoneTest1 evaluateWithObject:phone];
    
    //    NSString *phoneRegex = @"1[3|5|7|8|][0-9]{9}";
    //    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    //    return [phoneTest evaluateWithObject:phone];
    
//    if (phone.length == 11) {
//        NSString *firstL = [phone substringToIndex:1];
//        if (firstL.intValue == 1) {
//            return YES ;
//        }
//    }
//    return NO ;
}

#pragma mark --
#pragma mark -- 身份证校验 --

+ (BOOL)IsIdentityCard:(NSString *)IDNumber {
    NSMutableArray *IDArray = [NSMutableArray array];
    if (IDNumber.length < 18) {
        return NO;
    }
    // 遍历身份证字符串,存入数组中
    for (int i = 0; i < 18; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [IDNumber substringWithRange:range];
        [IDArray addObject:subString];
    }
    // 系数数组
    NSArray *coefficientArray = [NSArray arrayWithObjects:@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2", nil];
    // 余数数组
    NSArray *remainderArray = [NSArray arrayWithObjects:@"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", nil];
    // 每一位身份证号码和对应系数相乘之后相加所得的和
    int sum = 0;
    for (int i = 0; i < 17; i++) {
        int coefficient = [coefficientArray[i] intValue];
        int ID = [IDArray[i] intValue];
        sum += coefficient * ID;
    }
    // 这个和除以11的余数对应的数
    NSString *str = remainderArray[(sum % 11)];
    // 身份证号码最后一位
    NSString *string = [IDNumber substringFromIndex:17];
    // 如果这个数字和身份证最后一位相同,则符合国家标准,返回YES
    if ([str.lowercaseString isEqualToString:string.lowercaseString]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark --
#pragma mark -- 检验银行卡 --

+ (BOOL) checkCardNo:(NSString*) cardNo {
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[cardNo length];
    int lastNum = [[cardNo substringFromIndex:cardNoLength-1] intValue];
    
    cardNo = [cardNo substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}

//对象方法
- (CGSize)sizeOfTextWithMaxSize:(CGSize)maxSize font:(UIFont *)font {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

//类方法
+ (CGSize)sizeWithText:(NSString *)text maxSize:(CGSize)maxSize font:(UIFont *)font {
    return [text sizeOfTextWithMaxSize:maxSize font:font];
}

//计算label文本的高度
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    
    CGSize resultSize = CGSizeZero;
    if (self.length <= 0) {
        return resultSize;
    }
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        resultSize = [self boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: font } context:nil].size;
    } else {
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        
        resultSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        
#endif
        
    }
    resultSize = CGSizeMake(MIN(size.width, ceilf(resultSize.width)), MIN(size.height, ceilf(resultSize.height)));
    
    return resultSize;
}
+ (NSMutableAttributedString*)attrStrWith:(NSString*)str withFont:(CGFloat)strFont withFontRange:(NSRange)fontRange withColor:(UIColor*)strColor withColorRange:(NSRange)colorRange{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    if (fontRange.length>0) {
        [AttributedStr addAttribute:NSFontAttributeName
         
                              value:[UIFont systemFontOfSize:strFont]
         
                              range:fontRange];
    }
    if (colorRange.length>0) {
        [AttributedStr addAttribute:NSForegroundColorAttributeName
         
                              value:strColor
         
                              range:colorRange];
    }
    
    return AttributedStr;
}
+ (BOOL)validatePriceNum:(NSString *)price
{
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.\n"] invertedSet];
    NSString *filtered = [[price componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [price isEqualToString:filtered];
    if(!basicTest)
    {
        //输入了非法字符
        return NO;
    }
    //其他的类型不需要检测，直接写入
    return YES;
}
//判断是不是汉字
+ (BOOL)inputShouldChinese:(NSString *)inputString {
    if (inputString.length == 0){
        return NO;
    }
    
    NSString *regex = @"[\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}
//判断是不是base64编码
+ (BOOL)inputBase64Coding:(NSString *)inputString {
    if (inputString.length == 0){
        return NO;
    }
    
    NSString *regex = @"^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}
//把时间戳转化成时间字符串
- (NSString *)timeStampToStringWithFormaterStr:(NSString *)formaterStr {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self longLongValue]];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//日期时间格式化对象
    [formater setDateFormat:formaterStr];//设置日期显示格式
    return [formater stringFromDate:date];//把日期对象转化为字符串
}

//获取现在时间时间戳
+ (NSString *)getNowTimeTimestamp {
    NSDate *datenow = [NSDate date];//现在时间
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

// 时间字符串转化为时间戳字符串
- (NSString *)formatTimeToTimestampWithFormaterStr:(NSString *)formaterStr {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:formaterStr]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:self]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    NSString *timeSpStr = [NSString stringWithFormat:@"%zd", timeSp];
    return timeSpStr;
}

- (NSString *)timeStrToNewTimeStrWithOldFormaterStr:(NSString *)oldFormaterStr toNewFormaterStr:(NSString *)newFormaterStr {
    
    NSString *timeSpStr = [self formatTimeToTimestampWithFormaterStr:oldFormaterStr];
    
    NSString *newTimeStr = [timeSpStr timeStampToStringWithFormaterStr:newFormaterStr];
    return newTimeStr;
}
   
//由时间字符串转为自定义
- (NSString *)toCustomTimeStrFormaterStr:(NSString *)formaterStr {
    NSString *timeSpStr = [self formatTimeToTimestampWithFormaterStr:formaterStr];
    //把数字的日期，转换成日期对象
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeSpStr.integerValue];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //两个日期相减，获取指定的日期部分
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:date toDate:[NSDate date] options:0];
    if (components.minute < 60) {
        return [NSString stringWithFormat:@"%zd分钟前",components.minute];
    }
    //获取秒
    components = [calendar components:NSCalendarUnitSecond fromDate:date toDate:[NSDate date] options:0];
    NSString *h = [[NSString getNowTimeTimestamp] timeStampToStringWithFormaterStr:@"HH"];
    NSString *m = [[NSString getNowTimeTimestamp] timeStampToStringWithFormaterStr:@"mm"];
    NSString *s = [[NSString getNowTimeTimestamp] timeStampToStringWithFormaterStr:@"ss"];
    
    if (components.second <= h.integerValue * 3600 + m.integerValue * 60 + s.integerValue) {
        
        return [self timeStrToNewTimeStrWithOldFormaterStr:formaterStr toNewFormaterStr:@"HH:mm:ss"];
    }

    //获取日期
    NSDateFormatter *ndf = [[NSDateFormatter alloc] init];
//    ndf.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    ndf.dateFormat = @"yyyy-MM-dd";
    return [ndf stringFromDate:date];
}

#pragma mark- 数字+字母组合验证
+ (BOOL)isPasswordStrNumberAndCharacter:(NSString *)userName {
    NSString *nameRegex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    return [nameTest evaluateWithObject:userName];
}

- (CGFloat)getHeightOfStringWithspace:(float)lineSpace maxSize:(CGSize)size font:(CGFloat)font {
//    NSArray *strArr = [self getLinesArrayOfStringWithMaxSize:size font:[UIFont systemFontOfSize:font]];
    
    NSInteger numLines = [self sizeOfTextWithMaxSize:size font:[UIFont systemFontOfSize:font]].height / [UIFont systemFontOfSize:font].lineHeight;
    
    if (self.length == 0) {
        numLines = 0;
    }
    
    float textH = 0;
    if (numLines == 0) {
        textH = 0;
    } else if (numLines == 1) {
        textH = [UIFont systemFontOfSize:font].lineHeight;
    } else {
        textH = numLines * [UIFont systemFontOfSize:font].lineHeight + (numLines - 1) * lineSpace;
    }
//    LKLog(@"strArr == %@", strArr);
//    LKLog(@"numLines == %zd", numLines);
    
    return ceilf(textH);
}

- (NSArray *)getLinesArrayOfStringWithMaxSize:(CGSize)size font:(UIFont *)font {
    
    if (self.length == 0) {
        return [NSArray new];
    }
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge  id)myFont range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,size.width,size.height));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [self substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}

- (NSString *)md5String {
    const char *str = self.UTF8String;
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(str, (CC_LONG)strlen(str), buffer);
    
    return [self stringFromBytes:buffer length:CC_MD5_DIGEST_LENGTH];
}

    /**
     *  返回二进制 Bytes 流的字符串表示形式
     *
     *  @param bytes  二进制 Bytes 数组
     *  @param length 数组长度
     *
     *  @return 字符串表示形式
     */
- (NSString *)stringFromBytes:(uint8_t *)bytes length:(int)length {
    NSMutableString *strM = [NSMutableString string];
    
    for (int i = 0; i < length; i++) {
        [strM appendFormat:@"%02x", bytes[i]];
    }
    
    return [strM copy];
}

/**  卸载应用重新安装后会不一致*/
+ (NSString *)getUUID {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;;
}

@end

