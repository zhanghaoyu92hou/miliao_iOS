//
//  WH_JXFile_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/4.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"


typedef NS_OPTIONS(NSInteger, JSFileVCType) {
   JSFileVCTypeGroup    = 1 << 0,
};


@interface WH_JXFile_WHViewController : WH_JXTableViewController
@property (nonatomic,strong) WH_RoomData * room;


- (void)sp_upload;
@end
