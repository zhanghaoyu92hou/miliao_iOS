//
//  WH_JXLiveJid_WHManager.h
//  Tigase_imChatT
//
//  Created by 1 on 17/8/9.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXLiveJid_WHManager : NSObject

+(instancetype)shareArray;

-(void)add:(NSString *)jid;

-(void)remove:(NSString *)jid;

-(NSUInteger)indexOfFirst:(NSString *)jid;

-(BOOL)contains:(NSString *)jid;


@end
