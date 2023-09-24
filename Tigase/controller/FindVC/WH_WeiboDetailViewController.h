//
//  WH_WeiboDetailViewController.h
//  Tigase
//
//  Created by 政委 on 2020/6/5.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeiboData;
NS_ASSUME_NONNULL_BEGIN

@interface WH_WeiboDetailViewController : UIViewController<JXTableViewDelegate, UITableViewDataSource, UITableViewDelegate> {
JXTableView* _table;
}
@property(nonatomic,retain) WeiboData* weibo;

@end

NS_ASSUME_NONNULL_END
