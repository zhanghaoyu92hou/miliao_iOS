//
//  WH_JXWhoCanSee_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2018/6/27.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_JXWhoCanSee_WHCell;
@protocol WH_JXWhoCanSee_WHCellDelegate <NSObject>

- (void)whoCanSeeCell:(WH_JXWhoCanSee_WHCell *)whoCanSeeCell selectAction:(NSInteger)index;
- (void)whoCanSeeCell:(WH_JXWhoCanSee_WHCell *)whoCanSeeCell editBtnAction:(NSInteger)index;

@end

@interface WH_JXWhoCanSee_WHCell : UITableViewCell
@property (nonatomic, strong) UIButton *contentBtn;
@property (nonatomic, strong) UIImageView *selImageView;
@property (nonatomic, strong) JXLabel *title;
@property (nonatomic, strong) JXLabel *userNames;
@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, weak) id<WH_JXWhoCanSee_WHCellDelegate>delegate;
@property (nonatomic, assign) NSInteger index;

- (void)sp_didUserInfoFailed:(NSString *)string;
@end
