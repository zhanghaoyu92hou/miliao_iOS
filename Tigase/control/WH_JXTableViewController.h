//
//  WH_JXTableViewController.h
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "JXTableView.h"
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"

@class JXLabel;
@class JXTableView;
@protocol JXTableViewDelegate;

@interface WH_JXTableViewController : UIViewController<JXTableViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    BOOL _isLoading;
    //refresh一次page＋1
    int  _page;
    
    JXTableView* _table;
    
    int _tableHeight;    
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    ATMHud* _wait;
//    WH_JXTableViewController* _pSelf;
    int _oldRowCount;//翻页之前的行数
    NSTimeInterval _lastScrollTime;
}

@property (nonatomic, strong) JXTableView* tableView;

@property(nonatomic,assign) BOOL wh_isGotoBack;
@property(nonatomic,assign) BOOL wh_isFreeOnClose;
@property(nonatomic,assign) BOOL wh_isShowHeaderPull;
@property(nonatomic,assign) BOOL wh_isShowFooterPull;
@property(nonatomic,strong) UIView *wh_tableHeader;
@property(nonatomic,strong) UIView *wh_tableFooter;
@property(nonatomic,assign) int wh_heightHeader;
@property(nonatomic,assign) int wh_heightFooter;
@property(nonatomic,strong) UIButton *wh_footerBtnMid;
@property(nonatomic,strong) UIButton *wh_footerBtnLeft;
@property(nonatomic,strong) UIButton *wh_footerBtnRight;
@property(nonatomic,strong) JXLabel  *wh_headerTitle;
@property(nonatomic,strong) UIImageView *headerBGImgView;
@property(nonatomic,strong) MJRefreshFooterView *footer;
@property(nonatomic,strong) MJRefreshHeaderView *header;
@property (nonatomic, strong) UIButton *wh_gotoBackBtn;

@property (nonatomic ,assign) Boolean isClose; //更换返回按钮

@property (nonatomic, assign) int myTableViewStyle;
@property(nonatomic, assign) int isFrom;//1:只加footer（上拉加载）2.只加hearer（下拉刷新）。isFrom不存在时，footer和header都加。



-(void)WH_setupStrings;
-(void)WH_stopLoading;
-(void)WH_createHeadAndFoot;
-(void)WH_scrollToPageUp;
-(void)WH_scrollToPageDown;
-(void)WH_getServerData;
-(void)actionQuit;
-(void)WH_onGotoHome;
-(void)WH_doQuit;
-(void)WH_actionTitle:(JXLabel*)sender;
-(void)WH_doAutoScroll:(NSIndexPath*)indexPath;

//获取_table
- (JXTableView *)WH_getTableView;
- (void)WH_moveSelfViewToLeft;
- (void)WH_resetViewFrame;
@end
