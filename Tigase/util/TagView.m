//
//  TagView.m
//  CustomTag
//
//  Created by za4tech on 2017/12/15.
//  Copyright © 2017年 Junior. All rights reserved.
//

#import "TagView.h"

@implementation TagView

//-(void)setArr:(NSArray *)arr{
//    _arr = arr;
//    CGFloat marginX = scaleX(15);
//    CGFloat marginY = scaleY(10);
//    CGFloat height = scaleY(25);
//    UIButton * markBtn;
//    for (int i = 0; i < _arr.count; i++) {
//        CGFloat width =  [self calculateString:_arr[i] Width:scaleY(12)] + 50;
//        UIButton * tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        if (!markBtn) {
//            tagBtn.frame = CGRectMake(marginX, marginY, width, height);
//        }else{
//            if (markBtn.frame.origin.x + markBtn.frame.size.width + marginX + width + marginX > SCREEN_WIDTH) {
//                tagBtn.frame = CGRectMake(marginX, markBtn.frame.origin.y + markBtn.frame.size.height + marginY, width, height);
//            }else{
//                tagBtn.frame = CGRectMake(markBtn.frame.origin.x + markBtn.frame.size.width + marginX, markBtn.frame.origin.y, width, height);
//            }
//        }
//        [tagBtn setTitle:_arr[i] forState:UIControlStateNormal];
//        tagBtn.titleLabel.font = [UIFont systemFontOfSize:scaleY(13)];
//        [tagBtn setTitleColor:TBRGBColor(0, 0, 0) forState:UIControlStateNormal];
//        [self makeCornerRadius:scaleY(5) borderColor:TBRGBColor(0, 0, 0) layer:tagBtn.layer borderWidth:0.7];
//        markBtn = tagBtn;
//        
//        [tagBtn addTarget:self action:@selector(clickTag:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:markBtn];
//    }
//    CGRect rect = self.frame;
//    rect.size.height = markBtn.frame.origin.y + markBtn.frame.size.height + marginY;
//    self.frame = rect;
//}

- (void)loadBtns:(NSArray *)items height:(CGFloat)height corner:(CGFloat)cor color:(UIColor *)text border:(UIColor *)color {
    
    CGFloat marginX = 10;
    CGFloat marginY = 12;
    CGFloat space = 12;
    CGFloat fontsize = 15;

    UIButton * markBtn;
    for (int i = 0; i < items.count; i++) {
        CGFloat width =  [self calculateString:items[i] Width:fontsize] + space*2;
        UIButton * tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (!markBtn) {
            tagBtn.frame = CGRectMake(marginX, marginY, width, height);
        }else{
            if (markBtn.frame.origin.x + markBtn.frame.size.width + marginX + width + marginX > self.width) {
                tagBtn.frame = CGRectMake(marginX, markBtn.frame.origin.y + markBtn.frame.size.height + marginY, width, height);
            }else{
                tagBtn.frame = CGRectMake(markBtn.frame.origin.x + markBtn.frame.size.width + marginX, markBtn.frame.origin.y, width, height);
            }
        }
        tagBtn.backgroundColor = [UIColor whiteColor];

        [tagBtn setTitle:items[i] forState:UIControlStateNormal];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
        [tagBtn setTitleColor:text forState:UIControlStateNormal];
        tagBtn.layer.cornerRadius = cor;
        tagBtn.backgroundColor = color;
        markBtn = tagBtn;
        
        [tagBtn addTarget:self action:@selector(clickTo:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:markBtn];
    }
    CGRect rect = self.frame;
    rect.size.height = markBtn.frame.origin.y + markBtn.frame.size.height + marginY;
    self.frame = rect;
}

-(void)clickTag:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleSelectTag:btn:)]) {
        [self.delegate handleSelectTag:sender.titleLabel.text btn:sender];
    }
}

-(void)clickTo:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleSelectTag:)]) {
        [self.delegate handleSelectTag:sender.titleLabel.text];
    }
}

-(void)makeCornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor layer:(CALayer *)layer borderWidth:(CGFloat)borderWidth
{
    layer.cornerRadius = radius;
    layer.masksToBounds = YES;
    layer.borderColor = borderColor.CGColor;
    layer.borderWidth = borderWidth;
}

-(CGFloat)calculateString:(NSString *)str Width:(NSInteger)font
{
    CGSize size = [str boundingRectWithSize:CGSizeMake(self.width, 100000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]} context:nil].size;
    return size.width;
}

@end
