//
//  LetterScopeView.m
//  QuickVoip2.0
//
//  Created by Apparitionqk on 2018/4/23.
//  Copyright © 2018年 FengHuoWanJia. All rights reserved.
//

#import "LetterEnlargeView.h"
@interface LetterEnlargeView()
@property (nonatomic, strong) UILabel *letterLabel;
@end
@implementation LetterEnlargeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"enlarge"];
        [self addSubview:self.letterLabel];
    }
    return self;
}
- (UILabel *)letterLabel {
    if (!_letterLabel) {
        _letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width*0.8, self.height)];
        _letterLabel.textColor = [UIColor whiteColor];
        _letterLabel.font = [UIFont systemFontOfSize:18];
        _letterLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _letterLabel;
}

- (void)setLetter:(NSString *)letter {
    _letter = letter;
    _letterLabel.text = letter;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
