//
//  WH_JXSettings_WHViewController.h
//  Tigase_imChatT
//
//  Created by Apple on 16/5/6.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXSettings_WHCell.h"

@interface WH_JXSettings_WHViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    WH_JXSettings_WHViewController* _pSelf;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic) NSDictionary * dataSorce;

@property (strong, nonatomic) NSString * att;
@property (strong, nonatomic) NSString * greet;
@property (strong, nonatomic) NSString * friends;
@property (assign, nonatomic) BOOL isEncrypt;

- (void)sp_upload;
@end
