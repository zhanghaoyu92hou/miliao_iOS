//
//  WH_JXProgress_WHVC.h
//  Tigase_imChatT
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_JXProgress_WHVC : WH_admob_WHViewController
@property (nonatomic,strong) UIProgressView * progressView;//进度条
@property (nonatomic,strong) UILabel * progressLabel;//进度
@property (nonatomic,strong) NSArray * dataArray;//数据
@property (nonatomic,assign) long dbFriends;
@property (nonatomic,strong) UILabel * dbCountLabel;
@property (nonatomic,strong) UILabel * sysCountLabel;
@property (nonatomic,strong) UIButton * comBtn;

- (void)sp_didUserInfoFailed;
@end
