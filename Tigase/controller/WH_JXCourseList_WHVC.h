//
//  WH_JXCourseList_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2017/10/20.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXTableViewController.h"

@interface WH_JXCourseList_WHVC : WH_JXTableViewController

@property (nonatomic, assign) int selNum;

- (NSInteger)getSelNum:(NSInteger)num indexNum:(NSInteger)indexNum;


- (void)sp_getMediaFailed;
@end
