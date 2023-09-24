//
//  WH_JXSearchImageLog_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2019/4/9.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXSearchImageLog_WHCell : UICollectionViewCell

@property (nonatomic, strong) WH_JXMessageObject *msg;



NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostLikedSuccess:(NSString *)mediaInfo;
@end
