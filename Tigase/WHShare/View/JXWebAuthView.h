//
//  JXWebAuthView.h
//  Tigase_imChatT
//
//  Created by p on 2019/3/4.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JXWebAuthViewDelegate <NSObject>

- (void)webAuthViewWH_confirmBtnAction;

@end

@interface JXWebAuthView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *tipTitle;
@property (nonatomic, assign) id<JXWebAuthViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
