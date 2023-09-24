//
//  WH_JXSetShikuNum_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2019/4/11.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class WH_JXSetShikuNum_WHVC;

@protocol WH_JXSetShikuNum_WHVCDelegate <NSObject>

-(void)setShikuNum:(WH_JXSetShikuNum_WHVC *)setShikuNumVC updateSuccessWithAccount:(NSString *)account;

@end

@interface WH_JXSetShikuNum_WHVC : WH_admob_WHViewController

@property (nonatomic, strong) WH_JXUserObject *user;

@property (nonatomic, weak) id<WH_JXSetShikuNum_WHVCDelegate> delegate;



NS_ASSUME_NONNULL_END
- (void)sp_upload;

- (void)sp_checkUserInfo;
@end
