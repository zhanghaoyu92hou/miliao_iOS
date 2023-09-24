//
//  WH_JXSearchUser_WHVC.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class WH_SearchData;


typedef NS_ENUM(NSInteger, JXSearchType) {
    JXSearchTypeUser,           // 好友
    JXSearchTypePublicNumber,   // 公众号
};


@interface WH_JXSearchUser_WHVC : WH_admob_WHViewController{
    UITextField* _name;
    UITextField* _minAge;
    UITextField* _maxAge;
    UILabel* _date;
    UILabel* _sex;
    UILabel* _industry;
    UILabel* _function;
    
    UIImage* _image;
    WH_JXImageView* _head;
    
    NSMutableArray* _values;
    NSMutableArray* _numbers;
}

@property (nonatomic, assign) JXSearchType type;
@property (nonatomic,strong) WH_SearchData* job;
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;




@end
