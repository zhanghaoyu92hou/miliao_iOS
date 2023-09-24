//
//  KKToolBarItem.h
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/3.
//  Copyright © 2017年 kook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_KKImageToolInfo.h"

/**
 工具栏的menu item
 */
@interface WH_KKToolBarItem : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) WH_KKImageToolInfo *imgToolInfo;

- (instancetype)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action toolInfo:(WH_KKImageToolInfo*)toolInfo;


- (void)sp_upload;
@end
