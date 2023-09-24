//
//  WH_ReadDelTimeCell.h
//  Tigase
//
//  Created by Apple on 2019/8/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXMessageObject.h"


@interface WH_ReadDelTimeCell : UITableViewCell
@property (nonatomic, strong) UILabel *bottomTitleLb;//显示多久后消息消失
@property (nonatomic, strong) UIImageView *clockImageV;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic ,strong) void(^clickSettingBtnClick)();

@property (nonatomic,strong) WH_JXMessageObject * msg;

@end


