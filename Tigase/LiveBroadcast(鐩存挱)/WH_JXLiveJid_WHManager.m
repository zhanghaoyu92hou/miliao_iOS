//
//  WH_JXLiveJid_WHManager.m
//  Tigase_imChatT
//
//  Created by 1 on 17/8/9.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXLiveJid_WHManager.h"

@interface WH_JXLiveJid_WHManager ()

@property (atomic, strong) NSMutableArray * liveJidArray;

@end

@implementation WH_JXLiveJid_WHManager


+(instancetype)shareArray{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

-(instancetype)init{
    if (self = [super init]) {
        _liveJidArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)add:(NSString *)jid{
    [_liveJidArray addObject:jid];
}

-(void)remove:(NSString *)jid{
    NSUInteger index = [self indexOfFirst:jid];
    if (index != NSNotFound){
        [_liveJidArray removeObjectAtIndex:index];
    }
}

-(NSUInteger)indexOfFirst:(NSString *)jid{
    return [_liveJidArray indexOfObject:jid];
//    for (int i=0; i<_liveJidArray.count; i++) {
//        if ([[_liveJidArray objectAtIndex:i] isEqualToString:jid]) {
//            return i;
//        }
//    }
//    return NSNotFound;
}

-(BOOL)contains:(NSString *)jid{
    return [_liveJidArray containsObject:jid];
}

@end
