//
//  WH_JX_WHCell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBadgeView.h"

@interface WH_JX_WHCell : UITableViewCell{
    
}
@property (nonatomic,retain,setter=setTitle:) NSString*  title;
@property (nonatomic,strong) NSString*  subtitle;
@property (nonatomic,strong) NSString*  bottomTitle;
@property (nonatomic,strong) NSString*  headImage;
@property (nonatomic,strong) NSString*  bage;
@property (nonatomic,strong) NSString*  roomId;
@property (nonatomic,strong) NSString*  userId;
@property (strong, nonatomic) NSString * positionTitle;
@property (nonatomic,strong) WH_JXImageView * headImageView;

@property (nonatomic) int index;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) SEL       didDragout;
@property (nonatomic, assign) SEL       didReplay;


@property (nonatomic,strong) JXLabel*   lbTitle;
@property (nonatomic,strong) JXLabel*   lbBottomTitle;
@property (nonatomic,strong) JXLabel*   lbSubTitle;
@property (nonatomic,strong) JXLabel*   timeLabel;
@property (strong, nonatomic) UILabel * positionLabel;
@property (nonatomic, strong) WH_JXBadgeView* bageNumber;

@property (nonatomic,strong) WH_JXImageView * notPushImageView;
@property (nonatomic,strong) WH_JXImageView * replayView;
@property (nonatomic, strong) UIImageView *replayImgV;

@property (nonatomic, strong) id dataObj;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, assign) BOOL isSmall;
@property (nonatomic, assign) BOOL isNotPush;
@property (nonatomic, assign) BOOL isMsgVCCome;

@property (nonatomic ,strong) NSString *searchContent; //想要查询的内容

@property (nonatomic, strong) WH_JXUserObject *user;
//存cell的badge用的dict
//@property (nonatomic,strong) NSMutableDictionary * bageDict;
//
//- (void) saveBadge:(NSString*)badge withTitle:(NSString*)titl;
- (void)setSuLabel:(NSString *)s;
-(void)setForTimeLabel:(NSString *)s;
//- (void)getHeadImage;


//-(void)msgCellDataSet:(WH_JXMsgAndUserObject *) msgObject indexPath:(NSIndexPath *)indexPath;
//-(void)groupCellDataSet:(NSDictionary *)dataDict indexPath:(NSIndexPath *)indexPath;
-(void)WH_headImageViewImageWithUserId:(NSString *)userId roomId:(NSString *)roomIdStr;

/**
 设置分割线显示或者隐藏
 
 @param indexPath 当前cell所在索引
 */
- (void)setLineDisplayOrHidden:(NSIndexPath *)indexPath;


- (void)sp_getUsersMostLiked;
@end
