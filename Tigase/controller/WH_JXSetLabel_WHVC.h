//
//  WH_JXSetLabel_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2018/6/26.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"

@interface WH_JXSetLabel_WHVC : WH_admob_WHViewController
@property (nonatomic, strong) WH_JXUserObject *user;

@property (nonatomic, strong) NSMutableArray *array;    // 已选择标签
@property (nonatomic, strong) NSMutableArray *allArray; // 所有标签

@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;


- (void)sp_getLoginState:(NSString *)mediaInfo;
@end
