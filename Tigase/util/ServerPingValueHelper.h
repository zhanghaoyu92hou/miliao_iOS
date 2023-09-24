//
//  ServerPingValueHelper.h
//  Tigase
//
//  Created by 齐科 on 2019/10/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerPingValueHelper : NSObject
+ (void)getCurrentXmppServerPingValue:(void (^) (NSDictionary *_Nonnull pingDic))pingBlock;
+ (void)getNodesServerPingValue:(void (^) (NSDictionary *_Nonnull pingDic))pingBlock;
@end

NS_ASSUME_NONNULL_END
