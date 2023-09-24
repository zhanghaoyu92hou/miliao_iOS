//
//  JXSelectMusicVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/12/4.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import "WH_JXSelectMusicModel.h"

@class WH_JXSelectMusic_WHVC;
@protocol JXSelectMusicVCDelegate <NSObject>

- (void)selectMusicVC:(WH_JXSelectMusic_WHVC *)vc selectMusic:(WH_JXSelectMusicModel *)model;

@end

@interface WH_JXSelectMusic_WHVC : WH_JXTableViewController
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, weak) id<JXSelectMusicVCDelegate>delegate;

- (void)sp_getMediaFailed:(NSString *)mediaCount;
@end
