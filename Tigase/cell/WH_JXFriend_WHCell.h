//
//  WH_JXFriend_WHCell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXFriendObject;
@class WH_JXFriend_WHCell;

@protocol WH_JXFriend_WHCellDelegate <NSObject>

- (void) friendCell:(WH_JXFriend_WHCell *)friendCell headImageAction:(NSString *)userId;

@end

@interface WH_JXFriend_WHCell : UITableViewCell{
    UIImageView* bageImage;
    UILabel* bageNumber;
    UIButton* _btn2;
    UIButton* _btn1;
    UILabel* _lbSubtitle;
    
    UILabel *_statusLbl;
}
@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) NSString*  title;
@property (nonatomic,strong) NSString*  subtitle;
@property (nonatomic,strong) NSString*  rightTitle;
@property (nonatomic,strong) NSString*  bottomTitle;
@property (nonatomic,strong) NSString*  headImage;
@property (nonatomic,strong) NSString*  bage;
@property (nonatomic,strong) WH_JXFriendObject* user;
@property (nonatomic,strong) id target;
@property (nonatomic, weak) id<WH_JXFriend_WHCellDelegate>delegate;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, copy) NSString *status;

-(void)update;


- (void)sp_getUsersMostFollowerSuccess:(NSString *)mediaInfo;
@end
