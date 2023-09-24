//
//  WH_FindViewController.h
//  Tigase
//
//  Created by Apple on 2019/6/26.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_admob_WHViewController.h"

#import "WH_JXActionSheet_WHVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WH_FindViewController : WH_admob_WHViewController<WH_JXActionSheet_WHVCDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *wh_tableView;
@property (nonatomic, strong) UILabel *wh_weiboNewMsgNum;

@property (nonatomic ,strong) NSArray *wh_nameArray;
@property (nonatomic ,strong) NSArray *wh_imagesArray;

@property (nonatomic ,strong) NSMutableArray *wh_dataArray;

@property (nonatomic, strong) NSMutableArray *wh_remindArray;

@property (nonatomic, assign) BOOL wh_isAudioMeeting;

@property (nonatomic ,strong) UILabel *wh_numMarkLabel;

@property (nonatomic ,strong) NSMutableArray *wh_cMenuArray;

// 新消息红点提示
- (void)showNewMsgNoti;



NS_ASSUME_NONNULL_END
- (void)sp_getUsersMostLikedSuccess;
@end
