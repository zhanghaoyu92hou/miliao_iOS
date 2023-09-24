//
//  WH_CustomActionSheetView.m
//  Tigase
//
//  Created by 闫振奎 on 2019/7/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_CustomActionSheetView.h"

@interface WH_CustomActionSheetView ()

@end
@implementation WH_CustomActionSheetView


- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *topBgView = [[UIView alloc] init];
        topBgView.backgroundColor = [UIColor whiteColor];
        [topBgView radiusWithAngle:15];
        [self addSubview:topBgView];
        
        topBgView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 120);
        
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = HEXCOLOR(0x8C9AB8);
        lab.font = pingFangMediumFontWithSize(18);
        [self addSubview:lab];
        lab.frame = CGRectMake(38, 25, JX_SCREEN_WIDTH-38*2, 61);
        lab.numberOfLines = 0;
        lab.lineBreakMode = NSLineBreakByCharWrapping;
        [topBgView addSubview:lab];
        lab.text = title;
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomView];
        
        bottomView.frame = CGRectMake(0, 108, JX_SCREEN_WIDTH, self.height - 108);
        
        
        //分割线
        UIView *sepLineView = [[UIView alloc] init];
        sepLineView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 0.5);
        sepLineView.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        [bottomView addSubview:sepLineView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomView addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.layer.borderWidth = 0.5;
        cancelBtn.layer.borderColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:234/255.0 alpha:1.0].CGColor;
        cancelBtn.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        cancelBtn.layer.cornerRadius = 10;
        [cancelBtn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn.titleLabel setFont:pingFangMediumFontWithSize(16)];
        cancelBtn.frame = CGRectMake(32, 25, (JX_SCREEN_WIDTH - 32*2 - 17)*0.5, 44);
        
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomView addSubview:okBtn];
        [okBtn addTarget:self action:@selector(okBtnAction) forControlEvents:UIControlEventTouchUpInside];
        okBtn.layer.borderWidth = 0.5;
        okBtn.layer.borderColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:234/255.0 alpha:1.0].CGColor;
        
        okBtn.layer.backgroundColor = [UIColor colorWithRed:237/255.0 green:99/255.0 blue:80/255.0 alpha:1.0].CGColor;
        okBtn.layer.cornerRadius = 10;
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn.titleLabel setFont:pingFangMediumFontWithSize(16)];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        okBtn.frame = CGRectMake(JX_SCREEN_WIDTH * 0.5+17*0.5, 25, (JX_SCREEN_WIDTH - 32*2 - 17)*0.5, 44);
        
        
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)title sureBtnColor:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *topBgView = [[UIView alloc] init];
        topBgView.backgroundColor = [UIColor whiteColor];
        [topBgView radiusWithAngle:15];
        [self addSubview:topBgView];
        
        topBgView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 130);
        
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = HEXCOLOR(0x8C9AB8);
        lab.font = pingFangMediumFontWithSize(18);
        [self addSubview:lab];
        lab.frame = CGRectMake(38, 25, JX_SCREEN_WIDTH-38*2, 81);
        lab.numberOfLines = 0;
        lab.lineBreakMode = NSLineBreakByCharWrapping;
        [topBgView addSubview:lab];
        lab.text = title;
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomView];
        
        bottomView.frame = CGRectMake(0, 118, JX_SCREEN_WIDTH, self.height - 118);
        
        
        //分割线
        UIView *sepLineView = [[UIView alloc] init];
        sepLineView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 0.5);
        sepLineView.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        [bottomView addSubview:sepLineView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomView addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.layer.borderWidth = 0.5;
        cancelBtn.layer.borderColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:234/255.0 alpha:1.0].CGColor;
        cancelBtn.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        cancelBtn.layer.cornerRadius = 10;
        [cancelBtn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn.titleLabel setFont:pingFangMediumFontWithSize(16)];
        cancelBtn.frame = CGRectMake(32, 25, (JX_SCREEN_WIDTH - 32*2 - 17)*0.5, 44);
        
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomView addSubview:okBtn];
        [okBtn addTarget:self action:@selector(okBtnAction) forControlEvents:UIControlEventTouchUpInside];
        okBtn.layer.borderWidth = 0.5;
//        okBtn.layer.borderColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:234/255.0 alpha:1.0].CGColor;
//
//        okBtn.layer.backgroundColor = [UIColor colorWithRed:237/255.0 green:99/255.0 blue:80/255.0 alpha:1.0].CGColor;
        okBtn.layer.borderColor = color.CGColor;
        okBtn.layer.backgroundColor = color.CGColor;
        
        okBtn.layer.cornerRadius = 10;
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn.titleLabel setFont:pingFangMediumFontWithSize(16)];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        okBtn.frame = CGRectMake(JX_SCREEN_WIDTH * 0.5+17*0.5, 25, (JX_SCREEN_WIDTH - 32*2 - 17)*0.5, 44);
        
        
        
    }
    return self;
}


- (void)cancelBtnAction
{
    if (self.wh_cancelActionBlock) {
        self.wh_cancelActionBlock();
    }
}

- (void)okBtnAction
{
    if (self.wh_okActionBlock) {
        self.wh_okActionBlock();
    }
}

- (void)dealloc{
    NSLog(@"--------------------------");
}

@end
