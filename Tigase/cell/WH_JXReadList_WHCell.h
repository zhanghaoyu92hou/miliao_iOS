//
//  WH_JXReadList_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2017/9/2.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_JXReadList_WHCell : UITableViewCell

@property (nonatomic, assign) int index;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, strong) WH_RoomData *room;

- (void) setData:(WH_JXUserObject *)obj;


- (void)sp_checkNetWorking;
@end
