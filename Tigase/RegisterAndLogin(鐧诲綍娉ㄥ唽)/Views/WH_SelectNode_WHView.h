//
//  WH_SelectNode_WHView.h
//  Tigase
//
//  Created by Apple on 2019/7/16.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_SelectNode_WHView : UIView <UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic ,strong) UITableView *wh_listTable;
@property (nonatomic ,strong) void(^wh_SelectNodeBlock)(NSDictionary *data);
NS_ASSUME_NONNULL_END
- (void)sp_getMediaData;
@end
