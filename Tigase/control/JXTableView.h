//
//  JXTableView.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-5-27.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JXTableViewDelegate <NSObject>
@optional

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end


typedef enum : NSUInteger {
    EmptyTypeNoData,
    EmptyTypeNetWorkError,
} EmptyType;

@interface  JXTableView : UITableView
{
    UILabel *_tipLabel;
    UIButton *_tipBtn;
@private
//    id _touchDelegate;
    NSMutableArray* _pool;
}

@property (nonatomic,weak) id<JXTableViewDelegate> wh_touchDelegate;
@property (nonatomic,strong) UIImageView *wh_emptyView;

- (void)WH_gotoLastRow:(BOOL)animated;
- (void)WH_gotoFirstRow:(BOOL)animated;
- (void)WH_gotoRow:(int)n;

- (void)WH_showEmptyImage:(EmptyType)emptyType;
- (void)WH_hideEmptyImage;
- (void)WH_onAfterLoad;

-(void)WH_addToPool:(id)p;
-(void)WH_delFromPool:(id)p;
//-(void)clearPool:(BOOL)delObj;

-(void)WH_reloadRow:(int)n section:(int)section;//刷新一行
-(void)WH_insertRow:(int)n section:(int)section;//增加一行
-(void)WH_deleteRow:(int)n section:(int)section;//删除一行
@end
