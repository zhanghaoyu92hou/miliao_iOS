//
//  WH_JXSetNoteAndLabel_WHVC.h
//  Tigase_imChatT
//
//  Created by 1 on 2019/5/7.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXSetNoteAndLabel_WHVC : WH_admob_WHViewController
@property (nonatomic, strong) WH_JXUserObject *user;

@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;

@property (nonatomic ,strong) UIView *describeView;



NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostLiked:(NSString *)string;
@end
