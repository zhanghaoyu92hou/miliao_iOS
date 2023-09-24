//
//  WH_JXGroup_WHViewController
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_AddressbookSuper_WHController.h"
#import "WH_JXTopSiftJobView.h"

@protocol XMPPRoomDelegate;
@class WH_JXRoomObject;
@class WH_menuImageView;

@interface WH_JXGroup_WHViewController :WH_AddressbookSuper_WHController<XMPPRoomDelegate>{
    
    int _refreshCount;
    int _recordCount;

    NSString* _roomJid;
    WH_JXRoomObject *_chatRoom;
    UITextField* _inputText;

    WH_menuImageView* _tb;
    UIScrollView * _scrollView;
    int _selMenu;
    WH_JXTopSiftJobView *_topSiftView; //表头筛选控件
//    UIButton * _myRoomBtn;
//    UIButton * _allRoomBtn;
//    UIView *_topScrollLine;
//    int _sel;
}
@property (nonatomic,strong) NSMutableArray * array;
@property (assign,nonatomic) NSIndexPath *selectIndexPath;

//- (void)actionNewRoom;
//- (void)reconnectToRoom;

@end
