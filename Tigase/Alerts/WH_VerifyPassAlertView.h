//
//  WH_VerifyPassView.h
//  Tigase
//
//  Created by 齐科 on 2019/9/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_VerifyPassAlertView : UIView
@property (nonatomic, copy) void (^confirmBlock)(NSString *fieldString, UILabel *tipLabel);

- (instancetype)initWithTitle:(NSString *)title;

- (void)showAlert;
- (void)dismissAlert;
@end

NS_ASSUME_NONNULL_END
