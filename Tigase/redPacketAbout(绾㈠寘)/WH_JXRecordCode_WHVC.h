//
//  WH_JXRecordCode_WHVC.h
//  Tigase_imChatT
//
//  Created by Apple on 16/9/18.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

@interface WH_JXRecordCode_WHVC : WH_JXTableViewController
@property (strong, nonatomic) NSMutableArray * wh_dataArr;//数据源
@property (nonatomic,strong) NSMutableArray * wh_dataObjArray;//消息记录对象数组

@property (nonatomic ,strong) UIView *wh_eView;

- (void)sp_getMediaFailed;
@end
