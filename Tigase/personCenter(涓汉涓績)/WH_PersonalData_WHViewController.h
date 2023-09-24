//
//  WH_PersonalData_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/7/4.
//  Copyright © 2019 Reese. All rights reserved.
// 个人资料

#import "WH_admob_WHViewController.h"

#import "WH_JXSetShikuNum_WHVC.h"

#import "WH_JXCamera_WHVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_PersonalData_WHViewController : WH_admob_WHViewController<UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate ,WH_JXSetShikuNum_WHVCDelegate ,WH_JXCamera_WHVCDelegate ,UIImagePickerControllerDelegate>

@property (nonatomic ,strong) UITableView *wh_cTableView;
@property (nonatomic ,strong) NSArray *array;

@property (nonatomic,strong) WH_JXUserObject* user;
@property (nonatomic,assign) BOOL isRegister;
@property (nonatomic, strong) UIImage *wh_headImage;

@property (nonatomic ,strong) UIImage* image;

@property (nonatomic ,strong) WH_JXImageView *head;
@property (nonatomic ,strong) UISegmentedControl *wh_sex;
@property (nonatomic ,strong) UITextField *wh_name;
@property (nonatomic ,strong)  UITextField *wh_birthday;
@property (nonatomic ,strong) WH_JXDatePicker* wh_date;

@property (nonatomic ,strong) UILabel *wh_city;

@property (nonatomic ,assign) Boolean isRefresh; //是否刷新

NS_ASSUME_NONNULL_END
- (void)sp_didUserInfoFailed;


@end
