//
//  WWPopupView.m
//  WaHu
//
//  Created by fort on 2017/11/20.
//  Copyright © 2017年 gaiwenkeji. All rights reserved.
//

#import "WWPopupView.h"
#import "WWZanButton.h"

@interface WWPopupView()

@property (nonatomic, strong)WBPopOverView *popView;

@end

@implementation WWPopupView

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items arrowDirection:(WBArrowDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGPoint point = CGPointMake(frame.origin.x, frame.origin.y + frame.size.height / 2.f);
        _popView=[[WBPopOverView alloc]initWithOrigin:point Width:frame.size.width Height:frame.size.height Direction:direction];//初始化弹出视图的箭头顶点位置point，展示视图的宽度Width，高度Height，Direction以及展示的方向
        _popView.layer.cornerRadius = 6;
        _popView.layer.masksToBounds = YES;
        for (NSInteger i = 0; i < items.count; i ++) {
            WWZanButton *button = [[WWZanButton alloc] init];
            if ([items[i] isKindOfClass:[NSString class]]){
                NSString *title = items[i];
                [button setTitle:title forState:UIControlStateNormal];
            }else{
                NSDictionary *dic = items[i];
                [button setTitle:dic[@"title"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:dic[@"icon"]] forState:UIControlStateNormal];
            }
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.frame = CGRectMake(frame.size.width / items.count * i, 0, frame.size.width / items.count, frame.size.height);
            button.tag = i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            if (items.count > 1) {
                UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x-1, 8, 1, frame.size.height - 16)];
                sepLine.backgroundColor = HEXCOLOR(0x373D40);
                [_popView.wh_backView addSubview:sepLine];
            }
            
            [_popView.wh_backView addSubview:button];
        }
    }
    return self;
}

- (void)popup
{
    [_popView popView];
}

- (void)dismiss
{
    [_popView dismiss];
}

- (void)setWh_userName:(NSString *)userName
{
    _wh_userName = userName;
}

- (void)setWh_text:(NSString *)text
{
    _wh_text = text;
}

- (void)setWh_feedId:(NSString *)feedId
{
    _wh_feedId = feedId;
}

- (void)setWh_commentId:(NSString *)commentId
{
    _wh_commentId = commentId;
}

- (void)buttonAction:(WWZanButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(popupView:didSelectedItemAtIndex:userName:text:feedId:commentId:btn:cell:)]) {
        [self.delegate popupView:self didSelectedItemAtIndex:sender.tag userName:_wh_userName text:_wh_text feedId:_wh_feedId commentId:_wh_commentId btn:sender cell:_wh_weiboCell];
    }
}


- (void)sp_getLoginState {
    NSLog(@"Get User Succrss");
}
@end
