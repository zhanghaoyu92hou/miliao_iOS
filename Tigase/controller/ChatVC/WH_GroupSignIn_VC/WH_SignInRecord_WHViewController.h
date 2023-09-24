//
//  WH_SignInRecord_WHViewController.h
//  Tigase
//
//  Created by Apple on 2019/9/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_SignInRecord_WHViewController : WH_admob_WHViewController<UITableViewDataSource ,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic ,strong) NSString *roomId;

@property (nonatomic ,strong) UITableView *listTable;

@property (nonatomic, strong) UITextField *seekTextField;

@property (nonatomic, strong) NSMutableArray *checkBoxArr;
@property (nonatomic ,strong) NSMutableArray *searchArray;
@property (nonatomic ,strong) NSMutableArray *listArray;

@property (nonatomic ,strong) NSMutableArray *indexArray;//标签
@property (nonatomic ,strong) NSMutableArray *letterResultArr;//排序后内容

@property (nonatomic ,strong) NSMutableArray *selectDataArray; //选中数据

@property (nonatomic,strong) NSSet * existSet;
@property (nonatomic,strong) NSSet * disableSet;
@property (nonatomic ,strong) UIView *coverView;

@end

NS_ASSUME_NONNULL_END
