//
//  WH_JXCommonService.h
//  Tigase_imChatT
//
//  Created by p on 2017/11/9.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXCommonService : NSObject

@property (nonatomic, strong) NSTimer *wh_courseTimer;

- (void)WH_sendCourse:(WH_JXMsgAndUserObject *)obj Array:(NSArray *)array;

@end
