//
//  WH_JXActionSheet_WHVC.h
//  Tigase_imChatT
//
//  Created by 1 on 2018/9/3.
//  Copyright © 2018年 YZK. All rights reserved.
//  视频直播

#import <UIKit/UIKit.h>

@class WH_JXActionSheet_WHVC;

@protocol WH_JXActionSheet_WHVCDelegate <NSObject>

/**
 
  控件点击事件index从 0 开始,从下到上
 
 */
- (void)actionSheet:(WH_JXActionSheet_WHVC *)actionSheet didButtonWithIndex:(NSInteger)index;


@end

@interface WH_JXActionSheet_WHVC : UIViewController

@property (nonatomic, assign) NSInteger wh_tag;
@property (nonatomic, strong) UIColor *wh_backGroundColor;
@property (nonatomic, weak) id<WH_JXActionSheet_WHVCDelegate>delegate;



/*
 * 类似微信从底部弹出的效果
 */
- (instancetype)initWithImages:(NSArray *)images names:(NSArray *)names;
    

- (void)sp_getUsersMostFollowerSuccess;
@end
