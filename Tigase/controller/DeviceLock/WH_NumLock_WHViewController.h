//
//  WH_NumLock_WHViewController.h
//  numLockTest
//
//  Created by banbu01 on 15-2-5.
//  Copyright (c) 2015年 com.koochat.test0716. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WH_NumLock_WHViewController;

@protocol WH_NumLock_WHViewControllerDelegate <NSObject>

- (void)numLockVCSetSuccess:(WH_NumLock_WHViewController *)numLockVC;

@end

@interface WH_NumLock_WHViewController : UIViewController

@property (nonatomic, assign) BOOL isSet;
@property (nonatomic, assign) BOOL isClose;
@property (nonatomic, weak) id<WH_NumLock_WHViewControllerDelegate> delegate;



@end
