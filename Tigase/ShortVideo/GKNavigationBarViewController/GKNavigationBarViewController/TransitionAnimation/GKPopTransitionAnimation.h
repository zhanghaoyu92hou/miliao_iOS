//
//  GKPopTransitionAnimation.h
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKPopTransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)transitionWithScale:(BOOL)scale;


- (void)sp_getUsersMostLiked;
@end
