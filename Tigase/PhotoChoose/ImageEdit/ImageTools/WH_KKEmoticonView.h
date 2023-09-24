//
//  KKEmoticonView.h
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/12.
//  Copyright © 2017年 kook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_KKEmoticonTool;

@interface WH_KKEmoticonView : UIView

- (instancetype)initWithImage:(UIImage *)image tool:(WH_KKEmoticonTool *)tool;

/**
 设置当前选中的表情

 @param view 表情view
 */
+ (void)setActiveEmoticonView:(WH_KKEmoticonView*)view;
//- (void)setScale:(CGFloat)scale;


- (void)sp_getUsersMostLikedSuccess;
@end
