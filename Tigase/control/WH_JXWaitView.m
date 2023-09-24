//
//  WH_JXWaitView.m
//  Tigase_imChatT
//
//  Created by flyeagleTang on 17/1/13.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import "WH_JXWaitView.h"

@implementation WH_JXWaitView

-(id)initWithParent:(UIView*)value{
    self = [super init];
    if(self){
        if(value != nil)
            _parent = value;
        else
            _parent = [UIApplication sharedApplication].keyWindow;
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self WH_adjust];
//        [_parent addSubview:self];
    }
    return self;
}

-(void)dealloc{
//    [super dealloc];
}

-(void)WH_start{
    [self startAnimating];
    self.hidden = NO;
}

-(void)WH_stop{
    [self stopAnimating];
    self.hidden = YES;
}

-(void)WH_adjust{
    if(_parent==nil)
        return;
    [_parent addSubview:self];
    self.center = CGPointMake(_parent.frame.size.width/2, _parent.frame.size.height/2);
}

-(void)setParent:(UIView *)value{
    [self WH_adjust];
    if([_parent isEqual:value])
        return;
//    [_parent release];
//    _parent = [value retain];
    _parent = value;
    [self WH_adjust];
}

@end
