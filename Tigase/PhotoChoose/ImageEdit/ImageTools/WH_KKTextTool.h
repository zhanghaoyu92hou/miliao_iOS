//
//  KKTextTool.h
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/18.
//  Copyright © 2017年 kook. All rights reserved.
//

#import "WH_KKImageToolBase.h"
@class WH_KKTextView;

@interface WH_KKTextTool : WH_KKImageToolBase 
@property (nonatomic, strong) WH_KKTextView *selectedTextView; //当前选中的文字

- (void)sp_didUserInfoFailed;
@end
