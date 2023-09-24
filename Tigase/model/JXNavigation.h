//
//  JXNavigation.h
//  Tigase_imChatT
//
//  Created by p on 2017/12/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXNavigation : NSObject

// 页面进出总栈
@property (nonatomic, strong) NSMutableArray *subViews;
// 当前页面控制器的上一个控制器
@property (nonatomic, strong) UIViewController *lastVC;
// 根视图
@property (nonatomic, strong) UIViewController *rootViewController;


// window上的第一层总view，页面都将加在navigationView上，
// 其他如loading符类似需显示在上方的view可以加在window上面，
// 这样可以不受页面进出动画影响
@property (nonatomic, strong) UIView *navigationView;

+(JXNavigation*)sharedInstance;
- (instancetype)init;

// 边缘手势
- (void)screenEdgePanGestureRecognizer:(UIViewController *)viewController;

// 入栈
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
// 出栈
- (void)WH_dismiss_WHViewController:(UIViewController *)viewController animated:(BOOL)animated;
// 跳转根视图
- (void)popToRootViewController;
// 指定的单个控制器回跳(只能跳转subViews中的VC)
- (void)popToViewController:(Class)viewController animated:(BOOL)animated;

@end
