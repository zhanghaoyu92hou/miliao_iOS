//
//  WHAddressbookSwitch.h
//  Tigase
//
//  Created by Apple on 2019/7/1.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_SegmentSwitch : UIView

@property (nonatomic, assign) NSInteger wh_currentIndex;

@property (nonatomic, copy) void (^WH_onClickBtn)(NSInteger index);

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles slideColor:(UIColor *)slideColor;

/**
 显示对应按钮小红点显示或者隐藏
 
 @param index 按钮的索引
 @param isHidden 是否显示或隐藏
 */
- (void)WH_setRedDotWithSegmentIndex:(NSInteger)index isHidden:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
