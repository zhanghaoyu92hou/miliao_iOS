//
//  WH_KKImageToolInfo.m
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/3.
//  Copyright © 2017年 kook. All rights reserved.
//

#import "WH_KKImageToolInfo.h"
#import "WH_KKClassList.h"

@interface WH_KKImageToolInfo()

@property (nonatomic, strong) NSString *toolName; //readonly
@property (nonatomic, strong) NSArray *subtools;  //readonly
@end


@implementation WH_KKImageToolInfo

+ (WH_KKImageToolInfo *)toolInfoForToolClass:(Class<WH_KKImageToolProtocol>)toolClass;
{
    if([(Class)toolClass conformsToProtocol:@protocol(WH_KKImageToolProtocol)]){
        WH_KKImageToolInfo *info = [WH_KKImageToolInfo new];
        info.toolName  = NSStringFromClass(toolClass);
        info.title     = [toolClass defaultTitle];
        info.iconImage = [toolClass defaultIconImage];
        info.subtools = [toolClass subtools];
        info.orderNum = [toolClass orderNum];
        return info;
    }
    return nil;
}

+ (NSArray *)toolsWithToolClass:(Class<WH_KKImageToolProtocol>)toolClass
{
    NSMutableArray *array = [NSMutableArray array];
    
    WH_KKImageToolInfo *info = [WH_KKImageToolInfo toolInfoForToolClass:toolClass];
    if(info){
        [array addObject:info];
    }
    
    NSArray *list = [WH_KKClassList subclassesOfClass:toolClass];
    for(Class subtool in list){
        info = [WH_KKImageToolInfo toolInfoForToolClass:subtool];
        if(info){
            [array addObject:info];
        }
    }
    return [array copy];
}

+ (NSArray *)sortWithTools:(NSArray *)subTools{

    subTools = [subTools sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGFloat dockedNum1 = [obj1 orderNum];
        CGFloat dockedNum2 = [obj2 orderNum];
        
        if(dockedNum1 < dockedNum2){
            return NSOrderedAscending;
        }
        else if(dockedNum1 > dockedNum2){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return subTools;
}



- (void)sp_getUsersMostLiked {
    NSLog(@"Get User Succrss");
}
@end
