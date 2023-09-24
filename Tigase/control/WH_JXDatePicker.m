//
//  JXDatePicker.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 15-1-7.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "WH_JXDatePicker.h"

@implementation WH_JXDatePicker
@synthesize wh_delegate,wh_didCancel,wh_datePicker,wh_didSelect,wh_didChange;

- (id)initWithFrame:(CGRect)frame{
    int h = 40;
    
    int height = 226;
    if (THE_DEVICE_HAVE_HEAD) {
        height = 235 + 26;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.wh_hint = Localized(@"JXDatePicker_Sel");
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - height, JX_SCREEN_WIDTH, height)];
        [self addSubview:view];
        
        wh_datePicker = [[UIDatePicker alloc] init];
        wh_datePicker.datePickerMode = UIDatePickerModeDate;
        wh_datePicker.locale = [NSLocale currentLocale];
        if (@available(iOS 13.4, *)) {
            wh_datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        wh_datePicker.backgroundColor = [UIColor whiteColor];
        wh_datePicker.date = [NSDate date];
        wh_datePicker.maximumDate = [NSDate date];
        [wh_datePicker addTarget:self action:@selector(onDate:) forControlEvents:UIControlEventValueChanged];
        wh_datePicker.frame = CGRectMake(0, h, JX_SCREEN_WIDTH, height-h);
        [view addSubview:wh_datePicker];
        //        [datePicker release];
        
        

        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, h)];
        [topView setBackgroundColor:HEXCOLOR(0xffffff)];
        [view addSubview:topView];
        
        _sel = [[JXLabel alloc] initWithFrame:CGRectMake(h, 0, topView.frame.size.width-h*2, h)];
        _sel.font = sysFontWithSize(16);
        _sel.textAlignment = NSTextAlignmentCenter;
        _sel.textColor = [UIColor grayColor];
        _sel.wh_delegate = self;
        [_sel setBackgroundColor:HEXCOLOR(0xffffff)];
        _sel.didTouch = @selector(onClose);
        [topView addSubview:_sel];
        //        [_sel release];
        
        WH_JXImageView* iv = [[WH_JXImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
        iv.image = [UIImage imageNamed:@"title_back"];
        iv.wh_delegate = self;
        iv.didTouch = @selector(onClose);
        [topView addSubview:iv];
        //        [iv release];
        
        //        iv = [[WH_JXImageView alloc]initWithFrame:CGRectMake(frame.size.width-h, 0, h, h)];
        //        iv.image = [UIImage imageNamed:@"newicon_selected_done"];
        //        iv.wh_delegate = self;
        //        iv.didTouch = @selector(onSelect);
        //        [view addSubview:iv];
        //        [iv release];
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectBtn setBackgroundColor:HEXCOLOR(0xffffff)];
        [selectBtn setFrame:CGRectMake(frame.size.width-h, 0, h, h)];
        [topView addSubview:selectBtn];
        [selectBtn addTarget:self action:@selector(onSelect) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *btnTitle = [UIFactory WH_create_WHLabelWith:CGRectMake(0, 0, selectBtn.frame.size.width, CGRectGetHeight(selectBtn.frame)) text:@"确定" font:sysFontWithSize(14) textColor:HEXCOLOR(0x0093FF) backgroundColor:view.backgroundColor];
        [selectBtn addSubview:btnTitle];
        
        
    }
    return self;
}

-(void)dealloc{
    self.wh_hint = nil;
    //    [super dealloc];
}

-(void)onClose{
    [self removeFromSuperview];
    if (wh_delegate && [wh_delegate respondsToSelector:wh_didCancel])
        //		[delegate performSelector:didCancel withObject:nil];
        [wh_delegate performSelectorOnMainThread:wh_didCancel withObject:nil waitUntilDone:NO];
}

-(void)onSelect{
    [self removeFromSuperview];
    if (wh_delegate && [wh_delegate respondsToSelector:wh_didSelect])
        //		[delegate performSelector:didSelect withObject:self];
        [wh_delegate performSelectorOnMainThread:wh_didSelect withObject:self waitUntilDone:NO];
}

- (void)onDate:(UIView*)sender{
    NSString* s = nil;
    if(wh_datePicker.datePickerMode == UIDatePickerModeDateAndTime)
        s = @"yyyy-MM-dd HH:mm";
    if(wh_datePicker.datePickerMode == UIDatePickerModeDate)
        s = @"yyyy-MM-dd";
    if(wh_datePicker.datePickerMode == UIDatePickerModeTime)
        s = @"HH:mm:ss";
    
    _sel.text = [NSString stringWithFormat:@"%@:%@",self.wh_hint,[TimeUtil formatDate:wh_datePicker.date format:s]];
    if(sender)
        if (wh_delegate && [wh_delegate respondsToSelector:wh_didChange])
            //            [delegate performSelector:wh_didChange withObject:self];
            [wh_delegate performSelectorOnMainThread:wh_didChange withObject:self waitUntilDone:NO];
}

//-(NSDate*)date{
//    return wh_datePicker.date;
//}

- (NSDate *)wh_date {
    return wh_datePicker.date;
}

//-(void)setDate:(NSDate *)p{
//    //解决服务器超时 为null crash
//    if (p) {
//        wh_datePicker.date = p;
//        [self onDate:nil];
//    }
//}

- (void)setWh_date:(NSDate *)p {
    if (p) {
        wh_datePicker.date = p;
        [self onDate:nil];
        
    }
}

- (void)didMoveToSuperview{
    wh_datePicker.tag = self.tag;
    [self onDate:nil];
    [super didMoveToSuperview];
}

@end
