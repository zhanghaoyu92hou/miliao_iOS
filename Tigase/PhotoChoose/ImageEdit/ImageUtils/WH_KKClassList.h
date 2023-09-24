//
//  KKClassList.h
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/10.
//  Copyright © 2017年 kook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_KKClassList : NSObject

//获取所有子类
+ (NSArray*)subclassesOfClass:(Class)parentClass;


- (void)sp_checkUserInfo;
@end
