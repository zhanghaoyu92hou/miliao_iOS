//
//  ChatMoreButton.m
//  Tigase
//
//  Created by 齐科 on 2019/9/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "ChatMoreButton.h"
@interface ChatMoreButton()
{
    BOOL isMoreStyle;
}
@end
@implementation ChatMoreButton

- (void)setClockTitleWithIndex:(NSInteger)index {
    NSArray * timeArr = @[@"5秒", @"10秒", @"30秒", @"1分钟", @"5分钟", @"30分钟", @"1小时", @"6小时", @"12小时", @"1天", @"一星期"];
    NSString *title = timeArr[index - 1];
    if (!isMoreStyle) {//如果当前模式是时钟，只需要设置title
        [self setTitle:title forState:UIControlStateNormal];
        return;
    }
    isMoreStyle = NO;
    [self setTitle:title forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:8];
    [self setTitleColor:RGB(0, 147, 255) forState:UIControlStateNormal];
    [self setImageEdgeInsets:UIEdgeInsetsMake(3, 9,20, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(24 ,-16, 15,0)];
}
- (void)setMoreStyle {
    if (!isMoreStyle) {
        isMoreStyle = YES;
        [self setTitle:@"" forState:UIControlStateNormal];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0,0, 0)];
        [self setImage:[UIImage imageNamed:@"im_003_more_button_normal"] forState:UIControlStateNormal];
    }
}

@end
