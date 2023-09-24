//
//  WH_JXDatePicker.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 15-1-7.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXDatePicker : UIView{
    JXLabel* _sel;
}
@property(nonatomic,strong) UIDatePicker* wh_datePicker;
@property(nonatomic,weak) id wh_delegate;
@property(assign) SEL wh_didSelect;
@property(assign) SEL wh_didCancel;
@property(assign) SEL wh_didChange;
@property(nonatomic,strong) NSString* wh_hint;
//-(NSDate*)date;

@property(nonatomic,strong) NSDate* wh_date;

@end
