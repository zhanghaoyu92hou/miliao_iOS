//
//  WH_JXRoomMemberList_WHCell.h
//  Tigase_imChatT
//
//  Created by p on 2018/7/3.
//  Copyright © 2018年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "QCheckBox.h"

@interface WH_JXRoomMemberList_WHCell : UITableViewCell

@property (nonatomic, strong) memberData *data;

@property (nonatomic, assign) int role;

@property (nonatomic ,assign) int type;

@property (nonatomic ,assign) int roleMark;

@property (nonatomic, strong) WH_RoomData *room;

@property (nonatomic, strong) UILabel *roleLabel;

@property (nonatomic, strong) NSString *curManager;

//@property (nonatomic ,strong) QCheckBox *checkBtn;




@end
