//
//  ReplyCell.m
//  Tigase_imChatT
//
//  Created by Apple on 16/6/25.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "ReplyCell.h"

@implementation ReplyCell

//@synthesize label;
//-(void)prepareForReuse
//{
//    self.label.wh_match=nil;
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.wh_pointIndex = point.x/10;
//    printf("point = %lf,%lf\n", point.x, point.y);
//    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(3, 4, JX_SCREEN_WIDTH - 80, 27)];
        _label.font = [UIFont systemFontOfSize:13];
        _label.numberOfLines = 0;
        _label.textColor = HEXCOLOR(0x576B94);
        _label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_label];
    }
    return _label;
}

- (void)sp_checkNetWorking:(NSString *)isLogin {
    NSLog(@"Get User Succrss");
}
@end
