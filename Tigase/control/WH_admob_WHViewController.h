//
//  WH_admob_WHViewController.h
//  sjvodios
//
//  Created by  on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class WH_JXImageView;
@class JXLabel;

@interface WH_admob_WHViewController : UIViewController{
    ATMHud* _wait;
//    WH_admob_WHViewController* _pSelf;
}
@property(nonatomic,retain,setter = setLeftBarButtonItem:)  UIBarButtonItem *leftBarButtonItem;
@property(nonatomic,retain,setter = setRightBarButtonItem:) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic,assign) BOOL wh_isNotCreatewh_tableBody;
@property(nonatomic,assign) BOOL wh_isGotoBack;
@property(nonatomic,assign) BOOL wh_isFreeOnClose;
@property(nonatomic,strong) UIView *wh_tableHeader;
@property(nonatomic,strong) UIView *wh_tableFooter;
@property(nonatomic,strong) UIScrollView *wh_tableBody;
@property(nonatomic,assign) int wh_heightHeader;
@property(nonatomic,assign) int wh_heightFooter;
@property(nonatomic,strong) UIButton *wh_footerBtnMid;
@property(nonatomic,strong) UIButton *wh_footerBtnLeft;
@property(nonatomic,strong) UIButton *wh_footerBtnRight;
@property(nonatomic,strong) JXLabel  *wh_headerTitle;

-(void)createHeadAndFoot;

- (void)createHeadAndFootWithColor:(UIColor *)color;// 颜色更改

-(void)actionQuit;
-(void)onGotoHome;
@end
