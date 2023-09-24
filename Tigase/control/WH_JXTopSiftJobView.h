//
//  WH_JXTopSiftJobView.h
//  Tigase_imChatT
//
//  Created by MacZ on 16/5/19.
//  Copyright (c) 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXTopSiftJobView : UIView{
    NSArray *_paraDataArray;
    
    UIView *_bottomSlideLine;
    UIView *_moreParaView;
    NSInteger _paraSelIndex;
}

/**
 默认选项,要在dataArray前赋值
 */
@property (nonatomic, assign) NSUInteger wh_preferred;
@property (nonatomic, strong) NSArray *wh_dataArray;
@property (nonatomic,weak) id wh_delegate;
@property (nonatomic, assign) BOOL wh_isShowMoreParaBtn;

- (void)WH_showMoreParaView:(BOOL)show;
- (void)WH_moveBottomSlideLine:(CGFloat)offsetX; //移动顶部下划线
- (void)WH_resetItemBtnWith:(CGFloat)offsetX; //scrollView滑动结束，改变顶部item按钮选中状态
- (void)WH_resetSelParaBtnTransform;  //参数按钮图片旋转角度归零
- (void)WH_resetWithIndex:(NSInteger)index itemId:(int)itemId itemValue:(NSString *)value; //选中经验、公司规模
- (void)WH_resetWithIndex:(NSInteger)index min:(NSInteger)min max:(NSInteger)max; //选中薪水
- (void)WH_resetAllParaBtn;

- (void)WH_resetBottomLineIndex:(NSUInteger)index;

@end
