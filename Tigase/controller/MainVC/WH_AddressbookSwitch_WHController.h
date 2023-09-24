//
//  WH_AddressbookSwitch_WHController.h
//  Tigase
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_AddressbookSwitch_WHController : WH_admob_WHViewController

/**
 设置scrollView添加的子viewController
 
 @param viewControllers 待加到scrollView的VC
 */
- (void)setupViewControllers:(NSArray <UIViewController *>*)viewControllers;


/**
 当前页索引
 */
@property (nonatomic , assign) NSInteger currentPageIndex;

@property (nonatomic , copy) void (^onCurrentIndexChange)(NSInteger currentPageIndex);

@end

@interface WH_SlideConflict_Scroll_WHView : UIScrollView <UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isFilterCellGest; //是否过滤cell的手势


NS_ASSUME_NONNULL_END

@end
