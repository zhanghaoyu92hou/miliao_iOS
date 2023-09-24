//
//  WW_StrongReminderView.h
//  WaHu
//
//  Created by Apple on 2019/5/17.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WW_StrongReminderView : UIView

@property (nonatomic ,copy) void (^entryGroupCallback)(WW_StrongReminderView *reminderView);

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, strong) NSDictionary *notice;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupUI;

- (void)show;
- (void)close;



NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostFollowerSuccess;
@end
