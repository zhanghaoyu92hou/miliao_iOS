//
//  WH_JXMenuView.h
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/6.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_JXMenuView;

@protocol JXMenuViewDelegate <NSObject>

- (void)didMenuView:(WH_JXMenuView *)menuView WithButtonIndex:(NSInteger)index;

@end

@interface WH_JXMenuView : UIView

@property (nonatomic, weak) id<JXMenuViewDelegate>delegate;

@property (nonatomic, strong) NSArray *wh_titles;


/**
 
暂为weiboVC 专用控件
Point (.x 暂时无效)

 */

//  创建
- (instancetype)initWithPoint:(CGPoint)point Title:(NSArray *)titles Images:(NSArray *)images;

//  隐藏
- (void)dismissBaseView;



- (void)sp_getLoginState;
@end
