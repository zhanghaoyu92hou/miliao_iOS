//
//  WHAddressbookSwitch.m
//  wahu_2.0
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_SegmentSwitch.h"

@interface WH_SegmentSwitch ()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *slideView;

@property (nonatomic , strong) UIButton *lastSelectBtn;

@end

@implementation WH_SegmentSwitch

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles{
    if(self = [super initWithFrame:frame]){
        [self setupUI:titles];
    }
    return self;
}

- (void)setupUI:(NSArray *)titles{
    CGFloat btnWidth = CGRectGetWidth(self.frame) / titles.count;
    
    _bgView = [UIView new];
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
    _bgView.backgroundColor = HEXCOLOR(0xF8FAFD);
    _bgView.layer.borderColor = HEXCOLOR(0xE3E9F3).CGColor;
    _bgView.layer.borderWidth = 1.f;
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.cornerRadius = 14.f;
    
    _slideView = [UIView new];
    [self addSubview:_slideView];
    [_slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.top.offset(-0.5f);
        make.bottom.offset(0.5f);
        make.width.offset(btnWidth);
    }];
    _slideView.backgroundColor = HEXCOLOR(0x0093FF);
    _slideView.layer.cornerRadius = _bgView.layer.cornerRadius;
    _slideView.layer.masksToBounds = YES;
    
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
        btn.titleLabel.font = g_factory.font12m;
        btn.tag = i+10;
        if(i == 0){
            _lastSelectBtn = btn;
            btn.selected = YES;
        }
        [btn setTitle:titles[i] forState:UIControlStateNormal];
    }
}

- (void)clickBtn:(UIButton *)btn{
    _lastSelectBtn.selected = NO;
    btn.selected = YES;
    [_bgView bringSubviewToFront:btn];
    [UIView animateWithDuration:0.25f animations:^{
        _slideView.transform = CGAffineTransformMakeTranslation((btn.tag - 10) * (CGRectGetWidth(self.frame) - CGRectGetWidth(btn.frame)) / 2.f, 0);
    }];
    if (_onClickBtn) {
        _onClickBtn(btn.tag - 10);
    }
    _lastSelectBtn = btn;
}
- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self clickBtn:[self viewWithTag:currentIndex+10]];
    }
}

@end
