//
//  WH_JXInputValue_WHVC.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 14-6-10.
//  Copyright (c) 2019年 YZK. All rights reserved.
//

#import "WH_admob_WHViewController.h"
@class WH_SearchData;

@interface WH_JXInputValue_WHVC : WH_admob_WHViewController<UITextViewDelegate>{
    UITextView* _name;
}

@property (nonatomic ,strong) UITextView *textView;
@property (nonatomic ,strong) UILabel *textDefaultLabel;

@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) NSString* value;
@property(assign) SEL didSelect;
@property (nonatomic, assign) BOOL isLimit;
@property (nonatomic, assign) NSInteger limitLen;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) BOOL isRoomNum;
@property (nonatomic ,assign) BOOL allowForceNotice;

@end
