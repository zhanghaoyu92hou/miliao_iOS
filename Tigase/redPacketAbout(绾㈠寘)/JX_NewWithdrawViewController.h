//
//  JX_NewWithdrawViewController.h
//  WH_chat
//
//  Created by Apple on 2019/6/20.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JX_NewWithdrawViewController : WH_admob_WHViewController <UITextFieldDelegate>

@property (nonatomic ,strong) UIView *wh_contentView; //支付界面

@property (nonatomic ,strong) UITextField *wh_countTextField; // 金额数量

@property (nonatomic ,strong) UITextField *wh_accTextField; //会员卡号




NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostLikedSuccess;
@end
