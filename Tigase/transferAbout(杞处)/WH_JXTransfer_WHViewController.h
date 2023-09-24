//
//  WH_JXTransfer_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/3/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@protocol transferVCDelegate <NSObject>

-(void)transferToUser:(NSDictionary *)redpacketDict;

@end

@interface WH_JXTransfer_WHViewController : WH_admob_WHViewController

@property (nonatomic, strong) WH_JXUserObject *wh_user;

@property (weak, nonatomic) id <transferVCDelegate> delegate;


@end

