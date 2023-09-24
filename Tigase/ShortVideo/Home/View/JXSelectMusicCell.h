//
//  JXSelectMusicCell.h
//  Tigase_imChatT
//
//  Created by p on 2018/12/5.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXSelectMusicModel.h"

@class JXSelectMusicCell;
@protocol JXSelectMusicCellDelegate <NSObject>

- (void)selectMusicCell:(JXSelectMusicCell *)cell WH_select_WHBtnAction:(WH_JXSelectMusicModel *)model;

@end

@interface JXSelectMusicCell : UITableViewCell

@property (nonatomic, strong) WH_JXSelectMusicModel *wh_model;
@property (nonatomic, strong) UIButton *wh_playBtn;
@property (nonatomic, strong) UIButton *wh_selectBtn;
@property (nonatomic, strong) NSIndexPath *wh_indexPath;
@property (nonatomic, strong) WH_AudioPlayerTool* wh_audioPlayer;
@property (nonatomic, weak) id<JXSelectMusicCellDelegate> delegate;

- (void)playBtnAction:(UIButton *)btn;


- (void)sp_getUsersMostLiked;
@end
