//
//  WH_JXLive_WHViewController
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMPPRoomDelegate;
@class WH_JXRoomObject;
@class WH_menuImageView;
@class WH_JXInputValue_WHVC;

@interface WH_JXLive_WHViewController : WH_admob_WHViewController<XMPPRoomDelegate>{
    
    long _refreshCount;
    long _recordCount;
    
    NSString* _roomJid;
    WH_JXRoomObject *_chatRoom;
//    UITextField* _inputText;
    
//    WH_menuImageView* _tb;
//    UIScrollView * _scrollView;
    int _selMenu;
//    UISegmentedControl * _segment;
    long _sel;
    
    WH_JXInputValue_WHVC* _vc;
}
@property (nonatomic,strong) NSMutableArray * wh_allArray;
@property (nonatomic,strong) NSMutableArray * wh_livingArray;

@property (assign,nonatomic) long sel;

@end
