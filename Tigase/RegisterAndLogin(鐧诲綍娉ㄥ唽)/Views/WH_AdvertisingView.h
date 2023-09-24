//
//  WH_AdvertisingView.h
//  Tigase
//
//  Created by Apple on 2019/10/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_AdvertisingView : UIView

@property (nonatomic, copy) void(^skipAdBlock)(void); //点击跳过
@property (nonatomic, assign) NSInteger countTime;  //倒计时的秒数
@property (nonatomic, assign, getter=isShowSkipButton) BOOL showSkipButton;  //倒计时的秒数
//图片有可能是url，有可能是image对象，跳过button默认隐藏
- (instancetype)initWithFrame:(CGRect)frame withImage:(id)image showSkipButton:(BOOL)isShow;
@end

NS_ASSUME_NONNULL_END
