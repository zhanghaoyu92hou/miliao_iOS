//
//  ThirdLoginView.h
//  Tigase
//
//  Created by 齐科 on 2019/9/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThirdLoginView : UIView
@property (nonatomic, copy) void (^thirdLoginBlock)(NSInteger loginType);

@end

NS_ASSUME_NONNULL_END
