//
//  WHAddressbookSwitch.m
//  Tigase
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SegmentSwitch.h"

@interface WH_SegmentSwitch ()

@property (nonatomic , strong) UIView *wh_bgView;
@property (nonatomic , strong) UIView *wh_slideView;

@property (nonatomic , strong) UIButton *wh_lastSelectBtn;

@end

@implementation WH_SegmentSwitch

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles slideColor:(UIColor *)slideColor{
    if(self = [super initWithFrame:frame]){
        [self setupUI:titles slideColor:slideColor];
    }
    return self;
}

- (void)setupUI:(NSArray *)titles slideColor:(UIColor *)slideColor{
    CGFloat btnWidth = CGRectGetWidth(self.frame) / titles.count;
    
    _wh_bgView = [UIView new];
    [self addSubview:_wh_bgView];
    [_wh_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
    _wh_bgView.backgroundColor = HEXCOLOR(0xF8FAFD);
    _wh_bgView.layer.borderColor = HEXCOLOR(0xE3E9F3).CGColor;
    _wh_bgView.layer.borderWidth = 1.f;
    _wh_bgView.layer.masksToBounds = YES;
    _wh_bgView.layer.cornerRadius = 14.f;
    
    _wh_slideView = [UIView new];
    [self addSubview:_wh_slideView];
    [_wh_slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.top.offset(-0.5f);
        make.bottom.offset(0.5f);
        make.width.offset(btnWidth);
    }];
    _wh_slideView.backgroundColor = slideColor;
    _wh_slideView.layer.cornerRadius = _wh_bgView.layer.cornerRadius;
    _wh_slideView.layer.masksToBounds = YES;
    
//    NSArray *btnTitles = @[@"全部",@"群组",@"新朋友"];
    UIButton *btn = nil;
    for (int i = 0; i < titles.count; i++) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.bottom.offset(0);
//            if(i == 0){
//                make.left.offset(0);
//            } else if(i == 1){
//                make.centerX.offset(0);
//            } else {
//                make.right.offset(0);
//            }
//            make.width.offset(segmentW);
//        }];
        btn.frame = CGRectMake(i*btnWidth, 0, btnWidth, CGRectGetHeight(self.frame));
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setTitleColor:HEXCOLOR(0x8C9AB8) forState:UIControlStateNormal];
        btn.titleLabel.font = pingFangMediumFontWithSize(12);
        btn.tag = i+10;
        if(i == 0){
            _wh_lastSelectBtn = btn;
            btn.selected = YES;
        }
        [btn setTitle:titles[i] forState:UIControlStateNormal];
    }
}

- (void)clickBtn:(UIButton *)btn{
    _wh_lastSelectBtn.selected = NO;
    btn.selected = YES;
    [_wh_bgView bringSubviewToFront:btn];
    [UIView animateWithDuration:0.25f animations:^{
//        _slideView.transform = CGAffineTransformMakeTranslation((btn.tag - 10) * (CGRectGetWidth(self.frame) - CGRectGetWidth(btn.frame)) / 2.f, 0);
        _wh_slideView.transform = CGAffineTransformMakeTranslation((btn.tag - 10) * CGRectGetWidth(btn.frame), 0);
    }];
    if (_WH_onClickBtn) {
        _WH_onClickBtn(btn.tag - 10);
    }
    _wh_lastSelectBtn = btn;
}
- (void)setWh_currentIndex:(NSInteger)currentIndex{
    if (_wh_currentIndex != currentIndex) {
        _wh_currentIndex = currentIndex;
        [self clickBtn:[self viewWithTag:currentIndex+10]];
    }
}


/**
 显示对应按钮小红点显示或者隐藏

 @param index 按钮的索引
 @param isHidden 是否显示或隐藏
 */
- (void)WH_setRedDotWithSegmentIndex:(NSInteger)index isHidden:(BOOL)isHidden{
    UIButton *btn = [self viewWithTag:10+index];
    if (btn) {
        UIView *redDotView = [btn viewWithTag:1001];
        if (!redDotView) {
            redDotView = [UIView new];
            [btn addSubview:redDotView];
            [redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(btn.titleLabel.mas_right).offset(2);
                make.centerY.equalTo(btn.titleLabel);
                make.width.height.offset(6);
            }];
            redDotView.tag = 1001;
            redDotView.backgroundColor = HEXCOLOR(0xED6350);
            redDotView.layer.cornerRadius = 6 / 2.f;
            redDotView.layer.masksToBounds = YES;
        }
        redDotView.hidden = isHidden;
    }
}

@end
