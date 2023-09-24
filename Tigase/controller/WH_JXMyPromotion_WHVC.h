//
//  WH_JXMyPromotion_WHVC.h
//  Tigase_imChatT
//
//  Created by 闫振奎 on 2019/6/6.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_JXMyPromotion_WHVC : WH_JXTableViewController
@property (strong, nonatomic) NSMutableArray * dataArr;//数据源
@property (strong, nonatomic) NSDictionary * dataDic;//数据源


NS_ASSUME_NONNULL_END
- (void)sp_checkNetWorking:(NSString *)mediaInfo;
@end
