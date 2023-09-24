//
//  CodeTextDemo
//
//  Created by 小侯爷 on 2018/9/20.
//  Copyright © 2018年 小侯爷. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WH_HWTFCodeView;
@protocol WH_HWTFCodeViewDelegate <NSObject>

- (void)codeView:(WH_HWTFCodeView *)codeView inputFnish:(NSString *)text;

@end


/**
 * 基础版 - 下划线
 */
@interface WH_HWTFCodeView : UIView

/// 当前输入的内容
@property (nonatomic, copy, readonly) NSString *code;

- (instancetype)initWithCount:(NSInteger)count margin:(CGFloat)margin;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, weak) id<WH_HWTFCodeViewDelegate> delegate;





NS_ASSUME_NONNULL_END
- (void)sp_getLoginState:(NSString *)followCount;
@end
