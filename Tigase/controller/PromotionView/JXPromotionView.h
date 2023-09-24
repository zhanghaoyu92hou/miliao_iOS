//
//  JXPromotionView.h
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXPromotionView;
NS_ASSUME_NONNULL_BEGIN
@protocol JXPromotionViewDelegate <NSObject>

- (void)JXPromotionView:(JXPromotionView *)promotionView didClickMyInvertNumBtn:(UIButton *)btn;

@end
@interface JXPromotionView : UIView

@property (weak, nonatomic) id<JXPromotionViewDelegate> delegate;

@property (strong ,nonatomic) NSDictionary *dataDic;


NS_ASSUME_NONNULL_END
- (void)sp_didUserInfoFailed;
@end
