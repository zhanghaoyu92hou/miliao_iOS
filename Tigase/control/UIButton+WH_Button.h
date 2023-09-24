//
//  UIButton+WH_Button.h
//  Tigase
//
//  Created by Apple on 2019/7/2.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,LLButtonStyle) {
    LLButtonStyleTextOnly = 1, //只显示文字
    LLButtonStyleImgOnly,      //只显示图片
    LLButtonStyleTextLeft,     //文字在左，图片在右
    LLButtonStyleTextRight,    //文字在右，图片在左
    LLButtonStyleTextTop,      //文字在上，图片在下
    LLButtonStyleTextBottom    //文字在下，图片在上
};

@interface UIButton (WH_Button)
//调用这个方法前，必须先设置好button的image和title/attributedtitle 要不然无法生效
- (void)layoutButtonWithEdgeInsetsStyle:(LLButtonStyle)style
                        imageTitleSpace:(CGFloat)space;
@end

NS_ASSUME_NONNULL_END
