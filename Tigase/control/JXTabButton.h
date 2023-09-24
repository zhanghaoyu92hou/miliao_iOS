//
//  JXTabButton.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-5-17.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXBadgeView;

@interface JXTabButton : UIButton{
    UIImageView* _icon;
    UILabel* _lbTitle;
    WH_JXBadgeView* _lbBage;
}
@property (nonatomic, strong) NSString *wh_iconName;

@property (nonatomic, strong) NSString *wh_selectedIconName;

@property (nonatomic, strong) NSString *wh_backgroundImageName;

@property (nonatomic, strong) NSString *wh_selectedBackgroundImageName;

@property (nonatomic, strong) NSString *wh_text;

@property (nonatomic, strong) UIColor *wh_textColor;

@property (nonatomic, strong) UIColor *wh_selectedTextColor;

@property (nonatomic, strong) NSString *wh_bage;

@property (nonatomic, assign) BOOL      wh_isTabMenu;

@property (nonatomic, assign) SEL		wh_onDragout;

@property (nonatomic, weak) NSObject* wh_delegate;

- (void)show;

@end
