//#define SERVER_URL @"http://pull99.a8.com/live/1484986711488827.flv?ikHost=ws&ikOp=1&CodecInfo=8192"


//
//  AppDelegate.h
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import "JXNavigation.h"
#import "WH_JXDidPushObj.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif



@class emojiViewController;
@class WH_JXMain_WHViewController;
@class WH_JXGroup_WHViewController;
@class leftViewController;
@class JXServer;
@class WH_VersionManageTool;
@class WH_JXConstant;
@class WH_JXUserObject;
@class WH_JXMeetingObject;
@class WH_JXCommonService;
@class WH_NumLock_WHViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,PKPushRegistryDelegate,UNUserNotificationCenterDelegate>{
     
        UIButton * _suspensionBtn;//悬浮窗按钮
        CGRect   _subWindowFrame;
        CGRect   _subWindowInitFrame;
        UIImageView *imgV; //悬浮按钮图片
}

@property (strong, nonatomic) UIWindow *window;

// 可用于view显示在最上层,不受底下页面干扰
@property (strong, nonatomic) UIView *subWindow;

@property (assign, nonatomic)  BOOL  isHaveTopWindow;

@property (assign, nonatomic)  BOOL  isINTopWindow;


@property (strong, nonatomic) UIView *subTopWindow;

@property (nonatomic, strong) WH_NumLock_WHViewController *numLockVC;


#if TAR_IM
#ifdef Meeting_Version
@property (nonatomic,strong)  WH_JXMeetingObject* jxMeeting;
@property (nonatomic, strong) NSUUID * uuid;
#endif
#endif


@property (strong, nonatomic) emojiViewController* faceView;
@property (strong, nonatomic) WH_JXMain_WHViewController *mainVc;

@property (strong, nonatomic) NSString * isShowRedPacket;
@property (assign, nonatomic) double myMoney;

@property (nonatomic, strong) WH_JXCommonService *commonService;

@property (nonatomic, strong) JXNavigation *navigation;
@property (nonatomic, assign) BOOL isShowDeviceLock;

@property (nonatomic, strong) WH_JXDidPushObj *didPushObj;

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timer1;

-(void) showAlert: (NSString *) message;
-(UIAlertView *) showAlert: (NSString *) message delegate:(id)delegate;
- (UIAlertView *) showAlert: (NSString *) message delegate:(id)delegate tag:(NSUInteger)tag onlyConfirm:(BOOL)onlyConfirm;

- (void)copyDbWithUserId:(NSString *)userId;

-(void)showMainUI;
-(void)showLoginUI;

-(void)endCall;

- (void)showSuspensionWindow;
- (void)hideWebOnWindow;
/**
 网络状态监听
 */
- (void)networkStatusChange;

@end
