//
//  WH_CustomActionSheetView.h
//  Tigase
//
//  Created by 闫振奎 on 2019/7/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_CustomActionSheetView : UIView

@property (nonatomic, copy) void (^wh_okActionBlock)(void);
@property (nonatomic, copy) void (^wh_cancelActionBlock)(void);

- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)title;

- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)title sureBtnColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
