//
//  WH_selectArea_WHVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>
@class WH_menuImageView;

@interface WH_selectArea_WHVC: WH_JXTableViewController{
    NSMutableDictionary* _array;
    NSArray* _keys;
    int _refreshCount;
    int _selMenu;
}
@property(assign)int parentId;
@property(nonatomic,strong)NSString* parentName;
@property(nonatomic,assign) int selected;
@property(nonatomic,strong) NSString* selValue;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
@end
