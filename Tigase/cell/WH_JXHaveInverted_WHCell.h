//
//  WH_JXHaveInverted_WHCell.h
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXHaveInverted_WHCell;

NS_ASSUME_NONNULL_BEGIN
@protocol WH_JXHaveInverted_WHCellDelegate <NSObject>

- (void)WH_JXHaveInverted_WHCell:(WH_JXHaveInverted_WHCell *)cell didClickAddFriendBtnAction:(UIButton *)btn AndIndexPath:(NSIndexPath *)indexPath;

@end

@interface WH_JXHaveInverted_WHCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property(nonatomic,strong) NSDictionary *dataDic;

@property(nonatomic,weak) id <WH_JXHaveInverted_WHCellDelegate> delegate;

@property(nonatomic,strong) NSMutableArray *friendIdArr;//存放我当前的所有好友的ID

@property(nonatomic,strong) NSIndexPath *indexPath;


NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostLiked;
@end
