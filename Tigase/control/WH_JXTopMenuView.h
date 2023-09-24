//
//  WH_JXTopMenuView.h
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//
#define MAX_MENU_ITEM 20

#import <UIKit/UIKit.h>

@interface WH_JXTopMenuView : UIImageView{
    BOOL       _showMore[MAX_MENU_ITEM];
    NSMutableArray* arrayBage;
}
@property (nonatomic,strong)  NSMutableArray* wh_arrayBtns;
@property (nonatomic,strong)  NSArray* wh_items;
@property (nonatomic, weak) NSObject* wh_delegate;
@property (nonatomic, assign) SEL		wh_onClick;
@property (nonatomic, assign) int       wh_selected;

-(void)WH_unSelectAll;
-(void)WH_selectOne:(int)n;
-(void)WH_setBadge:(int)n title:(NSString*)s;
-(void)WH_setTitle:(int)n title:(NSString*)s;
-(void)WH_showMore:(int)index onSelected:(SEL)onSelected;
@end
