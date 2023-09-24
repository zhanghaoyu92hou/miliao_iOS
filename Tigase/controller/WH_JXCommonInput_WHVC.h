//
//  WH_JXCommonInput_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2019/4/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class WH_JXCommonInput_WHVC;

@protocol WH_JXCommonInput_WHVCDelegate <NSObject>

- (void)commonInputVCBtnActionWithVC:(WH_JXCommonInput_WHVC *)commonInputVC;

@end

@interface WH_JXCommonInput_WHVC : WH_admob_WHViewController

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic,copy) NSString *subTitle;
@property (nonatomic,copy) NSString *tip;
@property (nonatomic,copy) NSString *btnTitle;
@property (nonatomic, strong) UITextField *name;
@property (nonatomic, weak) id<WH_JXCommonInput_WHVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
