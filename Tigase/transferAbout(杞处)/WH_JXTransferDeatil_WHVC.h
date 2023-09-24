//
//  WH_JXTransferDeatil_WHVC.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/2.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"



@interface WH_JXTransferDeatil_WHVC : WH_admob_WHViewController

@property (nonatomic, strong) WH_JXUserObject *wh_user;
@property (nonatomic, strong) WH_JXMessageObject *wh_msg;

@property (assign) SEL onResend; // 重发消息
@property (weak, nonatomic) id delegate;


@end

