//
//  WH_JXTabMenuView.h
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import <UIKit/UIKit.h>

@interface WH_JXTabMenuView : UIImageView{
    NSMutableArray*    _arrayBtns;
    
}
//@property (nonatomic,strong)  NSArray* arrayBtns;
@property (nonatomic,strong)  NSArray* wh_items;
@property (nonatomic,strong)  NSArray* wh_imagesNormal;
@property (nonatomic,strong)  NSArray* wh_imagesSelect;
@property (nonatomic, weak) NSObject* wh_delegate;
@property (nonatomic, assign) SEL		wh_onClick;
@property (nonatomic, assign) SEL		wh_onDragout;
@property (nonatomic, assign) int       wh_height;
@property (nonatomic, assign) NSInteger wh_selected;
@property (nonatomic, assign) BOOL      wh_isTabMenu;
@property (nonatomic, strong) NSString *wh_backgroundImageName;

-(void)wh_unSelectAll;
-(void)wh_selectOne:(int)n;
-(void)wh_setTitle:(int)n title:(NSString*)s;
-(void)wh_setBadge:(int)n title:(NSString*)s;
@end
