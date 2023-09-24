//
//  WH_AddressbookSuper_WHController.h
//  Tigase
//
//  Created by Apple on 2019/7/3.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_AddressbookSuper_WHController : WH_JXTableViewController

@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) UIView *coverView;

- (void)createSeekTextField:(UIView *)superView isFriend:(BOOL)isFriend;

- (void)textFieldDidChange:(UITextField *)textField;



NS_ASSUME_NONNULL_END
- (void)sp_checkUserInfo;
@end
