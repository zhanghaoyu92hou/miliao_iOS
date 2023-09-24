//
//  WH_GroupSignIn_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/9/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_GroupSignIn_WHViewController : WH_admob_WHViewController<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UIImageView *headImgView;

@property (nonatomic ,strong) UILabel *signInNum; //签到天数

@property (nonatomic ,strong) UILabel *signInReminder ; //签到提示
@property (nonatomic ,strong) UIButton *signInButton ; //签到按钮

@property (nonatomic ,strong) UITableView *listTable;
@property (nonatomic ,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) WH_RoomData * room;

@property (nonatomic ,strong) UIView *hadSignInView ;

@property (nonatomic ,strong) UIView *topContentView;

@end

NS_ASSUME_NONNULL_END
