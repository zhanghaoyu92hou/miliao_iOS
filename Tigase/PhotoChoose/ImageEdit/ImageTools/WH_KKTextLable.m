//
//  KKTextLable.m
//  WWImageEdit
//
//  Created by 邬维 on 2017/2/5.
//  Copyright © 2017年 kook. All rights reserved.
//

#import "WH_KKTextLable.h"

@implementation WH_KKTextLable



- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
}


- (void)sp_getMediaData {
    NSLog(@"Check your Network");
}
@end
