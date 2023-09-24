//
//  WH_JXCourseList_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2017/10/20.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WH_JXCourseList_WHVC.h"

typedef int(^WH_JXCourseList_WHCellBlock)(int type);

@interface WH_JXCourseList_WHCell : UITableViewCell

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) WH_JXCourseList_WHVC *vc;
@property (nonatomic, assign) WH_JXCourseList_WHCellBlock block;
@property (nonatomic, assign) BOOL isMultiselect;
@property (nonatomic, assign) NSInteger indexNum;

@property (nonatomic, strong) UIButton *multiselectBtn;

- (void) setData:(NSDictionary *)dict;


- (void)sp_didUserInfoFailed;
@end
