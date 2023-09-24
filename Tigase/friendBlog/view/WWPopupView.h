//
//  WWPopupView.h
//  WaHu
//
//  Created by fort on 2017/11/20.
//  Copyright © 2017年 gaiwenkeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBPopOverView.h"

@class WWPopupView;
@class WH_WeiboCell;

@protocol WWPopupDelegate<NSObject>

- (void)popupView:(WWPopupView *)popupView didSelectedItemAtIndex:(NSInteger)index userName:(NSString *)userName text:(NSString *)text feedId:(NSString *)feedId commentId:(NSString *)commentId btn:(UIButton *)btn cell:(WH_WeiboCell *)weiboCell;

@end

@interface WWPopupView : UIView

@property (nonatomic, weak)id<WWPopupDelegate>delegate;

@property (nonatomic, copy)NSString *wh_userName;
@property (nonatomic, copy)NSString *wh_text;
@property (nonatomic, copy)NSString *wh_feedId;
@property (nonatomic, copy)NSString *wh_commentId;

@property (nonatomic, copy)WH_WeiboCell *wh_weiboCell;

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items arrowDirection:(WBArrowDirection)direction;
- (void)popup;
- (void)dismiss;


- (void)sp_getLoginState;
@end
