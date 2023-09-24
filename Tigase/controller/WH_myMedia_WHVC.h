//
//  WH_myMedia_WHVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>
@class WH_menuImageView;
@class WH_JXMedia_WHCell;

@interface WH_myMedia_WHVC: WH_JXTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
    WH_JXMedia_WHCell* _cell;
}
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
- (void) onAddVideo;


- (void)sp_getMediaData;
@end
