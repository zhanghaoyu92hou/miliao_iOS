//
//  WH_JXRelay_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/6/27.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXTableViewController.h"

@class WH_JXRelay_WHVC;
@protocol WH_JXRelay_WHVCDelegate <NSObject>

- (void)relay:(WH_JXRelay_WHVC *)relayVC MsgAndUserObject:(WH_JXMsgAndUserObject *)obj;

@end

@interface WH_JXRelay_WHVC : WH_JXTableViewController

//@property (nonatomic, strong) WH_JXMessageObject *msg;
@property (nonatomic, strong) NSMutableArray *relayMsgArray;

@property (nonatomic, assign) BOOL isCourse;
@property (nonatomic, weak) id<WH_JXRelay_WHVCDelegate> relayDelegate;

@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, assign) BOOL isSDKShare;
@property (nonatomic, strong) NSURL *shareUrl;
@property (nonatomic, copy) NSString *shareSchemes;
@property (nonatomic, assign) BOOL isUrl;



- (void)sp_getLoginState:(NSString *)mediaInfo;
@end
