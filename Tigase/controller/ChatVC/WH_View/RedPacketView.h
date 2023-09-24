//
//  RedPacketView.h
//  Tigase
//
//  Created by 齐科 on 2019/9/19.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RedPacketView : UIView
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, copy) void (^redPocketBlock)(NSDictionary *dict, BOOL success);

- (instancetype)initWithRedPacketInfo:(NSDictionary *)infoDic;
- (void)showRedPacket;
- (void)closeRedPacket ;

@end

NS_ASSUME_NONNULL_END
