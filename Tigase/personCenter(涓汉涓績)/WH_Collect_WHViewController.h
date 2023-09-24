//
//  WH_Collect_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/7/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

#import "WH_HBCoreLabel.h"
#import "WH_HBShowImageControl.h"
//#import "WH_Collect_WHTableViewCell.h"
@class WH_Collect_WHTableViewCell;
@class WH_Collect_WHViewController;

@protocol collectVCDelegate <NSObject>
- (void) collectVC:(WH_Collect_WHViewController *)weiboVC didSelectWithData:(WeiboData *)data;
@end

NS_ASSUME_NONNULL_BEGIN

@interface WH_Collect_WHViewController : WH_admob_WHViewController <UITableViewDelegate ,UITableViewDataSource ,WH_HBShowImageControlDelegate >

@property (nonatomic ,strong) UITableView *wh_listTable;
@property (nonatomic ,strong) NSMutableArray *wh_listArray;

@property (nonatomic ,assign) NSInteger page;

@property (nonatomic, assign) BOOL isSend;

@property (nonatomic ,strong) WeiboData *wh_weibo;
@property (nonatomic ,strong) WH_HBCoreLabel *wh_hcLabel; //收藏的文本的内容
@property (nonatomic ,strong) UIView *wh_imageContent; //图片内容
@property(nonatomic,strong) WH_AudioPlayerTool* wh_audioPlayer;
@property(nonatomic,retain) WH_JXVideoPlayer* wh_videoPlayer;

@property (nonatomic, assign) NSInteger wh_videoIndex;

@property(nonatomic,strong) WeiboData * wh_selectWeiboData;
@property(nonatomic,strong) WH_Collect_WHTableViewCell *wh_selectWH_CollectCell;

@property (nonatomic ,weak) id<collectVCDelegate> delegate;
@property (nonatomic, strong) WeiboData *wh_currentData;


-(void)delBtnAction:(WeiboData*)cellData ;
-(void)fileAction:(WeiboData *)cellData;



NS_ASSUME_NONNULL_END
- (void)sp_checkNetWorking;


@end
