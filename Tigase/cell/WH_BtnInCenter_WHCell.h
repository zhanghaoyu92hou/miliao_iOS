//
//  WH_BtnInCenter_WHCell.h
//  Tigase
//
//  Created by 闫振奎 on 2019/7/30.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_BtnInCenter_WHCell : UITableViewCell

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, copy) void (^onClickButton)(WH_BtnInCenter_WHCell *cell,UIButton *button);



NS_ASSUME_NONNULL_END
- (void)sp_checkNetWorking:(NSString *)mediaCount;
@end
