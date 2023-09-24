//
//  WH_Collect_WHTableViewCell.h
//  Tigase
//
//  Created by Apple on 2019/7/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WH_HBShowImageControl.h"
#import "WH_Collect_WHViewController.h"

#import "WH_HBCoreLabel.h"

//#import "WH_Collect_WHTableViewCell.h"
@class WH_Collect_WHTableViewCell ;
@class WH_Collect_WHViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol WH_Collect_WHTableViewCellDelegate <NSObject>

//- (void)WH_WeiboCell:(WH_Collect_WHTableViewCell *)WH_WeiboCell shareUrlActionWithUrl:(NSString *)url title:(NSString *)title;


- (void)WH_WeiboCell:(WH_Collect_WHTableViewCell *)WH_WeiboCell clickVideoWithIndex:(NSInteger)index;

- (void)collectDelect:(WeiboData *)data;

- (void)fileAction:(WeiboData *)data;

@end

@interface WH_Collect_WHTableViewCell : UITableViewCell<WH_HBShowImageControlDelegate>

@property (nonatomic ,retain) WeiboData * wh_weibo;
@property (nonatomic ,strong) WH_HBCoreLabel *wh_hcLabel; //收藏的文本的内容
@property (nonatomic ,strong) UIView *wh_imageContent; //图片内容
@property(nonatomic,strong) WH_AudioPlayerTool* wh_audioPlayer;
@property(nonatomic,retain) WH_JXVideoPlayer* wh_videoPlayer;
@property(nonatomic,retain) WH_JXImageView* wh_imagePlayer;

@property (nonatomic ,strong) UILabel *wh_nameAndTimeLabel; //收藏时间及收藏名称
@property (nonatomic ,strong) UIButton *wh_delBtn;
@property (nonatomic ,strong) UILabel *wh_title;

@property (nonatomic ,assign)  BOOL linesLimit;

@property(nonatomic,strong) UIView * wh_fileView;
@property (strong, nonatomic) UILabel * wh_fileTitleLabel;
@property (strong, nonatomic) UIImageView * wh_typeView;

@property (nonatomic, weak) id<WH_Collect_WHTableViewCellDelegate>delegate;

@property (nonatomic ,strong) WH_Collect_WHViewController *wh_controller;



NS_ASSUME_NONNULL_END
@end
