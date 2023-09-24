//
//  WH_StrongReminderView.h
//  WaHu
//
//  Created by Apple on 2019/5/17.
//  Copyright © 2019 gaiwenkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_StrongReminderView : UIView

@property (nonatomic ,copy) void (^entryGroupCallback)(WH_StrongReminderView *reminderView);

@property (nonatomic, copy) NSString *wh_name;
@property (nonatomic, copy) NSString *wh_headUrl;
@property (nonatomic, strong) NSDictionary *wh_notice;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupUI;

- (void)wh_show;
- (void)wh_close;

@end

NS_ASSUME_NONNULL_END
