//
//  NSString+ContainStr.m
//  Tigase_imChatT
//
//  Created by 1 on 17/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "NSString+ContainStr.h"

@implementation NSString (WH_ContainStr)

-(BOOL)containsMyString:(NSString *)str{
    if ([self rangeOfString:str].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

//生成UUID
+ (NSString *)createUUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString * uuid = (__bridge NSString *)uuid_string_ref;
    CFRelease(uuid_string_ref);
    return uuid;
}

- (BOOL)isUrl {
    if(self == nil) {
        return NO;
    }
    
    NSString *url;
    if (self.length>4 && [[self substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",self];
    }else{
        url = self;
    }
    NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
}
- (void)sp_getUserName {
    NSLog(@"Get User Succrss");
}

+ (BOOL)isHasChineseWithStr:(NSString *)strFrom {
    for (int i=0; i<strFrom.length; i++) {
        NSRange range =NSMakeRange(i, 1);
        NSString * strFromSubStr=[strFrom substringWithRange:range];
        const char *cStringFromstr = [strFromSubStr UTF8String];
        if (strlen(cStringFromstr)==3) {
            //汉字
            return YES;
        } else if (strlen(cStringFromstr)==1) {
            //字母
        }
        
    }
    
    return NO;
}

@end
