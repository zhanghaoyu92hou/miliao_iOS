//
//  WH_selectCountry_WHVC.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_JXTableViewController.h"
#import <UIKit/UIKit.h>
@class WH_menuImageView;

@interface WH_selectCountry_WHVC: WH_JXTableViewController{
    NSMutableDictionary* _array;
    int _refreshCount;
}
@property(nonatomic,assign) BOOL showProvince;
@property(nonatomic,assign) BOOL showArea;
@property(nonatomic,assign) int selected;
@property(nonatomic,strong) NSString* selValue;
@property(nonatomic,weak) id delegate;
@property(nonatomic,assign) SEL didSelect;
@property(nonatomic,assign) int provinceId;
@property(nonatomic,assign) int cityId;
@property(nonatomic,assign) int areaId;

@end
