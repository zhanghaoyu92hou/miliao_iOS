//
//  WH_JX_WH2Cell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXBadgeView.h"

@interface WH_JX_WH2Cell : UITableViewCell{
    
}
@property (nonatomic,retain,setter=setTitle:) NSString*  title;
@property (nonatomic,strong) NSString*  subtitle;
@property (nonatomic,strong) NSString*  bottomTitle;
@property (nonatomic,strong) NSString*  headImage;
@property (nonatomic,strong) NSString*  bage;
@property (nonatomic,strong) NSString*  roomId;
@property (nonatomic,strong) NSString*  userId;
@property (strong, nonatomic) NSString * positionTitle;
@property (nonatomic,strong) UIView * bgView;
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
@property (nonatomic,strong) WH_JXImageView * stickView;
@property (nonatomic, strong) UIImageView *stickImgV;

@property (nonatomic, strong) id dataObj;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) BOOL isSmall;
@property (nonatomic, assign) BOOL isNotPush;
@property (nonatomic, assign) BOOL isMsgVCCome;
/** 是否置顶,1置顶,0取消置顶 */
@property (nonatomic, assign) BOOL isStick;

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


@end
