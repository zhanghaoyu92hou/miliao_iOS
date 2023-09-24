//
//  WH_SetGroupHeads_WHView.m
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SetGroupHeads_WHView.h"

@implementation WH_SetGroupHeads_WHView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *topBgView = [[UIView alloc] init];
        topBgView.backgroundColor = [UIColor whiteColor];
        [topBgView radiusWithAngle:15];
        [self addSubview:topBgView];
        
        topBgView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, CGRectGetHeight(frame)+20);
        
        NSArray *array = @[Localized(@"JX_TakePhoto") ,Localized(@"JX_ChoosePhoto"),Localized(@"JX_Cencal")];
        CGFloat buttonHeight = (CGRectGetHeight(frame) - (THE_DEVICE_HAVE_HEAD ? 34 : 0))/ array.count;
        for (int i = 0; i < array.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0, i*buttonHeight, self.frame.size.width, buttonHeight)];
            [btn setTag:i];
            [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 17]];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [topBgView addSubview:btn];
            [btn addTarget:self action:@selector(buttonClickMethod:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i > 0 && i < array.count) {
                UIView *lView = [[UIView alloc] initWithFrame:CGRectMake(0, i*(buttonHeight + 10), self.frame.size.width, g_factory.cardBorderWithd)];
                [lView setBackgroundColor:HEXCOLOR(0xE8E8E8)];
                [topBgView addSubview:lView];
                [lView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.right.equalTo(btn);
                    make.height.offset(g_factory.cardBorderWithd);
                }];
            }
            
        } 
    }
    return self;
}

- (void)buttonClickMethod:(UIButton *)btn {
    //button.tag 0:拍摄照片 1:选择照片 2:取消
    if (self.wh_selectActionBlock) {
        self.wh_selectActionBlock(btn.tag);
    }
}


- (void)sp_checkNetWorking:(NSString *)isLogin {
    NSLog(@"Get User Succrss");
}
@end
