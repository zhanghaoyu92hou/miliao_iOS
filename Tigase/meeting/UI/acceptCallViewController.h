//
//  acceptCallViewController.h
//  Tigase_imChatT
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class WH_AudioPlayerTool;

@interface acceptCallViewController : WH_admob_WHViewController{
    UIButton* _buttonHangup;
    UIButton* _buttonAccept;
    WH_AudioPlayerTool* _player;
}
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, copy) NSString * toUserId;
@property (nonatomic, copy) NSString * toUserName;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString * roomNum;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;

@end
