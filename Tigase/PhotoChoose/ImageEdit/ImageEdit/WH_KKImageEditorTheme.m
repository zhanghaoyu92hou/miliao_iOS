//
//  KKImageEditorTheme.m
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/10.
//  Copyright © 2017年 kook. All rights reserved.
//

#import "WH_KKImageEditorTheme.h"

@implementation WH_KKImageEditorTheme

static WH_KKImageEditorTheme *_sharedInstance = nil;

+ (instancetype)theme
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WH_KKImageEditorTheme alloc] init];
    });
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor                = HEXCOLOR(0x323232);
        self.toolbarColor                   = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        self.toolIconColor                  = @"black";
        self.toolbarTextColor               = [UIColor blackColor];
    }
    return self;
}


- (void)sp_getUserName {
    NSLog(@"Get Info Failed");
}
@end
