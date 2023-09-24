//
//  WH_JXMain_WHViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>


#ifdef Live_Version
@class WH_JXLive_WHViewController;
#endif

@class WH_JXTabMenuView;
@class WH_JXMsg_WHViewController;
@class JXUserViewController;
@class WH_Addressbook_WHController;
@class WH_JXGroup_WHViewController;
@class WH_PSMy_WHViewController;
@class searchUserVC;
@class WH_WeiboViewControlle;
@class WH_OrganizTree_WHViewController;
@class JXSquareViewController;

@class WH_FindViewController;
@class WH_MineViewController;
@class WH_Friend_WHViewController;

@class WH_webpage_WHVC;

@class PSJobListVC;
@class PSAuditListVC;
@class PSWriteExamListVC;

@class WH_WKWebView_JXViewController;


@interface WH_JXMain_WHViewController : UIViewController<UIAlertViewDelegate>{
    WH_JXTabMenuView* _tb;
    UIView* _topView;
    
    UIViewController* _selectVC;

//    WH_JXFriend_WHViewController* _friendVC;
    WH_WeiboViewControlle* _weiboVC;
    JXSquareViewController *_squareVC;
    WH_JXGroup_WHViewController* _groupVC;
//    WH_OrganizTree_WHViewController *_organizVC;
    
    NSMutableArray * _friendArray;
}
//#ifdef Live_Version
//@property (strong, nonatomic) WH_JXLive_WHViewController *liveVC;
//#endif
@property (strong, nonatomic) WH_JXMsg_WHViewController* msgVc;
@property (strong, nonatomic) WH_Addressbook_WHController* addressbookVC;
@property (strong, nonatomic) WH_JXTabMenuView* tb;
@property (nonatomic, strong) UIImageView* bottomView;
@property (strong, nonatomic) UIButton* btn;
@property (strong, nonatomic) UIView* mainView;
@property (assign) BOOL IS_HR_MODE;

@property (nonatomic ,strong) WH_FindViewController *findVC;
@property (nonatomic ,strong) WH_MineViewController *mineVC;

@property (strong, nonatomic) WH_PSMy_WHViewController* psMyviewVC;

@property (nonatomic, strong) WH_webpage_WHVC *customTabVC;

@property (assign, nonatomic) NSInteger selTabBarIndex;

@property (nonatomic ,strong) WH_WKWebView_JXViewController *wkWebViewVC;


-(void)onAfterLogin;

-(void)doSelected:(int)n;


- (void)sp_getUsersMostLiked;
@end
