//
//  WH_JXAddressBook_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/8/30.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"

@interface WH_JXAddressBook_WHVC : WH_JXTableViewController

@property(nonatomic,strong)NSMutableArray *array;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong)NSMutableArray *abUreadArr;


- (void)sp_getUserName:(NSString *)mediaInfo;
@end
