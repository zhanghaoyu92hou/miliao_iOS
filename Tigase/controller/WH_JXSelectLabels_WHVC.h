//
//  WH_JXSelectLabels_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/7/19.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"

@class WH_JXSelectLabels_WHVC;
@protocol WH_JXSelectLabels_WHVCDelegate <NSObject>

- (void)selectLabelsVC:(WH_JXSelectLabels_WHVC *)selectLabelsVC selectLabelsArray:(NSMutableArray *)array;

@end

@interface WH_JXSelectLabels_WHVC : WH_JXTableViewController

@property (nonatomic, strong) NSMutableArray *selLabels;

@property (nonatomic, weak) id<WH_JXSelectLabels_WHVCDelegate>delegate;


- (void)sp_getMediaData:(NSString *)followCount;
@end
