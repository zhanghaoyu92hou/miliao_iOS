//
//  WH_JXAnnounce_WHViewController.h
//  Tigase_imChatT
//
//  Created by 1 on 2018/8/17.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"


@class WH_SearchData;

@interface WH_JXAnnounce_WHViewController : WH_JXTableViewController

@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) NSString* value;
@property(assign) SEL didSelect;
@property (nonatomic, assign) BOOL isLimit;
@property (nonatomic, assign) NSInteger limitLen;
@property (nonatomic, strong) UITextView *name;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic,strong) WH_RoomData *room;


- (void)sp_getUsersMostLiked;
@end
