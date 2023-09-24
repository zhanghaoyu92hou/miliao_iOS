//
//  WH_WeiboCell.h
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_HBCoreLabel.h"
#import "WH_HBShowImageControl.h"
#import "WeiboData.h"
#import "WH_WeiboViewControlle.h"
#import <QuickLook/QuickLook.h>
#import "ReplyCell.h"
#import "WH_AudioPlayerTool.h"
#import "WH_JXVideoPlayer.h"
#import "WH_WeiboSearchViewController.h"
#import "WH_JXWeiboDetailViewController.h"

#define REPLY_BACK_COLOR 0xd5d5d5

@class MPMoviePlayerController;
@class userInfoVC;
@class WH_WeiboCell;



@class WH_WeiboViewControlle;

@protocol WH_WeiboCellDelegate <NSObject>

- (void)WH_WeiboCell:(WH_WeiboCell *)WH_WeiboCell shareUrlActionWithUrl:(NSString *)url title:(NSString *)title;

- (void)WH_WeiboCell:(WH_WeiboCell *)WH_WeiboCell clickVideoWithIndex:(NSInteger)index;

@end

@interface WH_WeiboCell : UITableViewCell<WH_HBShowImageControlDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray * _replys;
    
    NSIndexPath * _indexPath;
    
    BOOL linesLimit;
    
    int replyCount;
    
    NSString* _oldInputText;
    
    NSMutableArray* _newGifts;
    
    int _heightPraise;
    
//    userInfoVC* _userVc;
    NSMutableArray* _pool;
}
@property(nonatomic,retain) UILabel *  title;
@property(nonatomic,retain) WH_HBCoreLabel * content;
@property(nonatomic,retain) UIView * wh_imageContent;
@property(nonatomic,strong) UIView * fileView;
@property (strong, nonatomic) UIImageView * typeView;
@property (strong, nonatomic) UILabel * wh_fileTitleLabel;
@property(nonatomic,retain) UILabel * time;
@property(nonatomic,strong) UIButton * delBtn;
@property(nonatomic,strong) UILabel * locLabel;
@property(nonatomic,retain) WH_JXImageView * mLogo;
@property(nonatomic,retain) UIView * wh_replyContent;
@property(nonatomic,retain) UIButton * wh_btnReply;  // 回复
@property(nonatomic,retain) UIButton * wh_btnLike;   // 点赞
@property(nonatomic,retain) UIButton * wh_btnCollection; // 收藏
@property(nonatomic,retain) UIButton * wh_btnReport; // 举报
@property(nonatomic,strong) UIButton * wh_moreMenu; // 查看菜单
@property (nonatomic, assign) BOOL isPraise; // 是否点赞
@property (nonatomic, assign) BOOL isCollect; // 是否收藏
@property(nonatomic,retain) UIImageView * back;
@property(nonatomic,retain) UITableView * wh_tableReply;
@property(nonatomic,retain) UIView * wh_lockView;
@property(nonatomic,retain) UIButton *wh_btnDelete;
@property(nonatomic,retain) UIButton * wh_btnShare;
@property(nonatomic,weak) WH_WeiboViewControlle * controller;
@property(nonatomic,weak) WH_WeiboSearchViewController *viewController;
@property(nonatomic,weak) WH_JXWeiboDetailViewController *detailController;
@property(nonatomic,weak) UITableView* wh_tableViewP;
@property(nonatomic,retain) WeiboData* weibo;
@property(nonatomic,retain) WH_JXImageView* wh_imagePlayer;
@property(nonatomic,retain) UIButton* wh_pauseBtn;
@property(nonatomic,assign) int wh_refreshCount;
@property(nonatomic,strong) WH_AudioPlayerTool* wh_audioPlayer;
@property(nonatomic,retain) WH_JXVideoPlayer* wh_videoPlayer;
@property (nonatomic, weak) id<WH_WeiboCellDelegate>delegate;
@property(nonatomic,retain) UILabel *moreLabel;
@property (nonatomic, weak) UIView *suSeparateLine;

+(float)getHeightByContent:(WeiboData*)data;

+(float) heightForReply:(NSArray*)replys;

-(void)loadReply;

//-(void)doHideMenu;

-(void)setReplys:(NSArray*)replys;
-(NSArray *)getReplys;
//-(void)refresh:(WH_WeiboCell *)selWH_WeiboCell;

-(void)refresh;

- (void)setupData;



- (void)sp_checkNetWorking:(NSString *)mediaCount;
@end
