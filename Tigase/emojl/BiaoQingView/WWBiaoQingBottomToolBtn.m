//
//  WWBiaoQingBottomToolBtn.m
//  WaHu
//
//  Created by Apple on 2019/3/4.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import "WWBiaoQingBottomToolBtn.h"

@implementation WWBiaoQingBottomToolBtn

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = 10;
    self.imageView.frame = CGRectMake(margin, margin, self.width-2*margin, self.height-2*margin);
}

@end
