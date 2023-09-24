//
//  WH_JXSettings_WHCell.h
//  Tigase_imChatT
//
//  Created by Apple on 16/5/6.
//  Copyright © 2016年 Reese. All rights reserved.
//  好友验证设置

#import <UIKit/UIKit.h>
@class WH_JXSettings_WHViewController;

@interface WH_JXSettings_WHCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
//@property (strong, nonatomic) IBOutlet UISwitch *mySwitch;
@property (strong, nonatomic) UISwitch *mySwitch;

@property (strong,nonatomic) WH_JXSettings_WHViewController * inTableView;

@property (strong,nonatomic) NSString * att;
@property (strong,nonatomic) NSString * greet;
@property (strong,nonatomic) NSString * friends;


@property (nonatomic,assign) void (^block)(BOOL,int);

- (void)sp_getUsersMostFollowerSuccess;
@end
