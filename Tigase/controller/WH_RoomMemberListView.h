//
//  WH_RoomMemberListView.h
//  test_oC
//
//  Created by 史小峰 on 2019/7/23.
//  Copyright © 2019 SXF. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WH_RoomMemberListView : UIView
@property (nonatomic ,strong) UIView *searchView;
@property (nonatomic ,strong) WH_RoomData *room;
@property (nonatomic ,copy) NSArray <memberData *>*dataSourceArr;
@property (nonatomic ,strong) void(^selectedIndex)(NSIndexPath *indexP, memberData *member);


NS_ASSUME_NONNULL_END
- (void)sp_getUserFollowSuccess:(NSString *)isLogin;
@end
