//
//  KKTextView.h
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/18.
//  Copyright © 2017年 kook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_KKTextTool;

static NSString* const kTextViewActiveViewDidTapNotification = @"kTextViewActiveViewDidTapNotification";

@interface WH_KKTextView : UIView

@property (nonatomic, strong) UIColor *textColor;

+ (void)setActiveTextView:(WH_KKTextView*)view;
- (id)initWithTool:(WH_KKTextTool*)tool;

- (void)setLableText:(NSString *)text;
- (NSString *)getLableText;


- (void)sp_getMediaData;
@end
