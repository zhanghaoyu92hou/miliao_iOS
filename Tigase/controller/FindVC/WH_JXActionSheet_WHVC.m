//
//  WH_JXActionSheet_WHVC.m
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/3.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXActionSheet_WHVC.h"

#define HEIGHT 49    // 每个成员高度，如果更改记得更改button按钮的imageEdgeInsets

@interface WH_JXActionSheet_WHVC ()

@property (nonatomic, strong) UIView *wh_baseView;
@property (nonatomic, strong) NSArray *wh_names;
@property (nonatomic, strong) NSArray *wh_images;


@end

@implementation WH_JXActionSheet_WHVC

- (instancetype)initWithImages:(NSArray *)images names:(NSArray *)names {
    self = [super init];
    if (self) {
        //这句话是让控制器透明
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.wh_backGroundColor = [UIColor whiteColor];
        self.wh_names = names;
        self.wh_images = images;
    }
    return self;
}

// 控制器生命周期方法(view加载完成)
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.tag = self.wh_tag;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    if (self.wh_images.count > 0 || self.wh_names.count > 0) {
        self.wh_baseView = [[UIView alloc] init];
        self.wh_baseView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self.view addSubview:self.wh_baseView];
        [self WH_setupViews];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.3f animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.wh_baseView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}

- (void)WH_setupViews {
    // 创建一个取消按钮
    [self WH_create_WHButtonWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM) index:10000];
    for (int i = 0; i < self.wh_names.count; i++) {
        int h = HEIGHT*(i+1);
        // 创建成员按钮
        [self WH_create_WHButtonWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM - h-5, JX_SCREEN_WIDTH, HEIGHT) index:i];
    }
}

- (void)WH_didButton:(UIButton *)button {
    
    //离开界面
    [self dismissViewController];
    if (button.tag >= 0 && button.tag != 10000) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:didButtonWithIndex:)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate actionSheet:self didButtonWithIndex:button.tag];
            });
        }
    } else {
        
    }
}

- (void)WH_create_WHButtonWithFrame:(CGRect)frame index:(int)index {
    UIButton *button = [[UIButton alloc] init];
    button.frame = frame;
    [button setTitle:index==10000 ? Localized(@"JX_Cencal") : self.wh_names[index] forState:UIControlStateNormal];
    if (self.wh_images.count > 0 && index !=10000 && index < self.wh_images.count) {
        [button setImage:[UIImage imageNamed:self.wh_images[index]] forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        // 修改button图片大小
        button.imageEdgeInsets = UIEdgeInsetsMake(14, 0, 14, 14);
    }
    button.backgroundColor = self.wh_backGroundColor;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.tag = index;
    [self.wh_baseView addSubview:button];
    [button addTarget:self action:@selector(WH_didButton:) forControlEvents:UIControlEventTouchUpInside];
    if (index == 10000) {
        if (THE_DEVICE_HAVE_HEAD) { // iPhoneX 字体显示上移
            button.titleEdgeInsets = UIEdgeInsetsMake(-6, 0, 6, 0);
        }
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM-5, JX_SCREEN_WIDTH, 5)];
        line.backgroundColor = HEXCOLOR(0xDBDBDB);
        [self.wh_baseView addSubview:line];
    }else {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, JX_SCREEN_WIDTH, 0.5)];
        line.backgroundColor = HEXCOLOR(0xDBDBDB);
        [button addSubview:line];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewController];
}


- (void)dismissViewController {
    [UIView animateWithDuration:.3f animations:^{
        self.wh_baseView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self) {
            [self.view removeFromSuperview];
        }
    }];
}


- (void)sp_getUsersMostFollowerSuccess {
    NSLog(@"Check your Network");
}
@end
