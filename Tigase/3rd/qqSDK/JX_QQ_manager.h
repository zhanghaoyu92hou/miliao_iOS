//
//  JX_QQ_manager.h
//  Tigase
//
//  Created by 史小峰 on 2019/7/25.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
NS_ASSUME_NONNULL_BEGIN

@interface JX_QQ_manager : NSObject

//回调
@property (nonatomic ,strong) void(^loginCallBack)(TencentOAuth *tecentOauth);
/**
 QQ等陆接口
 */
- (void)QQ_login;
@end

NS_ASSUME_NONNULL_END
