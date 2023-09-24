//
//  WH_JXNewFriend_WHViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_AddressbookSuper_WHController.h"
#import <UIKit/UIKit.h>

@class WH_JXFriendObject;
@class WH_JXFriend_WHCell;

@interface WH_JXNewFriend_WHViewController: WH_AddressbookSuper_WHController<UITextFieldDelegate>{
    NSMutableArray* _array;
    int _refreshCount;
    WH_JXFriendObject *_user;
    NSMutableDictionary* poolCell;
    int _friendStatus;
    WH_JXFriend_WHCell* _cell;
}


- (void)sp_getUserFollowSuccess:(NSString *)mediaCount;
@end
