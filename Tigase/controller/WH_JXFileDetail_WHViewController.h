//
//  WH_JXFileDetail_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 17/7/7.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class WH_JXShareFileObject;

@interface WH_JXFileDetail_WHViewController : WH_admob_WHViewController

@property (nonatomic,strong) WH_JXShareFileObject * shareFile;

@property (nonatomic ,copy) NSString *shareFieldUrl; //编码后的文件地址



@end
