                                         //
//  KKImageToolBase.m
//  WWImageEdit
//
//  Created by 邬维 on 2017/1/3.
//  Copyright © 2017年 kook. All rights reserved.
//

#import "WH_KKImageToolBase.h"

@implementation WH_KKImageToolBase

- (id)initWithImageEditor:(WH_KKImageEditor_WHViewController*)editor withToolInfo:(WH_KKImageToolInfo *)info{
    self = [super init];
    if(self){
        self.editor   = editor;
        self.toolInfo = info;
    }
    return self;
}

- (void)setup
{
    
}

- (void)cleanup
{
    
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    completionBlock(self.editor.imageView.image, nil, nil);
}


#pragma mark- protocol
+ (UIImage*)defaultIconImage{
    return nil;
}

+ (NSString*)defaultTitle{
    return @"toolTitle";
}

+ (NSArray*)subtools{
    return nil;
}

+ (NSUInteger)orderNum{
    return 0;
}


@end
