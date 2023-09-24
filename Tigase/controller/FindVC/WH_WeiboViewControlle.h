//
//  WeiboViewControlle.h
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//  朋友圈

#import <UIKit/UIKit.h>
#import "PageLoadFootView.h"
#import "WeiboData.h"
#import "WH_HBCoreLabel.h"
//#import "WH_admob_WHViewController.h"
#import "WH_JXTableViewController.h"
#import "WH_JX_SelectMenuView.h"

@class JXServer;
@class WeiboReplyData;
@class JXTextView;
@class WH_WeiboCell;
@class userInfoVC;
@class WH_JXMenuView;

#define WeiboUpdateNotification  @"WeiboUpdateNotification"

@class WH_WeiboViewControlle;
@protocol weiboVCDelegate <NSObject>

- (void) weiboVC:(WH_WeiboViewControlle *)weiboVC didSelectWithData:(WeiboData *)data;

@end

@interface WH_WeiboViewControlle : WH_JXTableViewController<WH_HBCoreLabelDelegate,UITextFieldDelegate>
{
    JXTextView* _input;
    
    UIView* _inputParent;
    
    void(^_block)(NSString*string);
    
//    WeiboData * _deleteWeibo;
    
    NSIndexPath *_deletePath;
    
    BOOL  animationEnd;
    
    NSMutableArray* _pool;
    
    UIView * _bgBlackAlpha;
    WH_JX_SelectMenuView * _selectView;
}

@property(nonatomic,strong) WH_JXUserObject* user;
@property(nonatomic,strong)NSMutableArray* datas;
@property(nonatomic,strong)WeiboData * wh_selectWeiboData;
@property(nonatomic,strong)WH_WeiboCell* wh_selectWH_WeiboCell;
//@property(nonatomic,strong)WeiboReplyData * replyData;
@property(nonatomic,strong)WeiboReplyData * wh_replyDataTemp;
@property(nonatomic,strong)WeiboData * wh_deleteWeibo;
@property(nonatomic,assign) int refreshCount;
@property(nonatomic,assign) NSInteger wh_refreshCellIndex;
@property(nonatomic,assign) int deleteReply;

@property (nonatomic, assign) BOOL isDetail;
@property (nonatomic, copy) NSString *wh_detailMsgId;
@property (nonatomic, assign) BOOL isNotShowRemind;
@property (nonatomic, assign) BOOL isCollection;
@property (nonatomic, weak) id<weiboVCDelegate>delegate;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) NSInteger wh_videoIndex;


@property(nonatomic,retain) WH_JXVideoPlayer* wh_videoPlayer;

@property(nonatomic,strong) WH_JXMenuView *wh_menuView;

//输入后面的透明view
@property (nonatomic,retain) UIView * clearBackGround;
-(void)WH_doShowAddMyCustomComment:(NSString*)s;
-(NSString*)getLastMessageId:(NSArray*)objects;

-(void)delBtnAction:(WeiboData *)cellData;
-(void)btnReplyAction:(UIButton *)sender WithCell:(WH_WeiboCell *)cell;
-(void)fileAction:(WeiboData *)cellData;
-(void)setupTableViewHeight:(CGFloat)height tag:(NSInteger)tag;
//收藏
-(instancetype)initCollection;




@end
