//
//  JXWebviewProgress.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXWebviewProgress : UIView

//进度条颜色
@property (nonatomic,strong) UIColor  *lineColor;

//开始加载
-(void)startLoadingAnimation;

//结束加载
-(void)endLoadingAnimation;


NS_ASSUME_NONNULL_END
- (void)sp_getLoginState;
@end
