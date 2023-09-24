//
//  WH_JXSearchImageLog_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2019/4/9.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXSearchImageLog_WHVC : WH_admob_WHViewController

@property (nonatomic, assign) BOOL isImage;
@property (nonatomic, strong) WH_JXUserObject *user;



NS_ASSUME_NONNULL_END
- (void)sp_checkUserInfo:(NSString *)followCount;
@end
