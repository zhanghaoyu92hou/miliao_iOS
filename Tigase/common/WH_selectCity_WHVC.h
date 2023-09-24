//
//  WH_selectCity_WHVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>
@class WH_menuImageView;

@interface WH_selectCity_WHVC: WH_JXTableViewController{
    NSMutableDictionary* _array;
    NSArray* _keys;
    int _refreshCount;
}
@property(assign)int parentId;
@property(strong,nonatomic)NSString* parentName;
@property(nonatomic,assign) BOOL showArea;
@property(nonatomic,assign) int selected;
@property(nonatomic,strong) NSString* selValue;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
@property(nonatomic,assign) int cityId;
@property(nonatomic,assign) int areaId;
@end
