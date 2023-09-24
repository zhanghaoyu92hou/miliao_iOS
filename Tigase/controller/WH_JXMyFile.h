//
//  WH_JXMyFile.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>
@class WH_menuImageView;
@class WH_JXRoomObject;

@interface WH_JXMyFile: WH_JXTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
    WH_menuImageView* _tb;
    UIView* _topView;
    int _selMenu;
    
}
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didSelect;


- (void)sp_didUserInfoFailed;
@end
