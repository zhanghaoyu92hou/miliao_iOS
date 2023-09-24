//
//  VoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2019年 __APP__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceConverter : NSObject

+ (NSString *)amrToWav:(NSString*)filePath;
+ (NSString *)wavToAmr:(NSString*)filePath;

@end
