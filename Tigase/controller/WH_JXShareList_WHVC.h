//
//  JXShareSelectView.h
//  Tigase_imChatT
//
//  Created by MacZ on 15/8/26.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"
#import <UIKit/UIKit.h>

#import "WH_JXShareModel.h"

@protocol ShareListDelegate <NSObject>

- (void)didShareBtnClick:(UIButton *)shareBtn;

@end

@interface WH_JXShareList_WHVC : UIViewController{
    UIView *_listView;
    
    WH_JXShareList_WHVC *_pSelf;
}

@property (nonatomic,weak) id<ShareListDelegate> shareListDelegate;

- (void)showShareView;


- (void)sp_getLoginState;
@end
