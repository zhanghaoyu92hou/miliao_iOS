//
//  WH_JXNear_WHVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//  附近的人

//#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>

@class WH_SearchData;
@class WH_JXLocMap_WHVC;
@class WH_JXGooMap_WHVC;
@interface WH_JXNear_WHVC: WH_admob_WHViewController{
    NSMutableArray* _array;
    int _refreshCount;

    UIView* _topView;
    UIButton* _apply;
    UILabel* _lb;
    //searchData* _search;
    //BOOL _bNearOnly;
}
@property (nonatomic,strong)WH_SearchData *wh_search;
@property (nonatomic,assign)BOOL wh_bNearOnly;
@property (nonatomic,assign)int wh_page;
@property (nonatomic,assign)BOOL wh_isSearch;

@property (nonatomic,strong) WH_JXLocMap_WHVC *wh_mapVC;
@property (nonatomic,strong) WH_JXGooMap_WHVC *wh_goomapVC;

-(void)onSearch;
-(void)WH_getServerData;
-(void)doSearch:(WH_SearchData*)p;

- (void)sp_getUsersMostLiked:(NSString *)mediaInfo;
@end
