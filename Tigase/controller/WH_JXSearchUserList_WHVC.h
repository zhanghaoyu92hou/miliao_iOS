//
//  WH_JXSearchUserList_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/4/18.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_JXSearchUserList_WHVC : WH_admob_WHViewController

@property (nonatomic,strong)WH_SearchData *search;
@property (nonatomic, assign) BOOL isUserSearch;  // 是否搜索好友  YES：好友搜索  NO：公众号搜索
@property (nonatomic, strong) NSString *keyWorld;  // 搜索关键字


- (void)sp_checkNetWorking;
@end
