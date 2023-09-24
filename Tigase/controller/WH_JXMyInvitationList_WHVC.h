//
//  WH_JXMyInvitationList_WHVC.h
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXMyInvitationList_WHVC : WH_JXTableViewController

@property (strong, nonatomic) NSMutableArray * dataArr;//数据源


NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostLikedSuccess;
@end
