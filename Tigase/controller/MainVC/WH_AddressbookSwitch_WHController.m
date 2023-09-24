//
//  WH_AddressbookSwitch_WHController.m
//  Tigase
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_AddressbookSwitch_WHController.h"

@interface WH_AddressbookSwitch_WHController () <UIScrollViewDelegate>

@property (nonatomic  , strong) NSArray *viewControllers;

@property (nonatomic, strong) WH_SlideConflict_Scroll_WHView *bgScrollView;

@end

@implementation WH_AddressbookSwitch_WHController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)setupUI{
    _bgScrollView = [[WH_SlideConflict_Scroll_WHView alloc] init];
    [self.view addSubview:_bgScrollView];
    _bgScrollView.scrollEnabled = NO;
    [_bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
}


/**
 设置scrollView添加的子viewController

 @param viewControllers 待加到scrollView的VC
 */
- (void)setupViewControllers:(NSArray <UIViewController *>*)viewControllers{
    _viewControllers = viewControllers; //需强引用数组,否则数组中控制器会被release,进而控制器的view会从父视图移除
    UIViewController *viewController = nil;
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    for (int i = 0; i < viewControllers.count; i++) {
        viewController = viewControllers[i];
        [_bgScrollView addSubview:viewController.view];
        viewController.view.frame = CGRectMake(i*width, 0, width, height);
        [viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(i*width);
            make.top.offset(0);
            make.width.offset(width);
            make.height.offset(height);
        }];
    }
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.contentSize = CGSizeMake(width*viewControllers.count, height);
    _bgScrollView.pagingEnabled = YES;
    
    _bgScrollView.delegate = self;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _currentPageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    if (_onCurrentIndexChange) {
        _onCurrentIndexChange(_currentPageIndex);
    }
    _bgScrollView.isFilterCellGest = _currentPageIndex != 1;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex{
    if (_currentPageIndex != currentPageIndex) {
        _currentPageIndex = currentPageIndex;
        _bgScrollView.isFilterCellGest = _currentPageIndex != 1;
        [_bgScrollView setContentOffset:CGPointMake(currentPageIndex * CGRectGetWidth(_bgScrollView.frame), 0) animated:YES];
    }
}

@end

@implementation WH_SlideConflict_Scroll_WHView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (_isFilterCellGest && [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}



@end
