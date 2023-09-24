//
//  WH_JXLocPerImage_WHVC.m
//  Tigase_imChatT
//
//  Created by Apple on 16/10/23.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXLocPerImage_WHVC.h"

@implementation WH_JXLocPerImage_WHVC



-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self creatUI];
    }
    return self;
}


-(void)creatUI{
    //自定义图片view
    _wh_headView = [[UIView alloc]initWithFrame:CGRectMake(-25, -60, 50, 60)];
    _wh_headView.backgroundColor = [UIColor clearColor];
    _wh_pointImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 60)];
    _wh_pointImage.image = [UIImage imageNamed:@"locationAcc2"];
    [_wh_headView addSubview:_wh_pointImage];
    _wh_headImage = [[WH_JXImageView alloc]initWithFrame:CGRectMake(5, 3, 40, 40)];
    [_wh_headImage headRadiusWithAngle:_wh_headImage.frame.size.width * 0.5];
    [_wh_headView addSubview:_wh_headImage];
    [self addSubview:_wh_headView];
}

-(void)wh_selectAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        _wh_headView.frame = CGRectMake(-30, -70, 60, 70);
        _wh_pointImage.frame = CGRectMake(0, 0, 60, 70);
        [_wh_headImage headRadiusWithAngle:25.0];
        _wh_headImage.frame = CGRectMake(6, 2, 48, 48);
    }];
}

-(void)wh_cancelSelectAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        _wh_headView.frame = CGRectMake(-25, -60, 50, 60);
        _wh_pointImage.frame = CGRectMake(0, 0, 50, 60);
        _wh_headImage.frame = CGRectMake(5, 3, 40, 40);
        [_wh_headImage headRadiusWithAngle:20.0];
    }];
}

-(void)wh_setData:(NSDictionary*)data andType:(int)dataType{

    [g_server WH_getHeadImageSmallWIthUserId:[NSString stringWithFormat:@"%lld",[data[@"userId"] longLongValue]] userName:data[@"nickname"] imageView:_wh_headImage];
   
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [_wh_headImage convertPoint:point fromView:self];
        if (CGRectContainsPoint(_wh_headImage.bounds, tempoint))
        {
            view = _wh_headImage;
        }
    }
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
