//
//  WH_JX_SelectMenuView.h
//  Tigase_imChatT
//
//  Created by Apple on 16/9/12.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_JX_SelectMenuView;

@protocol JXSelectMenuViewDelegate <NSObject>

- (void)didMenuView:(WH_JX_SelectMenuView *)MenuView WithIndex:(NSInteger)index;

@end

@interface WH_JX_SelectMenuView : UIView

@property (nonatomic, weak) id<JXSelectMenuViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *sels;

- (instancetype)initWithTitle:(NSArray *)titleArr image:(NSArray *)images cellHeight:(int)height;


// 隐藏
- (void)hide;


- (void)sp_getUserName;
@end
