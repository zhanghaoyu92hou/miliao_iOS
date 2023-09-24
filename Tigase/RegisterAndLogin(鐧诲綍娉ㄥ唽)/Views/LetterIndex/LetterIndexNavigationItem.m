//
//  LetterIndexNavigationItem.m
//  UC_Demo_1.0.0
//
//  Created by Barry on 15/5/11.
//  Copyright (c) 2015年 Barry. All rights reserved.
//

#import "LetterIndexNavigationItem.h"

@implementation LetterIndexNavigationItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.exclusiveTouch = YES;
    self.multipleTouchEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.textColor = HEXCOLOR(0xAEAFB3);
    self.textAlignment = NSTextAlignmentCenter;
    self.font = [UIFont systemFontOfSize:12];
    self.clipsToBounds = YES;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setIsHighlighted:(BOOL)isHighlighted
{
    _isHighlighted = isHighlighted;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isHighlighted) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
    }else{
        self.textColor = HEXCOLOR(0xAEAFB3);
        self.backgroundColor = [UIColor clearColor];
    }
}



@end
