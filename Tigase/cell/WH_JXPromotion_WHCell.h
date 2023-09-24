//
//  WH_JXPromotion_WHCell.h
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WH_JXPromotion_WHCell;
NS_ASSUME_NONNULL_BEGIN
@protocol WH_JXPromotion_WHCellDelegate <NSObject>

- (void)WH_JXPromotion_WHCell:(WH_JXPromotion_WHCell *)cell didSelCopyBtnActionWithCopyBtn:(UIButton *)copyBtn AndIndexPath:(NSIndexPath *)indexPath;

@end

@interface WH_JXPromotion_WHCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *dataDic;

@property(nonatomic,weak) id <WH_JXPromotion_WHCellDelegate> delegate;

@property(nonatomic,strong) NSIndexPath *indexPath;



NS_ASSUME_NONNULL_END
- (void)sp_checkNetWorking:(NSString *)isLogin;
@end
