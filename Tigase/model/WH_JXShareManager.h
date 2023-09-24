//
//  WH_JXShareManager.h
//  Tigase_imChatT
//
//  Created by MacZ on 16/8/19.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMShare/UMShare.h>
#import "WH_JXShareModel.h"
//#import <FBSDKShareKit/FBSDKShareKit.h>

@protocol ShareManagerDelegate <NSObject>

- (void)didShareSuccess;

@end

@interface WH_JXShareManager : NSObject<UMSocialPlatformProvider/*,FBSDKSharingDelegate*/>

@property (nonatomic,weak) id delegate;

+ (WH_JXShareManager *)defaultManager;

- (void)shareWith:(WH_JXShareModel *)shareModel delegate:(id)delegate;

@end
