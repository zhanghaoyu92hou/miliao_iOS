//
//  WH_JXWaitView.h
//  Tigase_imChatT
//
//  Created by flyeagleTang on 17/1/13.
//  Copyright © 2019年 YanZhenKui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WH_JXWaitView : UIActivityIndicatorView{
    UIView* _parent;
}

-(id)initWithParent:(UIView*)parent;
-(void)WH_start;
-(void)WH_stop;
-(void)WH_adjust;

@property (nonatomic, strong,setter=setParent:) UIView* parent;//可动态改变父亲

@end
