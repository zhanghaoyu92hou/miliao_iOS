//
//  MiXin_WithdrawInfo_MiXinCell.h
//  mixin_chat
//
//  Created by 闫振奎 on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MiXin_WithdrawInfo_MiXinCell : UITableViewCell


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *copiedBtn;
@property (nonatomic, copy) NSString *copiedStr;

@property (nonatomic, assign) BOOL isShowCopy;
@end

NS_ASSUME_NONNULL_END
