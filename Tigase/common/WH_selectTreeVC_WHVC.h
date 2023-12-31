//
//  WH_selectTreeVC_WHVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>
@class WH_menuImageView;

@interface WH_selectTreeVC_WHVC: WH_JXTableViewController{
    NSMutableArray* _names;
    NSMutableArray* _ids;
    NSMutableArray* _typeNames;
    NSMutableArray* _typeIds;
    int _refreshCount;
}
@property(assign)int parentId;
@property(strong,nonatomic) NSString* parentName;
@property(nonatomic,assign) int selected;
@property(nonatomic,assign) int selNumber;
@property(nonatomic,strong) NSString* selValue;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
@property(assign) BOOL hasSubtree;
@property(nonatomic,strong) NSMutableArray* selNames;
@property(nonatomic,strong) NSMutableArray* selIds;
@end
