//
//  WH_MyOrderTop_NavigationVew.h
//  Tigase
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_MyOrderTop_NavigationVew : UIView

@property (nonatomic ,strong) NSArray *listArray;

@property (nonatomic ,strong) NSMutableArray *btnArray;

@property (nonatomic ,assign) NSInteger currentIndex;

@property (nonatomic ,copy) void(^SelectedOrderTypeBlock)(NSInteger orderType);

@end

NS_ASSUME_NONNULL_END
