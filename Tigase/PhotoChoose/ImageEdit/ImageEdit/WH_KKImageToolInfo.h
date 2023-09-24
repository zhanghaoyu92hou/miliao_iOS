//
//  WH_KKImageToolInfo.h
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/3.
//  Copyright © 2017年 kook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WH_KKImageToolProtocol.h"

@interface WH_KKImageToolInfo : NSObject

@property (nonatomic, readonly) NSString *toolName; //类名
@property (nonatomic, strong)   NSString *title;    //工具显示的名称
@property (nonatomic, strong) UIImage  *iconImage;  //图片
@property (nonatomic, readonly) NSArray  *subtools; //包含的子工具信息 WH_KKImageToolInfo数组
@property (nonatomic, assign) NSUInteger orderNum;  //显示的顺序


/**
 获取toolInfo
 @param toolClass 实现KKImageToolProtocol的工具类
 @return 图片工具信息
 */
+ (WH_KKImageToolInfo*)toolInfoForToolClass:(Class<WH_KKImageToolProtocol>)toolClass;


/**
 获取全部工具类
 @param toolClass KKImageToolBase 基类
 */
+ (NSArray*)toolsWithToolClass:(Class<WH_KKImageToolProtocol>)toolClass;


/**
 工具栏排序
 @param subTools WH_KKImageToolInfo 数组
 @return 排序后的 subTools
 */
+ (NSArray *)sortWithTools:(NSArray *)subTools;


- (void)sp_getUsersMostLiked;
@end
