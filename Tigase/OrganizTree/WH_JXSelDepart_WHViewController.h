//
//  WH_JXSelDepart_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/6/1.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class WH_DepartObject;

@protocol SelDepartDelegate <NSObject>

-(void)selNewDepartmentWith:(WH_DepartObject *)newDepart;

@end

@interface WH_JXSelDepart_WHViewController : WH_admob_WHViewController

//@property (nonatomic,copy) NSString * oldDepartId;
@property (nonatomic, strong) WH_DepartObject * wh_oldDepart;
@property (nonatomic, strong) NSArray * wh_dataArray;
@property (nonatomic, weak) id delegate;

@end
