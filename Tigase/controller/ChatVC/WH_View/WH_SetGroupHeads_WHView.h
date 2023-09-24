//
//  WH_SetGroupHeads_WHView.h
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
//  修改群头像

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_SetGroupHeads_WHView : UIView

@property (nonatomic, copy) void (^wh_selectActionBlock)(NSInteger buttonTag);

- (instancetype)initWithFrame:(CGRect)frame;



NS_ASSUME_NONNULL_END
- (void)sp_checkNetWorking:(NSString *)isLogin;
@end
