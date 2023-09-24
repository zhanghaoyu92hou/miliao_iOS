//
//  acceptCallViewController.h
//  Tigase_imChatT
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class WH_AudioPlayerTool;

@interface AskCallViewController : WH_admob_WHViewController{
    BOOL _bAnswer;
    WH_AudioPlayerTool* _player;
}
@property (nonatomic, copy) NSString * toUserId;
@property (nonatomic, copy) NSString * toUserName;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy) NSString *meetUrl;

@end
