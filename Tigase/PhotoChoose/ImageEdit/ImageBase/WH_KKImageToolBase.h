//
//  KKImageToolBase.h
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/3.
//  Copyright © 2017年 kook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WH_KKImageEditor_WHViewController.h"
#import "WH_UIView+Frame.h"
#import "WH_KKImageToolProtocol.h"
#import "WH_KKImageToolInfo.h"
#import "WH_KKImageEditorTheme.h"

static const CGFloat kImageToolAnimationDuration = 0.3; //工具栏平移动画时间

typedef NS_ENUM(NSUInteger,WH_KKToolIndexNumber){
    KKToolIndexNumberFirst = 0,
    KKToolIndexNumberSecond = 1,
    KKToolIndexNumberThird = 2,
    KKToolIndexNumberFourth = 3,
    KKToolIndexNumberFifth = 4,
};

/**
 图片工具类 基类
 */
@interface WH_KKImageToolBase : NSObject<WH_KKImageToolProtocol>

@property (nonatomic, weak) WH_KKImageEditor_WHViewController *editor; //图片编辑vc
@property (nonatomic, weak) WH_KKImageToolInfo *toolInfo;  //工具信息

- (id)initWithImageEditor:(WH_KKImageEditor_WHViewController*)editor withToolInfo:(WH_KKImageToolInfo *)info;

/**
 初始化工具信息
 */
- (void)setup;


/**
 取消修改
 */
- (void)cleanup;

/**
 保存修改
 */
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;




@end
