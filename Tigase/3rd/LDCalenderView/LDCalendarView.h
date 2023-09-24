//
//  LDCalendarView.h
//
//  Created by lidi on 15/9/1.
//  Copyright (c) 2015年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDCalendarConst.h"

typedef void(^DaysSelectedBlock)(NSArray *result);

@interface LDCalendarView : UIView
@property (nonatomic, strong) NSArray          *defaultDays;
@property (nonatomic, copy  ) DaysSelectedBlock complete;
@property (nonatomic,strong) NSArray *list;

@property (nonatomic ,assign) Boolean isGroupSignIn; //是否是群签到
@property (nonatomic ,strong) NSString *roomId;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame roomId:(NSString *)roomId;
- (void)show;
- (void)hide;
@property(strong,nonatomic) NSMutableArray *dateList;
-(void) signature:(NSMutableArray *) array;//签到

- (void)sp_getLoginState;
@end
