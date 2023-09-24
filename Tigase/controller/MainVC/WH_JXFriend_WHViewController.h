//
//  WH_JXFriend_WHViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_AddressbookSuper_WHController.h"
#import <UIKit/UIKit.h>
#import "WH_JXTopSiftJobView.h"

@class WH_menuImageView;

@interface WH_JXFriend_WHViewController: WH_AddressbookSuper_WHController{
    NSMutableArray* _array;
    int _refreshCount;
    WH_menuImageView* _tb;
    UIView* _topView;
    int _selMenu;
//    UIButton * _myFriendsBtn;
//    UIButton * _listAttentionBtn;
    UIView *_topScrollLine;
    NSMutableArray * _friendArray;
    WH_JXTopSiftJobView *_topSiftView; //表头筛选控件
    UIView *backView;
}

@property (nonatomic,assign) BOOL isOneInit;
@property (nonatomic,assign) BOOL isMyGoIn; // 是从我界面 进入

- (void) showNewMsgCount:(NSInteger)friendNewMsgNum;


- (void)sp_getUsersMostFollowerSuccess:(NSString *)mediaCount;
@end
