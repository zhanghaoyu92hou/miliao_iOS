//
//  WH_JXSelectAddressBook_WHVC.h
//  Tigase_imChatT
//
//  Created by p on 2019/4/3.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "WH_JXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class WH_JXSelectAddressBook_WHVC;

@protocol WH_JXSelectAddressBook_WHVCDelegate <NSObject>

- (void)selectAddressBookVC:(WH_JXSelectAddressBook_WHVC *)selectVC doneAction:(NSArray *)array;

@end

@interface WH_JXSelectAddressBook_WHVC : WH_JXTableViewController

@property (nonatomic, weak) id<WH_JXSelectAddressBook_WHVCDelegate> delegate;



NS_ASSUME_NONNULL_END
- (void)sp_checkNetWorking;
@end
